using Newtonsoft.Json.Linq;
using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using static DataSqlServer;

/// <summary>
/// Summary description for filaBackground
/// </summary>
public class filaBackground
{
    private static Thread _StatusWorker;

    public filaBackground()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    //public static void StatusWorker_FilaStatusMaquinasStart()
    //{
    //    DataSqlServer oSql = new DataSqlServer();
    //    DataSqlServer oSqlMaquinas = new DataSqlServer();
    //    DataSqlServer oSqlUpdate = new DataSqlServer();
    //    var sql = "";
    //    var sqlMaquinas = "";
    //    var sqlUpdate = "";
    //    int _StatusWorkerSleeptime = 5000;
    //    bool _StatusWorkerAtiva = false;
    //    string filaStatusMaquinas = "FilaStatusMaquinas";
    //    string id = "", user = "", password = "", url = "", serial = "", maquina = "";
    //    Boolean email_alerta_enviado = false;

    //    _StatusWorker = new Thread(() =>
    //    {
    //        do
    //        {
    //            var a = 1;

    //            //Obtemos informação da fila
    //            sql = String.Format(@"  DECLARE @fila varchar(60) = '{0}';
    //                                    DECLARE @ret int;

    //                                    EXEC cashdro_processa_fila_background @fila, @ret output", filaStatusMaquinas);

    //            DataSet oDs = oSql.GetDataSet(sql, "").oData;

    //            if (oSql.validaDataSet(oDs))
    //            {
    //                _StatusWorkerSleeptime = Convert.ToInt32(oDs.Tables[0].Rows[0]["worksleep"]);
    //                _StatusWorkerAtiva = Convert.ToBoolean(oDs.Tables[0].Rows[0]["ativa"]);

    //                if (!_StatusWorkerAtiva) _StatusWorkerSleeptime = 0;
    //            }

    //            sqlMaquinas = @"    declare @id_maquina int;
    //                                declare @ativo bit = 1;
    //                                SELECT
	   //                                 id,
	   //                                 serialnumber,
	   //                                 localizacao, 
		  //                              [url],
    //                                    email_alerta_enviado,
    //                                    [password],
    //                                    username
    //                                FROM CASHDRO_REPORT_MAQUINAS(@id_maquina)
    //                                WHERE ATIVO = @ativo";

    //            DataSet oDsMaquinas = oSqlMaquinas.GetDataSet(sqlMaquinas, "").oData;

    //            var listaMaquinas = new List<string>();

    //            if (oSqlMaquinas.validaDataSet(oDsMaquinas))
    //            {
    //                foreach (DataRow estaLinha in oDsMaquinas.Tables[0].Rows)
    //                    listaMaquinas.Add(estaLinha["id"].ToString());
    //            }

    //            string lista_maquinas = "";
    //            var tot = listaMaquinas.Count();
    //            var totalMaquinas = tot;

    //            var totok = 0;
    //            var bloco = tot;


    //            while (totok < tot)
    //            {
    //                lista_maquinas = "";
    //                var listaTasks = new List<Task>();
    //                listaMaquinas.Skip(totok)
    //                             .Take(bloco)
    //                             .ToList()
    //                             .ForEach(t =>
    //                             {
    //                                 var novaTaska = Task.Factory.StartNew(() => MethodThreadOnOff(t));
    //                                 listaTasks.Add(novaTaska);
    //                             });
    //                Task.WaitAll(listaTasks.ToArray());
    //                totok += bloco;
    //            }


    //            //Dorme o tempo definido na configuração (Em segundos)
    //            Thread.Sleep(_StatusWorkerSleeptime);

    //        } while (_StatusWorkerSleeptime > 0);

    //    });

    //    _StatusWorker.IsBackground = true;
    //    _StatusWorker.Name = filaStatusMaquinas;
    //    _StatusWorker.Start();
    //}



    //static void MethodThreadOnOff(object data)
    //{
    //    DataSqlServer oSQL = new DataSqlServer();

    //    string id = "", user = "", password = "", url = "", serial = "", maquina = "";
    //    Boolean email_alerta_enviado = false;

    //    string sqlMaquinas = @"    declare @id_maquina int;
    //                                declare @ativo bit = 1;
    //                                SELECT
	   //                                 id,
	   //                                 serialnumber,
	   //                                 localizacao, 
		  //                              [url],
    //                                    email_alerta_enviado,
    //                                    [password],
    //                                    username
    //                                FROM CASHDRO_REPORT_MAQUINAS(@id_maquina)
    //                                WHERE id = " + data;

    //    DataSet oDsMaquinas = oSQL.GetDataSet(sqlMaquinas, "").oData;

    //    // Vai obter os dados das máquinas
    //    if (oSQL.validaDataSet(oDsMaquinas))
    //    {
    //        for (int i = 0; i < oDsMaquinas.Tables[0].Rows.Count; i++)
    //        {
    //            id = oDsMaquinas.Tables[0].Rows[i]["id"].ToString().Trim();
    //            user = oDsMaquinas.Tables[0].Rows[i]["username"].ToString().Trim();
    //            password = oDsMaquinas.Tables[0].Rows[i]["password"].ToString().Trim();
    //            url = oDsMaquinas.Tables[0].Rows[i]["url"].ToString().Trim();
    //            serial = oDsMaquinas.Tables[0].Rows[i]["serialnumber"].ToString().Trim();
    //            maquina = oDsMaquinas.Tables[0].Rows[i]["localizacao"].ToString().Trim();
    //            email_alerta_enviado = Convert.ToBoolean(oDsMaquinas.Tables[0].Rows[i]["email_alerta_enviado"]);

    //            // As que estao ligadas ou desligadas
    //            Boolean retOnOff = testaMaquinasOnOff(id, user, password, url);

    //            if (retOnOff)
    //            {
    //                // As que estao com erro
    //                Boolean retErro = testaMaquinasComErro(url, maquina, serial, id);
    //            }                
    //        }
    //    }
    //}


    //public static void StatusWorker_FilaMovimentosMaquinaStart()
    //{
    //    DataSqlServer oSql = new DataSqlServer();
    //    var sql = "";
    //    int _StatusWorkerSleeptime = 5000;
    //    bool _StatusWorkerAtiva = false;

    //    _StatusWorker = new Thread(() =>
    //    {
    //        do
    //        {
    //            var a = 1;

    //            //Obtemos informação da fila
    //            sql = String.Format(@"  DECLARE @fila varchar(60) = '{0}';
    //                                    DECLARE @ret int;

    //                                    EXEC cashdro_processa_fila_background @fila, @ret output", "FilaMovimentosMaquina");

    //            DataSet oDs = oSql.GetDataSet(sql, "").oData;

    //            if (oSql.validaDataSet(oDs))
    //            {
    //                _StatusWorkerSleeptime = Convert.ToInt32(oDs.Tables[0].Rows[0]["worksleep"]);
    //                _StatusWorkerAtiva = Convert.ToBoolean(oDs.Tables[0].Rows[0]["ativa"]);

    //                if (!_StatusWorkerAtiva) _StatusWorkerSleeptime = 0;
    //            }

