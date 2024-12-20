using System;
using System.Web.Services;
using System.Data;
using System.Net;
using System.IO;
using System.Text;
using System.Net.Mail;

public partial class lista_logs : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string getTotais(string id)
    {
        string sql = "", html = "";
        string label1 = "", total1 = "", rodape1 = "", label2 = "", total2 = "", rodape2 = "", label3 = "", total3 = "", rodape3 = "", label4 = "", total4 = "", rodape4 = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = @"    SET LANGUAGE Portuguese 
                    declare @dataatual datetime = getdate();

                    select
                        label1,
                        total1,
                        rodape1,
                        label2,
                        total2,
                        rodape2,
                        label3,
                        total3,
                        rodape3,
                        label4,
                        total4,
                        rodape4
                    from REPORT_DASHBOARD_DATA(@dataatual)";

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            label1 = oDs.Tables[0].Rows[0]["label1"].ToString().Trim();
            total1 = oDs.Tables[0].Rows[0]["total1"].ToString().Trim();
            rodape1 = oDs.Tables[0].Rows[0]["rodape1"].ToString().Trim();

            label2 = oDs.Tables[0].Rows[0]["label2"].ToString().Trim();
            total2 = oDs.Tables[0].Rows[0]["total2"].ToString().Trim();
            rodape2 = oDs.Tables[0].Rows[0]["rodape2"].ToString().Trim();

            label3 = oDs.Tables[0].Rows[0]["label3"].ToString().Trim();
            total3 = oDs.Tables[0].Rows[0]["total3"].ToString().Trim();
            rodape3 = oDs.Tables[0].Rows[0]["rodape3"].ToString().Trim();

            label4 = oDs.Tables[0].Rows[0]["label4"].ToString().Trim();
            total4 = oDs.Tables[0].Rows[0]["total4"].ToString().Trim();
            rodape4 = oDs.Tables[0].Rows[0]["rodape4"].ToString().Trim();
        }


        html = label1 + "@" + total1 + "@" + rodape1 + "@" + label2 + "@" + total2 + "@" + rodape2 + "@" + label3 + "@" + total3 + "@" + rodape3 + "@" + label4 + "@" + total4 + "@" + rodape4;

        return html;
    }

    [WebMethod]
    public static string getGrelha(string pesquisa, string order, string typeQuery, string initialDate, string finalDate, string type, string idUser)
    {
        string sql = "", html = "";
        string id = "", id_user = "", name_user = "", code_user = "", tipo = "", notas = "", id_relacionado = "";
        string data = "", data_it = "", data_uk = "", data_jp = "", data_odbc = "";

        DataSqlServer oDB = new DataSqlServer();

        html += @" <table class='table align-items-center table-flush'>
		        <thead class='thead-light'>
		              <tr>
			            <th scope='col' class='pointer th_text' onclick='ordenaData();'>Data</th>
			            <th scope='col' class='pointer th_text' onclick='ordenaUser();'>Utilizador</th>
                        <th scope='col' class='pointer th_text' onclick='ordenaTipo();'>Tipo</th>
                        <th scope='col' class='pointer th_text' onclick='ordenaLog();'>Registo</th>
                        <th scope='col'></th>
		              </tr>
		            </thead> <tbody>";

        sql = String.Format(@"  set dateformat dmy;
                                declare @id int;
                                declare @tipo varchar(200) = {3};
                                declare @id_relacionado int;
                                declare @initialDate date = '{4}';
                                declare @finalDate date = '{5}';
                                declare @idUser int = {6};

                                select 
	                                id,
		                            id_user,
		                            name_user,
		                            code_user,
		                            tipo,
		                            notas,
		                            id_relacionado,
		                            data_log,
		                            data_log_it, --dd-mm-yyyy
		                            data_log_uk, --dd/mm/yyyy
		                            data_log_jp, --yyyy/mm/dd
		                            data_log_odbc --yyyy-mm-dd
                                from [REPORT_LOGS](@id, @tipo, @id_relacionado, @initialDate, @finalDate, @idUser)
                                where (name_user like {0} or code_user like {0} or notas like {0}) {2}
                                {1}",
                                    String.Format("'%{0}%'", pesquisa),
                                    order,
                                    String.IsNullOrEmpty(type) ? typeQuery : "",
                                    String.IsNullOrEmpty(type) ? "NULL" : String.Format("'{0}'", type),
                                    initialDate,
                                    finalDate,
                                    String.IsNullOrEmpty(idUser) ? "NULL" : idUser);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    id = oDs.Tables[j].Rows[i]["id"].ToString().Trim();
                    id_user = oDs.Tables[j].Rows[i]["id_user"].ToString().Trim();
                    name_user = oDs.Tables[j].Rows[i]["name_user"].ToString().Trim();
                    code_user = oDs.Tables[j].Rows[i]["code_user"].ToString().Trim();
                    tipo = oDs.Tables[j].Rows[i]["tipo"].ToString().Trim();
                    notas = oDs.Tables[j].Rows[i]["notas"].ToString().Trim();
                    id_relacionado = oDs.Tables[j].Rows[i]["id_relacionado"].ToString().Trim();
                    data = oDs.Tables[j].Rows[i]["data_log"].ToString().Trim();
                    data_it = oDs.Tables[j].Rows[i]["data_log_it"].ToString().Trim();
                    data_uk = oDs.Tables[j].Rows[i]["data_log_uk"].ToString().Trim();
                    data_jp = oDs.Tables[j].Rows[i]["data_log_jp"].ToString().Trim();
                    data_odbc = oDs.Tables[j].Rows[i]["data_log_odbc"].ToString().Trim();

                    html += String.Format(@"    <tr class='pointer' ondblclick='visualizar({0});'>
		                                            <td><span>{1}</span></td>
		                                            <td><span>{2}</span></td>
                                                    <td><span>{3}</span></td>
		                                            <td><span>{4}</span></td>
		                                            <td class='text-right'>
		                                                <div class='dropdown'>
			                                                <a class='btn btn-sm btn-icon-only text-light' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
			                                                    <i class='fas fa-ellipsis-v'></i>
			                                                </a>
			                                                <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                                                <a class='dropdown-item' href='#' onclick='visualizar({0});'>Visualizar</a>
			                                                </div>
		                                                </div>
		                                            </td>                    
	                                            </tr>", id, data_uk, name_user, tipo, notas);
                }
            }
        }
        else
        {
            html += "  <tr><td colspan='3'>Não existem registos de atividade a apresentar.</td></tr> ";
        }


        html += "  </tbody> </table>";


        return html;
    }

    [WebMethod]
    public static string getRetornoURL(string url)
    {
        try
        {
            WebClient client = new WebClient();

            client.Headers.Add("User-Agent: BrowseAndDownload");
            ServicePointManager.Expect100Continue = true;
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            string ret = client.DownloadString(url);

            //TRIMA a string        
            ret = ret.Trim();

            return ret;
        }
        catch (Exception)
        {
            return "";
        }
    }
}