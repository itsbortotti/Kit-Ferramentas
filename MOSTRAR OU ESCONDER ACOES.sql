--LEMBRAR DE LIMPAR O CACHE APOS EFETUAR ESSAS ALTERAÇÕES

--PESQUISAR O NOME DA AÇÃO, E PEGAR O CD_ACAO
SELECT cd_acao, * FROM DINA_ACAO WHERE NM_ACAO = 'Extensões de Arquivo'

--PARA APLICAR, COMENTAR O ROLLBACK NO FIM DO SCRIPT E EFETUAR UM COMMIT
BEGIN TRAN

--ID E DESCRICAO DO COMPONENTE ONDE MOSTRARÁ OU ESCONDERÁ A GUIA

--TABELA dina_coluna_condicao 
--id_coluna_condicao	vl_campo	nm_hint
--37824					1			GED
--37825					2			PDF
--37826					3			EML
--37827					4			pWS
--37828					5			cWS
--37829					6			APA
--37823					7			JOKER
--38001					8			GEM

-- PARAMETRO PARA  MOSTRAR OU ESCONDER A GUIA NO COMPONENTE
DECLARE
	@DV_MOSTRA_GED	 BIT = 1,
	@DV_MOSTRA_PDF	 BIT = 0,
	@DV_MOSTRA_EML	 BIT = 0,
	@DV_MOSTRA_pWS	 BIT = 0,
	@DV_MOSTRA_cWS	 BIT = 0,
	@DV_MOSTRA_APA	 BIT = 0,
	@DV_MOSTRA_JOKER BIT = 0,
	@DV_MOSTRA_GEM	 BIT = 0

-- INFORMAR O CD_ACAO CAPTURADO NO PRIMEIRO SELECT
DECLARE @cd_acao int = 	39874	

-- SELECT PARA VISUALIZAÇÃO DE COMPARAÇÃO. DADOS PRE INSERT/UPDATE
SELECT DCCA.*, DCC.nm_hint
FROM dina_coluna_condicao_acao DCCA
JOIN dina_coluna_condicao      DCC ON DCC.id_coluna_condicao = DCCA.id_coluna_condicao
WHERE cd_acao = @cd_acao

--UPDATES E INSERTS
IF EXISTS (SELECT TOP 1 1 FROM dina_coluna_condicao_acao WHERE CD_ACAO = @CD_ACAO AND id_coluna_condicao = 37824) --GED
	BEGIN 
		UPDATE dina_coluna_condicao_acao
		SET DV_MOSTRA = @DV_MOSTRA_GED
		WHERE cd_acao = @cd_acao
		AND ID_COLUNA_CONDICAO = 37824
	END 
ELSE 
	BEGIN
		INSERT INTO dina_coluna_condicao_acao (DV_MOSTRA, cd_acao, ID_COLUNA_CONDICAO)
		VALUES (@DV_MOSTRA_GED, @cd_acao, 37824)
	END

IF EXISTS (SELECT TOP 1 1 FROM dina_coluna_condicao_acao WHERE CD_ACAO = @CD_ACAO AND id_coluna_condicao = 37825) --PDF
	BEGIN 
		UPDATE dina_coluna_condicao_acao
		SET DV_MOSTRA = @DV_MOSTRA_PDF
		WHERE cd_acao = @cd_acao
		AND ID_COLUNA_CONDICAO = 37825
	END 
ELSE 
	BEGIN
		INSERT INTO dina_coluna_condicao_acao (DV_MOSTRA, cd_acao, ID_COLUNA_CONDICAO)
		VALUES (@DV_MOSTRA_PDF, @cd_acao, 37825)
	END

IF EXISTS (SELECT TOP 1 1 FROM dina_coluna_condicao_acao WHERE CD_ACAO = @CD_ACAO AND id_coluna_condicao = 37826) --EML
	BEGIN 
		UPDATE dina_coluna_condicao_acao
		SET DV_MOSTRA = @DV_MOSTRA_EML
		WHERE cd_acao = @cd_acao
		AND ID_COLUNA_CONDICAO = 37826
	END 
