-- Report dados do dashboard
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_DASHBOARD_DATA]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_DASHBOARD_DATA]
END
GO

CREATE FUNCTION [dbo].[REPORT_DASHBOARD_DATA](@date date)
returns table as return
(
	with clientes as (
		select 
			count(nif) as total1,
			'Clientes' as label1,
			'Nº de Clientes' as rodape1
		from REPORT_CUSTOMERS(null, null, 1)
	),
	reparacoes_este_mes as (
		select 
			count(id) as total2,
			DATENAME(MONTH, @date) as label2,
			'Reparações Efetuadas' as rodape2
		from report_maintenances(null, null, null, 1, 0)
		where YEAR(data_manutencao) = YEAR(@date)
		and MONTH(data_manutencao) = MONTH(@date)
	),
	manutencoes_este_mes as (
		select 
			count(matricula) as total3,
			DATENAME(MONTH, @date) as label3,
			'Reparações Programadas' as rodape3
		from REPORT_MANUTENCOES_PROGRAMADAS_MES_MESSEGUINTE(null, null, @date)
		where mes = 0
	),
	manutencoes_mes_seguinte as (
		select 
			count(matricula) as total4,
			DATENAME(MONTH, DATEADD(month, 1, @date)) as label4,
			'Reparações Programadas' as rodape4
		from REPORT_MANUTENCOES_PROGRAMADAS_MES_MESSEGUINTE(null, null, @date)
		where mes = 1
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
		rodape3,

		label4,
		total4,
		rodape4
	from clientes
	inner join manutencoes_este_mes on 1=1
	inner join manutencoes_mes_seguinte on 1=1
	inner join reparacoes_este_mes on 1=1
)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[DELETE_USER]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[DELETE_USER]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_USER](
	@idUser int,
	@id int,
	@ret int OUTPUT,
	@retMsg varchar(max) output
)
AS BEGIN
	DECLARE @admin bit = (select administrador from REPORT_USERS(@idUser, null, null, 1, null))

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'O utilizador não tem permissões para apagar utilizadores!';
		return
	end

	IF(@id = @idUser)
	begin
		set @ret = -2;
		set @retMsg = 'O utilizador não se pode eliminar a ele próprio visto estar a usar o sistema! Por favor, contacte outro administrador!';
		return
	end

	delete from acessos where id_utilizador = @id;
	delete from USERS where USERSID = @id;

	set @ret = @id;
	set @retMsg = 'Utilizador eliminado com sucesso!';
END;
GO

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
		nif,
		pais
	from customers
	where (@id_customer is null or @id_customer = CUSTOMERSID)
	and (@nif is null or @nif = nif)
	and (@ativo is null or @ativo = ativo)
)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_CUSTOMER]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_CUSTOMER]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_CUSTOMER](
	@idUser int,
	@id INT,
	@nome varchar(max),
	@morada varchar(max),
	@localidade varchar(500),
	@codpostal varchar(20),
	@email varchar(max),
	@telemovel varchar(50),
	@nif varchar(10),
	@pais varchar(200),
	@notas varchar(max),
	@ativo bit,
	@fromCsvFile bit,
    @ret int OUTPUT,
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;

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
			select top 1 @id = id from REPORT_CUSTOMERS(null, @nif, 1)
		end

		if(isnull(@id, 0) <= 0)
		begin
			if(@fromCsvFile = 1)
			begin
				set @ret = -1;
				set @retMsg = 'Cliente não existente!';
				return;
			end
			else
			begin
				insert into CUSTOMERS(nome, morada, localidade, codpostal, email, telemovel, pais, notas, ativo, nif, ctrldataupdt, ctrlcodopupdt)
				values(@nome, @morada, @localidade, @codpostal, @email, @telemovel, @pais, @notas, @ativo, @nif, getdate(), @codOp)

				set @ret = SCOPE_IDENTITY();
				set @retMsg = 'Utilizador ' + @nome + ' inserido com sucesso!';
				return;
			end
		end
		else
		begin
			UPDATE CUSTOMERS
				set nome = @nome,
				morada = @morada,
				localidade = @localidade,
				codpostal = @codpostal,
				email = @email,
				telemovel = @telemovel,
				pais = @pais,
				notas = @notas,
				ativo = @ativo,
				nif = @nif,
				ctrlcodopupdt = @codOp,
				ctrldataupdt = getdate()
			where CUSTOMERSID = @id

			set @ret = @id;
			set @retMsg = 'Cliente atualizado com sucesso!';
		end
	end
	return;
END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[VALIDATE_USER_SESSION]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[VALIDATE_USER_SESSION]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VALIDATE_USER_SESSION](
	@id INT,
    @ret bit OUTPUT,
	@admin bit OUTPUT,
	@name varchar(max) OUTPUT
)
AS BEGIN
	DECLARE @u varchar(150);
    DECLARE @p varchar(60);
    DECLARE @ativo bit = 1;
    DECLARE @id_tipo int;
    DECLARE @sessaomax int = (select sessaomaxmin from report_configs());

    SELECT 
	    @ret = CASE WHEN DATEDIFF(mi, ut.lastlogin, getdate()) > @sessaomax then 0 else 1 end,
		@admin = administrador,
		@name = nome
    FROM report_users(@id, @u, @p, @ativo, @id_tipo) ut 
	return;
