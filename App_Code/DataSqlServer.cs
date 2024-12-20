using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using Microsoft.VisualBasic.FileIO;
using System;
using System.Collections.Generic;
using System.IO;
using ExcelDataReader;

/// <summary>
/// Summary description for DataSqlServer
/// </summary>
public class DataSqlServer
{
    SqlConnection oConn = null;

    public DataSqlServer()
    {

    }

    public struct getDataResult
    {
        public int Code;
        public string Message;
        public DataSet oData;
    }

    public struct CommandResult
    {
        public string Code;
        public string Message;
    }

    private string getConnectionString()
    {
        string ret = ConfigurationManager.ConnectionStrings["CS_GCS"].ConnectionString.ToString();

        return ret;
    }

    private void openDataBase()
    {
        if (oConn.State == ConnectionState.Closed) oConn.Open();
    }

    private void closeDataBase()
    {
        if (oConn.State == ConnectionState.Open) oConn.Close();
    }

    public bool validaDataSet(DataSet oDs)
    {
        if (oDs != null && oDs.Tables.Count > 0 && oDs.Tables[0].Rows.Count > 0)
            return true;
        else
            return false;
    }

    public getDataResult GetDataSet(string query, string session)
    {
        getDataResult oResult = new getDataResult();
        DataSet oData = new DataSet();


        if (session.Trim() != "")
        {
            query += " UPDATE SESSAO SET ultimaiteracao=getdate() WHERE session='" + session + "'";
        }

        // Verifica se temos objeto conexao à bd, se nao tivermos criamos
        if (oConn == null)
        {
            oConn = new SqlConnection(getConnectionString());
        }

        // Executamos o sql para retornar os dados pretendidos
        SqlCommand cmd = new SqlCommand(query, oConn);

        // Abre a conexao à base de dados, caso esta esteja fechada
        openDataBase();


        // create data adapter
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        // this will query your database and return the result to your datatable
        da.Fill(oData);

        // Fecha a conexao à base de dados, caso esta esteja aberta
        closeDataBase();

        // Destroimos o objet DataAdapter
        da.Dispose();


        // Verificamos a consitencia e preparamos o retorno
        if (validaDataSet(oData))
        {
            oResult.Code = 1;
            oResult.Message = "Foram retornados " + oData.Tables[0].Rows.Count.ToString() + " registos.";
            oResult.oData = oData;
        }

        return oResult;
    }

    public CommandResult RunDataCommand(string query, string session)
    {
        CommandResult oRes = new CommandResult();
        oRes.Code = "";
        oRes.Message = "";


        if (session.Trim() != "")
        {
            query += " UPDATE SESSAO SET ultimaiteracao=getdate() WHERE session='" + session + "'";
        }

        try
        {
            // Verifica se temos objeto conexao à bd, se nao tivermos criamos
            if (oConn == null)
            {
                oConn = new SqlConnection(getConnectionString());
            }

            // Abre a conexao à base de dados, caso esta esteja fechada
            openDataBase();

            SqlCommand cmdExecute = new SqlCommand(query, oConn);
            cmdExecute.ExecuteNonQuery();

            // Fecha a conexao à base de dados, caso esta esteja aberta
            closeDataBase();

            cmdExecute.Dispose();

            oRes.Code = "<OK>";
            oRes.Message = "Comando executado com sucesso.";
        }
        catch (SqlException ex)
        {
            oRes.Code = "<ERROR>";
            oRes.Message = ex.Message.ToString();
        }

        return oRes;
    }

    private DataTable GetDataTableFromCSVFile(string csv_file_path)
    {
        DataTable csvData = new DataTable();
        try
        {
            using (TextFieldParser csvReader = new TextFieldParser(csv_file_path))
            {
                csvReader.SetDelimiters(new string[] { ";" });
                csvReader.HasFieldsEnclosedInQuotes = true;
                string[] colFields = csvReader.ReadFields();
                foreach (string column in colFields)
                {
                    DataColumn datecolumn = new DataColumn(column);
                    datecolumn.AllowDBNull = true;
                    csvData.Columns.Add(datecolumn);
                }
                while (!csvReader.EndOfData)
                {
                    string[] fieldData = csvReader.ReadFields();
                    //Making empty value as null
                    for (int i = 0; i < fieldData.Length; i++)
                    {
                        if (fieldData[i] == "")
                        {
                            fieldData[i] = null;
                        }
                    }
                    csvData.Rows.Add(fieldData);
                }
            }
        }
        catch (Exception ex)
        {
            return null;
        }
        return csvData;
    }

