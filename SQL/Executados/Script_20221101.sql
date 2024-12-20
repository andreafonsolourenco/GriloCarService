IF COL_LENGTH('MAINTENANCE', 'numero') IS NULL
BEGIN
    ALTER TABLE MAINTENANCE
    ADD numero varchar(500) null default ''
END
GO

IF COL_LENGTH('MAINTENANCE', 'data_vencimento') IS NULL
BEGIN
    ALTER TABLE MAINTENANCE
    ADD data_vencimento date not null default cast(dateadd(month, 1, getdate()) as date)
END
GO

IF COL_LENGTH('MAINTENANCE', 'paga') IS NULL
BEGIN
    ALTER TABLE MAINTENANCE
    ADD paga bit not null default 0
END
GO

IF COL_LENGTH('MAINTENANCE', 'metodo_pagamento') IS NULL
BEGIN
    ALTER TABLE MAINTENANCE
    ADD metodo_pagamento varchar(max) null default ''
END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_MAINTENANCES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_MAINTENANCES]
END
GO

CREATE FUNCTION [dbo].[REPORT_MAINTENANCES](@id_maintenance int, @id_cliente int, @id_viatura int, @mecanica bit, @batechapas bit)
returns table as return
(
	select
		maint.MAINTENANCEID as id,
		maint.id_cliente,
		cust.nome as cliente,
		cust.morada as morada_cliente,
		cust.localidade as localidade_cliente,
		cust.codpostal as codpostal_cliente,
		cust.email as email_cliente,
		cust.telemovel as telemovel_cliente,
		cust.nif as nif_cliente,
		maint.id_viatura,
		cars.marca,
		cars.modelo,
		cars.ano,
		cars.matricula,
		cast(maint.data_manutencao as date) as data_manutencao,
		convert(varchar, data_manutencao, 105) as data_manutencao_it,
		convert(varchar, data_manutencao, 103) as data_manutencao_uk,
		convert(varchar, data_manutencao, 111) as data_manutencao_jp,
		convert(varchar(10), data_manutencao, 120) as data_manutencao_odbc,
		maint.descricao,
		maint.mecanica,
		maint.batechapas,
		maint.valortotal,
		maint.revisao,
		maint.valoriva,
		maint.kms_viatura,
		ISNULL(maint.numero, '') as numero,
		maint.data_vencimento,
		convert(varchar, data_vencimento, 105) as data_vencimento_it,
		convert(varchar, data_vencimento, 103) as data_vencimento_uk,
		convert(varchar, data_vencimento, 111) as data_vencimento_jp,
		convert(varchar(10), data_vencimento, 120) as data_vencimento_odbc,
		maint.paga,
		ISNULL(maint.metodo_pagamento, '') as metodo_pagamento
	from MAINTENANCE maint
	inner join REPORT_CUSTOMERS(@id_cliente, null, null) cust on cust.id = maint.id_cliente
	inner join REPORT_CARS(@id_viatura, null) cars on cars.id = maint.id_viatura
	where (@id_maintenance is null or @id_maintenance = MAINTENANCEID)
	and (@id_cliente is null or @id_cliente = id_cliente)
	and (@id_viatura is null or @id_viatura = id_viatura)
	and (@mecanica is null or @mecanica = mecanica)
	and (@batechapas is null or @batechapas = batechapas)
	and maint.orcamento = 0
)
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
	DECLARE @paga bit;
	DECLARE @metodo_pagamento varchar(max);
	DECLARE @numero varchar(500);
	DECLARE @data_vencimento date;
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
		@docDate = [DATA], @docDescription = DESCRICAO, @valorTotal = VALORTOTAL, @valorIVA = VALORIVA, @orcamento = ORCAMENTO,
		@paga = ISNULL(PAGA, 0), @metodo_pagamento = ISNULL(METODO_PAGAMENTO, ''), @numero = ISNULL(NUMERO, ''), @data_vencimento = ISNULL(DATA_VENCIMENTO, cast(dateadd(month, 1, getdate()) as date))
	FROM OPENXML (@DocHandle, '/DOC',2)
	WITH (ID INT, KMS DECIMAL(10,2), MECANICA BIT, BATECHAPAS BIT, REVISAO BIT, [DATA] VARCHAR(MAX), DESCRICAO VARCHAR(MAX), VALORTOTAL DECIMAL(10,2), VALORIVA DECIMAL(10,2), ORCAMENTO BIT,
		PAGA BIT, METODO_PAGAMENTO VARCHAR(MAX), NUMERO VARCHAR(500), DATA_VENCIMENTO DATE)

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
			paga = @paga,
			metodo_pagamento = @metodo_pagamento,
			numero = @numero,
			data_vencimento = @data_vencimento,
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
		INSERT INTO MAINTENANCE(kms_viatura, mecanica, batechapas, revisao, data_manutencao, descricao, valortotal, valoriva, orcamento, id_viatura, id_cliente, paga, metodo_pagamento, numero, data_vencimento, ctrlcodop)
		values(@kms, @mecanica, @batechapas, @revisao, CAST(@docDate as date), @docDescription, @valorTotal, @valorIVA, @orcamento, @carID, @customerID, @paga, @metodo_pagamento, @numero, @data_vencimento, @codOp)

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

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PAY_CUSTOMER_INVOICE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[PAY_CUSTOMER_INVOICE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PAY_CUSTOMER_INVOICE](
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
	DECLARE @metodo_pagamento varchar(max);

	DECLARE @tipoLog varchar(200) = 'REPARAÇÕES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

	DECLARE @ids table 
	(   
		id int not null
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
	SELECT @metodo_pagamento = METODO_PAGAMENTO
	FROM OPENXML (@DocHandle, '/PAGAMENTOS',2)
	WITH (METODO_PAGAMENTO VARCHAR(MAX))

	INSERT INTO @ids(id)
	SELECT ID
	FROM OPENXML (@DocHandle, '/PAGAMENTOS/FATURAS',2)
	WITH (ID INT)

	UPDATE MAINTENANCE
	set paga = 1,
	metodo_pagamento = @metodo_pagamento,
	ctrlcodopupdt = @codOp,
	ctrldataupdt = getdate()
	where MAINTENANCEID in (
		select id
		from @ids
	)
	and paga = 0

	select
		@log = CONCAT(@log, 'O utilizador ', @codOp, ' marcou a fatura ', numero, ' do cliente ', cliente, ' como paga;')
	from [REPORT_MAINTENANCES](null, null, null, null, null) maint
	inner join @ids ids on ids.id = maint.id

	EXEC REGISTA_LOG @id_op, null, @tipoLog, @log, @retLog output, @retMsgLog output;

	SET @error = 0;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO


IF COL_LENGTH('APPLICATION_CONFIG', 'numero_dias_vencimento') IS NULL
BEGIN
    ALTER TABLE APPLICATION_CONFIG
    ADD numero_dias_vencimento int not null default 30
END
GO

IF COL_LENGTH('PROVIDER', 'numero_dias_vencimento') IS NULL
BEGIN
    ALTER TABLE [PROVIDER]
    ADD numero_dias_vencimento int not null default 30
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_CONFIGS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_CONFIGS]
END
GO

CREATE FUNCTION [dbo].[REPORT_CONFIGS]()
returns table as return
(
	select
		email, 
		email_password, 
		email_smtp, 
		email_smtpport, 
		emails_alerta, 
		sessaomaxmin,
		url_nif,
		nif_key,
		numero_dias_vencimento
	from APPLICATION_CONFIG
)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_PROVIDERS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_PROVIDERS]
END
GO

CREATE FUNCTION [dbo].[REPORT_PROVIDERS](@id_provider int, @nif varchar(10))
returns table as return
(
    select
		PROVIDERID as id,
		nome,
		morada,
		localidade,
		codpostal,
		iban,
		nif,
		email,
		ativo,
		notas,
		numero_dias_vencimento
	from [PROVIDER]
	where (@id_provider is null or @id_provider = providerid)
	and (@nif is null or @nif = nif)
)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_PROVIDER_INVOICES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_PROVIDER_INVOICES]
END
GO

CREATE FUNCTION [dbo].[REPORT_PROVIDER_INVOICES](@id_invoice int, @id_provider int, @numero varchar(500), @min_invoice_date date, @max_invoice_data date, @min_due_data date, @max_due_date date)
returns table as return
(
    select
		inv.PROVIDER_INVOICEID as id,
		prov.id as id_provider,
		prov.nome as name_provider,
		prov.morada as address_provider,
		prov.localidade as city_provider,
		prov.codpostal as zipcode_provider,
		prov.iban as iban_provider,
		prov.nif as nif_provider,
		prov.email as email_provider,
		prov.ativo as active_provider,
		prov.notas as notes_provider,
		prov.numero_dias_vencimento,
		inv.numero,
		inv.data_fatura,
		convert(varchar, inv.data_fatura, 105) as data_fatura_it,
		convert(varchar, inv.data_fatura, 103) as data_fatura_uk,
		convert(varchar, inv.data_fatura, 111) as data_fatura_jp,
		convert(varchar(10), inv.data_fatura, 120) as data_fatura_odbc,
		inv.data_vencimento,
		convert(varchar, inv.data_vencimento, 105) as data_vencimento_it,
		convert(varchar, inv.data_vencimento, 103) as data_vencimento_uk,
		convert(varchar, inv.data_vencimento, 111) as data_vencimento_jp,
		convert(varchar(10), inv.data_vencimento, 120) as data_vencimento_odbc,
		inv.valor,
		inv.notas as notas,
		inv.paga,
		isnull(inv.metodo_pagamento, '') as metodo_pagamento
	from PROVIDER_INVOICE inv
	inner join REPORT_PROVIDERS(null, null) prov on prov.id = inv.id_provider
	where (@id_invoice is null or @id_invoice = PROVIDER_INVOICEID)
	and (@id_provider is null or @id_provider = prov.id)
	and (@numero is null or @numero = inv.numero)
	and (@min_invoice_date is null or @min_invoice_date <= inv.data_fatura)
	and (@max_invoice_data is null or @max_invoice_data >= inv.data_fatura)
	and (@min_due_data is null or @min_due_data <= inv.data_vencimento)
	and (@max_due_date is null or @max_due_date >= inv.data_vencimento)
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_PROVIDER_INVOICE_FILE]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_PROVIDER_INVOICE_FILE]
END
GO

