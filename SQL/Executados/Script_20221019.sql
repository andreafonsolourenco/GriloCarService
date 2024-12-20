IF COL_LENGTH('APPLICATION_CONFIG', 'url_nif') IS NULL
BEGIN
    ALTER TABLE APPLICATION_CONFIG
    ADD url_nif varchar(max) null
END
GO

IF COL_LENGTH('APPLICATION_CONFIG', 'nif_key') IS NULL
BEGIN
    ALTER TABLE APPLICATION_CONFIG
    ADD nif_key varchar(max) null
END
GO

IF COL_LENGTH('APPLICATION_CONFIG', 'url_nif') IS NOT NULL AND COL_LENGTH('APPLICATION_CONFIG', 'nif_key') IS NOT NULL
BEGIN
    UPDATE APPLICATION_CONFIG
	set url_nif = 'https://www.nif.pt/', nif_key = '929ab6a2d5500d11f10bd797d93b8264'
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
		nif_key
	from APPLICATION_CONFIG
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_MANUTENCOES_PROGRAMADAS_MES_MESSEGUINTE]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_MANUTENCOES_PROGRAMADAS_MES_MESSEGUINTE]
END
GO

CREATE FUNCTION [dbo].[REPORT_MANUTENCOES_PROGRAMADAS_MES_MESSEGUINTE](@id_cliente int, @id_viatura int, @date date)
returns table as return
(
    with rep_ano_anterior_mes as (
		select
			id_cliente,
            cliente,
		    telemovel_cliente,
			id_viatura,
		    marca,
		    modelo,
		    matricula
        from REPORT_MAINTENANCES(null, @id_cliente, @id_viatura, 1, 0)
        where YEAR(DATEADD(year, 1, data_manutencao)) = YEAR(@date)
		and MONTH(data_manutencao) = MONTH(@date)
		and revisao = 1
	),

	rep_ano_anterior_mes_seguinte as (
		select
			id_cliente,
            cliente,
		    telemovel_cliente,
			id_viatura,
		    marca,
		    modelo,
		    matricula
        from REPORT_MAINTENANCES(null, @id_cliente, @id_viatura, 1, 0)
        where YEAR(DATEADD(year, 1, data_manutencao)) = YEAR(@date)
		and MONTH(data_manutencao) = MONTH(DATEADD(month, 1, @date))
		and revisao = 1
	),

	rep_mes_anterior as (
		select
            id_cliente,
            cliente,
		    telemovel_cliente,
			id_viatura,
		    marca,
		    modelo,
		    matricula
        from REPORT_MAINTENANCES(null, @id_cliente, @id_viatura, 1, 0)
        where YEAR(data_manutencao) = YEAR(@date)
		and MONTH(data_manutencao) = MONTH(DATEADD(month, -1, @date))
		and revisao = 1
	),

	rep_mes as (
		select
            id_cliente,
            cliente,
		    telemovel_cliente,
			id_viatura,
		    marca,
		    modelo,
		    matricula
        from REPORT_MAINTENANCES(null, @id_cliente, @id_viatura, 1, 0)
        where YEAR(data_manutencao) = YEAR(@date)
		and MONTH(data_manutencao) = MONTH(@date)
		and revisao = 1
	),

	rep_prog_mes as (
		SELECT
			raam.id_cliente,
            raam.cliente,
		    raam.telemovel_cliente,
			raam.id_viatura,
			raam.marca,
			raam.modelo,
			raam.matricula,
			0 as mes
		FROM rep_ano_anterior_mes raam
		left join rep_mes_anterior rma on rma.matricula = raam.matricula
		left join rep_mes rm on rm.matricula = raam.matricula
		WHERE rma.matricula is null
		and rm.matricula is null
	),

	rep_prog_mes_seguinte as (
		SELECT
			raams.id_cliente,
            raams.cliente,
		    raams.telemovel_cliente,
			raams.id_viatura,
			raams.marca,
			raams.modelo,
			raams.matricula,
			1 as mes
		FROM rep_ano_anterior_mes_seguinte raams
		left join rep_mes_anterior rma on rma.matricula = raams.matricula
		left join rep_mes rm on rm.matricula = raams.matricula
		WHERE rma.matricula is null
		and rm.matricula is null
	)

	select
		id_cliente,
		cliente,
		telemovel_cliente,
		id_viatura,
		marca,
		modelo,
		matricula,
		mes
	from rep_prog_mes
	union
	select
		id_cliente,
		cliente,
		telemovel_cliente,
		id_viatura,
		marca,
		modelo,
		matricula,
		mes
	from rep_prog_mes_seguinte
)
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROVIDER]') AND type in (N'U'))
	DROP TABLE [dbo].[PROVIDER]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PROVIDER](
	[PROVIDERID] [int] IDENTITY(1,1) NOT NULL,
	[nome] [varchar](max) NOT NULL default '',
	[morada] [varchar](max) NOT NULL default '',
	[localidade] [varchar](500) NOT NULL default '',
	[codpostal] [varchar](20) NOT NULL default '',
	[iban] [varchar](500) NOT NULL DEFAULT '',
	[nif] [varchar](10) NOT NULL default '',
	[email] [varchar](max) NOT NULL default '',
	[ativo] [bit] NOT NULL DEFAULT 1,
	[notas] [varchar](max) NULL default '',
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_PROVIDER] PRIMARY KEY CLUSTERED 
(
	[PROVIDERID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_PROVIDER_NIF] UNIQUE NONCLUSTERED 
(
	nif ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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
		notas
	from [PROVIDER]
	where (@id_provider is null or @id_provider = providerid)
	and (@nif is null or @nif = nif)
)
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROVIDER_INVOICE]') AND type in (N'U'))
	DROP TABLE [dbo].[PROVIDER_INVOICE]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PROVIDER_INVOICE](
	[PROVIDER_INVOICEID] [int] IDENTITY(1,1) NOT NULL,
	[id_provider] int NOT NULL REFERENCES [PROVIDER] ([PROVIDERID]),
	[numero] [varchar](500) NOT NULL default '',
	[data_fatura] date not null default cast(getdate() as date),
	[data_vencimento] date not null default cast(dateadd(month, 1, getdate()) as date),
	[valor] decimal(10,2) not null default 0.0,
	[paga] bit not null default 0,
	[metodo_pagamento] varchar(max) null default '',
	[notas] [varchar](max) NULL default '',
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_PROVIDER_INVOICE] PRIMARY KEY CLUSTERED 
(
	[PROVIDER_INVOICEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_PROVIDER_INVOICE_ID_PROVIDER_NUMERO] UNIQUE NONCLUSTERED 
(
	id_provider ASC,
	numero ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROVIDER_INVOICE_FILE]') AND type in (N'U'))
	DROP TABLE [dbo].[PROVIDER_INVOICE_FILE]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PROVIDER_INVOICE_FILE](
	[PROVIDER_INVOICE_FILEID] [int] IDENTITY(1,1) NOT NULL,
	[id_provider_invoice] int NOT NULL REFERENCES [PROVIDER_INVOICE] ([PROVIDER_INVOICEID]),
	[file_path] varchar(max) null default '',
	[notas] [varchar](max) NULL default '',
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_PROVIDER_INVOICE_FILE] PRIMARY KEY CLUSTERED 
(
	[PROVIDER_INVOICE_FILEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY])
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


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[DELETE_PROVIDER]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[DELETE_PROVIDER]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_PROVIDER](
	@idUser int,
	@id int,
	@ret int OUTPUT,
	@retMsg varchar(max) output
)
AS BEGIN
	DECLARE @tipoLog varchar(200) = 'FORNECEDORES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	DECLARE @fornecedor varchar(max);

	select @admin = administrador, @codOp = codigo from REPORT_USERS(@idUser, null, null, 1, null)

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'O utilizador não tem permissões para apagar fornecedores!';
		return
	end

	select @fornecedor = nome from REPORT_PROVIDERS(@id, null)

	delete from PROVIDER_INVOICE_FILE where PROVIDER_INVOICE_FILEID in (select id from REPORT_PROVIDER_INVOICE_FILE(null, null, @id))
	delete from PROVIDER_INVOICE where provider_invoiceid in (select id from REPORT_PROVIDER_INVOICES(null, @id, null, null, null, null, null))
	delete from [PROVIDER] where providerid = @id;

	set @ret = @id;
	set @retMsg = 'Fornecedor eliminado com sucesso!';

	set @log = CONCAT('O utilizador ', @codOp, ' removeu o fornecedor ', @fornecedor, ' e consequentemente todas as suas faturas')

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[DELETE_PROVIDER_INVOICE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[DELETE_PROVIDER_INVOICE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_PROVIDER_INVOICE](
	@idUser int,
	@id int,
	@ret int OUTPUT,
	@retMsg varchar(max) output
)
AS BEGIN
	DECLARE @tipoLog varchar(200) = 'FATURAS FORNECEDORES';
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
		set @retMsg = 'O utilizador não tem permissões para apagar as faturas dos fornecedores!';
		return
	end

	select @numero = numero from REPORT_PROVIDER_INVOICES(@id, null, null, null, null, null, null)

	delete from PROVIDER_INVOICE_FILE where PROVIDER_INVOICE_FILEID in (select id from REPORT_PROVIDER_INVOICE_FILE(null, @id, null))
	delete from PROVIDER_INVOICE where PROVIDER_INVOICEID = @id;

	set @ret = @id;
	set @retMsg = 'Fatura do Fornecedor eliminada com sucesso!';

	set @log = CONCAT('O utilizador ', @codOp, ' removeu a fatura do fornecedor ', @numero, ' e consequentemente todos os seus ficheiros')

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[DELETE_PROVIDER_INVOICE_FILE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[DELETE_PROVIDER_INVOICE_FILE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_PROVIDER_INVOICE_FILE](
	@idUser int,
	@id int,
	@ret int OUTPUT,
	@retMsg varchar(max) output
)
AS BEGIN
	DECLARE @tipoLog varchar(200) = 'DOCS FATURAS FORNECEDORES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	DECLARE @file varchar(max);
	DECLARE @numero varchar(500);

	select @admin = administrador, @codOp = codigo from REPORT_USERS(@idUser, null, null, 1, null)

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'O utilizador não tem permissões para apagar os documentos das faturas dos fornecedores!';
		return
	end

	select @numero = numero, @file = file_path from REPORT_PROVIDER_INVOICE_FILE(@id, null, null)

	delete from PROVIDER_INVOICE_FILE where PROVIDER_INVOICE_FILEID = @id

	set @ret = @id;
	set @retMsg = 'Documento da Fatura do Fornecedor eliminado com sucesso!';

	set @log = CONCAT('O utilizador ', @codOp, ' removeu o documento ', @file, ' da fatura do fornecedor ', @numero)

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_PROVIDER]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_PROVIDER]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_PROVIDER](
	@idUser int,
	@id INT,
	@nome varchar(max),
	@morada varchar(max),
	@localidade varchar(500),
	@codpostal varchar(20),
	@iban varchar(500),
	@nif varchar(10),
	@email varchar(max),
	@ativo bit,
	@notas varchar(max),
	@fromCsvFile bit,
    @ret int OUTPUT,
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	DECLARE @tipoLog varchar(200) = 'FORNECEDORES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

	select @codOp = codigo, @admin = administrador from REPORT_USERS(@idUser, null, null, 1, null)

	if(isnull(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'Utilizador não tem permissões suficientes para efetuar a operação!';
		return
	end
	else
	begin
		if(@fromCsvFile = 1)
		begin
			select top 1 @id = id from REPORT_PROVIDERS(null, @nif)
		end

		if(isnull(@id, 0) <= 0)
		begin
			if(@fromCsvFile = 1)
			begin
				set @ret = -1;
				set @retMsg = 'Fornecedor não existente!';
				return;
			end
			else
			begin
				insert into [PROVIDER](nome, morada, localidade, codpostal, iban, nif, email, ativo, notas, ctrldataupdt, ctrlcodopupdt)
				values(@nome, @morada, @localidade, @codpostal, @iban, @nif, @email, @ativo, @notas, getdate(), @codOp)

				set @ret = SCOPE_IDENTITY();
				set @retMsg = 'Fornecedor ' + @nome + ' inserido com sucesso!';

				set @log = CONCAT('O utilizador ', @codOp, ' inseriu o fornecedor ', @nome)

				EXEC REGISTA_LOG @idUser, @ret, @tipoLog, @log, @retLog output, @retMsgLog output;
				return;
			end
		end
		else
		begin
			UPDATE [PROVIDER]
				set nome = @nome,
				morada = @morada,
				localidade = @localidade,
				codpostal = @codpostal,
				email = @email,
				iban = @iban,
				notas = @notas,
				ativo = @ativo,
				nif = @nif,
				ctrlcodopupdt = @codOp,
				ctrldataupdt = getdate()
			where PROVIDERID = @id

			set @ret = @id;
			set @retMsg = 'Fornecedor ' + @nome + ' atualizado com sucesso!';

			set @log = CONCAT('O utilizador ', @codOp, ' atualizou os dados do fornecedor ', @nome)

			EXEC REGISTA_LOG @idUser, @ret, @tipoLog, @log, @retLog output, @retMsgLog output;
		end
	end
	return;
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[GENERATE_VIEW_INFO]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[GENERATE_VIEW_INFO]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GENERATE_VIEW_INFO](
	@idUser int,
	@id INT,
	@tipoLog varchar(200),
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	declare @newLine varchar(max) = '<br />';
	declare @log varchar(max);
	declare @retLog int;
	declare @retMsgLog varchar(max);

	select @codOp = codigo, @admin = administrador from REPORT_USERS(@idUser, null, null, 1, null)

	if(@tipoLog = 'CLIENTES')
	begin
        declare @nif varchar(10);
        declare @ativo bit;
		declare @nome varchar(max);
		declare @morada varchar(max);
		declare @contactos varchar(max);
		declare @dadosFiscais varchar(max);
		declare @notas varchar(max);

        select
	        @nome = CONCAT('<div class="col-md-12"><strong>Nome: </strong>', nome, '</div>'), 
	        @morada = CONCAT('<div class="col-md-12"><strong>Morada: </strong>', morada, @newLine, codpostal, ' ', localidade, '</div>'),
			@contactos = CONCAT('<div class="col-md-12"><strong>Contactos', @newLine, 'Email: </strong>', email, @newLine, '<strong>Telemóvel: </strong>', telemovel, '</div>'),
			@dadosFiscais = CONCAT('<div class="col-md-12"><strong>NIF: </strong>', nif, ' ', pais, '</div>'),
			@notas = CASE ISNULL(notas, '') when '' then '' else CONCAT('<div class="col-md-12"><strong>Observações: </strong>', notas, '</div>') end,
			@log = CONCAT('O utilizador ', @codOp, ' visualizou os dados do cliente ', nome)
        from report_customers(@id, @nif, @ativo)

		set @retMsg = CONCAT('<div class="row">', @nome, @morada, @dadosFiscais, @contactos, @notas, '</div>');

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end

	if(@tipoLog = 'VIATURAS')
	begin
		declare @matricula varchar(20);
		declare @viatura varchar(max);
		declare @ano varchar(max);
		declare @placaMatricula varchar(max);
		declare @notasCar varchar(max);

        select
	        @viatura = CONCAT('<div class="col-md-12"><strong>Viatura: </strong>', marca, ' ', modelo, '</div>'),
			@placaMatricula = CONCAT('<div class="col-md-12"><strong>Matrícula: </strong>', matricula, '</div>'),
			@ano = CONCAT('<div class="col-md-12"><strong>Ano: </strong>', ano, '</div>'),
			@notas = CASE when ISNULL(notas, '') = '' then '' else CONCAT('<div class="col-md-12"><strong>Observações: </strong>', notas, '</div>') end,
			@log = CONCAT('O utilizador ', @codOp, ' visualizou os dados da viatura ', matricula)
        from REPORT_CARS(@id, @matricula)

		set @retMsg = CONCAT('<div class="row">', @viatura, @ano, @placaMatricula, @notas, '</div>');

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end

	declare @id_cliente int;
    declare @id_viatura int;
    declare @mecanica bit;
    declare @batechapas bit;
	declare @id_linha int;

	declare @cabecalho varchar(max)
	declare @dadosViatura varchar(max)
	declare @dadosReparacao varchar(max)
	declare @cabecalhoLinhasReparacao varchar(max)
	declare @linhasReparacao varchar(max)
	declare @valoresTotaisReparacao varchar(max)

	if(@tipoLog = 'REPARAÇÕES')
	begin
        select
			@cabecalho = CONCAT('<div class="row" style="font-size: 12px; text-align: left; margin-bottom: 10px;"><div class="col-md-4"><img src="../img/logo.png" style="width:100%; height: auto;" /></div><div class="col-md-8"><strong>', cliente, @newLine, morada_cliente, @newLine, 
				codpostal_cliente, ' ', localidade_cliente, @newLine, 'NIF: ', nif_cliente, @newLine, email_cliente, ' / ', telemovel_cliente, '</strong></div></div>'),
			@dadosViatura = CONCAT('<div class="row" style="font-size: 12px; margin-bottom: 10px;"><div class="col-md-6" style="text-align: left"><strong>', marca, ' ', modelo, '</strong></div>',
				'<div class="col-md-3"><strong>', matricula, '</strong></div>',
				'<div class="col-md-3" style="text-align: right"><strong>', kms_viatura, ' KMS</strong></div></div>'),
			@dadosReparacao = CONCAT('<div class="row" style="font-size: 12px; margin-bottom: 10px;"><div class="col-md-9" style="text-align: left"><strong>', descricao, '</strong></div>',
				'<div class="col-md-3" style="text-align: right"><strong>', data_manutencao_uk, '</strong></div></div>'),
			@cabecalhoLinhasReparacao = 
			case
				when @admin = 1 then '<div class="row" style="font-size: 12px; margin-bottom: 5px;"><div class="col-md-6"><strong>DESCRIÇÃO</strong></div><div class="col-md-3"><strong>VALOR S/ IVA</strong></div><div class="col-md-3"><strong>IVA</strong></div></div>'
				else '<div class="row" style="font-size: 12px;"><div class="col-md-12"><strong>DESCRIÇÃO</strong></div></div>'
			end,
			@log = CONCAT('O utilizador ', @codOp, ' visualizou os dados da reparação efetuada à viatura do cliente ', cliente, ' com a matrícula, ', matricula, ' no dia ', data_manutencao_uk)
        from REPORT_MAINTENANCES(@id, @id_cliente, @id_viatura, @mecanica, @batechapas)

		select
			@linhasReparacao = 
			case
				when @admin = 1 then CONCAT('<div class="row" style="font-size: 12px; margin-bottom: 10px;"><div class="col-md-6">', descricao_linha, '</div><div class="col-md-3">', valor, '€</div><div class="col-md-3">', iva, '%</div></div>')
				else CONCAT('<div class="row" style="font-size: 12px; text-align: left;"><div class="col-md-12">', descricao_linha, '</div></div>')
			end
		from REPORT_MAINTENANCE_LINES(@id_linha, @id)

		select
			@valoresTotaisReparacao = 
			case
				when @admin = 1 then CONCAT('<div class="row" style="font-size: 12px; margin-top: 10px;"><div class="col-md-12" style="text-align: left;"><div style="width: 50%; float: right; padding: 5px; border-radius: 10px; border: 1px solid #000";>Valor IVA: ', valoriva, '%', @newLine, 
					'Valor Total: ', valortotal, '€</div></div></div>')
				else ''
			end
        from REPORT_MAINTENANCES(@id, @id_cliente, @id_viatura, @mecanica, @batechapas)

		set @retMsg = CONCAT(@cabecalho, @dadosViatura, @dadosReparacao, @cabecalhoLinhasReparacao, @linhasReparacao, @valoresTotaisReparacao);

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end

	if(@tipoLog = 'ORÇAMENTOS')
	begin
		select
			@cabecalho = CONCAT('<div class="row" style="font-size: 12px; text-align: left; margin-bottom: 10px;"><div class="col-md-4"><img src="../img/logo.png" style="width:100%; height: auto;" /></div><div class="col-md-8"><strong>', cliente, @newLine, morada_cliente, @newLine, 
				codpostal_cliente, ' ', localidade_cliente, @newLine, 'NIF: ', nif_cliente, @newLine, email_cliente, ' / ', telemovel_cliente, '</strong></div></div>'),
			@dadosViatura = CONCAT('<div class="row" style="font-size: 12px; margin-bottom: 10px;"><div class="col-md-6" style="text-align: left"><strong>', marca, ' ', modelo, '</strong></div>',
				'<div class="col-md-3"><strong>', matricula, '</strong></div>',
				'<div class="col-md-3" style="text-align: right"><strong>', kms_viatura, ' KMS</strong></div></div>'),
			@dadosReparacao = CONCAT('<div class="row" style="font-size: 12px; margin-bottom: 10px;"><div class="col-md-9" style="text-align: left"><strong>', descricao, '</strong></div>',
				'<div class="col-md-3" style="text-align: right"><strong>', data_manutencao_uk, '</strong></div></div>'),
			@cabecalhoLinhasReparacao = 
			case
				when @admin = 1 then '<div class="row" style="font-size: 12px; margin-bottom: 5px;"><div class="col-md-6"><strong>DESCRIÇÃO</strong></div><div class="col-md-3"><strong>VALOR S/ IVA</strong></div><div class="col-md-3"><strong>IVA</strong></div></div>'
				else '<div class="row" style="font-size: 12px;"><div class="col-md-12"><strong>DESCRIÇÃO</strong></div></div>'
			end,
			@log = CONCAT('O utilizador ', @codOp, ' visualizou os dados do orçamento efetuado para a viatura do cliente ', cliente, ' com a matrícula, ', matricula, ' no dia ', data_manutencao_uk)
        from REPORT_ORCAMENTOS(@id, @id_cliente, @id_viatura, @mecanica, @batechapas)

		select
			@linhasReparacao = 
			case
				when @admin = 1 then CONCAT('<div class="row" style="font-size: 12px; margin-bottom: 10px;"><div class="col-md-6">', descricao_linha, '</div><div class="col-md-3">', valor, '€</div><div class="col-md-3">', iva, '%</div></div>')
				else CONCAT('<div class="row" style="font-size: 12px; text-align: left;"><div class="col-md-12">', descricao_linha, '</div></div>')
			end
		from REPORT_ORCAMENTO_LINES(@id_linha, @id)

		select
			@valoresTotaisReparacao = 
			case
				when @admin = 1 then CONCAT('<div class="row" style="font-size: 12px; margin-top: 10px;"><div class="col-md-12" style="text-align: left;"><div style="width: 50%; float: right; padding: 5px; border-radius: 10px; border: 1px solid #000";>Valor IVA: ', valoriva, '%', @newLine, 
					'Valor Total: ', valortotal, '€</div></div></div>')
				else ''
			end
        from REPORT_ORCAMENTOS(@id, @id_cliente, @id_viatura, @mecanica, @batechapas)

		set @retMsg = CONCAT(@cabecalho, @dadosViatura, @dadosReparacao, @cabecalhoLinhasReparacao, @linhasReparacao, @valoresTotaisReparacao);

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end

	if(@tipoLog = 'LOG')
	begin
		declare @tipo varchar(200)
		declare @id_relacionado int
		declare @initialDate date
		declare @finalDate date
		declare @userID int

		select
			@retMsg = CONCAT('<div class="row"><div class="col-md-6" style="text-align: left;"><strong>', data_log_uk, '</strong></div>',
				'<div class="col-md-6" style="text-align: right;"><strong>', tipo, '</strong></div></div>',
				'<div class="row"><div class="col-md-12"><strong>', name_user, ' (', code_user, '): ', notas, '</strong></div></div>'),
			@log = CONCAT('O utilizador ', @codOp, ' visualizou os dados do log referente ao utilizador ', code_user, ', do dia ', data_log_uk, ', do tipo ', tipo)
		from REPORT_LOGS(@id, @tipo, @id_relacionado, @initialDate, @finalDate, @userID)

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end

	if(@tipoLog = 'FORNECEDORES')
	begin
		declare @nif_provider varchar(10);
		declare @name_provider varchar(max);
		declare @address_provider varchar(max);
		declare @contacts_provider varchar(max);
		declare @fiscalData_provider varchar(max);
		declare @paymentData_provider varchar(max);
		declare @notes_provider varchar(max);

		select
			@name_provider = CONCAT('<div class="col-md-12"><strong>Nome: </strong>', nome, '</div>'), 
	        @address_provider = CONCAT('<div class="col-md-12"><strong>Morada: </strong>', morada, @newLine, codpostal, ' ', localidade, '</div>'),
			@contacts_provider = CONCAT('<div class="col-md-12"><strong>Email: </strong>', email, '</div>'),
			@fiscalData_provider = CONCAT('<div class="col-md-12"><strong>NIF: </strong>', nif, '</div>'),
			@paymentData_provider = CONCAT('<div class="col-md-12"><strong>IBAN: </strong>', iban, '</div>'),
			@notes_provider = CASE ISNULL(notas, '') when '' then '' else CONCAT('<div class="col-md-12"><strong>Observações: </strong>', notas, '</div>') end,
			@log = CONCAT('O utilizador ', @codOp, ' visualizou os dados do fornecedor ', nome)
		from REPORT_PROVIDERS(@id, @nif_provider)

		set @retMsg = CONCAT('<div class="row">', @name_provider, @address_provider, @fiscalData_provider, @paymentData_provider, @contacts_provider, @notes_provider, '</div>');

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end

	if(@tipoLog = 'FATURAS FORNECEDORES')
	begin
		declare @id_provider int;
		declare @invoice_number varchar(500);
		declare @date date;
		declare @cabecalho_invoice varchar(max);
		declare @invoice_data varchar(max);
		declare @invoice_paymentData varchar(max);
		declare @paid_invoice varchar(max);

		select
			@cabecalho_invoice = CONCAT('<div class="row" style="font-size: 12px; text-align: left; margin-bottom: 10px;"><div class="col-md-4"><img src="../img/logo.png" style="width:100%; height: auto;" /></div><div class="col-md-8"><strong>', name_provider, @newLine, address_provider, @newLine, 
				zipcode_provider, ' ', city_provider, @newLine, 'NIF: ', nif_provider, @newLine, 'IBAN: ', iban_provider, @newLine, email_provider, '</strong></div></div>'),
			@invoice_data = CONCAT('<div class="row" style="font-size: 12px; margin-bottom: 10px;"><div class="col-md-6" style="text-align: left"><strong>IBAN: ', iban_provider, '</strong></div>',
				'<div class="col-md-3" style="text-align: right"><strong>', data_fatura_uk, '</strong></div></div>'),
			@paid_invoice = 
			case
				when paga = 1 then CONCAT('Valor: ', valor, '€', @newLine, 'Paga: ', metodo_pagamento)
				else CONCAT('Valor: ', valor, '€', @newLine, 'Data de Vencimento: ', data_vencimento_uk)
			end,
			@invoice_paymentData = 
			case
				when @admin = 1 then CONCAT('<div class="row" style="font-size: 12px; margin-top: 10px;"><div class="col-md-12" style="text-align: left;"><div style="width: 50%; float: right; padding: 5px; border-radius: 10px; border: 1px solid #000";>', @paid_invoice, '</div></div></div>')
				else ''
			end,
			@log = CONCAT('O utilizador ', @codOp, ' visualizou os dados da fatura ', numero, ' do fornecedor ', name_provider)
        from REPORT_PROVIDER_INVOICES(@id, @id_provider, @invoice_number, @date, @date, @date, @date)

		set @retMsg = CONCAT(@cabecalho, @dadosViatura, @dadosReparacao, @cabecalhoLinhasReparacao, @linhasReparacao, @valoresTotaisReparacao);

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_PROVIDER_INVOICE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_PROVIDER_INVOICE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_PROVIDER_INVOICE](
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
	DECLARE @providerID int;
	DECLARE @providerName varchar(max);
	DECLARE @providerAddress varchar(max);
	DECLARE @providerCity varchar(500);
	DECLARE @providerZipCode varchar(20);
	DECLARE @providerIBAN varchar(500);
	DECLARE @providerNIF varchar(10);
	DECLARE @providerEmail varchar(max);
	DECLARE @providerNotes varchar(max);
	DECLARE @numero varchar(500);
	DECLARE @data_fatura date;
	DECLARE @data_vencimento date;
	DECLARE @valor decimal(10,2);
	DECLARE @notas varchar(max);

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

	-- START
	SET @XmlDocument=@DocXml;
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @DocXml;

	-- OBTEMOS AS LINHAS A TRATAR
	SELECT @idDoc = ID, @numero = NUMERO, @data_fatura = DATA, @data_vencimento = DATA_VENCIMENTO, @valor = VALOR, @notas = DESCRICAO
	FROM OPENXML (@DocHandle, '/FATURA',2)
	WITH (ID INT, NUMERO VARCHAR(500), [DATA] DATE, DATA_VENCIMENTO DATE, VALOR DECIMAL(10,2), DESCRICAO VARCHAR(MAX))

	SELECT @providerName = NOME, @providerAddress = MORADA, @providerZipCode = CODPOSTAL, @providerCity = LOCALIDADE, @providerNIF = NIF, @providerIBAN = IBAN, @providerEmail = EMAIL, @providerNotes = NOTES
	FROM OPENXML (@DocHandle, '/FATURA/FORNECEDOR',2)
	WITH (NOME VARCHAR(MAX), MORADA VARCHAR(MAX), CODPOSTAL varchar(20), LOCALIDADE varchar(500), NIF varchar(10), EMAIL varchar(max), NOTES varchar(max), IBAN varchar(500))

	select @providerID = id
	from REPORT_PROVIDERS(null, @providerNIF)

	IF(ISNULL(@providerID, 0) > 0)
	BEGIN
		UPDATE [PROVIDER]
			set nome = @providerName,
			morada = @providerAddress,
			codpostal = @providerZipCode,
			localidade = @providerCity,
			nif = @providerNIF,
			iban = @providerIBAN,
			email = @providerEmail,
			notas = @providerNotes,
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		where PROVIDERID = @providerID
	END
	ELSE
	BEGIN
		INSERT INTO [PROVIDER](nome, morada, codpostal, localidade, nif, iban, email, notas, ctrlcodop)
		VALUES(@providerName, @providerAddress, @providerZipCode, @providerCity, @providerNIF, @providerIBAN, @providerEmail, @providerNotes, @codOp)

		set @providerID = SCOPE_IDENTITY();
	END

	IF(ISNULL(@idDoc, 0) > 0)
	BEGIN
		UPDATE PROVIDER_INVOICE
			set id_provider = @providerID,
			numero = @numero,
			data_fatura = @data_fatura,
			data_vencimento = @data_vencimento,
			valor = @valor,
			notas = @notas,
			ctrlcodopupdt = @codOp,
			ctrldataupdt = getdate()
		WHERE PROVIDER_INVOICEID = @idDoc

		set @log = CONCAT('O utilizador ', @codOp, ' atualizou os dados do pagamento com o número ', @numero, ' ao fornecedor ', @providerName, ' do dia ', @data_fatura);

		EXEC REGISTA_LOG @id_op, @idDoc, @tipoLog, @log, @retLog output, @retMsgLog output;
	END
	ELSE
	BEGIN
		INSERT INTO PROVIDER_INVOICE(id_provider, numero, data_fatura, data_vencimento, valor, notas, ctrlcodop)
		values(@providerID, @numero, @data_fatura, @data_vencimento, @valor, @notas, @codOp)

		set @idDoc = SCOPE_IDENTITY();

		set @log = CONCAT('O utilizador ', @codOp, ' inseriu os dados do pagamento com o número ', @numero, ' ao fornecedor ', @providerName, ' do dia ', @data_fatura);

		EXEC REGISTA_LOG @id_op, @idDoc, @tipoLog, @log, @retLog output, @retMsgLog output;
	END

	SET @error = @idDoc;
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
			@log = CONCAT('O utilizador ', @codOp, ' atualizou o documento', @filename, ' referente ao pagamento com o número ', numero, ' ao fornecedor ', name_provider, ' do dia ', data_fatura_uk)
		from REPORT_PROVIDER_INVOICES(@id_invoice, null, null, null, null, null, null)

		EXEC REGISTA_LOG @id_op, @id_file, @tipoLog, @log, @retLog output, @retMsgLog output;
	END

	SET @error = @id_file;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[PAY_PROVIDER_INVOICE]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[PAY_PROVIDER_INVOICE]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PAY_PROVIDER_INVOICE](
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

	DECLARE @tipoLog varchar(200) = 'FATURAS FORNECEDORES';
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

	UPDATE PROVIDER_INVOICE
	set paga = 1,
	metodo_pagamento = @metodo_pagamento,
	ctrlcodopupdt = @codOp,
	ctrldataupdt = getdate()
	where PROVIDER_INVOICEID in (
		select id
		from @ids
	)
	and paga = 0

	select
		@log = CONCAT(@log, 'O utilizador ', @codOp, ' marcou a fatura ', numero, ' como paga;')
	from REPORT_PROVIDER_INVOICES(null, null, null, null, null, null, null) inv
	inner join @ids ids on ids.id = inv.id

	EXEC REGISTA_LOG @id_op, null, @tipoLog, @log, @retLog output, @retMsgLog output;

	SET @error = 0;
	SET @errorMsg = 'Operação realizada com sucesso!';
	
	return
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[GENERATE_PROVIDER_INVOICE_PAYMENT_DATA]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[GENERATE_PROVIDER_INVOICE_PAYMENT_DATA]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GENERATE_PROVIDER_INVOICE_PAYMENT_DATA](
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

	DECLARE @tipoLog varchar(200) = 'FATURAS FORNECEDORES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @strToReplace varchar(max);
	DECLARE @tmp varchar(max);

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
	INSERT INTO @ids(id)
	SELECT ID
	FROM OPENXML (@DocHandle, '/PAGAMENTOS/FATURAS',2)
	WITH (ID INT)

	select
		@errorMsg = CONCAT(@errorMsg, '<div class="row"><div class="col-md-6" style="font-weight: bold; text-align: left">', inv.name_provider, '<br />NIF: ', inv.nif_provider, '</div><div class="col-md-6" style="font-weight: bold; text-align: center">', LTRIM(RTRIM(STR(SUM(inv.valor)))), '€<br />', inv.iban_provider, '</div></div>')
	from REPORT_PROVIDER_INVOICES(null, null, null, null, null, null, null) inv
	inner join @ids ids on ids.id = inv.id
	where inv.paga = 0
	group by inv.name_provider, inv.iban_provider, inv.nif_provider

	select
		@log = CONCAT(@log, 'O utilizador ', @codOp, ' gerou os dados de pagamento da fatura ', numero, '; ')
	from REPORT_PROVIDER_INVOICES(null, null, null, null, null, null, null) inv
	inner join @ids ids on ids.id = inv.id
	where inv.paga = 0

	EXEC REGISTA_LOG @id_op, null, @tipoLog, @log, @retLog output, @retMsgLog output;

	SET @error = 0;
	
	return
END;
GO