    //            // Vai obter os dados das máquinas

    //            // As que estao ligadas ou desligadas
    //            var ret = filaMovimentosMaquinasTrata();


    //            //Dorme o tempo definido na configuração (Em segundos)
    //            Thread.Sleep(_StatusWorkerSleeptime);

    //        } while (_StatusWorkerSleeptime > 0);

    //    });

    //    _StatusWorker.IsBackground = true;
    //    _StatusWorker.Name = "FilaMovimentosMaquina";
    //    _StatusWorker.Start();
    //}

    //public static void StatusWorker_FilaEstadoFundoMaquinaStart()
    //{
    //    DataSqlServer oSql = new DataSqlServer();
    //    var sql = "";
    //    int _StatusWorkerSleeptime = 5000;
    //    bool _StatusWorkerAtiva = false;

    //    _StatusWorker = new Thread(() =>
    //    {
    //        do
    //        {
    //            var a = 1;

    //            //Obtemos informação da fila
    //            sql = String.Format(@"  DECLARE @fila varchar(60) = '{0}';
    //                                    DECLARE @ret int;

    //                                    EXEC cashdro_processa_fila_background @fila, @ret output", "FilaEstadoFundoMaquinas");

    //            DataSet oDs = oSql.GetDataSet(sql, "").oData;

    //            if (oSql.validaDataSet(oDs))
    //            {
    //                _StatusWorkerSleeptime = Convert.ToInt32(oDs.Tables[0].Rows[0]["worksleep"]);
    //                _StatusWorkerAtiva = Convert.ToBoolean(oDs.Tables[0].Rows[0]["ativa"]);

    //                if (!_StatusWorkerAtiva) _StatusWorkerSleeptime = 0;
    //            }

    //            //Obtem o estado de fundo da maquina
    //            var ret = FilaEstadoFundoMaquinasTrata();


    //            //Dorme o tempo definido na configuração (Em segundos)
    //            Thread.Sleep(_StatusWorkerSleeptime);

    //        } while (_StatusWorkerSleeptime > 0);

    //    });

    //    _StatusWorker.IsBackground = true;
    //    _StatusWorker.Name = "FilaEstadoFundoMaquinas";
    //    _StatusWorker.Start();
    //}

    //public static string FilaEstadoFundoMaquinasTrata()
    //{
    //    DataSqlServer oDB = new DataSqlServer();
    //    string sql = "", id_maquina = "", url = "", username = "", password = "";

    //    // obtemos as maquinas
    //    sql = @"    set dateformat ymd
    //                declare @id_maquina int;

    //                SELECT
    //                    id,
    //                    [url],
    //                    [password],
    //                    username                        
    //                FROM CASHDRO_FILA_ESTADOFUNDO_MAQUINAS_TRATA()";

    //    DataSet oDs = oDB.GetDataSet(sql, "").oData;

    //    if (oDB.validaDataSet(oDs))
    //    {
    //        for (int i = 0; i < oDs.Tables[0].Rows.Count; i++)
    //        {
    //            id_maquina = oDs.Tables[0].Rows[i]["id"].ToString().Trim();
    //            url = oDs.Tables[0].Rows[i]["url"].ToString().Trim();
    //            username = oDs.Tables[0].Rows[i]["username"].ToString().Trim();
    //            password = oDs.Tables[0].Rows[i]["password"].ToString().Trim();

    //            if (testaMaquinasOnOff(id_maquina, username, password, url))
    //            {
    //                FilaEstadoFundoMaquinas(id_maquina);
    //            }
    //        }
    //    }

    //    return "OK";
    //}

    //private static void FilaEstadoFundoMaquinas(string id_maquina)
    //{
    //    String currentHour = DateTime.Now.ToString("HH:mm");
    //    DataSqlServer oDB = new DataSqlServer();
    //    string sql = string.Format(@"   DECLARE @id INT = {0};
    //                                    DECLARE @horaenvioemail varchar(5) = '{1}'
    //                                    SELECT url, username, password
    //                                    FROM CASHDRO_REPORT_MAQUINAS(@id) mq
    //                                    where horaenvioemail = @horaenvioemail", id_maquina, currentHour);
    //    DataSet oDs = oDB.GetDataSet(sql, "").oData;

    //    if (oDB.validaDataSet(oDs))
    //    {
    //        string urlMaquina = oDs.Tables[0].Rows[0]["url"].ToString().Trim();
    //        string user = oDs.Tables[0].Rows[0]["username"].ToString().Trim();
    //        string pwd = oDs.Tables[0].Rows[0]["password"].ToString().Trim();

    //        sql = " DELETE FROM CASHDRO_DATA_FALTASFUNDO WHERE id_maquina=" + id_maquina;
    //        oDB.RunDataCommand(sql, "");

    //        var url = urlMaquina + "/Cashdro3WS/index.php?currencyId=EUR&includeImages=0&includeLevels=1&name=" + user + "&operation=getPiecesCurrency&password=" + pwd;
    //        string jsonOut = getRetornoURL(url);

    //        double moeda = 0, totalFundo = 0, totalRecirculador = 0, totalEmFalta = 0, totalCassete = 0;
    //        int nivelfundo = 0, nivelRecirculador = 0, nivelEmFalta = 0, nivelCassete = 0;

    //        string pMoeda = "", pNivelFundo = "", pTotalFundo = "", pNivelRecirculador = "", pTotalRecirculador = "", pNivelFalta = "", pTotalFalta = "";

    //        JToken contourManifest = JObject.Parse(jsonOut);
    //        JToken data = contourManifest.SelectToken("data");

    //        for (int i = 0; i < data.Count(); i++)
    //        {
    //            JToken tk_CurrencyId = data[i].SelectToken("CurrencyId");
    //            JToken tk_Value = data[i].SelectToken("Value");
    //            JToken tk_Type = data[i].SelectToken("Type");
    //            JToken tk_Destination = data[i].SelectToken("Destination");
    //            JToken tk_MinLevel = data[i].SelectToken("MinLevel");
    //            JToken tk_MaxLevel = data[i].SelectToken("MaxLevel");
    //            JToken tk_MaxLevelTemp = data[i].SelectToken("MaxLevelTemp");
    //            JToken tk_DepositLevel = data[i].SelectToken("DepositLevel");
    //            JToken tk_DepositLevelTemp = data[i].SelectToken("DepositLevelTemp");
    //            JToken tk_MaxPiecesExchange = data[i].SelectToken("MaxPiecesExchange");
    //            JToken tk_MaxPiecesChange = data[i].SelectToken("MaxPiecesChange");
    //            JToken tk_MaxPiecesCancel = data[i].SelectToken("MaxPiecesCancel");
    //            JToken tk_IsChargeable = data[i].SelectToken("IsChargeable");
    //            JToken tk_State = data[i].SelectToken("State");
    //            JToken tk_Image = data[i].SelectToken("Image");
    //            JToken tk_LevelRecycler = data[i].SelectToken("LevelRecycler");
    //            JToken tk_LevelCasete = data[i].SelectToken("LevelCasete");

