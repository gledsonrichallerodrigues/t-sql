use DB_PRD_INFINITY;

declare @d_menos_1_texto_formato_brasil varchar(10)
	, @d_menos_1_texto_formato_americano varchar(10)
	, @id_indicador int

select @d_menos_1_texto_formato_brasil = convert(varchar, cast(getdate() - 1 as date), 103) -- 06/07/2019
	, @d_menos_1_texto_formato_americano = cast(getdate() - 1 as date) -- 2019-07-06
	, @id_indicador = (select isnull(max(id), 0) from dashboard)

select @id_indicador

/***************************************************************** relatório 1, 'Tudo que está na recording_tagging está na recording_production?' ********************************************************************/

set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - Tudo que está na recording_tagging está na recording_production?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
	-- o que sai de tagging está chegando em production?
	select count(*) as qtde
	from recording_tagging t with (nolock)
	where t.id not in (
			select p.ID
			from recording_production p with (nolock)
		)
		and extension in (
			select Ramal from ramais_inb_fixa_sjc with (nolock) union all
			select Ramal from ramais_inb_mov_sbc with (nolock) union all
			select Ramal from ramais_inb_mov_sjc with (nolock)
		)
		and cast(local_end_time as date) = cast(getdate() - 1 as date)
)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = '	
	select *
	from recording_tagging t with (nolock)
	where t.id not in (
			select p.ID
			from recording_production p with (nolock)
		)
		and extension in (
			select Ramal from ramais_inb_fixa_sjc with (nolock) union all
			select Ramal from ramais_inb_mov_sbc with (nolock) union all
			select Ramal from ramais_inb_mov_sjc with (nolock)
		)
		and cast(local_end_time as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
	'
where id = @id_indicador


/************************************** relatório 2, 'Toda lista de ramais (OP00001) está na tabela client_customer_inboundmovel?' ****************************************/
set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - Toda lista de ramais (OP00001) está na tabela client_customer_inboundmovel?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
	SELECT count(distinct data02) as qtde
	FROM client_customer_inboundmovel a with (nolock)
	where data02 not in (
			select Ramal from ramais_inb_mov_sbc with (nolock) union all
			select Ramal from ramais_inb_mov_sjc with (nolock)
		)
		and cast(datetime as date) = cast(getdate() - 1 as date)
)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = '
	SELECT distinct data02
	FROM client_customer_inboundmovel a with (nolock)
	where data02 not in (
			select Ramal from ramais_inb_mov_sbc with (nolock) union all
			select Ramal from ramais_inb_mov_sjc with (nolock)
		)
		and cast(datetime as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
	'
where id = @id_indicador


/************************************** relatório 3, 'Toda lista de ramais (OP00004) está na tabela client_customer_inboundfixa?' ****************************************/
set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - Toda lista de ramais (OP00004) está na tabela client_customer_inboundfixa?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
	SELECT count(distinct data02) as qtde
	FROM client_customer_inboundfixa a with (nolock)
	where data02 not in (
			select Ramal from ramais_inb_fixa_sjc with (nolock)
		)
		and cast(datetime as date) = cast(getdate() - 1 as date)
)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = '	
	SELECT distinct data02
	FROM client_customer_inboundfixa a with (nolock)
	where data02 not in (
			select Ramal from ramais_inb_fixa_sjc with (nolock)
		)
		and cast(datetime as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
	'
where id = @id_indicador


/************************************** relatório 4, 'Toda lista de ramais (OP00001) está na tabela recording_tagging?' ****************************************/
set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - Toda lista de ramais (OP00001) está na tabela recording_tagging?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
	SELECT count(distinct ramal) as qtde
	FROM (
		SELECT ramal FROM ramais_inb_mov_sbc with (nolock) union all
		SELECT ramal FROM ramais_inb_mov_sjc with (nolock)
	) r
	where ramal NOT IN (
			SELECT extension
			FROM recording_tagging t with (nolock)
		)
)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = '
	SELECT distinct ramal
	FROM (
		SELECT ramal FROM ramais_inb_mov_sbc with (nolock) union all
		SELECT ramal FROM ramais_inb_mov_sjc with (nolock)
	) r
	where ramal NOT IN (
		SELECT extension
		FROM recording_tagging t with (nolock)
	)
		'
