IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[LOG]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LOG](
	[LOGID] [int] IDENTITY(1,1) NOT NULL,
	[id_user] [int] NOT NULL REFERENCES [USERS] ([USERSID]), 
	[id_relacionado] [int] NULL,
	[tipo] [varchar](200) NOT NULL DEFAULT '',
	[notas] [varchar](max) NOT NULL DEFAULT '',
	[ctrldata] [datetime] NOT NULL DEFAULT getdate(),
	[ctrlcodop] [varchar](500) NOT NULL DEFAULT 'AL',
	[ctrldataupdt] [datetime] NULL,
	[ctrlcodopupdt] [varchar](500) NULL,
 CONSTRAINT [PK_LOG] PRIMARY KEY CLUSTERED 
(
	[LOGID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_LOG_TIPO_IDRELACIONADO_DATA] UNIQUE NONCLUSTERED 
(
	[id_user] ASC,
	[tipo] ASC,
	[id_relacionado] ASC,
	[ctrldata] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REGISTA_LOG]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[REGISTA_LOG]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REGISTA_LOG](
	@idUser int,
	@id INT,
	@tipo varchar(200),
	@texto varchar(max),
	@ret int OUTPUT,
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	DECLARE @codOp varchar(500);

	select @codOp = codigo from REPORT_USERS(@idUser, null, null, 1, null)

	INSERT INTO [LOG](id_user, id_relacionado, tipo, notas, ctrlcodop)
	VALUES(@idUser, @id, @tipo, @texto, @codOp)

	set @ret = SCOPE_IDENTITY();
	set @retMsg = 'Log registado com sucesso!';

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
	@logs bit,
    @retMsg VARCHAR(max) OUTPUT
)
AS BEGIN
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	declare @newLine varchar(max) = '<br />';
	declare @log varchar(max);
	declare @tipoLog varchar(200);
	declare @retLog int;
	declare @retMsgLog varchar(max);

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
		set @tipoLog = 'CLIENTES';

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

	if(@car = 1)
	begin
		declare @matricula varchar(20);
		declare @viatura varchar(max);
		declare @ano varchar(max);
		declare @placaMatricula varchar(max);
		declare @notasCar varchar(max);
		set @tipoLog = 'VIATURAS';

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

	if(@maintenance = 1)
	begin
		set @tipoLog = 'REPARAÇÕES';

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

	if(@orcamento = 1)
	begin
		set @tipoLog = 'ORÇAMENTOS';

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

	if(@logs = 1)
	begin
		declare @tipo varchar(200)
		declare @id_relacionado int
		declare @initialDate date
		declare @finalDate date
		declare @userID int
		set @tipoLog = 'LOG';

		select
			@retMsg = CONCAT('<div class="row"><div class="col-md-6" style="text-align: left;"><strong>', data_log_uk, '</strong></div>',
				'<div class="col-md-6" style="text-align: right;"><strong>', tipo, '</strong></div></div>',
				'<div class="row"><div class="col-md-12"><strong>', name_user, ' (', code_user, '): ', notas, '</strong></div></div>'),
			@log = CONCAT('O utilizador ', @codOp, ' visualizou os dados do log referente ao utilizador ', code_user, ', do dia ', data_log_uk, ', do tipo ', tipo)
		from REPORT_LOGS(@id, @tipo, @id_relacionado, @initialDate, @finalDate, @userID)

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end
END
GO


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
	DECLARE @tipoLog varchar(200) = 'VIATURAS';
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
			select top 1 @id = id from REPORT_CARS(null, @matricula)
		end

		if(isnull(@id, 0) <= 0)
		begin
			if(@fromCsvFile = 1)
			begin
				set @ret = -1;
				set @retMsg = 'Viatura não existente!';
			end
			else
			begin
				insert into CARS(marca, modelo, ano, matricula, criadoem, notas, ctrldata, ctrlcodop)
				values(@marca, @modelo, @ano, @matricula, getdate(), @notas, getdate(), @codOp)

				set @ret = SCOPE_IDENTITY();
				set @retMsg = 'Viatura ' + @matricula + ' inserida com sucesso!';

				set @log = CONCAT('O utilizador ', @codOp, ' inseriu a viatura ', @matricula)

				EXEC REGISTA_LOG @idUser, @ret, @tipoLog, @log, @retLog output, @retMsgLog output;

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

			set @log = CONCAT('O utilizador ', @codOp, ' atualizou os dados da viatura ', @matricula)

			EXEC REGISTA_LOG @idUser, @ret, @tipoLog, @log, @retLog output, @retMsgLog output;
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
	DECLARE @tipoLog varchar(200) = 'SESSÃO';
	DECLARE @log varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

    SELECT 
	    @ret = CASE WHEN DATEDIFF(mi, ut.lastlogin, getdate()) > @sessaomax then 0 else 1 end,
		@admin = administrador,
		@name = nome,
		@codOp = codigo
    FROM report_users(@id, @u, @p, @ativo, @id_tipo) ut 

	if(@sessaomax = 0)
	begin
		set @log = CONCAT('O utilizador ', @codOp, ' perdeu a sessão')

		EXEC REGISTA_LOG @id, null, @tipoLog, @log, @retLog output, @retMsgLog output;
	end

	return;
END
GO


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
	DECLARE @tipoLog varchar(200) = 'LOGIN';
	DECLARE @log varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @idAcesso int;

	select top 1
		@id = id,
		@ativo = ativo,
		@codOp = codigo
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

					set @idAcesso = SCOPE_IDENTITY();

					set @log = CONCAT('O utilizador ', @codOp, ' efetuou login no sistema')

					EXEC REGISTA_LOG @id, @idAcesso, @tipoLog, @log, @retLog output, @retMsgLog output;
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
	DECLARE @tipoLog varchar(200) = 'UTILIZADORES';
	DECLARE @log varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @admin bit;
	DECLARE @codUser varchar(max);
	
	select @admin = administrador, @codOp = codigo from REPORT_USERS(@idUser, null, null, 1, null)

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

	select @codUser = codigo from REPORT_USERS(@id, null, null, null, null)

	delete from acessos where id_utilizador = @id;
	delete from USERS where USERSID = @id;

	set @ret = @id;
	set @retMsg = 'Utilizador eliminado com sucesso!';

	set @log = CONCAT('O utilizador ', @codOp, ' removeu o utilizador ', @codUser, ' e consequentemente todos os seus acessos')

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
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
	DECLARE @tipoLog varchar(200) = 'CLIENTES';
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
				set @retMsg = 'Cliente ' + @nome + ' inserido com sucesso!';

				set @log = CONCAT('O utilizador ', @codOp, ' inseriu o cliente ', @nome)

				EXEC REGISTA_LOG @idUser, @ret, @tipoLog, @log, @retLog output, @retMsgLog output;
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
			set @retMsg = 'Cliente ' + @nome + ' atualizado com sucesso!';

			set @log = CONCAT('O utilizador ', @codOp, ' atualizou os dados do cliente ', @nome)

			EXEC REGISTA_LOG @idUser, @ret, @tipoLog, @log, @retLog output, @retMsgLog output;
		end
	end
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
	DECLARE @tipoLog varchar(200) = 'CLIENTES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	DECLARE @customer varchar(max);

	select @admin = administrador, @codOp = codigo from REPORT_USERS(@idUser, null, null, 1, null)

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'O utilizador não tem permissões para apagar clientes!';
		return
	end

	select @customer = nome from REPORT_CUSTOMERS(@id, null, null)

	delete from MAINTENANCE where id_cliente = @id;
	delete from CUSTOMERS where CUSTOMERSID = @id;

	set @ret = @id;
	set @retMsg = 'Cliente eliminado com sucesso!';

	set @log = CONCAT('O utilizador ', @codOp, ' removeu o cliente ', @customer, ' e consequentemente todas as suas reparações e orçamentos')

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
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
	DECLARE @tipoLog varchar(200) = 'VIATURAS';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	DECLARE @matricula varchar(20);

	select @admin = administrador, @codOp = codigo from REPORT_USERS(@idUser, null, null, 1, null)

	IF(ISNULL(@admin, 0) = 0)
	begin
		set @ret = -1;
		set @retMsg = 'O utilizador não tem permissões para apagar viaturas!';
		return
	end

	select @matricula = matricula from REPORT_CARS(@id, null)

	delete from MAINTENANCE where id_viatura = @id;
	delete from CARS where CARSID = @id;

	set @ret = @id;
	set @retMsg = 'Viatura eliminada com sucesso!';

	set @log = CONCAT('O utilizador ', @codOp, ' removeu a viatura ', @matricula, ' e consequentemente todas as suas reparações e orçamentos')

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
	RETURN
END;
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

	DECLARE @tipoLog varchar(200);
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);

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
		INSERT INTO MAINTENANCE(kms_viatura, mecanica, batechapas, revisao, lg.ctrldata, descricao, valortotal, valoriva, orcamento, id_viatura, id_cliente, ctrlcodop)
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
	DECLARE @tipoLog varchar(200) = 'UTILIZADORES';
	DECLARE @log varchar(max);
	DECLARE @retLog int;
	DECLARE @retMsgLog varchar(max);
	DECLARE @matricula varchar(20);

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

			set @log = CONCAT('O utilizador ', @codOp, ' inseriu os dados do utilizador ', @codigo)
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

			set @log = CONCAT('O utilizador ', @codOp, ' atualizou os dados do utilizador ', @codigo)
		end
	end

	EXEC REGISTA_LOG @idUser, @ret, @tipoLog, @log, @retLog output, @retMsgLog output;

	return;
