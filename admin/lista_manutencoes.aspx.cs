using System;
using System.Web.Services;
using System.Data;
using System.Net;
using System.IO;

public partial class lista_manutencoes : System.Web.UI.Page
{
    string orcamento = "null";
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            orcamento = Request.QueryString["orcamento"];
        }
        catch (Exception)
        {
        }

        txtAuxOrcamento.Value = orcamento;
        getDates();
    }

    [WebMethod]
    public static string getGrelha(string pesquisa, string order, string admin, string orcamento, string initialDate, string finalDate)
    {
        string sql = "", html = "", htmlOptions = "";
        string id = "", cliente = "", marca = "", modelo = "", ano = "", matricula = "", data_manutencao = "", descricao = "", descricao_final = "";
        bool mecanica = false, batechapas = false, revisao = false;
        string mecanicaIcon = "<i class='fa fa-wrench text-primary' aria-hidden='true' style='width:75%; height: auto;'></i>",
            batechapasIcon = "<i class='fa fa-paint-brush text-primary' aria-hidden='true' style='width:75%; height: auto;'></i>",
            icons = "";

        DataSqlServer oDB = new DataSqlServer();

        html += @"  <table class='table align-items-center table-flush'>
		                <thead class='thead-light'>
		                    <tr>
			                    <th scope='col' class='pointer th_text' onclick='ordenaCliente();'>Cliente</th>
			                    <th scope='col' class='pointer th_text' onclick='ordenaViatura();'>Viatura</th>
                                <th scope='col' class='pointer th_text' onclick='ordenaData();'>Data</th>
                                <th scope='col' class='pointer th_text' onclick='ordenaDescricao();'>Descrição</th>
                                <th scope='col' class='pointer th_text' onclick='ordenaTipo();' style='text-align:center'>Tipo</th>
                                <th scope='col' class='pointer th_text'></th>
		                    </tr>
		                </thead><tbody>";

        sql = String.Format(@"  set dateformat dmy;
                                declare @id int;
                                declare @id_cliente int;
                                declare @id_viatura int;
                                declare @mecanica bit;
                                declare @batechapas bit;
                                declare @dataInicial date = '{3}';
                                declare @dataFinal date = '{4}';

                                select 
	                                id,
		                            cliente,
		                            marca,
		                            modelo,
		                            ano,
		                            matricula,
		                            data_manutencao,
		                            data_manutencao_it,
		                            data_manutencao_uk,
		                            data_manutencao_jp,
		                            data_manutencao_odbc,
		                            descricao,
		                            mecanica,
		                            batechapas,
		                            revisao
                                from {2}(@id, @id_cliente, @id_viatura, @mecanica, @batechapas)
                                where (cliente like {0} or marca like {0} or modelo like {0} or ano like {0} or matricula like {0} 
                                or data_manutencao like {0} or data_manutencao_it like {0} or data_manutencao_uk like {0} or data_manutencao_jp like {0} or data_manutencao_odbc like {0}
                                or descricao like {0}) and data_manutencao >= @dataInicial and data_manutencao <= @dataFinal
                                {1}", 
                                    String.Format("'%{0}%'", pesquisa), 
                                    order,
                                    String.Format("{0}", orcamento == "1" ? "REPORT_ORCAMENTOS" : "REPORT_MAINTENANCES"),
                                    initialDate, finalDate);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    id = oDs.Tables[j].Rows[i]["id"].ToString().Trim();
                    cliente = oDs.Tables[j].Rows[i]["cliente"].ToString().Trim();
                    marca = oDs.Tables[j].Rows[i]["marca"].ToString().Trim();
                    modelo = oDs.Tables[j].Rows[i]["modelo"].ToString().Trim();
                    ano = oDs.Tables[j].Rows[i]["ano"].ToString().Trim();
                    matricula = oDs.Tables[j].Rows[i]["matricula"].ToString().Trim();
                    data_manutencao = oDs.Tables[j].Rows[i]["data_manutencao"].ToString().Trim().Substring(0, 10);
                    descricao = oDs.Tables[j].Rows[i]["descricao"].ToString().Trim();
                    mecanica = Convert.ToBoolean(oDs.Tables[j].Rows[i]["mecanica"].ToString().Trim());
                    batechapas = Convert.ToBoolean(oDs.Tables[j].Rows[i]["batechapas"].ToString().Trim());
                    revisao = Convert.ToBoolean(oDs.Tables[j].Rows[i]["revisao"].ToString().Trim());
                    descricao_final = "";

                    icons = (mecanica ? mecanicaIcon : "") + (batechapas ? batechapasIcon : "");

                    if (descricao.Length > 40)
                    {
                        string[] descricaoSplit = descricao.Split(' ');
                        int lineLength = 0;

                        for (int pos = 0; pos < descricaoSplit.Length; pos++)
                        {
                            descricao_final += descricaoSplit[pos];
                            lineLength += descricaoSplit[pos].Length;

                            if (lineLength < 40)
                            {
                                descricao_final += " ";
                                lineLength++;
                            }
                            else
                            {
                                descricao_final += "<br />";
                                lineLength = 0;
                            }
                        }
                    }
                    else
                    {
                        descricao_final = descricao;
                    }

                    if (admin == "1")
                    {
                        htmlOptions = String.Format(@"  <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                                            <a class='dropdown-item' href='#' onclick='visualizar({0});'>Visualizar</a>
			                                                <a class='dropdown-item' href='#' onclick='editar({0});'>Editar</a>
                                                            <a class='dropdown-item' href='#' onclick='eliminar({0});'>Eliminar</a>
                                                            {1}
			                                            </div>", 
                                                        id, 
                                                        orcamento == "1" ? String.Format(@"<a class='dropdown-item' href='#' onclick='generatePDF({0});'>Gerar PDF</a>", id) : "");
                    }
                    else
                    {
                        htmlOptions = String.Format(@"  <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                                            <a class='dropdown-item' href='#' onclick='visualizar({0});'>Visualizar</a>
			                                            </div>", id);
                    }

                    html += String.Format(@"    <tr class='pointer' ondblclick='editar({0});'> 
		                                            <td><span>{1}</span></td>
		                                            <td><span>{2} {3} ({4})</span></td>
                                                    <td><span>{5}</span></td>
                                                    <td><span>{6}</span></td>
                                                    <td style='text-align:center;'>
		                                                <span class='badge badge-dot mr-12'>{8}</span>
                                                    </td>
		                                            <td class='text-right'>
		                                                <div class='dropdown'>
			                                                <a class='btn btn-sm btn-icon-only text-light' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
			                                                    <i class='fas fa-ellipsis-v'></i>
			                                                </a>
                                                            {7}
		                                                </div>
		                                            </td>                    
	                                            </tr>", id, cliente, marca, modelo, matricula, data_manutencao, descricao_final, htmlOptions, icons);
                }
            }
        }
        else
        {
            html += String.Format(@"<tr><td colspan='3'>Não existem {0} a apresentar.</td></tr> ", orcamento == "1" ? "orçamentos" : "reparações");
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
    public static string generatePDF(string idUser, string id, string orcamento)
    {
        string sql = "", pdfText = "", invoicesData = "", pdfHeader = "", pdfFooter = "", pdfBody = "";
        string cliente = "", morada = "", localidade = "", codpostal = "", email = "", telemovel = "", nif = "", marca = "", modelo = "", ano = "", matricula = "", kms_viatura = "", 
            data_atual = "", data_manutencao_uk = "", data_vencimento_uk = "", descricao = "", valortotal = "", valoriva = "", valorsemiva = "", numero = "",
            descricao_linha = "", valor_linha = "", iva_linha = "";
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

        sql = String.Format(@"  declare @id_maintenance int = {0};
                                declare @id_cliente int;
                                declare @id_viatura int;
                                declare @mecanica bit;
                                declare @batechapas bit;
                                declare @iban varchar(100) = (select iban from report_configs());
                                declare @id_op int = {1};
                                declare @tipoLog varchar(200) = '{2}';
                                declare @log varchar(max);
                                declare @retLog int;
                                declare @retMsgLog varchar(max);
                                declare @id_linha int;
                                declare @codOp varchar(30) = (select codigo from REPORT_USERS(@id_op, null, null, 1, null))

                                select
	                                cliente,
	                                morada_cliente,
	                                localidade_cliente,
	                                codpostal_cliente,
	                                email_cliente,
	                                telemovel_cliente,
	                                nif_cliente,
	                                marca,
	                                modelo,
	                                ano,
	                                matricula,
	                                kms_viatura,
                                    convert(varchar, cast(getdate() as date), 103) as data_atual,
                                    data_manutencao_uk,
	                                data_vencimento_uk,
	                                descricao,
	                                valortotal,
	                                valoriva,
                                    (valortotal - valoriva) as valorsemiva,
	                                numero
                                from {3}(@id_maintenance, @id_cliente, @id_viatura, @mecanica, @batechapas)

                                select
		                            descricao_linha,
		                            valor,
		                            iva
                                from {4}(@id_linha, @id_maintenance)

                                select
	                                @log = CONCAT(@log, 'O utilizador ', @codOp, ' gerou o orçamento ', numero, ' em pdf.')
                                from {3}(@id_maintenance, @id_cliente, @id_viatura, @mecanica, @batechapas)

                                EXEC REGISTA_LOG @id_op, @id_maintenance, @tipoLog, @log, @retLog output, @retMsgLog output;", id, idUser, orcamento == "1" ? "ORÇAMENTOS" : "REPARAÇÕES", orcamento == "1" ? "REPORT_ORCAMENTOS" : "REPORT_MAINTENANCES", orcamento == "1" ? "REPORT_ORCAMENTO_LINES" : "REPORT_MAINTENANCE_LINES");

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                if (j == 0)
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
                        data_atual = oDs.Tables[j].Rows[i]["data_atual"].ToString().Trim();
                        valortotal = oDs.Tables[j].Rows[i]["valortotal"].ToString().Trim().Replace(",", ".");
                        valoriva = oDs.Tables[j].Rows[i]["valoriva"].ToString().Trim().Replace(",", ".");
                        marca = oDs.Tables[j].Rows[i]["marca"].ToString().Trim();
                        modelo = oDs.Tables[j].Rows[i]["modelo"].ToString().Trim();
                        ano = oDs.Tables[j].Rows[i]["ano"].ToString().Trim();
                        matricula = oDs.Tables[j].Rows[i]["matricula"].ToString().Trim();
                        kms_viatura = oDs.Tables[j].Rows[i]["kms_viatura"].ToString().Trim();
                        data_manutencao_uk = oDs.Tables[j].Rows[i]["data_manutencao_uk"].ToString().Trim();
                        data_vencimento_uk = oDs.Tables[j].Rows[i]["data_vencimento_uk"].ToString().Trim();
                        descricao = oDs.Tables[j].Rows[i]["descricao"].ToString().Trim();
                        valorsemiva = oDs.Tables[j].Rows[i]["valorsemiva"].ToString().Trim().Replace(",", ".");
                        numero = oDs.Tables[j].Rows[i]["numero"].ToString().Trim();
                    }
                }
                else
                {
                    for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                    {
                        descricao_linha = oDs.Tables[j].Rows[i]["descricao_linha"].ToString().Trim();
                        valor_linha = oDs.Tables[j].Rows[i]["valor"].ToString().Trim().Replace(",", ".");
                        iva_linha = oDs.Tables[j].Rows[i]["iva"].ToString().Trim().Replace(",", ".");

                        invoicesData += String.Format(@"    <div style='width: 100%; height: auto; margin-top: 0! important; text-align: center; color: #000;'>
                                                                <div style='width: 50%; display: inline-block;'>
                                                                    <p style='font-size: 0.75rem'>{0}</p>
                                                                </div>
                                                                <div style='width: 24%; display: inline-block;'>
                                                                    <p style='font-size: 0.75rem'>{1} €</p>
                                                                </div>
                                                                <div style='width: 24%; display: inline-block;'>
                                                                    <p style='font-size: 0.75rem'>{2}</p>
                                                                </div>
                                                            </div>", descricao_linha, valor_linha, iva_linha);
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

                pdfHeader = String.Format(@"    <div style='width: 100%; height: auto; margin-left: 29.7324px; margin-right: 29.7324px; margin-top: 39.788px; font-family: 'Roboto', sans-serif; color: #000;'> 
                                                    <div style='height: auto;'>
                                                        <div style='width: 24%; text-align: center; display: inline-block; float: left'>
                                                            <img src='http://www.jpdado.pt/AMG/logo.png' style='width:100%; height: auto;' />
                                                        </div>
                                                        <div style='width: 76%; display: inline-block; float: right; padding-left: 40px'>
                                                            <div style='width:100%'>
                                                                <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                                <div style='width: 50%; display: inline-block; float: left;'>
                                                                    <h4>DATA:<br />{6}</h4>
                                                                </div>
                                                                <div style='width: 50%; display: inline-block; float: right;'>
                                                                    <h4>DATA VENCIMENTO:<br />{7}</h4>
                                                                </div>
                                                            </div>
                                                            <div style='width:100%'>
                                                                <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                                <h4>{0}<br />{1}<br />{2}<br />{3} {4}<br />NIF: {5}</h4>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>", "Exmo(s) Sr(s):", cliente, morada, codpostal, localidade, nif, data_manutencao_uk, data_vencimento_uk);

                pdfBody = String.Format(@"  <div style='margin-left: 29.7324px; margin-right: 29.7324px; height: 1390px; width: 100%; font-family: 'Roboto', sans-serif; color: #000;'>
                                                <br /><br /><br /><br /><br /><br /><br /><br /><br />
                                                <div style='height: auto; text-align: justify;'>
                                                        <div style='height: auto;'>
                                                            <h3>VIATURA:</h3>
                                                            <h3>{0} {1} ({2})</h3>
                                                            <br />
                                                        </div>
                                                    </div>
                                                <div style='height: auto; text-align: justify;'>
                                                    <div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1); text-align: center'>
                                                        <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                        <div style='width: 50%; display: inline-block;'>
                                                            <h3>DESCRIÇÃO</h3>
                                                        </div>
                                                        <div style='width: 24%; display: inline-block;'>
                                                            <h3>VALOR S/IVA</h3>
                                                        </div>
                                                        <div style='width: 24%; display: inline-block;'>
                                                            <h3>IVA</h3>
                                                        </div>
                                                        <hr style='margin-top: 0 !important; margin-right: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                    </div>
                                                    {3}
                                                    <br /><br /><br /><br /><br />
                                                    <div style='width: 100%; height: auto; background-color: rgba(0, 0, 0, 0.1);'>
                                                        <hr style='margin-top: 0 !important; margin-bottom: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                        <div style='width: 73.5%; display: inline-block; text-align: right;'>
                                                            <h3>
                                                                VALOR LÍQUIDO:<br /><br />
                                                                IVA:<br /><br />
                                                                VALOR TOTAL:
                                                            </h3>
                                                        </div>
                                                        <div style='width: 23.5%; display: inline-block; text-align: right;'>
                                                            <h3>
                                                                {4} €<br /><br />
                                                                {5} €<br /><br />
                                                                {6} €<br />
                                                            </h3>
                                                        </div>
                                                        <hr style='margin-top: 0 !important; margin-right: 0 !important; width: 100%; border: 0; height: 0; background-color: rgba(0, 0, 0, 0.3); border-top: 1px solid rgba(0, 0, 0, 0.3); border-bottom: 1px solid rgba(0, 0, 0, 0.3);' />
                                                    </div>
                                                </div>
                                            </div>", marca, modelo, matricula, invoicesData, valorsemiva, valoriva, valortotal);
            }
            catch (Exception ex)
            {
                return "orcamento_" + cliente + "_" + matricula + "_" + data_atual.Replace("/", "") + "<#SEP#>" + pdfText;
            }
        }

        return "orcamento_" + cliente + "_" + matricula + "_" + data_atual.Replace("/", "") + "<#SEP#>" + pdfHeader + "<#SEP#>" + pdfFooter + "<#SEP#>" + pdfBody + "<#SEP#>" + "Orçamento " + cliente + " " + matricula + " - " + data_atual;
    }

    public void getDates()
    {
        string sql = "", dataInicial = "", dataFinal = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  declare @id int;
                                declare @id_cliente int;
                                declare @id_viatura int;
                                declare @mecanica bit;
                                declare @batechapas bit;
                                declare @count int = (select count(*) from {0}(@id, @id_cliente, @id_viatura, @mecanica, @batechapas));

                                if(@count > 0)
                                begin
                                    select top 1
	                                    data_manutencao_uk as data_final,
		                                convert(varchar, DATEADD(month, -1, data_manutencao), 103) as data_inicial
                                    from {0}(@id, @id_cliente, @id_viatura, @mecanica, @batechapas)
                                    order by data_manutencao desc
                                end
                                else
                                begin
                                    select convert(varchar, getdate(), 103) as data_final, convert(varchar, DATEADD(month, -1, getdate()), 103) as data_inicial
                                end", orcamento == "1" ? "REPORT_ORCAMENTOS" : "REPORT_MAINTENANCES");

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    dataInicial = oDs.Tables[j].Rows[i]["data_inicial"].ToString().Trim();
                    dataFinal = oDs.Tables[j].Rows[i]["data_final"].ToString().Trim();
                }
            }
        }

        txtDataInicial.Value = dataInicial;
        txtDataFinal.Value = dataFinal;
    }
}