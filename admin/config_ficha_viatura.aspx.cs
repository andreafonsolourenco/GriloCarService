using System;
using System.Web.Services;
using System.Data;
using System.Net;

public partial class config_ficha_viatura : System.Web.UI.Page
{
    string id = "null";

    protected void Page_Load(object sender, EventArgs e)
    {
        if(!IsPostBack)
        {
            try
            {
                id = Request.QueryString["id"];
            }
            catch (Exception)
            {
            }

            txtAux.Value = id;
        }
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

    [WebMethod]
    public static string saveData(string idUser, string id, string marca, string modelo, string ano, string matricula, string notes)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "1", retMessage = "Dados guardados com sucesso.";
        
        sql = string.Format(@"   declare @userid int = {0};
                                 declare @id int = {1};
	                             declare @marca varchar(max) = '{2}';
	                             declare @modelo varchar(max) = '{3}';
	                             declare @matricula varchar(20) = '{5}';
	                             declare @ano int = {4};
                                 declare @fromCsvFile bit = 0;
                                 declare @notas varchar(max) = '{6}';
                                 declare @ret int;
                                 declare @retMsg VARCHAR(max);

                                 EXEC CRIA_EDITA_CAR @userid, @id, @marca, @modelo, @ano, @matricula, @notas, @fromCsvFile, @ret OUTPUT, @retMsg OUTPUT

                                 select @ret as ret, @retMsg as retMsg", idUser, id, marca, modelo, ano, matricula, notes);

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
        string sql = "", marca = "", modelo = "", ano = "", matricula = "", notas = "";

        const string sep = "<#SEP#>";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  set dateformat dmy
                                declare @id int = {0};
                                declare @matricula varchar(20);

                                select
	                                id,
	                                marca,
	                                modelo,
	                                ano,
	                                matricula,
	                                notas
                                from report_cars(@id, @matricula)", id);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            marca = oDs.Tables[0].Rows[0]["marca"].ToString().Trim();
            modelo = oDs.Tables[0].Rows[0]["modelo"].ToString().Trim();
            ano = oDs.Tables[0].Rows[0]["ano"].ToString().Trim();
            matricula = oDs.Tables[0].Rows[0]["matricula"].ToString().Trim();
            notas = oDs.Tables[0].Rows[0]["notas"].ToString().Trim();
        }

        // Prepara o retorno dos dados
        return marca + sep +
              modelo + sep +
              ano + sep +
              matricula + sep +
              notas;
    }
}