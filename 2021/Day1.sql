CREATE DATABASE AoC21
GO

USE AoC21


CREATE TABLE TestDepths (
	DepthID INT IDENTITY,
	DepthReading INT
);

INSERT INTO dbo.TestDepths (DepthReading)
VALUES (199),(200),(208),(210),(200),(207),(240),(269),(260),(263)

CREATE TABLE Depths (
	DepthID INT,
	DepthReading INT
);


-- inserted from Excel, with sequential column added

-- Part 1

WITH DepthChecks AS (
	SELECT DepthReading, LAG(DepthReading) OVER (ORDER BY DepthID) AS PreviousDepthReading
	FROM dbo.Depths
)
SELECT COUNT(*) 
	FROM DepthChecks
	WHERE DepthReading > PreviousDepthReading

-- Part 2

WITH DepthWindows AS (
	SELECT DepthID,
			DepthReading, 
			CASE 
				WHEN LEAD(DepthReading, 2) OVER (ORDER BY DepthID) IS NULL THEN 0
				ELSE 1
			END	AS DataCheck,
			SUM(DepthReading) OVER (ORDER BY DepthID ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS DepthWindow
	FROM dbo.Depths
),
DepthChecks AS (
	SELECT DepthWindow, LAG(DepthWindow) OVER (ORDER BY DepthID) AS PreviousDepthWindow
		FROM DepthWindows
		WHERE DataCheck = 1
)
SELECT COUNT(*) 
	FROM DepthChecks
	WHERE DepthWindow > PreviousDepthWindow