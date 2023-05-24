-- Day 6

-- Part 1
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

--DECLARE @InputString VARCHAR(8000) = '3,4,3,1,2'
DECLARE @InputString VARCHAR(8000) = '1,1,1,2,1,1,2,1,1,1,5,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,4,1,1,1,1,3,1,1,3,1,1,1,4,1,5,1,3,1,1,1,1,1,5,1,1,1,1,1,5,5,2,5,1,1,2,1,1,1,1,3,4,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,5,4,1,1,1,1,1,5,1,2,4,1,1,1,1,1,3,3,2,1,1,4,1,1,5,5,1,1,1,1,1,2,5,1,4,1,1,1,1,1,1,2,1,1,5,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,3,1,1,3,1,3,1,4,1,5,4,1,1,2,1,1,5,1,1,1,1,1,5,1,1,1,1,1,1,1,1,1,4,1,1,4,1,1,1,1,1,1,1,5,4,1,2,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,4,1,1,1,2,1,4,1,1,1,1,1,1,1,1,1,4,2,1,2,1,1,4,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,3,2,1,4,1,5,1,1,1,4,5,1,1,1,1,1,1,5,1,1,5,1,2,1,1,2,4,1,1,2,1,5,5,3';

INSERT INTO LanternFish (Lifestage)
SELECT value FROM STRING_SPLIT(@InputString, ',')

DECLARE @Day SMALLINT = 0;
WHILE @Day < 80
	BEGIN
		SET @Day += 1;

		UPDATE LanternFish SET Lifestage = Lifestage-1;
	END

SELECT COUNT(*) FROM LanternFish;

TRUNCATE TABLE LanternFish

GO
-- Can't use the same method for part 2. Far too many rows.

DROP TABLE IF EXISTS LanternFish;

CREATE TABLE LanternFish (
	Stage0 BIGINT DEFAULT 0,
	Stage1 BIGINT DEFAULT 0,
	Stage2 BIGINT DEFAULT 0,
	Stage3 BIGINT DEFAULT 0,
	Stage4 BIGINT DEFAULT 0,
	Stage5 BIGINT DEFAULT 0,
	Stage6 BIGINT DEFAULT 0,
	Stage7 BIGINT DEFAULT 0,
	Stage8 BIGINT DEFAULT 0
)
GO

--DECLARE @InputString VARCHAR(8000) = '3,4,3,1,2';
DECLARE @InputString VARCHAR(8000) = '1,1,1,2,1,1,2,1,1,1,5,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,4,1,1,1,1,3,1,1,3,1,1,1,4,1,5,1,3,1,1,1,1,1,5,1,1,1,1,1,5,5,2,5,1,1,2,1,1,1,1,3,4,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,5,4,1,1,1,1,1,5,1,2,4,1,1,1,1,1,3,3,2,1,1,4,1,1,5,5,1,1,1,1,1,2,5,1,4,1,1,1,1,1,1,2,1,1,5,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,3,1,1,3,1,3,1,4,1,5,4,1,1,2,1,1,5,1,1,1,1,1,5,1,1,1,1,1,1,1,1,1,4,1,1,4,1,1,1,1,1,1,1,5,4,1,2,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,4,1,1,1,2,1,4,1,1,1,1,1,1,1,1,1,4,2,1,2,1,1,4,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,3,2,1,4,1,5,1,1,1,4,5,1,1,1,1,1,1,5,1,1,5,1,2,1,1,2,4,1,1,2,1,5,5,3';

WITH InputValues AS (
SELECT value, COUNT(*) AS FishCount
	FROM STRING_SPLIT(@InputString, ',')
	GROUP BY value
)
INSERT INTO LanternFish (Stage1,Stage2,Stage3,Stage4,Stage5)
SELECT ISNULL(pvt.[1],0) AS Stage1,
       ISNULL(pvt.[2],0) AS Stage2,
       ISNULL(pvt.[3],0) AS Stage3,
       ISNULL(pvt.[4],0) AS Stage4,
       ISNULL(pvt.[5],0) AS Stage5
FROM 
	(SELECT value, FishCount FROM InputValues) SourceTbl PIVOT (MAX(Fishcount) FOR value IN ([1],[2],[3],[4],[5])) pvt;

DECLARE @Day SMALLINT = 0;
WHILE @Day < 256
	BEGIN
		SET @Day += 1;

		-- can do this because the DB engine splits the read and update phases, so data is read, then data is changed
		UPDATE LanternFish SET
			Stage0 = Stage1,
			Stage1 = Stage2,
			Stage2 = Stage3,
			Stage3 = Stage4,
			Stage4 = Stage5,
			Stage5 = Stage6,
			Stage6 = Stage0 + Stage7, 
			Stage7 = Stage8,
			Stage8 = Stage0;

	END

SELECT Stage0 + Stage1 + Stage2 + Stage3 + Stage4 + Stage5 + Stage6 + Stage7 + Stage8 FROM dbo.LanternFish;

