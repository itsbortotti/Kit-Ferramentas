/*
		SCRIPT CLONAR DE TELA
		Criado por:		Paulo Silva
		Data:			27/01
*/

DECLARE @cd_dina		   INT			= 11378		  /* TELA */

SET NOCOUNT ON

BEGIN TRY

	--begin tran
	
		DECLARE @cd_dina_novo	INT

		/* CONSTRUTOR DAS TABELAS TEMPORÁRIAS */
		IF OBJECT_ID('tempdb..#output') IS NOT NULL 
			BEGIN
				DROP TABLE #output 
			END
		CREATE TABLE #output
		(
			id_output				INT,
			cd_valor_1				INT,
			cd_valor_2				INT,
			cd_valor_3				INT,
			cd_valor_4				INT,
			cd_valor_5				INT,
			nm_campo_1				VARCHAR(800),
			nm_campo_2				VARCHAR(800),
			nm_campo_3				VARCHAR(800),
			nm_campo_4				VARCHAR(800),
			nm_campo_5				VARCHAR(800),
		)

		/* CONSTRUTOR DAS TABELAS TEMPORÁRIAS */
		IF OBJECT_ID('tempdb..#dina') IS NOT NULL 
			BEGIN
				DROP TABLE #dina
			END
		CREATE TABLE #dina
		(
			cd_dina_novo				INT ,
			cd_dina						INT ,
			nm_dina						VARCHAR(500),
			cd_tipo_tela				INT,
			nm_titulo					VARCHAR(500),
			nm_tabela					VARCHAR(255) ,
			cd_tipo_comando				INT ,
			nm_orderby					VARCHAR(100) ,
			nm_where					VARCHAR(300) ,
			nr_registro_pagina			INT ,
			dv_modo						CHAR(1) ,
			Cd_sistema					INT ,
			nm_query					TEXT ,
			nr_auto_refresh				SMALLINT ,
			dv_sem_link_lista			BIT ,
			cd_usuario					VARCHAR(10) ,
			dv_alterando				BIT ,
			dv_checkout					BIT ,	
			id_usuario_checkout			VARCHAR(10) ,
			dt_checkout					SMALLDATETIME ,
			nm_set						VARCHAR(255) ,
			dv_traduz_conteudo			BIT
		)
		
		IF OBJECT_ID('tempdb..#dina_coluna') IS NOT NULL 
			BEGIN
				DROP TABLE #dina_coluna
			END

		CREATE TABLE #dina_coluna
		(
			cd_dina_novo				INT ,
			cd_coluna_novo				INT   ,		
			cd_coluna					INT   ,
			cd_lookup_dina				INT ,
			cd_funcao_validacao			INT ,
			cd_dina						INT  ,
			nm_campo					VARCHAR(500)  ,
			nr_ordem					SMALLINT ,
			nm_titulo					VARCHAR(500)  ,
			dv_mostra_lista				CHAR(1) ,
			dv_mostra_ficha				CHAR(1) ,
			dv_mostra_filtro			CHAR(1) ,
			dv_chave					CHAR(1) ,
			dv_somente_leitura			CHAR(1) ,
			nm_hint						VARCHAR(300) ,
			nm_lookup_tabela			TEXT ,
			nm_lookup_chave				VARCHAR(500) ,
			nm_lookup_lista				VARCHAR(500) ,
			nm_lookup_where				VARCHAR(400) ,
			dv_obrigatorio				CHAR(1) ,
			dv_mostra					CHAR(1) ,
			nm_formato					VARCHAR(300) ,
			nm_alias					VARCHAR(200) ,
			dv_lookup_estilo			CHAR(1) ,
			nm_classe_lista				VARCHAR(100) ,
			dv_edita_lista				BIT ,
			cd_valor_padrao				INT ,
			nm_campo_hint				VARCHAR(500) ,
			dv_traduz_conteudo			BIT,
			cd_coluna_new				INT
		)

		IF OBJECT_ID('tempdb..#dina_acao') IS NOT NULL 
			BEGIN
				DROP TABLE #dina_acao
			END
		CREATE TABLE #dina_acao
		(
			cd_dina_novo				INT ,
			cd_acao_novo				INT   ,
			cd_acao								INT   ,
			cd_dina								INT  ,
			dv_log_sistema						BIT ,
			nm_acao								VARCHAR(250) ,
			cd_tipo_implementacao				SMALLINT ,
			nm_implementacao					VARCHAR(100) ,
			nm_implementacao_parametro			VARCHAR(800) ,
			cd_tipo_evento						SMALLINT ,
			cd_relatorio						INT ,
			nm_hint								VARCHAR(150) ,
			dv_modo								CHAR(1) ,
			cd_barra							SMALLINT ,
			cd_layout							INT ,
			nm_mensagem_alerta					VARCHAR(200) ,
			dv_padrao							BIT ,
			nm_target							VARCHAR(100) ,
			nm_servidor_remoto					VARCHAR(200) ,
			nr_ordem							SMALLINT ,
			nr_auto_refresh						INT ,
			id_dominio							INT ,
			dv_lock_app_resource				BIT
		)

		IF OBJECT_ID('tempdb..#dina_acao_parametro') IS NOT NULL 
			BEGIN 
				DROP TABLE #dina_acao_parametro
			END
		CREATE TABLE #dina_acao_parametro
		(
			id_parametro						INT  ,
			cd_acao								INT  ,
			nm_parametro						VARCHAR(400)
		)

		IF OBJECT_ID('tempdb..#dina_coluna_condicao') IS NOT NULL 
			BEGIN
				DROP TABLE #dina_coluna_condicao
			END

		CREATE TABLE #dina_coluna_condicao
		(
			id_coluna_condicao_novo				INT ,
			id_coluna_condicao					INT ,
			cd_coluna							INT  ,
			vl_campo							VARCHAR(800) ,
			nm_hint								VARCHAR(255) 
		)

		IF OBJECT_ID('tempdb..#dina_coluna_condicao_acao') IS NOT NULL 
			BEGIN
				DROP TABLE #dina_coluna_condicao_acao
			END
		CREATE TABLE #dina_coluna_condicao_acao
		(
			id_coluna_mostra_acao		int,
			id_coluna_condicao			int,
			cd_acao						int,
			dv_mostra					bit,
			cd_coluna_condicao			int,
			cd_coluna_condicao_novo		int,
			cd_acao_novo			int
		)

		IF OBJECT_ID('tempdb..#dina_coluna_condicao_coluna') IS NOT NULL 
			BEGIN 
				DROP TABLE #dina_coluna_condicao_coluna
			END

		CREATE TABLE #dina_coluna_condicao_coluna
		(
			id_coluna_mostra_condicao	int,
			id_coluna_condicao			int,
			cd_coluna_condicao			int,
			dv_mostra					bit,
			dv_protegido				bit,
			cd_coluna_campo				int,
			cd_coluna_condicao_novo		int,
			cd_coluna_campo_novo		int
		)

		/* TELA */ 
		insert into #dina (cd_dina, nm_dina, cd_tipo_tela, nm_titulo, nm_tabela, cd_tipo_comando, nm_orderby, nm_where, nr_registro_pagina, dv_modo, Cd_sistema, nm_query, nr_auto_refresh, dv_sem_link_lista, cd_usuario, dv_alterando, dv_checkout, id_usuario_checkout, dt_checkout, nm_set, dv_traduz_conteudo)
		select cd_dina, nm_dina, cd_tipo_tela, nm_titulo, nm_tabela, cd_tipo_comando, nm_orderby, nm_where, nr_registro_pagina, dv_modo, Cd_sistema, nm_query, nr_auto_refresh, dv_sem_link_lista, cd_usuario, dv_alterando, dv_checkout, id_usuario_checkout, dt_checkout, nm_set, dv_traduz_conteudo 
		from dina 
		where cd_dina =  @cd_dina

		/* COLUNA */ 
		insert into #dina_coluna (cd_valor_padrao, cd_lookup_dina, cd_funcao_validacao, cd_dina, nm_campo, nr_ordem, nm_titulo, dv_mostra_lista, dv_mostra_ficha, dv_mostra_filtro, dv_chave, dv_somente_leitura, nm_hint, nm_lookup_tabela, nm_lookup_chave, nm_lookup_lista, nm_lookup_where, dv_obrigatorio, dv_mostra, nm_formato, nm_alias, dv_lookup_estilo, nm_classe_lista, dv_edita_lista, nm_campo_hint, dv_traduz_conteudo, cd_coluna)
		select dc.cd_valor_padrao, dc.cd_lookup_dina, dc.cd_funcao_validacao, dc.cd_dina, dc.nm_campo, dc.nr_ordem, dc.nm_titulo, dc.dv_mostra_lista, dc.dv_mostra_ficha, dc.dv_mostra_filtro, dc.dv_chave, dc.dv_somente_leitura, dc.nm_hint, dc.nm_lookup_tabela, dc.nm_lookup_chave, dc.nm_lookup_lista, dc.nm_lookup_where, dc.dv_obrigatorio, dc.dv_mostra, dc.nm_formato, dc.nm_alias, dc.dv_lookup_estilo, dc.nm_classe_lista, dc.dv_edita_lista, dc.nm_campo_hint, dc.dv_traduz_conteudo, dc.cd_coluna
		from dina_coluna dc 
		where dc.cd_dina = @cd_dina
		order by nr_ordem

		/* COLUNA CONDIÇÃO */
		insert into #dina_coluna_condicao (cd_coluna, vl_campo, nm_hint, id_coluna_condicao)
		select dcc.cd_coluna, dcc.vl_campo, dcc.nm_hint, dcc.id_coluna_condicao 
		from dina_coluna_condicao dcc
			INNER JOIN #dina_coluna dct on dct.cd_coluna = dcc.cd_coluna

		/* COLUNA CONDIÇÃO COLUNA */
		insert into #dina_coluna_condicao_coluna (id_coluna_condicao, cd_coluna_condicao, cd_coluna_campo, dv_mostra, dv_protegido,id_coluna_mostra_condicao )
		select tdcc.id_coluna_condicao, tdcc.cd_coluna, dccc.cd_coluna, dccc.dv_mostra,dccc.dv_protegido, dccc.id_coluna_mostra_condicao
		from #dina_coluna_condicao tdcc
		INNER JOIN dbo.dina_coluna_condicao_coluna  dccc on dccc.id_coluna_condicao = tdcc.id_coluna_condicao

		/* COLUNA CONDIÇÃO AÇÃO */
		insert into #dina_coluna_condicao_acao (id_coluna_condicao, cd_acao, dv_mostra, id_coluna_mostra_acao, cd_coluna_condicao )
		select									dcca.id_coluna_condicao, dcca.cd_acao, dcca.dv_mostra, dcca.id_coluna_mostra_acao,TDCC.cd_coluna
		from dina_coluna_condicao_acao			dcca
			INNER JOIN #dina_coluna_condicao	tdcc	ON tdcc.id_coluna_condicao = dcca.id_coluna_condicao 
															AND dcca.id_coluna_condicao IS NOT NULL

		/* AÇÃO */
		insert into #dina_acao(cd_dina, dv_log_sistema, nm_acao, cd_tipo_implementacao, nm_implementacao, nm_implementacao_parametro, cd_tipo_evento, cd_relatorio, nm_hint, dv_modo, cd_barra, cd_layout, nm_mensagem_alerta, dv_padrao, nm_target, nm_servidor_remoto, nr_ordem, nr_auto_refresh, id_dominio, dv_lock_app_resource, cd_acao)
		select da.cd_dina, da.dv_log_sistema, da.nm_acao, da.cd_tipo_implementacao, da.nm_implementacao, da.nm_implementacao_parametro, da.cd_tipo_evento, da.cd_relatorio, da.nm_hint, da.dv_modo, da.cd_barra, da.cd_layout, da.nm_mensagem_alerta, da.dv_padrao, da.nm_target, da.nm_servidor_remoto, da.nr_ordem, da.nr_auto_refresh, da.id_dominio , da.dv_lock_app_resource, da.cd_acao
		from dina_acao da where cd_dina = @cd_dina

		/* AÇÃO PARAMETRO */
		insert into #dina_acao_parametro (cd_acao, nm_parametro)
		select dat.cd_acao, dap.nm_parametro
		from dina_acao_parametro dap
			INNER JOIN #dina_acao dat on dat.cd_acao = dap.cd_acao and dat.cd_dina = @cd_dina
		