CREATE FUNCTION [dbo].[REPORT_PROVIDER_INVOICE_FILE](@id_file int, @id_invoice int, @id_provider int)
returns table as return
(
    select
		PROVIDER_INVOICE_FILEID as id,
		invfile.file_path,
		invfile.notas,
		inv.id as id_invoice,
		inv.id_provider as id_provider,
		inv.name_provider,
		inv.address_provider,
		inv.city_provider,
		inv.zipcode_provider,
		inv.iban_provider,
		inv.nif_provider,
		inv.email_provider,
		inv.active_provider,
		inv.notes_provider,
		inv.numero_dias_vencimento,
		inv.numero,
		inv.data_fatura,
		inv.data_fatura_it,
		inv.data_fatura_uk,
		inv.data_fatura_jp,
		inv.data_fatura_odbc,
		inv.data_vencimento,
		inv.data_vencimento_it,
		inv.data_vencimento_uk,
		inv.data_vencimento_jp,
		inv.data_vencimento_odbc,
		inv.valor,
		inv.notas as notas_invoice,
		inv.paga,
		inv.metodo_pagamento
	from PROVIDER_INVOICE_FILE invfile
	inner join REPORT_PROVIDER_INVOICES(@id_invoice, @id_provider, null, null, null, null, null) inv on inv.id = invfile.id_provider_invoice
	where (@id_provider is null or @id_provider = inv.id_provider)
	and (@id_invoice is null or @id_invoice = inv.id)
	and (@id_file is null or @id_file = invfile.PROVIDER_INVOICE_FILEID)
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_ORCAMENTOS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_ORCAMENTOS]
END
GO

CREATE FUNCTION [dbo].[REPORT_ORCAMENTOS](@id_orcamento int, @id_cliente int, @id_viatura int, @mecanica bit, @batechapas bit)
returns table as return
(
	select
		maint.MAINTENANCEID as id,
		maint.id_cliente,
		cust.nome as cliente,
		cust.morada as morada_cliente,
		cust.localidade as localidade_cliente,
		cust.codpostal as codpostal_cliente,
		cust.email as email_cliente,
		cust.telemovel as telemovel_cliente,
		cust.nif as nif_cliente,
		maint.id_viatura,
		cars.marca,
		cars.modelo,
		cars.ano,
		cars.matricula,
		cast(maint.data_manutencao as date) as data_manutencao,
		convert(varchar, data_manutencao, 105) as data_manutencao_it,
		convert(varchar, data_manutencao, 103) as data_manutencao_uk,
		convert(varchar, data_manutencao, 111) as data_manutencao_jp,
		convert(varchar(10), data_manutencao, 120) as data_manutencao_odbc,
		maint.descricao,
		maint.mecanica,
		maint.batechapas,
		maint.valortotal,
		maint.revisao,
		maint.valoriva,
		maint.kms_viatura,
		ISNULL(maint.numero, '') as numero,
		maint.data_vencimento,
		convert(varchar, data_vencimento, 105) as data_vencimento_it,
		convert(varchar, data_vencimento, 103) as data_vencimento_uk,
		convert(varchar, data_vencimento, 111) as data_vencimento_jp,
		convert(varchar(10), data_vencimento, 120) as data_vencimento_odbc,
		maint.paga,
		ISNULL(maint.metodo_pagamento, '') as metodo_pagamento
	from MAINTENANCE maint
	inner join REPORT_CUSTOMERS(@id_cliente, null, null) cust on cust.id = maint.id_cliente
	inner join REPORT_CARS(@id_viatura, null) cars on cars.id = maint.id_viatura
	where (@id_orcamento is null or @id_orcamento = MAINTENANCEID)
	and (@id_cliente is null or @id_cliente = id_cliente)
	and (@id_viatura is null or @id_viatura = id_viatura)
	and (@mecanica is null or @mecanica = mecanica)
	and (@batechapas is null or @batechapas = batechapas)
	and maint.orcamento = 1
)
GO

IF COL_LENGTH('APPLICATION_CONFIG', 'iban') IS NULL
BEGIN
    ALTER TABLE APPLICATION_CONFIG
    ADD iban varchar(100) not null default ''
END
GO

update application_config
set iban = 'Millennium BCP: PT50003300004567227569205 (BCOMPTPL)'


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_CONFIGS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_CONFIGS]
END
GO

CREATE FUNCTION [dbo].[REPORT_CONFIGS]()
returns table as return
(
	select
		email, 
		email_password, 
		email_smtp, 
		email_smtpport, 
		emails_alerta, 
		sessaomaxmin,
		url_nif,
		nif_key,
		numero_dias_vencimento,
		iban
	from APPLICATION_CONFIG
)
GO


IF COL_LENGTH('APPLICATION_CONFIG', 'url_iban') IS NULL
BEGIN
    ALTER TABLE APPLICATION_CONFIG
    ADD url_iban varchar(max) not null default ''
END
GO

update application_config
set url_iban = 'https://openiban.com/validate/[IBAN]?getBIC=true&validateBankCode=true'
go

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_CONFIGS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_CONFIGS]
END
GO

CREATE FUNCTION [dbo].[REPORT_CONFIGS]()
returns table as return
(
	select
		email, 
		email_password, 
		email_smtp, 
		email_smtpport, 
		emails_alerta, 
		sessaomaxmin,
		url_nif,
		nif_key,
		numero_dias_vencimento,
		iban,
		url_iban
	from APPLICATION_CONFIG
)
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MAINTENANCE_FILE]') AND type in (N'U'))
	DROP TABLE [dbo].[MAINTENANCE_FILE]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MAINTENANCE_FILE](
	[MAINTENANCE_FILEID] [int] IDENTITY(1,1) NOT NULL,
	[id_maintenance] int NOT NULL REFERENCES [MAINTENANCE] ([MAINTENANCEID]),
	[file_path] varchar(max) null default '',
	[notas] [varchar](max) NULL default '',
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_MAINTENANCE_FILE] PRIMARY KEY CLUSTERED 
(
	[MAINTENANCE_FILEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY])
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_MAINTENANCE_FILE]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_MAINTENANCE_FILE]
END
GO