where id = @id_indicador


/************************************** relatório 5, 'Toda lista de ramais (OP00004) está na tabela recording_tagging?' ****************************************/
set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - Toda lista de ramais (OP00004) está na tabela recording_tagging?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
	SELECT count(distinct ramal) as qtde
	FROM ramais_inb_fixa_sjc r with (nolock)
	where ramal NOT IN (
		SELECT extension
		FROM recording_tagging t with (nolock)	
	)
)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = '
	SELECT distinct ramal
	FROM ramais_inb_fixa_sjc r with (nolock)
	where ramal NOT IN (
		SELECT extension
		FROM recording_tagging t with (nolock)	
	)
		'
where id = @id_indicador


/************************************** relatório 6, 'Tudo que está na client_customer_inboundmovel (OP00001) está na client_customerhistory?' ****************************************/
set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - Tudo que está na client_customer_inboundmovel (OP00001) está na client_customerhistory?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
	select isnull(sum(subtotal), 0)
	from (
			select qtde - (
					select count(*)
					from client_customerhistory with (nolock)
					where data04 = 'OP00001'
						and convert(varchar, datetime, 103) = t.data
				) as subtotal
			from (
				select convert(varchar, datetime, 103) as data
					, count(*) as qtde -- OP00001
				from client_customer_inboundmovel with (nolock)
				where data04 = 'OP00001'
					and cast(datetime as date) = cast(getdate() - 1 as date)
				group by convert(varchar, datetime, 103)
			) as t
			where t.data not in (
					select convert(varchar, datetime, 103)
					from client_customerhistory with (nolock)
					where data04 = 'OP00001'
						and cast(datetime as date) = cast(getdate() - 1 as date)
				)
				or t.qtde <> (
					select count(*)
					from client_customerhistory with (nolock)
					where data04 = 'OP00001'
						and convert(varchar, datetime, 103) = t.data
					group by convert(varchar, datetime, 103)		
				)
		) as u
)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = '
	select data as data_inboundmovel
		, qtde as qtde_inboundmovel
		, (
			select count(*)
			from client_customerhistory with (nolock)
			where data04 = ''OP00001''
				and convert(varchar, datetime, 103) = t.data
		) as qtde_customerhistory
	from (
		select convert(varchar, datetime, 103) as data
			, count(*) as qtde -- OP00001
		from client_customer_inboundmovel with (nolock)
		where data04 = ''OP00001''
			and cast(datetime as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
		group by convert(varchar, datetime, 103)
		-- order by convert(varchar, datetime, 103)
	) as t
	where t.data not in (
			select convert(varchar, datetime, 103)
			from client_customerhistory with (nolock)
			where data04 = ''OP00001''
				and cast(datetime as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
		)
		or t.qtde <> (
			select count(*)
			from client_customerhistory with (nolock)
			where data04 = ''OP00001''
				and convert(varchar, datetime, 103) = t.data
			group by convert(varchar, datetime, 103)		
		)
	'
where id = @id_indicador


/************************************** relatório 7, 'Tudo que está na client_customer_inboundfixa (OP00004) está na client_customerhistory?' ****************************************/
set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - Tudo que está na client_customer_inboundfixa (OP00004) está na client_customerhistory?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
	select isnull(sum(subtotal), 0)
	from (
			select qtde - (
					select count(*)
					from client_customerhistory with (nolock)
					where data04 = 'OP00004'
						and convert(varchar, datetime, 103) = t.data
				) as subtotal
			from (
				select convert(varchar, datetime, 103) as data
					, count(*) as qtde
				from client_customer_inboundfixa with (nolock)
				where data04 = 'OP00004'
					and cast(datetime as date) = cast(getdate() - 1 as date)
				group by convert(varchar, datetime, 103)
			) as t
			where t.data not in (
					select convert(varchar, datetime, 103)
					from client_customerhistory with (nolock)
					where data04 = 'OP00004'
						and cast(datetime as date) = cast(getdate() - 1 as date)
				)
				or t.qtde <> (
					select count(*)
					from client_customerhistory with (nolock)
					where data04 = 'OP00004'
						and convert(varchar, datetime, 103) = t.data
					group by convert(varchar, datetime, 103)		
				)
		) as u
)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = '
	select data as data_inboundfixa
		, qtde as qtde_inboundfixa
		, (
			select count(*)
			from client_customerhistory with (nolock)
			where data04 = ''OP00004''
				and convert(varchar, datetime, 103) = t.data
		) as qtde_customerhistory
	from (
		select convert(varchar, datetime, 103) as data
			, count(*) as qtde
		from client_customer_inboundfixa with (nolock)
		where data04 = ''OP00004''
			and cast(datetime as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
		group by convert(varchar, datetime, 103)
	) as t
	where t.data not in (
			select convert(varchar, datetime, 103)
			from client_customerhistory with (nolock)
			where data04 = ''OP00004''
				and cast(datetime as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
		)
		or t.qtde <> (
			select count(*)
			from client_customerhistory with (nolock)
			where data04 = ''OP00004''
				and convert(varchar, datetime, 103) = t.data
			group by convert(varchar, datetime, 103)		
		)
	'
where id = @id_indicador


/************************************** relatório 8, 'Todo o Matching (OP00001 e OP00004) foi inserido na tabela recording_matching?' ****************************************/
set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - Todo o Matching (OP00001 e OP00004) foi inserido na tabela recording_matching?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
	SELECT count(ID) as qtde
	FROM recording_production p with (nolock)
	where tag_id is not null
		and ID not in (
			SELECT IDRecording
			FROM recording_matching
			where cast(datetime as date) = cast(getdate() - 1 as date)
		)
		and cast(local_end_time as date) = cast(getdate() - 1 as date)
)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = '
	SELECT ID
	FROM recording_production p with (nolock)
	where tag_id is not null
		and ID not in (
			SELECT IDRecording
			FROM recording_matching
			where cast(datetime as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
		)
		and cast(local_end_time as date) = cast(''' + @d_menos_1_texto_formato_americano + ''' as date)
	'
where id = @id_indicador


/************************************** relatório 9 - A quantidade de interações na CH (OP00001) está na média com relação a RT? ****************************************/

begin try
	drop table #tabela
end try
begin catch
end catch

create table #tabela (
	data varchar(10)
	, qtde_CH int default(0)
	, qtde_RT int default(0)
	, CH_representa_em_RT decimal (5,2) default(0)
)

insert into #tabela (data, qtde_CH)
select left(data11, 10)
	, count(*) as qtde
FROM client_customerhistory a with (nolock)
where data02 in (
		select Ramal from ramais_inb_mov_sbc with (nolock) union all
		select Ramal from ramais_inb_mov_sjc with (nolock)
	)
	and cast(datetime as date) = cast(getdate() - 1 as date)
group by left(data11, 10)
order by left(data11, 10)

insert into #tabela (data, qtde_RT)
select data, qtde
from (
		select convert(varchar, local_end_time, 23) as data
			, count(*) as qtde
		from recording_tagging t with (nolock)
		where extension in (
				select Ramal from ramais_inb_mov_sbc with (nolock) union all
				select Ramal from ramais_inb_mov_sjc with (nolock)
			)
			and cast(local_end_time as date) = cast(getdate() - 1 as date)
		group by convert(varchar, local_end_time, 23)
	) as t
where t.data not in (
		select u.data
		from #tabela u
	)

update #tabela
set qtde_RT = (
		select count(*) as qtde
		from recording_tagging t with (nolock)
		where extension in (
				select Ramal from ramais_inb_mov_sbc with (nolock) union all
				select Ramal from ramais_inb_mov_sjc with (nolock)
			)
			and convert(varchar, local_end_time, 23) = data
	)
where qtde_RT = 0

update #tabela
set CH_representa_em_RT = round(cast(qtde_CH as real) / cast(qtde_RT as real) * 100, 2)

set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - A quantidade de interações na CH (OP00001) está na média com relação a RT?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
		select count(*)
		from #tabela t
		where CH_representa_em_RT < 50
			or CH_representa_em_RT > 80
	)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = (
		select COALESCE(
				(SELECT registro + iif(id=(select count(*) from #tabela where CH_representa_em_RT < 50 or CH_representa_em_RT > 80),'', ' union ') AS [text()]
				 FROM (
				select 'select ''' + data + ''' as data, ' 
					 + cast(qtde_CH as varchar) + ' as qtde_CH, ' 
					+ cast(qtde_RT as varchar) + ' as qtde_RT, ' 
					+ cast(CH_representa_em_RT as varchar) + ' as CH_representa_em_RT' as registro
					, id
				from (
						select top 100 percent *
							, row_number() over (order by data) as id
						from #tabela t
						where CH_representa_em_RT < 50
							or CH_representa_em_RT > 80
						order by data
					) as t
			) as u
				 FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), '') AS retorno
	)
where id = @id_indicador


/************************************** relatório 10 - A quantidade de interações na CH (OP00004) está na média com relação a RT? ****************************************/

delete from #tabela

insert into #tabela (data, qtde_CH)
select left(data11, 10)
	, count(*) as qtde
FROM client_customerhistory a with (nolock)
where data02 in (
		select Ramal from ramais_inb_fixa_sjc with (nolock) 
	)
	and cast(datetime as date) = cast(getdate() - 1 as date)
group by left(data11, 10)
order by left(data11, 10)

insert into #tabela (data, qtde_RT)
select data, qtde
from (
		select convert(varchar, local_end_time, 23) as data
			, count(*) as qtde
		from recording_tagging t with (nolock)
		where extension in (
				select Ramal from ramais_inb_fixa_sjc with (nolock)
			)
			and cast(local_end_time as date) = cast(getdate() - 1 as date)
		group by convert(varchar, local_end_time, 23)
	) as t
where t.data not in (
		select u.data
		from #tabela u
	)

update #tabela
set qtde_RT = (
		select count(*) as qtde
		from recording_tagging t with (nolock)
		where extension in (
				select Ramal from ramais_inb_fixa_sjc with (nolock)
			)
			and convert(varchar, local_end_time, 23) = data
	)
where qtde_RT = 0

update #tabela
set CH_representa_em_RT = round(cast(qtde_CH as real) / cast(qtde_RT as real) * 100, 2)

set @id_indicador = @id_indicador + 1

insert into dashboard (id, relatorio)
values (@id_indicador, @d_menos_1_texto_formato_brasil + ' - A quantidade de interações na CH (OP00004) está na média com relação a RT?')

update dashboard with (ROWLOCK)
set qtdeFaltante = (
		select count(*)
		from #tabela t
		where CH_representa_em_RT < 50
			or CH_representa_em_RT > 80
	)
where id = @id_indicador

update dashboard with (ROWLOCK)
set resposta = iif(qtdeFaltante > 0, 'Não', 'Sim')
	, queryQueRetornaOsProblemas = (
		select COALESCE(
				(SELECT registro + iif(id=(select count(*) from #tabela where CH_representa_em_RT < 50 or CH_representa_em_RT > 80),'', ' union ') AS [text()]
				 FROM (
				select 'select ''' + data + ''' as data, ' 
					 + cast(qtde_CH as varchar) + ' as qtde_CH, ' 
					+ cast(qtde_RT as varchar) + ' as qtde_RT, ' 
					+ cast(CH_representa_em_RT as varchar) + ' as CH_representa_em_RT' as registro
					, id
				from (
						select top 100 percent *
							, row_number() over (order by data) as id
						from #tabela t
						where CH_representa_em_RT < 50
							or CH_representa_em_RT > 80
						order by data
					) as t
			) as u
				 FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), '') AS retorno
	)
where id = @id_indicador

select * from dashboard d