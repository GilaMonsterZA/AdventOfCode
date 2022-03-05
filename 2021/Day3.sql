CREATE TABLE Diagnostics (
	RowID INT,
	ReportLine CHAR(12)
)

INSERT INTO dbo.Diagnostics (RowID, ReportLine)
VALUES
(1,'00100'),
(2,'11110'),
(3,'10110'),
(4,'10111'),
(5,'10101'),
(6,'01111'),
(7,'00111'),
(8,'11100'),
(9,'10000'),
(10,'11001'),
(11,'00010'),
(12,'01010');

-- truncate table dbo.Diagnostics



-- full data load done via Excel

-- Part 1

WITH DiagnosticBits AS (
	SELECT 
		ReportLine,
		CAST(SUBSTRING(ReportLine, 1,1) AS TINYINT) AS Bit1,
		CAST(SUBSTRING(ReportLine, 2,1) AS TINYINT) AS Bit2,
		CAST(SUBSTRING(ReportLine, 3,1) AS TINYINT) AS Bit3,
		CAST(SUBSTRING(ReportLine, 4,1) AS TINYINT) AS Bit4,
		CAST(SUBSTRING(ReportLine, 5,1) AS TINYINT) AS Bit5,
		CAST(SUBSTRING(ReportLine, 6,1) AS TINYINT) AS Bit6,
		CAST(SUBSTRING(ReportLine, 7,1) AS TINYINT) AS Bit7,
		CAST(SUBSTRING(ReportLine, 8,1) AS TINYINT) AS Bit8,
		CAST(SUBSTRING(ReportLine, 9,1) AS TINYINT) AS Bit9,
		CAST(SUBSTRING(ReportLine, 10,1) AS TINYINT) AS Bit10,
		CAST(SUBSTRING(ReportLine, 11,1) AS TINYINT) AS Bit11,
		CAST(SUBSTRING(ReportLine, 12,1) AS TINYINT) AS Bit12
	FROM dbo.Diagnostics
),
BitRatios AS (
	SELECT 
		COUNT(*) - SUM(Bit1) AS Bit1Value0,
		SUM(Bit1) AS Bit1Value1,	
		COUNT(*) - SUM(Bit2) AS Bit2Value0,
		SUM(Bit2) AS Bit2Value1,
		COUNT(*) - SUM(Bit3) AS Bit3Value0,
		SUM(Bit3) AS Bit3Value1,
		COUNT(*) - SUM(Bit4) AS Bit4Value0,
		SUM(Bit4) AS Bit4Value1,
		COUNT(*) - SUM(Bit5) AS Bit5Value0,
		SUM(Bit5) AS Bit5Value1,
		COUNT(*) - SUM(Bit6) AS Bit6Value0,
		SUM(Bit6) AS Bit6Value1,
		COUNT(*) - SUM(Bit7) AS Bit7Value0,
		SUM(Bit7) AS Bit7Value1,
		COUNT(*) - SUM(Bit8) AS Bit8Value0,
		SUM(Bit8) AS Bit8Value1,
		COUNT(*) - SUM(Bit9) AS Bit9Value0,
		SUM(Bit9) AS Bit9Value1,
		COUNT(*) - SUM(Bit10) AS Bit10Value0,
		SUM(Bit10) AS Bit10Value1,
		COUNT(*) - SUM(Bit11) AS Bit11Value0,
		SUM(Bit11) AS Bit11Value1,
		COUNT(*) - SUM(Bit12) AS Bit12Value0,
		SUM(Bit12) AS Bit12Value1
	FROM DiagnosticBits
)
SELECT 
	CASE WHEN Bit1Value0 > Bit1Value1 THEN '0' ELSE '1' END + CASE WHEN Bit2Value0 > Bit2Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit3Value0 > Bit3Value1 THEN '0' ELSE '1' END + CASE WHEN Bit4Value0 > Bit4Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit5Value0 > Bit5Value1 THEN '0' ELSE '1' END + CASE WHEN Bit6Value0 > Bit6Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit7Value0 > Bit7Value1 THEN '0' ELSE '1' END + CASE WHEN Bit8Value0 > Bit8Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit9Value0 > Bit9Value1 THEN '0' ELSE '1' END + CASE WHEN Bit10Value0 > Bit10Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit11Value0 > Bit11Value1 THEN '0' ELSE '1' END + CASE WHEN Bit12Value0 > Bit12Value1 THEN '0' ELSE '1' END AS GammaRate,
	CASE WHEN Bit1Value0 < Bit1Value1 THEN '0' ELSE '1' END + CASE WHEN Bit2Value0 < Bit2Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit3Value0 < Bit3Value1 THEN '0' ELSE '1' END + CASE WHEN Bit4Value0 < Bit4Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit5Value0 < Bit5Value1 THEN '0' ELSE '1' END + CASE WHEN Bit6Value0 < Bit6Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit7Value0 < Bit7Value1 THEN '0' ELSE '1' END + CASE WHEN Bit8Value0 < Bit8Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit9Value0 < Bit9Value1 THEN '0' ELSE '1' END + CASE WHEN Bit10Value0 < Bit10Value1 THEN '0' ELSE '1' END + 
		CASE WHEN Bit11Value0 < Bit11Value1 THEN '0' ELSE '1' END + CASE WHEN Bit12Value0 < Bit12Value1 THEN '0' ELSE '1' END AS EpsilonRate
