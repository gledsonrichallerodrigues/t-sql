--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SET NOCOUNT on;

begin try
	create table resultado_v3 (
		campo1 varchar(20) not null
		, tabela1 varchar(50) not null
		, operador varchar(15) not null
		, campo2 varchar(20) not null
		, tabela2 varchar(50) not null
		, qtdeTotalLinhas int not null default(0)
		, qtdeLinhasMatching int not null default(0)
		, id int not null
		, analisada bit not null default(0)
		, erro bit not null default(0)
		, mensagem_erro nvarchar(4000) null
		, tempo_de_execucao bigint not null default(0)
		, converteu_para_varchar bit not null default(0)
	)

	insert into resultado_v3
	select *
		, 0 as qtdeTotalLinhas
		, 0 as qtdeLinhasMatching
		, ROW_NUMBER() OVER(ORDER BY tabela1.coluna ASC) as id
		, 0 as analisada
		, 0 as erro
		, '' as mensagem_erro
		, 0 as tempo_de_execucao
		, 0 as converteu_para_varchar
	from (
			SELECT c.name AS coluna, o.name as tabela
			FROM sys.syscolumns AS c INNER JOIN
				sys.sysobjects AS o ON c.id = o.id
			WHERE (o.name = N'recording_production')
				and c.name not in ('ID', 'tag_id', 'duration', 'direction')
		) as tabela1 cross join
		(
			select 'igual' as operador /* union all
			select 'contém' as operador union all
			select 'está contido em' as operador */
		) as operadores cross join
		(
			SELECT c.name AS coluna, o.name as tabela
			FROM sys.syscolumns AS c INNER JOIN
				sys.sysobjects AS o ON c.id = o.id
			WHERE (o.name = N'client_customerhistory')
				and c.name <> 'id'
		) as tabela2

		-- impedindo de comparar o tipo data com outro tipo diferente
		update resultado_v3 WITH (ROWLOCK)
		set analisada = 1
			, erro = 1
			, mensagem_erro = 'tipos diferentes' 
		where (campo1 in ('start_time', 'local_start_time', 'end_time', 'local_end_time')
			or campo2 in ('datetime', 'data10', 'data11', 'data14'))
			and analisada = 0
			and campo1 not in (
				select a.campo1
				from resultado_v3 a WITH (NOLOCK)
				where a.campo1 in ('start_time', 'local_start_time', 'end_time', 'local_end_time')
					and a.analisada = 0
					and a.campo2 in ('datetime', 'data10', 'data11', 'data14')
					and a.campo2 = resultado_v3.campo2
			)
end try
BEGIN CATCH
	print ERROR_MESSAGE()
END CATCH

declare csAnalise cursor local static READ_ONLY FOR
select *
from resultado_v3 WITH (NOLOCK)
where analisada = 0

open csAnalise

declare @campo1 varchar(20)
	, @tabela1 varchar(50)
	, @operador varchar(15)
	, @campo2 varchar(20)
	, @tabela2 varchar(50)
	, @qtdeTotalLinhas int
	, @qtdeLinhasMatching int
	, @id int
	, @analisada bit
	, @erro bit
	, @mensagem_erro nvarchar(4000)
	, @tempo_de_execucao bigint
	, @inicio datetime
	, @comando varchar(4000)
	, @converteu_para_varchar bit

FETCH FIRST FROM csAnalise   
INTO @campo1
	, @tabela1
	, @operador
	, @campo2
	, @tabela2
	, @qtdeTotalLinhas
	, @qtdeLinhasMatching
	, @id
	, @analisada
	, @erro
	, @mensagem_erro
	, @tempo_de_execucao
	, @converteu_para_varchar

WHILE @@FETCH_STATUS = 0 BEGIN
	print '@id = ' + CAST(@id AS VARCHAR)

	if (@operador = 'igual' ) begin

		select @inicio = GETDATE()

		select @comando = (
		'update resultado_v3 WITH (ROWLOCK)
		set qtdeLinhasMatching = (
			select count(distinct ' + @tabela1 + '.' + @campo1 + ') as qtde
				from ' + @tabela1 + ' WITH (NOLOCK) inner join
				' + @tabela2 + ' WITH (NOLOCK) on ' + @tabela1 + '.' + @campo1 + ' = ' + @tabela2 + '.' + @campo2 + ')
		where id = ' + cast(@id as varchar)
		)

		print @comando

		BEGIN TRY
			exec (@comando)
			print 'sem conversao ok!'
		END TRY  
		BEGIN CATCH
			select @comando = (
			'update resultado_v3 WITH (ROWLOCK)
			set qtdeLinhasMatching = (
				select count(distinct ' + @tabela1 + '.' + @campo1 + ') as qtde
					from ' + @tabela1 + ' WITH (NOLOCK) inner join
					' + @tabela2 + ' WITH (NOLOCK) on RTRIM(LTRIM(CAST(' + @tabela1 + '.' + @campo1 + ' AS VARCHAR))) = RTRIM(LTRIM(CAST(' + @tabela2 + '.' + @campo2 + ' AS VARCHAR))))
			where id = ' + cast(@id as varchar)
			)

			print @comando

			BEGIN TRY
				exec (@comando)
				select @converteu_para_varchar = 1
				print 'converteu para varchar as colunas'
			END TRY
			BEGIN CATCH
				select @erro = 1
					, @mensagem_erro = ERROR_MESSAGE()
				print @mensagem_erro
			END CATCH
		END CATCH

		update resultado_v3 WITH (ROWLOCK)
		set analisada = 1
			, erro = @erro
			, mensagem_erro = @mensagem_erro
			, tempo_de_execucao = DATEDIFF(ss, @inicio, getdate())
			, converteu_para_varchar = @converteu_para_varchar
		where id = @id

		print ''

	end

	FETCH NEXT FROM csAnalise   
	INTO @campo1
		, @tabela1
		, @operador
		, @campo2
		, @tabela2
		, @qtdeTotalLinhas
		, @qtdeLinhasMatching
		, @id
		, @analisada
		, @erro
		, @mensagem_erro
		, @tempo_de_execucao
		, @converteu_para_varchar
END

CLOSE csAnalise;
DEALLOCATE csAnalise;

select *
from resultado_v3 WITH (NOLOCK)
where analisada = 1

/* limpa os lixos da tabela

update resultado_v3
set qtdeLinhasMatching = 0
	, analisada = 0
	, tempo_de_execucao = 0
	, erro = 0
	, mensagem_erro = ''
	, converteu_para_varchar = 0
	
*/

/*
select *
from resultado_v3
where analisada = 1
	and erro = 0
	and qtdeLinhasMatching <> 0
	and campo1 not in ('ID', 'tag_id')
order by qtdeLinhasMatching desc
*/