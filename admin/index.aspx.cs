using System;
using System.Web.Services;
using System.Data;
using System.Net;
using Newtonsoft.Json.Linq;

public partial class index : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }

    [WebMethod]
    public static string trataExpiracao(string i)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "-1", retMessage = "Sessão expirada", admin = "", name = "";

        sql = string.Format(@"  DECLARE @id int = {0};
                                DECLARE @ret bit;
                                DECLARE @admin bit;
                                DECLARE @name varchar(max);

                                EXEC [VALIDATE_USER_SESSION] @id, @ret output, @admin output, @name output

                                select @ret as ret, @admin as admin, @name as name", i);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = Convert.ToInt32(Convert.ToBoolean(oDs.Tables[0].Rows[0]["ret"].ToString().Trim())).ToString();
            retMessage = ret == "1" ? "Sessão válida e ativa" : "Sessão expirada";
            admin = Convert.ToInt32(Convert.ToBoolean(oDs.Tables[0].Rows[0]["admin"].ToString().Trim())).ToString();
            name = oDs.Tables[0].Rows[0]["name"].ToString().Trim();
        }

        return ret + "<#SEP#>" + retMessage + "<#SEP#>" + admin + "<#SEP#>" + name;
    }

    [WebMethod]
    public static string generateViewInfo(string idUser, string id, string tipo)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "";

        sql = string.Format(@"  DECLARE @id int = {0};
                                DECLARE @idUser int = {1};
                                DECLARE @ret varchar(max);
                                DECLARE @tipo varchar(200) = '{2}';

                                EXEC GENERATE_VIEW_INFO @idUser, @id, @tipo, @ret output

                                select @ret as ret", id, idUser, tipo);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            return oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
        }

        return "";
    }

    [WebMethod]
    public static string getTotais(string id)
    {
        string sql = "", html = "";
        string label1 = "", total1 = "", rodape1 = "", label2 = "", total2 = "", rodape2 = "", label3 = "", total3 = "", rodape3 = "", label4 = "", total4 = "", rodape4 = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = @"    SET LANGUAGE Portuguese 
                    declare @dataatual datetime = getdate();

                    select
                        label1,
                        total1,
                        rodape1,
                        label2,
                        total2,
                        rodape2,
                        label3,
                        total3,
                        rodape3,
                        label4,
                        total4,
                        rodape4
                    from REPORT_DASHBOARD_DATA(@dataatual)";

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            label1 = oDs.Tables[0].Rows[0]["label1"].ToString().Trim();
            total1 = oDs.Tables[0].Rows[0]["total1"].ToString().Trim();
            rodape1 = oDs.Tables[0].Rows[0]["rodape1"].ToString().Trim();

            label2 = oDs.Tables[0].Rows[0]["label2"].ToString().Trim();
            total2 = oDs.Tables[0].Rows[0]["total2"].ToString().Trim();
            rodape2 = oDs.Tables[0].Rows[0]["rodape2"].ToString().Trim();

            label3 = oDs.Tables[0].Rows[0]["label3"].ToString().Trim();
            total3 = oDs.Tables[0].Rows[0]["total3"].ToString().Trim();
            rodape3 = oDs.Tables[0].Rows[0]["rodape3"].ToString().Trim();

            label4 = oDs.Tables[0].Rows[0]["label4"].ToString().Trim();
            total4 = oDs.Tables[0].Rows[0]["total4"].ToString().Trim();
            rodape4 = oDs.Tables[0].Rows[0]["rodape4"].ToString().Trim();
        }


        html = label1 + "@" + total1 + "@" + rodape1 + "@" + label2 + "@" + total2 + "@" + rodape2 + "@" + label3 + "@" + total3 + "@" + rodape3 + "@" + label4 + "@" + total4 + "@" + rodape4;

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
    public static string validateNIF(string nif)
    {
        string sql = "";
        string url = "", key = "", ret = "";
        string resultStr = "", messageStr = "", creditsUsedStr = "", creditsLeftMonthStr = "", creditsLeftDayStr = "", creditsLeftHourStr = "",
            creditsLeftMinuteStr = "", creditsLeftPaidStr = "";
        string nome = "", morada = "", codpostal = "", localidade = "", email = "", notas = "", phone = "";
        Boolean nifValidationBool = false, isNifBool = false;

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  select url_nif, nif_key from REPORT_CONFIGS()");

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            url = oDs.Tables[0].Rows[0]["url_nif"].ToString().Trim();
            key = oDs.Tables[0].Rows[0]["nif_key"].ToString().Trim();
        }

        url = url + "?json=1&q=" + nif + "&key=" + key;

        var jsonOut = getRetornoURL(url);
        //var jsonOut = "{\"result\":\"error\",\"message\":\"No records found\",\"nif_validation\":true,\"is_nif\":true,\"credits\":{\"used\":\"free\",\"left\":{\"month\":996,\"day\":96,\"hour\":9,\"minute\":0,\"paid\":0}}}";

        if (jsonOut != "")
        {
            JToken jsonOutParsed = JObject.Parse(jsonOut);
            JToken result = jsonOutParsed.SelectToken("result");
            JToken nif_validation = jsonOutParsed.SelectToken("nif_validation");
            JToken is_nif = jsonOutParsed.SelectToken("is_nif");
            JToken credits = jsonOutParsed.SelectToken("credits");
            JToken creditsUsed = credits.SelectToken("used");
            JToken creditsLeft = credits.SelectToken("left");
            JToken creditsLeftMonth = creditsLeft.SelectToken("month");
            JToken creditsLeftDay = creditsLeft.SelectToken("day");
            JToken creditsLeftHour = creditsLeft.SelectToken("hour");
            JToken creditsLeftMinute = creditsLeft.SelectToken("minute");
            JToken creditsLeftPaid = creditsLeft.SelectToken("paid");

            nifValidationBool = Convert.ToBoolean(nif_validation.ToString());
            isNifBool = Convert.ToBoolean(is_nif.ToString());

            creditsUsedStr = creditsUsed.ToString();
            creditsLeftMonthStr = creditsLeftMonth.ToString();
            creditsLeftDayStr = creditsLeftDay.ToString();
            creditsLeftHourStr = creditsLeftHour.ToString();
            creditsLeftMinuteStr = creditsLeftMinute.ToString();
            creditsLeftPaidStr = creditsLeftPaid.ToString();

            if (nifValidationBool && isNifBool)
            {
                ret += "1<#SEP#>NIF Validado com sucesso!";
            }
            else
            {
                ret += "0<#SEP#>NIF Inválido ou Inexistente";
                return ret;
            }

            resultStr = result.ToString();

            if(resultStr == "error")
            {
                JToken message = jsonOutParsed.SelectToken("message");
                messageStr = message.ToString();

                return ret;
            }
            else if(resultStr == "success")
            {
                JToken records = jsonOutParsed.SelectToken("records");
                JToken nifElements = records.SelectToken(nif);
                JToken providerName = nifElements.SelectToken("title");
                JToken providerAddress = nifElements.SelectToken("address");
                JToken providerZipCode1 = nifElements.SelectToken("pc4");
                JToken providerZipCode2 = nifElements.SelectToken("pc3");
                JToken providerCity = nifElements.SelectToken("city");
                JToken providerActivity = nifElements.SelectToken("activity");
                JToken providerContacts = nifElements.SelectToken("contacts");
                JToken providerPlace = nifElements.SelectToken("place");

                JToken contactEmail = null;
                JToken contactPhone = null;
                JToken contactWebsite = null;
                JToken contactFax = null;

                JToken placeAddress = null;
                JToken placeZipCode1 = null;
                JToken placeZipCode2 = null;
                JToken placeCity = null;

                if (providerContacts != null)
                {
                    contactEmail = providerContacts.SelectToken("email");
                    contactPhone = providerContacts.SelectToken("phone");
                    contactWebsite = providerContacts.SelectToken("website");
                    contactFax = providerContacts.SelectToken("fax");
                }

                if(providerPlace != null)
                {
                    placeAddress = providerPlace.SelectToken("address");
                    placeZipCode1 = providerPlace.SelectToken("pc4");
                    placeZipCode2 = providerPlace.SelectToken("pc3");
                    placeCity = providerPlace.SelectToken("city");
                }

                nome = providerName.ToString();
                morada = providerAddress != null ? providerAddress.ToString() : (placeAddress != null ? placeAddress.ToString() : "");
                codpostal = providerZipCode1 != null ? providerZipCode1.ToString() : (placeZipCode1 != null ? placeZipCode1.ToString() : "");

                if(codpostal != "")
                {
                    codpostal += providerZipCode2 != null ? ("-" + providerZipCode2.ToString()) : (placeZipCode2 != null ? ("-" + placeZipCode2.ToString()) : "");
                }

                localidade = providerCity != null ? providerCity.ToString() : (placeCity != null ? placeCity.ToString() : "");
                email = contactEmail != null ? contactEmail.ToString() : "";
                phone = contactPhone != null ? contactPhone.ToString() : "";

                if(providerActivity != null || contactPhone != null || contactWebsite != null || contactFax != null)
                {
                    if(providerActivity != null)
                    {
                        notas += providerActivity.ToString();
                    }

                    if(!String.IsNullOrEmpty(phone))
                    {
                        if(!String.IsNullOrEmpty(notas))
                        {
                            notas += "\n";
                        }

                        notas += "Telefone: " + phone;
                    }

                    if (contactFax != null)
                    {
                        if (!String.IsNullOrEmpty(notas))
                        {
                            notas += "\n";
                        }

                        notas += "Fax: " + contactFax.ToString();
                    }

                    if (contactWebsite != null)
                    {
                        if (!String.IsNullOrEmpty(notas))
                        {
                            notas += "\n";
                        }

                        notas += "Website: " + contactWebsite.ToString();
                    }
                }

                ret += "<#SEP#>" + nome + "<#SEP#>" + morada + "<#SEP#>" + codpostal + "<#SEP#>" + localidade + "<#SEP#>" + email + "<#SEP#>" + notas + "<#SEP#>" + phone;

                return ret;
            }
        }

        return "-1<#SEP#>Impossível validar NIF! Por favor, tente novamente!";
    }

    [WebMethod]
    public static string checkExistentCarOrCustomer(string text, string customer)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "";

        if (customer == "1")
        {
            sql = String.Format(@"  declare @id_customer int;
                                    declare @nif varchar(10) = '{0}';
                                    declare @ativo bit = 1;

                                    select 
	                                    count(id) as nr
                                    from [REPORT_CUSTOMERS](@id_customer, @nif, @ativo)", text);
        }
        else
        {
            sql = String.Format(@"  declare @id_car int;
                                    declare @matricula varchar(20) = '{0}';

                                    select 
	                                    count(id) as nr
                                    from [REPORT_CARS](@id_car, @matricula)", text);
        }

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            return oDs.Tables[0].Rows[0]["nr"].ToString().Trim();
        }

        return "0";
    }

    [WebMethod]
    public static string checkExistentProvider(string text)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "";

        sql = String.Format(@"  declare @id_provider int;
                                declare @nif varchar(10) = '{0}';

                                select 
	                                count(id) as nr
                                from [REPORT_PROVIDERS](@id_provider, @nif)", text);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            return oDs.Tables[0].Rows[0]["nr"].ToString().Trim();
        }

        return "0";
    }

    [WebMethod]
    public static string checkInvoicesToPayOnNextDays(string idUser)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", html = "";
        string nameTemp = "", name = "", iban = "", nif = "", numero = "", data_vencimento = "", valor = "";

        sql = String.Format(@"  set dateformat dmy
                                declare @id_user int = {0};
                                declare @admin bit = (select administrador from report_users(@id_user, null, null, 1, null))
                                declare @id_invoice int
                                declare @id_provider int
                                declare @id_file int
                                declare @numero varchar(500)
                                declare @min_invoice_date date;
                                declare @max_invoice_date date;
                                declare @min_due_date date = cast(getdate() as date);
                                declare @max_due_date date = dateadd(ww, 1, @min_due_date);

                                if(@admin = 1)
                                begin
                                    select
	                                    name_provider,
	                                    iban_provider,
	                                    nif_provider,
	                                    numero,
                                        data_vencimento,
	                                    data_vencimento_uk,
	                                    valor
                                    from REPORT_PROVIDER_INVOICES(@id_invoice, @id_provider, @numero, @min_invoice_date, @max_invoice_date, @min_due_date, @max_due_date)
                                    where paga = 0
                                    order by name_provider asc, data_vencimento asc
                                end", idUser);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    name = oDs.Tables[j].Rows[i]["name_provider"].ToString().Trim();
                    nif = oDs.Tables[j].Rows[i]["nif_provider"].ToString().Trim();
                    iban = oDs.Tables[j].Rows[i]["iban_provider"].ToString().Trim();

                    if (nameTemp != name)
                    {
                        nameTemp = name;

                        if (i != 0)
                        {
                            html += "</div></div>";
                        }

                        html += String.Format(@"<div class='row' style='font-weight: bold'><div class='col-md-6'>{0}<br />NIF: {1}<br />IBAN: {2}</div><div class='col-md-6'>", name, nif, iban);
                    }

                    numero = oDs.Tables[j].Rows[i]["numero"].ToString().Trim();
                    data_vencimento = oDs.Tables[j].Rows[i]["data_vencimento_uk"].ToString().Trim();
                    valor = oDs.Tables[j].Rows[i]["valor"].ToString().Trim().Replace(",", ".");

                    html += String.Format(@"<div class='row'><div class='col-md-4'>Fatura {0}</div><div class='col-md-4'>{1}€</div><div class='col-md-4'>Vence a: {2}</div></div>", numero, valor, data_vencimento);
                }

                html += "</div></div>";
            }
        }

        return html;
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

    [WebMethod]
    public static string validateIBAN(string iban)
    {
        string url = "", ret = "", sql = "";
        string validStr = "", messagesStr = "", ibanStr = "", bankDataBankCodeStr = "", bankDataNameStr = "";
        Boolean ibanValidBool = false, bankCodeBool = false;

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  select url_iban from REPORT_CONFIGS()");

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            url = oDs.Tables[0].Rows[0]["url_iban"].ToString().Trim();
        }

        url = url.Replace("[IBAN]", iban);

        var jsonOut = getRetornoURL(url);
        //var jsonOut = "{\"valid\": true, \"messages\": [ \"Cannot validate bank code length. No information available.\", \"Cannot get BIC. No information available.\" ], \"iban\": \"PT50003300004558589195405\", \"bankData\": {\"bankCode\": \"\", \"name\": \"\"},\"checkResults\": {\"bankCode\": false}}";

        if (jsonOut != "")
        {
            JToken jsonOutParsed = JObject.Parse(jsonOut);
            JToken valid = jsonOutParsed.SelectToken("valid");
            JArray messages = JArray.Parse(jsonOutParsed.SelectToken("messages").ToString());
            JToken ibanToken = jsonOutParsed.SelectToken("iban");
            JToken bankData = jsonOutParsed.SelectToken("bankData");
            JToken bankDataBankCode = bankData.SelectToken("bankCode");
            JToken bankDataName = bankData.SelectToken("name");

            ibanValidBool = Convert.ToBoolean(valid.ToString());
            
            validStr = valid.ToString();

            for(int i=0; i<messages.Count; i++)
            {
                if(i>0)
                {
                    messagesStr += "; ";
                }

                messagesStr += messages[i].ToString();
            }

            ibanStr = ibanToken.ToString();
            bankDataBankCodeStr = bankDataBankCode.ToString();
            bankDataNameStr = bankDataBankCode.ToString();

            if (ibanValidBool)
            {
                JToken checkResults = jsonOutParsed.SelectToken("checkResults");
                JToken checkResultsBankCode = checkResults.SelectToken("bankCode");
                bankCodeBool = Convert.ToBoolean(checkResultsBankCode.ToString());

                ret += "1<#SEP#>IBAN Validado com sucesso!";
            }
            else
            {
                ret += "0<#SEP#>" + messagesStr;
            }

            return ret;
        }

        return "-1<#SEP#>Impossível validar IBAN! Por favor, tente novamente!";
    }

    [WebMethod]
    public static string delRowSale(string id, string idUser)
    {
        string sql = "", ret = "1", retMessage = "Registo eliminado com sucesso.";
        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  DECLARE @id INT = {0};
                                DECLARE @idUser int = {1};
                                DECLARE @ret int
                                DECLARE @retMsg VARCHAR(255)

                                EXEC DELETE_SALE @iduser, @id, @ret OUTPUT, @retMsg OUTPUT
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
    public static string getFilesSale(string idUser, string id)
    {
        string sql = "", ret = "";
        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  DECLARE @id INT = {0};
                                DECLARE @idUser int = {1};
                                DECLARE @ret int
                                DECLARE @retMsg VARCHAR(255)
                                DECLARE @codOp varchar(500) = (select codigo from REPORT_USERS(@idUser, null, null, 1, null))
                                DECLARE @log varchar(max) = (select CONCAT('O utilizador ', @codOp, ' visualizou os documentos da venda ', numero, ' do cliente ', cliente) from REPORT_SALES(@id, null, null, null, null, null))
                                DECLARE @tipoLog varchar(200) = 'VENDAS';

                                EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @ret output, @retMsg output;

                                select file_path from REPORT_SALES_FILE(null, @id, null)", id, idUser);


        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                ret = oDs.Tables[j].Rows.Count.ToString() + "@";

                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    if (i > 0)
                    {
                        ret += "<#SEP#>";
                    }

                    ret += oDs.Tables[j].Rows[i]["file_path"].ToString().Trim();
                }
            }

            return ret;
        }

        return "0@Não existem documentos associados a esta venda!";
    }
}