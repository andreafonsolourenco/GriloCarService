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


public partial class pos_verificapago : System.Web.UI.Page
{
    string idMaquina="", operacaoid = "",valor="";
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            idMaquina = Request.QueryString["idMaquina"];
            operacaoid = Request.QueryString["operacaoid"];
            valor = Request.QueryString["valor"];

            var ctrlStatus = verificastatuspagamento(idMaquina, operacaoid).Split('@');

            if (ctrlStatus[0] == "F" && ctrlStatus[1] !="0")
                Response.Redirect("pagook.aspx?id=" + idMaquina + "&pago=1&valor=" + valor);
            else
                Response.Redirect("pagook.aspx?id=" + idMaquina+ "&pago=0&valor=" + valor);
        }
        catch (Exception)
        {
        }
    }



    public string verificastatuspagamento(string idMaquina, string operacaoid)
    {
        string sql = "", cashdroid = "1", user = "", password = "", url = "", ret = "OK", totalout = "", state = "";

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

            do
            {
                var wsurl = url + "/Cashdro3WS/index.php?operation=askOperation&operationId=" + operacaoid + "&name=" + user + "&password=" + password;
                string jsonOut = getRetornoURL(wsurl);

                if (jsonOut != "")
                {
                    JToken contourManifest = JObject.Parse(jsonOut);
                    JToken data = contourManifest.SelectToken("data");


                    string _totalout = ((Newtonsoft.Json.Linq.JValue)data).Value.ToString();

                    int posIni = _totalout.IndexOf("totalout") + 11;
                    int posFini = _totalout.IndexOf(",", posIni) - 1;
                    totalout = _totalout.Substring(posIni, posFini - posIni);


                    posIni = _totalout.IndexOf("state") + 8;
                    posFini = _totalout.IndexOf(",", posIni) - 1;
                    state = _totalout.Substring(posIni, posFini - posIni);

                }
            }
            while (state != "F");
        }

        return state + "@" + totalout;
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