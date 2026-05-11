/* ============================================================
   Questão 01
   Procedimento: salaryHistogram

   Objetivo:
   Distribuir as frequências dos salários dos professores
   em intervalos, formando um histograma.
   ============================================================ */

IF OBJECT_ID('dbo.salaryHistogram', 'P') IS NOT NULL
    DROP PROCEDURE dbo.salaryHistogram;

CREATE PROCEDURE dbo.salaryHistogram
    @quantidadeIntervalos INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declaração das variáveis usadas no cálculo
    DECLARE @salarioMinimo NUMERIC(12, 2);
    DECLARE @salarioMaximo NUMERIC(12, 2);
    DECLARE @tamanhoIntervalo NUMERIC(12, 2);

    -- Busca o menor e o maior salário da tabela instructor
    SELECT
        @salarioMinimo = MIN(salary),
        @salarioMaximo = MAX(salary)
    FROM instructor;

    -- Calcula o tamanho de cada intervalo
    SET @tamanhoIntervalo = CEILING((@salarioMaximo - @salarioMinimo + 1) / @quantidadeIntervalos);

    -- Cria uma tabela temporária para armazenar os intervalos
    CREATE TABLE #intervalos
    (
        numeroIntervalo INT,
        valorMinimo NUMERIC(12, 2),
        valorMaximo NUMERIC(12, 2)
    );

    -- Variáveis auxiliares para montar os intervalos
    DECLARE @contador INT = 1;
    DECLARE @inicio NUMERIC(12, 2);
    DECLARE @fim NUMERIC(12, 2);

    SET @inicio = @salarioMinimo;

    -- Monta os intervalos do histograma
    WHILE @contador <= @quantidadeIntervalos
    BEGIN
        IF @contador = @quantidadeIntervalos
            SET @fim = @salarioMaximo;
        ELSE
            SET @fim = @inicio + @tamanhoIntervalo - 1;

        INSERT INTO #intervalos
        (
            numeroIntervalo,
            valorMinimo,
            valorMaximo
        )
        VALUES
        (
            @contador,
            @inicio,
            @fim
        );

        SET @inicio = @fim + 1;
        SET @contador = @contador + 1;
    END;

    -- Conta quantos professores estão em cada faixa salarial
    SELECT
        CAST(i.valorMinimo AS INT) AS valorMinimo,
        CAST(i.valorMaximo AS INT) AS valorMaximo,
        COUNT(inst.ID) AS total
    FROM #intervalos i
    LEFT JOIN instructor inst
        ON inst.salary >= i.valorMinimo
       AND inst.salary <= i.valorMaximo
    GROUP BY
        i.numeroIntervalo,
        i.valorMinimo,
        i.valorMaximo
    ORDER BY
        i.numeroIntervalo;
END;


/* ============================================================
   Teste do procedimento
   ============================================================ */

EXEC dbo.salaryHistogram 5;