    //            // Variaveis para cálculos
    //            moeda = Convert.ToDouble(tk_Value.ToString().Replace("\"", "")) / 100;
    //            nivelfundo = Convert.ToInt32(tk_DepositLevel.ToString().Replace("\"", ""));
    //            totalFundo = nivelfundo * moeda;
    //            nivelRecirculador = Convert.ToInt32(tk_LevelRecycler.ToString().Replace("\"", ""));
    //            totalRecirculador = nivelRecirculador * moeda;
    //            nivelEmFalta = nivelfundo - nivelRecirculador;
    //            if (nivelEmFalta < 0) nivelEmFalta = 0;
    //            totalEmFalta = nivelEmFalta * moeda;


    //            nivelCassete = Convert.ToInt32(tk_LevelCasete.ToString().Replace("\"", ""));
    //            totalCassete = nivelCassete * moeda;


    //            sql = string.Format(@" INSERT INTO CASHDRO_DATA_FALTASFUNDO (id_maquina, moeda, nivelfundo, nivelrecirculador,nivelfalta,totalfundo,totalrecirculador,totalfalta,nivelcassete,totalcassete)
    //                 SELECT {0},{1},{2},{3},{4},{5},{6},{7},{8},{9} ", id_maquina,
    //                                                             moeda.ToString().Replace(",", "."),
    //                                                             nivelfundo.ToString().Replace(",", "."),
    //                                                             nivelRecirculador.ToString().Replace(",", "."),
    //                                                             nivelEmFalta.ToString().Replace(",", "."),
    //                                                             totalFundo.ToString().Replace(",", "."),
    //                                                             totalRecirculador.ToString().Replace(",", "."),
    //                                                             totalEmFalta.ToString().Replace(",", "."),
    //                                                             nivelCassete.ToString().Replace(",", "."),
    //                                                             totalCassete.ToString().Replace(",", ".")
    //                                                             );
    //            oDB.RunDataCommand(sql, "");



    //            // Marca moeda, ou nota
    //            sql = string.Format(@" DECLARE @id_maquina INT = {0}
    //                                   UPDATE CASHDRO_DATA_FALTASFUNDO SET tipocoin=0 WHERE moeda<5 AND id_maquina=@id_maquina
    //                                   UPDATE CASHDRO_DATA_FALTASFUNDO SET tipocoin=1 WHERE moeda>=5 AND id_maquina=@id_maquina ", id_maquina);

    //            oDB.RunDataCommand(sql, "");
    //        }

    //        // Envia email aos clientes cujas maquinas estao com faltas
    //        FilaEstadoFundoMaquinas_EnvioEmail();
    //    }
    //}

    //private static void FilaEstadoFundoMaquinas_EnvioEmail()
    //{
    //    // De seguida envia o email a cada cliente informando quais as maquinas dele que estao sem fundo
    //    DataSqlServer oDB = new DataSqlServer();
    //    string sql="", email = "", cliente = "", localizacao = "", serial = "", tipo = "", descmoeda = "", nivelfalta = "", totalfalta = "", id_cliente = "", intro = "", subject = "", body = "", destinatarios = "", maq_ant = "", tblFaltas = "";
    //    sql = String.Format(@"  DECLARE @id_cliente int;
    //                            SELECT distinct id_cliente, cliente, email
    //                            FROM CASHDRO_REPORT_MAQUINAS_FALTAS_FUNDO(@id_cliente)");
    //    DataSet oDs = oDB.GetDataSet(sql, "").oData;
    //    if (oDB.validaDataSet(oDs))
    //    {
    //        for (int k = 0; k < oDs.Tables[0].Rows.Count; k++)
    //        {
    //            id_cliente = oDs.Tables[0].Rows[k]["id_cliente"].ToString();
    //            email = oDs.Tables[0].Rows[k]["email"].ToString();
    //            cliente = oDs.Tables[0].Rows[k]["cliente"].ToString();

    //            destinatarios = email;
    //            intro = "Nível de faltas a repor";
    //            subject = cliente + " - Nível de faltas a repor";
    //            body = "Informa-se para efeitos de regularização o nível de faltas a repor nas máquinas abaixo:<br /><br />";
    //            maq_ant = "";
    //            tblFaltas = "";

    //            sql = String.Format(@"  DECLARE @id_cliente int = {0};
    //                                    SELECT id_maquina, serialnumber, localizacao, tipo, moeda, nivelfalta, totalfalta
    //                                    FROM CASHDRO_REPORT_MAQUINAS_FALTAS_FUNDO(@id_cliente)
    //                                    ORDER BY id_cliente, id_maquina", id_cliente);

    //            DataSet oDsInfo = oDB.GetDataSet(sql, "").oData;
    //            if (oDB.validaDataSet(oDsInfo))
    //            {
    //                tblFaltas = "<table style='width:98%; text-align:center'>";
    //                tblFaltas += "<tr>";
    //                tblFaltas += "  <td>Tipo</td>";
    //                tblFaltas += "  <td>Moeda</td>";
    //                tblFaltas += "  <td>Nível em falta</td>";
    //                tblFaltas += "  <td>Valor em falta</td>";
    //                tblFaltas += "</tr>";

    //                for (int i = 0; i < oDsInfo.Tables[0].Rows.Count; i++)
    //                {
    //                    if (maq_ant != "" && maq_ant != oDsInfo.Tables[0].Rows[0]["id_maquina"].ToString())
    //                    {
    //                        tblFaltas += "</table>";

    //                        body += "Dados da máquina: <br />";
    //                        body += localizacao + " [" + serial + "]<br />";

    //                        body += tblFaltas;
    //                        body += "<br />";
    //                    }


    //                    serial = oDsInfo.Tables[0].Rows[i]["serialnumber"].ToString();
    //                    localizacao = oDsInfo.Tables[0].Rows[i]["localizacao"].ToString();
    //                    tipo = oDsInfo.Tables[0].Rows[i]["tipo"].ToString();
    //                    descmoeda = oDsInfo.Tables[0].Rows[i]["moeda"].ToString().Replace('.', ',') + " €";
    //                    nivelfalta = oDsInfo.Tables[0].Rows[i]["nivelfalta"].ToString();
    //                    totalfalta = oDsInfo.Tables[0].Rows[i]["totalfalta"].ToString().Replace('.', ',') + " €";


    //                    tblFaltas += "<tr>";
    //                    tblFaltas += "  <td>" + tipo + "</td>";
    //                    tblFaltas += "  <td>" + descmoeda + "</td>";
    //                    tblFaltas += "  <td>" + nivelfalta + "</td>";
    //                    tblFaltas += "  <td>" + totalfalta + "</td>";
    //                    tblFaltas += "</tr>";


    //                    maq_ant = oDsInfo.Tables[0].Rows[i]["id_maquina"].ToString();

    //                    if (oDsInfo.Tables[0].Rows.Count - 1 == i)
    //                    {
    //                        tblFaltas += "</table>";

    //                        body += "Dados da máquina: <br />";
    //                        body += localizacao + " [" + serial + "]<br />";

    //                        body += tblFaltas;
    //                        body += "<br />";

