using System;
using System.Web.Services;
using System.Data;
using System.Net;
using System.IO;
using System.Text;
using System.Net.Mail;
using System.Collections.Generic;

public partial class lista_faturas_clientes : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string getGrelha(string pesquisa, string order, string admin, string min_invoice_date, string max_invoice_date, string min_due_date, string max_due_date)
    {
        string sql = "", html = "", htmlOptions = "";
        string id = "", cliente = "", numero = "", data = "", data_vencimento = "", paga_icon = "", valor = "", sale = "", maintenance = "";
        Boolean paga = false, has_files = false;

        DataSqlServer oDB = new DataSqlServer();

        html += String.Format(@"<table class='table align-items-center table-flush'>
		                        <thead class='thead-light'>
		                              <tr>
                                        <th scope='col' class='pointer th_text'>
                                            <span class='badge badge-dot mr-12'><i id='selectAllInvoicesIcon' class='bg-success invoice_not_selected' style='height: 20px; width: 20px;' onclick='selectAllInvoices();'></i></span>
                                        </th>
			                            <th scope='col' class='pointer th_text' onclick='ordenaCliente();'>Cliente</th>
			                            <th scope='col' class='pointer th_text' onclick='ordenaNumero();'>Nº Fatura</th>
                                        <th scope='col' class='pointer th_text' onclick='ordenaValor();'>Valor</th>
                                        <th scope='col' class='pointer th_text' onclick='ordenaDataFatura();'>Data</th>
			                            <th scope='col' class='pointer th_text' onclick='ordenaDataVencimento();'>Data Vencimento</th>
                                        <th scope='col' class='pointer th_text' onclick='ordenaPaga();'>Paga</th>
                                        {0}
		                              </tr>
		                            </thead><tbody>", admin == "1" ? "<th scope='col'></th>" : "");

        sql = String.Format(@"  set dateformat dmy
                                declare @id int;
                                declare @id_cliente int;
                                declare @min_date date;
                                declare @max_date date;
                                declare @min_due_date date;
                                declare @max_due_date date;

                                select
                                    id,
	                                cliente,
	                                numero,
	                                data_doc_uk,
	                                data_vencimento_uk,
	                                paga,
	                                has_files,
	                                sale,
	                                maintenance,
                                    valortotal
                                from REPORT_ALL_CUSTOMERS_INVOICES(@id, @id_cliente, @min_date, @max_date, @min_due_date, @max_due_date)
                                where (cliente like {0} or numero like {0})
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
                    numero = oDs.Tables[j].Rows[i]["numero"].ToString().Trim();
                    data = oDs.Tables[j].Rows[i]["data_doc_uk"].ToString().Trim();
                    data_vencimento = oDs.Tables[j].Rows[i]["data_vencimento_uk"].ToString().Trim();
                    paga = Convert.ToBoolean(oDs.Tables[j].Rows[i]["paga"].ToString().Trim());
                    has_files = oDs.Tables[j].Rows[i]["has_files"].ToString().Trim() == "1" ? true : false;
                    valor = oDs.Tables[j].Rows[i]["valortotal"].ToString().Trim().Replace(",", ".");
                    sale = oDs.Tables[j].Rows[i]["sale"].ToString().Trim();
                    maintenance = oDs.Tables[j].Rows[i]["maintenance"].ToString().Trim();

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
                                                                    <a class='dropdown-item' href='#' onclick='simulateClickOnFileUploadButton({0}, {2}, {3});'>Upload Docs</a>
                                                                    <a class='dropdown-item' href='#' onclick='visualizar({0}, {2}, {3});'>Visualizar</a>
			                                                        <a class='dropdown-item' href='#' onclick='editar({0}, {2}, {3});'>Editar</a>
                                                                    <a class='dropdown-item' href='#' onclick='eliminar({0}, {2}, {3});'>Eliminar</a>
			                                                    </div>
                                                            </div>
		                                                </td>", id, has_files ? String.Format(@"<a class='dropdown-item' href='#' onclick='verDocs({0}, {1}, {2});'>Ver Docs</a>", id, maintenance, sale) : "", maintenance, sale);
                    }
                    else
                    {
                        htmlOptions = "";
                    }

                    html += String.Format(@"    <tr class='pointer' {9}>
                                                    <td class='variaveis' id='id{7}'>{0}</td>
                                                    <td class='variaveis' id='maintenance{7}'>{10}</td>
                                                    <td class='variaveis' id='sale{7}'>{11}</td>
                                                    <td><span class='badge badge-dot mr-12'><i id='invoiceSelectIcon{7}' class='bg-success invoice_not_selected' style='height: 20px; width: 20px;' onclick='changeInvoiceStatus({7});'></i></span></td>
		                                            <td><span>{1}</span></td>
		                                            <td><span>{2}</span></td>
                                                    <td><span>{8}€</span></td>
                                                    <td><span>{5}</span></td>
                                                    <td><span>{6}</span></td>
                                                    <td style='text-align: center;'>{4}</td>
		                                            {3}                    
	                                            </tr>", id, cliente, numero, htmlOptions, paga_icon, data, data_vencimento, i, valor, admin == "1" ? "ondblclick='editar({0});'" : "", maintenance, sale);
                }

                html += String.Format(@"<span class='variaveis' id='countInvoices'>{0}</span>", oDs.Tables[j].Rows.Count);
            }
        }
        else
        {
            html += String.Format(@"<tr><td colspan='{0}'>Não existem faturas a apresentar.</td></tr>", admin == "1" ? "8" : "7");
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

                                EXEC DELETE_MAINTENANCE @iduser, @id, @ret OUTPUT, @retMsg OUTPUT
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
                                DECLARE @log varchar(max) = (select CONCAT('O utilizador ', @codOp, ' visualizou os documentos da fatura ', numero, ' do cliente ', cliente) from REPORT_MAINTENANCES(@id, null, null, null, null))
                                DECLARE @tipoLog varchar(200) = 'FATURAS CLIENTES';

                                EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @ret output, @retMsg output;

                                select file_path from REPORT_MAINTENANCE_FILE(null, @id, null)", id, idUser);


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

                                EXEC PAY_CUSTOMER_INVOICE @id, @xml, @ret OUTPUT, @retMsg OUTPUT
                                SELECT @ret ret, @retMsg retMsg ", idUser, xml);


        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
            retMessage = oDs.Tables[0].Rows[0]["retMsg"].ToString().Trim();
        }

        return ret + "<#SEP#>" + retMessage;
    }

    //[WebMethod]
    //public static string generatePaymentData(string idUser, string xml)
    //{
    //    string sql = "", ret = "", retMessage = "";
    //    DataSqlServer oDB = new DataSqlServer();


    //    sql = string.Format(@"  DECLARE @id INT = {0};
    //                            DECLARE @xml nvarchar(max) = '{1}';
    //                            DECLARE @ret int
    //                            DECLARE @retMsg VARCHAR(255)

    //                            EXEC GENERATE_PROVIDER_INVOICE_PAYMENT_DATA @id, @xml, @ret OUTPUT, @retMsg OUTPUT
    //                            SELECT @ret ret, @retMsg retMsg ", idUser, xml);


    //    DataSet oDs = oDB.GetDataSet(sql, "").oData;

    //    if (oDB.validaDataSet(oDs))
    //    {
    //        ret = oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
    //        retMessage = oDs.Tables[0].Rows[0]["retMsg"].ToString().Trim();
    //    }

    //    return ret + "<#SEP#>" + retMessage;
    //}

    [WebMethod]
    public static string generatePaymentData(string idUser, string idsMaintenance, string idsSale)
    {
        string sql = "", pdfText = "", invoicesData = "", pdfHeader = "", pdfFooter = "", pdfBody = "", bodyHeader = "", bodyHeaderCustomers = "", bodyTotal = "", tableHeader = "";
        List<string> clientes = new List<string>();
        List<string> moradas = new List<string>();
        List<string> localidades = new List<string>();
        List<string> codpostais = new List<string>();
        List<string> emails = new List<string>();
        List<string> telemoveis = new List<string>();
        List<string> nifs = new List<string>();
        List<string> totaisfaturas = new List<string>();
        List<string> totaisivas = new List<string>();
        string cliente = "", nif = "", dataatual = "", data_manutencao = "", descricao = "", valor = "", numero = "", data_vencimento = "", iban = "", iva = "";
        string sqlLogMaintenance = "", sqlLogSale = "", sqlCondition = "";
        int nrCustomers = 0;
        const string salutationToReplace = "[CUSTOMER_PROVIDER_SALUTATION]";
        const string nameToReplace = "[CUSTOMER_PROVIDER_NAME]";
        const string addressToReplace = "[CUSTOMER_PROVIDER_ADDRESS]";
        const string zipcodeToReplace = "[CUSTOMER_PROVIDER_ZIPCODE]";
        const string cityToReplace = "[CUSTOMER_PROVIDER_CITY]";
        const string nifToReplace = "[CUSTOMER_PROVIDER_NIF]";
        const string ibanToReplace = "[CUSTOMER_PROVIDER_IBAN]";
        const string invoiceDataToReplace = "[CUSTOMER_PROVIDER_INVOICES_DATA]";
        const string ibanGCSReplace = "[IBAN]";
        const string totalToReplace = "[TOTAL]";
        const string dataToReplace = "[DATA]";
        const string subjectToReplace = "[SUBJECT]";
        idsMaintenance = idsMaintenance.Replace("<#SEP#>", ",");
        idsSale = idsSale.Replace("<#SEP#>", ",");

        if(!String.IsNullOrEmpty(idsMaintenance))
        {
            sqlLogMaintenance = String.Format(@"select
	                                                @log = CONCAT(@log, 'O utilizador ', @codOp, ' gerou os dados de pagamento da fatura ', numero, '; '),
                                                    @tipoLog = 'FATURAS CLIENTES'
                                                from REPORT_MAINTENANCES(@id, @id_cliente, @id_viatura, @mecanica, @batechapas)
                                                where paga = 0 and id in ({0})

                                                EXEC REGISTA_LOG @id_op, null, @tipoLog, @log, @retLog output, @retMsgLog output;", idsMaintenance);
        }

        if (!String.IsNullOrEmpty(idsSale))
        {
            sqlLogSale = String.Format(@"   select
	                                            @log = CONCAT(@log, 'O utilizador ', @codOp, ' gerou os dados de pagamento da fatura ', numero, '; '),
                                                @tipoLog = 'VENDAS'
                                            from REPORT_SALES(@id, @id_cliente, @min_date, @max_date, @min_due_date, @max_due_date)
                                            where paga = 0 and id in ({0})

                                            EXEC REGISTA_LOG @id_op, null, @tipoLog, @log, @retLog output, @retMsgLog output;", idsSale);
        }

        if (!String.IsNullOrEmpty(idsMaintenance) && !String.IsNullOrEmpty(idsSale))
        {
            sqlCondition = String.Format(@" and ((maintenance = 1 and id in ({0})) or (sale = 1 and id in ({1})))", idsMaintenance, idsSale);
        }
        else
        {
            if (!String.IsNullOrEmpty(idsMaintenance))
            {
                sqlCondition = String.Format(@" and (maintenance = 1 and id in ({0}))", idsMaintenance);
            }

            if (!String.IsNullOrEmpty(idsSale))
            {
                sqlCondition = String.Format(@" and (sale = 1 and id in ({0}))", idsSale);
            }
        }

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  declare @id int;
                                declare @id_cliente int;
                                declare @min_date date;
                                declare @max_date date;
                                declare @min_due_date date;
                                declare @max_due_date date;
                                declare @id_viatura int;
                                declare @mecanica bit;
                                declare @batechapas bit;
                                declare @iban varchar(100) = (select iban from report_configs());
                                declare @id_op int = {1};
                                declare @tipoLog varchar(200);
                                declare @log varchar(max);
                                declare @retLog int;
                                declare @retMsgLog varchar(max);
                                declare @codOp varchar(30) = (select codigo from REPORT_USERS(@id_op, null, null, 1, null))

                                select distinct
	                                cliente,
	                                morada_cliente,
	                                localidade_cliente,
	                                codpostal_cliente,
	                                email_cliente,
	                                telemovel_cliente,
	                                nif_cliente,
                                    convert(varchar, cast(getdate() as date), 103) as data_atual,
                                    @iban as iban,
									SUM(valortotal) as valortotal,
									SUM(valoriva) as valoriva
                                from REPORT_ALL_CUSTOMERS_INVOICES(@id, @id_cliente, @min_date, @max_date, @min_due_date, @max_due_date)
                                where paga = 0 {0}
                                group by cliente, morada_cliente, localidade_cliente, codpostal_cliente, email_cliente, telemovel_cliente, nif_cliente
                                order by cliente asc

                                select
                                    cliente,
                                    nif_cliente,
	                                data_doc_uk,
	                                descricao,
	                                valortotal,
	                                numero,
	                                data_vencimento_uk,
	                                paga,
	                                metodo_pagamento,
                                    valoriva
                                from REPORT_ALL_CUSTOMERS_INVOICES(@id, @id_cliente, @min_date, @max_date, @min_due_date, @max_due_date)
                                where paga = 0 {0}
                                order by cliente asc, data_vencimento asc

                                {2}

                                {3}", sqlCondition, idUser, sqlLogMaintenance, sqlLogSale);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                if (j == 0)
                {
                    nrCustomers = oDs.Tables[j].Rows.Count;

                    for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                    {
                        clientes.Add(oDs.Tables[j].Rows[i]["cliente"].ToString().Trim());
                        moradas.Add(oDs.Tables[j].Rows[i]["morada_cliente"].ToString().Trim());
                        localidades.Add(oDs.Tables[j].Rows[i]["localidade_cliente"].ToString().Trim());
                        codpostais.Add(oDs.Tables[j].Rows[i]["codpostal_cliente"].ToString().Trim());
                        emails.Add(oDs.Tables[j].Rows[i]["email_cliente"].ToString().Trim());
                        telemoveis.Add(oDs.Tables[j].Rows[i]["telemovel_cliente"].ToString().Trim());
                        nifs.Add(oDs.Tables[j].Rows[i]["nif_cliente"].ToString().Trim());
                        totaisfaturas.Add(oDs.Tables[j].Rows[i]["valortotal"].ToString().Trim().Replace(",", "."));
                        totaisivas.Add(oDs.Tables[j].Rows[i]["valoriva"].ToString().Trim().Replace(",", "."));

                        dataatual = oDs.Tables[j].Rows[i]["data_atual"].ToString().Trim();                        
                        iban = oDs.Tables[j].Rows[i]["iban"].ToString().Trim();
                    }
                }
                else
                {
                    string tmpCliente = "";
                    int k = 0;

                    for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                    {
                        cliente = oDs.Tables[j].Rows[i]["cliente"].ToString().Trim();

                        if(!tmpCliente.Equals(cliente))
                        {
                            if(nrCustomers > 1 && tmpCliente.Length != 0 && i > 0)
                            {
                                invoicesData += String.Format(@"<div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1);'>
                                                                    <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                                    <div style='width: 73.5%; display: inline-block; text-align: left;'>
                                                                        <h5>TOTAL EM DÍVIDA</h5>
                                                                    </div>
                                                                    <div style='width: 23.5%; display: inline-block; text-align: right;'>
                                                                        <h5>{0} €</h5>
                                                                    </div>
                                                                    <hr style='margin-top: 0 !important; margin-right: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                                </div>", totaisfaturas[k++]);
                            }

                            tmpCliente = cliente;

                            if(nrCustomers > 1)
                            {
                                invoicesData += String.Format(@"<div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1); text-align: center;'>
                                                                    <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                                    <div style='width: 97%; display: inline-block;'>
                                                                        <h5>{0} ({1})</h5>
                                                                    </div>
                                                                    <div style='width: 24.5%; display: inline-block;'>
                                                                        <h5>DATA FATURA</h5>
                                                                    </div>
                                                                    <div style='width: 24.5%; display: inline-block;'>
                                                                        <h5>Nº DOC</h5>
                                                                    </div>
                                                                    <div style='width: 24.5%; display: inline-block;'>
                                                                        <h5>DATA VENCIMENTO</h5>
                                                                    </div>
                                                                    <div style='width: 24.5%; display: inline-block;'>
                                                                        <h5>VALOR</h5>
                                                                    </div>
                                                                    <hr style='margin-top: 0 !important; margin-right: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                                </div>", clientes[k], nifs[k]);
                            }
                        }

                        nif = oDs.Tables[j].Rows[i]["nif_cliente"].ToString().Trim();
                        data_manutencao = oDs.Tables[j].Rows[i]["data_doc_uk"].ToString().Trim();
                        descricao = oDs.Tables[j].Rows[i]["descricao"].ToString().Trim();
                        valor = oDs.Tables[j].Rows[i]["valortotal"].ToString().Trim().Replace(",", ".");
                        iva = oDs.Tables[j].Rows[i]["valoriva"].ToString().Trim().Replace(",", ".");
                        numero = oDs.Tables[j].Rows[i]["numero"].ToString().Trim();
                        data_vencimento = oDs.Tables[j].Rows[i]["data_vencimento_uk"].ToString().Trim();

                        invoicesData += String.Format(@"    <div style='width: 100%; height: auto; margin-top: 0! important; text-align: center; color: #000;'>
                                                                <div style='width: 24.5%; display: inline-block;'>
                                                                    <p style='font-size: 0.75rem'>{0}</p>
                                                                </div>
                                                                <div style='width: 24.5%; display: inline-block;'>
                                                                    <p style='font-size: 0.75rem'>{1}</p>
                                                                </div>
                                                                <div style='width: 24.5%; display: inline-block;'>
                                                                    <p style='font-size: 0.75rem'>{2}</p>
                                                                </div>
                                                                <div style='width: 24.5%; display: inline-block;'>
                                                                    <p style='font-size: 0.75rem'>{3} €</p>
                                                                </div>
                                                            </div>", data_manutencao, numero, data_vencimento, valor);
                    }

                    if(nrCustomers > 1)
                    {
                        invoicesData += String.Format(@"<div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1);'>
                                                                    <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                                    <div style='width: 73.5%; display: inline-block; text-align: left;'>
                                                                        <h5>TOTAL EM DÍVIDA</h5>
                                                                    </div>
                                                                    <div style='width: 23.5%; display: inline-block; text-align: right;'>
                                                                        <h5>{0} €</h5>
                                                                    </div>
                                                                    <hr style='margin-top: 0 !important; margin-right: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                                </div>", totaisfaturas[k++]);
                    }
                }
            }

            try
            {
                pdfText = File.ReadAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "template_contacorrente.html"));

                //pdfText = pdfText.Replace(salutationToReplace, "Exmo(s) Sr(s):");
                //pdfText = pdfText.Replace(nameToReplace, cliente);
                //pdfText = pdfText.Replace(addressToReplace, morada);
                //pdfText = pdfText.Replace(zipcodeToReplace, codpostal);
                //pdfText = pdfText.Replace(cityToReplace, localidade);
                //pdfText = pdfText.Replace(nifToReplace, nif);
                //pdfText = pdfText.Replace(ibanToReplace, "");
                //pdfText = pdfText.Replace(dataToReplace, dataatual);
                //pdfText = pdfText.Replace(invoiceDataToReplace, invoicesData);
                //pdfText = pdfText.Replace(ibanGCSReplace, iban);
                //pdfText = pdfText.Replace(totalToReplace, totalfaturas.ToString());
                //pdfText = pdfText.Replace(subjectToReplace, "Conta Corrente - " + cliente + " - " + dataatual);

                pdfFooter = String.Format(@"    <div style='margin-left: 29.7324px; margin-right: 29.7324px; margin-top: 10px; height: auto; font-family: 'Roboto', sans-serif; color: #000;'>
                                                    <img src='http://www.jpdado.pt/AMG/template_footer.png' style='width:100%; height: 100%' />
                                                </div>");

                if(nrCustomers == 1)
                {
                    pdfHeader = String.Format(@"    <div style='width: 100%; height: auto; margin-left: 29.7324px; margin-right: 29.7324px; margin-top: 39.788px; font-family: 'Roboto', sans-serif; color: #000;'> 
                                                    <div style='height: auto;'>
                                                        <div style='width: 24%; text-align: center; display: inline-block; float: left'>
                                                            <img src='http://www.jpdado.pt/AMG/logo.png' style='width:100%; height: auto;' />
                                                        </div>
                                                        <div style='width: 76%; display: inline-block; float: right; padding-left: 40px'>
                                                            <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                            <h4>{0}<br />{1}<br />{2}<br />{3} {4}<br />NIF: {5}</h4>
                                                        </div>
                                                    </div>
                                                </div>", "Exmo(s) Sr(s):", clientes[0], moradas[0], codpostais[0], localidades[0], nifs[0]);

                    bodyHeader = String.Format(@"   <h3>Assunto: Resumo de Faturação Grilo Car Service</h3>
                                                    <h4>Processado em: {0}</h4>
                                                    <h5>
                                                        Junto enviamos o vosso extrato de conta corrente para vossa conferência de faturas.<br />
                                                        Agradecemos o pagamento dos documentos vencidos no prazo estabelecido conforme condições contratuais, para o seguinte IBAN:<br />
                                                        {1}<br />
                                                        Para eventuais esclarecimentos, por favor contacte<br />
                                                        Cátia Grilo - (+351) 918 334 093    grilocarservice22 @gmail.com
                                                    </h5>
                                                    <br />", dataatual, iban);

                    bodyTotal = String.Format(@"<br />
                                                    <div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1);'>
                                                        <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                        <div style='width: 73.5%; display: inline-block; text-align: left;'>
                                                            <h5>TOTAL EM DÍVIDA</h5>
                                                        </div>
                                                        <div style='width: 23.5%; display: inline-block; text-align: right;'>
                                                            <h5>{0} €</h5>
                                                        </div>
                                                        <hr style='margin-top: 0 !important; margin-right: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                    </div>", totaisfaturas[0]);

                    tableHeader = String.Format(@"<div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1); text-align: center'>
                                                        <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                        <div style='width: 24.5%; display: inline-block;'>
                                                            <h5>DATA FATURA</h5>
                                                        </div>
                                                        <div style='width: 24.5%; display: inline-block;'>
                                                            <h5>Nº DOC</h5>
                                                        </div>
                                                        <div style='width: 24.5%; display: inline-block;'>
                                                            <h5>DATA VENCIMENTO</h5>
                                                        </div>
                                                        <div style='width: 24.5%; display: inline-block;'>
                                                            <h5>VALOR</h5>
                                                        </div>
                                                        <hr style='margin-top: 0 !important; margin-right: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                    </div>");
                }
                else
                {
                    pdfHeader = String.Format(@"    <div style='width: 100%; height: auto; margin-left: 29.7324px; margin-right: 29.7324px; margin-top: 39.788px; font-family: 'Roboto', sans-serif; color: #000;'> 
                                                    <div style='height: auto;'>
                                                        <div style='width: 24%; text-align: center; display: inline-block; float: left'>
                                                            <img src='http://www.jpdado.pt/AMG/logo.png' style='width:100%; height: auto;' />
                                                        </div>
                                                        <div style='width: 76%; display: inline-block; float: right; padding-left: 40px'>
                                                            <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                            <h4>{0}<br />{1}<br />{2}<br />{3} {4}<br />NIF: {5}</h4>
                                                        </div>
                                                    </div>
                                                </div>", "Exmo(s) Sr(s):", "Grilo Car Service (Grilos Audazes - Unipessoal Lda)", "Rua da Liberdade, 33-33A R/C", "2695-746", "São João da Talha", "517042126");

                    for (int i = 0; i < nrCustomers; i++)
                    {
                        bodyHeaderCustomers += String.Format(@"{0} ({1}){2}", clientes[i], nifs[i], i < nrCustomers ? "<br />" : "");
                    }

                    bodyHeader = String.Format(@"   <h3>Assunto: Resumo de Faturação Grilo Car Service</h3>
                                                    <h4>Processado em: {0}</h4>
                                                    <h5>
                                                        Clientes:<br />
                                                        {2}
                                                    </h5>
                                                    <br />", dataatual, iban, bodyHeaderCustomers);

                    bodyTotal = "";
                    tableHeader = "";
                }

                pdfBody = String.Format(@"  <div style='margin-left: 29.7324px; margin-right: 29.7324px; height: 1390px; width: 100%; font-family: 'Roboto', sans-serif; color: #000;'>
                                                <br /><br /><br /><br /><br /><br /><br /><br /><br />
                                                <div style='height: auto; text-align: justify;'>
                                                        <div style='height: auto;'>
                                                            {3}
                                                        </div>
                                                    </div>
                                                <div style='height: auto; text-align: justify;'>
                                                    {5}
                                                    {1}
                                                    {4}
                                                </div>
                                            </div>", dataatual, invoicesData, iban, bodyHeader, bodyTotal, tableHeader);
            }
            catch (Exception ex)
            {
                return "extrato_contacorrente_" + cliente + "_" + dataatual.Replace("/", "") + "<#SEP#>" + pdfText;
            }
        }

        return "extrato_contacorrente_" + cliente + "_" + dataatual.Replace("/", "") + "<#SEP#>" + pdfHeader + "<#SEP#>" + pdfFooter + "<#SEP#>" + pdfBody + "<#SEP#>" + "Conta Corrente - " + cliente + " - " + dataatual;
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
                                        DECLARE @id_maintenance int = {1};
                                        DECLARE @filename varchar(max) = '{2}';
                                        DECLARE @error int;
                                        DECLARE @errorMsg varchar(max);

                                        EXEC CRIA_EDITA_MAINTENANCE_FILE @id_op, @id_file, @id_maintenance, @filename, @error output, @errorMsg output

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