use segcorp
SET ANSI_WARNINGS OFF
set nocount on
Set Transaction Isolation Level Read Uncommitted;

--begin tran -- rollback

declare @funcional        varchar(50),
        @dt_movimento     smalldatetime,
        @tipo_atualizacao int,
        @analista         varchar(20),
        @local            varchar(20),
        @email            varchar(100),
        @id_modulo        varchar(2),
        @tel_contato      varchar(20),
        @tempo_estimado   int
--###########################################################################################################################
-- A T E N Ç Ã O: Preencha os campos abaixo na primeira vez e depois faça apenas
--                a variação do Tempo Estimado de Uso e data de movimento desejada

--###########################################################################################################################

set @dt_movimento     = '20220202'                              -- indique a data de movimento desejada
set @funcional        = 'T02689'                                -- indique a sua funcional
set @analista         = 'Osvaldo Valtrig Jr'                               -- indique seu primeiro nome
set @local            = 'SEGUROS'                               -- indique seu local de trabalho
                                                                   -- SEGUROS
                                                                   -- HP
--set @email            = 'evida2@segurosunimed.com.br' -- indique seu e-mail
set @email            = 'osvaldo.valtrig.siscorp@segurosunimed.com.br' -- indique seu e-mail
set @tel_contato      = '(11) 3265-9224'                        -- indique seu telefone de contato
set @tipo_atualizacao = 4                                       -- indique o tipo de atualização
                                                                   -- 1 - Só Fechamento
                                                                   -- 2 - Só regras
                                                                   -- 3 - Só e-mails
                                                                   -- 4 - Tudo 
set @id_modulo = 99                                             -- indique o módulo de atualização
                                                                   -- 99 - TODOS 
                                                                   --  4 - Sinistros 
                                                                   --  5 - Emissao 
                                                                   -- 14 - Fechamento Mensal 
                                                                   -- 21 - Fechamento Diario 
                                                                   -- 22 - Fechamento Anual 
                                                                   -- 23 - Fechamento Impressao PDF
set @tempo_estimado = 120                                          -- indique o tempo estimado em MINUTOS que usará o fechamento

--###########################################################################################################################


-- Coloca o flag de grupo princial próximo ao número do grupo em Emissão/Apólices
update dina_coluna set nr_ordem = 4 where cd_coluna=7285

-- Aumenta o tamanho do campo Status da tela do fechamento diario
update dina set nm_query ='
SELECT cp.id_processo
       ,dv_executar = convert(BIT, 1)
       ,cm.nm_modulo
       ,cp.nm_processo
       ,nm_status = convert(varchar(120),cpl.nm_log)
       ,cm.id_modulo
       ,dt_movimento = cm.dt_movimento_contabil
       ,cp.id_periodo
       ,tempo = left(convert(VARCHAR, cpl.dt_log - cp2.dt_log, 114), 5)
       ,dv_fechamento_impressao = 0
       ,dv_executa_impressao = 1
FROM corp_processo cp(NOLOCK)
JOIN corp_modulo cm(NOLOCK) ON cm.id_modulo = cp.id_modulo
       AND cp.id_modulo = 21
       AND isnull(cp.dv_fechamento_impressao, 0) = 0
LEFT JOIN corp_processo_log cpl(NOLOCK) ON cpl.id_processo_log = (
              SELECT Max(log1.id_processo_log)
              FROM corp_processo cp1
              JOIN corp_processo_log log1 WITH (INDEX (XIF498corp_processo_log)) ON log1.id_processo = cp1.id_processo
                     AND log1.dt_movimento = cm.dt_movimento_contabil
              WHERE IsNull(cp1.id_processo_pai, cp1.id_processo) = cp.id_processo
              )
LEFT JOIN corp_processo_log cp2(NOLOCK) ON cp2.id_processo_log = (
              SELECT min(log1.id_processo_log)
              FROM corp_processo cp1
              JOIN corp_processo_log log1 WITH (INDEX (XIF498corp_processo_log)) ON log1.id_processo = cp1.id_processo
                     AND log1.dt_movimento = cm.dt_movimento_contabil
              WHERE IsNull(cp1.id_processo_pai, cp1.id_processo) = cp.id_processo
              )
