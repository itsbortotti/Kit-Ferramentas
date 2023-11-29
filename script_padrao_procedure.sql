IF EXISTS(SELECT TOP 1 1 FROM dbo.SYSOBJECTS 
		  WHERE id = OBJECT_ID(N'[bpm].[p_exemplo_procedure_modelo_incluir]') 
						and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [bpm].[p_exemplo_procedure_modelo_incluir]
GO

CREATE PROCEDURE [bpm].[p_exemplo_procedure_modelo_incluir]
(	
	@cd_usuario			VARCHAR(50)		=	NULL,
	@cd_retorno			INT			=	NULL OUTPUT,
	@nm_retorno			VARCHAR(3000)		=	NULL OUTPUT,
	@nr_versao_proc			VARCHAR(15)		=	NULL OUTPUT
)   
/*  	
	|CRIADOR					: Paulo Roberto da Silva
	|DATA DE CRIAÇÃO				: 02/2022
	|OBJETIVO					: Procedure modelo
	|EXEMPLO					:
      
		DECLARE @cd_retorno int, @nm_retorno varchar(3000)

				exec [bpm].p_exemplo_procedure_modelo_incluir							
					@cd_usuario			=	'componentes',	
					@cd_retorno			=	@cd_retorno OUTPUT,
					@nm_retorno			=	@nm_retorno OUTPUT

				SELECT @cd_retorno, @nm_retorno */
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --VERIFICAR NECESSIDADE DA ROTINA, POIS TERÁ LEITURA SUJA

BEGIN

	SELECT @nr_versao_proc = LTRIM(RTRIM(REPLACE(REPLACE('$Revision: 1.0 $','Revision:',''),'$','')))

	BEGIN TRY		
		/* CÓDIGO*/		
	END TRY
	BEGIN CATCH

		SELECT	@cd_retorno = 1,
				@nm_retorno = 'Erro: p_exemplo_procedure_modelo_incluir - ' + ERROR_MESSAGE() + ' - Linha: ' + CONVERT(VARCHAR(40),ERROR_LINE())		
		RETURN

	END CATCH 
END