END
GO

-- Report logs
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[REPORT_LOGS]') AND xtype IN (N'FN', N'IF', N'TF'))
BEGIN
    DROP FUNCTION [dbo].[REPORT_LOGS]
END
GO

CREATE FUNCTION [dbo].[REPORT_LOGS](@id int, @tipo varchar(200), @id_relacionado int, @initialDate date, @finalDate date, @idUser int)
returns table as return
(
	with lgn as (
		select
			lg.LOGID as id,
			users.id as id_user,
			users.nome as name_user,
			users.codigo as code_user,
			lg.tipo as tipo,
			lg.notas as notas,
			lg.id_relacionado as id_relacionado,
			lg.ctrldata as data_log,
			CONCAT(convert(varchar, lg.ctrldata, 105), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_it, --dd-mm-yyyy
			CONCAT(convert(varchar, lg.ctrldata, 103), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_uk, --dd/mm/yyyy
			CONCAT(convert(varchar, lg.ctrldata, 111), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_jp, --yyyy/mm/dd
			convert(varchar, lg.ctrldata, 120) as data_log_odbc --yyyy-mm-dd
		from [LOG] lg
		inner join REPORT_USERS(null, null, null, null, null) users on users.id = lg.id_user
		left join ACESSOS ac on ac.ACESSOSID = lg.id_relacionado
	),
	clientes as (
		select
			lg.LOGID as id,
			users.id as id_user,
			users.nome as name_user,
			users.codigo as code_user,
			lg.tipo as tipo,
			lg.notas as notas,
			lg.id_relacionado as id_relacionado,
			lg.ctrldata as data_log,
			CONCAT(convert(varchar, lg.ctrldata, 105), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_it, --dd-mm-yyyy
			CONCAT(convert(varchar, lg.ctrldata, 103), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_uk, --dd/mm/yyyy
			CONCAT(convert(varchar, lg.ctrldata, 111), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_jp, --yyyy/mm/dd
			convert(varchar, lg.ctrldata, 120) as data_log_odbc --yyyy-mm-dd
		from [LOG] lg
		inner join REPORT_USERS(null, null, null, null, null) users on users.id = lg.id_user
		left join REPORT_CUSTOMERS(@id, null, null) cust on cust.id = lg.id_relacionado
	),
	viaturas as (
		select
			lg.LOGID as id,
			users.id as id_user,
			users.nome as name_user,
			users.codigo as code_user,
			lg.tipo as tipo,
			lg.notas as notas,
			lg.id_relacionado as id_relacionado,
			lg.ctrldata as data_log,
			CONCAT(convert(varchar, lg.ctrldata, 105), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_it, --dd-mm-yyyy
			CONCAT(convert(varchar, lg.ctrldata, 103), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_uk, --dd/mm/yyyy
			CONCAT(convert(varchar, lg.ctrldata, 111), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_jp, --yyyy/mm/dd
			convert(varchar, lg.ctrldata, 120) as data_log_odbc --yyyy-mm-dd
		from [LOG] lg
		inner join REPORT_USERS(null, null, null, null, null) users on users.id = lg.id_user
		left join REPORT_CARS(@id, null) cars on cars.id = lg.id_relacionado
	),
	reparacoes as (
		select
			lg.LOGID as id,
			users.id as id_user,
			users.nome as name_user,
			users.codigo as code_user,
			lg.tipo as tipo,
			lg.notas as notas,
			lg.id_relacionado as id_relacionado,
			lg.ctrldata as data_log,
			CONCAT(convert(varchar, lg.ctrldata, 105), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_it, --dd-mm-yyyy
			CONCAT(convert(varchar, lg.ctrldata, 103), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_uk, --dd/mm/yyyy
			CONCAT(convert(varchar, lg.ctrldata, 111), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_jp, --yyyy/mm/dd
			convert(varchar, lg.ctrldata, 120) as data_log_odbc --yyyy-mm-dd
		from [LOG] lg
		inner join REPORT_USERS(null, null, null, null, null) users on users.id = lg.id_user
		left join REPORT_MAINTENANCES(@id, null, null, null, null) rep on rep.id = lg.id_relacionado
	),
	orcamentos as (
		select
			lg.LOGID as id,
			users.id as id_user,
			users.nome as name_user,
			users.codigo as code_user,
			lg.tipo as tipo,
			lg.notas as notas,
			lg.id_relacionado as id_relacionado,
			lg.ctrldata as data_log,
			CONCAT(convert(varchar, lg.ctrldata, 105), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_it, --dd-mm-yyyy
			CONCAT(convert(varchar, lg.ctrldata, 103), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_uk, --dd/mm/yyyy
			CONCAT(convert(varchar, lg.ctrldata, 111), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_jp, --yyyy/mm/dd
			convert(varchar, lg.ctrldata, 120) as data_log_odbc --yyyy-mm-dd
		from [LOG] lg
		inner join REPORT_USERS(null, null, null, null, null) users on users.id = lg.id_user
		left join REPORT_ORCAMENTOS(@id, null, null, null, null) rep on rep.id = lg.id_relacionado
	),
	rest as (
		select
			lg.LOGID as id,
			users.id as id_user,
			users.nome as name_user,
			users.codigo as code_user,
			lg.tipo as tipo,
			lg.notas as notas,
			lg.id_relacionado as id_relacionado,
			lg.ctrldata as data_log,
			CONCAT(convert(varchar, lg.ctrldata, 105), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_it, --dd-mm-yyyy
			CONCAT(convert(varchar, lg.ctrldata, 103), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_uk, --dd/mm/yyyy
			CONCAT(convert(varchar, lg.ctrldata, 111), ' ', convert(varchar, lg.ctrldata, 108)) as data_log_jp, --yyyy/mm/dd
			convert(varchar, lg.ctrldata, 120) as data_log_odbc --yyyy-mm-dd
		from [LOG] lg
		inner join REPORT_USERS(null, null, null, null, null) users on users.id = lg.id_user
		left join lgn on lgn.id = lg.LOGID
		left join clientes cli on cli.id = lg.LOGID
		left join viaturas viat on viat.id = lg.LOGID
		left join reparacoes rep on rep.id = lg.LOGID
		left join orcamentos orcam on orcam.id = lg.LOGID
		where lgn.id is null
		and cli.id is null
		and viat.id is null
		and rep.id is null
		and orcam.id is null
	),
	all_logs as (
		select
			id,
			id_user,
			name_user,
			code_user,
			tipo,
			notas,
			id_relacionado,
			data_log,
			data_log_it, --dd-mm-yyyy
			data_log_uk, --dd/mm/yyyy
			data_log_jp, --yyyy/mm/dd
			data_log_odbc --yyyy-mm-dd
		from lgn
		union
		select
			id,
			id_user,
			name_user,
			code_user,
			tipo,
			notas,
			id_relacionado,
			data_log,
			data_log_it, --dd-mm-yyyy
			data_log_uk, --dd/mm/yyyy
			data_log_jp, --yyyy/mm/dd
			data_log_odbc --yyyy-mm-dd
		from clientes
		union
		select
			id,
			id_user,
			name_user,
			code_user,
			tipo,
			notas,
			id_relacionado,
			data_log,
			data_log_it, --dd-mm-yyyy
			data_log_uk, --dd/mm/yyyy
			data_log_jp, --yyyy/mm/dd
			data_log_odbc --yyyy-mm-dd
		from viaturas
		union
		select
			id,
			id_user,
			name_user,
			code_user,
			tipo,
			notas,
			id_relacionado,
			data_log,
			data_log_it, --dd-mm-yyyy
			data_log_uk, --dd/mm/yyyy
			data_log_jp, --yyyy/mm/dd
			data_log_odbc --yyyy-mm-dd
		from reparacoes
		union
		select
			id,
			id_user,
			name_user,
			code_user,
			tipo,
			notas,
			id_relacionado,
			data_log,
			data_log_it, --dd-mm-yyyy
			data_log_uk, --dd/mm/yyyy
			data_log_jp, --yyyy/mm/dd
			data_log_odbc --yyyy-mm-dd
		from orcamentos
		union
		select
			id,
			id_user,
			name_user,
			code_user,
			tipo,
			notas,
			id_relacionado,
			data_log,
			data_log_it, --dd-mm-yyyy
			data_log_uk, --dd/mm/yyyy
			data_log_jp, --yyyy/mm/dd
			data_log_odbc --yyyy-mm-dd
		from rest
	)

	select
		id,
		id_user,
		name_user,
		code_user,
		tipo,
		notas,
		id_relacionado,
		data_log,
		data_log_it, --dd-mm-yyyy
		data_log_uk, --dd/mm/yyyy
		data_log_jp, --yyyy/mm/dd
		data_log_odbc --yyyy-mm-dd
	from all_logs
	where (@id is null or @id = id)
	and (@tipo is null or @tipo = tipo)
	and (@id_relacionado is null or @id_relacionado = id_relacionado)
	and (@initialDate is null or @initialDate <= cast(data_log as date))
	and (@finalDate is null or @finalDate >= cast(data_log as date))
	and (@idUser is null or @idUser = id_user)
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
			@log = CONCAT('O utilizador ', @codOp, ' eliminiu o orçamento efetuado no dia ', data_manutencao_uk, ' para o cliente ',  cliente, ' e viatura ', matricula)
		from REPORT_ORCAMENTOS(@id, null, null, null, null)
	end
	else
	begin
		set @typeText = 'Reparação';
		select
			@log = CONCAT('O utilizador ', @codOp, ' eliminiu o orçamento efetuado no dia ', data_manutencao_uk, ' para o cliente ',  cliente, ' e viatura ', matricula)
		from REPORT_MAINTENANCES(@id, null, null, null, null)
	end

	delete from MAINTENANCE_LINES where id_manutencao = @id;
	delete from MAINTENANCE where MAINTENANCEID = @id;

	set @ret = @id;
	set @retMsg = CONCAT(@typeText, ' eliminado com sucesso!');

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[GENERATE_ORCAMENTO]') AND type IN ( N'P', N'PC' ))
BEGIN
    DROP PROCEDURE [dbo].[GENERATE_ORCAMENTO]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GENERATE_ORCAMENTO](
	@idUser int,
	@id INT,
	@customer varchar(max) output,
	@description varchar(max) output,
	@date varchar(max) output,
	@car varchar(max) output,
	@kms varchar(max) output,
	@lines varchar(max) output,
	@total varchar(max) output
)
AS BEGIN
	DECLARE @codOp varchar(500);
	DECLARE @admin bit;
	declare @log varchar(max);
	declare @tipoLog varchar(200) = 'ORÇAMENTOS';
	declare @retLog int;
	declare @retMsgLog varchar(max);

	select @codOp = codigo, @admin = administrador from REPORT_USERS(@idUser, null, null, 1, null)

	if(@admin = 1)
	begin
		select
			@customer = CONCAT(cliente, '<br />', morada_cliente, '<br />', codpostal_cliente, ' ', localidade_cliente, '<br />NIF: ', nif_cliente), 
			@description = descricao,
			@date = data_manutencao_uk,
			@car = CONCAT(marca, ' ', modelo, ' (', matricula, ')'),
			@kms = CONCAT(STR(kms_viatura), ' kms'),
			@total = CONCAT('Valor IVA: ', STR(valoriva), '€<br />Valor Total: ', STR(valortotal), '€'),
			@log = CONCAT('O utilizador ', @codOp, ' gerou o orçamento em pdf da viatura do cliente ', cliente, ' com a matrícula, ', matricula, ' no dia ', data_manutencao_uk)
        from REPORT_ORCAMENTOS(@id, null, null, null, null)

		SELECT
			@lines = CONCAT(ISNULL(@lines, ''), '<tr><td style="width: 75%;"><div class="contentEditableContainer contentTextEditable"><div class="contentEditable" style="text-align: left;"><p style="font-size:13px">', 
				descricao_linha, '</p></div></div></td><td style="width: 25%;"><div class="contentEditableContainer contentTextEditable"><div class="contentEditable" style="text-align: right;"><p style="font-size:13px">', valor, ' €</p></div></div></td></tr>')
		from REPORT_ORCAMENTO_LINES(null, @id)

		EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;

		return;
	end
END
GO