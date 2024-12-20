using System;
using System.Linq;
using System.Web.Services;
using System.Data;
using System.Net;
using System.IO;
using System.Text;
using Newtonsoft.Json.Linq;
using System.Threading;
using System.Net.Mail;

public partial class pos_payment : System.Web.UI.Page
{
    string id = "null", pago="";
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            id = Request.QueryString["id"];
            pago = Request.QueryString["pago"];
        }
        catch (Exception)
        {
        }

        txtIDMaquina.Value = id;
        txtPago.Value = pago;
    }

    [WebMethod]
    public static string paga(string idMaquina, string valor)
    {
        string sql = "", cashdroid = "1", user = "", password = "", url = "", ret = "OK", operacaoid="";

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  declare @id_maquina int = {0}
                                SELECT 
	                                id,
	                                username,
	                                password,
                                    url
                                FROM CASHDRO_REPORT_MAQUINAS(@id_maquina)", idMaquina);
        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            cashdroid = oDs.Tables[0].Rows[0]["id"].ToString().Trim();
            url = oDs.Tables[0].Rows[0]["url"].ToString().Trim();
            user = oDs.Tables[0].Rows[0]["username"].ToString().Trim();
            password = oDs.Tables[0].Rows[0]["password"].ToString().Trim();

            var wsurl = url + "/Cashdro3WS/index.php?operation=startOperation&name=" + user + "&password=" + password + "&type=3&posid=helptechportal&posuser=" + user + "&parameters={'amount':'" + valor + "'}";
            string jsonOut = getRetornoURL(wsurl);
            if (jsonOut != "")
            {
                JToken contourManifest = JObject.Parse(jsonOut);
                JToken data = contourManifest.SelectToken("data");
                JToken code = contourManifest.SelectToken("code");

                operacaoid = data.ToString();

                wsurl = url + "/Cashdro3WS/index.php?name=" + user + "&operation=acknowledgeOperationId&operationId=" + operacaoid + "&password=" + password;
                jsonOut = getRetornoURL(wsurl);              
            }
        }

        return operacaoid;
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