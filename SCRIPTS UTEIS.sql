SELECT
CODIGO = lkp.id_pessoa,
DESCRICAO = lkp.nm_pessoa 
FROM corp_pessoas lkp (nolock)
JOIN dbo.t_pessoa_vinculada tpv 
ON lkp.id_pessoa = tpv.id_pessoa_socio

select * from dina_log where id_log = 1539

(1)	Pessoa					- cp.Nm_pessoa
(2)	Tipo Pessoa				- cp.Cd_tipo_pessoa
(3)	CPF						- cp.Nr_cnpj_cpf
(4)	Nome					- cp.Nm_pessoa
(5)	Data de Nascimento		- cp.Dt_nascimento
(6)	Sexo					- cp.id_sexo
(7)	Estado Civil			- cp.id_estado_civil
(8)	Não Residente			-
(9)	País 					-
(10)PEP?					-
(11)Tipo PEP				-
(12)E-mail					- cp.nm_email
(13)DDD e Telefone			- cp.nm_contato
(14)Usuário					-
(15)Dt Atualização			- cp.dt_alteracao


select top 10 * from corp_pessoas cp
select top 10 * from corp_sin_beneficiario
select top 10 * from corp_estado_civil
select top 10 * from CORP_PPE


SELECT 
codigo = lkp.id_estado_civil,
descricao = lkp.nm_estado_civil 
FROM corp_estado_civil lkp

Select a.name as 'Tabela', b.name as 'Coluna'
from sys.tables a inner join sys.columns b on a.object_id=b.object_id
where b.name like '%pep%'

Select * from dina_log where id_log =  1550
sp_helptext 'corpsp_alterar_beneficiario_detalhe'


SELECT distinct A.NAME, A.TYPE
  FROM SYSOBJECTS  A (nolock)
  JOIN SYSCOMMENTS B (nolock) 
    ON A.ID = B.ID
WHERE B.TEXT LIKE '%On e.cd_erro                    = 126%'  --- Informação a ser procurada no corpo da procedure, funcao ou view
  AND A.TYPE = 'P'                     --- Tipo de objeto a ser localizado no caso procedure
 ORDER BY A.NAME

 select * from corp_tp_movimento

  select  * from  vida_lote_detalhe where id_endosso = 28138905 
  select * from corp_layout

  sp_consulta 'civc.dv_nao_calcula'
  select * from dina_erros

  select dt_competencia,* from  corp_item_vida where id_pessoa_item = 492933798
  select * from corp_endosso_item_vida

  corpsp_alterar_valores_endosso


  corpsp_consistir_proposta

  corp_item_vida_cobertura
  civc.dv_nao_calcula 