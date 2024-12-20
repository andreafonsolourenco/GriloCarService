using System;
using System.Web.Services;
using System.Data;
using System.Net;
using System.IO;
using System.Text;
using System.Net.Mail;

public partial class lista_faturas_fornecedores : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string getGrelha(string pesquisa, string order, string admin, string min_invoice_date, string max_invoice_date, string min_due_date, string max_due_date)
    {
        string sql = "", html = "", htmlOptions = "";
        string id = "", fornecedor = "", numero = "", data = "", data_vencimento = "", paga_icon = "", valor = "";
        Boolean paga = false, has_files = false;

        DataSqlServer oDB = new DataSqlServer();

        html += String.Format(@"<table class='table align-items-center table-flush'>
		                        <thead class='thead-light'>
		                              <tr>
                                        <th scope='col' class='pointer th_text'>
                                            <span class='badge badge-dot mr-12'><i id='selectAllInvoicesIcon' class='bg-success invoice_not_selected' style='height: 20px; width: 20px;' onclick='selectAllInvoices();'></i></span>
                                        </th>
			                            <th scope='col' class='pointer th_text' onclick='ordenaFornecedor();'>Fornecedor</th>
			                            <th scope='col' class='pointer th_text' onclick='ordenaNumero();'>Nº Fatura</th>
                                        <th scope='col' class='pointer th_text' onclick='ordenaValor();'>Valor</th>
                                        <th scope='col' class='pointer th_text' onclick='ordenaDataFatura();'>Data</th>
			                            <th scope='col' class='pointer th_text' onclick='ordenaDataVencimento();'>Data Vencimento</th>
                                        <th scope='col' class='pointer th_text' onclick='ordenaPaga();'>Paga</th>
                                        {0}
		                              </tr>
		                            </thead><tbody>", admin == "1" ? "<th scope='col'></th>" : "");

        sql = String.Format(@"  set dateformat dmy
                                declare @id_invoice int
                                declare @id_provider int
                                declare @id_file int
                                declare @numero varchar(500)
                                declare @min_invoice_date date = {2};
                                declare @max_invoice_date date = {3};
                                declare @min_due_date date = {4};
                                declare @max_due_date date = {5};

                                select distinct
	                                inv.id,
	                                inv.id_provider,
	                                inv.name_provider,
	                                inv.address_provider,
	                                inv.city_provider,
	                                inv.zipcode_provider,
	                                inv.iban_provider,
	                                inv.nif_provider,
	                                inv.email_provider,
	                                inv.notes_provider,
	                                inv.numero,
                                    inv.data_fatura,
                                    inv.data_fatura_it,
                                    inv.data_fatura_jp,
                                    inv.data_fatura_odbc,
	                                inv.data_fatura_uk,
                                    inv.data_vencimento,
                                    inv.data_vencimento_it,
                                    inv.data_vencimento_jp,
                                    inv.data_vencimento_odbc,
	                                inv.data_vencimento_uk,
	                                inv.valor,
	                                inv.notas,
                                    inv.paga,
                                    case when ISNULL(invfile.id, 0) > 0 then 1 else 0 end as has_files
                                from REPORT_PROVIDER_INVOICES(@id_invoice, @id_provider, @numero, @min_invoice_date, @max_invoice_date, @min_due_date, @max_due_date) inv
                                left join REPORT_PROVIDER_INVOICE_FILE(@id_file, @id_invoice, @id_provider) invfile on invfile.id_invoice = inv.id
                                where (inv.name_provider like {0} or inv.numero like {0})
                                {1}", 
                                    String.Format("'%{0}%'", pesquisa), 
                                    order,
                                    String.IsNullOrEmpty(min_invoice_date) ? "NULL" : String.Format(@"'{0}'", min_invoice_date),
                                    String.IsNullOrEmpty(max_invoice_date) ? "NULL" : String.Format(@"'{0}'", max_invoice_date),
                                    String.IsNullOrEmpty(min_due_date) ? "NULL" : String.Format(@"'{0}'", min_due_date),
                                    String.IsNullOrEmpty(max_due_date) ? "NULL" : String.Format(@"'{0}'", max_due_date));

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    id = oDs.Tables[j].Rows[i]["id"].ToString().Trim();
                    fornecedor = oDs.Tables[j].Rows[i]["name_provider"].ToString().Trim();
                    numero = oDs.Tables[j].Rows[i]["numero"].ToString().Trim();
                    data = oDs.Tables[j].Rows[i]["data_fatura_uk"].ToString().Trim();
                    data_vencimento = oDs.Tables[j].Rows[i]["data_vencimento_uk"].ToString().Trim();
                    paga = Convert.ToBoolean(oDs.Tables[j].Rows[i]["paga"].ToString().Trim());
                    has_files = oDs.Tables[j].Rows[i]["has_files"].ToString().Trim() == "1" ? true : false;
                    valor = oDs.Tables[j].Rows[i]["valor"].ToString().Trim().Replace(",", ".");

                    if (paga)
                    {
                        paga_icon = "<span class='badge badge-dot mr-12'><i class='bg-success' style='height: 20px; width: 20px; background-color: green !important'></i></span>";
                    }
                    else
                    {
                        paga_icon = "<span class='badge badge-dot mr-12'><i class='bg-success' style='height: 20px; width: 20px; background-color: red !important'></i></span>";
                    }

                    if (admin == "1")
                    {
                        htmlOptions = String.Format(@"  <td class='text-right'>
		                                                    <div class='dropdown'>
			                                                    <a class='btn btn-sm btn-icon-only text-light' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
			                                                        <i class='fas fa-ellipsis-v'></i>
			                                                    </a>
                                                                <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                                                    {1}
                                                                    <a class='dropdown-item' href='#' onclick='simulateClickOnFileUploadButton({0});'>Upload Docs</a>
                                                                    <a class='dropdown-item' href='#' onclick='visualizar({0});'>Visualizar</a>
			                                                        <a class='dropdown-item' href='#' onclick='editar({0});'>Editar</a>
                                                                    <a class='dropdown-item' href='#' onclick='eliminar({0});'>Eliminar</a>
			                                                    </div>
                                                            </div>
		                                                </td>", id, has_files ? String.Format(@"<a class='dropdown-item' href='#' onclick='verDocs({0});'>Ver Docs</a>", id) : "");
                    }
                    else
                    {
                        htmlOptions = "";
                    }

                    html += String.Format(@"    <tr class='pointer' ondblclick='editar({0});'>
                                                    <td class='variaveis' id='id{7}'>{0}</td>
                                                    <td><span class='badge badge-dot mr-12'><i id='invoiceSelectIcon{7}' class='bg-success invoice_not_selected' style='height: 20px; width: 20px;' onclick='changeInvoiceStatus({7});'></i></span></td>
		                                            <td><span>{1}</span></td>
		                                            <td><span>{2}</span></td>
                                                    <td><span>{8}€</span></td>
                                                    <td><span>{5}</span></td>
                                                    <td><span>{6}</span></td>
                                                    <td style='text-align: center;'>{4}</td>
		                                            {3}                    
	                                            </tr>", id, fornecedor, numero, htmlOptions, paga_icon, data, data_vencimento, i, valor);
                }

                html += String.Format(@"<span class='variaveis' id='countInvoices'>{0}</span>", oDs.Tables[j].Rows.Count);
            }
        }
        else
        {
            html += String.Format(@"<tr><td colspan='{0}'>Não existem pagamentos a apresentar.</td></tr>", admin == "1" ? "8" : "7");
        }


        html += "</tbody></table>";


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

                                EXEC DELETE_PROVIDER_INVOICE @iduser, @id, @ret OUTPUT, @retMsg OUTPUT
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
    public static string getFiles(string idUser, string id)
    {
        string sql = "", ret = "";
        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  DECLARE @id INT = {0};
                                DECLARE @idUser int = {1};
                                DECLARE @ret int
                                DECLARE @retMsg VARCHAR(255)
                                DECLARE @codOp varchar(500) = (select codigo from REPORT_USERS(@idUser, null, null, 1, null))
                                DECLARE @log varchar(max) = (select CONCAT('O utilizador ', @codOp, ' visualizou os documentos da fatura ', numero, ' do fornecedor ', name_provider) from REPORT_PROVIDER_INVOICES(@id, null, null, null, null, null, null))
                                DECLARE @tipoLog varchar(200) = 'FATURAS FORNECEDORES';

                                EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @ret output, @retMsg output;

                                select file_path from report_provider_invoice_file(null, @id, null)", id, idUser);


        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                ret = oDs.Tables[j].Rows.Count.ToString() + "@";

                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    if(i > 0)
                    {
                        ret += "<#SEP#>";
                    }

                    ret += oDs.Tables[j].Rows[i]["file_path"].ToString().Trim();
                }
            }

            return ret;
        }

        return "0@Não existem documentos associados a este pagamento!";
    }

    [WebMethod]
    public static string payInvoice(string idUser, string xml)
    {
        string sql = "", ret = "", retMessage = "";
        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  DECLARE @id INT = {0};
                                DECLARE @xml nvarchar(max) = '{1}';
                                DECLARE @ret int
                                DECLARE @retMsg VARCHAR(255)

                                EXEC PAY_PROVIDER_INVOICE @id, @xml, @ret OUTPUT, @retMsg OUTPUT
                                SELECT @ret ret, @retMsg retMsg ", idUser, xml);


        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
            retMessage = oDs.Tables[0].Rows[0]["retMsg"].ToString().Trim();
        }

        return ret + "<#SEP#>" + retMessage;
    }

    [WebMethod]
    public static string generatePaymentData(string idUser, string xml)
    {
        string sql = "", ret = "", retMessage = "";
        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  DECLARE @id INT = {0};
                                DECLARE @xml nvarchar(max) = '{1}';
                                DECLARE @ret int
                                DECLARE @retMsg VARCHAR(255)

                                EXEC GENERATE_PROVIDER_INVOICE_PAYMENT_DATA @id, @xml, @ret OUTPUT, @retMsg OUTPUT
                                SELECT @ret ret, @retMsg retMsg ", idUser, xml);


        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
            retMessage = oDs.Tables[0].Rows[0]["retMsg"].ToString().Trim();
        }

        return ret + "<#SEP#>" + retMessage;
    }

    protected void Upload_Click(object sender, EventArgs e)
    {
        DataSqlServer oDB = new DataSqlServer();
        string idUser = userID.Text;
        string idInvoice = invoiceID.Text;
        string ret = "1", retMessage = "Dados guardados com sucesso!", sql = "";

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
                string pathToSave = Server.MapPath("~") + "/faturas/" + filename;

                FileUploadControl.SaveAs(pathToSave);

                sql = string.Format(@"  DECLARE @id_op int = {0};
                                        DECLARE @id_file int;
                                        DECLARE @id_invoice int = {1};
                                        DECLARE @filename varchar(max) = '{2}';
                                        DECLARE @error int;
                                        DECLARE @errorMsg varchar(max);

                                        EXEC CRIA_EDITA_PROVIDER_INVOICE_FILE @id_op, @id_file, @id_invoice, @filename, @error output, @errorMsg output

                                        SELECT @error error, @errorMsg errorMsg ", idUser, idInvoice, filename);

                DataSet oDs = oDB.GetDataSet(sql, "").oData;

                if (oDB.validaDataSet(oDs))
                {
                    ret = oDs.Tables[0].Rows[0]["error"].ToString().Trim();
                    retMessage = oDs.Tables[0].Rows[0]["errorMsg"].ToString().Trim();
                }

                uploadFileSuccess.InnerHtml = retMessage;
                uploadFileDanger.InnerHtml = "";
                return;
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