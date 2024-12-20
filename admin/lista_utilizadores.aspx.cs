using System;
using System.Web.Services;
using System.Data;

public partial class lista_utilizadores : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string getGrelha(string pesquisa, string order, string idUser)
    {
        string sql = "", html = "", htmlOptions = "";
        string id = "", tipo = "", nome = "", codigo = "", corAtivo = "", corAdmin = "";
        bool ativo = false, admin = false, eliminar = false;

        DataSqlServer oDB = new DataSqlServer();

        html += @" <table class='table align-items-center table-flush'>
		        <thead class='thead-light'>
		              <tr>
			            <th scope='col' class='pointer' onclick='ordenaNome();'>Nome</th>
			            <th scope='col' class='pointer' onclick='ordenaCodigo();'>Código</th>
			            <th scope='col' class='pointer' onclick='ordenaPerfil();'>Tipo</th>
                        <th scope='col' class='pointer' onclick='ordenaAdmin();' style='text-align: center;'>Administrador</th>
                        <th scope='col' class='pointer' onclick='ordenaAtivo();' style='text-align: center;'>Ativo</th>
			            <th scope='col'></th>
		              </tr>
		            </thead> <tbody>";


        sql = String.Format(@"  declare @id int;
                                DECLARE @ativo bit;
                                DECLARE @user varchar(150);
                                DECLARE @pass varchar(60);
                                declare @id_tipo int;
                                declare @idUser int = {2};
                                declare @admin bit = (select administrador from report_users(@idUser, @user, @pass, 1, @id_tipo))

                                IF(@admin = 1)
                                begin
                                    select
	                                    id,
	                                    nome,
	                                    codigo,
	                                    ativo,
	                                    tipo,
	                                    administrador,
                                        1 as eliminar
                                    from REPORT_USERS(@id, @user, @pass, @ativo, @id_tipo)
                                    where (nome like {0} or codigo like {0} or tipo like {0})
                                    {1}
                                end
                                else
                                begin
                                    select
	                                    id,
	                                    nome,
	                                    codigo,
	                                    ativo,
	                                    tipo,
	                                    administrador,
                                        0 as eliminar
                                    from REPORT_USERS(@idUser, @user, @pass, @ativo, @id_tipo)
                                    where (nome like {0} or codigo like {0} or tipo like {0})
                                    {1}
                                end", String.Format("'%{0}%'", pesquisa), order, idUser);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int i = 0; i < oDs.Tables[0].Rows.Count; i++)
            {
                id = oDs.Tables[0].Rows[i]["id"].ToString().Trim();
                tipo = oDs.Tables[0].Rows[i]["tipo"].ToString().Trim();
                nome = oDs.Tables[0].Rows[i]["nome"].ToString().Trim();
                codigo = oDs.Tables[0].Rows[i]["codigo"].ToString().Trim();
                ativo = Convert.ToBoolean(oDs.Tables[0].Rows[i]["ativo"]);
                admin = Convert.ToBoolean(oDs.Tables[0].Rows[i]["administrador"]);
                eliminar = Convert.ToBoolean(oDs.Tables[0].Rows[i]["eliminar"]);

                if (ativo) corAtivo = "#2DCE89";
                else corAtivo = "#F5365C";

                if (admin) corAdmin = "#2DCE89";
                else corAdmin = "#F5365C";

                if(eliminar)
                {
                    htmlOptions = String.Format(@"  <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
			                                            <a class='dropdown-item' href='#' onclick='editar({0});'>Editar</a>
                                                        <a class='dropdown-item' href='#' onclick='apaga({0});'>Eliminar</a>
			                                        </div>", id);
                }
                else
                {
                    htmlOptions = String.Format(@"  <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
			                                            <a class='dropdown-item' href='#' onclick='editar({0});'>Editar</a>
			                                        </div>", id);
                }

                html += String.Format(@"    <tr class='pointer' ondblclick='editar({0});'> 
		                                        <td><span>{1}</span></td>
		                                        <td><span>{2}</span></td>
                                                <td><span>{3}</span></td>
                                                <td style='text-align: center;'>
		                                            <span class='badge badge-dot mr-4'>
			                                            <i class='bg-success' style='height: 20px; width: 20px; background-color:{4} !important' ></i>
		                                            </span>
		                                        </td>
                                                <td style='text-align: center;'>
		                                            <span class='badge badge-dot mr-4'>
			                                            <i class='bg-success' style='height: 20px; width: 20px; background-color:{5} !important' ></i>
		                                            </span>
		                                        </td>
		                                        <td class='text-right'>
		                                            <div class='dropdown'>
			                                            <a class='btn btn-sm btn-icon-only text-light' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
			                                                <i class='fas fa-ellipsis-v'></i>
			                                            </a>
                                                        {6}
		                                            </div>
		                                        </td>                    
	                                        </tr>", id, nome, codigo, tipo, corAdmin, corAtivo, htmlOptions);

            }
        }


        html += "  </tbody> </table>";


        return html;
    }

    [WebMethod]
    public static string delRow(string id, string idUser)
    {
        string sql = "", ret = "1", retMessage = "Registo eliminado com sucesso.";
        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  DECLARE @id INT = {0};
                                DECLARE @idUser int = {1};
                                DECLARE @ret int
                                DECLARE @retMsg VARCHAR(255)

                                EXEC DELETE_USER @iduser, @id, @ret OUTPUT, @retMsg OUTPUT
                                SELECT @ret ret, @retMsg retMsg ", id, idUser);


        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
            retMessage = oDs.Tables[0].Rows[0]["retMsg"].ToString().Trim();
        }

        return ret + "<#SEP#>" + retMessage;
    }
}