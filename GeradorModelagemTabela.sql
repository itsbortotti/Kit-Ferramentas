
/* Instruções:
          1. Colocar o nome da tabela a gerar na variavel @tabela_nome abaixo
          2. Rodar o script no modo 'results to text'
          3. Copiar o resultado
*/
declare @tabela varchar(250) =  'res.corp_incendio_locais'  --  <---- Coloque o nome da tabela aqui!!!


set nocount on 
set xact_abort on

declare @dc_revision varchar(50) = replace(replace('$Revision: 1.1 $', '$', ''),'Revision', 'Versão')
declare @drop_fk_ix bit = 1		-- se 1 gera script para apagar indices e fks que estejam a mais


/* Remove inconsistencias */
declare	@tabela_id int, @object_id bigint
declare @nm_comando varchar(max), @tabela_nome varchar(256), @tabela_nome_completo	varchar(256), @pos int
	
set @tabela = replace(replace(REPLACE(@tabela,'[',''),']',''),' ','')

set @tabela_id = OBJECT_ID(@tabela)
set @tabela_nome = OBJECT_NAME(@tabela_id)
set @tabela_nome_completo = '[' + isnull(OBJECT_SCHEMA_NAME(@tabela_id),'') + '].[' + @tabela_nome + ']'

if @tabela_id is null
begin    
	set @nm_comando = '********* ERRO TABELA ''' + @tabela + ''' não encontrada!! ***************'
	raiserror (@nm_comando, 16, 1, 50000)
	return
end

/* Gera tabelas temporárias com as informações da tabela */

-- Campos
IF OBJECT_ID('TempDB.dbo.#campos') IS NOT NULL
	drop table #campos

select column_id = sysc.column_id,
		column_name = sysc.name,
		column_name_string = '[' + sysc.name + ']',
		column_type = usert.name,
		column_type_string = case 
								when usert.name != syst.name then '[' +  SCHEMA_NAME(usert.schema_id) +'].['+ usert.name + ']'
								else '['+ syst.name + '] ' 
								+   case
										when syst.name = 'numeric' and isnull(sysc.scale, 0) > 0 then '(' + cast(sysc.precision as varchar(10)) + ',' + cast(isnull(sysc.scale, 0) as varchar(10)) + ')'
										when syst.name = 'numeric' then '(' + cast(sysc.precision as varchar(10)) + ')'
										when syst.name in ('char', 'varchar','nchar','nvarchar') and sysc.max_length < 1 then '(max)'
										when syst.name in ('char', 'varchar','nchar','nvarchar') then '(' + cast(sysc.max_length as varchar(10)) + ')'
										else '' 
									end
							end, 
		is_identity = sysc.is_identity,
		identity_string = case when sysc.is_identity = 1 then 'IDENTITY(1,1)' else '' end,
		is_nullable = sysc.is_nullable,
		nullable_string = case when sysc.is_nullable = 1 then 'NULL' else 'NOT NULL' end,
		default_name = dc.name,
		default_definition = replace(dc.definition,'''', ''''''),
		column_num_scale = isnull(sysc.scale, 0),
		column_num_precision = ISNULL(sysc.precision, 0),
		column_max_length = isnull(sysc.max_length, 0)
	into #campos
	from sys.columns sysc 
			inner join sys.types usert
				on sysc.user_type_id = usert.user_type_id								
			inner join sys.types syst
				on sysc.system_type_id = syst.user_type_id
			left join sys.default_constraints dc 
				on sysc.default_object_id = dc.object_id   
		where sysc.object_id = @tabela_id

-- Indices
IF OBJECT_ID('TempDB.dbo.#indices') IS NOT NULL
	drop table #indices

select index_id = idx.index_id
		, column_list = idxc.colunas
		, index_name_padrao = Left(
				case when idx.is_primary_key = 1 
					then 'PK_' + @tabela_nome + '(' + replace(replace(replace(idxc.colunas, ',', '$'), '[', ''), ']', '') + ')' 
					else 'IX_' + @tabela_nome + '(' + replace(replace(replace(idxc.colunas, ',', '$'), '[', ''), ']', '') + ')' 
				end
		  , 128)
		, is_primary_key = idx.is_primary_key
		, is_unique = idx.is_unique
	into #indices
	from sys.indexes idx 
		cross apply (
					select colunas = STUFF((
						select ',[' + col_name(idxc.object_id, idxc.column_id) + ']'
							from sys.index_columns idxc
							where idxc.index_id = idx.index_id 
								and idxc.object_id = idx.object_id
								and idxc.key_ordinal > 0 -- exclude include and partitioned index columns
							order by idxc.key_ordinal
							for XML path('')
						),1,1,'')
				) idxc
	where idx.object_id = @tabela_id and idx.name is not null

if (select count(*) from #indices) != (select count(*) from (select distinct nome_padrao_sem_tipo = substring(index_name_padrao, 4, 256) from #indices) as x )
begin    
	set @nm_comando = '********* ERRO TABELA ''' + @tabela_nome_completo + ''' com indices duplicados (mais de um indice usando as mesmas colunas)!! ***************'
	raiserror (@nm_comando, 16, 1, 50000)
	return
end
	
-- Indices colunas
IF OBJECT_ID('TempDB.dbo.#indices_colunas') IS NOT NULL
	drop table #indices_colunas

select index_id = idxc.index_id
		, key_ordinal = idxc.key_ordinal
		, column_name = col_name(idxc.object_id, idxc.column_id)
	into #indices_colunas
	from sys.indexes idx 
		inner join sys.index_columns idxc on idxc.index_id = idx.index_id 
			and idxc.object_id = idx.object_id
			and idxc.key_ordinal > 0 -- exclui: include and partitioned index columns
	WHERE idx.object_id = @tabela_id

-- Fks
IF OBJECT_ID('TempDB.dbo.#fks') IS NOT NULL
	drop table #fks

select fk_id = f.object_id
		, fk_name_padrao = LEFT('FK_' + @tabela_nome + '_X_' + OBJECT_NAME(f.referenced_object_id) + '(' + replace(replace(replace(k.colunas, ',', '$'), '[', ''), ']', '') + ')', 128)
		, table_ref = '[' + OBJECT_SCHEMA_NAME(f.referenced_object_id) + '].[' + OBJECT_NAME(f.referenced_object_id) + ']'
		, column_list = k.colunas
		, column_list_ref = krc.colunas
		, fkdelete = case when f.delete_referential_action = 1 then ' on delete ' +  f.delete_referential_action_desc collate SQL_Latin1_General_CP1_CI_AI else '' end
		, fkupdate = case when f.update_referential_action = 1 then ' on update ' +  f.update_referential_action_desc collate SQL_Latin1_General_CP1_CI_AI else '' end
	into #fks
	from sys.foreign_keys f 
		outer apply (
			select colunas = STUFF((
				select ',[' + col_name(k.parent_object_id, k.parent_column_id) + ']' 
					from sys.foreign_key_columns k	
					where k.constraint_object_id = f.object_id
					order by k.constraint_object_id, k.constraint_column_id
					for XML path('')
				),1,1,'')
		) k
		outer apply (
			select colunas = STUFF((
				select ',[' + col_name(krc.referenced_object_id, krc.referenced_column_id) + ']' 
					from sys.foreign_key_columns krc	
					where krc.constraint_object_id = f.object_id
					order by krc.constraint_object_id, krc.constraint_column_id
					for XML path('')
				),1,1,'')
		) krc
	WHERE f.parent_object_id = @tabela_id

if (select count(*) from #fks) != (select count(*) from (select distinct fk_name_padrao from #fks) as x )
begin    
	set @nm_comando = '********* ERRO TABELA ''' + @tabela_nome_completo + ''' com fks duplicadas (mais de uma fk referenciando as mesmas colunas)!! ***************'
	raiserror (@nm_comando, 16, 1, 50000)
	return
end

-- Fks colunas
IF OBJECT_ID('TempDB.dbo.#fks_colunas') IS NOT NULL
	drop table #fks_colunas

select fk_id = f.object_id 
		, fk_column_id = k.constraint_column_id
		, table_ref = OBJECT_NAME(f.referenced_object_id)
		, column_name = col_name(k.parent_object_id, k.parent_column_id)
		, column_name_ref = col_name(k.referenced_object_id, k.referenced_column_id)
	into #fks_colunas
	from sys.foreign_keys f 
		inner join sys.foreign_key_columns k on f.object_id = k.constraint_object_id 
	WHERE f.parent_object_id = @tabela_id
			

/* INICIA A IMPRESSÃO DAS INFORMAÇÕES */	
print('')
print('-- Modelagem: ' + @tabela_nome_completo )
print('-- Gerado automaticamente pelo script_gerador_modelagem_tabela_meta.sql')
print('-- Revisão:   ' + @dc_revision )
print('-- Data:      ' + convert(varchar(30), getdate(), 121))
print('')
	
print ('set nocount on ')
print ('set xact_abort on ')
print ('')
print ('declare	@tabela_id int, @object_id int,	@nm_comando_todo varchar(max), @nm_comando1 varchar(max), @nm_comando2 varchar(max)')
print ('declare @column_name varchar(500), @is_primary_key bit, @is_identity bit, @is_nullable bit, @column_num_scale tinyint, @column_num_precision tinyint, @column_max_length smallint')
print ('declare @index_name varchar(128), @index_name_local varchar(256), @index_name_local_struct varchar(256)')
print ('declare @fk_name varchar(128), @fk_name_local varchar(256)')

print ('declare @campos table (column_id int, column_name varchar(100), column_create varchar(500), column_add varchar(1000), column_alter varchar(1000), column_default varchar(1000), is_identity bit, is_nullable bit, column_num_scale int, column_num_precision int, column_max_length int)')
print ('declare @indices table (index_id int, index_name varchar(1000), is_primary_key bit, cmd_ins varchar(1000))')
print ('declare @indices_columns table (index_id int, key_ordinal	int, column_name varchar(100))')
print ('declare @fks table (fk_id int, fk_name	varchar(1000), cmd_ins varchar(1000))')
print ('declare @fks_columns table (fk_id int, table_ref varchar(200), column_name varchar(100), column_name_ref	varchar(100))')


/* gera metadados das colunas */
if (select count(*) from #campos) > 0
begin
	print ('')
	print ('INSERT @CAMPOS (column_id, column_name, column_create, column_add, column_alter, column_default, is_identity, is_nullable, column_num_scale, column_num_precision, column_max_length) ')
	print (SPACE(5) + 'VALUES')

	SET @object_id = 0

	WHILE 1 = 1
	BEGIN
		set @nm_comando = null
	        
		select top 1
				@nm_comando = case when @object_id = 0 then ' (' else ',(' end +
				+ isnull(cast(column_id as varchar(30)), 'null') + ', '
				+ isnull('''' + column_name + '''', 'null') + ', '
				+ isnull('''' + column_name_string + ' ' + column_type_string + ' ' + identity_string + ' ' + nullable_string + isnull(' CONSTRAINT [' + default_name + '] DEFAULT ' + default_definition, '') + '''', 'null') + ', '
				+ isnull('''' +  -- Coluna nova desde que aceite null ou tenha default		
						case when is_nullable = 1 or default_name is not null 
							then 'ALTER TABLE ' + @tabela_nome_completo + ' ADD ' + column_name_string + ' ' + column_type_string + ' ' + identity_string + ' ' + nullable_string + isnull(' CONSTRAINT [' + default_name + '] DEFAULT ' + default_definition + ' WITH VALUES', '')
							else null
						end
						+ '''', 'null') + ', '
				+ isnull('''' + 'ALTER TABLE ' + @tabela_nome_completo + ' ALTER COLUMN ' + column_name_string + ' ' + column_type_string + ' ' + nullable_string + '''', 'null') + ', '
				+ isnull('''' + 'ALTER TABLE ' + @tabela_nome_completo + ' ADD CONSTRAINT [' + default_name + '] DEFAULT ' + default_definition + ' FOR ' + column_name + '''', 'null') + ', '
				+ isnull(cast(is_identity as char(1)), 'null') + ', '
				+ isnull(cast(is_nullable as char(1)), 'null') + ', '
				+ isnull(cast(column_num_scale as varchar(30)), 'null') + ', '
				+ isnull(cast(column_num_precision as varchar(30)), 'null') + ', '
				+ isnull(cast(column_max_length as varchar(30)), 'null') + ')'
			,@object_id = column_id
		from #campos
		where column_id > @object_id
		order by column_id
		
		if @nm_comando is null break
			
		print(space(5) +  @nm_comando)
	END

end

/* gera metadados dos indices */
if (select count(*) from #indices) > 0
begin
	print ('')
	print ('INSERT @indices (index_id, index_name, is_primary_key, cmd_ins) ')
	print (SPACE(5) + 'VALUES')

	SET @object_id = 0

	WHILE 1 = 1
	BEGIN
		set @nm_comando = null
	        
		select top 1
					@nm_comando = case when @object_id = 0 then ' (' else ',(' end +
					+ isnull(cast(index_id as varchar(30)), 'null') + ', '
					+ isnull('''' + index_name_padrao + '''', 'null') + ', '
					+ isnull(cast(is_primary_key as char(1)), 'null') + ', '
					+ isnull('''' +    
							case when is_primary_key = 1 
								then 'ALTER TABLE ' + @tabela_nome_completo + ' ADD CONSTRAINT [' + index_name_padrao + '] PRIMARY KEY CLUSTERED (' + column_list + ') WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]' 
								else 'CREATE ' + case when is_unique = 1 then 'UNIQUE ' else '' end + 'NONCLUSTERED INDEX [' + index_name_padrao + '] ON ' + @tabela_nome_completo + ' (' + column_list + ')' 
							end 
						+ '''' , 'null') + ') '
				,@object_id = index_id
			from #indices idx
			where idx.index_id > @object_id
			order by index_id

		if @nm_comando is null break
			
		print(space(5) +  @nm_comando)
	END

	/* gera metadados das colunas dos indices */
	print ('')
	print ('INSERT @indices_columns (index_id, key_ordinal, column_name)')
	print (SPACE(5) + 'VALUES')

	SET @object_id = 0

	WHILE 1 = 1
	BEGIN
			set @nm_comando = null

			select top 1
					@nm_comando = case when @object_id = 0 then ' (' else ',(' end +
						+ isnull(cast(index_id as varchar(30)), 'null') + ', '
						+ isnull(cast(key_ordinal as varchar(30)), 'null') + ', '
						+ isnull('''' + column_name + '''', 'null') + ') ' 
					,@object_id = cast(index_id  as bigint) * 1000 + key_ordinal
				from #indices_colunas idxc
				where cast(index_id  as bigint) * 1000 + key_ordinal > @object_id
				order by index_id, key_ordinal

			if @nm_comando is null break
			
			print(space(5) +  @nm_comando)
	END
end

/* gera metadados das FKs */
if (select count(*) from #fks) > 0
begin
	print ('')
	print ('INSERT @fks (fk_id, fk_name, cmd_ins) ')
	print (SPACE(5) + 'VALUES')

	SET @object_id = 0

	WHILE 1 = 1
	BEGIN
			set @nm_comando = null

			select top 1
					@nm_comando = case when @object_id = 0 then ' (' else ',(' end +
						+ isnull(cast(fk_id as varchar(30)), 'null') + ', '
						+ isnull('''' + fk_name_padrao + '''', 'null') + ', ' 
						+ isnull('''' + 'ALTER TABLE ' + @tabela_nome_completo + ' WITH NOCHECK ADD CONSTRAINT [' + fk_name_padrao + '] FOREIGN KEY (' + column_list + ') REFERENCES ' + table_ref + '(' + column_list_ref + ')' + (fkdelete COLLATE DATABASE_DEFAULT) + (fkupdate COLLATE DATABASE_DEFAULT) + '; ALTER TABLE ' + @tabela_nome_completo + ' CHECK CONSTRAINT [' + fk_name_padrao + ']' + '''', 'null') +  ') '
					,@object_id = fk_id
				from #fks f
				WHERE f.fk_id > @object_id
				order by fk_id

			if @nm_comando is null break
			
			print(space(5) +  @nm_comando)
	END

	/* gera metadados das colunas das FKs */
	print ('')
	print ('INSERT @fks_columns (fk_id, table_ref, column_name, column_name_ref)')
	print (SPACE(5) + 'VALUES')

	SET @object_id = 0

	WHILE 1 = 1
	BEGIN
			set @nm_comando = null

			select top 1
					@nm_comando = case when @object_id = 0 then ' (' else ',(' end +
						+ isnull(cast(fk_id as varchar(30)), 'null') + ', '
						+ isnull('''' + table_ref + '''', 'null') + ', ' 
						+ isnull('''' + column_name + '''', 'null') + ', ' 
						+ isnull('''' + column_name_ref + '''', 'null') +  ') '
					,@object_id = cast(fk_id as bigint) * 1000 + fk_column_id
				from #fks_colunas f
				WHERE cast(fk_id  as bigint) * 1000 + fk_column_id > @object_id
				order by fk_id, fk_column_id

			if @nm_comando is null break
			
			print(space(5) +  @nm_comando)
	END

end

/* Criação da tabela */
if (select count(*) from #campos) > 0
begin
	print('')	
	print('/* CRIAÇÃO DA TABELA */')
	print ('')
	print ('set @tabela_id = OBJECT_ID(N''' + @tabela_nome_completo + ''')')
	print ('')
	print(space(0)	+ 'IF @tabela_id is null')
	print(space(0)	+ 'BEGIN')
	print(space(5)		+ 'SET @NM_COMANDO_TODO = ''CREATE TABLE ' + @tabela_nome_completo + '(''')
	print(space(5)		+ '')	
	print(space(5)		+ 'SET @object_id = 0')
	print(space(5)		+ '')
	print(space(5)		+ 'WHILE 1 = 1')
	print(space(5)		+ 'BEGIN')
	print(space(10)			+ 'set @nm_comando1 = null')
	print(space(10)			+ '') 	        
	print(space(10)			+ 'select top 1')
	print(space(15)				+ '@object_id = column_id,')
	print(space(15)				+ '@nm_comando1	= cp.column_create')
	print(space(15)				+ 'from @campos cp')
	print(space(15)				+ 'where column_id > @object_id')
	print(space(15)				+ 'order by column_id')
	print(space(15)				+ '')			
	print(space(10)			+ 'if @nm_comando1 is null break')
	print(space(10)			+ '')			
	print(space(10)			+ 'SET @NM_COMANDO_TODO = @NM_COMANDO_TODO + @nm_comando1 + '','' ')
	print(space(5)		+ 'END')
	print(space(5)		+ '')
	print(space(5)		+ 'SET @NM_COMANDO_TODO = @NM_COMANDO_TODO + '') ON [PRIMARY]'' ')
	print(space(5)		+ '')
	print(space(5)		+ 'EXEC(@NM_COMANDO_TODO)')
	print(space(5)		+ 'SET @tabela_id = OBJECT_ID(N''' + @tabela_nome_completo + ''')')
	print(space(0)	+ 'END')
	print(space(0)	+ 'ELSE')
	
	/* Manutenção de campos novos da tabela  */	
	-- Obs.: campos novos NOT NULL não podem ser levados, pois a tabela no destino pode conter dados incorrendo no erro:
	-- .....ALTER TABLE only allows columns to be added that can contain nulls, or have a DEFAULT definition specified, or the column being added is an identity or timestamp column, or alternatively if none of the previous conditions are satisfied the table must be empty to allow addition of this column. Column 'dv_tela_dv_obrigatorio' cannot be added to non-empty table 'sdk_middleware_tp_layout_secao' because it does not satisfy these conditions.
	print(space(0)	+ 'BEGIN')
	print(space(5)		+ '/* Manutenção de campos */')
	print(space(5)		+ '')
	print(space(5)		+ 'SET @object_id = 0')
	print(space(5)		+ '')
	print(space(5)		+ 'WHILE 1 = 1')
	print(space(5)		+ 'BEGIN')
	print(space(10)			+ 'set @nm_comando1 = null')
	print(space(10)			+ 'set @nm_comando2 = null')
	print(space(10)			+ '')	        
	print(space(10)			+ 'select top 1')
	print(space(15)				+ '@object_id = cp.column_id,')
	print(space(15)				+ '@column_name = cp.column_name,')
	print(space(15)				+ '@nm_comando1	= cp.column_add,')
	print(space(15)				+ '@nm_comando2	= cp.column_alter,')
	print(space(15)				+ '@is_identity = cp.is_identity,')
	print(space(15)				+ '@is_nullable = cp.is_nullable,')
	print(space(15)				+ '@column_max_length = cp.column_max_length,')
	print(space(15)				+ '@column_num_precision = cp.column_num_precision,')
	print(space(15)				+ '@column_num_scale = cp.column_num_scale')
	print(space(15)				+ 'from @campos cp')
	print(space(15)				+ 'where cp.column_id > @object_id')
	print(space(15)				+ 'order by cp.column_id')
	print(space(15)				+ '')		
	print(space(10)			+ 'if @nm_comando1 is null and @nm_comando2 is null break')
	print(space(10)			+ '')		
	print(space(10)			+ 'IF NOT EXISTS (SELECT TOP 1 1 FROM SYS.COLUMNS C WHERE object_id = @tabela_id AND C.NAME = @column_name)')
	print(space(10)			+ 'BEGIN ')			-- Coluna nova 		
	print(space(15)				+ 'if @nm_comando1 is not null')		
	print(space(20)					+ 'EXEC(@nm_comando1)')
	print(space(10)			+ 'END')
	print(space(10)			+ 'ELSE IF EXISTS (SELECT TOP 1 1 FROM SYS.COLUMNS C WHERE object_id = @tabela_id AND C.NAME = @column_name AND ((c.is_nullable != @is_nullable and c.is_identity = 0) OR isnull(case when c.max_length = -1 then @column_max_length else c.max_length end, 0) < @column_max_length OR isnull(c.precision,0) < @column_num_precision OR isnull(c.scale,0) < @column_num_scale))')
	print(space(10)			+ 'BEGIN ')			-- Alteração só se o tipo aumentou de tamanho e campo passou a aceitar null		
	print(space(15)				+ '')			-- Apaga todas as dependencias da coluna antes de alterar
	print(space(15)				+ 'declare @id_drop int, @nm_cmd_drop varchar(max), @colum_id int')
	print(space(15)				+ 'select @colum_id = column_id from sys.columns c where c.object_id = @tabela_id and name = @column_name')
	print(space(15)				+ '')
	print(space(15)				+ 'SET @id_drop = 0') -- DROP DEFAULTS
	print(space(15)				+ '')
	print(space(15)				+ 'WHILE 1 = 1')  
	print(space(15)				+ 'BEGIN')
	print(space(20)					+ 'set @nm_cmd_drop = null')
	print(space(20)					+ '')	        
	print(space(20)					+ 'SELECT TOP 1 @id_drop = object_id,')
	print(space(25)						+ '@nm_cmd_drop = ''ALTER TABLE ' + @tabela_nome_completo + ' DROP CONSTRAINT ['' + name + '']'' ')
	print(space(20)					+ 'FROM SYS.DEFAULT_CONSTRAINTS')
	print(space(20)					+ 'WHERE parent_object_id = @tabela_id and parent_column_id = @colum_id')
	print(space(25)						+ 'and object_id > @id_drop')
	print(space(20)					+ 'order by object_id')
	print(space(20)					+ '')	        
	print(space(20)					+ 'if @nm_cmd_drop is null break')
	print(space(20)					+ 'EXEC(@nm_cmd_drop)')
	print(space(15)				+ 'END')
	print(space(15)				+ '')
	print(space(15)				+ 'SET @id_drop = 0')  -- DROP FKS
	print(space(15)				+ '')
	print(space(15)				+ 'WHILE 1 = 1')
	print(space(15)				+ 'BEGIN')
	print(space(20)					+ 'set @nm_cmd_drop = null')
	print(space(20)					+ '')	        
	print(space(20)					+ 'select TOP 1 @id_drop = f.object_id')	        
	print(space(25)						+ ',@nm_cmd_drop = ''ALTER TABLE ['' + OBJECT_SCHEMA_NAME(f.parent_object_id) + ''].['' + object_name(f.parent_object_id) + ''] DROP CONSTRAINT ['' + f.name + '']'' ')	        
	print(space(20)					+ 'from sys.foreign_keys f inner join sys.foreign_key_columns k on f.object_id = k.constraint_object_id ')	        
	print(space(20)					+ 'WHERE ((k.parent_object_id = @tabela_id and k.parent_column_id = @colum_id) or (k.referenced_object_id = @tabela_id and k.referenced_column_id = @colum_id))')	        
	print(space(25)						+ 'and f.object_id > @id_drop')	        
	print(space(20)					+ 'order by f.object_id')
	print(space(20)					+ '')	        
	print(space(20)					+ 'if @nm_cmd_drop is null break')
	print(space(20)					+ 'EXEC(@nm_cmd_drop)')
	print(space(15)				+ 'END')
	print(space(15)				+ '')
	print(space(15)				+ 'SET @id_drop = 0')  -- DROP STATS
	print(space(15)				+ '')
	print(space(15)				+ 'WHILE 1 = 1')
	print(space(15)				+ 'BEGIN')
	print(space(20)					+ 'set @nm_cmd_drop = null')
	print(space(20)					+ '')	        
	print(space(20)					+ 'SELECT TOP 1 @id_drop = f.object_id')	        
	print(space(25)						+ ',@nm_cmd_drop = ''DROP STATISTICS ' + @tabela_nome_completo + '.['' + f.name + '']'' ')	        
	print(space(20)					+ 'FROM SYS.STATS F inner join sys.stats_columns c on f.object_id = c.object_id and f.stats_id = c.stats_id')	        
	print(space(20)					+ 'WHERE c.OBJECT_ID = @tabela_id and c.column_id = @colum_id AND USER_CREATED = 1 ')	        
	print(space(25)						+ 'and f.object_id > @id_drop')	        
	print(space(20)					+ 'order by f.object_id')
	print(space(20)					+ '')	        
	print(space(20)					+ 'if @nm_cmd_drop is null break')
	print(space(20)					+ 'EXEC(@nm_cmd_drop)')
	print(space(15)				+ 'END')
	print(space(15)				+ '')
	print(space(15)				+ 'SET @id_drop = 0') -- DROP INDEX
	print(space(15)				+ '')
	print(space(15)				+ 'WHILE 1 = 1')  
	print(space(15)				+ 'BEGIN')
	print(space(20)					+ 'set @nm_cmd_drop = null')
	print(space(20)					+ '')	        
	print(space(20)					+ 'SELECT TOP 1 @id_drop = idx.index_id')	        
	print(space(25)						+ ', @nm_cmd_drop = case ')	        
	print(space(30)							+ 'when IDX.IS_UNIQUE_CONSTRAINT = 1 OR IDX.IS_PRIMARY_KEY = 1 then ''ALTER TABLE ' + @tabela_nome_completo + ' DROP CONSTRAINT ['' + IDX.NAME + '']'' ')	        
	print(space(30)							+ 'ELSE ''DROP INDEX ['' + idx.name + ''] ON ' + @tabela_nome_completo + ''' ')	        
	print(space(25)						+ 'end')	        
	print(space(20)					+ 'from sys.indexes idx inner join sys.index_columns idxc on idxc.index_id = idx.index_id 	and idxc.object_id = idx.object_id')	        
	print(space(20)					+ 'WHERE idxc.object_id = @tabela_id and idxc.column_id = @colum_id')	        
	print(space(25)						+ 'and idx.index_id > @id_drop')	        
	print(space(20)					+ 'order by idx.index_id')
	print(space(20)					+ '')	        
	print(space(20)					+ 'if @nm_cmd_drop is null break')
	print(space(20)					+ 'EXEC(@nm_cmd_drop)')
	print(space(15)				+ 'END')
	print(space(15)				+ '')
	print(space(15)				+ 'EXEC(@nm_comando2)')
	print(space(10)			+ 'END')
	print(space(5)		+ 'END')
	print(space(0)	+ 'END')
	
	/* DEFAULT*/
	print(space(0)	+ '')
	print(space(0)	+ '/* DEFAULT */')	
	print(space(0)	+ '')
	print(space(0)	+ 'SET @object_id = 0')
	print(space(0)	+ '')
	print(space(0)	+ 'WHILE 1 = 1')
	print(space(0)	+ 'BEGIN')
	print(space(5)		+ '')
	print(space(5)		+ 'set @nm_comando1 = null')
	print(space(5)		+ '')        						
	print(space(5)		+ 'SELECT TOP 1') 
	print(space(10)			+ '@object_id = cp.column_id,')
	print(space(10)			+ '@column_name	= cp.column_name,')			
	print(space(10)			+ '@nm_comando1 = cp.column_default')					
	print(space(10)			+ 'from @campos cp')				
	print(space(10)			+ 'where cp.column_default is not null')
	print(space(10)			+ '   and cp.column_id > @object_id')
	print(space(10)			+ 'order by cp.column_id')
	print(space(5)		+ '')
	print(space(5)		+ 'if @nm_comando1 is null break')
	print(space(5)		+ '')
	print(space(5)      + 'IF NOT EXISTS(SELECT top 1 1 FROM SYS.DEFAULT_CONSTRAINTS WHERE PARENT_OBJECT_ID = @tabela_id AND PARENT_COLUMN_ID = (select column_id from sys.columns where object_id = @tabela_id and name = @column_name ))'  )
	print(space(5)		+ 'BEGIN')
	print(space(10)			+ 'EXEC(@nm_comando1)')
	print(space(5)		+ 'END')
	print(space(0)	+ 'END')
end

/* Indices */	
if (select count(*) from #indices) > 0
begin
	print(space(0)	+ '')
	print(space(0)	+ '/* Indices */')
	print(space(0)	+ '')
	print(space(0)	+ 'SET @object_id = 0')
	print(space(0)	+ '')	
	print(space(0)	+ 'WHILE 1 = 1')
	print(space(0)	+ 'BEGIN')
	print(space(5)		+ '')
	print(space(5)		+ 'set @nm_comando1 = null')
	print(space(5)		+ '')        
	print(space(5)		+ 'select top 1')
	print(space(10)			+ '@object_id = idxt.index_id,')
	print(space(10)			+ '@nm_comando1 = idxt.cmd_ins,')
	print(space(10)			+ '@is_primary_key = idxt.is_primary_key,')
	print(space(10)			+ '@index_name = idxt.index_name,')
	print(space(10)         + '@index_name_local = nome.name,')
	print(space(10)         + '@index_name_local_struct = colu.name')
	print(space(10)			+ 'from @indices idxt') 
	print(space(15)				+ 'outer apply (') -- Procura indice na base local com exatamente as mesmas colunas
	print(space(20)					+ 'select top 1 idxl.name') 
	print(space(20)					+ 'from sys.indexes idxl') 
	print(space(20)					+ 'where idxl.object_id = @tabela_id')
	print(space(25)						+ 'and idxl.is_primary_key = idxt.is_primary_key ')
	print(space(25)						+ 'and exists (select 1 from @indices_columns idxct where idxt.index_id = idxct.index_id)')
	print(space(25)						+ 'and not exists (')  
	print(space(30)							+ 'select 1 ')
	print(space(30)							+ 'from @indices_columns idxct ')
	print(space(30)							+ 'left join sys.index_columns idxcl ')
	print(space(30)							+ 'on col_name(idxcl.object_id, idxcl.column_id) = idxct.column_name ')
	print(space(30)							+ 'and idxcl.key_ordinal = idxct.key_ordinal')
	print(space(30)							+ 'and idxl.object_id = idxcl.object_id')
	print(space(30)							+ 'and idxl.index_id = idxcl.index_id')
	print(space(30)							+ 'where idxt.index_id = idxct.index_id')
	print(space(30)							+ 'and idxcl.column_id is null')
	print(space(25)						+ ')')
	print(space(20)					+ 'order by idxl.is_unique_constraint desc, idxl.is_unique')
	print(space(15)				+ ') colu') 
	print(space(15)				+ 'outer apply ( ') -- Procura indice na base local com o mesmo nome ou se pk o nome dela
    print(space(20)					+ 'select top 1 idxl.name' )
    print(space(20)					+ 'from sys.indexes idxl' )
    print(space(20)					+ 'where idxl.object_id = @tabela_id ')
    print(space(25)						+ 'and idxl.is_primary_key = idxt.is_primary_key ')
    print(space(25)						+ 'and (idxt.is_primary_key = 1 or idxl.name = idxt.index_name) ')
    print(space(20)					+ 'order by idxl.is_unique_constraint desc, idxl.is_unique ')
    print(space(15)				+ ') nome')
	print(space(10)			+ 'WHERE idxt.index_id > @object_id')
	print(space(10)			+ 'ORDER BY idxt.index_id')
	print(space(5)		+ '')        
	print(space(5)		+ 'if @nm_comando1 is null break')
	print(space(5)		+ '')  -- Se achou indice mas não tem estrutura correta -> apaga       
	print(space(5)		+ 'IF (@index_name_local is not null and isnull(@index_name_local_struct,'''') != @index_name_local)')
	print(space(5)		+ 'BEGIN')  
	print(space(10)			+ 'IF @is_primary_key = 1')  -- Alterando PK 
	print(space(10)			+ 'BEGIN')
	print(space(15)				+ '')        
	print(space(20)					+ 'SET @id_drop = 0')  -- DROP FKS
	print(space(20)					+ '')
	print(space(20)					+ 'WHILE 1 = 1')
	print(space(20)					+ 'BEGIN')
	print(space(25)						+ 'set @nm_cmd_drop = null')
	print(space(25)						+ '')	        
	print(space(25)						+ 'select TOP 1 @id_drop = f.object_id')	        
	print(space(30)							+ ',@nm_cmd_drop = ''ALTER TABLE ['' + OBJECT_SCHEMA_NAME(f.parent_object_id) + ''].['' + object_name(f.parent_object_id) + ''] DROP CONSTRAINT ['' + f.name + '']'' ')	        
	print(space(25)						+ 'from sys.foreign_keys f inner join sys.foreign_key_columns k on f.object_id = k.constraint_object_id ')	        
	print(space(25)						+ 'WHERE ((k.parent_object_id = @tabela_id and k.parent_column_id = @colum_id) or (k.referenced_object_id = @tabela_id and k.referenced_column_id = @colum_id))')	        
	print(space(30)							+ 'and f.object_id > @id_drop')	  
	print(space(25)						+ 'order by f.object_id')
	print(space(25)						+ '')	        
	print(space(25)						+ 'if @nm_cmd_drop is null break')
	print(space(25)						+ 'print(@nm_cmd_drop)')
	print(space(20)					+ 'END')
	print(space(20)					+ '') -- Apaga PK
	print(space(20)					+ 'SET @nm_cmd_drop =  ''ALTER TABLE ' + @tabela_nome_completo + ' DROP CONSTRAINT ['' + @index_name_local + '']'' ');  
	print(space(20)					+ 'exec(@nm_cmd_drop)')
	print(space(20)					+ '')
	print(space(10)			+ 'END')
	print(space(10)			+ 'ELSE')
	print(space(10)			+ 'BEGIN')
	print(space(15)				+ '') -- Apaga indice
	print(space(15)				+ 'SET @nm_cmd_drop =  ''DROP INDEX ['' + @index_name_local + ''] ON ' + @tabela_nome_completo + ''' ');  
	print(space(15)				+ 'exec(@nm_cmd_drop)')
	print(space(15)				+ '')
	print(space(10)			+ 'END')
	print(space(10)			+ '')  -- não tem mais, posso fazer o rename de outro se for o caso!!  
	print(space(10)			+ 'set @index_name_local = null  ')
	print(space(5)		+ 'END')
	print(space(5)		+ '')  -- Se encontrou indice com estrutura certa e não achou com o nome correto -> renomeia
	print(space(5)		+ 'IF @index_name_local_struct is not null and isnull(@index_name_local, '''') != @index_name   ')
	print(space(5)		+ 'BEGIN')  
	print(space(10)			+ 'SET @index_name_local_struct = ''' + @tabela_nome_completo + '.['' + @index_name_local_struct + '']'' ')
	print(space(10)			+ 'PRINT ''sp_rename '' + @index_name_local_struct + '', '' + @index_name + '', INDEX''  ')
	print(space(10)			+ 'EXEC sp_rename @index_name_local_struct, @index_name, ''INDEX''  ')
	print(space(10)			+ 'SET @index_name_local = @index_name  ') -- indice com nome e estrutura corretas
	print(space(5)		+ 'END')
	print(space(5)		+ '')  -- Se não achou nem pelo nome nem pela estrutura -> cria  
	print(space(5)		+ 'IF (@index_name_local is null and @index_name_local_struct is null) ')
	print(space(5)		+ 'BEGIN')  
	print(space(10)			+ 'EXEC(@nm_comando1)')
	print(space(5)		+ 'END')
	print(space(0)	+ 'END')
	print(space(0)	+ '')	
	if @drop_fk_ix = 1 
	begin
		print(space(0)	+ '')	-- Para apagar indices que não existem na base de origem
		print(space(0)	+ 'SET @object_id = 0')
		print(space(0)	+ '')	
		print(space(0)	+ 'WHILE 1 = 1')
		print(space(0)	+ 'BEGIN')
		print(space(5)		+ '')
		print(space(5)		+ 'set @nm_comando1 = null')
		print(space(5)		+ '')        
		print(space(5)		+ '')        
		print(space(5)		+ 'select top 1')	
		print(space(10)			+ '@object_id = idx.index_id,')
		print(space(10)			+ '@nm_comando1 = ''DROP INDEX ['' + idx.name + ''] ON ' + @tabela_nome_completo + '''  ')
		print(space(10)			+ 'from sys.indexes idx') 
		print(space(10)			+ 'WHERE idx.object_id = @tabela_id')
		print(space(10)			+ 'and idx.index_id > @object_id')
		print(space(10)			+ 'and not exists (select 1 from @indices idxs where idxs.index_name = idx.name)')
		print(space(10)			+ 'order by idx.index_id')
		print(space(5)		+ '')        
		print(space(5)		+ 'if @nm_comando1 is null break')
		print(space(5)		+ '')        
		print(space(5)		+ 'EXEC(@nm_comando1)')
		print(space(0)	+ 'END')				
	end
end

/* FK */	
if (select count(*) from #fks) > 0
begin
	print(space(0)	+ '')
	print(space(0)	+ '/* FK */')
	print(space(0)	+ '')
	print(space(0)	+ 'SET @object_id = 0')
	print(space(0)	+ '')	
	print(space(0)	+ 'WHILE 1 = 1')
	print(space(0)	+ 'BEGIN')
	print(space(5)		+ '')
	print(space(5)		+ 'set @nm_comando1 = null')
	print(space(5)		+ '')        
	print(space(5)		+ '')        
	print(space(5)		+ 'select top 1')	
	print(space(10)			+ '@object_id = fori.fk_id,')
	print(space(10)			+ '@nm_comando1	= fori.cmd_ins,')
	print(space(10)         + '@fk_name = fori.fk_name,')
	print(space(10)         + '@fk_name_local = isnull(nome.name, colu.name)')
	print(space(10)			+ 'from @fks fori') 
	print(space(15)				+ 'outer apply (') -- Procura fk na base local com exatamente as mesmas colunas das duas pontas
	print(space(20)					+ 'select top 1 fdst.name') 
	print(space(20)					+ 'from sys.foreign_keys fdst') 
	print(space(20)					+ 'where fdst.parent_object_id = @tabela_id')
	print(space(25)						+ 'and exists (select 1 from @fks_columns fkct where fori.fk_id = fkct.fk_id)')
	print(space(25)						+ 'and not exists (')  
	print(space(30)							+ 'select 1 ')
	print(space(30)							+ 'from @fks_columns fkct')
	print(space(30)							+ 'left join sys.foreign_key_columns fkc')
	print(space(30)							+ 'on col_name(fkc.parent_object_id, fkc.parent_column_id) = fkct.column_name ')
	print(space(30)							+ 'and OBJECT_NAME(fkc.referenced_object_id) = fkct.table_ref')
	print(space(30)							+ 'and col_name(fkc.referenced_object_id, fkc.referenced_column_id) = fkct.column_name_ref')
	print(space(30)							+ 'and fdst.object_id = fkc.constraint_object_id')
	print(space(30)							+ 'where fkct.fk_id = fori.fk_id')
	print(space(30)							+ 'and fkc.referenced_column_id is null')
	print(space(25)						+ ')')
	print(space(15)				+ ') colu') 
	print(space(15)				+ 'outer apply ( ') -- Procura fk na base local com o mesmo nome
    print(space(20)					+ 'select top 1 fdst.name' )
    print(space(20)					+ 'from sys.foreign_keys fdst' )
    print(space(20)					+ 'where fdst.parent_object_id = @tabela_id ')
    print(space(25)						+ 'and fdst.name = fori.fk_name ')
    print(space(15)				+ ') nome')
	print(space(10)			+ 'WHERE fori.fk_id > @object_id')
	print(space(10)			+ 'order by fori.fk_id')
	print(space(5)		+ '')        
	print(space(5)		+ 'if @nm_comando1 is null break')
	print(space(5)		+ '')        
	print(space(5)		+ 'IF @fk_name_local is null')
	print(space(5)		+ 'BEGIN')  
	print(space(10)			+ 'EXEC(@nm_comando1)')
	print(space(5)		+ 'END')
	print(space(5)		+ 'ELSE IF @fk_name_local <> @fk_name')
	print(space(5)		+ 'BEGIN')  
	print(space(10)			+ 'SET @fk_name_local = ''['' + @fk_name_local + '']'' ')
	print(space(10)			+ 'PRINT ''sp_rename '' + @fk_name_local + '', '' + @fk_name + '', OBJECT'' ')
	print(space(10)			+ 'EXEC sp_rename @fk_name_local, @fk_name, ''OBJECT'' ')
	print(space(5)		+ 'END')
	print(space(0)	+ 'END')
	print(space(0)	+ '')	
	if @drop_fk_ix = 1 
	begin
		print(space(0)	+ '')	
		print(space(0)	+ 'SET @object_id = 0')
		print(space(0)	+ '')	
		print(space(0)	+ 'WHILE 1 = 1')
		print(space(0)	+ 'BEGIN')
		print(space(5)		+ '')
		print(space(5)		+ 'set @nm_comando1 = null')
		print(space(5)		+ '')        
		print(space(5)		+ '')        
		print(space(5)		+ 'select top 1')	
		print(space(10)			+ '@object_id = f.object_id,')
		print(space(10)			+ '@nm_comando1 = ''ALTER TABLE ' + @tabela_nome_completo + ' DROP CONSTRAINT ['' + f.name + '']''')
		print(space(10)			+ 'from sys.foreign_keys f') 
		print(space(10)			+ 'WHERE f.parent_object_id = @tabela_id')
		print(space(10)			+ 'and f.object_id > @object_id')
		print(space(10)			+ 'and not exists (select 1 from @fks fks where fks.fk_name = f.name)')
		print(space(10)			+ 'order by f.object_id')
		print(space(5)		+ '')        
		print(space(5)		+ 'if @nm_comando1 is null break')
		print(space(5)		+ '')        
		print(space(5)		+ 'EXEC(@nm_comando1)')
		print(space(0)	+ 'END')				
	end
end

