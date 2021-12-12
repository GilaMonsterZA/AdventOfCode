CREATE TABLE SubCommands (
	CommandID INT,
	Direction VARCHAR(50),
	Distance INT
);

INSERT INTO dbo.SubCommands (CommandID, Direction, Distance)
VALUES 
(1,'forward', 5),
(2,'down', 5),
(3,'forward', 8),
(4,'up', 3),
(5,'down', 8),
(6,'forward', 2);

-- TRUNCATE TABLE dbo.SubCommands

-- split and insert done from Excel

WITH SubCommandProcessed AS (
SELECT Direction, Distance,
	CASE Direction
		WHEN 'forward' THEN Distance
        ELSE 0
	END AS HorizontalDistance,
	CASE Direction
		WHEN 'forward' THEN 0
        WHEN 'down' THEN Distance
		WHEN 'up' THEN -1*Distance
	END AS Depth
	FROM dbo.SubCommands
)
SELECT SUM(HorizontalDistance), SUM(Depth) 
	FROM SubCommandProcessed;


-- part 2

WITH SubCommandProcessed AS (
SELECT Direction, Distance,
	CASE Direction
		WHEN 'forward' THEN Distance
        ELSE 0
	END AS HorizontalDistance,
	SUM(CASE Direction
			WHEN 'forward' THEN 0
			WHEN 'down' THEN Distance
			WHEN 'up' THEN -1*Distance
		END) OVER (ORDER BY CommandID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Aim
	FROM dbo.SubCommands
)
SELECT SUM(HorizontalDistance) AS HorizontalPosition, SUM(HorizontalDistance*Aim) AS Depth
FROM SubCommandProcessed

