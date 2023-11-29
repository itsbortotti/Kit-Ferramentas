
------------------------------------------------------------------------------------------------------------- 
--INICIO/ DECLARA VARIAVEIS 
-------------------------------------------------------------------------------------------------------------
USE SEGCORP
GO

BEGIN TRAN--ROLLBACK

DECLARE
@cd_usuario				VARCHAR(20)		= 'T02348',
@cd_proposta			INT				= 0057791,		
@id_sub					INT				= 1567500,
@dt_proposta 			SMALLDATETIME	= getdate(),
@dt_movimento			SMALLDATETIME,
@cd_retorno				INT,
@nm_retorno				VARCHAR(250),
@id_endosso				INT


SELECT @dt_movimento = isnull (Dt_movimento_contabil,GETDATE()) FROM corp_modulo WHERE Id_modulo = 5
 ------------------------------------------------------------------------------------------------------------- 
--TABELAS DE LOG
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#log_processamentoEndosso') IS NOT NULL DROP TABLE #log_processamentoEndosso
CREATE TABLE #log_processamentoEndosso (cd_proposta INT, id_endosso INT, cd_retorno INT, nm_retorno VARCHAR(255), nm_processo VARCHAR(20))

IF OBJECT_ID('tempdb..#log_processamentoConsiste') IS NOT NULL DROP TABLE #log_processamentoConsiste
CREATE TABLE #log_processamentoConsiste (cd_proposta INT, id_endosso INT, cd_retorno INT, nm_retorno VARCHAR(255), nm_processo VARCHAR(20))

IF OBJECT_ID('tempdb..#log_processamentoCalcula') IS NOT NULL DROP TABLE #log_processamentoCalcula
CREATE TABLE #log_processamentoCalcula (cd_proposta INT, id_endosso INT, cd_retorno INT, nm_retorno VARCHAR(255), nm_processo VARCHAR(20))

IF OBJECT_ID('tempdb..#log_processamentoGerarEndosso') IS NOT NULL DROP TABLE #log_processamentoGerarEndosso
CREATE TABLE #log_processamentoGerarEndosso (cd_proposta INT, id_endosso INT, cd_retorno INT, nm_retorno VARCHAR(255), nm_processo VARCHAR(20))

--CRIA ENDOSSO PARA A PROPOSTA
--------------------------------------------------------------------------------------------------------------
		 EXEC corpsp_emi_inserir_endosso
		      @cd_tipo_endosso          		= 6,--PROPOSTA
			  @id_sub						    = @id_sub,
			  @id_endosso						= @id_endosso OUTPUT,
		      @dt_proposta                   	= @dt_movimento,
			  @dv_copia_endosso_anterior		= 1,
			  @cd_proposta						= @cd_proposta,
			  @cd_usuario				        = @cd_usuario,
		      @cd_retorno               		= @cd_retorno OUTPUT,
		      @nm_retorno               		= @nm_retorno OUTPUT 

	INSERT INTO #log_processamentoEndosso VALUES (@cd_proposta, @id_endosso, @cd_retorno, @nm_retorno, 'INSERIR ENDOSSO')
	SET @cd_retorno = NULL
	SET	@nm_retorno = NULL

	SELECT * FROM #log_processamentoEndosso			 --WHERE cd_retorno <> 0

------------------------------------------------------------------------------------------------------------- 
-- CONSISTE 
--------------------------------------------------------------------------------------------------------------

	EXEC corpsp_consistir_proposta
			@id_endosso = @id_endosso,
			@cd_usuario = @cd_usuario,
			@cd_retorno = @cd_retorno OUTPUT,
			@nm_retorno = @nm_retorno OUTPUT

	INSERT INTO #log_processamentoConsiste VALUES (@cd_proposta, @id_endosso, @cd_retorno, @nm_retorno, 'CONSISTE')
	SET @cd_retorno = NULL
    SET	@nm_retorno = NULL

	SELECT * FROM #log_processamentoConsiste		 --WHERE cd_retorno <> 0
 ------------------------------------------------------------------------------------------------------------- 
-- CALCULA PREMIO 
--------------------------------------------------------------------------------------------------------------
	EXEC corpsp_alterar_valores_endosso
			@id_endosso					= @id_endosso,
			@vl_tarifario				= 0.00,			
			@vl_desconto				= 0.00,
			@vl_custo					= 0.00,
			@vl_agravo					= 0.00,
			@vl_adicional				= 0.00,
			@vl_comissao				= 0.00,
			@dv_premio_calculo_manual	= 0,
			@cd_usuario					= @cd_usuario,
			@cd_retorno					= @cd_retorno OUTPUT,
			@nm_retorno					= @nm_retorno OUTPUT

	INSERT INTO #log_processamentoCalcula  VALUES (@cd_proposta, @id_endosso, @cd_retorno, @nm_retorno, 'CALCULA PREMIO')
	SET @cd_retorno = NULL
	SET	@nm_retorno = NULL

	SELECT * FROM #log_processamentoCalcula			 --WHERE cd_retorno <> 0

------------------------------------------------------------------------------------------------------------- 
--EMITIR ENDOSSO
--------------------------------------------------------------------------------------------------------------
	UPDATE corp_endosso 
	SET dv_libera_ocorrencias = 1
	WHERE Id_endosso = @id_endosso

	EXEC corpsp_emi_gerar_endosso
			@id_endosso	= @id_endosso,
			@cd_usuario	= @cd_usuario,
			@cd_retorno	= @cd_retorno OUTPUT,
			@nm_retorno	= @nm_retorno OUTPUT

	INSERT INTO #log_processamentoGerarEndosso  VALUES (@cd_proposta, @id_endosso, @cd_retorno, @nm_retorno, 'GERAR ENDOSSO')
	SET @cd_retorno = NULL
	SET	@nm_retorno = NULL

	SELECT * FROM #log_processamentoGerarEndosso	 --WHERE cd_retorno <> 0


------------------------------------------------------------------------------------------------------------------------------------------------
