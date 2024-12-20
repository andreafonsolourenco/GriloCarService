using System;
using System.Web.Services;
using System.Data;

public partial class login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string entra(string u, string p)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "", retMessage = "Dados de autenticação inválidos.";

        sql = string.Format(@"  DECLARE @u varchar(150) = '{0}';
                                DECLARE @p varchar(60) = '{1}';
                                DECLARE @ret int;
                                DECLARE @retMsg varchar(max);

                                EXECUTE login @u, @p, @ret OUTPUT, @retMsg OUTPUT
                                SELECT @ret ret, @retMsg retMsg", u, p);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        ret = oDB.validaDataSet(oDs) ? oDs.Tables[0].Rows[0]["ret"].ToString().Trim() : "-999";
        retMessage = oDB.validaDataSet(oDs) ? oDs.Tables[0].Rows[0]["retMsg"].ToString().Trim() : "Erro ao efetuar login!";

        return ret + "<#SEP#>" + retMessage;
    }

    [WebMethod]
    public static string trataExpiracao(string i)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "-1", retMessage = "Sessão expirada";

        sql = string.Format(@"  DECLARE @u varchar(150);
                                DECLARE @p varchar(60);
                                DECLARE @id int = {0};
                                DECLARE @ativo bit = 1;
                                DECLARE @id_tipo int;
                                DECLARE @sessaomax int = (select sessaomaxmin from report_configs());
                                SELECT 
	                                CASE WHEN DATEDIFF(mi, ut.lastlogin, getdate()) > @sessaomax then 0 else 1 end ret
                                FROM report_users(@id, @u, @p, @ativo, @id_tipo) ut ", i);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["ret"].ToString().Trim();
            retMessage = "Sessão válida e ativa";
        }

        return ret + "<#SEP#>" + retMessage;
    }

    [WebMethod]
    public static string getUname(string i)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "", ret = "";

        sql = string.Format(@"  DECLARE @u varchar(150);
                                DECLARE @p varchar(60);
                                DECLARE @id int = {0};
                                DECLARE @ativo bit = 1;
                                DECLARE @id_tipo int;

                                SELECT TOP 1 nome FROM report_users(@id, @u, @p, @ativo, @id_tipo) ", i);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        if (oDB.validaDataSet(oDs))
        {
            ret = oDs.Tables[0].Rows[0]["nome"].ToString().Trim();
        }

        return ret;
    }


    [WebMethod]
    public static string getTipoUser(string i)
    {
        DataSqlServer oDB = new DataSqlServer();

        string sql = "";

        sql = string.Format(@"  DECLARE @id int = {0};
                                DECLARE @u varchar(150);
                                DECLARE @p varchar(60);
                                DECLARE @ativo bit;
                                DECLARE @id_tipo int;

                                SELECT tipo FROM CASHDRO_REPORT_UTILIZADORES(@id, @u, @p, @ativo, @id_tipo)", i);

        DataSet oDs = oDB.GetDataSet(sql, "").oData;

        return oDB.validaDataSet(oDs) ? oDs.Tables[0].Rows[0]["tipo"].ToString().Trim() : "";
    }

}