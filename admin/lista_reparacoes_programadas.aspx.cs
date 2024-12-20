using System;
using System.Web.Services;
using System.Data;

public partial class lista_reparacoes_programadas : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        getTablesTitle();
    }

    [WebMethod]
    public static string getReparacoesEsteMes(string admin)
    {
        string sql = "", html = "", headerAdmin = "", tableAdmin = "";
        string cliente = "", telemovel = "", marca = "", modelo = "", matricula = "", id_cliente = "", id_viatura = "";
        DataSqlServer oDB = new DataSqlServer();

        if(admin == "1")
        {
            headerAdmin = "<th scope='col' class='pointer th_text'></th>";
            tableAdmin = @" <td class='text-right'>
                                <div class='dropdown'>
                                    <a class='btn btn-sm btn-icon-only text-light' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
			                            <i class='fas fa-ellipsis-v'></i>
			                        </a>
                                    <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                        <a class='dropdown-item' href='#' onclick='sendEmail([ID_CLIENTE],[ID_VIATURA]);'>Enviar Email</a>
			                        </div>
		                        </div>
		                    </td>";
        }

        html += String.Format(@"  <table class='table align-items-center table-flush'>
		                <thead class='thead-light'>
		                    <tr>
                                <th scope='col' class='th_text'>Cliente</th>
                                <th scope='col' class='th_text'>Telefone</th>  
                                <th scope='col' class='th_text'>Viatura</th>
                                <th scope='col' class='th_text'>Matrícula</th>
                                {0}
		                    </tr>
		                </thead>
                        <tbody>", headerAdmin);


        sql = @"declare @id_cliente int
                declare @id_viatura int
                declare @date date = getdate();

                select
                    id_cliente,
                    cliente,
		            telemovel_cliente,
                    id_viatura,
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
                    id_cliente = oDs.Tables[j].Rows[i]["id_cliente"].ToString().Trim();
                    id_viatura = oDs.Tables[j].Rows[i]["id_viatura"].ToString().Trim();
                    tableAdmin = tableAdmin.Replace("[ID_CLIENTE]", id_cliente).Replace("[ID_VIATURA]", id_viatura);

                    html += String.Format(@"<tr style='cursor:pointer;'> 
		                                        <td><span>{0}</span></td>
                                                <td><span>{1}</span></td>
                                                <td><span>{2}</span></td>
                                                <td><span>{3}</span></td>
                                                {4}
                                            </tr>", cliente, telemovel, String.Format(@"{0} {1}", marca, modelo), matricula, tableAdmin);
                }
            }
        }

        html += "</tbody></table>";

        return html;
    }

    [WebMethod]
    public static string getReparacoesMesSeguinte(string admin)
    {
        string sql = "", html = "", headerAdmin = "", tableAdmin = "";
        string cliente = "", telemovel = "", marca = "", modelo = "", matricula = "", id_cliente = "", id_viatura = "";
        DataSqlServer oDB = new DataSqlServer();

        if (admin == "1")
        {
            headerAdmin = "<th scope='col' class='pointer th_text'></th>";
            tableAdmin = @" <td class='text-right'>
                                <div class='dropdown'>
                                    <a class='btn btn-sm btn-icon-only text-light' href='#' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
			                            <i class='fas fa-ellipsis-v'></i>
			                        </a>
                                    <div class='dropdown-menu dropdown-menu-right dropdown-menu-arrow'>
                                        <a class='dropdown-item' href='#' onclick='sendEmail([ID_CLIENTE],[ID_VIATURA]);'>Enviar Email</a>
			                        </div>
		                        </div>
		                    </td>";
        }

        html += String.Format(@"  <table class='table align-items-center table-flush'>
		                <thead class='thead-light'>
		                    <tr>
                                <th scope='col' class='th_text'>Cliente</th>
                                <th scope='col' class='th_text'>Telefone</th>  
                                <th scope='col' class='th_text'>Viatura</th>
                                <th scope='col' class='th_text'>Matrícula</th>
                                {0}
		                    </tr>
		                </thead>
                        <tbody>", headerAdmin);


        sql = @"declare @id_cliente int
                declare @id_viatura int
                declare @date date = getdate();

                select
                    id_cliente,
                    cliente,
		            telemovel_cliente,
                    id_viatura,
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
                    id_cliente = oDs.Tables[j].Rows[i]["id_cliente"].ToString().Trim();
                    id_viatura = oDs.Tables[j].Rows[i]["id_viatura"].ToString().Trim();
                    tableAdmin = tableAdmin.Replace("[ID_CLIENTE]", id_cliente).Replace("[ID_VIATURA]", id_viatura);

                    html += String.Format(@"<tr style='cursor:pointer;'> 
		                                        <td><span>{0}</span></td>
                                                <td><span>{1}</span></td>
                                                <td><span>{2}</span></td>
                                                <td><span>{3}</span></td>
                                                {4}
                                            </tr>", cliente, telemovel, String.Format(@"{0} {1}", marca, modelo), matricula, tableAdmin);
                }
            }
        }

        html += "</tbody></table>";

        return html;
    }

    private void getTablesTitle()
    {
        string sql = "", titleMes = "", titleMesSeguinte = "";

        DataSqlServer oDB = new DataSqlServer();


        sql = @"SET LANGUAGE Portuguese
                declare @mes date = getdate();
                declare @mesSeguinte date = dateadd(month, 1, @mes)
				declare @currentMonth varchar(max) = datename(month, @mes);
				declare @nextMonth varchar(max) = datename(month, @mesSeguinte);
                declare @mesStr varchar(max) = (select concat(upper(left(@currentMonth, 1)), lower(substring(@currentMonth, 2, len(@currentMonth)-1))));
                declare @mesSeguinteStr varchar(max) = (select concat(upper(left(@nextMonth, 1)), lower(substring(@nextMonth, 2, len(@nextMonth)-1))));

                SELECT CONCAT('Reparações Programadas ', @mesStr) AS mes, CONCAT('Reparações Programadas ', @mesSeguinteStr) as mesSeguinte";


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