
BEGIN TRAN

DECLARE @nm_retorno		VARCHAR(255),
		@cd_retorno		INT

EXEC dbo.corpsp_emi_apolice_batch
		@id_modulo					= NULL,
		@id_faturamento_batch		= 296392, --295029,
		@job						= 1,
		@cd_retorno					= @cd_retorno OUTPUT,
		@nm_retorno					= @nm_retorno OUTPUT

SELECT @cd_retorno, @nm_retorno

SELECT * FROM sdk_debug
DELETE sdk_debug