'
where cd_dina = 139





-- Aumenta o tamanho do campo Status da tela do fechamento impressao
update dina set nm_query ='
select 	
   cp.id_processo,
   dv_executar = convert(bit, 1),
   cm.nm_modulo,
   cp.nm_processo,
   nm_status = convert(varchar(120),cpl.nm_log),
   cm.id_modulo,
   dt_movimento = cm.dt_movimento_impressao,
   cp.id_periodo,
   tempo = left(convert(varchar, cpl.dt_log - cp2.dt_log, 114), 5),
   dv_fechamento_impressao = 1, 
   dv_executa_impressao = 0
from corp_processo cp (nolock)
join corp_modulo cm (nolock)
on cm.id_modulo = cp.id_modulo
and cp.id_modulo = 21
and isnull(cp.dv_fechamento_impressao,0) = 1
left join corp_processo_log cpl (nolock)
on cpl.id_processo_log = (
	Select Max(log1.id_processo_log)
       	From corp_processo cp1
	Join corp_processo_log log1 with(index(XIF498corp_processo_log))
	   On log1.id_processo = cp1.id_processo
	 And log1.dt_movimento = cm.dt_movimento_impressao
	Where IsNull(cp1.id_processo_pai, cp1.id_processo) = cp.id_processo)
left join corp_processo_log cp2 (nolock)
on cp2.id_processo_log = (
	Select min(log1.id_processo_log)
       	From corp_processo cp1
	Join corp_processo_log log1 with(index(XIF498corp_processo_log))
	   On log1.id_processo = cp1.id_processo
	 And log1.dt_movimento = cm.dt_movimento_impressao
	Where IsNull(cp1.id_processo_pai, cp1.id_processo) = cp.id_processo)
'
where cd_dina = 1158

-- Aumenta o tamanho do campo Status da tela do fechamento mensal
update dina set nm_query ='
select 	
        cp.id_processo,
        dv_executar 	= convert(bit, 1),
        cm.nm_modulo,
        cp.nm_processo,
        nm_status = convert(varchar(120),cpl.nm_log),
        cm.id_modulo,
        dt_movimento = cm.dt_movimento_contabil,
        dv_fechamento_impressao = 0,
        dv_executa_impressao       = 1
from corp_processo cp with(nolock)
join corp_modulo cm with(nolock)
on cm.id_modulo	= cp.id_modulo
and cm.id_modulo=14
left join corp_processo_log cpl with(nolock)
on cpl.id_processo_log = 
       (Select Max(log1.id_processo_log)
       From corp_processo_log log1 with(nolock)
       Where (log1.id_processo = cp.id_processo Or
                      log1.id_processo In 
	(Select cp1.id_processo
	 From corp_processo cp1 with(nolock)
	 Where cp1.id_processo_pai = cp.id_processo))
	And log1.dt_movimento = cm.dt_movimento_contabil)
'
where cd_dina = 248

