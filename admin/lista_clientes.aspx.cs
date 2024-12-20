using System;
using System.Web.Services;
using System.Data;
using System.Net;
using System.IO;
using System.Text;
using System.Net.Mail;

public partial class lista_clientes : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string getGrelha(string pesquisa, string order, string admin)
    {
        string sql = "", html = "", htmlOptions = "";
        string id = "", nome = "", morada = "", opcao_conta_corrente = "";
        int nrFaturas = 0;

        DataSqlServer oDB = new DataSqlServer();

        html += @" <table class='table align-items-center table-flush'>
		        <thead class='thead-light'>
		              <tr>
			            <th scope='col' class='pointer th_text' onclick='ordenaNome();'>Nome</th>
			            <th scope='col' class='pointer th_text' onclick='ordenaMorada();'>Morada</th>
                        <th scope='col'></th>
		              </tr>
		            </thead> <tbody>";

        sql = String.Format(@"  declare @id_customer int;
                                declare @nif varchar(10);
                                declare @ativo bit;
                                declare @id int;
                                declare @min_date date;
                                declare @max_date date;
                                declare @min_due_date date;
                                declare @max_due_date date;

                                select 
	                                cust.id,
	                                cust.nome,
	                                CONCAT(cust.morada, ' - ', cust.codpostal, ' ', cust.localidade) as morada_completa,
                                    isnull(count(m.id), 0) as nr_faturas
                                from [REPORT_CUSTOMERS](@id_customer, @nif, @ativo) cust
                                left join REPORT_ALL_CUSTOMERS_INVOICES(@id, @id_customer, @min_date, @max_date, @min_due_date, @max_due_date) m on m.id_cliente = cust.id and m.paga = 0
                                where (nome like {0} or morada like {0} or codpostal like {0} or localidade like {0})
                                group by cust.id, cust.nome, cust.morada, cust.codpostal, cust.localidade
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
                    nome = oDs.Tables[j].Rows[i]["nome"].ToString().Trim();
                    morada = oDs.Tables[j].Rows[i]["morada_completa"].ToString().Trim();
                    nrFaturas = Convert.ToInt32(oDs.Tables[j].Rows[i]["nr_faturas"].ToString().Trim());

                    if(admin == "1")
                    {
                        opcao_conta_corrente = String.Format(@"<a class='dropdown-item' href='#' onclick='contaCorrente({0});'>Conta Corrente</a>", id);

                        htmlOptions = String.Format(@"  <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                                            {1}
                                                            <a class='dropdown-item' href='#' onclick='visualizar({0});'>Visualizar</a>
			                                                <a class='dropdown-item' href='#' onclick='editar({0});'>Editar</a>
                                                            <a class='dropdown-item' href='#' onclick='eliminar({0});'>Eliminar</a>
                                                            <a class='dropdown-item' href='#' onclick='enviarEmailBoasVindas({0});'>Enviar Email de Boas-Vindas</a>
			                                            </div>", id, nrFaturas > 0 ? opcao_conta_corrente : "");
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
		                                            <td class='text-right'>
		                                                <div class='dropdown'>
			                                                <a class='btn btn-sm btn-icon-only text-light' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
			                                                    <i class='fas fa-ellipsis-v'></i>
			                                                </a>
			                                                {3}
		                                                </div>
		                                            </td>                    
	                                            </tr>", id, nome, morada, htmlOptions);
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

                                EXEC DELETE_CUSTOMER @iduser, @id, @ret OUTPUT, @retMsg OUTPUT
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
    public static string buildWelcomeEmail(string id)
    {
        string sql = "", html = "";
        string intro = "", subject = "", body = "", email = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  declare @id_customer int = {0};
                                declare @nif varchar(10);
                                declare @ativo bit;

                                select 
	                                'Bem-Vindo à AMG Car Service' as subject,
	                                CONCAT('Bem-Vindo ', nome, '!') as intro,
	                                'Temos a honra de lhe dar as boas vindas à AMG Car Service!<br />Esperemos que o serviço seja do seu agrado.<br /><br />Atenciosamente<br />A Gerência' as body,
                                    email
                                from [REPORT_CUSTOMERS](@id_customer, @nif, @ativo)", id);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    intro = oDs.Tables[j].Rows[i]["intro"].ToString().Trim();
                    subject = oDs.Tables[j].Rows[i]["subject"].ToString().Trim();
                    body = oDs.Tables[j].Rows[i]["body"].ToString().Trim();
                    email = oDs.Tables[j].Rows[i]["email"].ToString().Trim();
                }
            }
        }
        else
        {
            intro = "Bem-Vindo!";
            subject = "Bem-Vindo à AMG Car Service";
            body = "Temos a honra de lhe dar as boas vindas à AMG Car Service!<br />Esperemos que o serviço seja do seu agrado.<br /><br />Atenciosamente<br />A Gerência";
            email = "amgcarservice22@gmail.com";
        }


        html = subject + "<#SEP#>" + intro + "<#SEP#>" + body + "<#SEP#>" + email;

        return html;
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
    public static string sendEmail(string subject, string body, string intro, string email)
    {
        int timeout = 50000;
        int i = 0;
        string sql = "", sendemail = "", sendcc = "", sendbcc = "", from = "", pwd = "", smtp = "", smtpport = "", emails = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = string.Format(@"  SELECT
                                    email,
                                    email_password,
                                    email_smtp,
                                    email_smtpport,
                                    emails_alerta
                                FROM REPORT_CONFIGS()");
        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            from = oDs.Tables[0].Rows[0]["email"].ToString().Trim();
            pwd = oDs.Tables[0].Rows[0]["email_password"].ToString().Trim();
            smtp = oDs.Tables[0].Rows[0]["email_smtp"].ToString().Trim();
            smtpport = oDs.Tables[0].Rows[0]["email_smtpport"].ToString().Trim();
            emails = oDs.Tables[0].Rows[0]["emails_alerta"].ToString();
            sendbcc = emails;
            sendemail = email;
        }

        try
        {
            MailMessage mailMessage = new MailMessage();

            string newsletterText = string.Empty;
            newsletterText = File.ReadAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "template.html"));

            newsletterText = newsletterText.Replace("[EMAIL_INTRO]", intro);
            newsletterText = newsletterText.Replace("[EMAIL_TEXTBODY]", body);

            mailMessage.From = new MailAddress(from, "AMG Car Service");

            mailMessage.To.Add(sendemail);

            if (sendcc.Trim() != "")
                mailMessage.CC.Add(sendcc);
            if (sendbcc.Trim() != "")
                mailMessage.Bcc.Add(sendbcc);

            mailMessage.Subject = subject;
            mailMessage.Body = newsletterText;
            mailMessage.IsBodyHtml = true;
            mailMessage.Priority = MailPriority.Normal;

            mailMessage.SubjectEncoding = Encoding.UTF8;
            mailMessage.BodyEncoding = Encoding.UTF8;

            SmtpClient smtpClient = new SmtpClient(smtp);
            NetworkCredential mailAuthentication = new NetworkCredential(from, pwd);

            smtpClient.EnableSsl = true;
            smtpClient.UseDefaultCredentials = false;
            smtpClient.Credentials = mailAuthentication;
            smtpClient.Timeout = timeout;
            smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;

            smtpClient.Send(mailMessage);
            smtpClient.Dispose();
        }
        catch (Exception ex)
        {
            return "0";
        }

        return "1";
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
                string pathToSave = Server.MapPath("~") + "ClientesCarregados" + DateTime.Now.ToShortDateString().Replace("/", "") + "_" + DateTime.Now.ToLocalTime().ToShortTimeString().Replace(":", "") + extension;
                
                if(!extension.Contains("csv") && !extension.Contains("xls"))
                {
                    uploadFileSuccess.InnerHtml = "";
                    uploadFileDanger.InnerHtml = "Por favor, selecione um ficheiro Excel válido! (*.csv | *.xls | *.xlsx)";
                    return;
                }

                FileUploadControl.SaveAs(pathToSave);

                if (oDB.insertCSVFileIntoDB(pathToSave, "CUSTOMERS", userID.Text))
                {
                    uploadFileSuccess.InnerHtml = "Clientes Carregados com sucesso!";
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

    [WebMethod]
    public static string buildCurrentAccount(string id, string idUser)
    {
        string sql = "", pdfText = "", invoicesData = "", pdfHeader = "", pdfFooter = "", pdfBody = "";
        string cliente = "", morada = "", localidade = "", codpostal = "", email = "", telemovel = "", nif = "", dataatual = "",
            data_manutencao = "", descricao = "", valor = "", numero = "", data_vencimento = "", iban = "", iva = "", totalfaturas = "", totaliva = "";
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

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  declare @id int;
                                declare @id_cliente int = {0};
                                declare @min_date date;
                                declare @max_date date;
                                declare @min_due_date date;
                                declare @max_due_date date;
                                declare @iban varchar(100) = (select iban from report_configs());
                                declare @id_op int = {1};
                                declare @tipoLog varchar(200) = 'CLIENTES';
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
                                where paga = 0
                                group by cliente, morada_cliente, localidade_cliente, codpostal_cliente, email_cliente, telemovel_cliente, nif_cliente

                                select
	                                data_doc_uk,
	                                descricao,
	                                valortotal,
	                                numero,
	                                data_vencimento_uk,
	                                paga,
	                                metodo_pagamento,
                                    valoriva
                                from REPORT_ALL_CUSTOMERS_INVOICES(@id, @id_cliente, @min_date, @max_date, @min_due_date, @max_due_date)
                                where paga = 0
                                order by data_vencimento asc

                                select distinct
                                    @log = CONCAT(@log, 'O utilizador ', @codOp, ' gerou a conta corrente do cliente ', cliente)
                                from REPORT_ALL_CUSTOMERS_INVOICES(@id, @id_cliente, @min_date, @max_date, @min_due_date, @max_due_date)
                                where paga = 0

                                EXEC REGISTA_LOG @id_op, null, @tipoLog, @log, @retLog output, @retMsgLog output;", id, idUser);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                if(j == 0)
                {
                    for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                    {
                        cliente = oDs.Tables[j].Rows[i]["cliente"].ToString().Trim();
                        morada = oDs.Tables[j].Rows[i]["morada_cliente"].ToString().Trim();
                        localidade = oDs.Tables[j].Rows[i]["localidade_cliente"].ToString().Trim();
                        codpostal = oDs.Tables[j].Rows[i]["codpostal_cliente"].ToString().Trim();
                        email = oDs.Tables[j].Rows[i]["email_cliente"].ToString().Trim();
                        telemovel = oDs.Tables[j].Rows[i]["telemovel_cliente"].ToString().Trim();
                        nif = oDs.Tables[j].Rows[i]["nif_cliente"].ToString().Trim();
                        dataatual = oDs.Tables[j].Rows[i]["data_atual"].ToString().Trim();
                        totalfaturas = oDs.Tables[j].Rows[i]["valortotal"].ToString().Trim();
                        totaliva = oDs.Tables[j].Rows[i]["valoriva"].ToString().Trim();
                        iban = oDs.Tables[j].Rows[i]["iban"].ToString().Trim();
                    }
                }
                else
                {
                    for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                    {
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
                }
            }

            try
            {
                pdfText = File.ReadAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "template_contacorrente.html"));

                pdfText = pdfText.Replace(salutationToReplace, "Exmo(s) Sr(s):");
                pdfText = pdfText.Replace(nameToReplace, cliente);
                pdfText = pdfText.Replace(addressToReplace, morada);
                pdfText = pdfText.Replace(zipcodeToReplace, codpostal);
                pdfText = pdfText.Replace(cityToReplace, localidade);
                pdfText = pdfText.Replace(nifToReplace, nif);
                pdfText = pdfText.Replace(ibanToReplace, "");
                pdfText = pdfText.Replace(dataToReplace, dataatual);
                pdfText = pdfText.Replace(invoiceDataToReplace, invoicesData);
                pdfText = pdfText.Replace(ibanGCSReplace, iban);
                pdfText = pdfText.Replace(totalToReplace, totalfaturas.ToString());
                pdfText = pdfText.Replace(subjectToReplace, "Conta Corrente - " + cliente + " - " + dataatual);

                pdfFooter = String.Format(@"    <div style='margin-left: 29.7324px; margin-right: 29.7324px; margin-top: 10px; height: auto; font-family: 'Roboto', sans-serif; color: #000;'>
                                                    <img src='http://www.jpdado.pt/AMG/template_footer.png' style='width:100%; height: 100%' />
                                                </div>");

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
                                                </div>", "Exmo(s) Sr(s):", cliente, morada, codpostal, localidade, nif);

                pdfBody = String.Format(@"  <div style='margin-left: 29.7324px; margin-right: 29.7324px; height: 1390px; width: 100%; font-family: 'Roboto', sans-serif; color: #000;'>
                                                <br /><br /><br /><br /><br /><br /><br /><br /><br />
                                                <div style='height: auto; text-align: justify;'>
                                                        <div style='height: auto;'>
                                                            <h3>Assunto: Resumo de Faturação Grilo Car Service</h3>
                                                            <h4>Processado em: {0}</h4>
                                                            <h5>
                                                                Junto enviamos o vosso extrato de conta corrente para vossa conferência de faturas.<br />
                                                                Agradecemos o pagamento dos documentos vencidos no prazo estabelecido conforme condições contratuais, para o seguinte IBAN:<br />
                                                                {2}<br />
                                                                Para eventuais esclarecimentos, por favor contacte<br />
                                                                Cátia Grilo - (+351) 918 334 093    grilocarservice22 @gmail.com
                                                            </h5>
                                                            <br />
                                                        </div>
                                                    </div>
                                                <div style='height: auto; text-align: justify;'>
                                                    <div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1); text-align: center'>
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
                                                    </div>
                                                    {1}
                                                    <br />
                                                    <div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1);'>
                                                        <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                        <div style='width: 73.5%; display: inline-block; text-align: left;'>
                                                            <h5>TOTAL EM DÍVIDA</h5>
                                                        </div>
                                                        <div style='width: 23.5%; display: inline-block; text-align: right;'>
                                                            <h5>{3} €</h5>
                                                        </div>
                                                        <hr style='margin-top: 0 !important; margin-right: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                    </div>
                                                </div>
                                            </div>", dataatual, invoicesData, iban, totalfaturas);
            }
            catch (Exception ex)
            {
                return "extrato_contacorrente_" + cliente + "_" + dataatual.Replace("/", "") + "<#SEP#>" + pdfText;
            }
        }

        return "extrato_contacorrente_" + cliente + "_" + dataatual.Replace("/", "") + "<#SEP#>" + pdfHeader + "<#SEP#>" + pdfFooter + "<#SEP#>" + pdfBody + "<#SEP#>" + "Conta Corrente - " + cliente + " - " + dataatual;
    }
}