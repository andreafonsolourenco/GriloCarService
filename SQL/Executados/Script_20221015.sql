IF OBJECT_ID('IX_MAINTENANCE_CLIENTE_VIATURA_DATA_MECANICA_BATECHAPAS') IS NOT NULL
BEGIN
    ALTER TABLE maintenance
	DROP CONSTRAINT IX_MAINTENANCE_CLIENTE_VIATURA_DATA_MECANICA_BATECHAPAS
END
GO

IF COL_LENGTH('MAINTENANCE', 'kms_viatura') IS NOT NULL
BEGIN
    ALTER TABLE MAINTENANCE
	ALTER COLUMN kms_viatura decimal(10,2) NULL
END
GO

IF COL_LENGTH('MAINTENANCE', 'valortotal') IS NOT NULL
BEGIN
    ALTER TABLE MAINTENANCE
	ALTER COLUMN valortotal decimal(10,2)
END
GO

IF COL_LENGTH('MAINTENANCE', 'valoriva') IS NOT NULL
BEGIN
    ALTER TABLE MAINTENANCE
	ALTER COLUMN valoriva decimal(10,2)
END
GO

IF COL_LENGTH('maintenance_lines', 'valor') IS NOT NULL
BEGIN
    ALTER TABLE maintenance_lines
	ALTER COLUMN valor decimal(10,2)
END
GO

IF COL_LENGTH('maintenance_lines', 'iva') IS NOT NULL
BEGIN
    ALTER TABLE maintenance_lines
	ALTER COLUMN iva decimal(10,2)
END
GO

