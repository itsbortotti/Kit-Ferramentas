/*VOLTA AS URLS PARA OS AMBIENTES DE HML*/

/*GEM*/
IF EXISTS(SELECT TOP 1 1 FROM gem.t_gem_configuracao WHERE nm_url LIKE '%http://172.24.80.124:8080/gemapi%')
BEGIN
	UPDATE gem.t_gem_configuracao
		SET nm_url = 'http://172.24.70.71:8080/gemapi'
	WHERE id_gem_config = 1
END

/*JOKERDOCS*/
IF EXISTS(SELECT TOP 1 1 FROM jok.t_joker_configuracao WHERE nm_url LIKE '%https://jokerdocsws.segurosunimed.com.br/jokerintegration.asmx%')
BEGIN
	UPDATE jok.t_joker_configuracao
		SET nm_url = 'https://hml-joker.segurosunimed.com.br/jokerdocshlogws/JokerIntegration.asmx'
	WHERE id_joker_config = 1
END

/*GED*/
IF EXISTS(SELECT TOP 1 1 FROM bpm.t_bpm_parametro WHERE cd_parametro = 1 AND cd_recurso =1 AND vl_parametro LIKE '%\\UNIMED19\transito$\ged\pdf%')
BEGIN
	UPDATE bpm.t_bpm_parametro
		SET vl_parametro = '\\UNIMED02\Publico\Siscorp\GED'
	WHERE cd_parametro = 1 
		AND cd_recurso = 1
END