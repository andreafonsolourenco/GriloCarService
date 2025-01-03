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

	delete from MAINTENANCE_LINES where id_manutencao in (select MAINTENANCEID from MAINTENANCE where id_cliente = @id)
	delete from MAINTENANCE where id_cliente = @id;
	delete from CUSTOMERS where CUSTOMERSID = @id;

	set @ret = @id;
	set @retMsg = 'Cliente eliminado com sucesso!';

	set @log = CONCAT('O utilizador ', @codOp, ' removeu o cliente ', @customer, ' e consequentemente todas as suas reparações e orçamentos')

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
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
			@log = CONCAT('O utilizador ', @codOp, ' eliminou a reparação efetuada no dia ', data_manutencao_uk, ' para o cliente ',  cliente, ' e viatura ', matricula)
		from REPORT_MAINTENANCES(@id, null, null, null, null)
	end

	delete from MAINTENANCE_LINES where id_manutencao = @id;
	delete from MAINTENANCE where MAINTENANCEID = @id;

	set @ret = @id;
	set @retMsg = CONCAT(@typeText, ' eliminado com sucesso!');

	EXEC REGISTA_LOG @idUser, @id, @tipoLog, @log, @retLog output, @retMsgLog output;
END;
GO



