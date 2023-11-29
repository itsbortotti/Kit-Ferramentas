use segcorp
go

/*
select    ceiv.id_endosso_item_vida
                        into    #endossos -- drop table #endossos
                        from    corp_endosso_item_vida ceiv
                        where    ceiv.id_endosso = 27989324
                          and   isnull(ceiv.id_tp_movimento,0) not in (3,6)
						  and ceiv.id_endosso_item_vida = 1455395352
                          and   not exists (select top 1 1 from corp_endosso_item_vida_cap ceivc where ceivc.id_endosso_item_vida = ceiv.id_endosso_item_vida)


begin tran
declare @cd_retorno int, @nm_retorno varchar(255)
                        exec    corpsp_associar_nr_sorte_cap_item_segurado 
                                @id_endosso_item_vida    = null
                        ,        @nm_tabela                = '#endossos'
                        ,        @cd_retorno                = @cd_retorno output
                        ,        @nm_retorno                = @nm_retorno output
select nm_retorno = @nm_retorno
rollback
*/


if OBJECT_ID('tempdb..##log_registro_cap') is not null drop table ##log_registro_cap
create table ##log_registro_cap (contador int)



declare @id_endosso_item_vida int
      , @contador int = 0
      , @cd_retorno int
      , @nm_retorno varchar(255)


Declare c_SeguradosCap Insensitive Cursor For

	select   ceiv.id_endosso_item_vida --, cp_cli.Nm_pessoa
    from    corp_endosso_item_vida ceiv
	join    corp_item_vida civ
	  on    civ.id_pessoa_item = ceiv.id_pessoa_item
	join    corp_pessoas cp_cli
	  on    cp_cli.Id_pessoa = civ.id_pessoa
    where    ceiv.id_endosso = 28774124
	
        and   isnull(ceiv.id_tp_movimento,0) not in (3,6,1,5)
        and   not exists (select top 1 1 from corp_endosso_item_vida_cap ceivc where ceivc.id_endosso_item_vida = ceiv.id_endosso_item_vida)
      


Open c_SeguradosCap
Fetch c_SeguradosCap Into 
	@id_endosso_item_vida

While @@FETCH_STATUS <> -1
Begin
	
	set @contador = @contador + 1
	insert into ##log_registro_cap values (@contador)

	print 'contador: ' + cast(@contador as varchar)

	set @nm_retorno = null
                        exec    corpsp_associar_nr_sorte_cap_item_segurado 
                                @id_endosso_item_vida    = @id_endosso_item_vida
                        ,        @nm_tabela                = null
                        ,        @cd_retorno                = @cd_retorno output
                        ,        @nm_retorno                = @nm_retorno output
select nm_retorno = @nm_retorno


	Fetch c_SeguradosCap Into 
		@id_endosso_item_vida
End

Close c_SeguradosCap
Deallocate c_SeguradosCap


--commit