    //                        // Envia o email ao cliente
    //                        sendEmail(subject, body, intro, destinatarios);
    //                    }
    //                }
    //            }
    //        }
    //    }
    //}

    //public static void StatusWorker_FilaEnvioEmailManutencaoStart()
    //{
    //    DataSqlServer oSql = new DataSqlServer();
    //    var sql = "";
    //    int _StatusWorkerSleeptime = 5000;
    //    bool _StatusWorkerAtiva = false;

    //    _StatusWorker = new Thread(() =>
    //    {
    //        do
    //        {
    //            var a = 1;

    //            //Obtemos informação da fila
    //            sql = String.Format(@"  DECLARE @fila varchar(60) = '{0}';
    //                                    DECLARE @ret int;

    //                                    EXEC cashdro_processa_fila_background @fila, @ret output", "FilaEnvioEmailManutencao");

    //            DataSet oDs = oSql.GetDataSet(sql, "").oData;

    //            if (oSql.validaDataSet(oDs))
    //            {
    //                _StatusWorkerSleeptime = Convert.ToInt32(oDs.Tables[0].Rows[0]["worksleep"]);
    //                _StatusWorkerAtiva = Convert.ToBoolean(oDs.Tables[0].Rows[0]["ativa"]);

    //                if (!_StatusWorkerAtiva) _StatusWorkerSleeptime = 0;
    //            }

    //            //Obtem o estado de fundo da maquina
    //            var ret = FilaManutencao_EnvioEmail();

    //            //Dorme o tempo definido na configuração (Em segundos)
    //            Thread.Sleep(_StatusWorkerSleeptime);

    //        } while (_StatusWorkerSleeptime > 0);

    //    });

    //    _StatusWorker.IsBackground = true;
    //    _StatusWorker.Name = "FilaEnvioEmailManutencao";
    //    _StatusWorker.Start();
    //}

    //private static Boolean FilaManutencao_EnvioEmail()
    //{
    //    try
    //    {
    //        // De seguida envia o email a cada cliente informando quais as maquinas dele que estao sem fundo
    //        DataSqlServer oDB = new DataSqlServer();
    //        string sql = "", email = "", cliente = "", localizacao = "", serial = "", prox_interv = "", intro = "", subject = "", body = "";

    //        sql = String.Format(@"  SET dateformat dmy;
    //                            DECLARE @id_cliente int;
    //                            DECLARE @id_maquina int;
    //                            DECLARE @emails_alerta varchar(max) = (select emails_alerta from cashdro_report_configs())
    //                            SELECT cliente, serialnumber, localizacao, convert(varchar, data_proxima_manutencao, 103) as data_proxima_manutencao, @emails_alerta as emails
    //                            FROM CASHDRO_REPORT_MAQUINAS_MANUTENCAO(@id_cliente, @id_maquina)
    //                            WHERE DATEADD(dd, 0, DATEDIFF(dd, 0, DATEADD(ww, 2, getdate()))) = data_proxima_manutencao");

    //        DataSet oDs = oDB.GetDataSet(sql, "").oData;

    //        if (oDB.validaDataSet(oDs))
    //        {
    //            intro = "Manutenções";
    //            subject = "Manutenções dentro de 2 semanas";
    //            body = "Informa-se que será necessária manutenção dentro de 2 semanas ([DIA]) nas seguintes máquinas:<br /><br />";
    //            body += "<table style='width:98%; text-align:center'>";
    //            body += "<tr>";
    //            body += "  <td>Cliente</td>";
    //            body += "  <td>Máquina</td>";
    //            body += "</tr>";

    //            for (int k = 0; k < oDs.Tables[0].Rows.Count; k++)
    //            {
    //                serial = oDs.Tables[0].Rows[k]["serialnumber"].ToString();
    //                email = oDs.Tables[0].Rows[k]["emails"].ToString();
    //                cliente = oDs.Tables[0].Rows[k]["cliente"].ToString();
    //                localizacao = oDs.Tables[0].Rows[k]["localizacao"].ToString();
    //                prox_interv = oDs.Tables[0].Rows[k]["data_proxima_manutencao"].ToString();
    //                body = body.Replace("[DIA]", prox_interv);

    //                body += "<tr>";
    //                body += "  <td>" + cliente + "</td>";
    //                body += "  <td>" + localizacao + " [" + serial + "]</td>";
    //                body += "</tr>";
    //            }

    //            body += "</table>";

    //            // Envia o email ao cliente
    //            sendEmail(subject, body, intro, email);
    //        }

    //        return true;
    //    }
    //    catch(Exception e)
    //    {
    //        return false;
    //    }
    //}

    //public static void StatusWorker_FilaEnvioEmailsAlteracaoSerialsMaquinasStart()
    //{
    //    DataSqlServer oSql = new DataSqlServer();
    //    var sql = "";
    //    int _StatusWorkerSleeptime = 5000;
    //    bool _StatusWorkerAtiva = false;

    //    _StatusWorker = new Thread(() =>
    //    {
    //        do
    //        {
    //            var a = 1;

    //            //Obtemos informação da fila
    //            sql = String.Format(@"  DECLARE @fila varchar(60) = '{0}';
    //                                    DECLARE @ret int;

    //                                    EXEC cashdro_processa_fila_background @fila, @ret output", "FilaEnvioEmailAlteracaoSerialsMaquinas");

    //            DataSet oDs = oSql.GetDataSet(sql, "").oData;

    //            if (oSql.validaDataSet(oDs))
    //            {
    //                _StatusWorkerSleeptime = Convert.ToInt32(oDs.Tables[0].Rows[0]["worksleep"]);
    //                _StatusWorkerAtiva = Convert.ToBoolean(oDs.Tables[0].Rows[0]["ativa"]);

    //                if (!_StatusWorkerAtiva) _StatusWorkerSleeptime = 0;
    //            }

    //            //Envia os emails de alterações de serials nas máquinas
    //            var ret = FilaManutencao_EnvioEmailSerials();

    //            //Dorme o tempo definido na configuração (Em segundos)
    //            Thread.Sleep(_StatusWorkerSleeptime);

    //        } while (_StatusWorkerSleeptime > 0);

    //    });

    //    _StatusWorker.IsBackground = true;
    //    _StatusWorker.Name = "FilaEnvioEmailAlteracaoSerialsMaquinas";
    //    _StatusWorker.Start();
    //}

    //private static Boolean FilaManutencao_EnvioEmailSerials()
    //{
    //    try
    //    {
    //        // De seguida envia o email a cada cliente informando quais as maquinas dele que estao sem fundo
    //        DataSqlServer oDB = new DataSqlServer();
    //        string sql = "", email = "", cliente = "", maquina = "", alteracao = "", serial_antigo = "", serial_novo = "", data_ocorrencia = "", hora_ocorrencia = "", intro = "", subject = "", body = "";

    //        sql = String.Format(@"  SET dateformat dmy;
    //                                SELECT
    //                                    intro,
		  //                              subject,
		  //                              cliente,
		  //                              maquina,
		  //                              alteracao,
		  //                              serial_antigo,
		  //                              serial_novo,
		  //                              data_ocorrencia,
		  //                              hora_ocorrencia,
		  //                              emails_alerta
    //                                FROM CASHDRO_REPORT_ALTERACOES_SERIALS_MAQUINAS()");