CREATE FUNCTION [dbo].[REPORT_MAINTENANCE_FILE](@id_file int, @id_maintenance int, @id_customer int)
returns table as return
(
    select
		MAINTENANCE_FILEID as id,
		maintfile.file_path,
		maintfile.notas,
		maint.id as id_maintenance,
		maint.id_cliente,
		maint.cliente,
		morada_cliente,
		maint.localidade_cliente,
		maint.codpostal_cliente,
		maint.email_cliente,
		maint.telemovel_cliente,
		maint.nif_cliente,
		maint.id_viatura,
		maint.marca,
		maint.modelo,
		maint.ano,
		maint.matricula,
		data_manutencao,
		data_manutencao_it,
		data_manutencao_uk,
		data_manutencao_jp,
		data_manutencao_odbc,
		maint.descricao,
		maint.mecanica,
		maint.batechapas,
		maint.valortotal,
		maint.revisao,
		maint.valoriva,
		maint.kms_viatura,
		maint.numero,
		maint.data_vencimento,
		maint.data_vencimento_it,
		maint.data_vencimento_uk,
		maint.data_vencimento_jp,
		maint.data_vencimento_odbc,
		maint.paga,
		maint.metodo_pagamento
	from MAINTENANCE_FILE maintfile
	inner join [REPORT_MAINTENANCES](@id_maintenance, @id_customer, null, null, null) maint on maint.id = maintfile.id_maintenance
	where (@id_customer is null or @id_customer = maint.id_cliente)
	and (@id_maintenance is null or @id_maintenance = maint.id)
	and (@id_file is null or @id_file = maintfile.MAINTENANCE_FILEID)
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[DELETE_MAINTENANCE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[DELETE_MAINTENANCE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_MAINTENANCE](
	@idUser int,
	@id int,
	@ret int OUTPUT,
	@retMsg varchar(max) output
)
AS BEGIN
	DECLARE @tipoLog varchar(200);
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	DECLARE @orcamento bit;
	DECLARE @typeText varchar(max);

	select @admin = administrador, @codOp = codigo from REPORT_USERS(@idUser, null, null, 1, null)
	select @orcamento = orcamento from MAINTENANCE where MAINTENANCEID = @id

	if(@orcamento = 1)
	begin
		set @typeText = 'Orçamentos';
		set @tipoLog = 'ORÇAMENTOS';
	end
	else
	begin
		set @typeText = 'Reparações';
		set @tipoLog = 'REPARAÇÕES';
	end

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = CONCAT('O utilizador não tem permissões para eliminar ', @typeText, '!');
		return
	end

	if(@orcamento = 1)
	begin
		set @typeText = 'Orçamento';
		select
			@log = CONCAT('O utilizador ', @codOp, ' eliminou o orçamento efetuado no dia ', data_manutencao_uk, ' para o cliente ',  cliente, ' e viatura ', matricula)
		from REPORT_ORCAMENTOS(@id, null, null, null, null)
	end
	else
	begin
		set @typeText = 'Reparação';
		select
			@log = CONCAT('O utilizador ', @codOp, ' eliminou a reparação efetuada no dia ', data_manutencao_uk, ' para o cliente ',  cliente, ' e viatura ', matricula, ' bem como os respetivos ficheiros.')
		from REPORT_MAINTENANCES(@id, null, null, null, null)
	end

	delete from MAINTENANCE_FILE where id_maintenance = @id;
	delete from MAINTENANCE_LINES where id_manutencao = @id;
	delete from MAINTENANCE where MAINTENANCEID = @id;

	set @ret = @id;
	set @retMsg = CONCAT(@typeText, ' eliminado com sucesso!');

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_MAINTENANCE_FILE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_MAINTENANCE_FILE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_MAINTENANCE_FILE](
      @id_op int,
	  @id_file int,
	  @id_maintenance int,
	  @filename varchar(max),
	  @error int OUTPUT,
	  @errorMsg varchar(max) OUTPUT
)
AS BEGIN     
	SET dateformat dmy;
    SET @error = 0;
	SET @errorMsg = '';
    	
	DECLARE @codOp varchar(30);
	DECLARE @tipoLog varchar(200) = 'FATURAS CLIENTES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

	select @codOp = codigo
	from REPORT_USERS(@id_op, null, null, 1, null)

	if(ISNULL(@codOp, '') = '')
	begin
		set @error = -1;
		set @errorMsg = 'Operador Inválido!';

		return;
	end

	if(ISNULL(@id_file, 0) <> 0 and (select id from REPORT_MAINTENANCE_FILE(@id_file, @id_maintenance, null)) is null)
	begin
		set @error = -2;
		set @errorMsg = 'Ficheiro Inválido!';

		return;
	end

	if(ISNULL(@id_maintenance, 0) = 0 and (select id from REPORT_MAINTENANCES(@id_maintenance, null, null, null, null)) is null)
	begin
		set @error = -3;
		set @errorMsg = 'Reparação Inválida!';

		return;
	end

	if(ISNULL(@filename, '') = '' OR CHARINDEX('.', @filename) <= 0)
	begin
		set @error = -4;
		set @errorMsg = 'Nome do Ficheiro Inválido!';

		return;
	end

	IF(ISNULL(@id_file, 0) > 0)
	BEGIN
		UPDATE MAINTENANCE_FILE
			set file_path = @filename,
			id_maintenance = @id_maintenance,
			notas = '',
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		WHERE MAINTENANCE_FILEID = @id_file

		select
			@log = CONCAT('O utilizador ', @codOp, ' atualizou o documento', @filename, ' referente ao pagamento com o número ', numero, ' ao fornecedor ', cliente, ' do dia ', data_manutencao_uk)
		from REPORT_MAINTENANCES(@id_maintenance, null, null, null, null)

		EXEC REGISTA_LOG @id_op, @id_file, @tipoLog, @log, @retLog output, @retMsgLog output;
	END
	ELSE
	BEGIN
		INSERT INTO MAINTENANCE_FILE(file_path, id_maintenance, notas, ctrlcodop)
		values(@filename, @id_maintenance, '', @codOp)

		set @id_file = SCOPE_IDENTITY();

		select
			@log = CONCAT('O utilizador ', @codOp, ' inseriu o documento', @filename, ' referente ao pagamento com o número ', numero, ' ao fornecedor ', cliente, ' do dia ', data_manutencao_uk)
		from REPORT_MAINTENANCES(@id_maintenance, null, null, null, null)

		EXEC REGISTA_LOG @id_op, @id_file, @tipoLog, @log, @retLog output, @retMsgLog output;
	END

	SET @error = @id_file;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_PROVIDER_INVOICE_FILE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_PROVIDER_INVOICE_FILE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_PROVIDER_INVOICE_FILE](
      @id_op int,
	  @id_file int,
	  @id_invoice int,
	  @filename varchar(max),
	  @error int OUTPUT,
	  @errorMsg varchar(max) OUTPUT
)
AS BEGIN     
	SET dateformat dmy;
    SET @error = 0;
	SET @errorMsg = '';
    	
	DECLARE @codOp varchar(30);
	DECLARE @tipoLog varchar(200) = 'FATURAS FORNECEDORES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

	select @codOp = codigo
	from REPORT_USERS(@id_op, null, null, 1, null)

	if(ISNULL(@codOp, '') = '')
	begin
		set @error = -1;
		set @errorMsg = 'Operador Inválido!';

		return;
	end

	if(ISNULL(@id_file, 0) <> 0 and (select id from REPORT_PROVIDER_INVOICE_FILE(@id_file, @id_invoice, null)) is null)
	begin
		set @error = -2;
		set @errorMsg = 'Ficheiro Inválido!';

		return;
	end

	if(ISNULL(@id_invoice, 0) = 0 and (select id from REPORT_PROVIDER_INVOICES(@id_invoice, null, null, null, null, null, null)) is null)
	begin
		set @error = -3;
		set @errorMsg = 'Pagamento a Fornecedor Inválido!';

		return;
	end

	if(ISNULL(@filename, '') = '' OR CHARINDEX('.', @filename) <= 0)
	begin
		set @error = -4;
		set @errorMsg = 'Nome do Ficheiro Inválido!';

		return;
	end

	IF(ISNULL(@id_file, 0) > 0)
	BEGIN
		UPDATE PROVIDER_INVOICE_FILE
			set file_path = @filename,
			id_provider_invoice = @id_invoice,
			notas = '',
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		WHERE PROVIDER_INVOICE_FILEID = @id_file

		select
			@log = CONCAT('O utilizador ', @codOp, ' atualizou o documento', @filename, ' referente ao pagamento com o número ', numero, ' ao fornecedor ', name_provider, ' do dia ', data_fatura_uk)
		from REPORT_PROVIDER_INVOICES(@id_invoice, null, null, null, null, null, null)

		EXEC REGISTA_LOG @id_op, @id_file, @tipoLog, @log, @retLog output, @retMsgLog output;
	END
	ELSE
	BEGIN
		INSERT INTO PROVIDER_INVOICE_FILE(file_path, id_provider_invoice, notas, ctrlcodop)
		values(@filename, @id_invoice, '', @codOp)

		set @id_file = SCOPE_IDENTITY();

		select
			@log = CONCAT('O utilizador ', @codOp, ' inseriu o documento', @filename, ' referente ao pagamento com o número ', numero, ' ao fornecedor ', name_provider, ' do dia ', data_fatura_uk)
		from REPORT_PROVIDER_INVOICES(@id_invoice, null, null, null, null, null, null)

		EXEC REGISTA_LOG @id_op, @id_file, @tipoLog, @log, @retLog output, @retMsgLog output;
	END

	SET @error = @id_file;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO


