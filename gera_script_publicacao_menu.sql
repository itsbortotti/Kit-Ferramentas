----------------------------------------------------------------------------------------------------------------
---
--- SCRIPT PUBLICADOR DE MENU
--
-- $Revision: 1.2.2.1 $
-- $Date: 2020/11/12 18:54:15 $
----------------------------------------------------------------------------------------------------------------
DECLARE @cd_menu		   INT			= 20221400					--Informe a tela que deseja gerar o script de publicação
declare @cd_menu_filhos		varchar(300) = '
20221401
,20221402
,20221403
,20221404
,20221405
,20221406
,20221407
,20221408
'


/******
exemplo

DECLARE @cd_menu		   INT			= 20221200		--Informe a tela que deseja gerar o script de publicação
declare @cd_menu_filhos		varchar(300) = '20221201,20221202'


******/
SET NOCOUNT ON

BEGIN TRY


	IF OBJECT_ID('tempdb..#tabela_results') IS NOT NULL
	DROP TABLE #tabela_results

	create table #tabela_results
	(
		id int identity,
		nm_string varchar(max)
	)

	DECLARE @qtd_separador INT = 200
	DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)

	INSERT INTO #tabela_results(nm_string)
	SELECT 'USE SEGCORP' + @NewLineChar 

	INSERT INTO #tabela_results(nm_string)
	SELECT 'GO' + @NewLineChar 

	INSERT INTO #tabela_results(nm_string)
	SELECT '' + @NewLineChar 

	INSERT INTO #tabela_results(nm_string)
	SELECT	'DECLARE							' + CHAR(10) +
		   	'	@nr_versao_controle VARCHAR(20),' + CHAR(10) +
			'	@dt_versao_controle VARCHAR(50) ' + CHAR(10)

	INSERT INTO #tabela_results(nm_string)
	SELECT '' + @NewLineChar

	INSERT INTO #tabela_results(nm_string)
	SELECT '------ VERSÃO DA TELA ---------------------------------------------' + @NewLineChar 

	INSERT INTO #tabela_results(nm_string)
	SELECT	'SELECT														' + CHAR(10) +
			'	@nr_versao_controle = ''$Revision: 1.0 $'',				' + CHAR(10) +
			'	@dt_versao_controle = ''$Date: 2022/04/06 14:54:15 $''	' + CHAR(10)

	INSERT INTO #tabela_results(nm_string)
	SELECT '-------------------------------------------------------------------' + @NewLineChar 

	INSERT INTO #tabela_results(nm_string)
	SELECT '' + @NewLineChar 

	--Remove existências de tabelas temporarias
	IF OBJECT_ID('tempdb..#temp_menu') IS NOT NULL DROP TABLE #temp_menu
	IF OBJECT_ID('tempdb..#temp_menu_filho') IS NOT NULL DROP TABLE #temp_menu_filho

	--Construtor das tabelas temporárias
	CREATE TABLE #temp_menu(
		 cd_menu		INT
		,cd_dina		INT
		,Cd_empresa		INT
		,Nm_menu		VARCHAR(25)
		,Cd_sistema		INT
		,Cd_menu_pai	INT
	)

	CREATE TABLE #temp_menu_filho(
		 cd_menu		INT
		,cd_dina		INT
		,Cd_empresa		INT
		,Nm_menu		VARCHAR(25)
		,Cd_sistema		INT
		,Cd_menu_pai	INT
	)

	--Inserir a referência para os ids externos das tabelas externas nas tabelas temporárias externas
	INSERT INTO #temp_menu (cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai)
	SELECT 
		 cd_menu		=	dm.cd_menu	
		,cd_dina		=	dm.cd_dina	
		,Cd_empresa		=	dm.Cd_empresa	
		,Nm_menu		=	dm.Nm_menu	
		,Cd_sistema		=	dm.Cd_sistema	
		,Cd_menu_pai	=	dm.Cd_menu_pai
	FROM dina_menu dm
	WHERE dm.cd_menu = @cd_menu	


	declare @sql varchar(max)

