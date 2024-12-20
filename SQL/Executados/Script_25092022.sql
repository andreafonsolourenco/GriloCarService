IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_ALTERA_MANUTENCAO]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_ALTERA_MANUTENCAO]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_ALTERA_MANUTENCAO](
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

	delete from USERS where USERSID = @id;

	set @ret = @id;
	set @retMsg = 'Utilizador eliminado com sucesso!';
END; 
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

	if(isnull(@admin, 0) = 0)
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
go


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[update_customer_from_csv_file]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[update_customer_from_csv_file]
END
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
				insert into CUSTOMERS(nome, morada, localidade, codpostal, email, telemovel, pais, notas, ctrldataupdt, ctrlcodopupdt)
				values(@nome, @morada, @localidade, @codpostal, @email, @telemovel, @pais, @notas, getdate(), @codOp)

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
				ctrlcodopupdt = @codOp,
				ctrldataupdt = getdate()
			where CUSTOMERSID = @id

			set @ret = @id;
			set @retMsg = 'Cliente atualizado com sucesso!';
		end
	end
	return;
END
go

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[CRIA_EDITA_CAR]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[CRIA_EDITA_CAR]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CRIA_EDITA_CAR](
	@idUser int,
	@id INT,
	@marca varchar(max),
	@modelo varchar(max),
	@ano int,
	@matricula varchar(20),
	@notas varchar(max),
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
			select top 1 @id = id from REPORT_CARS(null, @matricula)
		end

		if(isnull(@id, 0) <= 0)
		begin
			if(@fromCsvFile = 1)
			begin
				set @ret = -1;
				set @retMsg = 'Viatura não existente!';
				return;
			end
			else
			begin
				insert into CARS(marca, modelo, ano, matricula, criadoem, notas, ctrldata, ctrlcodop)
				values(@marca, @modelo, @ano, @matricula, getdate(), @notas, getdate(), @codOp)

				set @ret = SCOPE_IDENTITY();
				set @retMsg = 'Viatura ' + @matricula + ' inserida com sucesso!';
				return;
			end
		end
		else
		begin
			UPDATE CARS
				set marca = @marca,
				modelo = @modelo,
				ano = @ano,
				matricula = @matricula,
				notas = @notas,
				ctrlcodopupdt = @codOp,
				ctrldataupdt = getdate()
			where CARSID = @id

			set @ret = @id;
			set @retMsg = 'Viatura atualizada com sucesso!';
		end
	end
	return;
END
go


-- Report manutenções programadas
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
            cliente,
		    telemovel_cliente,
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
            cliente,
		    telemovel_cliente,
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
            cliente,
		    telemovel_cliente,
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
            cliente,
		    telemovel_cliente,
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
			raam.cliente,
			raam.telemovel_cliente,
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
			raams.cliente,
			raams.telemovel_cliente,
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
		cliente,
		telemovel_cliente,
		marca,
		modelo,
		matricula,
		mes
	from rep_prog_mes
	union
	select
		cliente,
		telemovel_cliente,
		marca,
		modelo,
		matricula,
		mes
	from rep_prog_mes_seguinte
)
GO


-- Report manutenções programadas
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
			'Nº de Reparações efetuadas em ' + DATENAME(MONTH, @date) as rodape2
		from report_maintenances(null, null, null, 1, 0)
		where YEAR(data_manutencao) = YEAR(@date)
		and MONTH(data_manutencao) = MONTH(@date)
	),
	manutencoes_este_mes as (
		select 
			count(matricula) as total3,
			DATENAME(MONTH, @date) as label3,
			'Nº de Reparações Programadas para ' + DATENAME(MONTH, @date) as rodape3
		from REPORT_MANUTENCOES_PROGRAMADAS_MES_MESSEGUINTE(null, null, @date)
		where mes = 0
	),
	manutencoes_mes_seguinte as (
		select 
			count(matricula) as total4,
			DATENAME(MONTH, DATEADD(month, 1, @date)) as label4,
			'Nº de Reparações Programadas para ' + DATENAME(MONTH, DATEADD(month, 1, @date)) as rodape4
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