    //        DataSet oDs = oDB.GetDataSet(sql, "").oData;

    //        if (oDB.validaDataSet(oDs))
    //        {
    //            for (int k = 0; k < oDs.Tables[0].Rows.Count; k++)
    //            {
    //                intro = oDs.Tables[0].Rows[k]["intro"].ToString();
    //                subject = oDs.Tables[0].Rows[k]["subject"].ToString();
    //                cliente = oDs.Tables[0].Rows[k]["cliente"].ToString();
    //                maquina = oDs.Tables[0].Rows[k]["maquina"].ToString();
    //                alteracao = oDs.Tables[0].Rows[k]["alteracao"].ToString();
    //                serial_antigo = oDs.Tables[0].Rows[k]["serial_antigo"].ToString();
    //                serial_novo = oDs.Tables[0].Rows[k]["serial_novo"].ToString();
    //                data_ocorrencia = oDs.Tables[0].Rows[k]["data_ocorrencia"].ToString();
    //                hora_ocorrencia = oDs.Tables[0].Rows[k]["hora_ocorrencia"].ToString();
    //                email = oDs.Tables[0].Rows[k]["emails_alerta"].ToString();

    //                body = "Informa-se que foi efetuada uma alteração na máquina " + maquina + " do cliente " + cliente + " às " + hora_ocorrencia + " horas do dia " + data_ocorrencia;
    //                body += " com alteração do " + alteracao + " de " + serial_antigo + " para " + serial_novo;

    //                // Envia o email ao cliente
    //                sendEmail(subject, body, intro, email);
    //            }
    //        }

    //        try
    //        {
    //            oDB = new DataSqlServer();
    //            sql = String.Format(@"  DELETE FROM CASHDRO_MAQUINAS_EMAILS_SERIALS");
    //            CommandResult oRes = new CommandResult(); 
    //            oRes = oDB.RunDataCommand(sql, "");

    //            if(oRes.Code == "<OK>")
    //            {
    //                return true;
    //            }

    //            return false;
    //        }
    //        catch (Exception e)
    //        {
    //            return false;
    //        }
    //    }
    //    catch (Exception e)
    //    {
    //        return false;
    //    }
    //}


    //public static Boolean testaMaquinasOnOff(string id, string user, string pass, string url)
    //{
    //    Boolean ret = true;
    //    string sql = "";
    //    url += "/Cashdro3WS/index.php?operation=doTest&name=" + user + "&password=" + pass;

    //    DataSqlServer oDB = new DataSqlServer();

    //    var jsonOut = getRetornoURL(url);

    //    if (jsonOut != "")
    //    {
    //        JToken contourManifest = JObject.Parse(jsonOut);
    //        JToken data = contourManifest.SelectToken("data");
    //        JToken code = contourManifest.SelectToken("code");
    //        string codeStr = code.ToString();

    //        sql = String.Format(@"  declare @ligado bit = {0};
    //                                declare @id int = {1};
    //                                declare @ret int;

    //                                exec cashdro_regista_maquina_ligada_desligada @id, @ligado, @ret output", codeStr == "1" ? "1" : "0", id);

    //        ret = codeStr == "1" ? true : false;
    //    }
    //    else
    //    {
    //        sql = String.Format(@"  declare @ligado bit = {0};
    //                                declare @id int = {1};
    //                                declare @ret int;

    //                                exec cashdro_regista_maquina_ligada_desligada @id, @ligado, @ret output", "0", id);

    //        ret = false;
    //    }

    //    oDB.RunDataCommand(sql, "");

    //    return ret;
    //}

    //public static Boolean testaMaquinasComErro(string url, string maquina, string serial, string id)
    //{
    //    string sql = "";
    //    Boolean erro = false, emailSend = false, email_alerta_enviado = false;
    //    string device = "", error = "";
    //    string subject = "", body = "", intro = "";
    //    string ligacaoDireta = "", destinatarios="";

    //    DataSqlServer oDB = new DataSqlServer();

    //    device = "";
    //    error = "";
    //    erro = false;
    //    emailSend = false;
    //    subject = "";
    //    body = "";
    //    intro = "";
    //    ligacaoDireta = url + "/Cashdro3Web/index.html#/splash/true";

    //    url += "/Cashdro3WS/index.php?operation=getDiagnosis";
    //    var jsonOut = getRetornoURL(url);

    //    if (jsonOut != "")
    //    {
    //        JToken contourManifest = JObject.Parse(jsonOut);
    //        JToken data = contourManifest.SelectToken("data");

    //        JToken withError = data.SelectToken("WithError");
    //        JToken withErrorMRX = data.SelectToken("WithErrorMRX");
    //        JToken devices = data.SelectToken("Devices");

    //        erro = (Convert.ToBoolean(withError.ToString()) || (withErrorMRX != null && Convert.ToBoolean(withErrorMRX.ToString())));

    //        if (erro)
    //        {
    //            for (int k = 0; k < devices.Count(); k++)
    //            {
    //                JToken deviceName = devices[k].SelectToken("deviceName");
    //                JToken deviceState = devices[k].SelectToken("deviceState");
    //                JToken deviceMessagesInfo = devices[k].SelectToken("deviceMessagesInfo");
    //                JToken deviceWithError = devices[k].SelectToken("deviceWithError");

    //                if (Convert.ToBoolean(deviceWithError.ToString()))
    //                {
    //                    device = device + deviceName.ToString() + " ";

    //                    for (int a = 0; a < deviceMessagesInfo.Count(); a++)
    //                    {
    //                        JToken msg = deviceMessagesInfo[a].SelectToken("msg");
    //                        error = error + msg.ToString() + " ";
    //                    }
    //                }
    //            }

    //            // Obtem dados do cliente da maquina
    //            string nome_cliente = "", cashdro_nome = "", nif_cliente = "", morada_cliente = "", nomeestabelecimento = "", pessoaresponsavel = "", telefone = "";
    //            string email_parceiro = "", email_helptech = "", email_cliente = "";
    //            sql = string.Format(@"declare @id int = {0}
    //                                         SELECT
	   //                                         cli.nome cliente,
	   //                                         cli.cashdronome,
	   //                                         cli.nif,
	   //                                         cli.morada,
	   //                                         cli.nomeestabelecimento,
	   //                                         cli.pessoaresponsavel,
	   //                                         cli.telemovel telefone,
	   //                                         isnull(pa.email,'') email_parceiro,
	   //                                         cli.email email_cliente,
	   //                                         cg.emails_alerta email_helptech
    //                                        FROM cashdro_maquinas mq
    //                                        INNER JOIN UTILIZADORES cli ON cli.UTILIZADORESID = mq.id_cliente
    //                                        LEFT JOIN CASHDRO_PARCEIRO_CLIENTE pc on pc.ID_CLIENTE = cli.UTILIZADORESID
    //                                        LEFT JOIN UTILIZADORES pa ON pa.UTILIZADORESID = pc.ID_PARCEIRO
    //                                        INNER JOIN CONFIG_GERAL cg on 1=1
    //                                        WHERE mq.CASHDRO_MAQUINASID=@id", id);

