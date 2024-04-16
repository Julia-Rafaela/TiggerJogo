USE master
CREATE DATABASE ex_trigger_jogo
GO
USE ex_trigger_jogo
GO
CREATE TABLE Times (
CodTime INT		      NOT NULL,
NomeTime VARCHAR(50)  NOT NULL
PRIMARY KEY(CodTime)
)
GO
CREATE TABLE Jogos (
    CodTimeA INT,
    CodTimeB INT,
    SetTimeA INT,
    SetTimeB INT,
    FOREIGN KEY (CodTimeA) REFERENCES Times(CodTime),
    FOREIGN KEY (CodTimeB) REFERENCES Times(CodTime)
)

CREATE FUNCTION calcularEstatisticasTime(@codTime INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        t.NomeTime AS 'Nome Time',
        SUM(CASE WHEN j.CodTimeA = @codTime THEN 
                    CASE WHEN j.SetTimeA > j.SetTimeB THEN 2 
                         WHEN j.SetTimeA < j.SetTimeB THEN 1
                         ELSE 0 END
                 WHEN j.CodTimeB = @codTime THEN 
                    CASE WHEN j.SetTimeB > j.SetTimeA THEN 2 
                         WHEN j.SetTimeB < j.SetTimeA THEN 1
                         ELSE 0 END 
                 ELSE 0 END) AS 'Total Pontos',
        SUM(CASE WHEN j.CodTimeA = @codTime THEN j.SetTimeA 
                 WHEN j.CodTimeB = @codTime THEN j.SetTimeB 
                 ELSE 0 END) AS 'Total Sets Ganhos',
        SUM(CASE WHEN j.CodTimeA = @codTime THEN j.SetTimeB 
                 WHEN j.CodTimeB = @codTime THEN j.SetTimeA 
                 ELSE 0 END) AS 'Total Sets Perdidos',
        SUM(CASE WHEN j.CodTimeA = @codTime THEN j.SetTimeA - j.SetTimeB
                 WHEN j.CodTimeB = @codTime THEN j.SetTimeB - j.SetTimeA
                 ELSE 0 END) AS 'Set Average (Ganhos - Perdidos)'
    FROM Jogos j
    INNER JOIN Times t ON j.CodTimeA = t.CodTime OR j.CodTimeB = t.CodTime
    WHERE j.CodTimeA = @codTime OR j.CodTimeB = @codTime
    GROUP BY t.NomeTime
)

SELECT * FROM calcularEstatisticasTime(1);

CREATE TRIGGER VerificarSetsInsert ON Jogos
AFTER INSERT
AS
BEGIN
    DECLARE @MaxSets INT;
    DECLARE @Vencedor INT;
    SELECT @MaxSets = COUNT(*) FROM inserted WHERE CodTimeA IS NOT NULL;
    IF @MaxSets > 5
    BEGIN
        THROW 50000, 'Máximo de 5 sets permitidos.', 1;
        ROLLBACK TRANSACTION;
    END;
    SELECT @Vencedor = CASE WHEN i.SetTimeA > i.SetTimeB THEN i.CodTimeA
                             WHEN i.SetTimeB > i.SetTimeA THEN i.CodTimeB
                             ELSE NULL END
    FROM inserted i;
    IF @Vencedor IS NOT NULL
    BEGIN
        DECLARE @TotalSetsVencedor INT;
        SELECT @TotalSetsVencedor = COUNT(*) 
        FROM inserted 
        WHERE CodTimeA = @Vencedor OR CodTimeB = @Vencedor;
        IF @TotalSetsVencedor > 3
        BEGIN
            THROW 50000, 'O vencedor não pode ter mais de 3 sets.', 1;
            ROLLBACK TRANSACTION;
        END;
    END;
END;

INSERT INTO Times (CodTime, NomeTime) VALUES
(1, 'Time 1'),
(2, 'Time 2'),
(3, 'Time 3'),
(4, 'Time 4')
INSERT INTO Jogos (CodTimeA, CodTimeB, SetTimeA, SetTimeB) VALUES
(1, 2, 3, 2), -- Time 1 vs Time 2 (Time 1 venceu por 3 sets a 2)
(2, 3, 3, 0), -- Time 2 vs Time 3 (Time 2 venceu por 3 sets a 0)
(3, 4, 2, 3), -- Time 3 vs Time 4 (Time 4 venceu por 3 sets a 2)
(1, 3, 1, 3); -- Time 1 vs Time 3 (Time 3 venceu por 3 sets a 1)

-- Tentar inserir um jogo com mais de 5 sets
INSERT INTO Jogos (CodTimeA, CodTimeB, SetTimeA, SetTimeB) VALUES (1, 2, 3, 2), (2, 1, 3, 2), (1, 2, 3, 2), (2, 1, 3, 2), (1, 2, 3, 2), (2, 1, 3, 2);

-- Tentar inserir um jogo onde o vencedor tem mais de 3 sets
INSERT INTO Jogos (CodTimeA, CodTimeB, SetTimeA, SetTimeB) VALUES (1, 2, 3, 2), (2, 1, 3, 2), (1, 2, 3, 2), (2, 1, 3, 2), (2, 1, 3, 0);