USE SEGCORP
GO

Set Transaction Isolation Level Read Uncommitted;
go

-- commit / rollback
 begin tran

	--> Tempo aproximado de execu��o: 3 minutos

	/***** Remove endosso de cancelamento ******************************************/
	declare @id_endosso_cobranca int

	declare @id_apolice int = 1492064
	declare @id_endosso_cancelamento int = 29261124

	--select ca.id_sub_estipulante from corp_apolice ca
	--where ca.Id_apolice = 1014701




	update ce
	   set cd_tipo_endosso = 6
      from corp_endosso ce
	 where ce.id_endosso = @id_endosso_cancelamento

	exec corpsp_exclui_endosso_proposta @id_endosso = @id_endosso_cancelamento, @cd_retorno = null, @nm_retorno = null

	update ca
	   set cd_status = 7
	  from corp_apolice ca
	 where ca.id_apolice = @id_apolice

	update cse
	   set cd_status = 700
	  from corp_sub_estipulante cse
	 where cse.id_apolice = @id_apolice
	   and cse.dv_principal = 1


	update corp_sub_estipulante set cd_status = 700 where id_sub = 1517496
    	--update corp_sub_estipulante set cd_status = 700 where id_sub = 591777



    /***** Reativa Endosso de cobran�a 1923513 ******************************************/
	/*
	set @id_endosso_cobranca = 27034414

	print 'passo: 1'
    delete clcc
	  from corp_endosso_parcela cep
	  join corp_parc_movto cpm
	    on cpm.Id_parcela = cep.Id_parcela
	  join corp_comi_corr_movto cccm
	    on cccm.Id_parcela_movimentacao = cpm.Id_parcela_movimentacao
	  join corp_lancamento_contabil_consist clcc
	    on clcc.id_comi_corr_movto = cccm.id_comi_corr_movto
	 where cep.id_endosso = @id_endosso_cobranca
	   and cpm.Cd_evento = 401

	print 'passo: 2'
    delete clcl
	  from corp_endosso_parcela cep
	  join corp_parc_movto cpm
	    on cpm.Id_parcela = cep.Id_parcela
	  join corp_comi_corr_movto cccm
	    on cccm.Id_parcela_movimentacao = cpm.Id_parcela_movimentacao
	  join corp_lote_consist_log clcl
	    on clcl.id_comi_corr_movto = cccm.id_comi_corr_movto
	 where cep.id_endosso = @id_endosso_cobranca
	   and cpm.Cd_evento = 401

	print 'passo: 3'
    delete cccm
	   --set Cd_evento = 6011
	  from corp_endosso_parcela cep
	  join corp_parc_movto cpm
	    on cpm.Id_parcela = cep.Id_parcela
	  join corp_comi_corr_movto cccm
	    on cccm.Id_parcela_movimentacao = cpm.Id_parcela_movimentacao
	 where cep.id_endosso = @id_endosso_cobranca
	   and cpm.Cd_evento = 401

--select * from corp_evento where nm_evento like '%corre%' and nm_evento like '%pagament%'

	print 'passo: 4'
    delete clcc
	  from corp_endosso_parcela cep
	  join corp_parc_movto cpm
	    on cpm.Id_parcela = cep.Id_parcela
	  join corp_lancamento_contabil_consist clcc
	    on clcc.id_parcela_movimentacao = cpm.id_parcela_movimentacao
	 where cep.id_endosso = @id_endosso_cobranca
	   and cpm.Cd_evento = 401

	print 'passo: 5'
    delete clcl
	  from corp_endosso_parcela cep
	  join corp_parc_movto cpm
	    on cpm.Id_parcela = cep.Id_parcela
	  join corp_lote_consist_log clcl
	    on clcl.id_parcela_movimentacao = cpm.id_parcela_movimentacao
	 where cep.id_endosso = @id_endosso_cobranca
	   and cpm.Cd_evento = 401


	--print 'passo: 6'
 --   delete ccpm
	--  from corp_endosso_parcela cep
	--  join corp_parc_movto cpm
	--    on cpm.Id_parcela = cep.Id_parcela
	--  join corp_coss_parc_movto ccpm
	--    on ccpm.Id_parcela_movimentacao = cpm.Id_parcela_movimentacao
	-- where cep.id_endosso = @id_endosso_cobranca
	--   and cpm.Cd_evento = 401

	print 'passo: 7'
    update cpm
	   set Cd_evento = 201
	     , dt_movimento = cm.Dt_movimento_contabil
	  from corp_endosso_parcela cep
	  join corp_parc_movto cpm
	    on cpm.Id_parcela = cep.Id_parcela
	  join corp_modulo cm
	    on cm.id_modulo = 5
	 where cep.id_endosso = @id_endosso_cobranca
	   and cpm.Cd_evento = 401

    update corp_endosso_parcela set dv_situacao = 'Q' where id_endosso = @id_endosso_cobranca

	-------------------------------------------
	*/
    --exec dbo.corpsp_fechamento_diario_emissao @id_modulo = 21, @dt_movimento_alternativo = '20230301' -- Exec para remover o evento de Cancelamento

/*
insert into corp_sub_followup
        (id_sub,
        ds_followup,
        cd_usuario,
        dt_followup,
        dt_movimento,
        id_tp_followup)
select 
1034967,
'JIRA SIS-32714 - Ativaçao do Grupo 9291 ' , 
'SIS-32714', 
getdate(),
getdate(),
13
*/	
	/* 3 linhas movimento 104
	select * from corp_fecha_emissao_diario cfed
	where cfed.cd_apolice = 1009300636063
	and cfed.nr_ano_ref = 2023
	and cfed.dt_movimento = '20230301'
	*/