    private bool insertDataIntoDB(DataTable csvFileData, string tableName, string userID)
    {
        try
        {
            // Verifica se temos objeto conexao à bd, se nao tivermos criamos
            if (oConn == null)
            {
                oConn = new SqlConnection(getConnectionString());
            }

            // Abre a conexao à base de dados, caso esta esteja fechada
            openDataBase();

            using (SqlBulkCopy s = new SqlBulkCopy(oConn))
            {
                DataTable dt = null;
                s.DestinationTableName = tableName;
                
                foreach (var column in csvFileData.Columns)
                {
                    s.ColumnMappings.Add(column.ToString(), column.ToString());
                }

                switch(tableName)
                {
                    case "CUSTOMERS":
                        dt = getCustomerDataTable(csvFileData, userID);
                        break;
                    case "CARS":
                        dt = getCarsDataTable(csvFileData, userID);
                        break;
                    case "PROVIDERS":
                        dt = getProvidersDataTable(csvFileData, userID);
                        break;
                    default:
                        break;
                }

                openDataBase();
                s.WriteToServer(dt);
            }

            // Fecha a conexao à base de dados, caso esta esteja aberta
            closeDataBase();
        }
        catch (Exception ex)
        {
            return false;
        }

        return true;
    }

    private DataTable getCustomerDataTable(DataTable csvFileData, string userID)
    {
        DataTable dt = csvFileData.Clone();
        string[] rowNames = { "nome", "morada", "codpostal", "localidade", "nif", "pais" };

        foreach (DataRow row in csvFileData.Rows)
        {
            if (!updateCustomerIfExists(userID, row))
            {
                if(validateMandatoryRows(row, rowNames))
                {
                    dt.ImportRow(row);
                }
            }
        }

        return dt;
    }

    private DataTable getCarsDataTable(DataTable csvFileData, string userID)
    {
        DataTable dt = csvFileData.Clone();
        string[] rowNames = { "marca", "modelo", "ano", "matricula" };

        foreach (DataRow row in csvFileData.Rows)
        {
            if (!updateCarIfExists(userID, row))
            {
                if (validateMandatoryRows(row, rowNames))
                {
                    dt.ImportRow(row);
                }
            }
        }

        return dt;
    }

    private DataTable getProvidersDataTable(DataTable csvFileData, string userID)
    {
        DataTable dt = csvFileData.Clone();
        string[] rowNames = { "nome", "morada", "codpostal", "localidade", "nif", "iban", "email" };

        foreach (DataRow row in csvFileData.Rows)
        {
            if (!updateProviderIfExists(userID, row))
            {
                if (validateMandatoryRows(row, rowNames))
                {
                    dt.ImportRow(row);
                }
            }
        }

        return dt;
    }

    private bool validateMandatoryRows(DataRow row, string[] rowNames)
    {
        foreach(string rowName in rowNames)
        {
            if(String.IsNullOrEmpty(row[rowName].ToString()))
            {
                return false;
            }
        }

        return true;
    }

