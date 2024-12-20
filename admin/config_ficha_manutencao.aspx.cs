using System;
using System.Web.Services;
using System.Data;

public partial class config_ficha_manutencao : System.Web.UI.Page
{
    string id = "null";
    string orcamento = "null";

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

            try
            {
                orcamento = Request.QueryString["orcamento"];
            }
            catch (Exception)
            {
            }

            txtAux.Value = id;
            txtAuxOrcamento.Value = orcamento;
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

                                EXEC CRIA_EDITA_MANUTENCAO @id, @xml, @error OUTPUT, @errorMsg OUTPUT

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
    public static string getData(string id, string orcamento)
    {
        string sql = "", cliente = "", morada_cliente = "", localidade_cliente = "", codpostal_cliente = "", nif_cliente = "", marca = "",
            modelo = "", ano = "", matricula = "", data_manutencao = "", descricao = "", valortotal = "", valoriva = "", kms_viatura = "", lines = "",
            numero = "", data_vencimento = "", metodo_pagamento = "";

        bool mecanica = false, batechapas = false, revisao = false, paga = false;
        string s_mecanica = "false", s_batechapas = "false", s_revisao = "false", s_paga = "false";

        const string sep = "<#SEP#>";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  set dateformat dmy
                                DECLARE @id int = {0}
                                DECLARE @id_cliente int;
                                DECLARE @id_viatura int;
                                DECLARE @mecanica bit;
                                DECLARE @batechapas bit;
                                DECLARE @id_linha int;
                                DECLARE @lines int = (select count(id_linha) from {2}(@id_linha, @id))

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
		                            id_viatura,
		                            marca,
		                            modelo,
		                            ano,
		                            matricula,
		                            data_manutencao_uk,
		                            descricao,
		                            mecanica,
		                            batechapas,
		                            valortotal,
		                            revisao,
		                            valoriva,
		                            kms_viatura,
                                    numero,
		                            data_vencimento_uk,
		                            paga,
		                            metodo_pagamento,
                                    @lines as lines
                                FROM {1}(@id, @id_cliente, @id_viatura, @mecanica, @batechapas)", 
                                    id, String.Format("{0}", orcamento == "1" ? "REPORT_ORCAMENTOS" : "REPORT_MAINTENANCES"),
                                    String.Format("{0}", orcamento == "1" ? "REPORT_ORCAMENTOS_LINES" : "REPORT_MAINTENANCE_LINES"));
        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            cliente = oDs.Tables[0].Rows[0]["cliente"].ToString().Trim();
            morada_cliente = oDs.Tables[0].Rows[0]["morada_cliente"].ToString().Trim();
            localidade_cliente = oDs.Tables[0].Rows[0]["localidade_cliente"].ToString().Trim();
            codpostal_cliente = oDs.Tables[0].Rows[0]["codpostal_cliente"].ToString().Trim();
            nif_cliente = oDs.Tables[0].Rows[0]["nif_cliente"].ToString().Trim();
            marca = oDs.Tables[0].Rows[0]["marca"].ToString().Trim();
            modelo = oDs.Tables[0].Rows[0]["modelo"].ToString().Trim();
            ano = oDs.Tables[0].Rows[0]["ano"].ToString().Trim();
            matricula = oDs.Tables[0].Rows[0]["matricula"].ToString().Trim();
            data_manutencao = oDs.Tables[0].Rows[0]["data_manutencao_uk"].ToString().Trim();
            descricao = oDs.Tables[0].Rows[0]["descricao"].ToString().Trim();
            valortotal = oDs.Tables[0].Rows[0]["valortotal"].ToString().Trim().Replace(",", ".");
            valoriva = oDs.Tables[0].Rows[0]["valoriva"].ToString().Trim().Replace(",", ".");
            kms_viatura = oDs.Tables[0].Rows[0]["kms_viatura"].ToString().Trim().Replace(",", ".");
            mecanica = Convert.ToBoolean(oDs.Tables[0].Rows[0]["mecanica"]);
            batechapas = Convert.ToBoolean(oDs.Tables[0].Rows[0]["batechapas"]);
            revisao = Convert.ToBoolean(oDs.Tables[0].Rows[0]["revisao"]);
            lines = oDs.Tables[0].Rows[0]["lines"].ToString().Trim();
            paga = Convert.ToBoolean(oDs.Tables[0].Rows[0]["paga"]);
            numero = oDs.Tables[0].Rows[0]["numero"].ToString().Trim();
            data_vencimento = oDs.Tables[0].Rows[0]["data_vencimento_uk"].ToString().Trim();
            metodo_pagamento = oDs.Tables[0].Rows[0]["metodo_pagamento"].ToString().Trim();