END
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[DELETE_CUSTOMER]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[DELETE_CUSTOMER]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_CUSTOMER](
	@idUser int,
	@id int,
	@ret int OUTPUT,
	@retMsg varchar(max) output
)
AS BEGIN
	DECLARE @admin bit = (select administrador from REPORT_USERS(@idUser, null, null, 1, null))

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'O utilizador não tem permissões para apagar clientes!';
		return
	end

	delete from MAINTENANCE where id_cliente = @id;
	delete from CUSTOMERS where CUSTOMERSID = @id;

	set @ret = @id;
	set @retMsg = 'Cliente eliminado com sucesso!';
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[DELETE_CAR]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[DELETE_CAR]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELETE_CAR](
	@idUser int,
	@id int,
	@ret int OUTPUT,
	@retMsg varchar(max) output
)
AS BEGIN
	DECLARE @admin bit = (select administrador from REPORT_USERS(@idUser, null, null, 1, null))

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'O utilizador não tem permissões para apagar viaturas!';
		return
	end

	delete from MAINTENANCE where id_viatura = @id;
	delete from CARS where CARSID = @id;

	set @ret = @id;
	set @retMsg = 'Viatura eliminada com sucesso!';
END;
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

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_UTILIZADOR]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_UTILIZADOR]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_UTILIZADOR](
	@idUser int,
	@id INT,
	@nome varchar(max),
	@codigo varchar(500),
	@email varchar(max),
	@telemovel varchar(50),
	@ativo bit,
	@password varchar(250),
	@notas varchar(max),
	@id_tipo int,
	@ret int OUTPUT,
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;

	select @codOp = codigo, @admin = administrador from REPORT_USERS(@idUser, null, null, 1, null)

	if(isnull(@admin, 0) = 0 and isnull(@idUser, 0) <> isnull(@id, 0))
	begin
		set @ret = -1;
		set @retMsg = 'Utilizador não tem permissões suficientes para efetuar a operação!';
		return
	end
	else
	begin
		if(isnull(@id, 0) <= 0)
		begin
			insert into users(nome, codigo, email, telemovel, ativo, criadoem, [password], notas, id_tipo_utilizador, ctrldata, ctrlcodop)
			values(@nome, @codigo, @email, @telemovel, @ativo, getdate(), @password, @notas, @id_tipo, getdate(), @codOp)

			set @ret = SCOPE_IDENTITY();
			set @retMsg = 'Utilizador ' + @codigo + ' inserido com sucesso!';
		end
		else
		begin
			update users
				set nome = @nome,
				codigo = @codigo,
				email = @email,
				telemovel = @telemovel,
				ativo = @ativo,
				[password] = @password,
				notas = @notas,
				id_tipo_utilizador = @id_tipo,
				ctrldataupdt = getdate(),
				ctrlcodopupdt = @codOp
			where usersid = @id

			set @ret = @id;
			set @retMsg = 'Utilizador ' + @codigo + ' atualizado com sucesso!';
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
	@customer bit,
	@car bit,
	@maintenance bit,
	@orcamento bit,
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	declare @newLine varchar(max) = '<br />';

	select @codOp = codigo, @admin = administrador from REPORT_USERS(@idUser, null, null, 1, null)

	if(@customer = 1)
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
			@notas = CASE ISNULL(notas, '') when '' then '' else CONCAT('<div class="col-md-12"><strong>Observações: </strong>', notas, '</div>') end
        from report_customers(@id, @nif, @ativo)

		set @retMsg = CONCAT('<div class="row">', @nome, @morada, @dadosFiscais, @contactos, @notas, '</div>');
		return;
	end

	if(@car = 1)
	begin
		declare @matricula varchar(20);
		declare @viatura varchar(max);
		declare @ano varchar(max);
		declare @placaMatricula varchar(max);
		declare @notasCar varchar(max);

        select
	        @viatura = CONCAT('<div class="col-md-12"><strong>Viatura: </strong>', marca, ' ', modelo, '</div>'),
			@ano = CONCAT('<div class="col-md-12"><strong>Matrícula: </strong>', matricula, '</div>'),
			@placaMatricula = CONCAT('<div class="col-md-12"><strong>Ano: </strong>', ano, '</div>'),
			@notas = CASE ISNULL(notas, '') when '' then '' else CONCAT('<div class="col-md-12"><strong>Observações: </strong>', notas, '</div>') end
        from REPORT_CARS(@id, @matricula)

		set @retMsg = CONCAT('<div class="row">', @viatura, @ano, @placaMatricula, @notas, @notas, '</div>');
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

	if(@maintenance = 1)
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
			end
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

		return;
	end

	if(@orcamento = 1)
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
			end
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

		return;
	end
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_ALTERA_MANUTENCAO]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_ALTERA_MANUTENCAO]
END

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_ALTERA_MANUTENCAO]') AND type IN ( N'P', N'PC' ))
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
	DECLARE @valorTotal DECIMAL(5,2);
	DECLARE @valorIVA DECIMAL(5,2);
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

	DECLARE @lines table 
	(   
		id int not null,
		descricao varchar(max) not null,
		valorsemiva decimal(5,2) not null,
		iva decimal(5,2) not null
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
	SELECT @idDoc = ID, @kms = KMS, @mecanica = MECANICA, @batechapas = BATECHAPAS, @revisao = REVISAO, 
		@docDate = [DATA], @docDescription = DESCRICAO, @valorTotal = VALORTOTAL, @valorIVA = VALORIVA, @orcamento = ORCAMENTO
	FROM OPENXML (@DocHandle, '/DOC',2)
	WITH (ID INT, KMS DECIMAL(10,2), MECANICA BIT, BATECHAPAS BIT, REVISAO BIT, [DATA] VARCHAR(MAX), DESCRICAO VARCHAR(MAX), VALORTOTAL DECIMAL(5,2), VALORIVA DECIMAL(5,2), ORCAMENTO BIT)

	SELECT @customerName = NOME, @customerAddress = MORADA, @customerZipCode = CODPOSTAL, @customerCity = LOCALIDADE, @customerNIF = NIF
	FROM OPENXML (@DocHandle, '/DOC/CLIENTE',2)
	WITH (NOME VARCHAR(MAX), MORADA VARCHAR(MAX), CODPOSTAL varchar(20), LOCALIDADE varchar(500), NIF varchar(10))

	SELECT @carBrand = MARCA, @carModel = MODELO, @carRegistration = MATRICULA, @carYear = ANO
	FROM OPENXML (@DocHandle, '/DOC/VIATURA',2)
	WITH (MARCA VARCHAR(MAX), MODELO VARCHAR(MAX), MATRICULA varchar(20), ANO int)
	
	INSERT INTO @lines(id, descricao, valorsemiva, iva)
	SELECT ID, DESCRICAO, VALORSEMIVA, IVA
	FROM OPENXML (@DocHandle, '/DOC/LINHAS/LINHA',2)
	WITH (ID INT, DESCRICAO VARCHAR(MAX), VALORSEMIVA DECIMAL(5,2), IVA DECIMAL(5,2))

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
	END
	ELSE
	BEGIN
		INSERT INTO MAINTENANCE(kms_viatura, mecanica, batechapas, revisao, data_manutencao, descricao, valortotal, valoriva, orcamento, id_viatura, id_cliente, ctrlcodop)
		values(@kms, @mecanica, @batechapas, @revisao, CAST(@docDate as date), @docDescription, @valorTotal, @valorIVA, @orcamento, @carID, @customerID, @codOp)

		set @idDoc = SCOPE_IDENTITY();
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