FROM BitRatios;

-- Part 2

CREATE TABLE SignificantBits (
	Type VARCHAR(10),
	Bit1 TINYINT,
	Bit2 TINYINT,
	Bit3 TINYINT,
	Bit4 TINYINT,
	Bit5 TINYINT,
	Bit6 TINYINT,
	Bit7 TINYINT,
	Bit8 TINYINT,
	Bit9 TINYINT,
	Bit10 TINYINT,
	Bit11 TINYINT,
	Bit12 TINYINT
);

WITH DiagnosticBits AS (
	SELECT 
		ReportLine,
		CAST(SUBSTRING(ReportLine, 1,1) AS TINYINT) AS Bit1,
		CAST(SUBSTRING(ReportLine, 2,1) AS TINYINT) AS Bit2,
		CAST(SUBSTRING(ReportLine, 3,1) AS TINYINT) AS Bit3,
		CAST(SUBSTRING(ReportLine, 4,1) AS TINYINT) AS Bit4,
		CAST(SUBSTRING(ReportLine, 5,1) AS TINYINT) AS Bit5,
		CAST(SUBSTRING(ReportLine, 6,1) AS TINYINT) AS Bit6,
		CAST(SUBSTRING(ReportLine, 7,1) AS TINYINT) AS Bit7,
		CAST(SUBSTRING(ReportLine, 8,1) AS TINYINT) AS Bit8,
		CAST(SUBSTRING(ReportLine, 9,1) AS TINYINT) AS Bit9,
		CAST(SUBSTRING(ReportLine, 10,1) AS TINYINT) AS Bit10,
		CAST(SUBSTRING(ReportLine, 11,1) AS TINYINT) AS Bit11,
		CAST(SUBSTRING(ReportLine, 12,1) AS TINYINT) AS Bit12
	FROM dbo.Diagnostics
),
BitRatios AS (
	SELECT 
		COUNT(*) - SUM(Bit1) AS Bit1Value0,
		SUM(Bit1) AS Bit1Value1,	
		COUNT(*) - SUM(Bit2) AS Bit2Value0,
		SUM(Bit2) AS Bit2Value1,
		COUNT(*) - SUM(Bit3) AS Bit3Value0,
		SUM(Bit3) AS Bit3Value1,
		COUNT(*) - SUM(Bit4) AS Bit4Value0,
		SUM(Bit4) AS Bit4Value1,
		COUNT(*) - SUM(Bit5) AS Bit5Value0,
		SUM(Bit5) AS Bit5Value1,
		COUNT(*) - SUM(Bit6) AS Bit6Value0,
		SUM(Bit6) AS Bit6Value1,
		COUNT(*) - SUM(Bit7) AS Bit7Value0,
		SUM(Bit7) AS Bit7Value1,
		COUNT(*) - SUM(Bit8) AS Bit8Value0,
		SUM(Bit8) AS Bit8Value1,
		COUNT(*) - SUM(Bit9) AS Bit9Value0,
		SUM(Bit9) AS Bit9Value1,
		COUNT(*) - SUM(Bit10) AS Bit10Value0,
		SUM(Bit10) AS Bit10Value1,
		COUNT(*) - SUM(Bit11) AS Bit11Value0,
		SUM(Bit11) AS Bit11Value1,
		COUNT(*) - SUM(Bit12) AS Bit12Value0,
		SUM(Bit12) AS Bit12Value1
	FROM DiagnosticBits
)
INSERT INTO SignificantBits
SELECT 
	'Most' AS Mode,
	CASE WHEN Bit1Value0 > Bit1Value1 THEN 0 ELSE 1 END AS Bit1, 
	CASE WHEN Bit2Value0 > Bit2Value1 THEN 0 ELSE 1 END AS Bit2, 
	CASE WHEN Bit3Value0 > Bit3Value1 THEN 0 ELSE 1 END AS Bit3, 
	CASE WHEN Bit4Value0 > Bit4Value1 THEN 0 ELSE 1 END AS Bit4,  
	CASE WHEN Bit5Value0 > Bit5Value1 THEN 0 ELSE 1 END AS Bit5, 
	CASE WHEN Bit6Value0 > Bit6Value1 THEN 0 ELSE 1 END AS Bit6, 
	CASE WHEN Bit7Value0 > Bit7Value1 THEN 0 ELSE 1 END AS Bit7, 
	CASE WHEN Bit8Value0 > Bit8Value1 THEN 0 ELSE 1 END AS Bit8,  
	CASE WHEN Bit9Value0 > Bit9Value1 THEN 0 ELSE 1 END AS Bit9, 
	CASE WHEN Bit10Value0 > Bit10Value1 THEN 0 ELSE 1 END AS Bit10,  
	CASE WHEN Bit11Value0 > Bit11Value1 THEN 0 ELSE 1 END AS Bit11, 
	CASE WHEN Bit12Value0 > Bit12Value1 THEN 0 ELSE 1 END AS Bit12	