-- Manutenções
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SALES]') AND type in (N'U'))
DROP TABLE [dbo].[SALES]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SALES](
	[SALESID] [int] IDENTITY(1,1) NOT NULL,
	id_cliente int not null references customers (customersid),
	data_venda datetime not null default getdate(),
	descricao varchar(max) not null default '',
	valortotal decimal(10,2) not null default 0.00,
	valoriva decimal(10,2) not null default 0.00,
	[numero] [varchar](500) NULL default '',
	[data_vencimento] [date] NOT NULL DEFAULT (CONVERT([date],dateadd(month,(1),getdate()))),
	[paga] [bit] NOT NULL default 0,
	[metodo_pagamento] [varchar](max) NULL default '',
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_SALES] PRIMARY KEY CLUSTERED 
(
	[SALESID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SALES_LINES]') AND type in (N'U'))
DROP TABLE [dbo].[SALES_LINES]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SALES_LINES](
	[SALES_LINESID] [int] IDENTITY(1,1) NOT NULL,
	[id_sale] [int] NOT NULL references sales (salesid),
	[descricao] [varchar](max) NOT NULL default '',
	[valor] [decimal](10, 2) NULL default 0.00,
	[iva] [decimal](10, 2) NULL default 0.00,
	[ctrldata] [datetime] NOT NULL default getdate(),
	[ctrlcodop] [varchar](500) NOT NULL default 'AL',
	[ctrldataupdt] [datetime] NULL,
	[ctrlcodopupdt] [varchar](500) NULL,
 CONSTRAINT [PK_SALES_LINES] PRIMARY KEY CLUSTERED 
(
	[SALES_LINESID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SALES_FILES]') AND type in (N'U'))
DROP TABLE [dbo].[SALES_FILES]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SALES_FILES](
	[SALES_FILESID] [int] IDENTITY(1,1) NOT NULL,
	[id_sale] [int] NOT NULL references sales (salesid),
	[file_path] [varchar](max) NULL default '',
	[notas] [varchar](max) NULL default '',
	[ctrldata] [datetime] NOT NULL default getdate(),
	[ctrlcodop] [varchar](500) NOT NULL default 'AL',
	[ctrldataupdt] [datetime] NULL,
	[ctrlcodopupdt] [varchar](500) NULL,
 CONSTRAINT [PK_SALES_FILES] PRIMARY KEY CLUSTERED 
(
	[SALES_FILESID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_SALES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_SALES]
END
GO

CREATE FUNCTION [dbo].[REPORT_SALES](@id_sale int, @id_cliente int, @min_date date, @max_date date, @min_due_date date, @max_due_date date)
returns table as return
(
	select
		s.SALESID as id,
		cust.id as id_cliente,
		cust.nome as cliente,
		cust.morada as morada_cliente,
		cust.localidade as localidade_cliente,
		cust.codpostal as codpostal_cliente,
		cust.email as email_cliente,
		cust.telemovel as telemovel_cliente,
		cust.nif as nif_cliente,
		cast(s.data_venda as date) as data_venda,
		convert(varchar, s.data_venda, 105) as data_venda_it,
		convert(varchar, s.data_venda, 103) as data_venda_uk,
		convert(varchar, s.data_venda, 111) as data_venda_jp,
		convert(varchar(10), s.data_venda, 120) as data_venda_odbc,
		s.descricao,
		s.valortotal,
		s.valoriva,
		s.numero,
		cast(s.data_vencimento as date) as data_vencimento,
		convert(varchar, s.data_vencimento, 105) as data_vencimento_it,
		convert(varchar, s.data_vencimento, 103) as data_vencimento_uk,
		convert(varchar, s.data_vencimento, 111) as data_vencimento_jp,
		convert(varchar(10), s.data_vencimento, 120) as data_vencimento_odbc,
		s.paga,
		s.metodo_pagamento
	from SALES s
	inner join REPORT_CUSTOMERS(@id_cliente, null, null) cust on cust.id = s.id_cliente
	where (@id_sale is null or @id_sale = s.SALESID)
	and (@id_cliente is null or @id_cliente = s.id_cliente)
	and (@min_date is null or @min_date <= cast(s.data_venda as date))
	and (@max_date is null or @max_date >= cast(s.data_venda as date))
	and (@min_due_date is null or @min_due_date <= cast(s.data_vencimento as date))
	and (@max_due_date is null or @max_due_date >= cast(s.data_vencimento as date))
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_SALES_LINES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_SALES_LINES]
END
GO

CREATE FUNCTION [dbo].[REPORT_SALES_LINES](@id_linha int, @id_sale int, @id_customer int)
returns table as return
(
	select
		lines.SALES_LINESID as id,
		s.id as id_sale,
		s.id_cliente,
		s.cliente,
		s.morada_cliente,
		s.localidade_cliente,
		s.codpostal_cliente,
		s.email_cliente,
		s.telemovel_cliente,
		s.nif_cliente,
		s.data_venda,
		s.data_venda_it,
		s.data_venda_uk,
		s.data_venda_jp,
		s.data_venda_odbc,
		s.descricao as descricao_sale,
		s.valortotal,
		s.valoriva,
		s.numero,
		s.data_vencimento,
		s.data_vencimento_it,
		s.data_vencimento_uk,
		s.data_vencimento_jp,
		s.data_vencimento_odbc,
		s.paga,
		s.metodo_pagamento,
		lines.descricao,
		lines.valor,
		lines.iva
	from SALES_LINES lines
	inner join REPORT_SALES(@id_sale, null, null, null, null, null) s on s.id = lines.id_sale
	where (@id_linha is null or @id_linha = lines.id_sale)
	and (@id_sale is null or @id_sale = lines.SALES_LINESID)
	and (@id_customer is null or @id_customer = s.id_cliente)
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_SALES_FILE]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_SALES_FILE]
END
GO

CREATE FUNCTION [dbo].[REPORT_SALES_FILE](@id_file int, @id_sale int, @id_customer int)
returns table as return
(
    select
		SALES_FILESID as id,
		sfile.file_path,
		sfile.notas,
		s.id as id_sale,
		s.id_cliente,
		s.cliente,
		s.morada_cliente,
		s.localidade_cliente,
		s.codpostal_cliente,
		s.email_cliente,
		s.telemovel_cliente,
		s.nif_cliente,
		s.data_venda,
		s.data_venda_it,
		s.data_venda_uk,
		s.data_venda_jp,
		s.data_venda_odbc,
		s.descricao,
		s.valortotal,
		s.valoriva,
		s.numero,
		s.data_vencimento,
		s.data_vencimento_it,
		s.data_vencimento_uk,
		s.data_vencimento_jp,
		s.data_vencimento_odbc,
		s.paga,
		s.metodo_pagamento
	from SALES_FILES sfile
	inner join REPORT_SALES(@id_sale, @id_customer, null, null, null, null) s on s.id = sfile.id_sale
	where (@id_customer is null or @id_customer = s.id_cliente)
	and (@id_sale is null or @id_sale = s.id)
	and (@id_file is null or @id_file = sfile.SALES_FILESID)
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[DELETE_SALE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[DELETE_SALE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_SALE](
	@idUser int,
	@id int,
	@ret int OUTPUT,
	@retMsg varchar(max) output
)
AS BEGIN
	DECLARE @tipoLog varchar(200) = 'VENDAS';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	DECLARE @numero varchar(500);

	select @admin = administrador, @codOp = codigo from REPORT_USERS(@idUser, null, null, 1, null)

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'O utilizador não tem permissões para apagar as vendas!';
		return
	end

	select @numero = numero from REPORT_SALES(@id, null, null, null, null, null)

	delete from SALES_LINES where SALES_LINESID in (select id from REPORT_SALES_LINES(null, @id, null))
	delete from SALES_FILES where SALES_FILESID in (select id from REPORT_SALES_FILE(null, @id, null))
	delete from SALES where SALESID = @id

	set @ret = @id;
	set @retMsg = 'Venda eliminada com sucesso!';

	set @log = CONCAT('O utilizador ', @codOp, ' removeu a venda ', @numero, ' e consequentemente todos os seus ficheiros')

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_SALE_FILE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_SALE_FILE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_SALE_FILE](
      @id_op int,
	  @id_file int,
	  @id_sale int,
	  @filename varchar(max),
	  @error int OUTPUT,
	  @errorMsg varchar(max) OUTPUT
)
AS BEGIN     
	SET dateformat dmy;
    SET @error = 0;
	SET @errorMsg = '';
    	
	DECLARE @codOp varchar(30);
	DECLARE @tipoLog varchar(200) = 'VENDAS';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

	select @codOp = codigo
	from REPORT_USERS(@id_op, null, null, 1, null)

	if(ISNULL(@codOp, '') = '')
	begin
		set @error = -1;
		set @errorMsg = 'Operador Inválido!';

		return;
	end

	if(ISNULL(@id_file, 0) <> 0 and (select id from REPORT_SALES_FILE(@id_file, @id_sale, null)) is null)
	begin
		set @error = -2;
		set @errorMsg = 'Ficheiro Inválido!';

		return;
	end

	if(ISNULL(@id_sale, 0) = 0 and (select id from REPORT_SALES(@id_sale, null, null, null, null, null)) is null)
	begin
		set @error = -3;
		set @errorMsg = 'Venda Inválida!';

		return;
	end

	if(ISNULL(@filename, '') = '' OR CHARINDEX('.', @filename) <= 0)
	begin
		set @error = -4;
		set @errorMsg = 'Nome do Ficheiro Inválido!';

		return;
	end

	IF(ISNULL(@id_file, 0) > 0)
	BEGIN
		UPDATE SALES_FILES
			set file_path = @filename,
			id_sale = @id_sale,
			notas = '',
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		WHERE SALES_FILESID = @id_file

		select
			@log = CONCAT('O utilizador ', @codOp, ' atualizou o documento', @filename, ' referente à venda com o número ', numero, ' ao cliente ', cliente, ' do dia ', data_venda_uk)
		from REPORT_SALES(@id_sale, null, null, null, null, null)

		EXEC REGISTA_LOG @id_op, @id_file, @tipoLog, @log, @retLog output, @retMsgLog output;
	END
	ELSE
	BEGIN
		INSERT INTO SALES_FILES(file_path, id_sale, notas, ctrlcodop)
		values(@filename, @id_sale, '', @codOp)

		set @id_file = SCOPE_IDENTITY();

		select
			@log = CONCAT('O utilizador ', @codOp, ' inseriu o documento', @filename, ' referente à venda com o número ', numero, ' ao cliente ', cliente, ' do dia ', data_venda_uk)
		from REPORT_SALES(@id_sale, null, null, null, null, null)

		EXEC REGISTA_LOG @id_op, @id_file, @tipoLog, @log, @retLog output, @retMsgLog output;
	END

	SET @error = @id_file;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_SALE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_SALE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_SALE](
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
	DECLARE @docDate VARCHAR(MAX);
	DECLARE @docDescription VARCHAR(MAX);
	DECLARE @valorTotal DECIMAL(10,2);
	DECLARE @valorIVA DECIMAL(10,2);
	DECLARE @paga bit;
	DECLARE @metodo_pagamento varchar(max);
	DECLARE @numero varchar(500);
	DECLARE @data_vencimento date;
	DECLARE @customerID int;
	DECLARE @customerName VARCHAR(MAX); 
	DECLARE @customerAddress VARCHAR(MAX); 
	DECLARE @customerZipCode varchar(20); 
	DECLARE @customerCity varchar(500); 
	DECLARE @customerNIF varchar(10);
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
	SELECT @idDoc = ID, @docDate = [DATA], @docDescription = DESCRICAO, @valorTotal = VALORTOTAL, @valorIVA = VALORIVA,
		@paga = ISNULL(PAGA, 0), @metodo_pagamento = ISNULL(METODO_PAGAMENTO, ''), @numero = ISNULL(NUMERO, ''), 
		@data_vencimento = ISNULL(DATA_VENCIMENTO, cast(dateadd(month, 1, getdate()) as date))
	FROM OPENXML (@DocHandle, '/DOC',2)
	WITH (ID INT, [DATA] VARCHAR(MAX), DESCRICAO VARCHAR(MAX), VALORTOTAL DECIMAL(10,2), VALORIVA DECIMAL(10,2), 
		PAGA BIT, METODO_PAGAMENTO VARCHAR(MAX), NUMERO VARCHAR(500), DATA_VENCIMENTO DATE)

	SELECT @customerName = NOME, @customerAddress = MORADA, @customerZipCode = CODPOSTAL, @customerCity = LOCALIDADE, @customerNIF = NIF
	FROM OPENXML (@DocHandle, '/DOC/CLIENTE',2)
	WITH (NOME VARCHAR(MAX), MORADA VARCHAR(MAX), CODPOSTAL varchar(20), LOCALIDADE varchar(500), NIF varchar(10))
	
	INSERT INTO @lines(id, descricao, valorsemiva, iva)
	SELECT ID, DESCRICAO, VALORSEMIVA, IVA
	FROM OPENXML (@DocHandle, '/DOC/LINHAS/LINHA',2)
	WITH (ID INT, DESCRICAO VARCHAR(MAX), VALORSEMIVA DECIMAL(10,2), IVA DECIMAL(10,2))

	select @customerID = id
	from REPORT_CUSTOMERS(null, @customerNIF, 1)

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

	IF(ISNULL(@idDoc, 0) > 0)
	BEGIN
		UPDATE SALES
			set data_venda = CAST(@docDate as date),
			valortotal = @valorTotal,
			valoriva = @valorIVA,
			id_cliente = @customerID,
			paga = @paga,
			metodo_pagamento = @metodo_pagamento,
			numero = @numero,
			data_vencimento = @data_vencimento,
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		WHERE SALESID = @idDoc

		set @tipoLog = 'VENDAS';
		set @log = CONCAT('O utilizador ', @codOp, ' atualizou os dados da venda efetuada ao cliente ', @customerName, ', com o nº', @numero, ', no dia ', CAST(@docDate as date))

		EXEC REGISTA_LOG @id_op, @idDoc, @tipoLog, @log, @retLog output, @retMsgLog output;
	END
	ELSE
	BEGIN
		INSERT INTO SALES(data_venda, descricao, valortotal, valoriva, id_cliente, paga, metodo_pagamento, numero, data_vencimento, ctrlcodop)
		values(CAST(@docDate as date), @docDescription, @valorTotal, @valorIVA, @customerID, @paga, @metodo_pagamento, @numero, @data_vencimento, @codOp)

		set @idDoc = SCOPE_IDENTITY();

		set @tipoLog = 'VENDAS';
		set @log = CONCAT('O utilizador ', @codOp, ' inseriu os dados da venda efetuada ao cliente ', @customerName, ', com o nº', @numero, ', no dia ', CAST(@docDate as date))

		EXEC REGISTA_LOG @id_op, @idDoc, @tipoLog, @log, @retLog output, @retMsgLog output;
	END

	INSERT INTO SALES_LINES(id_sale, descricao, iva, valor, ctrlcodop)
	select @idDoc, descricao, iva, valorsemiva, @codOp
	from @lines
	where id <= 0

	UPDATE SALES_LINES
		SET id_sale = idSale, 
		descricao = lines.descricao,
		valor = lines.valorsemiva,
		iva = lines.iva,
		ctrldataupdt = dataatual,
		ctrlcodopupdt = codOp
	FROM (
		select id, descricao, valorsemiva, iva, @codOp as codOp, getdate() as dataatual, @idDoc as idSale
		from @lines
	) as lines
	where SALES_LINES.SALES_LINESID = lines.id

	UPDATE SALES
		SET valoriva = iva,
		valortotal = tot
	FROM (
		select sum(valor * (1 + (iva * 0.01))) as tot, SUM(valor * (iva * 0.01)) as iva
		from SALES_LINES
		where id_sale = @idDoc
		group by id_sale
	) as lines
	where SALESID = @idDoc

	SET @error = @idDoc;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_ALL_CUSTOMERS_INVOICES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_ALL_CUSTOMERS_INVOICES]
END
GO

CREATE FUNCTION [dbo].[REPORT_ALL_CUSTOMERS_INVOICES](@id int, @id_customer int, @min_date date, @max_date date, @min_due_date date, @max_due_date date)
returns table as return
(
	with maintenances as (
		select distinct
	        rpt.id,
	        rpt.id_cliente,
	        rpt.cliente,
	        rpt.morada_cliente,
	        rpt.localidade_cliente,
	        rpt.codpostal_cliente,
	        rpt.email_cliente,
	        rpt.telemovel_cliente,
	        rpt.nif_cliente,
	        rpt.id_viatura,
	        rpt.marca,
	        rpt.modelo,
	        rpt.ano,
	        rpt.matricula,
	        rpt.data_manutencao,
	        rpt.data_manutencao_it,
	        rpt.data_manutencao_jp,
	        rpt.data_manutencao_odbc,
	        rpt.data_manutencao_uk,
	        rpt.descricao,
	        rpt.mecanica,
	        rpt.batechapas,
	        rpt.valortotal,
	        rpt.revisao,
	        rpt.valoriva,
	        rpt.kms_viatura,
	        rpt.numero,
	        rpt.data_vencimento,
	        rpt.data_vencimento_it,
	        rpt.data_vencimento_jp,
	        rpt.data_vencimento_odbc,
	        rpt.data_vencimento_uk,
	        rpt.paga,
	        rpt.metodo_pagamento,
            case when ISNULL(maintfile.id, 0) > 0 then 1 else 0 end as has_files,
			0 as sale,
			1 as maintenance
        from REPORT_MAINTENANCES(@id, @id_customer, null, null, null) rpt
        left join report_maintenance_file(null, @id, @id_customer) maintfile on maintfile.id_maintenance = rpt.id
		where (@min_date is null or @min_date <= cast(rpt.data_manutencao as date))
		and (@max_date is null or @max_date >= cast(rpt.data_manutencao as date))
		and (@min_due_date is null or @min_due_date <= cast(rpt.data_vencimento as date))
		and (@max_due_date is null or @max_due_date >= cast(rpt.data_vencimento as date))
	),

	sales as (
		select distinct
			rpt.id,
			rpt.id_cliente,
			rpt.cliente,
			rpt.morada_cliente,
			rpt.localidade_cliente,
			rpt.codpostal_cliente,
			rpt.email_cliente,
			rpt.telemovel_cliente,
			rpt.nif_cliente,
			rpt.data_venda,
			rpt.data_venda_it,
			rpt.data_venda_uk,
			rpt.data_venda_jp,
			rpt.data_venda_odbc,
			rpt.descricao,
			rpt.valortotal,
			rpt.valoriva,
			rpt.numero,
			rpt.data_vencimento,
			rpt.data_vencimento_it,
			rpt.data_vencimento_uk,
			rpt.data_vencimento_jp,
			rpt.data_vencimento_odbc,
			rpt.paga,
			rpt.metodo_pagamento,
			case when ISNULL(sf.id, 0) > 0 then 1 else 0 end as has_files,
			1 as sale,
			0 as maintenance
		from REPORT_SALES(@id, @id_customer, @min_date, @max_date, @min_due_date, @max_due_date) rpt
		left join REPORT_SALES_FILE(null, @id, @id_customer) sf on sf.id_sale = rpt.id
	)

	select
		id,
	    cliente,
		numero,
		paga,
		has_files,
		sale,
		maintenance,
	    id_cliente,
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
	    data_manutencao as data_doc,
	    data_manutencao_it as data_doc_it,
	    data_manutencao_jp as data_doc_jp,
	    data_manutencao_odbc as data_doc_odbc,
	    data_manutencao_uk as data_doc_uk,
	    descricao,
	    mecanica,
	    batechapas,
	    valortotal,
	    revisao,
	    valoriva,
	    kms_viatura,
	    data_vencimento,
	    data_vencimento_it,
	    data_vencimento_jp,
	    data_vencimento_odbc,
	    data_vencimento_uk,
	    metodo_pagamento
	from maintenances
	union
	select
		id,
	    cliente,
		numero,
		paga,
		has_files,
		sale,
		maintenance,
	    id_cliente,
	    morada_cliente,
	    localidade_cliente,
	    codpostal_cliente,
	    email_cliente,
	    telemovel_cliente,
	    nif_cliente,
	    0 as id_viatura,
	    '' as marca,
	    '' as modelo,
	    0 as ano,
	    '' as matricula,
	    data_venda as data_doc,
	    data_venda_it as data_doc_it,
	    data_venda_jp as data_doc_jp,
	    data_venda_odbc as data_doc_odbc,
	    data_venda_uk as data_doc_uk,
	    descricao,
	    0 as mecanica,
	    0 as batechapas,
	    valortotal,
	    0 as revisao,
	    valoriva,
	    0 as kms_viatura,
	    data_vencimento,
	    data_vencimento_it,
	    data_vencimento_jp,
	    data_vencimento_odbc,
	    data_vencimento_uk,
	    metodo_pagamento
	from sales
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PAY_CUSTOMER_INVOICE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[PAY_CUSTOMER_INVOICE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PAY_CUSTOMER_INVOICE](
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
	DECLARE @metodo_pagamento varchar(max);

	DECLARE @tipoLog varchar(200);
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

	DECLARE @ids table 
	(   
		id int not null,
		maintenance bit not null,
		sale bit not null
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
	SELECT @metodo_pagamento = METODO_PAGAMENTO
	FROM OPENXML (@DocHandle, '/PAGAMENTOS',2)
	WITH (METODO_PAGAMENTO VARCHAR(MAX))

	INSERT INTO @ids(id, maintenance, sale)
	SELECT ID, MAINTENANCE, SALE
	FROM OPENXML (@DocHandle, '/PAGAMENTOS/FATURAS',2)
	WITH (ID INT, MAINTENANCE BIT, SALE BIT)

	UPDATE MAINTENANCE
	set paga = 1,
	metodo_pagamento = @metodo_pagamento,
	ctrlcodopupdt = @codOp,
	ctrldataupdt = getdate()
	where MAINTENANCEID in (
		select id
		from @ids
		where maintenance = 1
	)
	and paga = 0

	select
		@log = CONCAT(@log, 'O utilizador ', @codOp, ' marcou a fatura ', numero, ' do cliente ', cliente, ' como paga;'),
		@tipoLog = 'REPARAÇÕES'
	from [REPORT_MAINTENANCES](null, null, null, null, null) maint
	inner join @ids ids on ids.id = maint.id

	EXEC REGISTA_LOG @id_op, null, @tipoLog, @log, @retLog output, @retMsgLog output;

	UPDATE SALES
	set paga = 1,
	metodo_pagamento = @metodo_pagamento,
	ctrlcodopupdt = @codOp,
	ctrldataupdt = getdate()
	where SALESID in (
		select id
		from @ids
		where sale = 1
	)
	and paga = 0

	select
		@log = CONCAT(@log, 'O utilizador ', @codOp, ' marcou a fatura ', numero, ' do cliente ', cliente, ' como paga;'),
		@tipoLog = 'VENDAS'
	from REPORT_SALES(null, null, null, null, null, null) maint
	inner join @ids ids on ids.id = maint.id

	EXEC REGISTA_LOG @id_op, null, @tipoLog, @log, @retLog output, @retMsgLog output;

	SET @error = 0;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SEQUENTIAL_NUMBER]') AND type in (N'U'))
DROP TABLE [dbo].[SEQUENTIAL_NUMBER]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SEQUENTIAL_NUMBER](
	[SEQUENTIAL_NUMBERID] [int] IDENTITY(1,1) NOT NULL,
	[numero] [int] NOT NULL default 0,
	[ano] [int] NOT NULL default 2022,
	[manutencao_venda] [bit] NOT NULL default 1,
	[orcamento] [bit] not null default 0,
	[ctrldata] [datetime] NOT NULL default getdate(),
	[ctrlcodop] [varchar](500) NOT NULL default 'AL',
	[ctrldataupdt] [datetime] NULL,
	[ctrlcodopupdt] [varchar](500) NULL,
 CONSTRAINT [PK_SEQUENTIAL_NUMBER] PRIMARY KEY CLUSTERED 
(
	[SEQUENTIAL_NUMBERID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_SEQUENTIAL_NUMBER_NUMERO_ANO_TIPO] UNIQUE NONCLUSTERED 
(
	[numero] ASC,
	[ano] ASC,
	[manutencao_venda] ASC,
	[orcamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_SEQUENTIAL_NUMBER]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_SEQUENTIAL_NUMBER]
END
GO

CREATE FUNCTION [dbo].[REPORT_SEQUENTIAL_NUMBER](@numero int, @ano int, @manutencao_venda bit, @orcamento bit)
returns table as return
(
	select
		SEQUENTIAL_NUMBERID as id,
		numero,
		ano,
		manutencao_venda,
		orcamento
	from SEQUENTIAL_NUMBER
	where (@numero is null or @numero = numero)
	and (@ano is null or @ano = ano)
	and (@manutencao_venda is null or @manutencao_venda = manutencao_venda)
	and (@orcamento is null or @orcamento = orcamento)
)
GO


IF COL_LENGTH('maintenance', 'num_sequencial') IS NULL
BEGIN
    ALTER TABLE maintenance
    ADD num_sequencial varchar(15) not null default ''
END
GO

IF COL_LENGTH('sales', 'num_sequencial') IS NULL
BEGIN
    ALTER TABLE sales
    ADD num_sequencial varchar(15) not null default ''
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[GENERATE_SEQUENTIAL_NUMBER]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[GENERATE_SEQUENTIAL_NUMBER]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GENERATE_SEQUENTIAL_NUMBER](
      @ano int,
	  @manutencao_venda bit,
	  @orcamento bit,
	  @number varchar(max) OUTPUT
)
AS BEGIN     
	SET dateformat dmy;
	SET @number = '';	
	DECLARE @cnt INT = 0;
	DECLARE @num int;
	DECLARE @idToUpdate int;

	if(select numero from REPORT_SEQUENTIAL_NUMBER(@num, @ano, @manutencao_venda, @orcamento)) is null
	begin
		insert into sequential_number(numero, ano, manutencao_venda, orcamento)
		values(0, @ano, @manutencao_venda, @orcamento)
	end

	select @idToUpdate = id, @num = numero from REPORT_SEQUENTIAL_NUMBER(@num, @ano, @manutencao_venda, @orcamento)

	set @num = @num + 1;

	update sequential_number
	set numero = @num
	where sequential_numberid = @idToUpdate

	WHILE @cnt < (6-LEN(LTRIM(RTRIM(STR(@num)))))
	BEGIN
		SET @number = CONCAT('0', @number)
		SET @cnt = @cnt + 1;
	END;

	select @number = CONCAT(@number, numero, '/', LTRIM(RTRIM(STR(ano)))) from REPORT_SEQUENTIAL_NUMBER(@num, @ano, @manutencao_venda, @orcamento)

	return
END;
GO


declare @ano int;
declare @num_gerado varchar(max);
declare @id int;

DECLARE Cursor_cr cursor FAST_FORWARD for
select maintenanceid, year(data_manutencao)
from maintenance
where orcamento = 1
				    
OPEN Cursor_cr;				
FETCH NEXT FROM Cursor_cr into @id, @ano
WHILE @@FETCH_STATUS = 0
BEGIN
	-------------- para cada linha inserida --------------
	exec GENERATE_SEQUENTIAL_NUMBER @ano, 0, 1, @num_gerado output;

	update maintenance
	set num_sequencial = @num_gerado
	where maintenanceid = @id
	and orcamento = 1

	FETCH NEXT FROM Cursor_cr into @id, @ano
END;

CLOSE Cursor_cr;
DEALLOCATE Cursor_cr;



declare @sale bit;
declare @maintenance bit;

DECLARE Cursor_cr cursor FAST_FORWARD for
select id, year(data_doc), sale, maintenance
from REPORT_ALL_CUSTOMERS_INVOICES(null, null, null, null, null, null)
order by data_doc asc
				    
OPEN Cursor_cr;				
FETCH NEXT FROM Cursor_cr into @id, @ano, @sale, @maintenance
WHILE @@FETCH_STATUS = 0
BEGIN
	-------------- para cada linha inserida --------------
	exec GENERATE_SEQUENTIAL_NUMBER @ano, 1, 0, @num_gerado output;

	if(@maintenance = 1)
	begin
		update maintenance
		set num_sequencial = @num_gerado
		where maintenanceid = @id
		and orcamento = 0
	end

	if(@sale = 1)
	begin
		update sales
		set num_sequencial = @num_gerado
		where salesid = @id
	end

	FETCH NEXT FROM Cursor_cr into @id, @ano, @sale, @maintenance
END;

CLOSE Cursor_cr;
DEALLOCATE Cursor_cr;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_MAINTENANCES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_MAINTENANCES]
END
GO

CREATE FUNCTION [dbo].[REPORT_MAINTENANCES](@id_maintenance int, @id_cliente int, @id_viatura int, @mecanica bit, @batechapas bit)
returns table as return
(
	select
		maint.MAINTENANCEID as id,
		maint.id_cliente,
		cust.nome as cliente,
		cust.morada as morada_cliente,
		cust.localidade as localidade_cliente,
		cust.codpostal as codpostal_cliente,
		cust.email as email_cliente,
		cust.telemovel as telemovel_cliente,
		cust.nif as nif_cliente,
		maint.id_viatura,
		cars.marca,
		cars.modelo,
		cars.ano,
		cars.matricula,
		cast(maint.data_manutencao as date) as data_manutencao,
		convert(varchar, data_manutencao, 105) as data_manutencao_it,
		convert(varchar, data_manutencao, 103) as data_manutencao_uk,
		convert(varchar, data_manutencao, 111) as data_manutencao_jp,
		convert(varchar(10), data_manutencao, 120) as data_manutencao_odbc,
		maint.descricao,
		maint.mecanica,
		maint.batechapas,
		maint.valortotal,
		maint.revisao,
		maint.valoriva,
		maint.kms_viatura,
		ISNULL(maint.numero, '') as numero,
		maint.data_vencimento,
		convert(varchar, data_vencimento, 105) as data_vencimento_it,
		convert(varchar, data_vencimento, 103) as data_vencimento_uk,
		convert(varchar, data_vencimento, 111) as data_vencimento_jp,
		convert(varchar(10), data_vencimento, 120) as data_vencimento_odbc,
		maint.paga,
		ISNULL(maint.metodo_pagamento, '') as metodo_pagamento,
		maint.num_sequencial
	from MAINTENANCE maint
	inner join REPORT_CUSTOMERS(@id_cliente, null, null) cust on cust.id = maint.id_cliente
	inner join REPORT_CARS(@id_viatura, null) cars on cars.id = maint.id_viatura
	where (@id_maintenance is null or @id_maintenance = MAINTENANCEID)
	and (@id_cliente is null or @id_cliente = id_cliente)
	and (@id_viatura is null or @id_viatura = id_viatura)
	and (@mecanica is null or @mecanica = mecanica)
	and (@batechapas is null or @batechapas = batechapas)
	and maint.orcamento = 0
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_MAINTENANCE_FILE]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_MAINTENANCE_FILE]
END
GO

CREATE FUNCTION [dbo].[REPORT_MAINTENANCE_FILE](@id_file int, @id_maintenance int, @id_customer int)
returns table as return
(
    select
		MAINTENANCE_FILEID as id,
		maintfile.file_path,
		maintfile.notas,
		maint.id as id_maintenance,
		maint.id_cliente,
		maint.cliente,
		morada_cliente,
		maint.localidade_cliente,
		maint.codpostal_cliente,
		maint.email_cliente,
		maint.telemovel_cliente,
		maint.nif_cliente,
		maint.id_viatura,
		maint.marca,
		maint.modelo,
		maint.ano,
		maint.matricula,
		data_manutencao,
		data_manutencao_it,
		data_manutencao_uk,
		data_manutencao_jp,
		data_manutencao_odbc,
		maint.descricao,
		maint.mecanica,
		maint.batechapas,
		maint.valortotal,
		maint.revisao,
		maint.valoriva,
		maint.kms_viatura,
		maint.numero,
		maint.data_vencimento,
		maint.data_vencimento_it,
		maint.data_vencimento_uk,
		maint.data_vencimento_jp,
		maint.data_vencimento_odbc,
		maint.paga,
		maint.metodo_pagamento,
		maint.num_sequencial
	from MAINTENANCE_FILE maintfile
	inner join [REPORT_MAINTENANCES](@id_maintenance, @id_customer, null, null, null) maint on maint.id = maintfile.id_maintenance
	where (@id_customer is null or @id_customer = maint.id_cliente)
	and (@id_maintenance is null or @id_maintenance = maint.id)
	and (@id_file is null or @id_file = maintfile.MAINTENANCE_FILEID)
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_ORCAMENTOS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_ORCAMENTOS]
END
GO

CREATE FUNCTION [dbo].[REPORT_ORCAMENTOS](@id_orcamento int, @id_cliente int, @id_viatura int, @mecanica bit, @batechapas bit)
returns table as return
(
	select
		maint.MAINTENANCEID as id,
		maint.id_cliente,
		cust.nome as cliente,
		cust.morada as morada_cliente,
		cust.localidade as localidade_cliente,
		cust.codpostal as codpostal_cliente,
		cust.email as email_cliente,
		cust.telemovel as telemovel_cliente,
		cust.nif as nif_cliente,
		maint.id_viatura,
		cars.marca,
		cars.modelo,
		cars.ano,
		cars.matricula,
		cast(maint.data_manutencao as date) as data_manutencao,
		convert(varchar, data_manutencao, 105) as data_manutencao_it,
		convert(varchar, data_manutencao, 103) as data_manutencao_uk,
		convert(varchar, data_manutencao, 111) as data_manutencao_jp,
		convert(varchar(10), data_manutencao, 120) as data_manutencao_odbc,
		maint.descricao,
		maint.mecanica,
		maint.batechapas,
		maint.valortotal,
		maint.revisao,
		maint.valoriva,
		maint.kms_viatura,
		ISNULL(maint.numero, '') as numero,
		maint.data_vencimento,
		convert(varchar, data_vencimento, 105) as data_vencimento_it,
		convert(varchar, data_vencimento, 103) as data_vencimento_uk,
		convert(varchar, data_vencimento, 111) as data_vencimento_jp,
		convert(varchar(10), data_vencimento, 120) as data_vencimento_odbc,
		maint.paga,
		ISNULL(maint.metodo_pagamento, '') as metodo_pagamento,
		maint.num_sequencial
	from MAINTENANCE maint
	inner join REPORT_CUSTOMERS(@id_cliente, null, null) cust on cust.id = maint.id_cliente
	inner join REPORT_CARS(@id_viatura, null) cars on cars.id = maint.id_viatura
	where (@id_orcamento is null or @id_orcamento = MAINTENANCEID)
	and (@id_cliente is null or @id_cliente = id_cliente)
	and (@id_viatura is null or @id_viatura = id_viatura)
	and (@mecanica is null or @mecanica = mecanica)
	and (@batechapas is null or @batechapas = batechapas)
	and maint.orcamento = 1
)
GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_SALES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_SALES]
END
GO

CREATE FUNCTION [dbo].[REPORT_SALES](@id_sale int, @id_cliente int, @min_date date, @max_date date, @min_due_date date, @max_due_date date)
returns table as return
(
	select
		s.SALESID as id,
		cust.id as id_cliente,
		cust.nome as cliente,
		cust.morada as morada_cliente,
		cust.localidade as localidade_cliente,
		cust.codpostal as codpostal_cliente,
		cust.email as email_cliente,
		cust.telemovel as telemovel_cliente,
		cust.nif as nif_cliente,
		cast(s.data_venda as date) as data_venda,
		convert(varchar, s.data_venda, 105) as data_venda_it,
		convert(varchar, s.data_venda, 103) as data_venda_uk,
		convert(varchar, s.data_venda, 111) as data_venda_jp,
		convert(varchar(10), s.data_venda, 120) as data_venda_odbc,
		s.descricao,
		s.valortotal,
		s.valoriva,
		s.numero,
		cast(s.data_vencimento as date) as data_vencimento,
		convert(varchar, s.data_vencimento, 105) as data_vencimento_it,
		convert(varchar, s.data_vencimento, 103) as data_vencimento_uk,
		convert(varchar, s.data_vencimento, 111) as data_vencimento_jp,
		convert(varchar(10), s.data_vencimento, 120) as data_vencimento_odbc,
		s.paga,
		s.metodo_pagamento,
		s.num_sequencial
	from SALES s
	inner join REPORT_CUSTOMERS(@id_cliente, null, null) cust on cust.id = s.id_cliente
	where (@id_sale is null or @id_sale = s.SALESID)
	and (@id_cliente is null or @id_cliente = s.id_cliente)
	and (@min_date is null or @min_date <= cast(s.data_venda as date))
	and (@max_date is null or @max_date >= cast(s.data_venda as date))
	and (@min_due_date is null or @min_due_date <= cast(s.data_vencimento as date))
	and (@max_due_date is null or @max_due_date >= cast(s.data_vencimento as date))
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_SALES_LINES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_SALES_LINES]
END
GO

CREATE FUNCTION [dbo].[REPORT_SALES_LINES](@id_linha int, @id_sale int, @id_customer int)
returns table as return
(
	select
		lines.SALES_LINESID as id,
		s.id as id_sale,
		s.id_cliente,
		s.cliente,
		s.morada_cliente,
		s.localidade_cliente,
		s.codpostal_cliente,
		s.email_cliente,
		s.telemovel_cliente,
		s.nif_cliente,
		s.data_venda,
		s.data_venda_it,
		s.data_venda_uk,
		s.data_venda_jp,
		s.data_venda_odbc,
		s.descricao as descricao_sale,
		s.valortotal,
		s.valoriva,
		s.numero,
		s.data_vencimento,
		s.data_vencimento_it,
		s.data_vencimento_uk,
		s.data_vencimento_jp,
		s.data_vencimento_odbc,
		s.paga,
		s.metodo_pagamento,
		s.num_sequencial,
		lines.descricao,
		lines.valor,
		lines.iva
	from SALES_LINES lines
	inner join REPORT_SALES(@id_sale, null, null, null, null, null) s on s.id = lines.id_sale
	where (@id_linha is null or @id_linha = lines.id_sale)
	and (@id_sale is null or @id_sale = lines.SALES_LINESID)
	and (@id_customer is null or @id_customer = s.id_cliente)
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_SALES_FILE]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_SALES_FILE]
END
GO