IF COL_LENGTH('CARS', 'ano') IS NOT NULL
BEGIN
    ALTER TABLE CARS
	ALTER COLUMN ano int null
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_MANUTENCAO]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_MANUTENCAO]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_MANUTENCAO](
      @id_op int,
	  @DocXml nvarchar(max),
	  @error int OUTPUT,
	  @errorMsg varchar(max) OUTPUT
)
AS BEGIN     
	SET dateformat dmy;
    SET @error = 0;
	SET @errorMsg = '';
    	
	DECLARE @DocHandle INT; SET @DocHandle=-1;
	DECLARE @XmlDocument VARCHAR(MAX);
	DECLARE @codOp varchar(30);
	DECLARE @idDoc int;
	DECLARE @kms DECIMAL(10,2);
	DECLARE @mecanica BIT;
	DECLARE @batechapas BIT; 
	DECLARE @revisao BIT; 
	DECLARE @docDate VARCHAR(MAX);
	DECLARE @docDescription VARCHAR(MAX);
	DECLARE @orcamento bit;
	DECLARE @valorTotal DECIMAL(10,2);
	DECLARE @valorIVA DECIMAL(10,2);
	DECLARE @customerID int;
	DECLARE @customerName VARCHAR(MAX); 
	DECLARE @customerAddress VARCHAR(MAX); 
	DECLARE @customerZipCode varchar(20); 
	DECLARE @customerCity varchar(500); 
	DECLARE @customerNIF varchar(10);
	DECLARE @carID int;
	DECLARE @carBrand VARCHAR(MAX); 
	DECLARE @carModel VARCHAR(MAX); 
	DECLARE @carRegistration varchar(20); 
	DECLARE @carYear int;

	DECLARE @tipoLog varchar(200);
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

	DECLARE @lines table 
	(   
		id int not null,
		descricao varchar(max) not null,
		valorsemiva decimal(10,2) not null,
		iva decimal(10,2) not null
	)

	select @codOp = codigo
	from REPORT_USERS(@id_op, null, null, 1, null)

	if(ISNULL(@codOp, '') = '')
	begin
		set @error = -1;
		set @errorMsg = 'Operador Inválido!';

		return;
	end

	-- START
	SET @XmlDocument=@DocXml;
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @DocXml;

	-- OBTEMOS AS LINHAS A TRATAR
	SELECT @idDoc = ID, @kms = ISNULL(KMS, 0.0), @mecanica = MECANICA, @batechapas = BATECHAPAS, @revisao = REVISAO, 
		@docDate = [DATA], @docDescription = DESCRICAO, @valorTotal = VALORTOTAL, @valorIVA = VALORIVA, @orcamento = ORCAMENTO
	FROM OPENXML (@DocHandle, '/DOC',2)
	WITH (ID INT, KMS DECIMAL(10,2), MECANICA BIT, BATECHAPAS BIT, REVISAO BIT, [DATA] VARCHAR(MAX), DESCRICAO VARCHAR(MAX), VALORTOTAL DECIMAL(10,2), VALORIVA DECIMAL(10,2), ORCAMENTO BIT)

	SELECT @customerName = NOME, @customerAddress = MORADA, @customerZipCode = CODPOSTAL, @customerCity = LOCALIDADE, @customerNIF = NIF
	FROM OPENXML (@DocHandle, '/DOC/CLIENTE',2)
	WITH (NOME VARCHAR(MAX), MORADA VARCHAR(MAX), CODPOSTAL varchar(20), LOCALIDADE varchar(500), NIF varchar(10))

	SELECT @carBrand = MARCA, @carModel = MODELO, @carRegistration = MATRICULA, @carYear = ISNULL(ANO, 0)
	FROM OPENXML (@DocHandle, '/DOC/VIATURA',2)
	WITH (MARCA VARCHAR(MAX), MODELO VARCHAR(MAX), MATRICULA varchar(20), ANO int)
	
	INSERT INTO @lines(id, descricao, valorsemiva, iva)
	SELECT ID, DESCRICAO, VALORSEMIVA, IVA
	FROM OPENXML (@DocHandle, '/DOC/LINHAS/LINHA',2)
	WITH (ID INT, DESCRICAO VARCHAR(MAX), VALORSEMIVA DECIMAL(10,2), IVA DECIMAL(10,2))

	select @customerID = id
	from REPORT_CUSTOMERS(null, @customerNIF, 1)

	select @carID = id
	from REPORT_CARS(null, @carRegistration)

	IF(ISNULL(@customerID, 0) > 0)
	BEGIN
		UPDATE CUSTOMERS
			set nome = @customerName,
			morada = @customerAddress,
			codpostal = @customerZipCode,
			localidade = @customerCity,
			nif = @customerNIF,
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		where CUSTOMERSID = @customerID
	END
	ELSE
	BEGIN
		INSERT INTO CUSTOMERS(nome, morada, codpostal, localidade, nif, ctrlcodop)
		VALUES(@customerName, @customerAddress, @customerZipCode, @customerCity, @customerNIF, @codOp)

		set @customerID = SCOPE_IDENTITY();
	END

	IF(ISNULL(@carID, 0) > 0)
	BEGIN
		UPDATE CARS
			set marca = @carBrand,
			modelo = @carModel,
			matricula = @carRegistration,
			ano = @carYear,
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		where CARSID = @carID
	END
	ELSE
	BEGIN
		INSERT INTO CARS(marca, modelo, matricula, ano, ctrlcodop)
		VALUES(@carBrand, @carModel, @carRegistration, @carYear, @codOp)

		set @carID = SCOPE_IDENTITY();
	END

	IF(ISNULL(@idDoc, 0) > 0)
	BEGIN
		UPDATE MAINTENANCE
			set kms_viatura = @kms,
			mecanica = @mecanica,
			batechapas = @batechapas,
			revisao = @revisao,
			data_manutencao = CAST(@docDate as date),
			valortotal = @valorTotal,
			valoriva = @valorIVA,
			orcamento = @orcamento,
			id_viatura = @carID,
			id_cliente = @customerID,
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		WHERE MAINTENANCEID = @idDoc

		if(@orcamento = 1)
		begin
			set @tipoLog = 'ORÇAMENTOS';
			set @log = CONCAT('O utilizador ', @codOp, ' atualizou os dados do orçamento efetuado à viatura do cliente ', @customerName, ' com a matrícula, ', @carRegistration, ' no dia ', CAST(@docDate as date))
		end
		else
		begin
			set @tipoLog = 'REPARAÇÕES';
			set @log = CONCAT('O utilizador ', @codOp, ' atualizou os dados da reparação efetuada à viatura do cliente ', @customerName, ' com a matrícula, ', @carRegistration, ' no dia ', CAST(@docDate as date))
		end

		EXEC REGISTA_LOG @id_op, @idDoc, @tipoLog, @log, @retLog output, @retMsgLog output;
	END
	ELSE
	BEGIN
		INSERT INTO MAINTENANCE(kms_viatura, mecanica, batechapas, revisao, data_manutencao, descricao, valortotal, valoriva, orcamento, id_viatura, id_cliente, ctrlcodop)
		values(@kms, @mecanica, @batechapas, @revisao, CAST(@docDate as date), @docDescription, @valorTotal, @valorIVA, @orcamento, @carID, @customerID, @codOp)

		set @idDoc = SCOPE_IDENTITY();

		if(@orcamento = 1)
		begin
			set @tipoLog = 'ORÇAMENTOS';
			set @log = CONCAT('O utilizador ', @codOp, ' inseriu os dados do orçamento efetuado à viatura do cliente ', @customerName, ' com a matrícula, ', @carRegistration, ' no dia ', CAST(@docDate as date))
		end
		else
		begin
			set @tipoLog = 'REPARAÇÕES';
			set @log = CONCAT('O utilizador ', @codOp, ' inseriu os dados da reparação efetuada à viatura do cliente ', @customerName, ' com a matrícula, ', @carRegistration, ' no dia ', CAST(@docDate as date))
		end

		EXEC REGISTA_LOG @id_op, @idDoc, @tipoLog, @log, @retLog output, @retMsgLog output;
	END

	INSERT INTO MAINTENANCE_LINES(id_manutencao, descricao, iva, valor, ctrlcodop)
	select @idDoc, descricao, iva, valorsemiva, @codOp
	from @lines
	where id <= 0

	UPDATE MAINTENANCE_LINES
		SET id_manutencao = idManut, 
		descricao = lines.descricao,
		valor = lines.valorsemiva,
		iva = lines.iva,
		ctrldataupdt = dataatual,
		ctrlcodopupdt = codOp
	FROM (
		select id, descricao, valorsemiva, iva, @codOp as codOp, getdate() as dataatual, @idDoc as idManut
		from @lines
	) as lines
	where MAINTENANCE_LINES.MAINTENANCE_LINESID = lines.id

	UPDATE MAINTENANCE
		SET valoriva = iva,
		valortotal = tot
	FROM (
		select sum(valor * (1 + (iva * 0.01))) as tot, SUM(valor * (iva * 0.01)) as iva
		from MAINTENANCE_LINES
		where id_manutencao = @idDoc
		group by id_manutencao
	) as lines
	where MAINTENANCEID = @idDoc

	SET @error = @idDoc;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO

