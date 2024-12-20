IF COL_LENGTH('MAINTENANCE', 'valoriva') IS NULL
BEGIN
    ALTER TABLE MAINTENANCE
	ADD valoriva decimal(5,2) not null default 0.00
END

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
		maint.revisao,
		maint.valoriva
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

-- Report orçamentos
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
		maint.data_manutencao,
		maint.descricao,
		maint.mecanica,
		maint.batechapas,
		maint.valortotal,
		maint.revisao,
		maint.valoriva
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

-- Manutenções Linhas
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MAINTENANCE_LINES]') AND type in (N'U'))
DROP TABLE [dbo].[MAINTENANCE_LINES]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MAINTENANCE_LINES](
	[MAINTENANCE_LINESID] [int] IDENTITY(1,1) NOT NULL,
	id_manutencao int not null references maintenance (maintenanceid),
	descricao varchar(max) not null default '',
	valor decimal(5,2) not null default 0.00,
	iva decimal(5,2) not null default 0.00,
	[ctrldata] datetime not null default GETDATE(),
	[ctrlcodop] [varchar](500) not null default 'AL',
	[ctrldataupdt] datetime null,
	[ctrlcodopupdt] [varchar](500) null,
 CONSTRAINT [PK_MAINTENANCE_LINES] PRIMARY KEY CLUSTERED 
(
	[MAINTENANCE_LINESID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY])
GO

-- Report maintenance lines
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_MAINTENANCE_LINES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_MAINTENANCE_LINES]
END
GO

CREATE FUNCTION [dbo].[REPORT_MAINTENANCE_LINES](@id_linha int, @id_manutencao int)
returns table as return
(
	select
		lines.MAINTENANCE_LINESID as id_linha,
		maint.id as id_manutencao,
		lines.descricao as descricao_linha,
		lines.valor as valor,
		lines.iva as iva
	from MAINTENANCE_LINES lines
	inner join REPORT_MAINTENANCES(@id_manutencao, null, null, null, null) maint on maint.id = lines.id_manutencao
	where (@id_manutencao is null or @id_manutencao = lines.id_manutencao)
	and (@id_linha is null or @id_linha = lines.MAINTENANCE_LINESID)
)
GO


-- Report orçamento lines
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_ORCAMENTO_LINES]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_ORCAMENTO_LINES]
END
GO

CREATE FUNCTION [dbo].[REPORT_ORCAMENTO_LINES](@id_linha int, @id_orcamento int)
returns table as return
(
	select
		lines.MAINTENANCE_LINESID as id_linha,
		orcam.id as id_orcamento,
		lines.descricao as descricao_linha,
		lines.valor as valor,
		lines.iva as iva
	from MAINTENANCE_LINES lines
	inner join REPORT_ORCAMENTOS(@id_orcamento, null, null, null, null) orcam on orcam.id = lines.id_manutencao
	where (@id_orcamento is null or @id_orcamento = lines.id_manutencao)
	and (@id_linha is null or @id_linha = lines.MAINTENANCE_LINESID)
)
GO