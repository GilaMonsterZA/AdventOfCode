create table DiagnosticReportEntries (
	EntryID Int not null Primary Key,
	EntryLine Char(12),
);

create table DiagnosticReportEntryItems (
	EntryID int,
	Offset tinyint,
	value tinyint,
	Status Char(1)
);

/*
truncate table DiagnosticReportEntries
truncate table DiagnosticReportEntryItems
*/

insert into DiagnosticReportEntries
values 
(1, '00100'),
(2, '11110'),
(3, '10110'),
(4, '10111'),
(5, '10101'),
(6, '01111'),
(7, '00111'),
(8, '11100'),
(9, '10000'),
(10, '11001'),
(11, '00010'),
(12, '01010');


With SeparatedBits AS (
select EntryID, EntryLine, 
	Nullif(Substring(EntryLine,1,1),'') as [1],
	Nullif(Substring(EntryLine,2,1),'') as [2],
	Nullif(Substring(EntryLine,3,1),'') as [3],
	Nullif(Substring(EntryLine,4,1),'') as [4],
	Nullif(Substring(EntryLine,5,1),'') as [5],
	Nullif(Substring(EntryLine,6,1),'') as [6],
	Nullif(Substring(EntryLine,7,1),'') as [7],
	Nullif(Substring(EntryLine,8,1),'') as [8],
	Nullif(Substring(EntryLine,9,1),'') as [9],
	Nullif(Substring(EntryLine,10,1),'') as [10],
	Nullif(Substring(EntryLine,11,1),'') as [11],
	Nullif(Substring(EntryLine,12,1),'') as [12]
from DiagnosticReportEntries
)
insert into DiagnosticReportEntryItems (EntryID, Offset, Value, Status)
select EntryID, EntryBit, BitValue, 'A' from (
select EntryID, [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12] from SeparatedBits
) as Orig
UNPIVOT (BitValue FOR EntryBit IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) as u
	


-- O2

DECLARE @Pass int = 1;
DECLARE @Count0s INT, @Count1s INT, @ValueToRemove INT;

While @Pass <= 12
	BEGIN
		SELECT @Count0s = COUNT(*) FROM DiagnosticReportEntryItems WHERE Offset = @Pass AND Value = 0 and Status = 'A';
		SELECT @Count1s = COUNT(*) FROM DiagnosticReportEntryItems WHERE Offset = @Pass AND Value = 1 and Status = 'A';

		IF @Count0s > @Count1s 
			SET @ValueToRemove = 1
		ELSE 
			SET @ValueToRemove = 0

		UPDATE DiagnosticReportEntryItems 
			Set Status = 'I'
		WHERE EntryID IN (SELECT EntryID FROM DiagnosticReportEntryItems WHERE Offset = @Pass AND value = @ValueToRemove and Status = 'A');

		IF (SELECT Count(DISTINCT EntryID) FROM DiagnosticReportEntryItems WHERE Status = 'A') = 1
			BREAK;

		SET @Pass = @Pass + 1;
	END

SELECT * FROM DiagnosticReportEntries WHERE EntryID IN (SELECT EntryID from DiagnosticReportEntryItems WHERE Status = 'A')

Update DiagnosticReportEntryItems SET Status = 'A'

-- CO2
SET @Pass = 1;

While @Pass <= 12
	BEGIN
		SELECT @Count0s = COUNT(*) FROM DiagnosticReportEntryItems WHERE Offset = @Pass AND Value = 0 and Status = 'A';
		SELECT @Count1s = COUNT(*) FROM DiagnosticReportEntryItems WHERE Offset = @Pass AND Value = 1 and Status = 'A';

		IF @Count0s > @Count1s 
			SET @ValueToRemove = 0
		ELSE 
			SET @ValueToRemove = 1

		UPDATE DiagnosticReportEntryItems 
			Set Status = 'I'
		WHERE EntryID IN (SELECT EntryID FROM DiagnosticReportEntryItems WHERE Offset = @Pass AND value = @ValueToRemove and Status = 'A');

		IF (SELECT Count(DISTINCT EntryID) FROM DiagnosticReportEntryItems WHERE Status = 'A') = 1
			BREAK;

		SET @Pass = @Pass + 1;
	END

SELECT * FROM DiagnosticReportEntries WHERE EntryID IN (SELECT EntryID from DiagnosticReportEntryItems WHERE Status = 'A')