CREATE FUNCTION [dbo].[REPORT_SALES_FILE](@id_file int, @id_sale int, @id_customer int)
returns table as return
(
    select
		SALES_FILESID as id,
		sfile.file_path,
		sfile.notas,
		s.id as id_sale,
		s.id_cliente,
		s.cliente,
		s.morada_cliente,
		s.localidade_cliente,
		s.codpostal_cliente,
		s.email_cliente,
		s.telemovel_cliente,
		s.nif_cliente,
		s.data_venda,
		s.data_venda_it,
		s.data_venda_uk,
		s.data_venda_jp,
		s.data_venda_odbc,
		s.descricao,
		s.valortotal,
		s.valoriva,
		s.numero,
		s.data_vencimento,
		s.data_vencimento_it,
		s.data_vencimento_uk,
		s.data_vencimento_jp,
		s.data_vencimento_odbc,
		s.paga,
		s.metodo_pagamento,
		s.num_sequencial
	from SALES_FILES sfile
	inner join REPORT_SALES(@id_sale, @id_customer, null, null, null, null) s on s.id = sfile.id_sale
	where (@id_customer is null or @id_customer = s.id_cliente)
	and (@id_sale is null or @id_sale = s.id)
	and (@id_file is null or @id_file = sfile.SALES_FILESID)
)
GO



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_ALL_CUSTOMERS_INVOICES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_ALL_CUSTOMERS_INVOICES]
END
GO