-- TRECHO DO FECHAMENTO DIÁRIO
if (@tipo_atualizacao = 1 or @tipo_atualizacao = 4)
begin
      delete corp_processo_log
      where dt_movimento = @dt_movimento
    
    if (@id_modulo = 21 or @id_modulo = 14) 
      begin
            insert into corp_processo_log
            (id_processo,dt_log,nm_log,dt_movimento,cd_tp_log,cd_proposta)
            select
            id_processo,
            getdate(),
            'Movimento de ' +
            convert(varchar,@dt_movimento,103) +
            ' reservado até as ' + 
            convert(varchar,DATEADD(MINUTE,@tempo_estimado,GETDATE()),108) +
            ' por ' +
            @analista +
            ' da ' +
            @local + 
            '. Fone: ' +
            @tel_contato +
            '. Entre em contato!',
            @dt_movimento,
            4,
            null
            from corp_processo
            where id_modulo = @id_modulo
      end
      else
      begin 
            insert into corp_processo_log
            (id_processo,dt_log,nm_log,dt_movimento,cd_tp_log,cd_proposta)
            select
            id_processo,
            getdate(),
            'Movimento de ' +
            convert(varchar,@dt_movimento,103) +
            ' reservado até as ' + 
            convert(varchar,DATEADD(MINUTE,@tempo_estimado,GETDATE()),108) +
            ' por ' +
            @analista +
            ' da ' +
            @local + 
            '. Fone: ' +
            @tel_contato +
            '. Entre em contato!',
            @dt_movimento,
            4, 
            null
            from corp_processo
            where id_modulo in(14,21)
      end
      if @id_modulo <> 99
       begin
            UPDATE CORP_MODULO
            SET DT_MOVIMENTO_CONTABIL = @dt_movimento
            WHERE ID_MODULO IN(@ID_MODULO)
       end
       else
        begin
            UPDATE CORP_MODULO
            SET DT_MOVIMENTO_CONTABIL = @dt_movimento
            , dt_movimento_impressao = @dt_movimento
        end

    print 'ATUALIZAÇÃO: Atualização Fechamento Diário Executada'
      
end


-- TRECHO DAS REGRAS DE USUÁRIO
if (@tipo_atualizacao = 2 or @tipo_atualizacao = 4)
begin 
      delete corp_usuario_regra
      where cd_usuario = @funcional

insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 8,1, convert(varchar(50),9999999999))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 44,1, convert(varchar(50),200000))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 45,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 47,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 59,1, convert(varchar(50),500))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 226,1, convert(varchar(50),NULL))
--insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 228,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 235,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 236,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 238,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 240,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 243,1, convert(varchar(50),1))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 245,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 252,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 258,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 264,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 275,1, convert(varchar(50),999999999))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 276,1, convert(varchar(50),99999999))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 283,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 309,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 319,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 328,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 333,1, convert(varchar(50),100))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 334,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 341,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 347,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 349,1, convert(varchar(50),15))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 350,0, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 353,1, convert(varchar(50),15))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 359,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 360,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 366,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 373,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 381,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 386,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 392,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 397,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 400,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 401,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 412,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 416,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 449,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 451,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 471,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 487,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 488,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 489,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 494,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 497,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 512,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 513,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 514,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 515,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 582,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 583,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 585,1, convert(varchar(50),NULL))
insert corp_usuario_regra (cd_usuario, cd_regra, dv_regra, vl_regra) values (@funcional, 586,1, convert(varchar(50),NULL))

      print 'ATUALIZAÇÃO: Atualização Regras de Usuário Executada'
      
end


-- TRECHO ATUALIZAÇÃO DOS E-MAILS E CAMINHOS PROCESSOS

if (@tipo_atualizacao = 3 or @tipo_atualizacao = 4)
begin
ALTER TABLE dbo.corp_pessoas DISABLE TRIGGER ASSOCIACAOTRG_PESSOAS
      update corp_pessoas
      set nm_email = @email,
      nm_email_sinistro = @email,
      dv_envia_email_processo_sinistro = 1,
      NM_EMAIL_SENHA = @EMAIL
--      where cd_tp_registro in (1,2,3,4,7,8,12,13) -- Corretor, Cliente, Segurado, Beneficiário, Congenere, Sub-Estipulante, Preposto, Agenciador
      where cd_tp_registro in (1,8,12,13) -- Corretor, Sub-Estipulante, Preposto, Agenciador

      update corp_filial 
      set nm_email = @email,
      dv_envia_email_processo_sinistro = 1 -- OK

      update corp_apolice_formulario_pdf_email -- OK
      set nm_email = @email

      update corp_apolice_email -- OK
      set nm_email = @email,
      nm_email_cc = @email

      update corp_cadastro_processo_email -- OK
      set nm_email = @email

      update corp_processo 
      set nm_diretorio = '\\unimed04\e-vida$\Osvaldo\' -- OK

      update corp_processo 
      set nm_diretorio = '\\unimed04\e-vida$\Osvaldo\' where id_processo = 139 -- OK

      update corp_processo 
      set nm_email = @email 

      update corp_cadastro_processo -- OK
      set nm_caminho = '\\unimed04\e-vida$\Osvaldo\'
      
      update du
      set nm_email = @email
      from corp_formulario_email cfe
      inner join dina_usuario du
      on du.cd_usuario = cfe.cd_usuario

      update dina_usuario set nm_email = @email

      update cfe
      set cd_usuario = @funcional
      from corp_formulario_email cfe

      update corp_apolice_email_pdf_txt
      set nm_email = @email,
          nm_email_cc = @email

      update corp_formulario_automatico
      set nm_caminho = '\\unimed04\e-vida$\Osvaldo\'
      
      update corp_empresa_regra
      set vl_regra = @email where cd_regra = 354 -- Remetente envio de email do Pagamento do Sinistro

      update corp_empresa
      set nm_smtp = '10.10.20.13', -- Espelhado
