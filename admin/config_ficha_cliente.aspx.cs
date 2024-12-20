using System;
using System.Web.Services;
using System.Data;
using System.Net;

public partial class config_ficha_cliente : System.Web.UI.Page
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
    public static string saveData(string idUser, string id, string name, string address, string zipCode, string city, string nif, 
        string email, string phone, string notes, string country, string active)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "1", retMessage = "Dados guardados com sucesso.";
        
        sql = string.Format(@"   declare @userid int = {0};
                                 declare @id int = {1};
	                             declare @nome varchar(max) = '{2}';
	                             declare @morada varchar(max) = '{3}';
	                             declare @localidade varchar(500) = '{5}';
	                             declare @codpostal varchar(20) = '{4}';
	                             declare @email varchar(max) = '{7}';
	                             declare @telemovel varchar(50) = '{8}';
	                             declare @nif varchar(10) = '{6}';
	                             declare @pais varchar(200) = '{10}';
                                 declare @fromCsvFile bit = 0;
                                 declare @notas varchar(max) = '{9}';
                                 declare @ativo bit = {11};
                                 declare @ret int;
                                 declare @retMsg VARCHAR(max);

                                 EXEC CRIA_EDITA_CUSTOMER @userid, @id, @nome, @morada, @localidade, @codpostal, @email, @telemovel, @nif, @pais, @notas, @ativo, @fromCsvFile, @ret OUTPUT, @retMsg OUTPUT

                                 select @ret as ret, @retMsg as retMsg", idUser, id, name, address, zipCode, city, nif, email, phone, notes, country, active);

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
        string sql = "", nome = "", morada = "", localidade = "", codpostal = "", email = "", telemovel = "", notas = "", nif = "", pais = "";

        bool ativo = false;
        string s_ativo = "false";

        const string sep = "<#SEP#>";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  set dateformat dmy
                                declare @id int = {0};
                                declare @nif varchar(10);
                                declare @ativo bit;

                                select
	                                id,
	                                nome,
	                                morada,
	                                localidade,
	                                codpostal,
	                                email,
	                                telemovel,
	                                ativo,
	                                notas,
	                                nif,
                                    pais
                                from report_customers(@id, @nif, @ativo)", id);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            nome = oDs.Tables[0].Rows[0]["nome"].ToString().Trim();
            morada = oDs.Tables[0].Rows[0]["morada"].ToString().Trim();
            localidade = oDs.Tables[0].Rows[0]["localidade"].ToString().Trim();
            codpostal = oDs.Tables[0].Rows[0]["codpostal"].ToString().Trim();
            nif = oDs.Tables[0].Rows[0]["nif"].ToString().Trim();
            email = oDs.Tables[0].Rows[0]["email"].ToString().Trim();
            telemovel = oDs.Tables[0].Rows[0]["telemovel"].ToString().Trim();
            notas = oDs.Tables[0].Rows[0]["notas"].ToString().Trim();
            pais = oDs.Tables[0].Rows[0]["pais"].ToString().Trim();
            ativo = Convert.ToBoolean(oDs.Tables[0].Rows[0]["ativo"]);

            s_ativo = ativo ? "true" : "false";
        }

        // Prepara o retorno dos dados
        return nome + sep +
              morada + sep +
              localidade + sep +
              codpostal + sep +
              nif + sep +
              email + sep +
              telemovel + sep +
              notas + sep +
              pais + sep +
              s_ativo;
    }
}