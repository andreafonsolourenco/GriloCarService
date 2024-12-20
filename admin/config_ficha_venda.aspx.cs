using System;
using System.Web.Services;
using System.Data;

public partial class config_ficha_venda : System.Web.UI.Page
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

                                EXEC CRIA_EDITA_SALE @id, @xml, @error OUTPUT, @errorMsg OUTPUT

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
        string sql = "", cliente = "", morada_cliente = "", localidade_cliente = "", codpostal_cliente = "", nif_cliente = "",
            data_venda = "", descricao = "", valortotal = "", valoriva = "", lines = "", numero = "", data_vencimento = "", metodo_pagamento = "";

        bool paga = false;
        string s_paga = "false";

        const string sep = "<#SEP#>";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  set dateformat dmy
                                DECLARE @id int = {0}
                                DECLARE @id_cliente int;
                                DECLARE @id_linha int;
                                DECLARE @min_date date;
                                DECLARE @max_date date;
                                DECLARE @min_due_date date;
                                DECLARE @max_due_date date;
                                DECLARE @lines int = (select count(id_linha) from report_sales_lines(@id_linha, @id, @id_cliente))

                                SELECT
	                                id,
		                            id_cliente,
		                            cliente,
		                            morada_cliente,
		                            localidade_cliente,
		                            codpostal_cliente,
		                            email_cliente,
		                            telemovel_cliente,
		                            nif_cliente,
		                            data_venda,
		                            data_venda_it,
		                            data_venda_uk,
		                            data_venda_jp,
		                            data_venda_odbc,
		                            descricao,
		                            valortotal,
		                            valoriva,
		                            numero,
		                            data_vencimento,
		                            data_vencimento_it,
		                            data_vencimento_uk,
		                            data_vencimento_jp,
		                            data_vencimento_odbc,
		                            paga,
                                    @lines as lines
                                FROM report_sales(@id, @id_cliente, @min_date, @max_date, @min_due_date, @max_due_date)", id);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            cliente = oDs.Tables[0].Rows[0]["cliente"].ToString().Trim();
            morada_cliente = oDs.Tables[0].Rows[0]["morada_cliente"].ToString().Trim();
            localidade_cliente = oDs.Tables[0].Rows[0]["localidade_cliente"].ToString().Trim();
            codpostal_cliente = oDs.Tables[0].Rows[0]["codpostal_cliente"].ToString().Trim();
            nif_cliente = oDs.Tables[0].Rows[0]["nif_cliente"].ToString().Trim();
            data_venda = oDs.Tables[0].Rows[0]["data_venda_uk"].ToString().Trim();
            descricao = oDs.Tables[0].Rows[0]["descricao"].ToString().Trim();
            valortotal = oDs.Tables[0].Rows[0]["valortotal"].ToString().Trim().Replace(",", ".");
            valoriva = oDs.Tables[0].Rows[0]["valoriva"].ToString().Trim().Replace(",", ".");
            lines = oDs.Tables[0].Rows[0]["lines"].ToString().Trim();
            paga = Convert.ToBoolean(oDs.Tables[0].Rows[0]["paga"]);
            numero = oDs.Tables[0].Rows[0]["numero"].ToString().Trim();
            data_vencimento = oDs.Tables[0].Rows[0]["data_vencimento_uk"].ToString().Trim();
            metodo_pagamento = oDs.Tables[0].Rows[0]["metodo_pagamento"].ToString().Trim();
            s_paga = paga ? "true" : "false";
        }

        // Prepara o retorno dos dados
        return cliente + sep +
              morada_cliente + sep +
              localidade_cliente + sep +
              codpostal_cliente + sep +
              nif_cliente + sep +
              data_venda + sep +
              descricao + sep +
              valortotal + sep +
              valoriva + sep +
              lines + sep +
              s_paga + sep +
              numero + sep +
              data_vencimento + sep +
              metodo_pagamento;
    }

    [WebMethod]
    public static string getLinesData(string id)
    {
        string sql = "", id_linha = "", descricao = "", valor = "", valoriva = "";
        string ret = "", background_color = " background_white ";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  set dateformat dmy
                                DECLARE @id int = {0}
                                DECLARE @id_linha int;
                                DECLARE @id_customer int;

                                SELECT
	                                id,
		                            id_sale,
		                            descricao_linha,
		                            valor,
		                            iva
                                FROM REPORT_SALES_LINES(@id_linha, @id, @id_customer)", id);
        
        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    id_linha = oDs.Tables[j].Rows[i]["id_linha"].ToString().Trim();
                    descricao = oDs.Tables[j].Rows[i]["descricao_linha"].ToString().Trim();
                    valor = oDs.Tables[j].Rows[i]["valor"].ToString().Trim().Replace(",", ".");
                    valoriva = oDs.Tables[j].Rows[i]["iva"].ToString().Trim().Replace(",", ".");

                    ret += String.Format(@" <div class='row pointer margin_lines_row{5}' id='line{0}' ondblclick='openNewLineDialog({0});'>
                                                <div class='variaveis' id='div{0}Id'>{1}</div>
                                                <div class='col-md-6' id='div{0}Description'>{2}</div>
                                                <div class='col-md-3' id='div{0}Value'>{3}€</div>
                                                <div class='col-md-3' id='div{0}IVA'>{4}%</div>
                                            </div>", i, id_linha, descricao, valor, valoriva, (i%2 != 0) ? background_color : "");
                }
            }
        }

        // Prepara o retorno dos dados
        return ret;
    }

    [WebMethod]
    public static string getCustomersList(string search, string dialogOpen)
    {
        string sql = "", html = "", htmlWithSearch = "";
        string id = "", nome = "", nif = "", localidade = "";

        DataSqlServer oDB = new DataSqlServer();

        html += @"  <input id='customerSearchBar' class='form-control' placeholder='Pesquisar...' type='text' style='color: black; width: 75%; float:left;' />
                    <img id='customerSearchIcon' src='../Img/search_icon.png' style='width: auto; height: calc(2.75rem + 2px); cursor: pointer; margin-left: 5px; float:right;' alt='Pesquisar Cliente' title='Pesquisar Cliente' onclick='getCustomersList();'/>
                    <div id='divTableCustomers'>";

        html += @"<table class='table align-items-center table-flush'>
		                                <thead class='thead-light'>
		                                    <tr>
			                                    <th scope='col' class='pointer th_text'>Nome</th>
			                                    <th scope='col' class='pointer th_text'>NIF</th>
                                                <th scope='col' class='pointer th_text'>Localidade</th>
                                            </tr>
		                                </thead>
                                        <tbody>";

        htmlWithSearch += @"<table class='table align-items-center table-flush'>
		                                <thead class='thead-light'>
		                                    <tr>
			                                    <th scope='col' class='pointer th_text'>Nome</th>
			                                    <th scope='col' class='pointer th_text'>NIF</th>
                                                <th scope='col' class='pointer th_text'>Localidade</th>
                                            </tr>
		                                </thead>
                                        <tbody>";

        sql = String.Format(@"  declare @id_customer int;
                                declare @nif varchar(10);
                                declare @ativo bit = 1;

                                select 
	                                id,
	                                nome,
	                                localidade,
                                    nif
                                from [REPORT_CUSTOMERS](@id_customer, @nif, @ativo)
                                where nome like {0} or localidade like {0} or nif like {0}
                                order by nome", String.Format("'%{0}%'", search));

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
                    localidade = oDs.Tables[j].Rows[i]["localidade"].ToString().Trim();

                    html += @"<tr class='pointer' id='customerLine" + i + "' onclick='selectCustomerRow(" + id + @", " + i + @")'> 
		                    <td><span>" + nome + @"</span></td>
		                    <td><span>" + nif + @"</span>
                            <td><span>" + localidade + @"</span>                   
	                      </tr> ";

                    htmlWithSearch += @"<tr class='pointer' id='customerLine" + i + "' onclick='selectCustomerRow(" + id + @", " + i + @")'> 
		                    <td><span>" + nome + @"</span></td>
		                    <td><span>" + nif + @"</span>
                            <td><span>" + localidade + @"</span>                   
	                      </tr> ";
                }

                html += "<span class='variaveis' id='countCustomers'>" + oDs.Tables[j].Rows.Count + "</span>";

                htmlWithSearch += "<span class='variaveis' id='countCustomers'>" + oDs.Tables[j].Rows.Count + "</span>";
            }
        }
        else
        {
            html += "<tr><td colspan='3'>Não existem clientes a apresentar.</td></tr>";
            htmlWithSearch += "<tr><td colspan='3'>Não existem clientes a apresentar.</td></tr>";
        }


        html += "</tbody></table></div>";
        htmlWithSearch += "</tbody></table></div>";

        return dialogOpen == "0" ? html : htmlWithSearch;
    }

    [WebMethod]
    public static string getCustomerData(string id, string nif)
    {
        string sql = "";
        string sep = "<#SEP#>";
        string nome = "",morada = "", codpostal = "", localidade = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  declare @id_customer int = {0};
                                declare @nif varchar(10) = {1};
                                declare @ativo bit = 1;

                                select 
	                                nome,
                                    morada,
	                                localidade,
                                    codpostal,
                                    nif
                                from [REPORT_CUSTOMERS](@id_customer, @nif, @ativo)", String.IsNullOrEmpty(id) ? "NULL" : id, String.IsNullOrEmpty(nif) ? "NULL" : String.Format(@"'{0}'", nif));

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
                }
            }
        }

        return nome + sep + morada + sep + codpostal + sep + localidade + sep + nif;
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
            txtAuxNumeroDiasPagamento.Value = oDs.Tables[0].Rows[0]["numero_dias_vencimento"].ToString().Trim();
            txtAuxDefaultInvoiceDate.Value = oDs.Tables[0].Rows[0]["defaultDate"].ToString().Trim();
            txtAuxDefaultInvoiceDueDate.Value = oDs.Tables[0].Rows[0]["defaultDueDate"].ToString().Trim();
        }
        else
        {
            txtAuxNumeroDiasPagamento.Value = "30";
            txtAuxDefaultInvoiceDate.Value = "";
            txtAuxDefaultInvoiceDueDate.Value = "";
        }
    }
}