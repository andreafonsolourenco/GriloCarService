using System;
using System.Web.Services;
using System.Data;
using System.IO;

public partial class config_ficha_fatura_fornecedor : System.Web.UI.Page
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
            getInvoicePaymentDays();
        }
    }

    [WebMethod]
    public static string saveData(string idUser, string xml)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "1", retMessage = "Dados guardados com sucesso.";
        sql = string.Format(@"  DECLARE @id INT={0};
                                DECLARE @xml NVARCHAR(MAX)='{1}';
                                DECLARE @error int;
                                DECLARE @errorMsg varchar(max);

                                EXEC CRIA_EDITA_PROVIDER_INVOICE @id, @xml, @error OUTPUT, @errorMsg OUTPUT

                                SELECT @error error, @errorMsg errorMsg ", idUser, xml);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["error"].ToString().Trim();
            retMessage = oDs.Tables[0].Rows[0]["errorMsg"].ToString().Trim();
        }

        return ret + "<#SEP#>" + retMessage;
    }


    [WebMethod]
    public static string getData(string id)
    {
        string sql = "", provider = "", provider_address = "", provider_city = "", provider_zipcode = "", provider_nif = "", provider_iban = "", provider_notes = "", provider_email = "",
            numdiaspagamento = "", number = "", invoice_date = "", invoice_due_date = "", value = "", notes = "";

        const string sep = "<#SEP#>";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  declare @id_invoice int = {0};
                                declare @id_provider int
                                declare @numero varchar(500)
                                declare @min_invoice_date date
                                declare @max_invoice_date date
                                declare @min_due_date date
                                declare @max_due_date date

                                select
	                                name_provider,
	                                address_provider,
	                                city_provider,
	                                zipcode_provider,
	                                iban_provider,
	                                nif_provider,
	                                email_provider,
	                                notes_provider,
	                                numero,
	                                data_fatura_uk,
	                                data_vencimento_uk,
	                                valor,
	                                notas,
                                    numero_dias_vencimento
                                from REPORT_PROVIDER_INVOICES(@id_invoice, @id_provider, @numero, @min_invoice_date, @max_invoice_date, @min_due_date, @max_due_date)", id);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            provider = oDs.Tables[0].Rows[0]["name_provider"].ToString().Trim();
            provider_address = oDs.Tables[0].Rows[0]["address_provider"].ToString().Trim();
            provider_city = oDs.Tables[0].Rows[0]["city_provider"].ToString().Trim();
            provider_zipcode = oDs.Tables[0].Rows[0]["zipcode_provider"].ToString().Trim();
            provider_nif = oDs.Tables[0].Rows[0]["nif_provider"].ToString().Trim();
            provider_iban = oDs.Tables[0].Rows[0]["iban_provider"].ToString().Trim();
            provider_notes = oDs.Tables[0].Rows[0]["notes_provider"].ToString().Trim();
            number = oDs.Tables[0].Rows[0]["numero"].ToString().Trim();
            invoice_date = oDs.Tables[0].Rows[0]["data_fatura_uk"].ToString().Trim();
            invoice_due_date = oDs.Tables[0].Rows[0]["data_vencimento_uk"].ToString().Trim();
            value = oDs.Tables[0].Rows[0]["valor"].ToString().Trim().Replace(",", ".");
            notes = oDs.Tables[0].Rows[0]["notas"].ToString().Trim();
            provider_email = oDs.Tables[0].Rows[0]["email_provider"].ToString().Trim();
            numdiaspagamento = oDs.Tables[0].Rows[0]["numero_dias_vencimento"].ToString().Trim();
        }

        // Prepara o retorno dos dados
        return provider + sep +
              provider_address + sep +
              provider_city + sep +
              provider_zipcode + sep +
              provider_nif + sep +
              provider_iban + sep +
              provider_notes + sep +
              number + sep +
              invoice_date + sep +
              invoice_due_date + sep +
              value + sep +
              notes + sep +
              provider_email + sep +
              numdiaspagamento;
    }

    [WebMethod]
    public static string getProvidersList(string search, string dialogOpen)
    {
        string sql = "", html = "", htmlWithSearch = "";
        string id = "", nome = "", nif = "";
        int rowsNumber = 0;

        DataSqlServer oDB = new DataSqlServer();

        html += @"  <input id='providersSearchBar' class='form-control' placeholder='Pesquisar...' type='text' style='color: black; width: 75%; float:left;' />
                    <img id='providerSearchIcon' src='../Img/search_icon.png' style='width: auto; height: calc(2.75rem + 2px); cursor: pointer; margin-left: 5px; float:right;' alt='Pesquisar Cliente' title='Pesquisar Fornecedor' onclick='getProvidersList();'/>
                    <div id='divTableProviders'>";

        html += @"<table class='table align-items-center table-flush'>
		                                <thead class='thead-light'>
		                                    <tr>
			                                    <th scope='col' class='pointer th_text'>NIF</th>
			                                    <th scope='col' class='pointer th_text'>Fornecedor</th>
                                            </tr>
		                                </thead>
                                        <tbody>";

        htmlWithSearch += @"<table class='table align-items-center table-flush'>
		                                <thead class='thead-light'>
		                                    <tr>
			                                    <th scope='col' class='pointer th_text'>NIF</th>
			                                    <th scope='col' class='pointer th_text'>Fornecedor</th>
                                            </tr>
		                                </thead>
                                        <tbody>";

        sql = String.Format(@"  declare @id int
                                declare @nif varchar(10)

                                select
	                                id,
	                                nome,
	                                morada,
	                                localidade,
	                                codpostal,
	                                iban,
	                                nif,
	                                email,
	                                ativo,
	                                notas
                                from REPORT_PROVIDERS(@id, @nif)
                                where ativo = 1
                                and (nome like {0} or nif like {0})
                                order by nome, nif", String.Format("'%{0}%'", search));

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    id = oDs.Tables[j].Rows[i]["id"].ToString().Trim();
                    nome = oDs.Tables[j].Rows[i]["nome"].ToString().Trim();
                    nif = oDs.Tables[j].Rows[i]["nif"].ToString().Trim();

                    html += String.Format(@"<tr class='pointer' id='providerLine{0}' onclick='selectProviderRow({1},{0})'> 
		                                        <td><span>{2}</span></td>
		                                        <td><span>{3}</span>                  
	                                          </tr>", i, id, nif, nome);

                    htmlWithSearch += String.Format(@"<tr class='pointer' id='providerLine{0}' onclick='selectProviderRow({1},{0})'> 
		                                                <td><span>{2}</span></td>
		                                                <td><span>{3}</span>                
	                                                  </tr>", i, id, nif, nome);
                }

                rowsNumber = oDs.Tables[j].Rows.Count;

                html += String.Format(@"<span class='variaveis' id='countProviders'>{0}</span>", rowsNumber);

                htmlWithSearch += String.Format(@"<span class='variaveis' id='countProviders'>{0}</span>", rowsNumber);
            }
        }
        else
        {
            html += "<tr><td colspan='2'>Não existem fornecedores a apresentar.</td></tr>";
            htmlWithSearch += "<tr><td colspan='2'>Não existem fornecedores a apresentar.</td></tr>";
        }


        html += "</tbody></table></div>";
        htmlWithSearch += "</tbody></table></div>";

        return dialogOpen == "0" ? html : htmlWithSearch;
    }

    [WebMethod]
    public static string getProviderData(string id, string contribuinte)
    {
        string sql = "";
        string sep = "<#SEP#>";
        string nome = "", morada = "", codpostal = "", nif = "", localidade = "", iban = "", email = "", notas = "", numdiaspagamento = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  declare @id int = {0};
                                declare @nif varchar(10) = {1};

                                select
	                                id,
	                                nome,
	                                morada,
	                                localidade,
	                                codpostal,
	                                iban,
	                                nif,
	                                email,
	                                ativo,
	                                notas,
                                    numero_dias_vencimento
                                from REPORT_PROVIDERS(@id, @nif)", id == "0" ? "NULL" : id, String.IsNullOrEmpty(contribuinte) ? "NULL" : String.Format(@"'{0}'", contribuinte));

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    nome = oDs.Tables[j].Rows[i]["nome"].ToString().Trim();
                    morada = oDs.Tables[j].Rows[i]["morada"].ToString().Trim();
                    nif = oDs.Tables[j].Rows[i]["nif"].ToString().Trim();
                    localidade = oDs.Tables[j].Rows[i]["localidade"].ToString().Trim();
                    codpostal = oDs.Tables[j].Rows[i]["codpostal"].ToString().Trim();
                    iban = oDs.Tables[j].Rows[i]["iban"].ToString().Trim();
                    email = oDs.Tables[j].Rows[i]["email"].ToString().Trim();
                    notas = oDs.Tables[j].Rows[i]["notas"].ToString().Trim();
                    numdiaspagamento = oDs.Tables[j].Rows[i]["numero_dias_vencimento"].ToString().Trim();
                }
            }
        }

        return nome + sep + morada + sep + codpostal + sep + localidade + sep + nif + sep + iban + sep + email + sep + notas + sep + numdiaspagamento;
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

    [WebMethod]
    public static string getDueDateCalculation(string invoiceDate, string paymentDays)
    {
        string sql = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  set dateformat dmy;
                                declare @invoiceDate date = '{0}';
                                declare @days int = {1};

                                select 
	                                convert(varchar, cast(dateadd(dd, @days, @invoiceDate) as date), 103) as dueDate", invoiceDate, paymentDays);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    return oDs.Tables[j].Rows[i]["dueDate"].ToString().Trim();
                }
            }
        }

        return "";
    }

    private void getInvoicePaymentDays()
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "";
        sql = string.Format(@"  declare @today date = cast(getdate() as date);
                                select numero_dias_vencimento, convert(varchar, @today, 103) as defaultDate, convert(varchar, cast(dateadd(dd, numero_dias_vencimento, @today) as date), 103) as defaultDueDate from REPORT_CONFIGS()");

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            txtAuxDefaultInvoiceDate.Value = oDs.Tables[0].Rows[0]["defaultDate"].ToString().Trim();
            txtAuxDefaultInvoiceDueDate.Value = oDs.Tables[0].Rows[0]["defaultDueDate"].ToString().Trim();
        }
        else
        {
            txtAuxDefaultInvoiceDate.Value = "";
            txtAuxDefaultInvoiceDueDate.Value = "";
        }
    }
}