using System;
using System.Web.Services;
using System.Data;

public partial class dashboard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        getTablesTitle();
    }

    [WebMethod]
    public static string getReparacoesEsteMes(string idCliente)
    {
        string sql = "", html = "";
        string cliente = "", telemovel = "", marca = "", modelo = "", matricula = "";
        DataSqlServer oDB = new DataSqlServer();

        html += @"  <table class='table align-items-center table-flush'>
		                <thead class='thead-light'>
		                    <tr>
                                <th scope='col'>Cliente</th>
                                <th scope='col'>Telefone</th>  
                                <th scope='col'>Viatura</th>
                                <th scope='col'>Matrícula</th>
		                    </tr>
		                </thead>
                        <tbody>";


        sql = @"declare @id_cliente int
                declare @id_viatura int
                declare @date date = getdate();

                select
                    cliente,
		            telemovel_cliente,
		            marca,
		            modelo,
		            matricula
                from REPORT_MANUTENCOES_PROGRAMADAS_MES_MESSEGUINTE(@id_cliente, @id_viatura, @date)
                where mes = 0";

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    cliente = oDs.Tables[j].Rows[i]["cliente"].ToString().Trim();
                    telemovel = oDs.Tables[j].Rows[i]["telemovel_cliente"].ToString().Trim();
                    marca = oDs.Tables[j].Rows[i]["marca"].ToString().Trim();
                    modelo = oDs.Tables[j].Rows[i]["modelo"].ToString().Trim();
                    matricula = oDs.Tables[j].Rows[i]["matricula"].ToString().Trim();

                    html += @"<tr style='cursor:pointer;'> 
		                    <td>" + cliente + @"                    
		                    </td>
		                    <td>
		                      <span>" + telemovel + @"</span>
		                    </td>
		                    <td>
		                      <span>" + marca + " " + modelo + @"</span>
		                    </td>
                            <td>
		                      <span>" + matricula + @"</span>
		                    </td>
	                      </tr> ";
                }
            }
        }

        html += "</tbody></table>";

        return html;
    }

    [WebMethod]
    public static string getReparacoesMesSeguinte(string idCliente)
    {
        string sql = "", html = "";
        string cliente = "", telemovel = "", marca = "", modelo = "", matricula = "";
        DataSqlServer oDB = new DataSqlServer();

        html += @"  <table class='table align-items-center table-flush'>
		                <thead class='thead-light'>
		                    <tr>
                                <th scope='col'>Cliente</th>
                                <th scope='col'>Telefone</th>  
                                <th scope='col'>Viatura</th>
                                <th scope='col'>Matrícula</th>
		                    </tr>
		                </thead>
                        <tbody>";


        sql = @"declare @id_cliente int
                declare @id_viatura int
                declare @date date = getdate();

                select
                    cliente,
		            telemovel_cliente,
		            marca,
		            modelo,
		            matricula
                from REPORT_MANUTENCOES_PROGRAMADAS_MES_MESSEGUINTE(@id_cliente, @id_viatura, @date)
                where mes = 1";

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int j = 0; j < oDs.Tables.Count; j++)
            {
                for (int i = 0; i < oDs.Tables[j].Rows.Count; i++)
                {
                    cliente = oDs.Tables[j].Rows[i]["cliente"].ToString().Trim();
                    telemovel = oDs.Tables[j].Rows[i]["telemovel_cliente"].ToString().Trim();
                    marca = oDs.Tables[j].Rows[i]["marca"].ToString().Trim();
                    modelo = oDs.Tables[j].Rows[i]["modelo"].ToString().Trim();
                    matricula = oDs.Tables[j].Rows[i]["matricula"].ToString().Trim();

                    html += @"<tr style='cursor:pointer;'> 
		                    <td>" + cliente + @"                    
		                    </td>
		                    <td>
		                      <span>" + telemovel + @"</span>
		                    </td>
		                    <td>
		                      <span>" + marca + " " + modelo + @"</span>
		                    </td>
                            <td>
		                      <span>" + matricula + @"</span>
		                    </td>
	                      </tr> ";
                }
            }
        }

        html += "</tbody></table>";

        return html;
    }

    [WebMethod]
    public static string getGrafico(string idCliente)
    {
        string sql = "", ret = "", hoje = "", mecanica_mes = "", batechapas_mes = "";
        DataSqlServer oDB = new DataSqlServer();


        sql = @"select
                    hoje,
		            mecanica_mes,
		            batechapas_mes
                from REPORT_GRAPHIC_DATA()";

        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            hoje = oDs.Tables[0].Rows[0]["hoje"].ToString().Trim();
            mecanica_mes = oDs.Tables[0].Rows[0]["mecanica_mes"].ToString().Trim();
            batechapas_mes = oDs.Tables[0].Rows[0]["batechapas_mes"].ToString().Trim();
        }

        ret = hoje + "<#SEP#>" +
                mecanica_mes + "<#SEP#>" +
                batechapas_mes + "<#SEP#>";

        return ret;
    }

    private void getTablesTitle()
    {
        string sql = "", titleMes = "", titleMesSeguinte = "";

        DataSqlServer oDB = new DataSqlServer();


        sql = @"SET LANGUAGE Portuguese
                declare @mes date = getdate();
                declare @mesSeguinte date = dateadd(month, 1, @mes)

                SELECT UPPER('Reparações Programadas ' + DATENAME(MONTH, @mes)) AS mes, UPPER('Reparações Programadas ' + DATENAME(MONTH, @mesSeguinte)) as mesSeguinte";


        DataSet oDs = oDB.GetDataSet(sql, "").oData;
        if (oDB.validaDataSet(oDs))
        {
            for (int i = 0; i < oDs.Tables[0].Rows.Count; i++)
            {
                titleMes = oDs.Tables[0].Rows[i]["mes"].ToString().Trim();
                titleMesSeguinte = oDs.Tables[0].Rows[i]["mesSeguinte"].ToString().Trim();
            }
        }
        else
        {
            titleMes = "Reparações Programadas Este Mês";
            titleMesSeguinte = "Reparações Programadas Mês Seguinte";
        }

        titleTableMes.InnerHtml = titleMes;
        titleTableMesSeguinte.InnerHtml = titleMesSeguinte;
    }
}