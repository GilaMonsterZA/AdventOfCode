DROP TABLE IF EXISTS AsteroidMap;
DROP TABLE IF EXISTS AsteroidLocations;

CREATE TABLE AsteroidMap (
	RowNo INT IDENTITY, 
	AsteroidRow VARCHAR(200)
);
CREATE TABLE AsteroidLocations (
	AsteroidID INT IDENTITY,
	X INT,
	Y INT
);	

DECLARE @AsteroidList VARCHAR(4000) = ''

INSERT INTO AsteroidMap (AsteroidRow)
VALUES 
('#.#...#.#.'),
('.###....#.'),
('.#....#...'),
('##.#.#.#.#'),
('....#.#.#.'),
('.##..###.#'),
('..#...##..'),
('..##....##'),
('......#...'),
('.####.###.');


--('.#..##.###...#######'),
--('##.############..##.'),
--('.#.######.########.#'),
--('.###.#######.####.#.'),
--('#####.##.#.##.###.##'),
--('..#####..#.#########'),
--('####################'),
--('#.####....###.#.#.##'),
--('##.#################'),
--('#####.##.###..####..'),
--('..######..##.#######'),
--('####.##.####...##..#'),
--('.#####..#.######.###'),
--('##...#.##########...'),
--('#.##########.#######'),
--('.####.#.###.###.#.##'),
--('....##.##.###..#####'),
--('.#.#.###########.###'),
--('#.#.#.#####.####.###'),
--('###.##.####.##.#..##');


--('...###.#########.####'),
--('.######.###.###.##...'),
--('####.########.#####.#'),
--('########.####.##.###.'),
--('####..#.####.#.#.##..'),
--('#.################.##'),
--('..######.##.##.#####.'),
--('#.####.#####.###.#.##'),
--('#####.#########.#####'),
--('#####.##..##..#.#####'),
--('##.######....########'),
--('.#######.#.#########.'),
--('.#.##.#.#.#.##.###.##'),
--('######...####.#.#.###'),
--('###############.#.###'),
--('#.#####.##..###.##.#.'),
--('##..##..###.#.#######'),
--('#..#..########.#.##..'),
--('#.#.######.##.##...##'),
--('.#.##.#####.#..#####.'),
--('#.#.##########..#.##.');

WITH AsteroidsSplit AS (
SELECT RowNo, n.Number, SUBSTRING(AsteroidRow,n.Number,1) AS IsAsteroid
	FROM AsteroidMap am
		CROSS JOIN dbo.Numbers n 
	WHERE n.Number <= LEN(am.AsteroidRow)
)
INSERT INTO dbo.AsteroidLocations (X, Y)
SELECT Number-1, RowNo-1
FROM AsteroidsSplit
WHERE IsAsteroid = '#';

TRUNCATE TABLE dbo.AsteroidLocations

INSERT INTO dbo.AsteroidLocations (Y,X)
VALUES 
(1,2), (1,6), (2,4), (4,3), (4,5);

WITH Tracking AS (
SELECT Station.AsteroidID, Station.X AS StationX, Station.Y AS StationY, Target.X AS TargetX, Target.Y AS TargetY,
	CASE WHEN Station.Y-Target.Y = 0 THEN 9999
		ELSE 1.0*(Station.X-Target.X)/(Station.Y-Target.Y)
	END 
	AS Angle,
	CASE 
		WHEN Station.X>=Target.X AND Station.Y<Target.Y
			THEN 0 
		WHEN Station.X>=Target.X AND Station.Y>=Target.Y 
			THEN 1
		WHEN Station.X<Target.X AND Station.Y>=Target.Y 
			THEN 2
		WHEN Station.X<Target.X AND Station.Y<Target.Y 
			THEN 3
	END  AS Quadrant
	FROM dbo.AsteroidLocations Station 
		CROSS JOIN dbo.AsteroidLocations Target
	WHERE Station.AsteroidID != Target.AsteroidID
)
-- answer to part 1
SELECT TOP(1) StationX, StationY, COUNT(*) 
	FROM dbo.AsteroidLocations al
		CROSS APPLY (
SELECT DISTINCT AsteroidID, StationX, StationY, 
		t.Quadrant, t.Angle
	FROM Tracking t
	WHERE t.StationX = al.X AND t.StationY = al.Y
	) Visible
	GROUP BY StationX,
             StationY
	ORDER BY COUNT(*) DESC;


WITH Shooting AS (
SELECT Station.AsteroidID, Station.X AS StationX, Station.Y AS StationY, Target.X AS TargetX, Target.Y AS TargetY,
	CASE WHEN Station.Y-Target.Y = 0 THEN 0
		ELSE DEGREES(ATAN(1.0*(Station.X-Target.X)/(Station.Y-Target.Y))) 
	END AS Angle,
	CASE 
		WHEN Target.X>=Station.X AND Target.Y<Station.Y
			THEN 0 
		WHEN Target.X>=Station.X AND Target.Y>=Station.Y 
			THEN 90
		WHEN Target.X<Station.X AND Target.Y>=Station.Y 
			THEN 180
		WHEN Target.X<Station.X AND Target.Y<Station.Y 
			THEN 270
	END  AS Quadrant,
	0 AS Distance
	FROM dbo.AsteroidLocations Station 
		CROSS JOIN dbo.AsteroidLocations Target
	WHERE Station.AsteroidID != Target.AsteroidID
)
SELECT AsteroidID,
       StationX,
       StationY,
       TargetX,
       TargetY,
       Angle,
       Quadrant,
	   StationX-TargetX,
	   StationY-TargetY
FROM Shooting
WHERE StationX = 4 AND StationY = 2
ORDER BY Angle, Quadrant
