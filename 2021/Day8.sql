CREATE TABLE Day8Import (
	RowID int identity,
	Signal0 char(7),
	Signal1 char(7),
	Signal2 char(7),
	Signal3 char(7),
	Signal4 char(7),
	Signal5 char(7),
	Signal6 char(7),
	Signal7 char(7),
	Signal8 char(7),
	Signal9 char(7),
	Display1 char(7),
	Display2 char(7),
	Display3 char(7),
	Display4 char(7)
);
GO
-- import from excel, where the data was split into columns

-- How many times does 1, 4, 7, 8 appear in the output displays
-- 1 has a len of 2, 4 has a len of 4, 7 has a len of 3, 8 has a len of 7

WITH BasicDigits AS (
SELECT [Signal0], [Signal1], [Signal2], [Signal3], [Signal4], [Signal5], [Signal6], [Signal7], [Signal8], [Signal9], [Display1], [Display2], [Display3], [Display4],
	CASE WHEN LEN(Display1) IN (2,3,4,7) THEN 1 ELSE 0 END AS Check1, CASE WHEN LEN(Display2) IN (2,3,4,7) THEN 1 ELSE 0 END AS Check2, CASE WHEN LEN(Display3) IN (2,3,4,7) THEN 1 ELSE 0 END AS Check3, CASE WHEN LEN(Display4) IN (2,3,4,7) THEN 1 ELSE 0 END AS Check4
FROM Day8Import
)
SELECT sum(Check1+Check2+Check3+Check4)
from BasicDigits
GO

-- Part 2

CREATE TABLE Segments (
	Segment TINYINT
);
INSERT INTO Segments 
	VALUES (1),(2),(3),(4),(5),(6),(7)
GO

DROP TABLE IF EXISTS Signals;
DROP TABLE IF EXISTS SignalElements;
GO

CREATE TABLE Signals (
 RowID int,
 Display tinyint,
 Signal Char(7),
 DecodedValue tinyint
);

CREATE TABLE SignalElements (
	RowID INT,
	Signal TINYINT,
	Segment CHAR(1)
);
GO

Insert Into Signals (RowID, Display, Signal, DecodedValue)
select RowID, CAST(REPLACE(Display,'Signal','') AS TinyINT) AS Display, Signal, CAST (NULL AS Tinyint) AS DecodedValue
from 
	(SELECT RowID, Signal0, Signal1, Signal2, Signal3, Signal4, Signal5, Signal6, Signal7, Signal8, Signal9 FROM Day8Import) sig 
	UNPIVOT (Signal FOR Display IN (Signal0, Signal1, Signal2, Signal3, Signal4, Signal5, Signal6, Signal7, Signal8, Signal9)) AS u;

With SplitSignals as (
SELECT RowID, 0 as Signal, SUBSTRING(Signal0,Segments.Segment,1) as Segment 
	FROM Day8Import CROSS APPLY Segments
	WHERE SUBSTRING(Signal0,Segments.Segment,1) != ''
)
insert into SignalElements (RowID, Signal, Segment)
Select * from SplitSignals
order by RowID, Signal, segment

