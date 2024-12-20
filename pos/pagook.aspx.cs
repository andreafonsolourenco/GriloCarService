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


public partial class pos_pagook : System.Web.UI.Page
{
    string id = "null", pago = "",valor="";
    protected void Page_Load(object sender, EventArgs e)
    {
        DataSqlServer oDB = new DataSqlServer();

        try
        {
            id = Request.QueryString["id"];
            pago = Request.QueryString["pago"];
            valor = Request.QueryString["valor"];

            txtIDMaquina.Value = id;
        }
        catch (Exception)
        {
        }

        if (pago == "0")
            lblMensagem.InnerText = "Montante Não Pago";
        else
        {
            lblMensagem.InnerText = "Montante Pago";
            lblMensagem.Style["color"] = "green";


            string subject="", body="", intro = "";


            string sql = string.Format(@"declare @id int = {0}
                                             SELECT
	                                            cli.nome cliente,
	                                            cli.cashdronome,
	                                            cli.nif,
	                                            cli.morada,
	                                            cli.nomeestabelecimento,
	                                            cli.pessoaresponsavel,
	                                            cli.telemovel telefone,
	                                            isnull(pa.email,'') email_parceiro,
	                                            cli.email email_cliente,
	                                            cg.emails_alerta email_helptech
                                            FROM cashdro_maquinas mq
                                            INNER JOIN UTILIZADORES cli ON cli.UTILIZADORESID = mq.id_cliente
                                            LEFT JOIN CASHDRO_PARCEIRO_CLIENTE pc on pc.ID_CLIENTE = cli.UTILIZADORESID
                                            LEFT JOIN UTILIZADORES pa ON pa.UTILIZADORESID = pc.ID_PARCEIRO
                                            INNER JOIN CONFIG_GERAL cg on 1=1
                                            WHERE mq.CASHDRO_MAQUINASID=@id", id);

            DataSet oDsCli = oDB.GetDataSet(sql, "").oData;

            // Vai obter os dados das máquinas
            if (oDB.validaDataSet(oDsCli))
            {
                string nomemaquina = oDsCli.Tables[0].Rows[0]["cashdronome"].ToString().Trim();


                intro = "Novo pagamento efetuado";
                subject = "CashDro Portal - Novo pagamento efetuado";
                body = "Informa-se que foi efetuado o pagamento abaixo:<br /><br />";
                body += "<table style='width:98%; text-align:center'>";
                body += "<tr>";
                body += "  <td>Máquina</td>";
                body += "  <td>Valor</td>";
                body += "</tr>";
                body += "<tr>";
                body += "  <td>" + nomemaquina + "</td>";
                body += "  <td>" + valor + "</td>";
                body += "</tr>";

                // Envia o email
                sendEmail(subject, body, intro);
            }
        }
    }

    [WebMethod]
    public static Boolean sendEmail(string subject, string body, string intro)
    {
        int timeout = 50000;
        int i = 0;
        string sql = "", sendemail = "", sendcc = "", sendbcc = "", from = "", pwd = "", smtp = "", smtpport = "", emails = "";
        string[] emailVector;

        DataSqlServer oDB = new DataSqlServer();

        sql = string.Format(@"  SELECT
                                    email,
                                    email_password,
                                    email_smtp,
                                    email_smtpport,
                                    emails_alerta
                                FROM CASHDRO_REPORT_CONFIGS()");
        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            from = oDs.Tables[0].Rows[0]["email"].ToString().Trim();
            pwd = oDs.Tables[0].Rows[0]["email_password"].ToString().Trim();
            smtp = oDs.Tables[0].Rows[0]["email_smtp"].ToString().Trim();
            smtpport = oDs.Tables[0].Rows[0]["email_smtpport"].ToString().Trim();
            emails = oDs.Tables[0].Rows[0]["emails_alerta"].ToString();
            emailVector = emails.Split(';');
            i = 0;

            foreach (var word in emailVector)
            {
                if (i == 0)
                {
                    sendemail = word;
                }
                else
                {
                    if (i == 1)
                    {
                        sendbcc += word;
                    }
                    else
                    {
                        sendbcc += ";" + word;
                    }
                }
                i++;
            }
        }

        try
        {
            MailMessage mailMessage = new MailMessage();

            string newsletterText = string.Empty;
            newsletterText = File.ReadAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "template.html"));

            newsletterText = newsletterText.Replace("[EMAIL_INTRO]", intro);
            newsletterText = newsletterText.Replace("[EMAIL_TEXTBODY]", body);

            mailMessage.From = new MailAddress(from, "HelpTech Cashdro Support");

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
            return false;
        }

        return true;
    }





}