CREATE FUNCTION [dbo].[REPORT_ALL_CUSTOMERS_INVOICES](@id int, @id_customer int, @min_date date, @max_date date, @min_due_date date, @max_due_date date)
returns table as return
(
	with maintenances as (
		select distinct
	        rpt.id,
	        rpt.id_cliente,
	        rpt.cliente,
	        rpt.morada_cliente,
	        rpt.localidade_cliente,
	        rpt.codpostal_cliente,
	        rpt.email_cliente,
	        rpt.telemovel_cliente,
	        rpt.nif_cliente,
	        rpt.id_viatura,
	        rpt.marca,
	        rpt.modelo,
	        rpt.ano,
	        rpt.matricula,
	        rpt.data_manutencao,
	        rpt.data_manutencao_it,
	        rpt.data_manutencao_jp,
	        rpt.data_manutencao_odbc,
	        rpt.data_manutencao_uk,
	        rpt.descricao,
	        rpt.mecanica,
	        rpt.batechapas,
	        rpt.valortotal,
	        rpt.revisao,
	        rpt.valoriva,
	        rpt.kms_viatura,
	        rpt.numero,
	        rpt.data_vencimento,
	        rpt.data_vencimento_it,
	        rpt.data_vencimento_jp,
	        rpt.data_vencimento_odbc,
	        rpt.data_vencimento_uk,
	        rpt.paga,
	        rpt.metodo_pagamento,
			rpt.num_sequencial,
            case when ISNULL(maintfile.id, 0) > 0 then 1 else 0 end as has_files,
			0 as sale,
			1 as maintenance
        from REPORT_MAINTENANCES(@id, @id_customer, null, null, null) rpt
        left join report_maintenance_file(null, @id, @id_customer) maintfile on maintfile.id_maintenance = rpt.id
		where (@min_date is null or @min_date <= cast(rpt.data_manutencao as date))
		and (@max_date is null or @max_date >= cast(rpt.data_manutencao as date))
		and (@min_due_date is null or @min_due_date <= cast(rpt.data_vencimento as date))
		and (@max_due_date is null or @max_due_date >= cast(rpt.data_vencimento as date))
	),

	sales as (
		select distinct
			rpt.id,
			rpt.id_cliente,
			rpt.cliente,
			rpt.morada_cliente,
			rpt.localidade_cliente,
			rpt.codpostal_cliente,
			rpt.email_cliente,
			rpt.telemovel_cliente,
			rpt.nif_cliente,
			rpt.data_venda,
			rpt.data_venda_it,
			rpt.data_venda_uk,
			rpt.data_venda_jp,
			rpt.data_venda_odbc,
			rpt.descricao,
			rpt.valortotal,
			rpt.valoriva,
			rpt.numero,
			rpt.data_vencimento,
			rpt.data_vencimento_it,
			rpt.data_vencimento_uk,
			rpt.data_vencimento_jp,
			rpt.data_vencimento_odbc,
			rpt.paga,
			rpt.metodo_pagamento,
			rpt.num_sequencial,
			case when ISNULL(sf.id, 0) > 0 then 1 else 0 end as has_files,
			1 as sale,
			0 as maintenance
		from REPORT_SALES(@id, @id_customer, @min_date, @max_date, @min_due_date, @max_due_date) rpt
		left join REPORT_SALES_FILE(null, @id, @id_customer) sf on sf.id_sale = rpt.id
	)

	select
		id,
	    cliente,
		numero,
		paga,
		has_files,
		sale,
		maintenance,
	    id_cliente,
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
	    data_manutencao as data_doc,
	    data_manutencao_it as data_doc_it,
	    data_manutencao_jp as data_doc_jp,
	    data_manutencao_odbc as data_doc_odbc,
	    data_manutencao_uk as data_doc_uk,
	    descricao,
	    mecanica,
	    batechapas,
	    valortotal,
	    revisao,
	    valoriva,
	    kms_viatura,
	    data_vencimento,
	    data_vencimento_it,
	    data_vencimento_jp,
	    data_vencimento_odbc,
	    data_vencimento_uk,
	    metodo_pagamento,
		num_sequencial
	from maintenances
	union
	select
		id,
	    cliente,
		numero,
		paga,
		has_files,
		sale,
		maintenance,
	    id_cliente,
	    morada_cliente,
	    localidade_cliente,
	    codpostal_cliente,
	    email_cliente,
	    telemovel_cliente,
	    nif_cliente,
	    0 as id_viatura,
	    '' as marca,
	    '' as modelo,
	    0 as ano,
	    '' as matricula,
	    data_venda as data_doc,
	    data_venda_it as data_doc_it,
	    data_venda_jp as data_doc_jp,
	    data_venda_odbc as data_doc_odbc,
	    data_venda_uk as data_doc_uk,
	    descricao,
	    0 as mecanica,
	    0 as batechapas,
	    valortotal,
	    0 as revisao,
	    valoriva,
	    0 as kms_viatura,
	    data_vencimento,
	    data_vencimento_it,
	    data_vencimento_jp,
	    data_vencimento_odbc,
	    data_vencimento_uk,
	    metodo_pagamento,
		num_sequencial
	from sales
)
GO


