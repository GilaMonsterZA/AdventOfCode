declare @Path1 varchar(4000) = 'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51',
		@Path2 varchar(4000) = 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7'

drop table if exists Paths

CREATE TABLE Paths (
	StepID int identity(1,1),
	PathID int,
	TurtleCmd varchar(6)
)

insert into Paths (PathID, TurtleCmd)
SELECT 1, 'U0' -- origin
union all
SELECT 1, value from string_split(@Path1,',');

insert into Paths (PathID, TurtleCmd)
SELECT 2, 'U0' -- origin
union all
SELECT 2, value from string_split(@Path2,',');

WITH PathCalculation AS (
SELECT
		StepID,
		PathID,
		CASE LEFT(TurtleCmd,1) 
			WHEN 'R' THEN 0
			WHEN 'U' THEN 1
			WHEN 'L' THEN 0
			WHEN 'D' THEN -1
		END AS VerticalMultiplier,
		CASE LEFT(TurtleCmd,1) 
			WHEN 'R' THEN 1
			WHEN 'U' THEN 0
			WHEN 'L' THEN -1
			WHEN 'D' THEN 0
		END AS HorizontalMultiplier,
		RIGHT(TurtleCmd, LEN(TurtleCmd)-1) as Movement
	FROM Paths
),
ComputedPaths as (
SELECT StepID, PathID,
		SUM(VerticalMultiplier * Movement) over (Partition by PathID Order By StepID rows between unbounded preceding and current row)
			as VerticalPosition,
		SUM(HorizontalMultiplier * Movement) over (Partition by PathID Order By StepID rows between unbounded preceding and current row)
			as HorizontalPosition
FROM PathCalculation
)
SELECT PathID, STRING_AGG(CAST(VerticalPosition as VARCHAR(6)) + ' ' + CAST(HorizontalPosition as VARCHAR(6)), ',') WITHIN GROUP (ORDER BY StepID ) 
FROM ComputedPaths
group by PathID;