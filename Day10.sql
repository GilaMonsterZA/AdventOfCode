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
('...###.#########.####'),
('.######.###.###.##...'),
('####.########.#####.#'),
('########.####.##.###.'),
('####..#.####.#.#.##..'),
('#.################.##'),
('..######.##.##.#####.'),
('#.####.#####.###.#.##'),
('#####.#########.#####'),
('#####.##..##..#.#####'),
('##.######....########'),
('.#######.#.#########.'),
('.#.##.#.#.#.##.###.##'),
('######...####.#.#.###'),
('###############.#.###'),
('#.#####.##..###.##.#.'),
('##..##..###.#.#######'),
('#..#..########.#.##..'),
('#.#.######.##.##...##'),
('.#.##.#####.#..#####.'),
('#.#.##########..#.##.');

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

-- Best station is at 11, 13

WITH Shooting AS (
SELECT Station.AsteroidID, Station.X AS StationX, Station.Y AS StationY, Target.X AS TargetX, Target.Y AS TargetY,
	CASE 
		WHEN Station.Y-Target.Y = 0 AND Station.X > Target.X THEN 90
		WHEN Station.Y-Target.Y = 0 AND Station.X < Target.X THEN -90
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
	SQRT(POWER(Station.X-Target.X, 2) + POWER(Station.Y-Target.Y, 2)) AS Distance -- Pythag
	FROM dbo.AsteroidLocations Station 
		CROSS JOIN dbo.AsteroidLocations Target
	WHERE Station.AsteroidID != Target.AsteroidID
		AND Station.X = 11 AND Station.Y = 13
),
Adjusted AS (
SELECT AsteroidID,
       StationX,
       StationY,
       TargetX,
       TargetY,
	   Distance,
	   Angle,
	   Quadrant,
	   CASE Quadrant
		WHEN 0 THEN Angle*-1
		WHEN 90 THEN 180-Angle
		WHEN 180 THEN 180+(Angle*-1)
		WHEN 270 THEN 360-Angle
	   END AS Rotation		
FROM Shooting
)
SELECT *, ROW_NUMBER() OVER (PARTITION BY Rotation ORDER BY Distance) AS ShootingOrder
FROM Adjusted
ORDER BY ShootingOrder, Rotation

-- Row 200 is the answer to part 2


