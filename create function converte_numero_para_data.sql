-- =============================================
-- Author:		Gledson Richalle Rodrigues
-- Create date: 27/05/2019 20:14
-- Description:	Converte um valor decimal em data no formato americano
-- Parâmetros: numero = número decimal que será convertido
-- Retorno: Retorna um datetime com a data que foi convertida de número para datetime
-- =============================================
CREATE FUNCTION converte_numero_para_data (
	@numero varchar(16)
)
RETURNS datetime 
AS
BEGIN
	declare @dias int
		, @posicaoVirgula tinyint
		, @segundos int
		, @data datetime
		, @fracaoDoDia varchar(10)

	select @posicaoVirgula = CHARINDEX(',', @numero)
	--print '@posicaoVirgula = ' + cast(@posicaoVirgula as varchar)

	-- testando o número está pelo menos no formato 9,9, para evitar de erro no cálculo
	if (len(@numero) >= 3 and @posicaoVirgula > 0) begin
		select @dias = LEFT(@numero, @posicaoVirgula - 1)
		--print '@dias = ' + cast(@dias as varchar)

		select @fracaoDoDia = SUBSTRING(@numero, @posicaoVirgula + 1, LEN(@numero) - @posicaoVirgula)
		--print '@fracaoDoDia = ' + cast(@fracaoDoDia as varchar)

		select @segundos = 86400 * cast('0.' + @fracaoDoDia as real)
		--print '@minutos = ' + cast(@segundos as varchar)

		select @data = '01/01/1900  00:00:00'
		--print '@data = ' + cast(@data as varchar)

		select @data = DATEADD(dd, @dias - 2, @data)
		--print '@data = ' + cast(@data as varchar)

		select @data = DATEADD(ss, @segundos, @data)
		--print '@data = ' + cast(@data as varchar)
	end
	RETURN @data
END

