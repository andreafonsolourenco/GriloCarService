-- Tipos de Utilizador
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USERTYPE]') AND type in (N'U'))
DROP TABLE [dbo].[USERTYPE]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[USERTYPE](
	[USERTYPEID] [int] IDENTITY(1,1) NOT NULL,
	[nome] [varchar](500) NOT NULL DEFAULT '',
	[notas] [varchar](500) NOT NULL DEFAULT '',
	[administrador] [bit] NOT NULL DEFAULT 0,
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
  CONSTRAINT [PK_USERTYPE] PRIMARY KEY CLUSTERED 
(
	[USERTYPEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_USERTYPE_NOME] UNIQUE NONCLUSTERED 
(
	nome ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
GO

INSERT INTO USERTYPE(nome, notas, administrador)
VALUES('Administrador', '', 1)

INSERT INTO USERTYPE(nome, notas, administrador)
VALUES('Default User', '', 0)



-- Configurações Gerais
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[APPLICATION_CONFIG]') AND type in (N'U'))
DROP TABLE [dbo].[APPLICATION_CONFIG]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[APPLICATION_CONFIG](
	[APPLICATION_CONFIGID] [int] IDENTITY(1,1) NOT NULL,
	[email] [varchar](500) NULL,
	[email_password] [varchar](250) NULL,
	[email_smtp] [varchar](150) NULL,
	[email_smtpport] [varchar](20) NULL,
	[emails_alerta] [varchar](max) NOT NULL DEFAULT '',
	[sessaomaxmin] int NOT NULL DEFAULT 30,
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_APPLICATION_CONFIG] PRIMARY KEY CLUSTERED 
(
	[APPLICATION_CONFIGID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

INSERT INTO APPLICATION_CONFIG(email, email_password, email_smtp, email_smtpport, emails_alerta, sessaomaxmin)
VALUES('grilocarservice22@gmail.com', 'grilocarservice', 'smtp.gmail.com', '465', 'afonsopereira6@gmail.com', 600)


-- Utilizadores
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USERS]') AND type in (N'U'))
DROP TABLE [dbo].[USERS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[USERS](
	[USERSID] [int] IDENTITY(1,1) NOT NULL,
	[nome] [varchar](max) NOT NULL default '',
	[codigo] [varchar](500) NOT NULL DEFAULT '',
	[email] [varchar](max) NULL default '',
	[telemovel] [varchar](50) NULL default '',
	[ativo] [bit] NOT NULL DEFAULT 1,
	[criadoem] [datetime] NOT NULL DEFAULT GETDATE(),
	[password] [varchar](250) NULL default '*',
	[notas] [varchar](max) NULL default '',
	[lastlogin] [datetime] NULL,
	[id_tipo_utilizador] [int] NOT NULL REFERENCES [USERTYPE] ([USERTYPEID]),
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_USERS] PRIMARY KEY CLUSTERED 
(
	[USERSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_USERS_CODIGO] UNIQUE NONCLUSTERED 
(
	codigo ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

INSERT INTO USERS(nome, codigo, email, telemovel, ativo, criadoem, password, notas, id_tipo_utilizador)
select 'André Lourenço', 'AL', 'afonsopereira6@gmail.com', '912803666', 1, getdate(), 'ALiceCFMG77', '', USERTYPEID
from [USERTYPE]
where administrador = 1

INSERT INTO USERS(nome, codigo, email, telemovel, ativo, criadoem, password, notas, id_tipo_utilizador)
select 'Cátia Grilo', 'CG', 'catiagrilo_14@hotmail.com', '918334093', 1, getdate(), 'amorproprio1990', '', USERTYPEID
from [USERTYPE]
where administrador = 1

INSERT INTO USERS(nome, codigo, email, telemovel, ativo, criadoem, password, notas, id_tipo_utilizador)
select 'Agostinho Grilo', 'AMG', 'amgcarservice22@gmail.com', '917043976', 1, getdate(), 'amgcarservice', '', USERTYPEID
from [USERTYPE]
where administrador = 1

INSERT INTO USERS(nome, codigo, email, telemovel, ativo, criadoem, password, notas, id_tipo_utilizador)
select 'Alice Grilo', 'ALice', 'kk31@outlook.com', '918334093', 1, getdate(), 'ALice', '', USERTYPEID
from [USERTYPE]
where administrador = 0
and nome = 'Default User'


-- Acessos
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ACESSOS]') AND type in (N'U'))
DROP TABLE [dbo].[ACESSOS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ACESSOS](
	[ACESSOSID] [int] IDENTITY(1,1) NOT NULL,
	[id_utilizador] [int] NOT NULL REFERENCES USERS (USERSID),
	[datahora] [datetime] NOT NULL DEFAULT GETDATE(),
	[tipo] [varchar](50) NOT NULL DEFAULT 'LOGIN',
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_ACESSOS] PRIMARY KEY CLUSTERED 
(
	[ACESSOSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
CONSTRAINT [IX_ACESSOS_USER_DATE_TYPE] UNIQUE NONCLUSTERED 
(
	id_utilizador ASC,
	datahora ASC,
	tipo ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
GO


-- Report tipos de utilizador
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_USERTYPE]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_USERTYPE]
END
GO

CREATE FUNCTION [dbo].[REPORT_USERTYPE](@id_tipo int)
returns table as return
(
    SELECT
		USERTYPEID as id,
		nome,
		notas,
		administrador,
		ctrldata,
		ctrlcodop,
		ctrldataupdt,
		ctrlcodopupdt
    FROM USERTYPE
    WHERE (@id_tipo is null or @id_tipo = USERTYPEID)
)
GO


-- Report utilizadores
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_USERS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_USERS]
END
GO

CREATE FUNCTION [dbo].[REPORT_USERS](@id_user int, @username varchar(500), @password varchar(250), @ativo bit, @id_tipo int)
returns table as return
(
	select
		u.usersid as id,
		u.nome,
		u.codigo,
		u.email,
		u.telemovel,
		u.ativo,
		u.criadoem,
		u.password,
		u.notas,
		u.lastlogin,
		ut.id as id_tipo,
		ut.nome as tipo,
		ut.administrador,
		u.ctrldata,
		u.ctrlcodop,
		u.ctrldataupdt,
		u.ctrlcodopupdt
	from users u
	inner join REPORT_USERTYPE(@id_tipo) as ut on ut.id = id_tipo_utilizador
	where (@id_user is null or @id_user = USERSID)
	and (@username is null or @username = u.codigo)
	and (@password is null or @password = u.password)
	and (@ativo is null or @ativo = u.ativo)
	and (@id_tipo is null or @id_tipo = u.id_tipo_utilizador)
)
GO


-- SP para efetuar login
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[login]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[login]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[login](
	@user varchar(150),
	@pass varchar(60),
    @ret int OUTPUT,
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	declare @id int;
	declare @ativo bit;
	declare @id_tipo int;
	declare @dataatual datetime;

	select top 1
		@id = id,
		@ativo = ativo
	from REPORT_USERS(@id, @user, @pass, @ativo, @id_tipo)

	IF (@id is not null)
		BEGIN
			IF (@ativo = 1)
				begin
					set @dataatual = getdate()
					set @ret = @id;
					set @retMsg = 'Login efetuado com sucesso!'

					UPDATE USERS SET lastlogin = @dataatual WHERE USERSID = @id;
					INSERT INTO ACESSOS (id_utilizador, datahora) SELECT @id, @dataatual;
				end
			ELSE
				begin
					set @ret = -1;
					set @retMsg = 'Utilizador Inativo!' + CHAR(13) + CHAR(10) + 'Para mais informações, por favor contacte o administrador do sistema!';
				end
		END
	ELSE 
		BEGIN
			set @ret = -2;
			set @retMsg = 'Dados de autenticação inválidos!';
		END

	RETURN;
END;
GO


-- Report utilizadores
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
		sessaomaxmin
	from APPLICATION_CONFIG
)
GO


-- Clientes
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CUSTOMERS]') AND type in (N'U'))
DROP TABLE [dbo].[CUSTOMERS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CUSTOMERS](
	[CUSTOMERSID] [int] IDENTITY(1,1) NOT NULL,
	[nome] [varchar](max) NOT NULL default '',
	morada varchar(max) not null default '',
	localidade varchar(500) not null default '',
	codpostal varchar(20) not null default 'xxxx-xxx',
	[email] [varchar](max) NULL default '',
	[telemovel] [varchar](50) NULL default '',
	[ativo] [bit] NOT NULL DEFAULT 1,
	[criadoem] [datetime] NOT NULL DEFAULT GETDATE(),
	[notas] [varchar](max) NULL default '',
	nif varchar(10) not null default 'xxxxxxxxx',
	pais varchar(200) not null default 'Portugal',
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_CUSTOMERS] PRIMARY KEY CLUSTERED 
(
	[CUSTOMERSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_CUSTOMERS_NIF] UNIQUE NONCLUSTERED 
(
	nif ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


INSERT INTO CUSTOMERS(nome, morada, localidade, codpostal, email, telemovel, nif)
values('André Afonso Pinto Pereira Lourenço', 'Largo da Ermida, 14, 1', 'Freixofeira (Turcifal)', '2565-773', 'afonsopereira6@gmail.com', '912803666', '223730440')


INSERT INTO CUSTOMERS(nome, morada, localidade, codpostal, email, telemovel, nif)
values('Cátia Fernandes Monteiro Grilo', 'Rua Mestre de Avis, 1A, 3º Esq', 'Porto de Mós', '2480-339', 'catiagrilo_14@hotmail.com', '918334093', '225432056')


-- Report clientes
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_CUSTOMERS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_CUSTOMERS]
END
GO

CREATE FUNCTION [dbo].[REPORT_CUSTOMERS](@id_customer int, @nif varchar(10), @ativo bit)
returns table as return
(
	select
		customersid as id,
		nome,
		morada,
		localidade,
		codpostal,
		email,
		telemovel,
		ativo,
		criadoem,
		notas,
		nif
	from customers
	where (@id_customer is null or @id_customer = CUSTOMERSID)
	and (@nif is null or @nif = nif)
	and (@ativo is null or @ativo = ativo)
)
GO


-- Viaturas
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CARS]') AND type in (N'U'))
DROP TABLE [dbo].[CARS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CARS](
	[CARSID] [int] IDENTITY(1,1) NOT NULL,
	marca varchar(max) not null default '',
	modelo varchar(max) not null default '',
	ano int not null default 2022,
	matricula varchar(20) not null default 'XX-KK-XX',
	[criadoem] [datetime] NOT NULL DEFAULT GETDATE(),
	[notas] [varchar](max) NULL default '',
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_CARS] PRIMARY KEY CLUSTERED 
(
	[CARSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_CARS_MATRICULA] UNIQUE NONCLUSTERED 
(
	matricula ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


INSERT INTO CARS(marca, modelo, ano, matricula)
values('Opel', 'Insignia Sports Tourer 2.0 CDTI', 2014, '06-UU-54')

INSERT INTO CARS(marca, modelo, ano, matricula)
values('Seat', 'Ibiza I-Tech 1.6 TDI', 2014, '16-PV-45')


-- Report clientes
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_CARS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_CARS]
END
GO

CREATE FUNCTION [dbo].[REPORT_CARS](@id_car int, @matricula varchar(20))
returns table as return
(
	select
		CARSID as id,
		marca,
		modelo,
		ano,
		matricula,
		notas
	from cars
	where (@id_car is null or @id_car = CARSID)
	and (@matricula is null or @matricula = matricula)
)
GO


-- Manutenções
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MAINTENANCE]') AND type in (N'U'))
DROP TABLE [dbo].[MAINTENANCE]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MAINTENANCE](
	[MAINTENANCEID] [int] IDENTITY(1,1) NOT NULL,
	id_cliente int not null references customers (customersid),
	id_viatura int not null references cars (carsid),
	data_manutencao datetime not null default getdate(),
	descricao varchar(max) not null default '',
	mecanica bit not null default 1,
	batechapas bit not null default 0,
	valortotal decimal(5,2) not null default 0.00,
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_MAINTENANCE] PRIMARY KEY CLUSTERED 
(
	[MAINTENANCEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
 CONSTRAINT [IX_MAINTENANCE_CLIENTE_VIATURA_DATA_MECANICA_BATECHAPAS] UNIQUE NONCLUSTERED 
(
	id_cliente ASC,
	id_viatura ASC,
	data_manutencao ASC,
	mecanica ASC,
	batechapas ASC,
	valortotal asc
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

IF COL_LENGTH('MAINTENANCE', 'revisao') IS NULL
BEGIN
    ALTER TABLE MAINTENANCE
	ADD revisao bit not null default 0;
END

INSERT INTO MAINTENANCE(id_cliente, id_viatura, data_manutencao, descricao, mecanica, batechapas, valortotal, revisao)
select cust.id, car.id, dateadd(year, -1, getdate()), 'Revisão', 1, 0, 150.00, 1
from REPORT_CUSTOMERS(null, '223730440', 1) cust
inner join REPORT_CARS(null, '06-UU-54') car on 1=1

INSERT INTO MAINTENANCE(id_cliente, id_viatura, data_manutencao, descricao, mecanica, batechapas, valortotal, revisao)
select cust.id, car.id, dateadd(month, 1, dateadd(year, -1, getdate())), 'Revisão', 1, 0, 100.00, 1
from REPORT_CUSTOMERS(null, '225432056', 1) cust
inner join REPORT_CARS(null, '16-PV-45') car on 1=1


-- Report manutenções
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
		maint.data_manutencao,
		maint.descricao,
		maint.mecanica,
		maint.batechapas,
		maint.valortotal,
		maint.revisao
	from MAINTENANCE maint
	inner join REPORT_CUSTOMERS(@id_cliente, null, null) cust on cust.id = maint.id_cliente
	inner join REPORT_CARS(@id_viatura, null) cars on cars.id = maint.id_viatura
	where (@id_maintenance is null or @id_maintenance = MAINTENANCEID)
	and (@id_cliente is null or @id_cliente = id_cliente)
	and (@id_viatura is null or @id_viatura = id_viatura)
	and (@mecanica is null or @mecanica = mecanica)
	and (@batechapas is null or @batechapas = batechapas)
)
GO


-- Report dados do dashboard
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_DASHBOARD_DATA]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_DASHBOARD_DATA]
END
GO

CREATE FUNCTION [dbo].[REPORT_DASHBOARD_DATA](@ano int, @mesatual int, @messeguinte int)
returns table as return
(
	with clientes as (
		select 
			count(nif) as total1,
			'Clientes' as label1,
			'Nº de Clientes' as rodape1
		from REPORT_CUSTOMERS(null, null, 1)
	),
	manutencoes_este_mes as (
		select 
			count(id) as total2,
			'Este mês' as label2,
			'Nº de Reparações Programadas este mês' as rodape2
		from report_maintenances(null, null, null, 1, 0)
		where YEAR(DATEADD(year, 1, data_manutencao)) = @ano
		and MONTH(data_manutencao) = @mesatual
		and revisao = 1
	),
	manutencoes_mes_seguinte as (
		select 
			count(id) as total3,
			'Próximo mês' as label3,
			'Nº de Reparações Programadas no próximo mês' as rodape3
		from report_maintenances(null, null, null, 1, 0)
		where YEAR(DATEADD(year, 1, data_manutencao)) = @ano
		and MONTH(data_manutencao) = @messeguinte
		and revisao = 1
	)

	SELECT 
		label1,
		total1,
		rodape1,

		label2,
		total2,
		rodape2,

		label3,
		total3,
		rodape3
	from clientes
	inner join manutencoes_este_mes on 1=1
	inner join manutencoes_mes_seguinte on 1=1
)
GO


-- Report dados do gráfico do dashboard
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_GRAPHIC_DATA]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_GRAPHIC_DATA]
END
GO

CREATE FUNCTION [dbo].[REPORT_GRAPHIC_DATA]()
returns table as return
(
	with reparacoes_hoje as (
		select 
			count(id) as hoje
		from report_maintenances(null, null, null, null, null)
		where CAST(data_manutencao as date) = CAST(getdate() as date)
	),
	mecanica_mes as (
		select 
			count(id) as mecanica_mes
		from report_maintenances(null, null, null, 1, 0)
		where MONTH(data_manutencao) = MONTH(getdate())
		and YEAR(data_manutencao) = YEAR(getdate())
	),
	batechapas_mes as (
		select 
			count(id) as batechapas_mes
		from report_maintenances(null, null, null, 0, 1)
		where MONTH(data_manutencao) = MONTH(getdate())
		and YEAR(data_manutencao) = YEAR(getdate())
	)

	SELECT 
		hoje,
		mecanica_mes,
		batechapas_mes
	from reparacoes_hoje
	inner join mecanica_mes on 1=1
	inner join batechapas_mes on 1=1
)
GO


-- SP para efetuar update aos clientes carregados por um ficheiro csv já existentes
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[update_customer_from_csv_file]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[update_customer_from_csv_file]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[update_customer_from_csv_file](
	@userid int,
	@nome varchar(max),
	@morada varchar(max),
	@localidade varchar(500),
	@codpostal varchar(20),
	@email varchar(max),
	@telemovel varchar(50),
	@nif varchar(10),
	@pais varchar(200),
    @ret int OUTPUT,
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	declare @admin bit;
	declare @ativo bit;
	declare @codUser varchar(500);
	declare @idCustomer int;

	select top 1
		@admin = administrador,
		@ativo = ativo,
		@codUser = codigo
	from REPORT_USERS(@userid, null, null, @ativo, null)

	select top 1
		@idCustomer = id
	from REPORT_CUSTOMERS(@idCustomer, @nif, null)

	if(@ativo = 0 OR @admin = 0)
	begin
		set @ret = -1;
		set @retMsg = 'Dados de autenticação inválidos!';
		return;
	end

	if(@idCustomer is not null)
	begin
		UPDATE CUSTOMERS
			set nome = @nome,
			morada = @morada,
			localidade = @localidade,
			codpostal = @codpostal,
			email = @email,
			telemovel = @telemovel,
			pais = @pais,
			ctrlcodopupdt = @codUser,
			ctrldataupdt = getdate()
		where CUSTOMERSID = @idCustomer

		set @ret = @idCustomer;
		set @retMsg = 'Cliente atualizado com sucesso!';
	end
	else
	begin
		set @ret = 0;
		set @retMsg = 'Cliente não existente!';
	end

	RETURN;
END;
GO
