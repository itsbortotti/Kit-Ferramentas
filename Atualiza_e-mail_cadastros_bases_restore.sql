--atualiza os e-mails nas bases de testes

update corp_detalhe_simulacao_sindicato set nm_email = 'evida_dev@segurosunimed.com.br'
update corp_envio_email_retorno_pagamentos set email_para = 'evida_dev@segurosunimed.com.br'
update corp_pessoa_dado_adicional set nm_email = 'evida_dev@segurosunimed.com.br' where nm_email <> 'osvaldo.valtrig.siscorp@segurosunimed.com.br'
update corp_pessoas set nm_email = 'evida_dev@segurosunimed.com.br' 
where nm_email not in ('osvaldo.valtrig.siscorp@segurosunimed.com.br','paulo.silva.siscorp@segurosunimed.com.br', 'caio.paula.siscorp@segurosunimed.com.br')
update corp_sin_beneficiario set nm_email = 'evida_dev@segurosunimed.com.br' 
where nm_email not in ('osvaldo.valtrig.siscorp@segurosunimed.com.br','paulo.silva.siscorp@segurosunimed.com.br', 'caio.paula.siscorp@segurosunimed.com.br')
update corp_sinistro set nm_email = 'evida_dev@segurosunimed.com.br' 
where isnull(nm_email, 'osvaldo.valtrig.siscorp@segurosunimed.com.br') not in ('osvaldo.valtrig.siscorp@segurosunimed.com.br','paulo.silva.siscorp@segurosunimed.com.br', 'caio.paula.siscorp@segurosunimed.com.br')
update corp_sub_agendamento set emailCliente = 'evida_dev@segurosunimed.com.br' where emailCliente is not null 
update corp_sub_estipulante set nm_email = 'evida_dev@segurosunimed.com.br' where nm_email is not null 


