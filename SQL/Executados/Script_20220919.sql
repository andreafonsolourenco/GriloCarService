IF COL_LENGTH('MAINTENANCE', 'kms_viatura') IS NULL
BEGIN
    ALTER TABLE MAINTENANCE
	ADD kms_viatura decimal(10,2) not null default 0.00
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
		maint.valoriva,
		maint.kms_viatura
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
		maint.valoriva,
		maint.kms_viatura
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