----------------------------------------------------------------------------------------------------------------
---
--- SCRIPT PUBLICADOR DE TELA
--
-- $Revision: 1.2.2.1 $
-- $Date: 2022/05/16 14:34:15 $
----------------------------------------------------------------------------------------------------------------
DECLARE @cd_dina		   INT			= 379			  --Informe a tela que deseja gerar o script de publicação
DECLARE @versao_comentario VARCHAR(MAX) = 'T02348' --Comentário da versão
DECLARE @id_tp_perfil	int = 2
/*
tipo de perfil:
1 - não fazer nada em permissões
2 - escrever permissões apenas se não existir no destino
3 - escrever ou sobrescrever permissões no destino
*/

SET NOCOUNT ON


BEGIN TRY

		IF OBJECT_ID('tempdb..#tabela_results') IS NOT NULL
		DROP TABLE #tabela_results

		create table #tabela_results
		(
			id int identity,
			nm_string varchar(max)
		)

		--Parametro de Entrada (Código da tela DINA)

		DECLARE @cd_usuario_log varchar(100) = ''''+isnull((select cd_usuario from dina where cd_dina = @cd_dina),'legado-hp/i4pro')+''''
		--Parametro de Entrada (Versão da tela DINA)



		DECLARE @qtd_separador INT = 200
		DECLARE @insert_dina_tela_log VARCHAR(2000)
		DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)

		insert into #tabela_results(nm_string)
		select 'USE SEGCORP' + @NewLineChar 

		insert into #tabela_results(nm_string)
		select 'GO' + @NewLineChar 

		insert into #tabela_results(nm_string)
		select '' + @NewLineChar 

		insert into #tabela_results(nm_string)
		select '
		DECLARE @nr_versao_controle VARCHAR(20),
				@dt_versao_controle VARCHAR(50)
		'

		insert into #tabela_results(nm_string)
		select '' + @NewLineChar 

		insert into #tabela_results(nm_string)
		select '' + @NewLineChar 


		insert into #tabela_results(nm_string)
		select '------ VERSÃO DA TELA ---------------------------------------------' + @NewLineChar 

		insert into #tabela_results(nm_string)
		select 'SELECT  @nr_versao_controle = ''$Revision: 1.2.2.1 $'',
				@dt_versao_controle = ''$Date: 2020/11/12 18:54:15 $'''

		insert into #tabela_results(nm_string)
		select '-------------------------------------------------------------------' + @NewLineChar 

		insert into #tabela_results(nm_string)
		select '' + @NewLineChar 




		--Remove existências de tabelas temporarias
		IF OBJECT_ID('tempdb..#dina') IS NOT NULL DROP TABLE #dina
		IF OBJECT_ID('tempdb..#dina_acao') IS NOT NULL DROP TABLE #dina_acao
		IF OBJECT_ID('tempdb..#dina_acao_parametro') IS NOT NULL DROP TABLE #dina_acao_parametro
		IF OBJECT_ID('tempdb..#dina_idioma_acao') IS NOT NULL DROP TABLE #dina_idioma_acao
		IF OBJECT_ID('tempdb..#dina_perfil_acao') IS NOT NULL DROP TABLE #dina_perfil_acao
		IF OBJECT_ID('tempdb..#dina_usuario_acao') IS NOT NULL DROP TABLE #dina_usuario_acao
		IF OBJECT_ID('tempdb..#dina_coluna_condicao_acao') IS NOT NULL DROP TABLE #dina_coluna_condicao_acao
		IF OBJECT_ID('tempdb..#dina_estatistica') IS NOT NULL DROP TABLE #dina_estatistica
		IF OBJECT_ID('tempdb..#dina_coluna') IS NOT NULL DROP TABLE #dina_coluna
		IF OBJECT_ID('tempdb..#dina_coluna_condicao_coluna') IS NOT NULL DROP TABLE #dina_coluna_condicao_coluna
		IF OBJECT_ID('tempdb..#dina_idioma_coluna') IS NOT NULL DROP TABLE #dina_idioma_coluna
		IF OBJECT_ID('tempdb..#dina_coluna_condicao') IS NOT NULL DROP TABLE #dina_coluna_condicao
		IF OBJECT_ID('tempdb..#dina_idioma_dina') IS NOT NULL DROP TABLE #dina_idioma_dina
		IF OBJECT_ID('tempdb..#dina_log') IS NOT NULL DROP TABLE #dina_log
		IF OBJECT_ID('tempdb..#dina_menu') IS NOT NULL DROP TABLE #dina_menu
		IF OBJECT_ID('tempdb..#dina_idioma_menu') IS NOT NULL DROP TABLE #dina_idioma_menu
		IF OBJECT_ID('tempdb..#dina_perfil_menu') IS NOT NULL DROP TABLE #dina_perfil_menu
		IF OBJECT_ID('tempdb..#dina_usuario_menu') IS NOT NULL DROP TABLE #dina_usuario_menu
		IF OBJECT_ID('tempdb..#dina_help_telas') IS NOT NULL DROP TABLE #dina_help_telas


		--Construtor das tabelas temporárias
		CREATE TABLE #dina
		(
			cd_dina int ,
			nm_dina varchar(50),
			cd_tipo_tela int,
			nm_titulo varchar(50),
			nm_tabela varchar(255) ,
			cd_tipo_comando int ,
			nm_orderby varchar(100) ,
			nm_where varchar(300) ,
			nr_registro_pagina int ,
			dv_modo char(1) ,
			Cd_sistema int ,
			nm_query text ,
			nr_auto_refresh smallint ,
			dv_sem_link_lista bit ,
			cd_usuario varchar(10) ,
			dv_alterando bit ,
			dv_checkout bit ,
			id_usuario_checkout varchar(10) ,
			dt_checkout smalldatetime ,
			nm_set varchar(255) ,
			dv_traduz_conteudo bit
		)

		CREATE TABLE #dina_acao(
			cd_acao int   ,
			cd_dina int  ,
			dv_log_sistema bit ,
			nm_acao varchar(25) ,
			cd_tipo_implementacao smallint ,
			nm_implementacao varchar(100) ,
			nm_implementacao_parametro varchar(800) ,
			cd_tipo_evento smallint ,
			cd_relatorio int ,
			nm_hint varchar(150) ,
			dv_modo char(1) ,
			cd_barra smallint ,
			cd_layout int ,
			nm_mensagem_alerta varchar(200) ,
			dv_padrao bit ,
			nm_target varchar(10) ,
			nm_servidor_remoto varchar(20) ,
			nr_ordem smallint ,
			nr_auto_refresh int ,
			id_dominio int ,
			dv_lock_app_resource bit,
			cd_acao_new int
		)

		CREATE TABLE #dina_acao_parametro(
			id_parametro int  ,
			cd_acao int  ,
			nm_parametro varchar(40)
		)

		CREATE TABLE #dina_idioma_acao(
			cd_idioma_acao int   ,
			cd_acao int  ,
			cd_idioma int ,
			nm_acao varchar(25) ,
			nm_hint varchar(150) ,
			nm_mensagem_alerta varchar(200) 
		)

		CREATE TABLE #dina_perfil_acao(
			cd_perfil int  ,
			cd_acao int  ,
			dv_acesso bit 
		)

		CREATE TABLE #dina_usuario_acao(
			cd_acao int  ,
			Cd_usuario varchar(10)  ,
			Dv_acesso bit 
		)

		CREATE TABLE #dina_coluna(
			cd_coluna int   ,
			cd_lookup_dina int ,
			cd_funcao_validacao int ,
			cd_dina int  ,
			nm_campo varchar(50)  ,
			nr_ordem smallint ,
			nm_titulo varchar(50)  ,
			dv_mostra_lista char(1) ,
			dv_mostra_ficha char(1) ,
			dv_mostra_filtro char(1) ,
			dv_chave char(1) ,
			dv_somente_leitura char(1) ,
			nm_hint varchar(300) ,
			nm_lookup_tabela text ,
			nm_lookup_chave varchar(50) ,
			nm_lookup_lista varchar(50) ,
			nm_lookup_where varchar(400) ,
			dv_obrigatorio char(1) ,
			dv_mostra char(1) ,
			nm_formato varchar(30) ,
			nm_alias varchar(200) ,
			dv_lookup_estilo char(1) ,
			nm_classe_lista varchar(10) ,
			dv_edita_lista bit ,
			cd_valor_padrao int ,
			nm_campo_hint varchar(50) ,
			dv_traduz_conteudo bit,
			cd_coluna_new int
		)

		CREATE TABLE #dina_estatistica(
			id_estatistica int  ,
			cd_dina int ,
			cd_acao int ,
			cd_coluna int ,
			cd_relatorio int ,
			dt_inicio_execucao smalldatetime ,
			dt_fim_execucao smalldatetime ,
			nm_metodo_origem varchar(100) ,
			nm_query_executada varchar(5000) ,
			nr_io int ,
			cd_sistema int ,
			dt_estatistica smalldatetime 
		)

		CREATE TABLE #dina_idioma_coluna(
			cd_idioma_coluna int  ,
			cd_coluna int  ,
			cd_idioma int ,
			nm_titulo varchar(50) ,
			nm_hint varchar(300) 
		)

		CREATE TABLE #dina_coluna_condicao(
			id_coluna_condicao int ,
			cd_coluna int  ,
			vl_campo varchar(80) ,
			nm_hint varchar(255) ,
			id_coluna_condicao_new int
		)

		CREATE TABLE #dina_coluna_condicao_acao(
			id_coluna_mostra_acao int   ,
			id_coluna_condicao int ,
			cd_acao int  ,
			dv_mostra bit
		)

		CREATE TABLE #dina_coluna_condicao_coluna(
			id_coluna_mostra_condicao int  ,
			id_coluna_condicao int ,
			cd_coluna int  ,
			dv_mostra bit ,
			dv_protegido bit
		)

		CREATE TABLE #dina_idioma_dina(
			cd_idioma_dina int ,
			cd_dina int  ,
			cd_idioma int ,
			nm_titulo varchar(50) 
		)

		CREATE TABLE #dina_log(
			id_log int   ,
			cd_usuario varchar(10) ,
			cd_dina int ,
			nm_data_action varchar(50) ,
			dt_erro smalldatetime ,
			nm_descricao varchar(8000) 
		)

		CREATE TABLE #dina_menu(
			cd_menu int  ,
			cd_dina int ,
			Cd_empresa int ,
			Nm_menu varchar(25) ,
			Cd_sistema int ,
			Cd_menu_pai int
		)

		CREATE TABLE #dina_idioma_menu(
			cd_idioma_menu int   ,
			cd_menu int ,
			cd_idioma int ,
			nm_menu varchar(25) 
		)

		CREATE TABLE #dina_perfil_menu(
			cd_perfil int  ,
			cd_menu int  
		)

		CREATE TABLE #dina_usuario_menu(
			Cd_usuario varchar(10)  ,
			cd_menu int  
		)

		CREATE TABLE #dina_help_telas(
			id_dina_help_telas int   ,
			id_dina_help int ,
			cd_dina int 
		)


		--Inserir a referência para os ids externos das tabelas externas nas tabelas temporárias externas
		insert into #dina (cd_dina, nm_dina, cd_tipo_tela, nm_titulo, nm_tabela, cd_tipo_comando, nm_orderby, nm_where, nr_registro_pagina, dv_modo, Cd_sistema, nm_query, nr_auto_refresh, dv_sem_link_lista, cd_usuario, dv_alterando, dv_checkout, id_usuario_checkout, dt_checkout, nm_set, dv_traduz_conteudo)
		select cd_dina, nm_dina, cd_tipo_tela, nm_titulo, nm_tabela, cd_tipo_comando, nm_orderby, nm_where, nr_registro_pagina, dv_modo, Cd_sistema, nm_query, nr_auto_refresh, dv_sem_link_lista, cd_usuario, dv_alterando, dv_checkout, id_usuario_checkout, dt_checkout, nm_set, dv_traduz_conteudo from dina where cd_dina = @cd_dina

			insert into #dina_acao(cd_dina, dv_log_sistema, nm_acao, cd_tipo_implementacao, nm_implementacao, nm_implementacao_parametro, cd_tipo_evento, cd_relatorio, nm_hint, dv_modo, cd_barra, cd_layout, nm_mensagem_alerta, dv_padrao, nm_target, nm_servidor_remoto, nr_ordem, nr_auto_refresh, id_dominio, dv_lock_app_resource, cd_acao)
			select da.cd_dina, da.dv_log_sistema, da.nm_acao, da.cd_tipo_implementacao, da.nm_implementacao, da.nm_implementacao_parametro, da.cd_tipo_evento, da.cd_relatorio, da.nm_hint, da.dv_modo, da.cd_barra, da.cd_layout, da.nm_mensagem_alerta, da.dv_padrao, da.nm_target, da.nm_servidor_remoto, da.nr_ordem, da.nr_auto_refresh, da.id_dominio , da.dv_lock_app_resource, da.cd_acao
			from dina_acao da where cd_dina = @cd_dina

				insert into #dina_acao_parametro (cd_acao, nm_parametro)
				select dat.cd_acao, dap.nm_parametro
				from dina_acao_parametro dap
				join #dina_acao dat on dat.cd_acao = dap.cd_acao and dat.cd_dina = @cd_dina

				insert into #dina_idioma_acao (cd_acao, cd_idioma_acao, nm_acao, nm_hint, nm_mensagem_alerta)
				select dia.cd_acao, dia.cd_idioma_acao, dia.nm_acao, dia.nm_hint, dia.nm_mensagem_alerta
				from dina_idioma_acao dia
				join #dina_acao dat on dat.cd_acao = dia.cd_acao and dat.cd_dina = @cd_dina

				-----------------neto aqui
				if @id_tp_perfil != 1 
				begin 
					insert into #dina_perfil_acao (cd_acao, cd_perfil, dv_acesso) 
					select dpa.cd_acao, dpa.cd_perfil, dpa.dv_acesso
					from dina_perfil_acao dpa
					join #dina_acao dat on dat.cd_acao = dpa.cd_acao and dat.cd_dina = @cd_dina
				end

				insert into #dina_usuario_acao (cd_acao, Cd_usuario, Dv_acesso)
				select dua.cd_acao, dua.Cd_usuario, dua.Dv_acesso
				from dina_usuario_acao dua
				join #dina_acao dat on dat.cd_acao = dua.cd_acao and dat.cd_dina = @cd_dina

				insert into #dina_estatistica (cd_acao, cd_coluna, cd_sistema, cd_dina, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, dt_estatistica)
				select de1.cd_acao, de1.cd_coluna, de1.cd_sistema, de1.cd_dina, de1.cd_relatorio, de1.dt_inicio_execucao, de1.dt_fim_execucao, de1.nm_metodo_origem, de1.nm_query_executada, de1.nr_io, de1.dt_estatistica
				from dina_estatistica de1
				join #dina_acao dat on dat.cd_acao = de1.cd_acao and dat.cd_dina = @cd_dina

			insert into #dina_coluna (cd_valor_padrao, cd_lookup_dina, cd_funcao_validacao, cd_dina, nm_campo, nr_ordem, nm_titulo, dv_mostra_lista, dv_mostra_ficha, dv_mostra_filtro, dv_chave, dv_somente_leitura, nm_hint, nm_lookup_tabela, nm_lookup_chave, nm_lookup_lista, nm_lookup_where, dv_obrigatorio, dv_mostra, nm_formato, nm_alias, dv_lookup_estilo, nm_classe_lista, dv_edita_lista, nm_campo_hint, dv_traduz_conteudo, cd_coluna)
			select dc.cd_valor_padrao, dc.cd_lookup_dina, dc.cd_funcao_validacao, dc.cd_dina, dc.nm_campo, dc.nr_ordem, dc.nm_titulo, dc.dv_mostra_lista, dc.dv_mostra_ficha, dc.dv_mostra_filtro, dc.dv_chave, dc.dv_somente_leitura, dc.nm_hint, dc.nm_lookup_tabela, dc.nm_lookup_chave, dc.nm_lookup_lista, dc.nm_lookup_where, dc.dv_obrigatorio, dc.dv_mostra, dc.nm_formato, dc.nm_alias, dc.dv_lookup_estilo, dc.nm_classe_lista, dc.dv_edita_lista, dc.nm_campo_hint, dc.dv_traduz_conteudo, dc.cd_coluna
			from dina_coluna dc where dc.cd_dina = @cd_dina

				insert into #dina_coluna_condicao_coluna (cd_coluna, id_coluna_condicao, dv_mostra, dv_protegido)
				select dccc1.cd_coluna, dccc1.id_coluna_condicao, dccc1.dv_mostra, dccc1.dv_protegido
				from dina_coluna_condicao_coluna dccc1
				join #dina_coluna dct on dct.cd_coluna = dccc1.cd_coluna and dccc1.id_coluna_condicao is null

				insert into #dina_estatistica (id_estatistica, cd_acao, cd_coluna, cd_sistema, cd_dina, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, dt_estatistica)
				select de2.id_estatistica, de2.cd_acao, de2.cd_coluna, de2.cd_sistema, de2.cd_dina, de2.cd_relatorio, de2.dt_inicio_execucao, de2.dt_fim_execucao, de2.nm_metodo_origem, de2.nm_query_executada, de2.nr_io, de2.dt_estatistica
				from dina_estatistica de2
				join #dina_coluna dct on dct.cd_coluna = de2.cd_coluna

				insert into #dina_idioma_coluna (cd_coluna, cd_idioma ,nm_titulo, nm_hint)
				select dic.cd_coluna, dic.cd_idioma, dic.nm_titulo, dic.nm_hint
				from dina_idioma_coluna dic
				join #dina_coluna dct on dct.cd_coluna = dic.cd_coluna 

				insert into #dina_coluna_condicao (cd_coluna, vl_campo, nm_hint, id_coluna_condicao)
				select dcc.cd_coluna, dcc.vl_campo, dcc.nm_hint, dcc.id_coluna_condicao from dina_coluna_condicao dcc
				join #dina_coluna dct on dct.cd_coluna = dcc.cd_coluna

					insert into #dina_coluna_condicao_acao (id_coluna_condicao, cd_acao, dv_mostra, id_coluna_mostra_acao)
					select dcca.id_coluna_condicao, dcca.cd_acao, dcca.dv_mostra, dcca.id_coluna_mostra_acao
					from dina_coluna_condicao_acao dcca
					join #dina_coluna_condicao dcct on dcct.id_coluna_condicao = dcca.id_coluna_condicao and dcca.id_coluna_condicao is not null

					insert into #dina_coluna_condicao_coluna (cd_coluna, id_coluna_condicao, dv_mostra, dv_protegido, id_coluna_mostra_condicao)
					select dccc2.cd_coluna, dccc2.id_coluna_condicao, dccc2.dv_mostra, dccc2.dv_protegido, dccc2.id_coluna_mostra_condicao
					from dina_coluna_condicao_coluna dccc2
					where dccc2.id_coluna_condicao in(select id_coluna_condicao from #dina_coluna_condicao join #dina_coluna dct on dct.cd_dina = @cd_dina) and dccc2.id_coluna_condicao is not null

			insert into #dina_estatistica (cd_coluna, cd_sistema, cd_dina ,cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, dt_estatistica)
			select de3.cd_coluna, de3.cd_sistema, de3.cd_dina, de3.cd_relatorio, de3.dt_inicio_execucao, de3.dt_fim_execucao, de3.nm_metodo_origem, de3.nm_query_executada, de3.nr_io, de3.dt_estatistica
			from dina_estatistica de3
			where de3.cd_dina = @cd_dina and cd_coluna is null and cd_acao is null

			insert into #dina_idioma_dina (cd_idioma, cd_dina, nm_titulo)
			select did.cd_idioma, did.cd_dina, did.nm_titulo
			from dina_idioma_dina did where did.cd_dina = @cd_dina
			/*
			insert into #dina_log (cd_usuario, cd_dina, nm_data_action, dt_erro, nm_descricao)
			select dl.cd_usuario, dl.cd_dina, dl.nm_data_action, dl.dt_erro, dl.nm_descricao from dina_log dl 
			where dl.cd_dina = @cd_dina
			*/
			insert into #dina_menu (cd_menu, Cd_sistema, cd_dina, Cd_empresa, Nm_menu, Cd_menu_pai)
			select dm.cd_menu, dm.Cd_sistema, dm.cd_dina, dm.Cd_empresa, dm.Nm_menu, dm.Cd_menu_pai
			from dina_menu dm 
			where dm.cd_dina = @cd_dina

				insert into #dina_idioma_menu (cd_menu, cd_idioma, nm_menu)
				select dim.cd_menu, dim.cd_idioma, dim.nm_menu from dina_idioma_menu dim
				join #dina_menu dmt on dmt.cd_menu = dim.cd_menu 
				
				---neto aqui
				if @id_tp_perfil != 1 
				begin
					insert into #dina_perfil_menu (cd_menu, cd_perfil)
					select dpm.cd_menu, dpm.cd_perfil from dina_perfil_menu dpm
					join #dina_menu dmt on dmt.cd_menu = dpm.cd_menu 
				end 

				insert into #dina_usuario_menu (cd_menu, Cd_usuario)
				select dum.cd_menu, dum.Cd_usuario from dina_usuario_menu dum
				join #dina_menu dmt on dmt.cd_menu = dum.cd_menu

			insert into #dina_help_telas (id_dina_help, cd_dina)
			select dht.id_dina_help, dht.cd_dina
			from dina_help_telas dht
			where dht.cd_dina = @cd_dina



		--Gerar o script para deletar as tabelas internas
			insert into #tabela_results(nm_string)
		select 'DECLARE @cd_dina int = '+CONVERT(VARCHAR(MAX),@cd_dina) + @NewLineChar 
			insert into #tabela_results(nm_string)
		select 'BEGIN TRANSACTION' + @NewLineChar 
			insert into #tabela_results(nm_string)
		select 'BEGIN TRY' + @NewLineChar 
			insert into #tabela_results(nm_string)
		select 'SET NOCOUNT ON' + @NewLineChar 

		--Insere a versão na dina_tela_log
		SELECT @insert_dina_tela_log =
		'


		IF ( replace(replace('+'@nr_versao_controle'+',''v.'',''''),''a'','''') > (select max(replace(replace(nr_versao,''v.'',''''),''a'','''')) FROM dina WHERE cd_dina = '+ CONVERT(VARCHAR(MAX),@cd_dina)+'))
		begin

			INSERT INTO dina_tela_log (cd_dina, nr_versao, nm_observacao, cd_usuario, dt_inclusao_log, cd_tipo_comando, nm_dina, nm_titulo, nm_tabela) 
			SELECT
			cd_dina,
			'+ '@nr_versao_controle' + ', 
			''' + @versao_comentario + ''', 
			'+@cd_usuario_log+',
			''' + REPLACE(CONVERT(VARCHAR(MAX), GETDATE(), 121),'-','') + ''',
			''1'',
			nm_dina,
			nm_titulo,
			nm_tabela
			FROM dina
			WHERE cd_dina = '+ CONVERT(VARCHAR(20),@cd_dina)+'

		end
		'


		insert into #tabela_results(nm_string)
		SELECT @insert_dina_tela_log


		insert into #tabela_results(nm_string)
		select '
		IF OBJECT_ID('+ isnull('''tempdb..#dina''','NULL') +') IS NOT NULL DROP TABLE #dina
		IF OBJECT_ID('+ isnull('''tempdb..#dina_acao''','NULL') +') IS NOT NULL DROP TABLE #dina_acao
		IF OBJECT_ID('+ isnull('''tempdb..#dina_acao_parametro''','NULL') +') IS NOT NULL DROP TABLE #dina_acao_parametro
		IF OBJECT_ID('+ isnull('''tempdb..#dina_idioma_acao''','NULL') +') IS NOT NULL DROP TABLE #dina_idioma_acao
		IF OBJECT_ID('+ isnull('''tempdb..#dina_perfil_acao''','NULL') +') IS NOT NULL DROP TABLE #dina_perfil_acao
		IF OBJECT_ID('+ isnull('''tempdb..#dina_usuario_acao''','NULL') +') IS NOT NULL DROP TABLE #dina_usuario_acao
		IF OBJECT_ID('+ isnull('''tempdb..#dina_coluna_condicao_acao''','NULL') +') IS NOT NULL DROP TABLE #dina_coluna_condicao_acao
		IF OBJECT_ID('+ isnull('''tempdb..#dina_estatistica''','NULL') +') IS NOT NULL DROP TABLE #dina_estatistica
		IF OBJECT_ID('+ isnull('''tempdb..#dina_coluna''','NULL') +') IS NOT NULL DROP TABLE #dina_coluna
		IF OBJECT_ID('+ isnull('''tempdb..#dina_coluna_condicao_coluna''','NULL') +') IS NOT NULL DROP TABLE #dina_coluna_condicao_coluna
		IF OBJECT_ID('+ isnull('''tempdb..#dina_idioma_coluna''','NULL') +') IS NOT NULL DROP TABLE #dina_idioma_coluna
		IF OBJECT_ID('+ isnull('''tempdb..#dina_coluna_condicao''','NULL') +') IS NOT NULL DROP TABLE #dina_coluna_condicao
		IF OBJECT_ID('+ isnull('''tempdb..#dina_idioma_dina''','NULL') +') IS NOT NULL DROP TABLE #dina_idioma_dina
		IF OBJECT_ID('+ isnull('''tempdb..#dina_log''','NULL') +') IS NOT NULL DROP TABLE #dina_log
		IF OBJECT_ID('+ isnull('''tempdb..#dina_menu''','NULL') +') IS NOT NULL DROP TABLE #dina_menu
		IF OBJECT_ID('+ isnull('''tempdb..#dina_idioma_menu''','NULL') +') IS NOT NULL DROP TABLE #dina_idioma_menu
		IF OBJECT_ID('+ isnull('''tempdb..#dina_perfil_menu''','NULL') +') IS NOT NULL DROP TABLE #dina_perfil_menu
		IF OBJECT_ID('+ isnull('''tempdb..#dina_usuario_menu''','NULL') +') IS NOT NULL DROP TABLE #dina_usuario_menu
		IF OBJECT_ID('+ isnull('''tempdb..#dina_help_telas''','NULL') +') IS NOT NULL DROP TABLE #dina_help_telas' + @NewLineChar +

		'CREATE TABLE #dina
		(
			cd_dina int ,
			nm_dina varchar(50),
			cd_tipo_tela int,
			nm_titulo varchar(50),
			nm_tabela varchar(255) ,
			cd_tipo_comando int ,
			nm_orderby varchar(100) ,
			nm_where varchar(300) ,
			nr_registro_pagina int ,
			dv_modo char(1) ,
			Cd_sistema int ,
			nm_query text ,
			nr_auto_refresh smallint ,
			dv_sem_link_lista bit ,
			cd_usuario varchar(10) ,
			dv_alterando bit ,
			dv_checkout bit ,
			id_usuario_checkout varchar(10) ,
			dt_checkout smalldatetime ,
			nm_set varchar(255) ,
			dv_traduz_conteudo bit
		)' + @NewLineChar +

		'CREATE TABLE #dina_acao(
			cd_acao int   ,
			cd_dina int  ,
			dv_log_sistema bit ,
			nm_acao varchar(25) ,
			cd_tipo_implementacao smallint ,
			nm_implementacao varchar(100) ,
			nm_implementacao_parametro varchar(800) ,
			cd_tipo_evento smallint ,
			cd_relatorio int ,
			nm_hint varchar(150) ,
			dv_modo char(1) ,
			cd_barra smallint ,
			cd_layout int ,
			nm_mensagem_alerta varchar(200) ,
			dv_padrao bit ,
			nm_target varchar(10) ,
			nm_servidor_remoto varchar(20) ,
			nr_ordem smallint ,
			nr_auto_refresh int ,
			id_dominio int ,
			dv_lock_app_resource bit,
			cd_acao_new int
		)' + @NewLineChar + 

		'CREATE TABLE #dina_acao_parametro(
			id_parametro int  ,
			cd_acao int  ,
			nm_parametro varchar(40)
		)' + @NewLineChar +

		'CREATE TABLE #dina_idioma_acao(
			cd_idioma_acao int   ,
			cd_acao int  ,
			cd_idioma int ,
			nm_acao varchar(25) ,
			nm_hint varchar(150) ,
			nm_mensagem_alerta varchar(200) 
		)' + @NewLineChar +

		'CREATE TABLE #dina_perfil_acao(
			cd_perfil int  ,
			cd_acao int  ,
			dv_acesso bit 
		)' + @NewLineChar +

		'CREATE TABLE #dina_usuario_acao(
			cd_acao int  ,
			Cd_usuario varchar(10)  ,
			Dv_acesso bit 
		)' + @NewLineChar +

		'CREATE TABLE #dina_coluna(
			cd_coluna int   ,
			cd_lookup_dina int ,
			cd_funcao_validacao int ,
			cd_dina int  ,
			nm_campo varchar(50)  ,
			nr_ordem smallint ,
			nm_titulo varchar(50)  ,
			dv_mostra_lista char(1) ,
			dv_mostra_ficha char(1) ,
			dv_mostra_filtro char(1) ,
			dv_chave char(1) ,
			dv_somente_leitura char(1) ,
			nm_hint varchar(300) ,
			nm_lookup_tabela text ,
			nm_lookup_chave varchar(50) ,
			nm_lookup_lista varchar(50) ,
			nm_lookup_where varchar(400) ,
			dv_obrigatorio char(1) ,
			dv_mostra char(1) ,
			nm_formato varchar(30) ,
			nm_alias varchar(200) ,
			dv_lookup_estilo char(1) ,
			nm_classe_lista varchar(10) ,
			dv_edita_lista bit ,
			cd_valor_padrao int ,
			nm_campo_hint varchar(50) ,
			dv_traduz_conteudo bit,
			cd_coluna_new int
		)' + @NewLineChar +

		'CREATE TABLE #dina_estatistica(
			id_estatistica int  ,
			cd_dina int ,
			cd_acao int ,
			cd_coluna int ,
			cd_relatorio int ,
			dt_inicio_execucao smalldatetime ,
			dt_fim_execucao smalldatetime ,
			nm_metodo_origem varchar(100) ,
			nm_query_executada varchar(5000) ,
			nr_io int ,
			cd_sistema int ,
			dt_estatistica smalldatetime 
		)' + @NewLineChar +

		'CREATE TABLE #dina_idioma_coluna(
			cd_idioma_coluna int  ,
			cd_coluna int  ,
			cd_idioma int ,
			nm_titulo varchar(50) ,
			nm_hint varchar(300) 
		)' + @NewLineChar +

		'CREATE TABLE #dina_coluna_condicao(
			id_coluna_condicao int ,
			cd_coluna int  ,
			vl_campo varchar(80) ,
			nm_hint varchar(255) ,
			id_coluna_condicao_new int
		)' + @NewLineChar +

		'CREATE TABLE #dina_coluna_condicao_acao(
			id_coluna_mostra_acao int   ,
			id_coluna_condicao int ,
			cd_acao int  ,
			dv_mostra bit 
		)' + @NewLineChar +

		'CREATE TABLE #dina_coluna_condicao_coluna(
			id_coluna_mostra_condicao int  ,
			id_coluna_condicao int ,
			cd_coluna int  ,
			dv_mostra bit ,
			dv_protegido bit 
		)' + @NewLineChar +

		'CREATE TABLE #dina_idioma_dina(
			cd_idioma_dina int ,
			cd_dina int  ,
			cd_idioma int ,
			nm_titulo varchar(50) 
		)' + @NewLineChar +

		'CREATE TABLE #dina_log(
			id_log int   ,
			cd_usuario varchar(10) ,
			cd_dina int ,
			nm_data_action varchar(50) ,
			dt_erro smalldatetime ,
			nm_descricao varchar(8000) 
		)' + @NewLineChar +

		'CREATE TABLE #dina_menu(
			cd_menu int  ,
			cd_dina int ,
			Cd_empresa int ,
			Nm_menu varchar(25) ,
			Cd_sistema int ,
			Cd_menu_pai int
		)' + @NewLineChar +

		'CREATE TABLE #dina_idioma_menu(
			cd_idioma_menu int   ,
			cd_menu int ,
			cd_idioma int ,
			nm_menu varchar(25) 
		)' + @NewLineChar +

		'CREATE TABLE #dina_perfil_menu(
			cd_perfil int  ,
			cd_menu int  
		)' + @NewLineChar +

		'CREATE TABLE #dina_usuario_menu(
			Cd_usuario varchar(10)  ,
			cd_menu int  
		)' + @NewLineChar +

		'CREATE TABLE #dina_help_telas(
			id_dina_help_telas int   ,
			id_dina_help int ,
			cd_dina int 
		)' + @NewLineChar 

				insert into #tabela_results(nm_string)
			select '
			delete from dina_help_telas
			where cd_dina = @cd_dina' + @NewLineChar + '

				delete dum from dina_usuario_menu dum
				join dina_menu dm on dm.cd_menu = dum.cd_menu where cd_dina = @cd_dina' + @NewLineChar + '
				'+
				'

				if '+convert(varchar(100),@id_tp_perfil)+' = 3
				begin
					delete dpm from dina_perfil_menu dpm
					join dina_menu dm on dm.cd_menu = dpm.cd_menu where cd_dina = @cd_dina' + @NewLineChar + '
				end

				delete dim from dina_idioma_menu dim
				join dina_menu dm on dm.cd_menu = dim.cd_menu where cd_dina = @cd_dina' + @NewLineChar + '

			delete from dina_menu
			where cd_dina = @cd_dina' + @NewLineChar + '

			delete from dina_idioma_dina
			where cd_dina = @cd_dina' + @NewLineChar + '

			delete from dina_estatistica
			where cd_dina = @cd_dina' + @NewLineChar + '

					delete dccc from dina_coluna_condicao_coluna dccc
					where dccc.id_coluna_condicao in (select id_coluna_condicao from dina_coluna_condicao where cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina)) and dccc.id_coluna_condicao is not null' + @NewLineChar + '

					delete dcca from dina_coluna_condicao_acao dcca
					where dcca.id_coluna_condicao in (select id_coluna_condicao from dina_coluna_condicao where cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina)) and dcca.id_coluna_condicao is not null' + @NewLineChar + '

				delete dcc from dina_coluna_condicao dcc
				where dcc.cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina)' + @NewLineChar + '

				delete dic from dina_idioma_coluna dic
				join dina_coluna dc on dc.cd_coluna = dic.cd_coluna where cd_dina = @cd_dina' + @NewLineChar + '

				delete de from dina_estatistica de
				join dina_coluna dc on dc.cd_coluna = de.cd_coluna where dc.cd_dina = @cd_dina' + @NewLineChar + '

				delete dccc from dina_coluna_condicao_coluna dccc
				where dccc.cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina)' + @NewLineChar + '

				delete de from dina_estatistica de
				join dina_acao da on da.cd_acao = de.cd_acao where da.cd_dina = @cd_dina' + @NewLineChar + '

				delete dcca from dina_coluna_condicao_acao dcca
				join dina_acao da on da.cd_acao = dcca.cd_acao where cd_dina = @cd_dina' + @NewLineChar + '

				delete dua from dina_usuario_acao dua
				join dina_acao da on da.cd_acao = dua.cd_acao where cd_dina = @cd_dina' + @NewLineChar + '

				'+
				'

				if '+convert(varchar(100),@id_tp_perfil)+' = 3
				begin
					delete dpa from dina_perfil_acao dpa
					join dina_acao da on da.cd_acao = dpa.cd_acao where cd_dina = @cd_dina' + @NewLineChar + '
				end

				delete dia from dina_idioma_acao dia
				join dina_acao da on da.cd_acao = dia.cd_acao where cd_dina = @cd_dina' + @NewLineChar + '

				delete dap from dina_acao_parametro dap
				join dina_acao da on da.cd_acao = dap.cd_acao where cd_dina = @cd_dina' + @NewLineChar + '

			delete from dina_coluna
			where cd_dina = @cd_dina' + @NewLineChar + '

			delete from dina_acao
			where cd_dina = @cd_dina' + @NewLineChar + '

		ALTER TABLE dina_coluna NOCHECK CONSTRAINT ALL 
		ALTER TABLE dina_log NOCHECK CONSTRAINT ALL

		 delete from dina
		 where cd_dina = @cd_dina

		ALTER TABLE dina_coluna WITH NOCHECK CHECK CONSTRAINT ALL 
		ALTER TABLE dina_log WITH NOCHECK CHECK CONSTRAINT ALL
		' + @NewLineChar


		--Gerar o script para inserir nas tabelas temporárias internas a partir do que está gravado nas tabelas temporárias externas
		--Variáveis utilizadas nos cursores
		DECLARE @nm_dina varchar(50)
		DECLARE @cd_tipo_tela int
		DECLARE @nm_titulo varchar(50)
		DECLARE @nm_tabela varchar(255)
		DECLARE @cd_tipo_comando int
		DECLARE @nm_orderby varchar(100)
		DECLARE @nm_where varchar(300)
		DECLARE @nr_registro_pagina int
		DECLARE @dv_modo char(1)
		DECLARE @Cd_sistema int
		DECLARE @nm_query varchar(max)
		DECLARE @nr_auto_refresh smallint
		DECLARE @dv_sem_link_lista bit
		DECLARE @cd_usuario varchar(10)
		DECLARE @dv_alterando bit
		DECLARE @dv_checkout bit
		DECLARE @id_usuario_checkout varchar(10)
		DECLARE @dt_checkout smalldatetime
		DECLARE @nm_set varchar(255)
		DECLARE @dv_traduz_conteudo bit
		DECLARE @cd_acao int
		DECLARE @dv_log_sistema bit
		DECLARE @nm_acao varchar(25)
		DECLARE @cd_tipo_implementacao smallint
		DECLARE @nm_implementacao varchar(100)
		DECLARE @nm_implementacao_parametro varchar(800)
		DECLARE @cd_tipo_evento smallint
		DECLARE @cd_relatorio int
		DECLARE @nm_hint varchar(150)
		DECLARE @cd_barra smallint
		DECLARE @cd_layout int
		DECLARE @nm_mensagem_alerta varchar(200)
		DECLARE @dv_padrao bit
		DECLARE @nm_target varchar(10)
		DECLARE @nm_servidor_remoto varchar(20)
		DECLARE @nr_ordem smallint
		DECLARE @id_dominio int
		DECLARE @dv_lock_app_resource bit
		DECLARE @cd_acao_new int
		DECLARE @id_parametro int
		DECLARE @nm_parametro varchar(40)
		DECLARE @cd_idioma_acao int
		DECLARE @cd_idioma int
		DECLARE @cd_perfil int
		DECLARE @dv_acesso bit
		DECLARE @id_estatistica int
		DECLARE @cd_coluna int
		DECLARE @dt_inicio_execucao smalldatetime
		DECLARE @dt_fim_execucao smalldatetime
		DECLARE @nm_metodo_origem varchar(100)
		DECLARE @nm_query_executada varchar(5000)
		DECLARE @nr_io int
		DECLARE @dt_estatistica smalldatetime
		DECLARE @cd_lookup_dina int
		DECLARE @cd_funcao_validacao int
		DECLARE @nm_campo varchar(50)
		DECLARE @dv_mostra_lista char(1)
		DECLARE @dv_mostra_ficha char(1)
		DECLARE @dv_mostra_filtro char(1)
		DECLARE @dv_chave char(1)
		DECLARE @dv_somente_leitura char(1)
		DECLARE @nm_lookup_tabela varchar(max)
		DECLARE @nm_lookup_chave varchar(50)
		DECLARE @nm_lookup_lista varchar(50)
		DECLARE @nm_lookup_where varchar(400)
		DECLARE @dv_obrigatorio char(1)
		DECLARE @dv_mostra char(1)
		DECLARE @nm_formato varchar(30)
		DECLARE @nm_alias varchar(200)
		DECLARE @dv_lookup_estilo char(1)
		DECLARE @nm_classe_lista varchar(10)
		DECLARE @dv_edita_lista bit
		DECLARE @cd_valor_padrao int
		DECLARE @nm_campo_hint varchar(50)
		DECLARE @cd_coluna_new int
		DECLARE @id_coluna_mostra_condicao int
		DECLARE @id_coluna_condicao int
		DECLARE @dv_protegido bit
		DECLARE @cd_idioma_coluna int
		DECLARE @vl_campo varchar(80)
		DECLARE @id_coluna_condicao_new int
		DECLARE @id_coluna_mostra_acao int
		DECLARE @cd_idioma_dina int
		DECLARE @cd_menu int
		DECLARE @cd_empresa int
		DECLARE @nm_menu varchar(25)
		DECLARE @cd_menu_pai int
		DECLARE @cd_idioma_menu int
		DECLARE @id_dina_help_telas int
		DECLARE @id_dina_help int




		--DINA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 2) + 'DINA' + REPLICATE('-', @qtd_separador)
		DECLARE cursor_dina CURSOR FOR
		SELECT cd_dina, nm_dina, cd_tipo_tela, nm_titulo, nm_tabela, cd_tipo_comando, nm_orderby, nm_where, nr_registro_pagina, dv_modo, Cd_sistema, nm_query, nr_auto_refresh, dv_sem_link_lista, cd_usuario, dv_alterando, dv_checkout, id_usuario_checkout, dt_checkout, nm_set, dv_traduz_conteudo
		FROM #dina
		WHERE cd_dina = @cd_dina

		OPEN cursor_dina
		FETCH NEXT FROM cursor_dina INTO @cd_dina, @nm_dina, @cd_tipo_tela, @nm_titulo, @nm_tabela, @cd_tipo_comando, @nm_orderby, @nm_where, @nr_registro_pagina, @dv_modo, @Cd_sistema, @nm_query, @nr_auto_refresh, @dv_sem_link_lista, @cd_usuario, @dv_alterando, @dv_checkout, @id_usuario_checkout, @dt_checkout, @nm_set, @dv_traduz_conteudo

		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			insert into #tabela_results(nm_string)
			select'
			set identity_insert dina on
			insert into #dina (cd_dina, nm_dina, cd_tipo_tela, nm_titulo, nm_tabela, cd_tipo_comando, nm_orderby, nm_where, nr_registro_pagina, dv_modo, Cd_sistema, nm_query, nr_auto_refresh, dv_sem_link_lista, cd_usuario, dv_alterando, dv_checkout, id_usuario_checkout, dt_checkout, nm_set, dv_traduz_conteudo)
			select ' + isnull(convert(varchar(max),@cd_dina),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_dina),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@cd_tipo_tela),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_titulo),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_tabela),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@cd_tipo_comando),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_orderby),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_where),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@nr_registro_pagina),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_modo),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@Cd_sistema),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_query),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@nr_auto_refresh),'NULL') +', '+ isnull(convert(varchar(max),@dv_sem_link_lista),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@cd_usuario),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@dv_alterando),'NULL') +', '+ isnull(convert(varchar(max),@dv_checkout),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@id_usuario_checkout),'''','''''')+'''','NULL') +', '+ isnull('''' + convert(varchar(max),@dt_checkout,121)+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_set),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@dv_traduz_conteudo),'NULL') +'
			set identity_insert dina off'
			+ @NewLineChar 
			FETCH NEXT FROM cursor_dina INTO @cd_dina, @nm_dina, @cd_tipo_tela, @nm_titulo, @nm_tabela, @cd_tipo_comando, @nm_orderby, @nm_where, @nr_registro_pagina, @dv_modo, @Cd_sistema, @nm_query, @nr_auto_refresh, @dv_sem_link_lista, @cd_usuario, @dv_alterando, @dv_checkout, @id_usuario_checkout, @dt_checkout, @nm_set, @dv_traduz_conteudo
		END
		CLOSE cursor_dina
		DEALLOCATE cursor_dina

		--DINA_ACAO
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 6) + 'DINA_ACAO' + REPLICATE('-', @qtd_separador)
			DECLARE cursor_dina CURSOR FOR
			SELECT cd_acao, cd_dina, dv_log_sistema, nm_acao, cd_tipo_implementacao, nm_implementacao, nm_implementacao_parametro, cd_tipo_evento, cd_relatorio, nm_hint, dv_modo, cd_barra, cd_layout, nm_mensagem_alerta, dv_padrao, nm_target, nm_servidor_remoto, nr_ordem, nr_auto_refresh, id_dominio, dv_lock_app_resource
			FROM #dina_acao
			WHERE cd_dina = @cd_dina ORDER BY cd_acao

			OPEN cursor_dina
			FETCH NEXT FROM cursor_dina INTO @cd_acao, @cd_dina, @dv_log_sistema, @nm_acao, @cd_tipo_implementacao, @nm_implementacao, @nm_implementacao_parametro, @cd_tipo_evento, @cd_relatorio, @nm_hint, @dv_modo, @cd_barra, @cd_layout, @nm_mensagem_alerta, @dv_padrao, @nm_target, @nm_servidor_remoto, @nr_ordem, @nr_auto_refresh, @id_dominio, @dv_lock_app_resource

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into #tabela_results(nm_string)
				select'
				insert into #dina_acao (cd_acao, cd_dina, dv_log_sistema, nm_acao, cd_tipo_implementacao, nm_implementacao, nm_implementacao_parametro, cd_tipo_evento, cd_relatorio, nm_hint, dv_modo, cd_barra, cd_layout, nm_mensagem_alerta, dv_padrao, nm_target, nm_servidor_remoto, nr_ordem, nr_auto_refresh, id_dominio, dv_lock_app_resource)
				select '+ isnull(convert(varchar(max),@cd_acao),'NULL') +' ,'+ isnull(convert(varchar(max),@cd_dina),'NULL') +' ,'+ isnull(convert(varchar(max),@dv_log_sistema),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_acao),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@cd_tipo_implementacao),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_implementacao),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_implementacao_parametro),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@cd_tipo_evento),'NULL') +', '+ isnull(convert(varchar(max),@cd_relatorio),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_hint),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_modo),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@cd_barra),'NULL') +', '+ isnull(convert(varchar(max),@cd_layout),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_mensagem_alerta),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@dv_padrao),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_target),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_servidor_remoto),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@nr_ordem),'NULL') +', '+ isnull(convert(varchar(max),@nr_auto_refresh),'NULL') +', '+ isnull(convert(varchar(max),@id_dominio),'NULL') +', '+ isnull(convert(varchar(max),@dv_lock_app_resource),'NULL')
				+ @NewLineChar
				FETCH NEXT FROM cursor_dina INTO @cd_acao, @cd_dina, @dv_log_sistema, @nm_acao, @cd_tipo_implementacao, @nm_implementacao, @nm_implementacao_parametro, @cd_tipo_evento, @cd_relatorio, @nm_hint, @dv_modo, @cd_barra, @cd_layout, @nm_mensagem_alerta, @dv_padrao, @nm_target, @nm_servidor_remoto, @nr_ordem, @nr_auto_refresh, @id_dominio, @dv_lock_app_resource
			END
			CLOSE cursor_dina
			DEALLOCATE cursor_dina

		--DINA_ACAO_PARAMETRO
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_ACAO_PARAMETRO' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT id_parametro, cd_acao, nm_parametro
				FROM #dina_acao_parametro ORDER BY id_parametro

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @id_parametro, @cd_acao, @nm_parametro

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_acao_parametro (id_parametro, cd_acao, nm_parametro)
					select '+ isnull(convert(varchar(max),@id_parametro),'NULL') +', '+ isnull(convert(varchar(max),@cd_acao),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_parametro),'''','''''')+'''','NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @id_parametro, @cd_acao, @nm_parametro
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_IDIOMA_ACAO
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_IDIOMA_ACAO' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT cd_idioma_acao, cd_acao, cd_idioma, nm_acao, nm_hint, nm_mensagem_alerta
				FROM #dina_idioma_acao ORDER BY cd_idioma_acao

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @cd_idioma_acao, @cd_acao, @cd_idioma, @nm_acao, @nm_hint, @nm_mensagem_alerta

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_idioma_acao (cd_idioma_acao, cd_acao, cd_idioma, nm_acao, nm_hint, nm_mensagem_alerta)
					select '+ isnull(convert(varchar(max),@cd_idioma_acao),'NULL') +', '+ isnull(convert(varchar(max),@cd_acao),'NULL') +', '+ isnull(convert(varchar(max),@cd_idioma),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_acao),'''','''''')+'''','NULL') + ', ' + isnull('''' + replace(convert(varchar(max),@nm_hint),'''','''''')+'''','NULL') + ', ' + isnull('''' + replace(convert(varchar(max),@nm_mensagem_alerta),'''','''''')+'''','NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @cd_idioma_acao, @cd_acao, @cd_idioma, @nm_acao, @nm_hint, @nm_mensagem_alerta
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_PERFIL_ACAO neto aqui
		if @id_tp_perfil != 1 
		begin 
			insert into #tabela_results(nm_string)
			SELECT REPLICATE('-', 10) + 'DINA_PERFIL_ACAO' + REPLICATE('-', @qtd_separador)

				DECLARE cursor_dina CURSOR FOR
				SELECT cd_perfil, cd_acao, dv_acesso
				FROM #dina_perfil_acao ORDER BY cd_perfil

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @cd_perfil, @cd_acao, @dv_acesso

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_perfil_acao (cd_perfil, cd_acao, dv_acesso)
					select ' + isnull(convert(varchar(max),@cd_perfil),'NULL') +', '+ isnull(convert(varchar(max),@cd_acao),'NULL') +' ,'+ isnull(convert(varchar(max),@dv_acesso),'NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @cd_perfil, @cd_acao, @dv_acesso
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina
		end
		--DINA_USUARIO_ACAO
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_USUARIO_ACAO' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT cd_acao, Cd_usuario, Dv_acesso
				FROM #dina_usuario_acao ORDER BY Cd_usuario

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @cd_acao, @Cd_usuario, @Dv_acesso

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_usuario_acao (cd_acao, Cd_usuario, Dv_acesso)
					select '+ isnull(convert(varchar(max),@cd_acao),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@Cd_usuario),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@Dv_acesso),'NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @cd_acao, @Cd_usuario, @Dv_acesso
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_ESTATISTICA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_ESTATISTICA' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT id_estatistica, cd_dina, cd_acao, cd_coluna, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, cd_sistema, dt_estatistica
				FROM #dina_estatistica
				WHERE cd_acao is not null ORDER BY id_estatistica

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @id_estatistica, @cd_dina, @cd_acao, @cd_coluna, @cd_relatorio, @dt_inicio_execucao, @dt_fim_execucao, @nm_metodo_origem, @nm_query_executada, @nr_io, @cd_sistema, @dt_estatistica

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_estatistica (id_estatistica, cd_dina, cd_acao, cd_coluna, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, cd_sistema, dt_estatistica)
					select ' + isnull(convert(varchar(max),@id_estatistica),'NULL') +', ' + isnull(convert(varchar(max),@cd_dina),'NULL') +', ' + isnull(convert(varchar(max),@cd_acao),'NULL') +', ' + isnull(convert(varchar(max),@cd_coluna),'NULL') +', '+ isnull(convert(varchar(max),@cd_relatorio),'NULL') +', '+ isnull('''' + convert(varchar(max),@dt_inicio_execucao,121)+'''','NULL') +', '+ isnull('''' + convert(varchar(max),@dt_fim_execucao,121)+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_metodo_origem),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_query_executada),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@nr_io),'NULL') +', '+ isnull(convert(varchar(max),@cd_sistema),'NULL') +', '+ isnull('''' + convert(varchar(max),@dt_estatistica,121)+'''','NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @id_estatistica, @cd_dina, @cd_acao, @cd_coluna, @cd_relatorio, @dt_inicio_execucao, @dt_fim_execucao, @nm_metodo_origem, @nm_query_executada, @nr_io, @cd_sistema, @dt_estatistica
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_COLUNA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 6) + 'DINA_COLUNA' + REPLICATE('-', @qtd_separador)
			DECLARE cursor_dina CURSOR FOR
			SELECT dct.cd_coluna, dct.cd_lookup_dina, dct.cd_funcao_validacao, dt.cd_dina, dct.nm_campo, dct.nr_ordem, dct.nm_titulo, dct.dv_mostra_lista, dct.dv_mostra_ficha, dct.dv_mostra_filtro, dct.dv_chave, dct.dv_somente_leitura, dct.nm_hint, dct.nm_lookup_tabela, dct.nm_lookup_chave, dct.nm_lookup_lista, dct.nm_lookup_where, dct.dv_obrigatorio, dct.dv_mostra, dct.nm_formato, dct.nm_alias, dct.dv_lookup_estilo, dct.nm_classe_lista, dct.dv_edita_lista, dct.cd_valor_padrao, dct.nm_campo_hint, dct.dv_traduz_conteudo
			FROM #dina_coluna dct
			JOIN #dina dt on dt.cd_dina = @cd_dina ORDER BY dct.cd_coluna

			OPEN cursor_dina
			FETCH NEXT FROM cursor_dina INTO @cd_coluna, @cd_lookup_dina, @cd_funcao_validacao, @cd_dina, @nm_campo, @nr_ordem, @nm_titulo, @dv_mostra_lista, @dv_mostra_ficha, @dv_mostra_filtro, @dv_chave, @dv_somente_leitura, @nm_hint, @nm_lookup_tabela, @nm_lookup_chave, @nm_lookup_lista, @nm_lookup_where, @dv_obrigatorio, @dv_mostra, @nm_formato, @nm_alias, @dv_lookup_estilo, @nm_classe_lista, @dv_edita_lista, @cd_valor_padrao, @nm_campo_hint, @dv_traduz_conteudo

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into #tabela_results(nm_string)
				select'
				insert into #dina_coluna (cd_coluna, cd_lookup_dina, cd_funcao_validacao, cd_dina, nm_campo, nr_ordem, nm_titulo, dv_mostra_lista, dv_mostra_ficha, dv_mostra_filtro, dv_chave, dv_somente_leitura, nm_hint, nm_lookup_tabela, nm_lookup_chave, nm_lookup_lista, nm_lookup_where, dv_obrigatorio, dv_mostra, nm_formato, nm_alias, dv_lookup_estilo, nm_classe_lista, dv_edita_lista, cd_valor_padrao, nm_campo_hint, dv_traduz_conteudo)
				select ' + isnull(convert(varchar(max),@cd_coluna),'NULL') +', '+ isnull(convert(varchar(max),@cd_lookup_dina),'NULL') +', '+ isnull(convert(varchar(max),@cd_funcao_validacao),'NULL') +', '+ isnull(convert(varchar(max),@cd_dina),'NULL') +' ,'+ isnull('''' + replace(convert(varchar(max),@nm_campo),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@nr_ordem),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_titulo),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_mostra_lista),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_mostra_ficha),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_mostra_filtro),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_chave),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_somente_leitura),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_hint),'''','''''')+'''','NULL') +', '+ isnull('''' + convert(varchar(max),replace(convert(varchar(max),@nm_lookup_tabela),'''',''''''))+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_lookup_chave),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_lookup_lista),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_lookup_where),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_obrigatorio),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_mostra),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_formato),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_alias),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@dv_lookup_estilo),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_classe_lista),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@dv_edita_lista),'NULL') +', '+ isnull(convert(varchar(max),@cd_valor_padrao),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_campo_hint),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@dv_traduz_conteudo),'NULL')
				+ @NewLineChar
				FETCH NEXT FROM cursor_dina INTO @cd_coluna, @cd_lookup_dina, @cd_funcao_validacao, @cd_dina, @nm_campo, @nr_ordem, @nm_titulo, @dv_mostra_lista, @dv_mostra_ficha, @dv_mostra_filtro, @dv_chave, @dv_somente_leitura, @nm_hint, @nm_lookup_tabela, @nm_lookup_chave, @nm_lookup_lista, @nm_lookup_where, @dv_obrigatorio, @dv_mostra, @nm_formato, @nm_alias, @dv_lookup_estilo, @nm_classe_lista, @dv_edita_lista, @cd_valor_padrao, @nm_campo_hint, @dv_traduz_conteudo
			END
			CLOSE cursor_dina
			DEALLOCATE cursor_dina

		--DINA_COLUNA_CONDICAO_COLUNA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_COLUNA_CONDICAO_COLUNA' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT id_coluna_mostra_condicao, id_coluna_condicao, cd_coluna, dv_mostra, dv_protegido
				FROM #dina_coluna_condicao_coluna dccct
				WHERE id_coluna_condicao is null ORDER BY id_coluna_mostra_condicao

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @id_coluna_mostra_condicao, @id_coluna_condicao, @cd_coluna, @dv_mostra, @dv_protegido

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_coluna_condicao_coluna (id_coluna_mostra_condicao, id_coluna_condicao, cd_coluna, dv_mostra, dv_protegido)
					select '+ isnull(convert(varchar(max),@id_coluna_mostra_condicao),'NULL') +', '+ isnull(convert(varchar(max),@id_coluna_condicao),'NULL') +', '+ isnull(convert(varchar(max),@cd_coluna),'NULL') +', '+ isnull(convert(varchar(max),@dv_mostra),'NULL') +', '+ isnull(convert(varchar(max),@dv_protegido),'NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @id_coluna_mostra_condicao, @id_coluna_condicao, @cd_coluna, @dv_mostra, @dv_protegido
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_ESTATISTICA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_ESTATISTICA' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT det.id_estatistica, det.cd_dina, det.cd_acao, dct.cd_coluna, det.cd_relatorio, det.dt_inicio_execucao, det.dt_fim_execucao, det.nm_metodo_origem, det.nm_query_executada, det.nr_io, det.cd_sistema, det.dt_estatistica
				FROM #dina_estatistica det
				JOIN #dina_coluna dct on det.cd_coluna = dct.cd_coluna and det.cd_coluna is not null ORDER BY det.id_estatistica

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @id_estatistica, @cd_dina, @cd_acao, @cd_coluna, @cd_relatorio, @dt_inicio_execucao, @dt_fim_execucao, @nm_metodo_origem, @nm_query_executada, @nr_io, @cd_sistema, @dt_estatistica

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_estatistica (id_estatistica, cd_dina, cd_acao, cd_coluna, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, cd_sistema, dt_estatistica)
					select ' + isnull(convert(varchar(max),@id_estatistica),'NULL') +', ' + isnull(convert(varchar(max),@cd_dina),'NULL') +', '+ isnull(convert(varchar(max),@cd_acao),'NULL') +', '+ isnull(convert(varchar(max),@cd_coluna),'NULL') +', '+ isnull(convert(varchar(max),@cd_relatorio),'NULL') +', '+ isnull('''' + convert(varchar(max),@dt_inicio_execucao,121)+'''','NULL') +', '+ isnull('''' + convert(varchar(max),@dt_fim_execucao,121)+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_metodo_origem),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_query_executada),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@nr_io),'NULL') +', '+ isnull(convert(varchar(max),@cd_sistema),'NULL') +', '+ isnull('''' + convert(varchar(max),@dt_estatistica,121)+'''', 'NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @id_estatistica, @cd_dina, @cd_acao, @cd_coluna, @cd_relatorio, @dt_inicio_execucao, @dt_fim_execucao, @nm_metodo_origem, @nm_query_executada, @nr_io, @cd_sistema, @dt_estatistica
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_IDIOMA_COLUNA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_IDIOMA_COLUNA' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT cd_idioma_coluna, cd_coluna, cd_idioma, nm_titulo, nm_hint
				FROM #dina_idioma_coluna ORDER BY cd_idioma_coluna

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @cd_idioma_coluna, @cd_coluna, @cd_idioma, @nm_titulo, @nm_hint

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_idioma_coluna (cd_idioma_coluna, cd_coluna, cd_idioma, nm_titulo, nm_hint)
					select ' + isnull(convert(varchar(max),@cd_idioma_coluna),'NULL') +', '+ isnull(convert(varchar(max),@cd_coluna),'NULL') +', '+ isnull(convert(varchar(max),@cd_idioma),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_titulo),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_hint),'''','''''')+'''','NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @cd_idioma_coluna, @cd_coluna, @cd_idioma, @nm_titulo, @nm_hint
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_COLUNA_CONDICAO
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_COLUNA_CONDICAO' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT id_coluna_condicao, cd_coluna, vl_campo, nm_hint
				FROM #dina_coluna_condicao ORDER BY id_coluna_condicao

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @id_coluna_condicao, @cd_coluna, @vl_campo, @nm_hint

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_coluna_condicao (id_coluna_condicao, cd_coluna, vl_campo, nm_hint)
					select '+ isnull(convert(varchar(max),@id_coluna_condicao),'NULL') +', '+ isnull(convert(varchar(max),@cd_coluna),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@vl_campo),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_hint),'''','''''')+'''','NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @id_coluna_condicao, @cd_coluna, @vl_campo, @nm_hint
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_COLUNA_CONDICAO_ACAO
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 14) + 'DINA_COLUNA_CONDICAO_ACAO' + REPLICATE('-', @qtd_separador)
					DECLARE cursor_dina CURSOR FOR
					SELECT id_coluna_mostra_acao, id_coluna_condicao, cd_acao, dv_mostra
					FROM #dina_coluna_condicao_acao ORDER BY id_coluna_mostra_acao

					OPEN cursor_dina
					FETCH NEXT FROM cursor_dina INTO @id_coluna_mostra_acao, @id_coluna_condicao, @cd_acao, @dv_mostra

					WHILE @@FETCH_STATUS = 0
					BEGIN
						insert into #tabela_results(nm_string)
						select'
						insert into #dina_coluna_condicao_acao (id_coluna_mostra_acao, id_coluna_condicao, cd_acao, dv_mostra)
						select '+ isnull(convert(varchar(max),@id_coluna_mostra_acao),'NULL') +', '+ isnull(convert(varchar(max),@id_coluna_condicao),'NULL') +', '+ isnull(convert(varchar(max),@cd_acao),'NULL') +', '+ isnull(convert(varchar(max),@dv_mostra),'NULL')
						+ @NewLineChar
						FETCH NEXT FROM cursor_dina INTO @id_coluna_mostra_acao, @id_coluna_condicao, @cd_acao, @dv_mostra
					END
					CLOSE cursor_dina
					DEALLOCATE cursor_dina

		--DINA_COLUNA_CONDICAO_COLUNA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 14) + 'DINA_COLUNA_CONDICAO_COLUNA' + REPLICATE('-', @qtd_separador)
					DECLARE cursor_dina CURSOR FOR
					SELECT id_coluna_mostra_condicao, id_coluna_condicao, cd_coluna, dv_mostra, dv_protegido
					FROM #dina_coluna_condicao_coluna dccct
					WHERE id_coluna_condicao is not null ORDER BY id_coluna_mostra_condicao

					OPEN cursor_dina
					FETCH NEXT FROM cursor_dina INTO @id_coluna_mostra_condicao, @id_coluna_condicao, @cd_coluna, @dv_mostra, @dv_protegido

					WHILE @@FETCH_STATUS = 0
					BEGIN
						insert into #tabela_results(nm_string)
						select'
						insert into #dina_coluna_condicao_coluna (id_coluna_mostra_condicao, id_coluna_condicao, cd_coluna, dv_mostra, dv_protegido)
						select '+ isnull(convert(varchar(max),@id_coluna_mostra_condicao),'NULL') +', '+ isnull(convert(varchar(max),@id_coluna_condicao),'NULL') +', '+ isnull(convert(varchar(max),@cd_coluna),'NULL') +', '+ isnull(convert(varchar(max),@dv_mostra),'NULL') +', '+ isnull(convert(varchar(max),@dv_protegido),'NULL')
						+ @NewLineChar
						FETCH NEXT FROM cursor_dina INTO @id_coluna_mostra_condicao, @id_coluna_condicao, @cd_coluna, @dv_mostra, @dv_protegido
					END
					CLOSE cursor_dina
					DEALLOCATE cursor_dina

		--DINA_ESTATISTICA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 6) + 'DINA_ESTATISTICA' + REPLICATE('-', @qtd_separador)
			DECLARE cursor_dina CURSOR FOR
			SELECT id_estatistica, cd_dina, cd_acao, cd_coluna, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, cd_sistema, dt_estatistica
			FROM #dina_estatistica
			WHERE cd_dina is not null and cd_acao is null ORDER BY id_estatistica

			OPEN cursor_dina
			FETCH NEXT FROM cursor_dina INTO @id_estatistica, @cd_dina, @cd_acao, @cd_coluna, @cd_relatorio, @dt_inicio_execucao, @dt_fim_execucao, @nm_metodo_origem, @nm_query_executada, @nr_io, @cd_sistema, @dt_estatistica

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into #tabela_results(nm_string)
				select'
				insert into #dina_estatistica (id_estatistica, cd_dina, cd_acao, cd_coluna, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, cd_sistema, dt_estatistica)
				select '+ isnull(convert(varchar(max),@id_estatistica),'NULL') +', '+ isnull(convert(varchar(max),@cd_dina),'NULL') +', '+ isnull(convert(varchar(max),@cd_acao),'NULL') +', '+ isnull(convert(varchar(max),@cd_coluna),'NULL') +', '+ isnull(convert(varchar(max),@cd_relatorio),'NULL') +', '+ isnull('''' + convert(varchar(max),@dt_inicio_execucao,121)+'''','NULL') +', '+ isnull('''' + convert(varchar(max),@dt_fim_execucao,121)+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_metodo_origem),'''','''''')+'''','NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_query_executada),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@nr_io),'NULL') +', '+ isnull(convert(varchar(max),@cd_sistema),'NULL') +', '+ isnull('''' + convert(varchar(max),@dt_estatistica,121)+'''','NULL')
				+ @NewLineChar
				FETCH NEXT FROM cursor_dina INTO @id_estatistica, @cd_dina, @cd_acao, @cd_coluna, @cd_relatorio, @dt_inicio_execucao, @dt_fim_execucao, @nm_metodo_origem, @nm_query_executada, @nr_io, @cd_sistema, @dt_estatistica
			END
			CLOSE cursor_dina
			DEALLOCATE cursor_dina

		--DINA_IDIOMA_DINA
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 6) + 'DINA_IDIOMA_DINA' + REPLICATE('-', @qtd_separador)
			DECLARE cursor_dina CURSOR FOR
			SELECT cd_idioma_dina, cd_dina, cd_idioma, nm_titulo
			FROM #dina_idioma_dina ORDER BY cd_idioma_dina

			OPEN cursor_dina
			FETCH NEXT FROM cursor_dina INTO @cd_idioma_dina, @cd_dina, @cd_idioma, @nm_titulo

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into #tabela_results(nm_string)
				select'
				insert into #dina_idioma_dina (cd_idioma_dina, cd_dina, cd_idioma, nm_titulo)
				select '+ isnull(convert(varchar(max),@cd_idioma_dina),'NULL') +', '+ isnull(convert(varchar(max),@cd_dina),'NULL') +', '+ isnull(convert(varchar(max),@cd_idioma),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_titulo),'''','''''')+'''','NULL') + ' from dina din where din.cd_dina = @cd_dina
				' + @NewLineChar
				FETCH NEXT FROM cursor_dina INTO @cd_idioma_dina, @cd_dina, @cd_idioma, @nm_titulo
			END		
			CLOSE cursor_dina
			DEALLOCATE cursor_dina

		--DINA_MENU
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 6) + 'DINA_MENU' + REPLICATE('-', @qtd_separador)
			DECLARE cursor_dina CURSOR FOR
			SELECT cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai
			FROM #dina_menu
			WHERE cd_dina = @cd_dina ORDER BY cd_menu

			OPEN cursor_dina
			FETCH NEXT FROM cursor_dina INTO @cd_menu, @cd_dina, @Cd_empresa, @Nm_menu, @Cd_sistema, @Cd_menu_pai

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into #tabela_results(nm_string)
				select'
				insert into #dina_menu (cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai)
				select '+ isnull(convert(varchar(max),@cd_menu),'NULL') +', '+ isnull(convert(varchar(max),@cd_dina),'NULL') +', '+ isnull(convert(varchar(max),@Cd_empresa),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@Nm_menu),'''','''''')+'''','NULL') +', '+ isnull(convert(varchar(max),@Cd_sistema),'NULL') +', '+ isnull(convert(varchar(max),@Cd_menu_pai),'NULL')
				+ @NewLineChar
				FETCH NEXT FROM cursor_dina INTO @cd_menu, @cd_dina, @Cd_empresa, @Nm_menu, @Cd_sistema, @Cd_menu_pai
			END		
			CLOSE cursor_dina
			DEALLOCATE cursor_dina

		--DINA_IDIOMA_MENU
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_IDIOMA_MENU' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT cd_idioma_menu, cd_menu, cd_idioma, nm_menu
				FROM #dina_idioma_menu ORDER BY cd_idioma_menu

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @cd_idioma_menu, @cd_menu, @cd_idioma, @nm_menu

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select distinct'
					insert into #dina_idioma_menu (cd_idioma_menu, cd_menu, cd_idioma, nm_menu)
					select '+ isnull(convert(varchar(max),@cd_idioma_menu),'NULL') +', '+ isnull(convert(varchar(max),@cd_menu),'NULL') +', '+ isnull(convert(varchar(max),@cd_idioma),'NULL') +', '+ isnull('''' + replace(convert(varchar(max),@nm_menu),'''','''''')+'''','NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @cd_idioma_menu, @cd_menu, @cd_idioma, @nm_menu
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_PERFIL_MENU --- neto aqui
		if @id_tp_perfil != 1 
		begin 
			insert into #tabela_results(nm_string)
			SELECT REPLICATE('-', 10) + 'DINA_PERFIL_MENU' + REPLICATE('-', @qtd_separador)

			DECLARE cursor_dina CURSOR FOR
			SELECT cd_perfil, cd_menu
			FROM #dina_perfil_menu ORDER BY cd_perfil

			OPEN cursor_dina
			FETCH NEXT FROM cursor_dina INTO @cd_perfil, @cd_menu

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into #tabela_results(nm_string)
				select'
				insert into #dina_perfil_menu (cd_perfil, cd_menu)
				select ' + isnull(convert(varchar(max),@cd_perfil),'NULL') +', ' + isnull(convert(varchar(max),@cd_menu),'NULL')
				+ @NewLineChar
				FETCH NEXT FROM cursor_dina INTO @cd_perfil, @cd_menu
			END
			CLOSE cursor_dina
			DEALLOCATE cursor_dina
		end

		--DINA_USUARIO_MENU
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 10) + 'DINA_USUARIO_MENU' + REPLICATE('-', @qtd_separador)
				DECLARE cursor_dina CURSOR FOR
				SELECT Cd_usuario, cd_menu
				FROM #dina_usuario_menu ORDER BY Cd_usuario

				OPEN cursor_dina
				FETCH NEXT FROM cursor_dina INTO @Cd_usuario, @cd_menu

				WHILE @@FETCH_STATUS = 0
				BEGIN
					insert into #tabela_results(nm_string)
					select'
					insert into #dina_usuario_menu (Cd_usuario, cd_menu)
					select ' + isnull('''' + replace(convert(varchar(max),@Cd_usuario),'''','''''')+'''','NULL') +', ' + isnull(convert(varchar(max),@cd_menu),'NULL')
					+ @NewLineChar
					FETCH NEXT FROM cursor_dina INTO @Cd_usuario, @cd_menu
				END
				CLOSE cursor_dina
				DEALLOCATE cursor_dina

		--DINA_HELP_TELAS
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', 6) + 'DINA_HELP_TELAS' + REPLICATE('-', @qtd_separador)
			DECLARE cursor_dina CURSOR FOR
			SELECT id_dina_help_telas, id_dina_help, cd_dina
			FROM #dina_help_telas ORDER BY id_dina_help_telas

			OPEN cursor_dina
			FETCH NEXT FROM cursor_dina INTO @id_dina_help_telas, @id_dina_help, @cd_dina

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into #tabela_results(nm_string)
				select'
				insert into #dina_help_telas (id_dina_help_telas, id_dina_help, cd_dina)
				select ' + isnull(convert(varchar(max), @id_dina_help_telas),'NULL') +', ' + isnull(convert(varchar(max), @id_dina_help),'NULL') +', ' + isnull(convert(varchar(max), @cd_dina),'NULL')
				+ @NewLineChar
				FETCH NEXT FROM cursor_dina INTO @id_dina_help_telas, @id_dina_help, @cd_dina
			END
			CLOSE cursor_dina
			DEALLOCATE cursor_dina


		--Gerar o script para inserir nas tabelas internas a partir das tabelas temporárias internas
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)

		insert into #tabela_results(nm_string)
		select'
		set identity_insert dina on
		insert into dina (cd_dina, nm_dina, cd_tipo_tela, nm_titulo, nm_tabela, cd_tipo_comando, nm_orderby, nm_where, nr_registro_pagina, dv_modo, Cd_sistema, nm_query, nr_auto_refresh, dv_sem_link_lista, cd_usuario, dv_alterando, dv_checkout, id_usuario_checkout, dt_checkout, nm_set, dv_traduz_conteudo)
		select dt.cd_dina, dt.nm_dina, dt.cd_tipo_tela, dt.nm_titulo, dt.nm_tabela, dt.cd_tipo_comando, dt.nm_orderby, dt.nm_where, dt.nr_registro_pagina, dt.dv_modo, dt.Cd_sistema, dt.nm_query, dt.nr_auto_refresh, dt.dv_sem_link_lista, dt.cd_usuario, dt.dv_alterando, dt.dv_checkout, dt.id_usuario_checkout, dt.dt_checkout, dt.nm_set, dt.dv_traduz_conteudo
		from #dina dt
		where dt.cd_dina = @cd_dina
		set identity_insert dina off
		' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
		DECLARE cursor_dina CURSOR FOR
		SELECT cd_acao
		FROM #dina_acao

		OPEN cursor_dina
		FETCH NEXT FROM cursor_dina INTO @cd_acao

		WHILE @@FETCH_STATUS = 0
		BEGIN
			insert into #tabela_results(nm_string)
			select '
			insert into dina_acao (cd_dina, dv_log_sistema, nm_acao, cd_tipo_implementacao, nm_implementacao, nm_implementacao_parametro, cd_tipo_evento, cd_relatorio, nm_hint, dv_modo, cd_barra, cd_layout, nm_mensagem_alerta, dv_padrao, nm_target, nm_servidor_remoto, nr_ordem, nr_auto_refresh, id_dominio, dv_lock_app_resource)
			select dat.cd_dina, dat.dv_log_sistema, dat.nm_acao, dat.cd_tipo_implementacao, dat.nm_implementacao, dat.nm_implementacao_parametro, dat.cd_tipo_evento, dat.cd_relatorio, dat.nm_hint, dat.dv_modo, dat.cd_barra, dat.cd_layout, dat.nm_mensagem_alerta, dat.dv_padrao, dat.nm_target, dat.nm_servidor_remoto, dat.nr_ordem, dat.nr_auto_refresh, dat.id_dominio, dat.dv_lock_app_resource
			from #dina_acao dat
			where dat.cd_dina = @cd_dina and cd_acao = ' + isnull(convert(varchar(max), @cd_acao),'NULL') +'
			update #dina_acao set cd_acao_new = @@IDENTITY where cd_acao = ' + isnull(convert(varchar(max), @cd_acao),'NULL') + @NewLineChar
			FETCH NEXT FROM cursor_dina INTO @cd_acao
		END

		CLOSE cursor_dina
		DEALLOCATE cursor_dina

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
			insert into #tabela_results(nm_string)
				select '
				insert into dina_acao_parametro (cd_acao, nm_parametro)
				select dat.cd_acao_new, dapt.nm_parametro
				from #dina_acao_parametro dapt
				join #dina_acao dat on dat.cd_acao = dapt.cd_acao and dat.cd_dina = @cd_dina' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
			insert into #tabela_results(nm_string)
				select '
				insert into dina_idioma_acao (cd_acao, cd_idioma, nm_acao, nm_hint, nm_mensagem_alerta)
				select dat.cd_acao_new, diat.cd_idioma, diat.nm_acao, diat.nm_hint, diat.nm_mensagem_alerta
				from #dina_idioma_acao diat
				join #dina_acao dat on dat.cd_acao = diat.cd_acao and dat.cd_dina = @cd_dina' + @NewLineChar

			---neto aqui
			if @id_tp_perfil =3
			begin 
				insert into #tabela_results(nm_string)
				SELECT REPLICATE('-', @qtd_separador)

				insert into #tabela_results(nm_string)
				select '
				insert into dina_perfil_acao (cd_perfil, cd_acao, dv_acesso)
				select dpat.cd_perfil, dat.cd_acao_new, dpat.dv_acesso
				from #dina_perfil_acao dpat
				join #dina_acao dat on dat.cd_acao = dpat.cd_acao and dat.cd_dina = @cd_dina' + @NewLineChar
			end
			else if @id_tp_perfil =2
			begin
				
				insert into #tabela_results(nm_string)
				SELECT REPLICATE('-', @qtd_separador)

				insert into #tabela_results(nm_string)
				select '
				insert into dina_perfil_acao (cd_perfil, cd_acao, dv_acesso)
				select dpat.cd_perfil, dat.cd_acao_new, dpat.dv_acesso
				from #dina_perfil_acao dpat
				join #dina_acao dat 
				on dat.cd_acao = dpat.cd_acao 
				and dat.cd_dina = @cd_dina
				left join dina_perfil_acao dpac
				on dpac.cd_perfil = dpat.cd_perfil
				and dpac.cd_acao = dat.cd_acao_new
				where dpac.cd_perfil is null' + @NewLineChar

			end

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
					insert into #tabela_results(nm_string)
				select '
				insert into dina_usuario_acao (cd_acao, Cd_usuario, Dv_acesso)
				select dat.cd_acao_new, duat.Cd_usuario, duat.Dv_acesso
				from #dina_usuario_acao duat
				join #dina_acao dat on dat.cd_acao = duat.cd_acao and dat.cd_dina = @cd_dina' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
					insert into #tabela_results(nm_string)
				select '
				insert into dina_estatistica (cd_dina, cd_acao, cd_coluna, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, cd_sistema, dt_estatistica)
				select det.cd_dina, dat.cd_acao_new, det.cd_coluna, det.cd_relatorio, det.dt_inicio_execucao, det.dt_fim_execucao, det.nm_metodo_origem, det.nm_query_executada, det.nr_io, det.cd_sistema, det.dt_estatistica
				from #dina_estatistica det
				join #dina_acao dat on dat.cd_acao = det.cd_acao and det.cd_dina = @cd_dina' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
		DECLARE cursor_dina CURSOR FOR
		SELECT cd_coluna
		FROM #dina_coluna

		OPEN cursor_dina
		FETCH NEXT FROM cursor_dina INTO @cd_coluna

		WHILE @@FETCH_STATUS = 0
		BEGIN
			insert into #tabela_results(nm_string)
			select '
			insert into dina_coluna (cd_lookup_dina, cd_funcao_validacao, cd_dina, nm_campo, nr_ordem, nm_titulo, dv_mostra_lista, dv_mostra_ficha, dv_mostra_filtro, dv_chave, dv_somente_leitura, nm_hint, nm_lookup_tabela, nm_lookup_chave, nm_lookup_lista, nm_lookup_where, dv_obrigatorio, dv_mostra, nm_formato, nm_alias, dv_lookup_estilo, nm_classe_lista, dv_edita_lista, cd_valor_padrao, nm_campo_hint, dv_traduz_conteudo)
			select dct.cd_lookup_dina, dct.cd_funcao_validacao, dct.cd_dina, dct.nm_campo, dct.nr_ordem, dct.nm_titulo, dct.dv_mostra_lista, dct.dv_mostra_ficha, dct.dv_mostra_filtro, dct.dv_chave, dct.dv_somente_leitura, dct.nm_hint, dct.nm_lookup_tabela, dct.nm_lookup_chave, dct.nm_lookup_lista, dct.nm_lookup_where, dct.dv_obrigatorio, dct.dv_mostra, dct.nm_formato, dct.nm_alias, dct.dv_lookup_estilo, dct.nm_classe_lista, dct.dv_edita_lista, dct.cd_valor_padrao, dct.nm_campo_hint, dct.dv_traduz_conteudo
			from #dina_coluna dct
			where dct.cd_dina = @cd_dina and cd_coluna = ' + isnull(convert(varchar(max), @cd_coluna),'NULL') +'
			update #dina_coluna set cd_coluna_new = @@IDENTITY where cd_coluna = ' + isnull(convert(varchar(max), @cd_coluna),'NULL') + @NewLineChar
			FETCH NEXT FROM cursor_dina INTO @cd_coluna
		END

		CLOSE cursor_dina
		DEALLOCATE cursor_dina

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
					insert into #tabela_results(nm_string)
				select '
				insert into dina_coluna_condicao_coluna (id_coluna_condicao, cd_coluna, dv_mostra, dv_protegido)
				select dccct.id_coluna_condicao, dct.cd_coluna_new, dccct.dv_mostra, dccct.dv_protegido
				from #dina_coluna_condicao_coluna dccct
				join #dina_coluna dct on dct.cd_coluna = dccct.cd_coluna and dccct.id_coluna_condicao is null' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
					insert into #tabela_results(nm_string)
				select '
				insert into dina_estatistica (cd_dina, cd_acao, cd_coluna, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, cd_sistema, dt_estatistica)
				select det.cd_dina, det.cd_acao, dct.cd_coluna_new, det.cd_relatorio, det.dt_inicio_execucao, det.dt_fim_execucao, det.nm_metodo_origem, det.nm_query_executada, det.nr_io, det.cd_sistema, det.dt_estatistica
				from #dina_estatistica det
				join #dina_coluna dct on dct.cd_coluna = det.cd_coluna' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
					insert into #tabela_results(nm_string)
				select '
				insert into dina_idioma_coluna (cd_coluna, cd_idioma, nm_titulo, nm_hint)
				select dct.cd_coluna_new, dict.cd_idioma, dict.nm_titulo, dict.nm_hint
				from #dina_idioma_coluna dict
				join #dina_coluna dct on dct.cd_coluna = dict.cd_coluna' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
			DECLARE cursor_dina CURSOR FOR
			SELECT id_coluna_condicao
			FROM #dina_coluna_condicao

			OPEN cursor_dina
			FETCH NEXT FROM cursor_dina INTO @id_coluna_condicao

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into #tabela_results(nm_string)
				select '
				insert into dina_coluna_condicao (cd_coluna, vl_campo, nm_hint)
				select dct.cd_coluna_new, dcct.vl_campo, dcct.nm_hint
				from #dina_coluna_condicao dcct
				join #dina_coluna dct on dct.cd_coluna = dcct.cd_coluna and id_coluna_condicao = ' + isnull(convert(varchar(max), @id_coluna_condicao),'NULL')+'
				update #dina_coluna_condicao set id_coluna_condicao_new = @@IDENTITY where id_coluna_condicao = ' + isnull(convert(varchar(max), @id_coluna_condicao),'NULL') + @NewLineChar
				FETCH NEXT FROM cursor_dina INTO @id_coluna_condicao
			END

			CLOSE cursor_dina
			DEALLOCATE cursor_dina

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
						insert into #tabela_results(nm_string)
					select '
					insert into dina_coluna_condicao_acao (id_coluna_condicao, cd_acao, dv_mostra)
					select dcct.id_coluna_condicao_new, dat.cd_acao_new, dccat.dv_mostra
					from #dina_coluna_condicao_acao dccat
					join #dina_coluna_condicao dcct on dcct.id_coluna_condicao = dccat.id_coluna_condicao and dccat.id_coluna_condicao is not null
					join #dina_acao dat on dccat.cd_acao = dat.cd_acao' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
						insert into #tabela_results(nm_string)
					select '
					insert into dina_coluna_condicao_coluna (id_coluna_condicao, cd_coluna, dv_mostra, dv_protegido)
					select dcct.id_coluna_condicao_new, dct.cd_coluna_new, dccct.dv_mostra, dccct.dv_protegido
					from #dina_coluna_condicao_coluna dccct
					join #dina_coluna_condicao dcct on dcct.id_coluna_condicao = dccct.id_coluna_condicao and dccct.id_coluna_condicao is not null
					join #dina_coluna dct on dct.cd_coluna = dccct.cd_coluna and dct.cd_dina = @cd_dina' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
				insert into #tabela_results(nm_string)
			select '
			insert into dina_estatistica (cd_dina, cd_acao, cd_coluna, cd_relatorio, dt_inicio_execucao, dt_fim_execucao, nm_metodo_origem, nm_query_executada, nr_io, cd_sistema, dt_estatistica)
			select det.cd_dina, det.cd_acao, det.cd_coluna, det.cd_relatorio, det.dt_inicio_execucao, det.dt_fim_execucao, det.nm_metodo_origem, det.nm_query_executada, det.nr_io, det.cd_sistema, det.dt_estatistica
			from #dina_estatistica det
			where det.cd_dina = @cd_dina and det.cd_coluna is null and det.cd_acao is null' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
				insert into #tabela_results(nm_string)
			select '
			insert into dina_idioma_dina (cd_dina, cd_idioma, nm_titulo)
			select didt.cd_dina, didt.cd_idioma, didt.nm_titulo
			from #dina_idioma_dina didt
			join dina din on din.cd_dina = @cd_dina and didt.cd_dina = @cd_dina' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
				insert into #tabela_results(nm_string)
			select '
			insert into dina_menu (cd_menu, cd_dina, Cd_empresa, Nm_menu, Cd_sistema, Cd_menu_pai)
			select dmt.cd_menu, dmt.cd_dina, dmt.Cd_empresa, dmt.Nm_menu, dmt.Cd_sistema, dmt.Cd_menu_pai
			from #dina_menu dmt
			where dmt.cd_dina = @cd_dina' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
					insert into #tabela_results(nm_string)
				select '
				insert into dina_idioma_menu (cd_menu, cd_idioma, nm_menu)
				select dimt.cd_menu, dimt.cd_idioma, dimt.nm_menu
				from #dina_idioma_menu dimt
				join #dina_menu dmt on dmt.cd_menu = dimt.cd_menu' + @NewLineChar

				----neto aqui
			if @id_tp_perfil =3
			begin 
				insert into #tabela_results(nm_string)
				SELECT REPLICATE('-', @qtd_separador)

				insert into #tabela_results(nm_string)
				select '
				insert into dina_perfil_menu (cd_perfil, cd_menu)
				select dpmt.cd_perfil, dpmt.cd_menu
				from #dina_perfil_menu dpmt
				join #dina_menu dmt on dmt.cd_menu = dpmt.cd_menu' + @NewLineChar
			end
			else if @id_tp_perfil =2
			begin
				
				insert into #tabela_results(nm_string)
				SELECT REPLICATE('-', @qtd_separador)

				insert into #tabela_results(nm_string)
				select '
				insert into dina_perfil_menu (cd_perfil, cd_menu)
				select dpmt.cd_perfil, dpmt.cd_menu
				from #dina_perfil_menu dpmt
				join #dina_menu dmt 
				on dmt.cd_menu = dpmt.cd_menu
				left join dina_perfil_menu cptm
				on cptm.cd_perfil = dpmt.cd_perfil
				and cptm.cd_menu = dpmt.cd_menu
				where cptm.cd_perfil is null' + @NewLineChar

			end

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
					insert into #tabela_results(nm_string)
				select '
				insert into dina_usuario_menu (Cd_usuario, cd_menu)
				select dumt.Cd_usuario, dumt.cd_menu
				from #dina_usuario_menu dumt
				join #dina_menu dmt on dmt.cd_menu = dumt.cd_menu' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
				insert into #tabela_results(nm_string)
			select '
			insert into dina_help_telas (id_dina_help, cd_dina)
			select dhtt.id_dina_help, dhtt.cd_dina
			from #dina_help_telas dhtt
			where dhtt.cd_dina = @cd_dina
			' + @NewLineChar

			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)
			insert into #tabela_results(nm_string)
		SELECT REPLICATE('-', @qtd_separador)

			insert into #tabela_results(nm_string)
		select 'SET NOCOUNT OFF
		SELECT ''SCRIPT EXECUTOU COM SUCESSO!''
		'+ @NewLineChar

			insert into #tabela_results(nm_string)
		select 'select ''#dina_acao (cd_acao_new)'', count(*) as contador from dina_acao da where da.cd_dina = @cd_dina

		select ''#dina_acao_parametro (cd_acao)'', count(*) as contador from dina_acao_parametro dap
		where dap.cd_acao in (select cd_acao from dina_acao where cd_dina = @cd_dina)

		select ''#dina_idioma_acao(cd_acao)'', count(*) as contador from dina_idioma_acao dia
		where dia.cd_acao in (select cd_acao from dina_acao where cd_dina = @cd_dina)

		'+
		---neto aqui
		'
		------neto ( ignorar ) 
		select ''#dina_perfil_acao(cd_acao)'', count(*) as contador from dina_perfil_acao dpa
		where dpa.cd_acao in (select cd_acao from dina_acao where cd_dina = @cd_dina)

		select ''#dina_usuario_acao (cd_acao)'', count(*) as contador from dina_usuario_acao dua
		where dua.cd_acao in (select cd_acao from dina_acao where cd_dina = @cd_dina)

		select ''#dina_coluna (cd_coluna_new)'', count(*) as contador from dina_coluna dc where dc.cd_dina = @cd_dina

		select ''#dina_coluna_condicao_coluna(cd_coluna,id_coluna_condicao)'', count(*) as contador from dina_coluna_condicao_coluna dccc
		where dccc.cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina) and dccc.id_coluna_condicao is null

		select ''#dina_estatistica(cd_coluna)'', count(*) as contador from dina_estatistica de
		where de.cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina) and de.cd_dina is null

		select ''#dina_idioma_coluna(cd_coluna)'', count(*) as contador from dina_idioma_coluna dic
		where dic.cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina)

		select ''#dina_coluna_condicao(cd_coluna, id_coluna_condicao_new)'', count(*) as contador from dina_coluna_condicao dcc
		where dcc.cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina)

		select ''#dina_coluna_condicao_acao(id_coluna_condicao, cd_acao)'', count(*) as contador from dina_coluna_condicao_acao dcca
		where dcca.id_coluna_condicao in (select id_coluna_condicao from dina_coluna_condicao where cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina)) and dcca.id_coluna_condicao is not null

		select ''#dina_coluna_condicao_coluna(id_coluna_condicao, cd_coluna)'', count(*) as contador from dina_coluna_condicao_coluna dccc
		where dccc.id_coluna_condicao in (select id_coluna_condicao from dina_coluna_condicao where cd_coluna in (select cd_coluna from dina_coluna where cd_dina = @cd_dina)) and dccc.id_coluna_condicao is not null

		select ''#dina_menu(cd_menu_new)'', count(*) as contador from dina_menu dm where dm.cd_dina = @cd_dina

		select ''#dina_idioma_menu(cd_menu)'', count(*) as contador from dina_idioma_menu dim
		where dim.cd_menu in (select cd_menu from dina_menu where cd_dina = @cd_dina)

		'+
		---neto aqui
		'
		-----neto (ignorar) 
		select ''#dina_perfil_menu(cd_menu)'', count(*) as contador from dina_perfil_menu dpm
		where dpm.cd_menu in (select cd_menu from dina_menu where cd_dina = @cd_dina)

		select ''#dina_usuario_menu(cd_menu)'', count(*) as contador from dina_usuario_menu dum
		where dum.cd_menu in (select cd_menu from dina_menu where cd_dina = @cd_dina)'

			insert into #tabela_results(nm_string)
		SELECT '
		--Início dos casos especiais
		'

		IF (@cd_dina = 65)
		BEGIN
			insert into #tabela_results(nm_string)
		SELECT '
		--60558 - Atualizar vinculo da acao com a tela do cartao
		DECLARE @GerarEndosso int

		SELECT 
			@GerarEndosso = cd_acao
		FROM dina_acao
		WHERE 
			cd_dina = 65 AND
			nm_acao =''Emitir Endosso'' AND
			nm_target = ''_self''
	
		UPDATE dina_acao
		SET nm_implementacao = ''cartao.asp?acao=''+convert(nvarchar(20),@GerarEndosso)
		WHERE 
			cd_dina = 65 AND
			nm_acao =''Emitir Endosso'' AND
			nm_target = ''cartao''
		'	
		END

		--

		IF (@cd_dina = 185)
		BEGIN
			insert into #tabela_results(nm_string)
		SELECT '
		--60558 - Atualiza vinculo da acao com a tela do cartao
		DECLARE @GerarEndosso int

		SELECT 
			@GerarEndosso = cd_acao
		FROM dina_acao
		WHERE 
			cd_dina = 185 AND
			nm_acao =''Gera Apólice'' AND
			nm_target IS NULL
	
		UPDATE dina_acao
		SET nm_implementacao = ''cartao.asp?acao=''+convert(nvarchar(20),@GerarEndosso)
		WHERE 
			cd_dina = 185 AND
			nm_acao =''Gera Apólice'' AND
			nm_target = ''cartao''
	
		'
		END

			insert into #tabela_results(nm_string)
		SELECT '
		--Final dos casos especiais
		'

		--Insere a versão na dina
			insert into #tabela_results(nm_string)
		SELECT '
		UPDATE dina SET nr_versao = ' + '@nr_versao_controle' + ' WHERE cd_dina =' + CONVERT(VARCHAR(MAX),@cd_dina)
		FROM dina WHERE cd_dina = @cd_dina 

			insert into #tabela_results(nm_string)
		SELECT '
		COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
		SELECT ''SCRIPT EXECUTOU COM FALHA: '' + ERROR_MESSAGE() AS ErrorMessage
		ROLLBACK TRANSACTION
		END CATCH'


		select [GO] = nm_string from #tabela_results order by id asc

END TRY
BEGIN CATCH

		SELECT ERRO = ERROR_MESSAGE()
		RETURN

END CATCH

RETURN