    public static bool SaveAsCsv(string excelFilePath, string destinationCsvFilePath)
    {
        try
        {
            using (var stream = new FileStream(excelFilePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            {
                IExcelDataReader reader = null;
                if (excelFilePath.EndsWith(".xls"))
                {
                    reader = ExcelReaderFactory.CreateBinaryReader(stream);
                }
                else if (excelFilePath.EndsWith(".xlsx"))
                {
                    reader = ExcelReaderFactory.CreateOpenXmlReader(stream);
                }

                if (reader == null)
                    return false;

                DataSet ds = reader.AsDataSet(new ExcelDataSetConfiguration()
                {
                    ConfigureDataTable = (tableReader) => new ExcelDataTableConfiguration()
                    {
                        UseHeaderRow = false
                    }
                });

                var csvContent = string.Empty;
                int row_no = 0;
                while (row_no < ds.Tables[0].Rows.Count)
                {
                    var arr = new List<string>();
                    for (int i = 0; i < ds.Tables[0].Columns.Count; i++)
                    {
                        arr.Add(ds.Tables[0].Rows[row_no][i].ToString());
                    }
                    row_no++;
                    csvContent += string.Join(";", arr) + "\n";
                }

                StreamWriter csv = new StreamWriter(destinationCsvFilePath, false);
                csv.Write(csvContent);
                csv.Close();
                return true;
            }
        }
        catch (Exception ex)
        {
            return false;
        }
    }

    public bool updateCustomerIfExists(string userID, DataRow row)
    {
        string nome = row["nome"].ToString(), morada = row["morada"].ToString(), codpostal = row["codpostal"].ToString(), 
            localidade = row["localidade"].ToString(), nif = row["nif"].ToString(), pais = row["pais"].ToString(), 
            email = row["email"].ToString(), telemovel = row["telemovel"].ToString();

        string sql = string.Format(@"   declare @userid int = {0};
                                        declare @id int;
	                                    declare @nome varchar(max) = '{1}';
	                                    declare @morada varchar(max) = '{2}';
	                                    declare @localidade varchar(500) = '{3}';
	                                    declare @codpostal varchar(20) = '{4}';
	                                    declare @email varchar(max) = '{5}';
	                                    declare @telemovel varchar(50) = '{6}';
	                                    declare @nif varchar(10) = '{7}';
	                                    declare @pais varchar(200) = '{8}';
                                        declare @fromCsvFile bit = 1;
                                        declare @ativo bit = 1;
                                        declare @notas varchar(max) = 'Cliente inserido através do carregamento de ficheiro';
                                        declare @ret int;
                                        declare @retMsg VARCHAR(max);

                                        EXEC CRIA_EDITA_CUSTOMER @userid, @id, @nome, @morada, @localidade, @codpostal, @email, @telemovel, @nif, @pais, @notas, @ativo, @fromCsvFile, @ret OUTPUT, @retMsg OUTPUT

                                        select @ret as ret, @retMsg as retMsg", userID, nome, morada, localidade, codpostal, email, telemovel, nif, pais);
        
        DataSet oDs = GetDataSet(sql, "").oData;

        if (validaDataSet(oDs))
        {
            if(Convert.ToInt32(oDs.Tables[0].Rows[0]["ret"].ToString().Trim()) > 0)
            {
                return true;
            }

            return false;
        }

        return false;
    }

    public bool updateCarIfExists(string userID, DataRow row)
    {
        string marca = row["marca"].ToString(), modelo = row["modelo"].ToString(), ano = row["ano"].ToString(),
            matricula = row["matricula"].ToString();

        string sql = string.Format(@"   declare @idUser int = {0};
                                        declare @id int;
	                                    declare @marca varchar(max) = '{1}';
                                        declare @modelo varchar(max) = '{2}';
                                        declare @ano int = {3};
                                        declare @matricula varchar(20) = '{4}';
                                        declare @notas varchar(max) = 'Viatura inserida através do carregamento de ficheiro';
                                        declare @fromCsvFile bit = 1;
                                        declare @ret int;
                                        declare @retMsg VARCHAR(max);

                                        EXEC CRIA_EDITA_CAR @idUser, @id, @marca, @modelo, @ano, @matricula, @notas, @fromCsvFile, @ret OUTPUT, @retMsg OUTPUT

                                        select @ret as ret, @retMsg as retMsg", userID, marca, modelo, ano, matricula);

        DataSet oDs = GetDataSet(sql, "").oData;

        if (validaDataSet(oDs))
        {
            if (Convert.ToInt32(oDs.Tables[0].Rows[0]["ret"].ToString().Trim()) > 0)
            {
                return true;
            }

            return false;
        }

        return false;
    }

    public bool updateProviderIfExists(string userID, DataRow row)
    {
        string nome = row["nome"].ToString(), morada = row["morada"].ToString(), codpostal = row["codpostal"].ToString(),
            localidade = row["localidade"].ToString(), nif = row["nif"].ToString(), iban = row["iban"].ToString(),
            email = row["email"].ToString();

        string sql = string.Format(@"   declare @userid int = {0};
                                        declare @id int;
	                                    declare @nome varchar(max) = '{1}';
	                                    declare @morada varchar(max) = '{2}';
	                                    declare @localidade varchar(500) = '{3}';
	                                    declare @codpostal varchar(20) = '{4}';
	                                    declare @email varchar(max) = '{5}';
	                                    declare @iban varchar(500) = '{6}';
	                                    declare @nif varchar(10) = '{7}';
                                        declare @fromCsvFile bit = 1;
                                        declare @ativo bit = 1;
                                        declare @notas varchar(max) = 'Fornecedor inserido através do carregamento de ficheiro';
                                        declare @ret int;
                                        declare @retMsg VARCHAR(max);

                                        EXEC CRIA_EDITA_PROVIDER @idUser, @id, @nome, @morada, @localidade, @codpostal, @iban, @nif, @email, @ativo, @notas, @fromCsvFile, @ret OUTPUT, @retMsg OUTPUT

                                        select @ret as ret, @retMsg as retMsg", userID, nome, morada, localidade, codpostal, email, iban, nif);

        DataSet oDs = GetDataSet(sql, "").oData;

        if (validaDataSet(oDs))
        {
            if (Convert.ToInt32(oDs.Tables[0].Rows[0]["ret"].ToString().Trim()) > 0)
            {
                return true;
            }

            return false;
        }

        return false;
    }

    public bool insertCSVFileIntoDB(string path, string tableName, string userID)
    {
        if(path.EndsWith(".xls") || path.EndsWith(".xlsx"))
        {
            string newPath = path.EndsWith(".xlsx") ? path.Replace(".xlsx", ".csv") : path.Replace(".xls", ".csv");
            if(!SaveAsCsv(path, newPath))
            {
                return false;
            }
            path = newPath;
        }

        DataTable csvData = GetDataTableFromCSVFile(path);

        if(csvData == null)
        {
            return false;
        }

        return insertDataIntoDB(csvData, tableName, userID);
    }
}