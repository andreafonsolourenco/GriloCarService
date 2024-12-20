using System;
using System.Web.Services;
using System.Data;
using System.IO;

public partial class lista_vendas : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string getGrelha(string pesquisa, string order, string admin, string min_invoice_date, string max_invoice_date, string min_due_date, string max_due_date)
    {
        string sql = "", html = "", htmlOptions = "";
        string id = "", cliente = "", data = "", descricao = "";
        Boolean has_files = false;

        DataSqlServer oDB = new DataSqlServer();

        html += String.Format(@"<table class='table align-items-center table-flush'>
		                        <thead class='thead-light'>
		                              <tr>
			                            <th scope='col' class='pointer th_text' onclick='ordenaCliente();'>Cliente</th>
                                        <th scope='col' class='pointer th_text' onclick='ordenaDataFatura();'>Data</th>
			                            <th scope='col' class='pointer th_text' onclick='ordenaDescricao();'>Descrição</th>
                                        {0}
		                              </tr>
		                            </thead><tbody>", admin == "1" ? "<th scope='col'></th>" : "");

        sql = String.Format(@"  set dateformat dmy
                                declare @id_sale int
                                declare @id_customer int
                                declare @id_file int
                                declare @numero varchar(500)
                                declare @min_date date = {2};
                                declare @max_date date = {3};
                                declare @min_due_date date = {4};
                                declare @max_due_date date = {5};

                                select distinct
	                                s.id,
		                            s.id_cliente,
		                            s.cliente,
		                            s.morada_cliente,
		                            s.localidade_cliente,
		                            s.codpostal_cliente,
		                            s.email_cliente,
		                            s.telemovel_cliente,
		                            s.nif_cliente,
		                            s.data_venda,
		                            s.data_venda_it,
		                            s.data_venda_uk,
		                            s.data_venda_jp,
		                            s.data_venda_odbc,
		                            s.descricao,
		                            s.valortotal,
		                            s.valoriva,
		                            s.numero,
		                            s.data_vencimento,
		                            s.data_vencimento_it,
		                            s.data_vencimento_uk,
		                            s.data_vencimento_jp,
		                            s.data_vencimento_odbc,
		                            s.paga,
                                    case when ISNULL(sf.id, 0) > 0 then 1 else 0 end as has_files
                                from REPORT_SALES(@id_sale, @id_customer, @min_date, @max_date, @min_due_date, @max_due_date) s
                                left join REPORT_SALES_FILE(@id_file, @id_sale, @id_customer) sf on sf.id_sale = s.id
                                where (s.cliente like {0} or s.numero like {0} or s.descricao like {0})
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
                    cliente = oDs.Tables[j].Rows[i]["cliente"].ToString().Trim();
                    data = oDs.Tables[j].Rows[i]["data_venda_uk"].ToString().Trim();
                    descricao = oDs.Tables[j].Rows[i]["descricao"].ToString().Trim();
                    has_files = oDs.Tables[j].Rows[i]["has_files"].ToString().Trim() == "1" ? true : false;

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
                                                    <td class='variaveis' id='id{5}'>{0}</td>
		                                            <td><span>{1}</span></td>
		                                            <td><span>{3}</span></td>
                                                    <td><span>{4}</span></td>
		                                            {2}                    
	                                            </tr>", id, cliente, htmlOptions, data, descricao, i);
                }

                html += String.Format(@"<span class='variaveis' id='countInvoices'>{0}</span>", oDs.Tables[j].Rows.Count);
            }
        }
        else
        {
            html += String.Format(@"<tr><td colspan='{0}'>Não existem vendas a apresentar.</td></tr>", admin == "1" ? "8" : "7");
        }


        html += "</tbody></table>";


        return html;
    }

    protected void Upload_Click(object sender, EventArgs e)
    {
        DataSqlServer oDB = new DataSqlServer();
        string idUser = userID.Text;
        string idInvoice = saleID.Text;
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
                                        DECLARE @id_sale int = {1};
                                        DECLARE @filename varchar(max) = '{2}';
                                        DECLARE @error int;
                                        DECLARE @errorMsg varchar(max);

                                        EXEC CRIA_EDITA_SALE_FILE @id_op, @id_file, @id_sale, @filename, @error output, @errorMsg output

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