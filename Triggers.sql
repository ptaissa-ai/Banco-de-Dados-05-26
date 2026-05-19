/* 
   QUESTÃO 01
   Trigger: dbo.lost_credits

   Objetivo:
   Diminuir os créditos totais do aluno quando um curso
   for removido da sua lista.
 */

CREATE TRIGGER dbo.lost_credits
ON dbo.takes
AFTER DELETE
AS
BEGIN
    -- Evita mensagens extras do SQL Server
    SET NOCOUNT ON;

    -- Atualiza os créditos totais do aluno
    UPDATE s
    SET s.tot_cred = s.tot_cred - c.credits
    FROM dbo.student AS s

    -- Pega o aluno e o curso que foram removidos
    INNER JOIN deleted AS d
        ON s.ID = d.ID

    -- Busca a quantidade de créditos do curso removido
    INNER JOIN dbo.course AS c
        ON c.course_id = d.course_id;
END;
GO