FROM BitRatios
UNION ALL
SELECT 'Least' AS Mode,
	CASE WHEN Bit1Value0 < Bit1Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit2Value0 < Bit2Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit3Value0 < Bit3Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit4Value0 < Bit4Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit5Value0 < Bit5Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit6Value0 < Bit6Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit7Value0 < Bit7Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit8Value0 < Bit8Value1 THEN 0 ELSE 1 END,
	CASE WHEN Bit9Value0 < Bit9Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit10Value0 < Bit10Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit11Value0 < Bit11Value1 THEN 0 ELSE 1 END, 
	CASE WHEN Bit12Value0 < Bit12Value1 THEN 0 ELSE 1 END 
FROM BitRatios;

SELECT * FROM dbo.SignificantBits;

WITH DiagnosticBits AS (
	SELECT 
		ReportLine,
		CAST(SUBSTRING(ReportLine, 1,1) AS TINYINT) AS Bit1,
		CAST(SUBSTRING(ReportLine, 2,1) AS TINYINT) AS Bit2,
		CAST(SUBSTRING(ReportLine, 3,1) AS TINYINT) AS Bit3,
		CAST(SUBSTRING(ReportLine, 4,1) AS TINYINT) AS Bit4,
		CAST(SUBSTRING(ReportLine, 5,1) AS TINYINT) AS Bit5,
		CAST(SUBSTRING(ReportLine, 6,1) AS TINYINT) AS Bit6,
		CAST(SUBSTRING(ReportLine, 7,1) AS TINYINT) AS Bit7,
		CAST(SUBSTRING(ReportLine, 8,1) AS TINYINT) AS Bit8,
		CAST(SUBSTRING(ReportLine, 9,1) AS TINYINT) AS Bit9,
		CAST(SUBSTRING(ReportLine, 10,1) AS TINYINT) AS Bit10,
		CAST(SUBSTRING(ReportLine, 11,1) AS TINYINT) AS Bit11,
		CAST(SUBSTRING(ReportLine, 12,1) AS TINYINT) AS Bit12
	FROM dbo.Diagnostics
)
-- unpivot
