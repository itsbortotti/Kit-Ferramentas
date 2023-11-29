/*LISTA CASOS QUE NÃO FORAM GERADOS A CAPITALIZAÇÃO*/
select top 10000 
--1, civ.dt_competencia , ce.dt_competencia, civc.id_tp_movimento, 
ca.cd_apolice, ce.cd_proposta, ce.Id_endosso, ce.cd_forma_pagamento, ceivc.nr_titulo_cap,
cltc.*, ceivc.id_compra_capitalizacao, ceivc.dt_envio_compra_titulo, ceivc.dt_inclusao, ceivc.dt_processamento
from corp_endosso_item_vida ceiv 
join corp_endosso ce with(nolock) 
on ce.id_endosso = ceiv.id_endosso 
join corp_endosso_parcela cep
on cep.id_endosso = ce.id_endosso
and cep.nr_parcela = 1
join corp_parc_movto cpm
on cpm.id_parcela = cep.id_parcela
and cpm.cd_evento = 201
join corp_sub_estipulante cse
on cse.id_sub = ce.id_sub
join corp_apolice ca
on ca.id_apolice = cse.id_apolice
join corp_item_vida civ with(nolock) 
on civ.id_pessoa_item = ceiv.id_pessoa_item 
--and civ.dt_competencia = ce.dt_competencia 
join corp_item_vida_cobertura civc 
on civc.id_pessoa_item = ceiv.id_pessoa_item 
--and isnull(civc.id_tp_movimento,0) in (1,5,8) 
join corp_produto_cobertura_regra cpcr 
on cpcr.id_produto_cobertura = civc.id_produto_cobertura 
and cpcr.cd_regra = 323 and isnull(cpcr.dv_regra,0) = 1
left join corp_endosso_item_vida_cap ceivc 
on ceivc.id_endosso_item_vida = ceiv.id_endosso_item_vida    
left join corp_lote_titulo_cap cltc on ceivc.id_titulo = cltc.id_titulo 
--left join corp_arquivo_cap cac on cltc.id_arquivo_cap = cac.id_arquivo_cap 
--left join corp_capitalizacao cc on cc.id_capitalizacao = cac.id_capitalizacao 
--left join corp_contrato_cap ccc on ccc.id_capitalizacao = cc.id_capitalizacao and ceivc.id_contrato_cap = ccc.id_contrato_cap
where ca.dv_documento_oficial = 1 
and ca.id_ramo in (1,91)
and cltc.nr_sorteio is null
and ca.cd_status = 7


/*REGERA A CAPITALIZAÇÃO*/
BEGIN TRAN

DECLARE 
	@cd_retorno			INT				=	NULL,
	@nm_retorno			VARCHAR(255)	=	NULL,
	@id_endosso			INT				=	NULL,
	@i					INT				=	0

IF OBJECT_ID('tempdb..#tpm_id_endosso') IS NOT NULL
	DROP TABLE #tpm_id_endosso

SELECT 
id_endosso = ce.id_endosso, cd_proposta = ce.cd_proposta, dv_processado = 0
into #tpm_id_endosso
FROM dbo.corp_endosso ce
WHERE ce.cd_proposta in (
1555735004,
1555735967,
1555737583,
1555738042,
1555738092,
1555737709,
1555738125,
1555738264,
1555738080,
1555738263,
1555738251,
1555737861,
1555738842,
1555738290
)
AND ce.cd_tipo_endosso = 0

SELECT '#tpm_id_endosso', * FROM #tpm_id_endosso order by cd_proposta

WHILE EXISTS(SELECT TOP 1 1 FROM #tpm_id_endosso WHERE dv_processado = 0)
BEGIN
	
	SET @i += 1
	SELECT @i

	SELECT 
		@id_endosso = id_endosso
	FROM #tpm_id_endosso
	WHERE dv_processado = 0
	ORDER BY id_endosso

	EXEC	corpsp_associar_nr_sorte_cap_individual 
				@id_endosso				= @id_endosso
		,		@nm_tabela				= null
		,		@cd_retorno				= @cd_retorno output
		,		@nm_retorno				= @nm_retorno output

	SELECT 
		id_endosso			=	@id_endosso,
		cd_retorno			=	@cd_retorno,
		nm_retorno			=	@nm_retorno

	UPDATE a
		SET dv_processado = 1
	FROM #tpm_id_endosso a
	WHERE a.id_endosso = @id_endosso
END

	--ROLLBACK
	--COMMIT