/* INSERE OS NOVOS DADOS */
/* TELA */
		INSERT INTO dina(	nm_dina,cd_tipo_tela,nm_titulo,nm_tabela,cd_tipo_comando,nm_orderby,nm_where,nr_registro_pagina,dv_modo,cd_sistema,nm_query,
							nr_auto_refresh,dv_sem_link_lista,cd_usuario,dv_alterando,dv_checkout,id_usuario_checkout,dt_checkout,nm_set,dv_traduz_conteudo,nr_versao )
		OUTPUT inserted.cd_dina INTO #output (id_output)
		SELECT	nm_dina + '_Clone',cd_tipo_tela,nm_titulo,nm_tabela,cd_tipo_comando,nm_orderby,nm_where,nr_registro_pagina,dv_modo,cd_sistema,nm_query,
				nr_auto_refresh,dv_sem_link_lista,cd_usuario = NULL,dv_alterando = 0,dv_checkout = 0,id_usuario_checkout = NULL,dt_checkout = NULL,nm_set,dv_traduz_conteudo,nr_versao = 1
		FROM  #dina

		/* ATUALIZA O NOVO ID DA TELA */
		SET @cd_dina_novo = (SELECT TOP 1 id_output FROM #output) 				
		UPDATE #dina SET cd_dina_novo = @cd_dina_novo
		UPDATE #dina_coluna SET cd_dina_novo = @cd_dina_novo
		UPDATE #dina_acao SET cd_dina_novo = @cd_dina_novo

/* COLUNAS */
		DELETE FROM #output
		INSERT INTO dina_coluna (cd_lookup_dina,cd_funcao_validacao,cd_dina,nm_campo,nr_ordem,nm_titulo,dv_mostra_lista,dv_mostra_ficha,dv_mostra_filtro,dv_chave,dv_somente_leitura,
								 nm_hint,nm_lookup_tabela,nm_lookup_chave,nm_lookup_lista,nm_lookup_where,dv_obrigatorio,dv_mostra,nm_formato,nm_alias,dv_lookup_estilo,nm_classe_lista,
								 dv_edita_lista,cd_valor_padrao,nm_campo_hint,dv_traduz_conteudo)
		SELECT		cd_lookup_dina,cd_funcao_validacao,cd_dina_novo,nm_campo,nr_ordem,nm_titulo,dv_mostra_lista,dv_mostra_ficha,dv_mostra_filtro,dv_chave,dv_somente_leitura,
								 nm_hint,nm_lookup_tabela,nm_lookup_chave,nm_lookup_lista,nm_lookup_where,dv_obrigatorio,dv_mostra,nm_formato,nm_alias,dv_lookup_estilo,nm_classe_lista,
								 dv_edita_lista,cd_valor_padrao,nm_campo_hint,dv_traduz_conteudo 
		FROM #dina_coluna
		ORDER BY nr_ordem
		
		/* OBTEM OS NOVOS ID´S  DAS COLUNAS */
		UPDATE tdc
	       SET tdc.cd_coluna_novo = dc.cd_coluna		
		from dina_coluna dc
			INNER JOIN #dina_coluna tdc ON tdc.cd_dina_novo = dc.cd_dina
										AND tdc.nm_campo = dc.nm_campo
										AND tdc.nr_ordem = dc.nr_ordem
		WHERE dc.cd_dina = @cd_dina_novo
		
/* COLUNA CONDIÇÃO */
		DELETE FROM #output
		INSERT INTO dina_coluna_condicao (cd_coluna,vl_campo,nm_hint)
		OUTPUT inserted.id_coluna_condicao, inserted.cd_coluna, inserted.vl_campo,inserted.nm_hint 
		INTO #output (id_output,cd_valor_1,nm_campo_1,nm_campo_2)						
		SELECT	tdc.cd_coluna_novo, tdcc.vl_campo, tdcc.nm_hint
		FROM #dina_coluna_condicao tdcc
			INNER JOIN #dina_coluna tdc ON tdc.cd_coluna = tdcc.cd_coluna 
		
		/* ATUALIZA OS NOVOS ID´S DAS CONDIÇÕES */
		UPDATE tdcc
		   SET tdcc.id_coluna_condicao_novo = otp.id_output
		FROM #dina_coluna_condicao		tdcc
			INNER JOIN #dina_coluna		tdc		ON tdc.cd_coluna = tdcc.cd_coluna
			INNER JOIN #output			otp		ON otp.cd_valor_1 = tdc.cd_coluna_novo 
													AND ISNULL(otp.nm_campo_1,'N') = ISNULL(tdcc.vl_campo,'N') 
													AND ISNULL(otp.nm_campo_2,'N') = ISNULL(tdcc.nm_hint,'N')

/* COLUNA CONDIÇÃO COLUNA */
		DELETE FROM #output
		INSERT INTO dina_coluna_condicao_coluna (id_coluna_condicao,cd_coluna,dv_mostra,dv_protegido)		
		OUTPUT inserted.id_coluna_mostra_condicao,inserted.id_coluna_condicao,inserted.cd_coluna,inserted.dv_mostra,inserted.dv_protegido 
		INTO #output(id_output,cd_valor_1,cd_valor_2,cd_valor_3,cd_valor_4)
		SELECT tdcc.id_coluna_condicao_novo, tdc.cd_coluna_novo, tdccc.dv_mostra, tdccc.dv_protegido
		FROM #dina_coluna_condicao_coluna		tdccc
			INNER JOIN #dina_coluna_condicao	tdcc on tdcc.id_coluna_condicao = tdccc.id_coluna_condicao
			INNER JOIN #dina_coluna				tdc	 on tdc.cd_coluna = tdccc.cd_coluna_campo
		

/* AÇÃO */
		DELETE FROM #output
		INSERT INTO dina_acao (	cd_dina,dv_log_sistema,nm_acao,cd_tipo_implementacao,nm_implementacao,nm_implementacao_parametro,cd_tipo_evento,cd_relatorio,nm_hint,
								dv_modo,cd_barra,cd_layout,nm_mensagem_alerta,dv_padrao,nm_target,nm_servidor_remoto,nr_ordem,nr_auto_refresh,id_dominio,dv_lock_app_resource)
		
		OUTPUT inserted.cd_acao, inserted.nm_acao,inserted.cd_tipo_implementacao,inserted.nm_implementacao, inserted.nm_hint,inserted.nr_ordem
		INTO #output(id_output,nm_campo_1,cd_valor_1,nm_campo_2,nm_campo_3,cd_valor_2)
		SELECT	cd_dina_novo,dv_log_sistema,nm_acao,cd_tipo_implementacao,nm_implementacao,nm_implementacao_parametro,cd_tipo_evento,cd_relatorio,nm_hint,
				dv_modo,cd_barra,cd_layout,nm_mensagem_alerta,dv_padrao,nm_target,nm_servidor_remoto,nr_ordem,nr_auto_refresh,id_dominio,dv_lock_app_resource
		FROM #dina_acao tda
		ORDER BY tda.nr_ordem
		
		/* ATUALIZA OS NOVOS ID´S */		
		UPDATE tda
		   SET tda.cd_acao_novo = otp.id_output
		FROM #dina_acao			tda
			inner join #output	otp		ON otp.nm_campo_1 = tda.nm_acao
											AND otp.cd_valor_1 = tda.cd_tipo_implementacao
											AND otp.nm_campo_2 = tda.nm_implementacao
											AND ISNULL(otp.nm_campo_3,'N') = ISNULL(tda.nm_hint,'N')
											AND otp.cd_valor_2 = tda.nr_ordem
		

/* AÇÃO PARAMETRO */
		INSERT INTO dina_acao_parametro(cd_acao,nm_parametro)
		SELECT  tda.cd_acao_novo, tdap.nm_parametro
		FROM #dina_acao_parametro tdap
			INNER JOIN #dina_acao tda	on tda.cd_acao = tdap.cd_acao

/* AÇÃO COLUNA CONDIÇÃO AÇÃO */
		INSERT INTO dina_coluna_condicao_acao (id_coluna_condicao,cd_acao,dv_mostra)
		SELECT		tdcc.id_coluna_condicao_novo, tda.cd_acao_novo, tdcca.dv_mostra
		FROM #dina_coluna_condicao_acao			tdcca
			INNER JOIN #dina_acao				tda		ON tda.cd_acao = tdcca.cd_acao
			INNER JOIN #dina_coluna_condicao	tdcc	ON tdcc.id_coluna_condicao = tdcca.id_coluna_condicao
			INNER JOIN #dina_coluna				tdc		ON tdc.cd_coluna = tdcca.cd_coluna_condicao


		/* DADOS SELECIONADOS */
		SELECT		'#dina								' dina							, * FROM  #dina

		SELECT		'#dina_coluna						' dina_coluna					, * FROM #dina_coluna
		SELECT		'#dina_coluna_condicao				' dina_coluna_condicao			, * FROM #dina_coluna_condicao
		SELECT		'#dina_coluna_condicao_coluna		' dina_coluna_condicao_coluna	, * FROM #dina_coluna_condicao_coluna

		SELECT		'#dina_acao							' dina_acao						, * FROM #dina_acao
		SELECT		'#dina_acao_parametro				' dina_acao_parametro			, * FROM #dina_acao_parametro
		SELECT		'#dina_coluna_condicao_acao			' dina_coluna_condicao_acao		, * FROM #dina_coluna_condicao_acao
		
END TRY
BEGIN CATCH

		SELECT ERRO = ERROR_MESSAGE()
		RETURN

END CATCH

RETURN