USE [SEGCORP]
GO



-- wmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwm
-- Definição de parametros do relatorio
-- wmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwm

	declare @id_formulario varchar(5) = '1032'
	declare @nm_procedure varchar(50) = 'corpsp_relatorio_inadimplencia_vi'
	declare @nm_formulario varchar(50) = 'Relatorio Inadimplencia VI'
	declare @id_grp int = 60 --> FINANCEIRO



-- wmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwm
-- Definição de parametros do relatorio
-- wmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwm

    /** O select abaixo serve de consulta para identificar qual cd_coluna incluir no formulario **/
	/** select cd_coluna, nm_campo, nm_titulo from dina_coluna where cd_dina = 313              **/

declare @par1 int,
        @par2 int,
        @par3 int,
        @par4 int,
        @par5 int
        
    set @par1 = (select top 1 cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'id_grp')
    set @par2 = (select top 1 cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'id_formulario')
    --set @par3 = (select top 1 cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'nr_ano_ref')
   -- set @par4 = (select top 1 cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'nr_mes_ref')



	if OBJECT_ID('tempdb..#colunas_incluir') is not null drop table #colunas_incluir
	create table #colunas_incluir ( cd_coluna int )

	insert into #colunas_incluir values (@par1) -- id_grp        --> Deixar fixo
	insert into #colunas_incluir values (@par2) -- id_formulario --> Deixar fixo

	--insert into #colunas_incluir values (@par3) -- nr_ano_ref
	--insert into #colunas_incluir values (@par4) -- nr_mes_ref


-- wmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwm
-- Valida se pode utilizar o formulario informado
-- wmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwm

	if exists (
		  select top 1 '1'
		    from dina_coluna dc
		    join dina_coluna_condicao dcc	     	on dc.cd_coluna = dcc.cd_coluna
		    join dina_coluna_condicao_acao dccc	on dcc.id_coluna_condicao = dccc.id_coluna_condicao
		   where dc.cd_dina = 313 
		     and dc.cd_coluna = (select cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'id_formulario')
		     and dcc.vl_campo = @id_formulario
		union all
		  select top 1 '1'
		    from dina_coluna dc
		    join dina_coluna_condicao dcc          on dc.cd_coluna = dcc.cd_coluna
		    join dina_coluna_condicao_coluna dccc  on dcc.id_coluna_condicao = dccc.id_coluna_condicao
		   where dc.cd_dina = 313 
		     and dc.cd_coluna = (select cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'id_formulario')
		     and dcc.vl_campo = @id_formulario
		union all
          select top 1 '1' 
            from dina_coluna dc
            join dina_coluna_condicao dcc on dc.cd_coluna = dcc.cd_coluna
           where dc.cd_dina = 313 
             and dc.cd_coluna = (select cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'id_formulario')
             and dcc.vl_campo = @id_formulario
		union all
		  select top 1 '1' from dina_relatorio_parametro_entrada where cd_relatorio = @id_formulario
		union all
		  select top 1 '1' from corp_formulario where id_formulario = @id_formulario
		union all
		  select top 1 '1' from dina_relatorio where cd_relatorio = @id_formulario
		union all
		  select top 1 '1' from dina_coluna_condicao where vl_Campo = @id_formulario
	)
	BEGIN
       Select Nm_retorno = 'ATENÇÃO !! O id_formulario '+ cast(@id_formulario as varchar) +' não pode ser utilizado porque já existe um relatório com esta chave'
	   return
	end




-- wmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwm
-- Parametriza a query via proc no formulário
-- wmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwmwm

	print 'insert into corp_formulario...'
	insert into corp_formulario ( id_formulario,nm_formulario,nm_layout,nm_procedure,nm_papel,id_grp,cd_tp_dominio,nr_registros_agrupados,dv_acesso_restrito,Cd_empresa,nr_qtd_vias,cd_uns,nm_mensagem,dv_mostra_estipulante,dv_mostra_corretor,dv_mostra_filial,dv_imprimi_site_online,dv_envia_impressao_terceiro,dv_ativo,dv_mostra_escr_regional,nr_min_registros,nr_ordem_impressao,id_encaminha_doc,nm_proc_diario,nr_ordem_proc,dv_imprime_chancela,nm_procedure_txt,hr_inicio_permissao,min_inicio_permissao,hr_fim_permissao,min_fim_permissao,dv_impressao_duplex,dv_converter_xml_para_pdf,nr_max_pag,dv_gera_nome_reduzido )
	select id_formulario = @id_formulario
		    , nm_formulario = @nm_formulario
		    , nm_layout
		    , nm_procedure = @nm_procedure
		    , nm_papel
		    , id_grp = @id_grp
		    , cd_tp_dominio
		    , nr_registros_agrupados
		    , dv_acesso_restrito
		    , Cd_empresa
		    , nr_qtd_vias
		    , cd_uns
		    , nm_mensagem
		    , dv_mostra_estipulante
		    , dv_mostra_corretor
		    , dv_mostra_filial
		    , dv_imprimi_site_online
		    , dv_envia_impressao_terceiro
		    , dv_ativo
		    , dv_mostra_escr_regional
		    , nr_min_registros
		    , nr_ordem_impressao
		    , id_encaminha_doc
		    , nm_proc_diario
		    , nr_ordem_proc
		    , dv_imprime_chancela
		    , nm_procedure_txt
		    , hr_inicio_permissao
		    , min_inicio_permissao
		    , hr_fim_permissao
		    , min_fim_permissao
		    , dv_impressao_duplex
		    , dv_converter_xml_para_pdf
		    , nr_max_pag
		    , dv_gera_nome_reduzido
		from corp_formulario 
		where id_formulario = 294

	print 'insert into dina_relatorio...'
	insert into dina_relatorio (cd_relatorio,nm_relatorio,nm_arquivo_relatorio,cd_tipo_saida,nm_proc_relatorio,nm_layout)
	select cd_relatorio = @id_formulario
		    , nm_relatorio = @nm_formulario
		    , nm_arquivo_relatorio
		    , cd_tipo_saida
		    , nm_proc_relatorio = @nm_procedure
		    , nm_layout
		from dina_relatorio 
		where cd_relatorio = 294


	declare @id_coluna_condicao int

	print 'insert into dina_coluna_condicao...' -- so insere uma linha
	insert into dina_coluna_condicao(cd_coluna,vl_campo,nm_hint)
	select dcc.cd_coluna
		    , vl_campo = @id_formulario
		    , nm_hint = @nm_formulario
		from dina_coluna dc
		join dina_coluna_condicao dcc on dc.cd_coluna = dcc.cd_coluna
		where dc.cd_dina = 313 
        and dc.cd_coluna = (select cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'id_formulario')
		and dcc.vl_campo = 294


	-- Aqui, o script insere todas as colunas que não devem ser visualizadas
	print 'insert into dina_coluna_condicao_coluna...' --> insere varias linhas
	select @id_coluna_condicao= max(id_coluna_condicao) from dina_coluna_condicao

	if OBJECT_ID('tempdb..#dina_coluna_condicao_coluna') is not null drop table #dina_coluna_condicao_coluna
	select id_coluna_condicao = @id_coluna_condicao
         , dc.cd_coluna
         , dv_mostra = 0
         , dv_protegido = 0
      into #dina_coluna_condicao_coluna
  	  from dina_coluna dc
     where dc.cd_dina = 313 

	insert into dina_coluna_condicao_coluna (id_coluna_condicao,cd_coluna,dv_mostra,dv_protegido)
	Select id_coluna_condicao = @id_coluna_condicao
		    , cd_coluna
		    , dv_mostra
		    , dv_protegido
		from #dina_coluna_condicao_coluna
		where cd_coluna not in (select cd_coluna from #colunas_incluir)


	print 'insert into dina_coluna_condicao_acao...' --: insere 3 linhas
	insert into dina_coluna_condicao_acao (id_coluna_condicao,cd_acao,dv_mostra)
	select id_coluna_condicao = @id_coluna_condicao
		    , dccc.cd_acao
		    , dccc.dv_mostra
		from dina_coluna dc
		join dina_coluna_condicao dcc        on dc.cd_coluna = dcc.cd_coluna
		join dina_coluna_condicao_acao dccc  on dcc.id_coluna_condicao = dccc.id_coluna_condicao
		where dc.cd_dina = 313 
		and dc.cd_coluna = (select cd_coluna from dina_coluna where cd_dina = 313 and nm_campo = 'id_formulario')
		and dcc.vl_campo = 294