    //            DataSet oDsCli = oDB.GetDataSet(sql, "").oData;

    //            // Vai obter os dados das máquinas
    //            if (oDB.validaDataSet(oDsCli))
    //            {
    //                nome_cliente = oDsCli.Tables[0].Rows[0]["cliente"].ToString().Trim();
    //                cashdro_nome = oDsCli.Tables[0].Rows[0]["cashdronome"].ToString().Trim();
    //                nif_cliente = oDsCli.Tables[0].Rows[0]["nif"].ToString().Trim();
    //                morada_cliente = oDsCli.Tables[0].Rows[0]["morada"].ToString().Trim();
    //                nomeestabelecimento = oDsCli.Tables[0].Rows[0]["nomeestabelecimento"].ToString().Trim();
    //                pessoaresponsavel = oDsCli.Tables[0].Rows[0]["pessoaresponsavel"].ToString().Trim();
    //                telefone = oDsCli.Tables[0].Rows[0]["telefone"].ToString().Trim();

    //                email_parceiro = oDsCli.Tables[0].Rows[0]["email_parceiro"].ToString().Trim();
    //                email_helptech = oDsCli.Tables[0].Rows[0]["email_helptech"].ToString().Trim();
    //                email_cliente = oDsCli.Tables[0].Rows[0]["email_cliente"].ToString().Trim();

    //                if (email_helptech.Trim() != "")
    //                    destinatarios += email_helptech;

    //                if (email_parceiro.Trim() != "")
    //                    destinatarios += ";" + email_parceiro;

    //                if (email_cliente.Trim() != "")
    //                    destinatarios += ";" + email_cliente;

    //            }

    //            intro = "ERRO MÁQUINA " + maquina + "<br /><img src=\"http://helptechpt.ddns.net:6969/Img/error.png\" style=\"height:150px; width: auto;\" />";
    //            subject = "Cashdro Support - Máquina " + maquina + " com Erro";
    //            body = "Informa-se para efeitos de prevenção que existe uma máquina com erro:<br /><br />";

    //            body += maquina + " [" + serial + "]<br />";
    //            body += "Dados do cliente: <br />";
    //            body += "Cliente: " + nome_cliente + "<br />";
    //            body += "Nome Cashdro: " + cashdro_nome + "<br />";
    //            body += "NIF: " + nif_cliente + "<br />";
    //            body += "Morada: " + morada_cliente + "<br />";
    //            body += "Nome do estabelecimento: " + nomeestabelecimento + "<br />";
    //            body += "Pessoa responsável: " + pessoaresponsavel + "<br />";
    //            body += "Contacto telefónico: " + telefone + "<br /><br />";                

    //            body += "Módulos a dar erro: " + device + "<br />";
    //            body += "Erro: " + error + "<br />";
    //            body += "Acesso à máquina: " + ligacaoDireta;
    //        }
    //    }

    //    if (!erro && email_alerta_enviado)
    //    {
    //        intro = "MÁQUINA " + maquina + " OK<br /><img src=\"http://helptechpt.ddns.net:6969/Img/ok.png\" style=\"height:150px; width: auto;\" />";
    //        subject = "Cashdro Support - Máquina " + maquina + " OK";
    //        body = "Informa-se que a máquina<br /><br />";
    //        body += maquina + " [" + serial + "]<br />";
    //        body += "se encontra novamente em pleno funcionamento.";

    //        emailSend = sendEmail(subject, body, intro,"");
    //        email_alerta_enviado = !emailSend;
    //    }
    //    else if (erro && !email_alerta_enviado)
    //    {
    //        emailSend = sendEmail(subject, body, intro, destinatarios);
    //        email_alerta_enviado = emailSend;
    //    }

    //    sql = String.Format(@"  DECLARE @id_maquina int = {0}; 
    //                            DECLARE @status_erro bit = {1};
    //                            DECLARE @email_alerta_enviado bit = {2};
    //                            declare @ret int;

    //                            exec cashdro_regista_maquina_estado_erro @id_maquina, @status_erro, @email_alerta_enviado, @ret output", id, erro ? "1" : "0", email_alerta_enviado ? "1" : "0");
        
    //    oDB.RunDataCommand(sql, "");

    //    return true;
    //}


    //public static string filaMovimentosMaquinasTrata()
    //{
    //    DataSqlServer oDB = new DataSqlServer();
    //    string sql = "", id_maquina = "", url = "", username = "", password = "", dataini = "", datafini = "";

    //    // obtemos as maquinas
    //    sql = @"    set dateformat ymd
    //                declare @id_maquina int;

    //                SELECT
    //                    id,
    //                    [url],
    //                    [password],
    //                    username,
    //                    concat(convert(varchar(10), firstday, 120), '_00:00:00') as firstday,
	   //                 concat(convert(varchar(10), getdate(), 120), '_23:59:59') as lastday
    //                FROM CASHDRO_FILA_MOVIMENTOS_MAQUINAS_TRATA(@id_maquina)";

    //    DataSet oDs = oDB.GetDataSet(sql, "").oData;


    //    var listaMaquinas = new List<string>();

    //    if (oDB.validaDataSet(oDs))
    //    {
    //        foreach (DataRow estaLinha in oDs.Tables[0].Rows)
    //            listaMaquinas.Add(estaLinha["id"].ToString());
    //    }

    //    var tot = listaMaquinas.Count();
    //    var totalMaquinas = tot;

    //    var totok = 0;
    //    var bloco = tot;


    //    while (totok < tot)
    //    {
    //        var listaTasks = new List<Task>();
    //        listaMaquinas.Skip(totok)
    //                     .Take(bloco)
    //                     .ToList()
    //                     .ForEach(t =>
    //                     {
    //                         var novaTaska = Task.Factory.StartNew(() => MethodThreadMovimentosMaquinas(t));
    //                         listaTasks.Add(novaTaska);
    //                     });
    //        Task.WaitAll(listaTasks.ToArray());
    //        totok += bloco;
    //    }

    //    //if (oDB.validaDataSet(oDs))
    //    //{
    //    //    for (int i = 0; i < oDs.Tables[0].Rows.Count; i++)
    //    //    {
    //    //        id_maquina = oDs.Tables[0].Rows[i]["id"].ToString().Trim();
    //    //        url = oDs.Tables[0].Rows[i]["url"].ToString().Trim();
    //    //        username = oDs.Tables[0].Rows[i]["username"].ToString().Trim();
    //    //        password = oDs.Tables[0].Rows[i]["password"].ToString().Trim();
    //    //        dataini = oDs.Tables[0].Rows[i]["firstday"].ToString().Trim();
    //    //        datafini = oDs.Tables[0].Rows[i]["lastday"].ToString().Trim();

    //    //        if(testaMaquinasOnOff(id_maquina, username, password, url))
    //    //        {
    //    //            filaMovimentosMaquinas(url, dataini, datafini, password, username, id_maquina);
    //    //        }
    //    //    }
    //    //}

