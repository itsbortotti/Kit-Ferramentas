CREATE FUNCTION [bpm].[f_mensagem_erro]
(
	@cd_erro	INT						,
	@cd_usuario	VARCHAR(50)				,
	@param1		VARCHAR(MAX)	=	NULL,
	@param2		VARCHAR(MAX)	=	NULL,
	@param3		VARCHAR(MAX)	=	NULL,
	@param4		VARCHAR(MAX)	=	NULL,
	@param5		VARCHAR(MAX)	=	NULL
)

RETURNS VARCHAR(MAX)

BEGIN

	DECLARE 
		@msg	VARCHAR(MAX)

	SELECT @cd_usuario = LTRIM(RTRIM(@cd_usuario))

	IF NOT EXISTS(SELECT TOP 1 1 FROM dina_usuario du WHERE LTRIM(RTRIM(du.Cd_usuario)) = @cd_usuario)
	BEGIN
	   SELECT @cd_usuario = 'dina'
	END

	SELECT 
		@msg = de.nm_erro
	FROM dina_erros de
	WHERE de.cd_erro = @cd_erro

	IF(ISNULL(LTRIM(RTRIM(@param1)),'') <> '')
	BEGIN
		SELECT @msg = REPLACE(@msg, '%1', @param1)
	END

	IF(ISNULL(LTRIM(RTRIM(@param2)),'') <> '')
	BEGIN
		SELECT @msg = REPLACE(@msg, '%2', @param2)
	END

	IF(ISNULL(LTRIM(RTRIM(@param3)),'') <> '')
	BEGIN
		SELECT @msg = REPLACE(@msg, '%3', @param3)
	END

	IF(ISNULL(LTRIM(RTRIM(@param4)),'') <> '')
	BEGIN
		SELECT @msg = REPLACE(@msg, '%4', @param4)
	END

	IF(ISNULL(LTRIM(RTRIM(@param5)),'') <> '')
	BEGIN
		SELECT @msg = REPLACE(@msg, '%5', @param5)
	END

	SELECT @msg = 'Código ' + CONVERT(VARCHAR(20),@cd_erro) + ': ' + ISNULL(@msg, '')

	RETURN @msg

END