IF EXISTS (SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[MANUTENCAO_GERA_NUMERO_SEQUENCIAL]') AND [type] = 'TR')
BEGIN
	DROP TRIGGER [dbo].[MANUTENCAO_GERA_NUMERO_SEQUENCIAL];
END;
GO

CREATE TRIGGER [dbo].[MANUTENCAO_GERA_NUMERO_SEQUENCIAL]
   ON [dbo].[MAINTENANCE] 
   AFTER INSERT
AS 
BEGIN
	set dateformat dmy;
	declare @linserted int
	declare @ano int;
	declare @num_gerado varchar(max);
	declare @id int;
    
	BEGIN TRY
		select @lInserted = count(*)
        from inserted
		where orcamento = 0;
		
		BEGIN TRANSACTION
		IF (@linserted > 0)
		BEGIN
			DECLARE Cursor_cr cursor FAST_FORWARD for
			select maintenanceid, year(data_manutencao)
			from inserted
			where orcamento = 0
				    
			OPEN Cursor_cr;				
			FETCH NEXT FROM Cursor_cr into @id, @ano
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-------------- para cada linha inserida --------------
				exec GENERATE_SEQUENTIAL_NUMBER @ano, 0, 1, @num_gerado output;

				update maintenance
				set num_sequencial = @num_gerado
				where maintenanceid = @id
				and orcamento = 0

				FETCH NEXT FROM Cursor_cr into @id, @ano
			END;

			CLOSE Cursor_cr;
			DEALLOCATE Cursor_cr;
		END

	COMMIT TRANSACTION; 
    END TRY

    BEGIN CATCH
		IF XACT_STATE() <> 0 OR @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
	END CATCH;
END;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[ORCAMENTO_GERA_NUMERO_SEQUENCIAL]') AND [type] = 'TR')
BEGIN
	DROP TRIGGER [dbo].[ORCAMENTO_GERA_NUMERO_SEQUENCIAL];
END;
GO

CREATE TRIGGER [dbo].[ORCAMENTO_GERA_NUMERO_SEQUENCIAL]
   ON [dbo].[MAINTENANCE] 
   AFTER INSERT
AS 
BEGIN
	set dateformat dmy;
	declare @linserted int
	declare @ano int;
	declare @num_gerado varchar(max);
	declare @id int;
    
	BEGIN TRY
		select @lInserted = count(*)
        from inserted
		where orcamento = 1;
		
		BEGIN TRANSACTION
		IF (@linserted > 0)
		BEGIN
			DECLARE Cursor_cr cursor FAST_FORWARD for
			select maintenanceid, year(data_manutencao)
			from inserted
			where orcamento = 1
				    
			OPEN Cursor_cr;				
			FETCH NEXT FROM Cursor_cr into @id, @ano
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-------------- para cada linha inserida --------------
				exec GENERATE_SEQUENTIAL_NUMBER @ano, 1, 0, @num_gerado output;

				update maintenance
				set num_sequencial = @num_gerado
				where maintenanceid = @id
				and orcamento = 1

				FETCH NEXT FROM Cursor_cr into @id, @ano
			END;

			CLOSE Cursor_cr;
			DEALLOCATE Cursor_cr;
		END

	COMMIT TRANSACTION; 
    END TRY

    BEGIN CATCH
		IF XACT_STATE() <> 0 OR @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
	END CATCH;
END;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[VENDA_GERA_NUMERO_SEQUENCIAL]') AND [type] = 'TR')
BEGIN
	DROP TRIGGER [dbo].[VENDA_GERA_NUMERO_SEQUENCIAL];
END;
GO

CREATE TRIGGER [dbo].[VENDA_GERA_NUMERO_SEQUENCIAL]
   ON [dbo].[SALES] 
   AFTER INSERT
AS 
BEGIN
	set dateformat dmy;
	declare @linserted int
	declare @ano int;
	declare @num_gerado varchar(max);
	declare @id int;
    
	BEGIN TRY
		select @lInserted = count(*)
        from inserted
		
		BEGIN TRANSACTION
		IF (@linserted > 0)
		BEGIN
			DECLARE Cursor_cr cursor FAST_FORWARD for
			select salesid, year(data_venda)
			from inserted
				    
			OPEN Cursor_cr;				
			FETCH NEXT FROM Cursor_cr into @id, @ano
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-------------- para cada linha inserida --------------
				exec GENERATE_SEQUENTIAL_NUMBER @ano, 0, 1, @num_gerado output;

				update sales
				set num_sequencial = @num_gerado
				where salesid = @id

				FETCH NEXT FROM Cursor_cr into @id, @ano
			END;

			CLOSE Cursor_cr;
			DEALLOCATE Cursor_cr;
		END

	COMMIT TRANSACTION; 
    END TRY

    BEGIN CATCH
		IF XACT_STATE() <> 0 OR @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
	END CATCH;
END;
GO