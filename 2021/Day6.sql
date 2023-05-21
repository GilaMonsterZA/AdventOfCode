-- Day 6

-- 3,4,3,1,2

DROP TABLE IF EXISTS LanternFish;

CREATE TABLE LanternFish (
	FishID INT IDENTITY PRIMARY KEY,
	Lifestage SMALLINT
)
GO

CREATE TRIGGER LanternFish_update 
	ON LanternFish
	AFTER UPDATE
AS
	BEGIN
		INSERT INTO LanternFish (Lifestage)
		SELECT 8 FROM inserted i WHERE i.Lifestage = -1;

		UPDATE LanternFish
			SET Lifestage = 6 
			WHERE FishID IN (SELECT FishID from inserted i where i.Lifestage = -1);
	END;
GO

INSERT INTO LanternFish (Lifestage)
VALUES (3), (4), (3), (1), (2);
GO

DECLARE @Day SMALLINT = 0;
WHILE @Day < 80
	BEGIN
		SET @Day += 1;

		UPDATE LanternFish SET Lifestage = Lifestage-1;
	END

SELECT * FROM LanternFish

SELECT COUNT(*) FROM LanternFish;

TRUNCATE TABLE LanternFish