ELSE 
	BEGIN
		INSERT INTO dina_coluna_condicao_acao (DV_MOSTRA, cd_acao, ID_COLUNA_CONDICAO)
		VALUES (@DV_MOSTRA_EML, @cd_acao, 37826)
	END

IF EXISTS (SELECT TOP 1 1 FROM dina_coluna_condicao_acao WHERE CD_ACAO = @CD_ACAO AND id_coluna_condicao = 37827) --pWS
	BEGIN 
		UPDATE dina_coluna_condicao_acao
		SET DV_MOSTRA = @DV_MOSTRA_pWS
		WHERE cd_acao = @cd_acao
		AND ID_COLUNA_CONDICAO = 37827
	END 
ELSE 
	BEGIN
		INSERT INTO dina_coluna_condicao_acao (DV_MOSTRA, cd_acao, ID_COLUNA_CONDICAO)
		VALUES (@DV_MOSTRA_pWS, @cd_acao, 37827)
	END

IF EXISTS (SELECT TOP 1 1 FROM dina_coluna_condicao_acao WHERE CD_ACAO = @CD_ACAO AND id_coluna_condicao = 37828) --cWS
	BEGIN 
		UPDATE dina_coluna_condicao_acao
		SET DV_MOSTRA = @DV_MOSTRA_cWS
		WHERE cd_acao = @cd_acao
		AND ID_COLUNA_CONDICAO = 37828
	END 
ELSE 
	BEGIN
		INSERT INTO dina_coluna_condicao_acao (DV_MOSTRA, cd_acao, ID_COLUNA_CONDICAO)
		VALUES (@DV_MOSTRA_cWS, @cd_acao, 37828)
	END

IF EXISTS (SELECT TOP 1 1 FROM dina_coluna_condicao_acao WHERE CD_ACAO = @CD_ACAO AND id_coluna_condicao = 37829) --APA
	BEGIN 
		UPDATE dina_coluna_condicao_acao
		SET DV_MOSTRA = @DV_MOSTRA_APA
		WHERE cd_acao = @cd_acao
		AND ID_COLUNA_CONDICAO = 37829
	END 
ELSE 
	BEGIN
		INSERT INTO dina_coluna_condicao_acao (DV_MOSTRA, cd_acao, ID_COLUNA_CONDICAO)
		VALUES (@DV_MOSTRA_APA, @cd_acao, 37829)
	END

IF EXISTS (SELECT TOP 1 1 FROM dina_coluna_condicao_acao WHERE CD_ACAO = @CD_ACAO AND id_coluna_condicao = 37823) --JOKER
	BEGIN 
		UPDATE dina_coluna_condicao_acao
		SET DV_MOSTRA = @DV_MOSTRA_JOKER
		WHERE cd_acao = @cd_acao
		AND ID_COLUNA_CONDICAO = 37823
	END 
ELSE 
	BEGIN
		INSERT INTO dina_coluna_condicao_acao (DV_MOSTRA, cd_acao, ID_COLUNA_CONDICAO)
		VALUES (@DV_MOSTRA_JOKER, @cd_acao, 37823)
	END

IF EXISTS (SELECT TOP 1 1 FROM dina_coluna_condicao_acao WHERE CD_ACAO = @CD_ACAO AND id_coluna_condicao = 38001) --GEM
	BEGIN 
		UPDATE dina_coluna_condicao_acao
		SET DV_MOSTRA = @DV_MOSTRA_GEM
		WHERE cd_acao = @cd_acao
		AND ID_COLUNA_CONDICAO = 38001
	END 
ELSE 
	BEGIN
		INSERT INTO dina_coluna_condicao_acao (DV_MOSTRA, cd_acao, ID_COLUNA_CONDICAO)
		VALUES (@DV_MOSTRA_GEM, @cd_acao, 38001)
	END


--SELECT PARA VISUALIZAR COMPARAÇÃO. DADOS POS INSERTS/UPDATES
SELECT DCCA.*, DCC.nm_hint
FROM dina_coluna_condicao_acao DCCA
JOIN dina_coluna_condicao      DCC ON DCC.id_coluna_condicao = DCCA.id_coluna_condicao
WHERE cd_acao = @cd_acao

ROLLBACK