--      set nm_smtp = '10.10.10.5', -- Homologação
      nm_smtp_user = 'eapolice',
      nm_smtp_pwd = 'eapolice'

      update corp_processo_agrupamento_email
      set nm_email = @email

      update corp_forma_pagamento set nm_caminho_emissao = '\\unimed04\e-vida$\Osvaldo\Bancaria\Remessa\',
                                      nm_caminho_retorno = '\\unimed04\e-vida$\Osvaldo\Bancaria\Retorno\'

update corp_forma_pagamento set nm_caminho_retorno = '\\unimed04\e-vida$\Osvaldo\Bancaria\Bancoob\' where cd_forma_pagamento = 756	-- Bancoob
update corp_forma_pagamento set nm_caminho_retorno = '\\unimed04\e-vida$\Osvaldo\Bancaria\Bradesco\' where cd_forma_pagamento = 502	-- Bradesco
update corp_forma_pagamento set nm_caminho_retorno = '\\unimed04\e-vida$\Osvaldo\Bancaria\Banespa\' where cd_forma_pagamento = 501	-- Banespa
update corp_forma_pagamento set nm_caminho_retorno = '\\unimed04\e-vida$\Osvaldo\Bancaria\Itau\' where cd_forma_pagamento = 100	-- Itau
update corp_forma_pagamento set nm_caminho_retorno = '\\unimed04\e-vida$\Osvaldo\Bancaria\Itau\' where cd_forma_pagamento = 25	-- Itau
update corp_forma_pagamento set nm_caminho_retorno = '\\unimed04\e-vida$\Osvaldo\Bancaria\Uniprime\' where cd_forma_pagamento = 84	-- Uniprime
update corp_forma_pagamento set nm_caminho_retorno = '\\unimed04\e-vida$\Osvaldo\Bancaria\BB\' where cd_forma_pagamento = 27	-- BB


update corp_processo
      set nm_diretorio = '\\Unimed38\transito$\BaseCep\'
      where nm_processo = 'Atualiza da base de endereço'
      
ALTER TABLE dbo.corp_pessoas ENABLE TRIGGER ASSOCIACAOTRG_PESSOAS
      print 'ATUALIZAÇÃO: Atualização E-mails e caminhos padrões atualizado'
end

-- Atualiza base para não registrar boleto on-line

update srcc
  set cd_servico_soa_tp_ambiente = 1 -- Testes
 from servico_reg_cob_cadastro srcc
where isnull(srcc.cd_servico_soa_tp_ambiente,0) <> 1 


/*
Atualizando os caminhos da AXA\Brasil Assistência do caminho de produção para homologação
*/

begin tran
UPDATE	dina
SET		nm_query = REPLACE(CAST(nm_query AS VARCHAR(MAX)), '\\unimed19\transito$\interfaces\brasilassist\enviados\', '\\unimed04\e-vida$\Teste\Brasil')
WHERE	cd_dina = 683
commit work

/*
Atualizando os caminhos da AXA produção para homologação
*/

update corp_produto_cobertura_interface_texto
set nm_diretorio_saida = REPLACE(nm_diretorio_saida,'Produção', 'Homologação')
where nm_diretorio_saida like '%axaftp%'

