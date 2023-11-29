USE SEGCORP
BEGIN TRAN 

--INICIA AS VARIAVEIS
declare @cd_retorno int ,
		@nm_retorno varchar(255), 
		@id_endosso_item_vida int, 
		@Id_endosso int , 
		@id_pessoa_item int, 
		@Id_pessoa int, 
		@nm_pessoa varchar(50),
		@id_sexo int,
		@nr_cpf varchar(255),
		@while int 

select  @Id_endosso =  --id do endosso, 
		@while = 1

-----CRIA A TABELAS TEMPORARIAS
IF object_id('#cpfsegurado') IS NOT NULL
BEGIN
	DROP TABLE #cpfsegurado
END
	CREATE TABLE #cpfsegurado (id int IDENTITY(1,1) , nr_cpf varchar(255))

insert into #cpfsegurado(nr_cpf) values()--cpf dos segurados


if object_id('#retorno') IS NOT NULL 
begin
	drop table #retorno
end
	create table #retorno (cpf varchar(255), id_endosso_item_vida varchar(255),id_pessoa_item varchar(255),Id_pessoa varchar(255), cd_retorno int, nm_retorno varchar(255))
------------------------------------------------------------------------
--INICIA O LOOPING

while @while <= (select MAX(id)from #cpfsegurado)
begin

    select @nr_cpf = (select nr_cpf from #cpfsegurado where id = @while)

	Select top 1
			@Id_pessoa = civ.id_pessoa,
			@id_endosso_item_vida = ceiv.id_endosso_item_vida,
			@id_pessoa_item = civ.id_pessoa_item
	from corp_endosso_item_vida ceiv
	join corp_item_vida civ on civ.id_pessoa_item = ceiv.id_pessoa_item
	join corp_pessoas cp on cp.Id_pessoa = civ.id_pessoa
	where ceiv.id_endosso = @Id_endosso
	and cp.Nr_cnpj_cpf = @nr_cpf 
	
	---EXECUTA O ALTERAR SEGURADO  
	Exec corpsp_emis_alterar_segurado  
		@id_endosso_item_vida   			= @id_endosso_item_vida, 
		@Id_endosso							= @Id_endosso	        , 
		@id_pessoa_item						= @id_pessoa_item       , 
		@Id_pessoa							= @Id_pessoa,  
		@id_tp_movimento					= 3,  
		@cd_motivo							= 11,
		@cd_retorno							= @cd_retorno output, 
		@nm_retorno							= @nm_retorno output 
	
	SELECT @while = (@while + 1)

	INSERT INTO #retorno VALUES (@nr_cpf,@id_endosso_item_vida,@id_pessoa_item,@Id_pessoa,@cd_retorno,@nm_retorno)
	
END

IF EXISTS (SELECT * FROM #retorno WHERE cd_retorno <> 0 )
BEGIN 
	ROLLBACK
END
ELSE
	COMMIT