select @sql = '
	INSERT INTO #temp_menu_filho (cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai)
	SELECT 
		 cd_menu		=	dm.cd_menu	
		,cd_dina		=	dm.cd_dina	
		,Cd_empresa		=	dm.Cd_empresa	
		,Nm_menu		=	dm.Nm_menu	
		,Cd_sistema		=	dm.Cd_sistema	
		,Cd_menu_pai	=	dm.Cd_menu_pai
	FROM dina_menu dm
	WHERE dm.Cd_menu_pai = ' + convert(varchar(100),@cd_menu)
	+ 'and dm.cd_menu in (' + @cd_menu_filhos + ')'
	exec (@sql)

	
	--Gerar o script para deletar as tabelas internas
	INSERT INTO #tabela_results(nm_string)
	SELECT 'DECLARE @cd_menu INT = ' + CONVERT(VARCHAR(MAX),@cd_menu) + @NewLineChar 
	INSERT INTO #tabela_results(nm_string)
	SELECT 'BEGIN TRANSACTION' + @NewLineChar 
	INSERT INTO #tabela_results(nm_string)
	SELECT 'BEGIN TRY' + @NewLineChar 
	INSERT INTO #tabela_results(nm_string)
	SELECT '	SET NOCOUNT ON' + @NewLineChar 

	INSERT INTO #tabela_results(nm_string)
	SELECT  '	IF OBJECT_ID(''tempdb..#temp_menu'') IS NOT NULL DROP TABLE #temp_menu				' + CHAR(10) +
			'	IF OBJECT_ID(''tempdb..#temp_menu_filho'') IS NOT NULL DROP TABLE #temp_menu_filho	' + CHAR(10) +
				@NewLineChar +
			'	CREATE TABLE #temp_menu(															' + CHAR(10) +
			'		 cd_menu		INT																' + CHAR(10) +
			'		,cd_dina		INT																' + CHAR(10) +
			'		,Cd_empresa		INT																' + CHAR(10) +
			'		,Nm_menu		VARCHAR(25)														' + CHAR(10) +
			'		,Cd_sistema		INT																' + CHAR(10) +
			'		,Cd_menu_pai	INT																' + CHAR(10) +
			'	)																					' + CHAR(10) +
			+	 @NewLineChar +
			'	CREATE TABLE #temp_menu_filho(														' + CHAR(10) +
			'		 cd_menu		INT																' + CHAR(10) +
			'		,cd_dina		INT																' + CHAR(10) +
			'		,Cd_empresa		INT																' + CHAR(10) +
			'		,Nm_menu		VARCHAR(25)														' + CHAR(10) +
			'		,Cd_sistema		INT																' + CHAR(10) +
			'		,Cd_menu_pai	INT																' + CHAR(10) +
			'	) 																					' + CHAR(10) +
			+ @NewLineChar 

	--Gerar o script para inserir nas tabelas temporárias internas a partir do que está gravado nas tabelas temporárias externas
	--Variáveis utilizadas nos cursores

	DECLARE 
		 @cd_dina		INT
		,@Cd_empresa	INT
		,@Nm_menu		VARCHAR(25)
		,@Cd_sistema	INT
		,@Cd_menu_pai	INT

	--MENU
	INSERT INTO #tabela_results(nm_string)
	SELECT REPLICATE('-', 2) + 'MENU' + REPLICATE('-', @qtd_separador)

	DECLARE cursor_dina CURSOR FOR
	SELECT cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai
	FROM #temp_menu
	WHERE cd_menu = @cd_menu

	OPEN cursor_dina
	FETCH NEXT FROM cursor_dina INTO @cd_menu, @cd_dina, @Cd_empresa, @Nm_menu, @Cd_sistema, @Cd_menu_pai

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tabela_results(nm_string)
		SELECT	'	INSERT INTO #temp_menu (cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai)' + CHAR(10) +
				'	SELECT cd_menu =	' + ISNULL(CONVERT(VARCHAR(MAX),@cd_menu),'NULL') +', cd_dina =	' + ISNULL('''' + REPLACE(CONVERT(VARCHAR(MAX),@cd_dina),'''','''''')+'''','NULL') +', Cd_empresa =	' + ISNULL(CONVERT(VARCHAR(MAX),@Cd_empresa),'NULL') +', Nm_menu = ' + ISNULL('''' + REPLACE(CONVERT(VARCHAR(MAX),@Nm_menu),'''','''''')+'''','NULL') +', Cd_sistema = ' + ISNULL('''' + REPLACE(CONVERT(VARCHAR(MAX),@Cd_sistema),'''','''''')+'''','NULL') +', Cd_menu_pai = ' + ISNULL(CONVERT(VARCHAR(MAX),@Cd_menu_pai),'NULL')
		+ @NewLineChar 
		FETCH NEXT FROM cursor_dina INTO @cd_menu, @cd_dina, @Cd_empresa, @Nm_menu, @Cd_sistema, @Cd_menu_pai
	END
	CLOSE cursor_dina
	DEALLOCATE cursor_dina

	--Gerar o script para inserir nas tabelas internas a partir das tabelas temporárias internas
	INSERT INTO #tabela_results(nm_string)
	SELECT REPLICATE('-', @qtd_separador)
	INSERT INTO #tabela_results(nm_string)
	SELECT REPLICATE('-', @qtd_separador)

	INSERT INTO #tabela_results(nm_string)
	SELECT	'	MERGE dbo.dina_menu AS TARGET													' + CHAR(10) +
			'		USING(	SELECT 																' + CHAR(10) +
			'					 cd_menu		=	dm.cd_menu									' + CHAR(10) +
			'					,cd_dina		=	dm.cd_dina									' + CHAR(10) +
			'					,Cd_empresa		=	dm.Cd_empresa								' + CHAR(10) +
			'					,Nm_menu		=	dm.Nm_menu									' + CHAR(10) +
			'					,Cd_sistema		=	dm.Cd_sistema								' + CHAR(10) +
			'					,Cd_menu_pai	=	dm.Cd_menu_pai								' + CHAR(10) +
			'				FROM #temp_menu dm													' + CHAR(10) +
			'		) AS SOURCE(cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai)	' + CHAR(10) +
			'	ON (TARGET.cd_menu = SOURCE.cd_menu)											' + CHAR(10) +
			'																					' + CHAR(10) +
			'	WHEN MATCHED THEN																' + CHAR(10) +
			'		UPDATE SET 																	' + CHAR(10) +
			'			 Nm_menu	=	SOURCE.Nm_menu											' + CHAR(10) +
			'																					' + CHAR(10) +
			'	WHEN NOT MATCHED THEN															' + CHAR(10) +
			'		INSERT(	cd_menu, 															' + CHAR(10) +
			'				cd_dina,															' + CHAR(10) +
			'				Cd_empresa,															' + CHAR(10) +
			'				Nm_menu,															' + CHAR(10) +
			'				Cd_sistema,															' + CHAR(10) +
			'				Cd_menu_pai															' + CHAR(10) +
			'				)																	' + CHAR(10) +
			'		VALUES(	SOURCE.cd_menu, 													' + CHAR(10) +
			'				SOURCE.cd_dina,														' + CHAR(10) +
			'				SOURCE.Cd_empresa,													' + CHAR(10) +
			'				SOURCE.Nm_menu,														' + CHAR(10) +
			'				SOURCE.Cd_sistema,													' + CHAR(10) +
			'				SOURCE.Cd_menu_pai													' + CHAR(10) +
			'			   );																	' + CHAR(10) +
			@NewLineChar
	
	
	--MENU FILHO
	INSERT INTO #tabela_results(nm_string)
	SELECT REPLICATE('-', 2) + 'MENU FILHO' + REPLICATE('-', @qtd_separador)

	
	
if isnull(@cd_menu_filhos,'') <> ''
begin
	DECLARE cursor_dina CURSOR FOR
	
	SELECT cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai
	FROM #temp_menu_filho
	WHERE Cd_menu_pai = @cd_menu


	OPEN cursor_dina
	FETCH NEXT FROM cursor_dina INTO @cd_menu, @cd_dina, @Cd_empresa, @Nm_menu, @Cd_sistema, @Cd_menu_pai

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tabela_results(nm_string)
		SELECT	'	INSERT INTO #temp_menu_filho (cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai)' + CHAR(10) +
				'	SELECT cd_menu =	' + ISNULL(CONVERT(VARCHAR(MAX),@cd_menu),'NULL') +', cd_dina =	' + ISNULL('''' + REPLACE(CONVERT(VARCHAR(MAX),@cd_dina),'''','''''')+'''','NULL') +', Cd_empresa =	' + ISNULL(CONVERT(VARCHAR(MAX),@Cd_empresa),'NULL') +', Nm_menu = ' + ISNULL('''' + REPLACE(CONVERT(VARCHAR(MAX),@Nm_menu),'''','''''')+'''','NULL') +', Cd_sistema = ' + ISNULL('''' + REPLACE(CONVERT(VARCHAR(MAX),@Cd_sistema),'''','''''')+'''','NULL') +', Cd_menu_pai = ' + ISNULL(CONVERT(VARCHAR(MAX),@Cd_menu_pai),'NULL')
		+ @NewLineChar 
		FETCH NEXT FROM cursor_dina INTO @cd_menu, @cd_dina, @Cd_empresa, @Nm_menu, @Cd_sistema, @Cd_menu_pai
	END
	CLOSE cursor_dina
	DEALLOCATE cursor_dina
end
	INSERT INTO #tabela_results(nm_string)
	SELECT REPLICATE('-', @qtd_separador)
	INSERT INTO #tabela_results(nm_string)
	SELECT	'	MERGE dbo.dina_menu AS TARGET													' + CHAR(10) +
			'		USING(	SELECT 																' + CHAR(10) +
			'					 cd_menu		=	dm.cd_menu									' + CHAR(10) +
			'					,cd_dina		=	dm.cd_dina									' + CHAR(10) +
			'					,Cd_empresa		=	dm.Cd_empresa								' + CHAR(10) +
			'					,Nm_menu		=	dm.Nm_menu									' + CHAR(10) +
			'					,Cd_sistema		=	dm.Cd_sistema								' + CHAR(10) +
			'					,Cd_menu_pai	=	dm.Cd_menu_pai								' + CHAR(10) +
			'				FROM #temp_menu_filho dm											' + CHAR(10) +
			'		) AS SOURCE(cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai)	' + CHAR(10) +
			'	ON (TARGET.cd_menu = SOURCE.cd_menu)											' + CHAR(10) +
			'																					' + CHAR(10) +
			'	WHEN MATCHED THEN																' + CHAR(10) +
			'		UPDATE SET 																	' + CHAR(10) +
			'			 Nm_menu	=	SOURCE.Nm_menu											' + CHAR(10) +
			'																					' + CHAR(10) +
			'	WHEN NOT MATCHED THEN															' + CHAR(10) +
			'		INSERT(	cd_menu, 															' + CHAR(10) +
			'				cd_dina,															' + CHAR(10) +
			'				Cd_empresa,															' + CHAR(10) +
			'				Nm_menu,															' + CHAR(10) +
			'				Cd_sistema,															' + CHAR(10) +
			'				Cd_menu_pai															' + CHAR(10) +
			'				)																	' + CHAR(10) +
			'		VALUES(	SOURCE.cd_menu, 													' + CHAR(10) +
			'				SOURCE.cd_dina,														' + CHAR(10) +
			'				SOURCE.Cd_empresa,													' + CHAR(10) +
			'				SOURCE.Nm_menu,														' + CHAR(10) +
			'				SOURCE.Cd_sistema,													' + CHAR(10) +
			'				SOURCE.Cd_menu_pai													' + CHAR(10) +
			'			   );																	' + CHAR(10) +
			@NewLineChar

	INSERT INTO #tabela_results(nm_string)
	SELECT REPLICATE('-', @qtd_separador)
	INSERT INTO #tabela_results(nm_string)
	SELECT REPLICATE('-', @qtd_separador)

	INSERT INTO #tabela_results(nm_string)
	SELECT	'	SET NOCOUNT OFF							' + CHAR(10) +
			'	SELECT ''SCRIPT EXECUTOU COM SUCESSO!''	' + CHAR(10) +
			@NewLineChar 

	INSERT INTO #tabela_results(nm_string)
	SELECT	'	COMMIT TRANSACTION														' + CHAR(10) +
			'END TRY																	' + CHAR(10) +
			'BEGIN CATCH																' + CHAR(10) +
			'	SELECT ''SCRIPT EXECUTOU COM FALHA: '' + ERROR_MESSAGE() AS ErrorMessage' + CHAR(10) +
			'	ROLLBACK TRANSACTION													' + CHAR(10) +
			'END CATCH																	' + CHAR(10) 

	SELECT nm_string FROM #tabela_results ORDER BY id ASC

END TRY
BEGIN CATCH

		SELECT ERRO = ERROR_MESSAGE()
		RETURN

END CATCH

RETURN