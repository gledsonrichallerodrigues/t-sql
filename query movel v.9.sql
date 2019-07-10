--UPDATE recording_production SET tag_id = c.id
select count(*) as qtde
FROM recording_production (NOLOCK) r
INNER JOIN client_customerhistory (NOLOCK) c
ON(
	(
		RTRIM(r.ani) = RTRIM(c.phone)

		---- ani = data17 -- 05-13 = 0 registros
		---- 10 dígitos sendo dd + fixo
        or (case when len(rtrim(r.ani)) = 10 and left(RIGHT(rtrim(r.ani), 9), 1) <> '9' then right(rtrim(r.ani), 10) else null end) = (case when ISNUMERIC(rtrim(c.data17)) = 1 and len(rtrim(c.data17)) = 10 and left(RIGHT(rtrim(c.data17), 9), 1) <> '9' then right(rtrim(c.data17), 10) else null end)

		---- 11 dígitos sendo dd + movel
		or (case when len(rtrim(r.ani)) = 11 and left(RIGHT(rtrim(r.ani), 9), 1) = '9' then right(rtrim(r.ani), 11) else null end) = (case when ISNUMERIC(rtrim(c.data17)) = 1 and len(rtrim(c.data17)) = 11 and left(RIGHT(rtrim(c.data17), 9), 1) = '9' then right(rtrim(c.data17), 11) else null end)

		---- 12 dígitos sendo 0 + dd + movel
		or (case when len(rtrim(r.ani)) = 12 and left(RIGHT(rtrim(r.ani), 9), 1) = '9' then right(rtrim(r.ani), 11) else null end) = (case when ISNUMERIC(rtrim(c.data17)) = 1 and len(rtrim(c.data17)) = 11 and left(RIGHT(rtrim(c.data17), 9), 1) = '9' then right(rtrim(c.data17), 11) else null end)
		
		---- 13 dígitos sendo 0 + operadora + dd + fixo
		or (case when len(rtrim(r.ani)) = 13 and left(RIGHT(rtrim(r.ani), 9), 1) <> '9' then right(rtrim(r.ani), 10) else null end) = (case when ISNUMERIC(rtrim(c.data17)) = 1 and len(rtrim(c.data17)) = 10 and left(RIGHT(rtrim(c.data17), 9), 1) <> '9' then right(rtrim(c.data17), 10) else null end)

		---- 14 dígitos sendo 0 + operadora + dd + móvel
		or (case when len(rtrim(r.ani)) = 14 and left(RIGHT(rtrim(r.ani), 9), 1) = '9' then right(rtrim(r.ani), 11) else null end) = (case when ISNUMERIC(rtrim(c.data17)) = 1 and len(rtrim(c.data17)) = 11 and left(RIGHT(rtrim(c.data17), 9), 1) = '9' then right(rtrim(c.data17), 11) else null end)

		or RTRIM(r.ani) = RTRIM(LTRIM(REPLACE(replace(REPLACE(c.data08, '(', ''), ')', ''), '-', '')))

		---- r.dnis_code = c.phone
		----case len igual a 11 retirar o zero do início, quando for outbound, direction = 2, fixo
		or (case when ISNUMERIC(RTRIM(LTRIM(r.dnis_code))) = 1 and len(RTRIM(LTRIM(r.dnis_code))) = 11 then right(RTRIM(LTRIM(r.dnis_code)), 10) else null end) = (case when len(RTRIM(c.phone)) = 10 and LEFT(RTRIM(c.phone), 2) > 10 then RTRIM(c.phone) else null end)
		----case len igual a 14 e NAO tiver B1 dentro do dnis_code então retirar os 3 primeiros digitos do número e igualar a chave correspondente, quando for outbound, direction = 2
		or (case when ISNUMERIC(RTRIM(LTRIM(r.dnis_code))) = 1 and len(RTRIM(LTRIM(r.dnis_code))) = 14 then (case when right(r.dnis_code, 2) = 'B1' then SUBSTRING(RTRIM(LTRIM(r.dnis_code)), 2, 11) else SUBSTRING(RTRIM(LTRIM(r.dnis_code)), 4, 11) end) else null end) = (case when len(rtrim(c.phone)) = 11 and left(RIGHT(rtrim(c.phone), 9), 1) = '9' then rtrim(c.phone) else null end) 
		----case len igual a 15 e tiver B dentro do dnis_code então retirar o zero do início e o B do final e igualar a chave correspondente, quando for outbound, direction = 2
		or (case when ISNUMERIC(RTRIM(LTRIM(r.dnis_code))) = 1 and len(RTRIM(LTRIM(CAST (r.dnis_code AS VARCHAR)))) = 15 and right(r.dnis_code, 1) = 'B' then SUBSTRING(RTRIM(LTRIM(CAST (r.dnis_code AS VARCHAR))), 4, 11) else null end) = (case when len(rtrim(c.phone)) = 11 and left(RIGHT(rtrim(c.phone), 9), 1) = '9' then rtrim(c.phone) else null end)

	)
	AND r.extension =  c.data02

	and local_start_time between dateadd(mi, -70, (case when charindex('/', data10) > 0 then convert(datetime, data10, 103) else (case when charindex(',', data10) > 0 then dbo.converte_numero_para_data (data10) else cast(data10 as datetime) end) end)) and 
							      dateadd(mi, 70, (case when charindex('/', data10) > 0 then convert(datetime, data10, 103) else (case when charindex(',', data10) > 0 then dbo.converte_numero_para_data (data10) else cast(data10 as datetime) end) end))
	and local_end_time between   dateadd(mi, -70, (case when charindex('/', data11) > 0 then convert(datetime, data11, 103) else cast(data11 as datetime) end)) and 
	                              dateadd(mi, 70, (case when charindex('/', data11) > 0 then convert(datetime, data11, 103) else cast(data11 as datetime) end))
)
WHERE CAST(local_end_time AS DATE) = CAST('2019-05-24' AS DATE) -- and CAST('2019-05-24' AS DATE)
AND extension IN (
	SELECT DISTINCT ramal FROM ramais_inb_mov_sbc with (nolock) union all
	SELECT DISTINCT ramal FROM ramais_inb_mov_sjc with (nolock)
)
AND description = 'OP00001'
AND duration > 10
and direction <> 3