            s_mecanica = mecanica ? "true" : "false";
            s_batechapas = batechapas ? "true" : "false";
            s_revisao = revisao ? "true" : "false";
            s_paga = paga ? "true" : "false";
        }

        // Prepara o retorno dos dados
        return cliente + sep +
              morada_cliente + sep +
              localidade_cliente + sep +
              codpostal_cliente + sep +
              nif_cliente + sep +
              marca + sep +
              modelo + sep +
              ano + sep +
              matricula + sep +
              data_manutencao + sep +
              descricao + sep +
              valortotal + sep +
              valoriva + sep +
              kms_viatura + sep +
              s_mecanica + sep +
              s_batechapas + sep +
              s_revisao + sep +
              lines + sep +
              s_paga + sep +
              numero + sep +
              data_vencimento + sep +
              metodo_pagamento;
    }

    [WebMethod]
    public static string getLinesData(string id, string orcamento)
    {
        string sql = "", id_linha = "", descricao = "", valor = "", valoriva = "";
        string ret = "", background_color = " background_white ";

        DataSqlServer oDB = new DataSqlServer();


        sql = string.Format(@"  set dateformat dmy
                                DECLARE @id int = {0}
                                DECLARE @id_linha int;

                                SELECT
	                                id_linha,
		                            id_manutencao,
		                            descricao_linha,
		                            valor,
		                            iva
                                FROM {1}(@id_linha, @id)",
                                    id, String.Format("{0}", orcamento == "1" ? "REPORT_ORCAMENTOS_LINES" : "REPORT_MAINTENANCE_LINES"));
        
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
                                                <div class='variaveis' id='div{0}Removed'>0</div>
                                                <div class='col-md-6' id='div{0}Description'>{2}</div>
                                                <div class='col-md-2' id='div{0}Value'>{3}€</div>
                                                <div class='col-md-2' id='div{0}IVA'>{4}%</div>
                                                <div class='col-md-2' id='div{0}RemoveIcon'>
                                                    <img src='../Img/remove_icon.png' style='width: 10%; height: auto; cursor: pointer;' alt='Remover Linha' title='Remover Linha' onclick='removeLine({0});'/>
                                                </div>
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
    public static string getCarsList(string search, string dialogOpen)
    {
        string sql = "", html = "", htmlWithSearch = "";
        string id = "", marca = "", modelo = "", ano = "", matricula = "";

        DataSqlServer oDB = new DataSqlServer();

        html += @"  <input id='carSearchBar' class='form-control' placeholder='Pesquisar...' type='text' style='color: black; width: 75%; float:left;' />
                    <img src='../Img/search_icon.png' style='width: 10%; height: auto; cursor: pointer; margin-left: 5px; float:right;' alt='Pesquisar Viatura' title='Pesquisar Viatura' onclick='getCarsList();'/>
                    <div id='divTableCars'>";

        html += @"<table class='table align-items-center table-flush'>
		                                <thead class='thead-light'>
		                                    <tr>
			                                    <th scope='col' class='pointer th_text'>Viatura</th>
			                                    <th scope='col' class='pointer th_text'>Ano</th>
                                                <th scope='col' class='pointer th_text'>Matrícula</th>
                                            </tr>
		                                </thead>
                                        <tbody>";

        htmlWithSearch += @"<table class='table align-items-center table-flush'>
		                                <thead class='thead-light'>
		                                    <tr>
			                                    <th scope='col' class='pointer th_text'>Viatura</th>
			                                    <th scope='col' class='pointer th_text'>Ano</th>
                                                <th scope='col' class='pointer th_text'>Matrícula</th>
                                            </tr>
		                                </thead>
                                        <tbody>";

        sql = String.Format(@"  declare @id_car int;
                                declare @matricula varchar(20);

                                select 
	                                id,
	                                marca,
                                    modelo,
	                                matricula,
                                    ano
                                from [REPORT_CARS](@id_car, @matricula)
                                where marca like {0} or modelo like {0} or matricula like {0} or ano like {0}
                                order by marca, modelo, matricula", String.Format("'%{0}%'", search));

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    id = oDs.Tables[j].Rows[i]["id"].ToString().Trim();
                    marca = oDs.Tables[j].Rows[i]["marca"].ToString().Trim();
                    modelo = oDs.Tables[j].Rows[i]["modelo"].ToString().Trim();
                    matricula = oDs.Tables[j].Rows[i]["matricula"].ToString().Trim();
                    ano = oDs.Tables[j].Rows[i]["ano"].ToString().Trim();

                    html += @"<tr class='pointer' id='carLine" + i + @"' onclick='selectCarRow(" + id + @", " + i + @")'> 
		                    <td><span>" + marca + " " + modelo + @"</span></td>
		                    <td><span>" + ano + @"</span>
                            <td><span>" + matricula + @"</span>                   
	                      </tr> ";

                    htmlWithSearch += @"<tr class='pointer' id='carLine" + i + @"' onclick='selectCarRow(" + id + @", " + i + @")'> 
		                    <td><span>" + marca + " " + modelo + @"</span></td>
		                    <td><span>" + ano + @"</span>
                            <td><span>" + matricula + @"</span>                   
	                      </tr> ";
                }

                html += "<span class='variaveis' id='countCars'>" + oDs.Tables[j].Rows.Count + "</span>";

                htmlWithSearch += "<span class='variaveis' id='countCars'>" + oDs.Tables[j].Rows.Count + "</span>";
            }
        }
        else
        {
            html += "<tr><td colspan='3'>Não existem viaturas a apresentar.</td></tr> ";
            htmlWithSearch += "<tr><td colspan='3'>Não existem viaturas a apresentar.</td></tr> ";
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

    [WebMethod]
    public static string getCarData(string id, string matricula)
    {
        string sql = "";
        string sep = "<#SEP#>";
        string marca = "", modelo = "", ano = "";

        DataSqlServer oDB = new DataSqlServer();

        sql = String.Format(@"  declare @id_car int = {0};
                                declare @matricula varchar(20) = {1};

                                select 
	                                marca,
                                    modelo,
	                                matricula,
                                    ano
                                from [REPORT_CARS](@id_car, @matricula)", String.IsNullOrEmpty(id) ? "NULL" : id, String.IsNullOrEmpty(matricula) ? "NULL" : String.Format(@"'{0}'", matricula));

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    marca = oDs.Tables[j].Rows[i]["marca"].ToString().Trim();
                    modelo = oDs.Tables[j].Rows[i]["modelo"].ToString().Trim();
                    matricula = oDs.Tables[j].Rows[i]["matricula"].ToString().Trim();
                    ano = oDs.Tables[j].Rows[i]["ano"].ToString().Trim();
                }
            }
        }

        return marca + sep + modelo + sep + matricula + sep + ano;
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