    //    return "OK";
    //}


    //static bool MethodThreadMovimentosMaquinas(object data)
    //{
    //    DataSqlServer oSQL = new DataSqlServer();

    //    string url="", dataini = "", datafini = "", passw = "", username = "", id_maquina = "";


    //    string sql = @" set dateformat ymd
    //                    declare @id_maquina int;

    //                    SELECT
    //                        id,
    //                        [url],
    //                        [password],
    //                        username,
    //                        concat(convert(varchar(10), firstday, 120), '_00:00:00') as firstday,
	   //                     concat(convert(varchar(10), getdate(), 120), '_23:59:59') as lastday
    //                    FROM CASHDRO_FILA_MOVIMENTOS_MAQUINAS_TRATA(@id_maquina) where id=" + data;
    //    DataSet oDs = oSQL.GetDataSet(sql, "").oData;
    //    if (oSQL.validaDataSet(oDs))
    //    {
    //        id_maquina = oDs.Tables[0].Rows[0]["id"].ToString().Trim();
    //        url = oDs.Tables[0].Rows[0]["url"].ToString().Trim();
    //        username = oDs.Tables[0].Rows[0]["username"].ToString().Trim();
    //        passw = oDs.Tables[0].Rows[0]["password"].ToString().Trim();
    //        dataini = oDs.Tables[0].Rows[0]["firstday"].ToString().Trim();
    //        datafini = oDs.Tables[0].Rows[0]["lastday"].ToString().Trim();


    //        string xml = "";
    //        url += "/Cashdro3WS/index.php?fromDate=" + dataini + "&group=false&name=" + username + "&operation=askMovements&operationType=[{\"Id\":-1},{\"Id\":-2},{\"Id\":1},{\"Id\":2},{\"Id\":3},{\"Id\":4},{\"Id\":8},{\"Id\":10},{\"Id\":11},{\"Id\":12},{\"Id\":14},{\"Id\":16},{\"Id\":17},{\"Id\":18},{\"Id\":22},{\"Id\":23},{\"Id\":27},{\"Id\":28},{\"Id\":29},{\"Id\":32},{\"Id\":33},{\"Id\":34},{\"Id\":42}]&password=" + passw + "&toDate=" + datafini;
    //        var jsonOut = getRetornoURL(url);
    //        var jsonString = jsonOut;
    //        string tipoStr = "", amountStr = "", operationidStr = "", useridStr = "", amountinStr = "", amountoutStr = "", amounttransferredStr = "", roundvalueStr = "";
    //        string posidStr = "", posuserStr = "", aliasidStr = "", nameStr = "", dateStr = "", hourStr = "", errorsStr = "";

    //        if (jsonOut != null)
    //        {
    //            try
    //            {
    //                JObject jObject = JObject.Parse(jsonString);
    //                jsonString = jObject.SelectToken("data").ToString();
    //                jObject = JObject.Parse(jsonString);
    //                JArray Movimentos = (JArray)jObject.SelectToken("movements");

    //                foreach (JToken movimento in Movimentos)
    //                {
    //                    xml = "<MOVIMENTOS>";
    //                    JToken type = movimento.SelectToken("Type");
    //                    JToken amount = movimento.SelectToken("Amount");
    //                    JToken operationID = movimento.SelectToken("OperationId");
    //                    JToken userID = movimento.SelectToken("UserId");
    //                    JToken amountIn = movimento.SelectToken("AmountIn");
    //                    JToken amountOut = movimento.SelectToken("AmountOut");
    //                    JToken amountTransferred = movimento.SelectToken("AmountTransferred");
    //                    JToken roundValue = movimento.SelectToken("RoundValue");
    //                    JToken posID = movimento.SelectToken("PosId");
    //                    JToken posUser = movimento.SelectToken("PosUser");
    //                    JToken aliasID = movimento.SelectToken("AliasId");
    //                    JToken name = movimento.SelectToken("Name");
    //                    JToken date = movimento.SelectToken("Date");
    //                    JToken hour = movimento.SelectToken("Hour");
    //                    JToken errors = movimento.SelectToken("Errors");

    //                    tipoStr = type != null ? checkNumericValue(type.ToString().Trim()) : "0";
    //                    amountStr = amount != null ? checkNumericValue(amount.ToString().Trim()) : "0";
    //                    operationidStr = operationID != null ? checkNumericValue(operationID.ToString().Trim()) : "0";
    //                    useridStr = userID != null ? checkNumericValue(userID.ToString().Trim()) : "0";
    //                    amountinStr = amountIn != null ? checkNumericValue(amountIn.ToString().Trim()) : "0";
    //                    amountoutStr = amountOut != null ? checkNumericValue(amountOut.ToString().Trim()) : "0";
    //                    amounttransferredStr = amountTransferred != null ? checkNumericValue(amountTransferred.ToString().Trim()) : "0";
    //                    roundvalueStr = roundValue != null ? checkNumericValue(roundValue.ToString().Trim()) : "0";
    //                    posidStr = posID != null ? checkNumericValue(posID.ToString().Trim()) : "0";
    //                    posuserStr = posUser != null ? posUser.ToString().Trim() : "";
    //                    aliasidStr = aliasID != null ? aliasID.ToString().Trim() : "";
    //                    nameStr = name != null ? name.ToString().Trim() : "";
    //                    dateStr = date != null ? date.ToString().Trim() : "2020-01-01";
    //                    hourStr = hour != null ? hour.ToString().Trim() : "00:00:00";
    //                    errorsStr = errors != null ? checkNumericValue(errors.ToString().Trim()) : "0";

    //                    xml += "<MOVIMENTO>";
    //                    xml += "<OPERATIONID>" + operationidStr + "</OPERATIONID>";
    //                    xml += "<USERID>" + useridStr + "</USERID>";
    //                    xml += "<TYPE>" + tipoStr + "</TYPE>";
    //                    xml += "<AMOUNT>" + amountStr + "</AMOUNT>";
    //                    xml += "<AMOUNTIN>" + amountinStr + "</AMOUNTIN>";
    //                    xml += "<AMOUNTOUT>" + amountoutStr + "</AMOUNTOUT>";
    //                    xml += "<AMOUNTTRANSFERRED>" + amounttransferredStr + "</AMOUNTTRANSFERRED>";
    //                    xml += "<ROUNDVALUE>" + roundvalueStr + "</ROUNDVALUE>";
    //                    xml += "<POSID>" + posidStr + "</POSID>";
    //                    xml += "<POSUSER>" + posuserStr + "</POSUSER>";
    //                    xml += "<ALIASID>" + aliasidStr + "</ALIASID>";
    //                    xml += "<NAME>" + nameStr + "</NAME>";
    //                    xml += "<DATAMOVIMENTO>" + dateStr + " " + hourStr + "</DATAMOVIMENTO>";
    //                    xml += "<ERRORS>" + errorsStr + "</ERRORS>";
    //                    xml += "</MOVIMENTO>";

    //                    xml += "</MOVIMENTOS>";

