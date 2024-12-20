using System;
using System.Web.Services;
using System.Data;
using System.Net;

public partial class config_ficha_fornecedor : System.Web.UI.Page
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
        string email, string notes, string iban, string active, string numdiaspagamento)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "1", retMessage = "Dados guardados com sucesso.";
        
        sql = string.Format(@"  declare @userid int = {0};
                                declare @id int = {1};
	                            declare @nome varchar(max) = '{2}';
	                            declare @morada varchar(max) = '{3}';
	                            declare @localidade varchar(500) = '{5}';
	                            declare @codpostal varchar(20) = '{4}';
	                            declare @iban varchar(500) = '{9}';
	                            declare @nif varchar(10) = '{6}';
	                            declare @email varchar(max) = '{7}';
	                            declare @ativo bit = {10};
	                            declare @notas varchar(max) = '{8}';
                                declare @numdiaspagamento int = {11};
	                            declare @fromCsvFile bit = 0;
                                declare @ret int;
                                declare @retMsg VARCHAR(max);

                                 EXEC CRIA_EDITA_PROVIDER @userid, @id, @nome, @morada, @localidade, @codpostal, @iban, @nif, @email, @ativo, @notas, @numdiaspagamento, @fromCsvFile, @ret OUTPUT, @retMsg OUTPUT

                                 select @ret as ret, @retMsg as retMsg", idUser, id, name, address, zipCode, city, nif, email, notes, iban, active, numdiaspagamento);

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
        string sql = "", nome = "", morada = "", localidade = "", codpostal = "", email = "", iban = "", notas = "", nif = "", numdiasvencimento = "";

        bool ativo = false;
        string s_ativo = "false";

        const string sep = "<#SEP#>";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  set dateformat dmy
                                declare @id int = {0};
                                declare @nif varchar(10);

                                select
	                                id,
	                                nome,
	                                morada,
	                                localidade,
	                                codpostal,
	                                email,
	                                iban,
	                                ativo,
	                                notas,
	                                nif,
                                    numero_dias_vencimento
                                from report_providers(@id, @nif)", id);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            nome = oDs.Tables[0].Rows[0]["nome"].ToString().Trim();
            morada = oDs.Tables[0].Rows[0]["morada"].ToString().Trim();
            localidade = oDs.Tables[0].Rows[0]["localidade"].ToString().Trim();
            codpostal = oDs.Tables[0].Rows[0]["codpostal"].ToString().Trim();
            nif = oDs.Tables[0].Rows[0]["nif"].ToString().Trim();
            email = oDs.Tables[0].Rows[0]["email"].ToString().Trim();
            iban = oDs.Tables[0].Rows[0]["iban"].ToString().Trim();
            notas = oDs.Tables[0].Rows[0]["notas"].ToString().Trim();
            numdiasvencimento = oDs.Tables[0].Rows[0]["numero_dias_vencimento"].ToString().Trim();
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
              iban + sep +
              notas + sep +
              s_ativo + sep +
              numdiasvencimento;
    }
}