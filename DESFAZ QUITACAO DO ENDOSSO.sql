------------------------------------------------------------------------------------------------------------
--DESFAZ QUITAÇÃO DE UMA PARCELA: inicio
------------------------------------------------------------------------------------------------------------

declare @id_endosso int
Select @id_endosso = 28675080

delete clcc
  from corp_endosso_parcela cep
  join corp_parc_movto cpm
    on cpm.id_parcela = cep.Id_parcela
   and cpm.Cd_evento = 201
  join dbo.corp_comi_corr_movto cccm
    on cccm.Id_parcela_movimentacao = cpm.Id_parcela_movimentacao
  join dbo.corp_lancamento_contabil_consist clcc
    on clcc.id_comi_corr_movto = cccm.id_comi_corr_movto
 where cep.Id_endosso = @id_endosso

delete clcl
  from corp_endosso_parcela cep
  join corp_parc_movto cpm
    on cpm.id_parcela = cep.Id_parcela
   and cpm.Cd_evento = 201
  join dbo.corp_comi_corr_movto cccm
    on cccm.Id_parcela_movimentacao = cpm.Id_parcela_movimentacao
  join dbo.corp_lote_consist_log clcl
    on clcl.id_comi_corr_movto = cccm.id_comi_corr_movto
 where cep.Id_endosso = @id_endosso

delete cccm
  from corp_endosso_parcela cep
  join corp_parc_movto cpm
    on cpm.id_parcela = cep.Id_parcela
   and cpm.Cd_evento = 201
  join dbo.corp_comi_corr_movto cccm
    on cccm.Id_parcela_movimentacao = cpm.Id_parcela_movimentacao
 where cep.Id_endosso = @id_endosso

delete clcc
  from corp_endosso_parcela cep
  join corp_parc_movto cpm
    on cpm.id_parcela = cep.Id_parcela
   and cpm.Cd_evento = 201
  join dbo.corp_lancamento_contabil_consist clcc
    on clcc.id_parcela_movimentacao = cpm.id_parcela_movimentacao
 where cep.Id_endosso = @id_endosso

delete clcl
  from corp_endosso_parcela cep
  join corp_parc_movto cpm
    on cpm.id_parcela = cep.Id_parcela
   and cpm.Cd_evento = 201
  join dbo.corp_lote_consist_log clcl
    on clcl.id_parcela_movimentacao = cpm.id_parcela_movimentacao
 where cep.Id_endosso = @id_endosso

delete cpm
  from corp_endosso_parcela cep
  join corp_parc_movto cpm
    on cpm.id_parcela = cep.Id_parcela
   and cpm.Cd_evento = 201
 where cep.Id_endosso = @id_endosso

update corp_endosso_parcela
   set dv_situacao = 'P'
 where id_endosso = @id_endosso

------------------------------------------------------------------------------------------------------------
--DESFAZ QUITAÇÃO DE UMA PARCELA: fim
------------------------------------------------------------------------------------------------------------