using System;
using System.Web.Services;
using System.Data;
using System.Net;
using System.IO;

public partial class lista_carros : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

    [WebMethod]
    public static string getGrelha(string pesquisa, string order, string admin)
    {
        string sql = "", html = "", htmlOptions = "";
        string id = "", ano = "", matricula = "", carro = "";

        DataSqlServer oDB = new DataSqlServer();

        html += @" <table class='table align-items-center table-flush'>
		        <thead class='thead-light'>
		              <tr>
			            <th scope='col' class='pointer th_text' onclick='ordenaMatricula();'>Matrícula</th>
			            <th scope='col' class='pointer th_text' onclick='ordenaCarro();'>Viatura</th>
                        <th scope='col' class='pointer th_text' onclick='ordenaAno();'>Ano</th>
                        <th scope='col'></th>
		              </tr>
		            </thead> <tbody>";

        sql = String.Format(@"  declare @id_car int;
                                declare @matricula varchar(20);

                                select 
	                                id,
		                            ano,
		                            matricula,
		                            notas,
	                                CONCAT(marca, ' ', modelo) as car
                                from REPORT_CARS(@id_car, @matricula)
                                where (marca like {0} or modelo like {0} or matricula like {0})
                                {1}", 
                                    String.Format("'%{0}%'", pesquisa), 
                                    order);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    id = oDs.Tables[j].Rows[i]["id"].ToString().Trim();
                    ano = oDs.Tables[j].Rows[i]["ano"].ToString().Trim();
                    matricula = oDs.Tables[j].Rows[i]["matricula"].ToString().Trim();
                    carro = oDs.Tables[j].Rows[i]["car"].ToString().Trim();

                    if(admin == "1")
                    {
                        htmlOptions = String.Format(@"  <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                                            <a class='dropdown-item' href='#' onclick='visualizar({0});'>Visualizar</a>
			                                                <a class='dropdown-item' href='#' onclick='editar({0});'>Editar</a>
                                                            <a class='dropdown-item' href='#' onclick='eliminar({0});'>Eliminar</a>
			                                            </div>", id);
                    }
                    else
                    {
                        htmlOptions = String.Format(@"  <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                                            <a class='dropdown-item' href='#' onclick='visualizar({0});'>Visualizar</a>
			                                            </div>", id);
                    }

                    html += String.Format(@"    <tr class='pointer' ondblclick='visualizar({0});'> 
		                                            <td><span>{1}</span></td>
		                                            <td><span>{2}</span></td>
                                                    <td><span>{3}</span></td>
		                                            <td class='text-right'>
		                                                <div class='dropdown'>
			                                                <a class='btn btn-sm btn-icon-only text-light' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
			                                                    <i class='fas fa-ellipsis-v'></i>
			                                                </a>
			                                                {4}
		                                                </div>
		                                            </td>                    
	                                            </tr>", id, matricula, carro, ano, htmlOptions);
                }
            }
        }
        else
        {
            html += "  <tr><td colspan='3'>Não existem clientes a apresentar.</td></tr> ";
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

                                EXEC DELETE_CAR @iduser, @id, @ret OUTPUT, @retMsg OUTPUT
                                SELECT @ret ret, @retMsg retMsg ", id, idUser);


        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
            retMessage = oDs.Tables[0].Rows[0]["retMsg"].ToString().Trim();
        }

        return ret + "<#SEP#>" + retMessage;
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

    protected void Upload_Click(object sender, EventArgs e)
    {
        DataSqlServer oDB = new DataSqlServer();

        if (!FileUploadControl.HasFile)
        {
            uploadFileSuccess.InnerHtml = "";
            uploadFileDanger.InnerHtml = "Por favor, selecione um ficheiro!";
            return;
        }

        if (!FileUploadControl.HasFile)
        {
            uploadFileSuccess.InnerHtml = "";
            uploadFileDanger.InnerHtml = "Por favor, selecione um ficheiro!";
            return;
        }

        if (FileUploadControl.HasFile)
        {
            try
            {
                string filename = Path.GetFileName(FileUploadControl.FileName);
                string extension = Path.GetExtension(FileUploadControl.FileName);
                string pathToSave = Server.MapPath("~") + "ViaturasCarregadas" + DateTime.Now.ToShortDateString().Replace("/", "") + "_" + DateTime.Now.ToLocalTime().ToShortTimeString().Replace(":", "") + extension;

                if (!extension.Contains("csv") && !extension.Contains("xls"))
                {
                    uploadFileSuccess.InnerHtml = "";
                    uploadFileDanger.InnerHtml = "Por favor, selecione um ficheiro Excel válido! (*.csv | *.xls | *.xlsx)";
                    return;
                }

                FileUploadControl.SaveAs(pathToSave);

                if (oDB.insertCSVFileIntoDB(pathToSave, "CARS", userID.Text))
                {
                    uploadFileSuccess.InnerHtml = "Viaturas Carregadas com sucesso!";
                    uploadFileDanger.InnerHtml = "";
                    return;
                }
                else
                {
                    uploadFileSuccess.InnerHtml = "";
                    uploadFileDanger.InnerHtml = "Ocorreu um erro ao carregar o ficheiro!";
                    return;
                }
            }
            catch (Exception ex)
            {
                uploadFileSuccess.InnerHtml = "";
                uploadFileDanger.InnerHtml = "Ocorreu um erro ao carregar o ficheiro: " + ex.ToString();
                return;
            }
        }
    }
}