    //                    sql = string.Format(@"  SET DATEFORMAT DMY 
    //                                            DECLARE @id_maquina int = {0};
    //                                            DECLARE @xml NVARCHAR(MAX) = N'{1}';
    //                                            DECLARE @erro int;
                               
    //                                            EXEC cashdro_processa_movimentos @id_maquina, @xml, @erro output", id_maquina, xml);

    //                    oSQL.RunDataCommand(sql, "");
    //                }
    //            }
    //            catch (Exception e)
    //            {
    //                return false;
    //            }
    //        }            
    //    }

    //    return true;
    //}


    //public static Boolean filaMovimentosMaquinas(string url, string dataini, string datafini, string passw, string username, string id_maquina)
    //{
    //    DataSqlServer oDB = new DataSqlServer();
    //    string sql = "";
    //    string xml = "";
    //    url += "/Cashdro3WS/index.php?fromDate=" + dataini + "&group=false&name=" + username + "&operation=askMovements&operationType=[{\"Id\":-1},{\"Id\":-2},{\"Id\":1},{\"Id\":2},{\"Id\":3},{\"Id\":4},{\"Id\":8},{\"Id\":10},{\"Id\":11},{\"Id\":12},{\"Id\":14},{\"Id\":16},{\"Id\":17},{\"Id\":18},{\"Id\":22},{\"Id\":23},{\"Id\":27},{\"Id\":28},{\"Id\":29},{\"Id\":32},{\"Id\":33},{\"Id\":34},{\"Id\":42}]&password=" + passw + "&toDate=" + datafini;
    //    var jsonOut = getRetornoURL(url);
    //    var jsonString = jsonOut;
    //    string tipoStr = "", amountStr = "", operationidStr = "", useridStr = "", amountinStr = "", amountoutStr = "", amounttransferredStr = "", roundvalueStr = "";
    //    string posidStr = "", posuserStr = "", aliasidStr = "", nameStr = "", dateStr = "", hourStr = "", errorsStr = "";

    //    if (jsonOut != null)
    //    {
    //        try
    //        {
    //            JObject jObject = JObject.Parse(jsonString);
    //            jsonString = jObject.SelectToken("data").ToString();
    //            jObject = JObject.Parse(jsonString);
    //            JArray Movimentos = (JArray)jObject.SelectToken("movements");
                
    //            foreach (JToken movimento in Movimentos)
    //            {
    //                xml = "<MOVIMENTOS>";
    //                JToken type = movimento.SelectToken("Type");
    //                JToken amount = movimento.SelectToken("Amount");
    //                JToken operationID = movimento.SelectToken("OperationId");
    //                JToken userID = movimento.SelectToken("UserId");
    //                JToken amountIn = movimento.SelectToken("AmountIn");
    //                JToken amountOut = movimento.SelectToken("AmountOut");
    //                JToken amountTransferred = movimento.SelectToken("AmountTransferred");
    //                JToken roundValue = movimento.SelectToken("RoundValue");
    //                JToken posID = movimento.SelectToken("PosId");
    //                JToken posUser = movimento.SelectToken("PosUser");
    //                JToken aliasID = movimento.SelectToken("AliasId");
    //                JToken name = movimento.SelectToken("Name");
    //                JToken date = movimento.SelectToken("Date");
    //                JToken hour = movimento.SelectToken("Hour");
    //                JToken errors = movimento.SelectToken("Errors");

    //                tipoStr = type != null ? checkNumericValue(type.ToString().Trim()) : "0";
    //                amountStr = amount != null ? checkNumericValue(amount.ToString().Trim()) : "0";
    //                operationidStr = operationID != null ? checkNumericValue(operationID.ToString().Trim()) : "0";
    //                useridStr = userID != null ? checkNumericValue(userID.ToString().Trim()) : "0";
    //                amountinStr = amountIn != null ? checkNumericValue(amountIn.ToString().Trim()) : "0";
    //                amountoutStr = amountOut != null ? checkNumericValue(amountOut.ToString().Trim()) : "0";
    //                amounttransferredStr = amountTransferred != null ? checkNumericValue(amountTransferred.ToString().Trim()) : "0";
    //                roundvalueStr = roundValue != null ? checkNumericValue(roundValue.ToString().Trim()) : "0";
    //                posidStr = posID != null ? checkNumericValue(posID.ToString().Trim()) : "0";
    //                posuserStr = posUser != null ? posUser.ToString().Trim() : "";
    //                aliasidStr = aliasID != null ? aliasID.ToString().Trim() : "";
    //                nameStr = name != null ? name.ToString().Trim() : "";
    //                dateStr = date != null ? date.ToString().Trim() : "2020-01-01";
    //                hourStr = hour != null ? hour.ToString().Trim() : "00:00:00";
    //                errorsStr = errors != null ? checkNumericValue(errors.ToString().Trim()) : "0";

    //                xml += "<MOVIMENTO>";
    //                xml += "<OPERATIONID>" + operationidStr + "</OPERATIONID>";
    //                xml += "<USERID>" + useridStr + "</USERID>";
    //                xml += "<TYPE>" + tipoStr + "</TYPE>";
    //                xml += "<AMOUNT>" + amountStr + "</AMOUNT>";
    //                xml += "<AMOUNTIN>" + amountinStr + "</AMOUNTIN>";
    //                xml += "<AMOUNTOUT>" + amountoutStr + "</AMOUNTOUT>";
    //                xml += "<AMOUNTTRANSFERRED>" + amounttransferredStr + "</AMOUNTTRANSFERRED>";
    //                xml += "<ROUNDVALUE>" + roundvalueStr + "</ROUNDVALUE>";
    //                xml += "<POSID>" + posidStr + "</POSID>";
    //                xml += "<POSUSER>" + posuserStr + "</POSUSER>";
    //                xml += "<ALIASID>" + aliasidStr + "</ALIASID>";
    //                xml += "<NAME>" + nameStr + "</NAME>";
    //                xml += "<DATAMOVIMENTO>" + dateStr + " " + hourStr + "</DATAMOVIMENTO>";
    //                xml += "<ERRORS>" + errorsStr + "</ERRORS>";
    //                xml += "</MOVIMENTO>";

    //                xml += "</MOVIMENTOS>";

    //                sql = string.Format(@"  SET DATEFORMAT DMY 
    //                                        DECLARE @id_maquina int = {0};
    //                                        DECLARE @xml NVARCHAR(MAX) = N'{1}';
    //                                        DECLARE @erro int;
                               
    //                                        EXEC cashdro_processa_movimentos @id_maquina, @xml, @erro output", id_maquina, xml);

    //                oDB.RunDataCommand(sql, "");
    //            }
    //        }
    //        catch (Exception e)
    //        {
    //            return false;
    //        }
    //    }

    //    return true;
    //}

    public static string checkNumericValue(string str)
    {
        try
        {
            int value = Int32.Parse(str);
        }
        catch(Exception e)
        {
            return "0";
        }

        return str;
    }

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

    public static Boolean sendEmail(string subject, string body, string intro, string destinatarios)
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

            if (destinatarios.Trim()=="")
                emailVector = emails.Split(';');
            else
                emailVector = destinatarios.Split(';');

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