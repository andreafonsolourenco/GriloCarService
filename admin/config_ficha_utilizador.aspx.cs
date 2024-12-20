using System;
using System.Web.Services;
using System.Data;


public partial class config_ficha_utilizador : System.Web.UI.Page
{
    string id = "null";

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            id = Request.QueryString["id"];
        }
        catch (Exception)
        {
        }

        txtAux.Value = id;
        getTipoUtilizadores();
    }



    [WebMethod]
    public static string saveData(string id, string nome, string email, string password, string tlm, string notas, string ativo, string codigo, string id_tipo, string idUser)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "1", retMessage = "Dados guardados com sucesso.";

        sql = string.Format(@"  DECLARE @idUser int = {0};
	                            DECLARE @id INT = {1};
	                            DECLARE @nome varchar(max) = '{2}';
	                            DECLARE @codigo varchar(500) = '{3}';
	                            DECLARE @email varchar(max) = '{4}';
	                            DECLARE @telemovel varchar(50) = '{5}';
	                            DECLARE @ativo bit = {6};
	                            DECLARE @password varchar(250) = '{7}';
	                            DECLARE @notas varchar(max) = '{8}';
	                            DECLARE @id_tipo int = {9};
	                            DECLARE @ret int;
                                DECLARE @retMsg VARCHAR(max);

                                EXECUTE CRIA_EDITA_UTILIZADOR @idUser, @id, @nome, @codigo, @email, @telemovel, @ativo, @password, @notas, @id_tipo, @ret OUTPUT, @retMsg OUTPUT
                                SELECT @ret ret, @retMsg retMsg ", idUser, String.IsNullOrEmpty(id) ? "NULL" : id, nome, codigo, email, tlm, ativo, password, notas, id_tipo);


        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
            retMessage = oDs.Tables[0].Rows[0]["retMsg"].ToString().Trim();
        }

        return ret + "<#SEP#>" + retMessage;
    }


    [WebMethod]
    public static string getData(string id)
    {
        const string sep = "<#SEP#>";
        string sql = "", nome = "", codigo = "", email = "", telemovel = "", s_ativo = "", password = "", notas = "", id_tipo = "", tipo = "", s_administrador = "";
        bool ativo = false, administrador = false;

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  DECLARE @id int = {0}
                                DECLARE @ativo bit;
                                DECLARE @user varchar(150);
                                DECLARE @pass varchar(60);
                                DECLARE @id_tipo int;
                                select
                                    id,
	                                nome,
	                                codigo,
	                                email,
	                                telemovel,
	                                ativo,
	                                password,
	                                notas,
	                                id_tipo,
	                                tipo,
	                                administrador
                                from REPORT_USERS(@id, @user, @pass, @ativo, @id_tipo)", id);
        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            id_tipo = oDs.Tables[0].Rows[0]["id_tipo"].ToString().Trim();
            tipo = oDs.Tables[0].Rows[0]["tipo"].ToString().Trim();
            nome = oDs.Tables[0].Rows[0]["nome"].ToString().Trim();
            codigo = oDs.Tables[0].Rows[0]["codigo"].ToString().Trim();
            email = oDs.Tables[0].Rows[0]["email"].ToString().Trim();
            password = oDs.Tables[0].Rows[0]["password"].ToString().Trim();
            telemovel = oDs.Tables[0].Rows[0]["telemovel"].ToString().Trim();
            notas = oDs.Tables[0].Rows[0]["notas"].ToString().Trim();
            ativo = Convert.ToBoolean(oDs.Tables[0].Rows[0]["ativo"]);
            administrador = Convert.ToBoolean(oDs.Tables[0].Rows[0]["administrador"]);

            s_ativo = ativo ? "true" : "false";
            s_administrador = administrador ? "true" : "false";
        }

        // Prepara o retorno dos dados
        return nome + sep +
              codigo + sep +
              email + sep +
              password + sep +
              telemovel + sep +
              notas + sep +
              id_tipo + sep +
              tipo + sep +
              s_ativo + sep +
              s_administrador;
    }

    private void getTipoUtilizadores()
    {
        string sql = "", html = "";
        string id = "", nome = "";

        DataSqlServer oDB = new DataSqlServer();



        html += @"  <div class='form-group'>
                    <label class='form-control-label' for='input-username'>Tipo de Utilizador</label>
                    <select id='ddlTipo' onchange='verifyUserType();' class='form-control form-control-alternative'>";


        sql = @"declare @id int;
                SELECT
                    id,
		            nome,
                    administrador
                FROM REPORT_USERTYPE(@id)
                order by administrador desc, nome asc ";


        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int i = 0; i < oDs.Tables[0].Rows.Count; i++)
            {
                id = oDs.Tables[0].Rows[i]["id"].ToString().Trim();
                nome = oDs.Tables[0].Rows[i]["nome"].ToString().Trim();


                html += @"<option value='" + id + @"'>" + nome + @"</option>";
            }
        }
        else
        {
            html += @"<option value='0'>Não existem tipos de utilizador a apresentar</option>";
        }


        html += "</select></div>";


        divTipoUtilizador.InnerHtml = html;
    }

    [WebMethod]
    public static string checkAdmin(int id_tipo)
    {
        string sql = "", ret = "";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  declare @id int = {0};
                                SELECT
                                    administrador
                                FROM REPORT_USERTYPE(@id)", id_tipo);
        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            for (int i = 0; i < oDs.Tables[0].Rows.Count; i++)
            {
                return Convert.ToBoolean(oDs.Tables[0].Rows[i]["administrador"]) ? "true" : "false";
            }
        }

        return "false";
    }
}