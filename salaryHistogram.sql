/* ============================================================
   Questão 01
   Procedimento: salaryHistogram

   Objetivo:
   Distribuir as frequências dos salários dos professores
   em intervalos, formando um histograma.

   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.salaryHistogram
    @quantidadeIntervalos INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declaração das variáveis que serão usadas no cálculo
    DECLARE @salarioMinimo NUMERIC(12, 2);
    DECLARE @salarioMaximo NUMERIC(12, 2);
    DECLARE @tamanhoIntervalo NUMERIC(12, 2);

    -- Busca o menor e o maior salário da tabela instructor
    SELECT
        @salarioMinimo = MIN(salary),
        @salarioMaximo = MAX(salary)
    FROM instructor;

    -- Calcula o tamanho de cada intervalo do histograma
    SET @tamanhoIntervalo = CEILING((@salarioMaximo - @salarioMinimo + 1) / @quantidadeIntervalos);

    -- Cria os intervalos e conta quantos professores estão em cada faixa salarial
    ;WITH intervalos AS
    (
        SELECT
            1 AS numeroIntervalo,
            @salarioMinimo AS valorMinimo,
            @salarioMinimo + @tamanhoIntervalo - 1 AS valorMaximo

        UNION ALL

        SELECT
            numeroIntervalo + 1,
            valorMaximo + 1,
            valorMaximo + @tamanhoIntervalo
        FROM intervalos
        WHERE numeroIntervalo < @quantidadeIntervalos
    )

    SELECT
        CAST(valorMinimo AS INT) AS valorMinimo,
        CAST(
            CASE 
                WHEN numeroIntervalo = @quantidadeIntervalos THEN @salarioMaximo
                ELSE valorMaximo
            END AS INT
        ) AS valorMaximo,
        COUNT(i.ID) AS total
    FROM intervalos
    LEFT JOIN instructor i
        ON i.salary >= valorMinimo
       AND i.salary <= CASE 
                           WHEN numeroIntervalo = @quantidadeIntervalos THEN @salarioMaximo
                           ELSE valorMaximo
                       END
    GROUP BY
        numeroIntervalo,
        valorMinimo,
        valorMaximo
    ORDER BY
        valorMinimo;
END;


/* ============================================================
   Teste do procedimento
   ============================================================ */

EXEC dbo.salaryHistogram 5;
