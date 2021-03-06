DROP TABLE IF EXISTS IntCodeInputs
CREATE TABLE IntCodeInputs (
	InputNumber INT,
	Input BIGINT
);

DROP TABLE IF EXISTS IntCodeOutputs
CREATE TABLE IntCodeOutputs (
	OutputNumber INT,
	Output BIGINT
);
GO

CREATE OR ALTER PROCEDURE FetchOperand (@Mode INT, @ProgramPointer INT, @Offset INT, @Operand BIGINT OUTPUT, @RelativeBase INT)
AS

	SET @Operand = NULL;

	IF @Mode = 0
		SELECT @Operand = code FROM #opcodes WHERE Position = (SELECT code FROM #OpCodes WHERE Position = @ProgramPointer + @Offset)
	IF @Mode = 1
		SELECT @Operand = code FROM #opcodes WHERE Position = @ProgramPointer + @Offset
	IF @Mode = 2
		SELECT @Operand = code FROM #opcodes WHERE Position = (SELECT code FROM #OpCodes WHERE Position = @ProgramPointer + @Offset)  + @RelativeBase

	IF @Operand IS NULL
		SET @Operand = 0;

GO

CREATE OR ALTER PROCEDURE dbo.TestIntMachine (@opcodes VARCHAR(8000))
AS

CREATE TABLE #opcodes (
	RowNo INT IDENTITY (0,1), 
	Position INT,
	ParameterMode1 AS (SUBSTRING(RIGHT('0000' + CAST(code AS VARCHAR(18)),5), 3, 1)),
	ParameterMode2 AS (SUBSTRING(RIGHT('0000' + CAST(code AS VARCHAR(18)),5), 2, 1)),
	ParameterMode3 AS (SUBSTRING(RIGHT('0000' + CAST(code AS VARCHAR(18)),5), 1, 1)),
	Command AS CAST((SUBSTRING(RIGHT('0000' + CAST(code AS VARCHAR(18)),5), 4, 2)) AS BIGINT),
	Code BIGINT
)
INSERT INTO #opcodes (Code)
SELECT value
FROM STRING_SPLIT(@opcodes, ',')

UPDATE #opcodes
	SET Position = RowNo;

ALTER TABLE #opcodes
	DROP COLUMN RowNo;

DECLARE @currentPosition INT = 0,
	@CurrentOpCode INT = 0,
	@Mode1 INT,
	@Mode2 INT,
	@Mode3 INT,
	@Operand1 BIGINT, 
	@Operand2 BIGINT,
	@Operand3 BIGINT,
	@InputOffset INT = 1,
	@OutputOffset INT = 1,
	@RelativeBase INT = 0;

WHILE @CurrentOpCode != 99
	BEGIN
		SELECT @CurrentOpCode = Command,
				@Mode1 = ParameterMode1,
				@Mode2 = ParameterMode2,
				@Mode3 = ParameterMode3
			FROM #opcodes WHERE Position = @currentPosition

		IF @CurrentOpCode = 1
			-- add
			BEGIN

				EXEC FetchOperand @Mode1, @currentPosition, 1, @Operand1 OUTPUT, @RelativeBase
				EXEC FetchOperand @Mode2, @currentPosition, 2, @Operand2 OUTPUT, @RelativeBase
				SET @Operand3 = (SELECT code from #OpCodes where Position = @CurrentPosition + 3) + CASE WHEN @Mode3 = 2 THEN @RelativeBase ELSE 0 END

				UPDATE #opcodes 
					SET Code = @Operand1 + @Operand2
						WHERE Position = @Operand3

				IF @@ROWCOUNT = 0
					INSERT INTO #opcodes (Position, Code)
					VALUES (@Operand3, @Operand1 + @Operand2)

				SET @currentPosition = @currentPosition + 4;
			END

		IF @CurrentOpCode = 2
			-- multiply
			BEGIN
				EXEC FetchOperand @Mode1, @currentPosition, 1, @Operand1 OUTPUT, @RelativeBase
				EXEC FetchOperand @Mode2, @currentPosition, 2, @Operand2 OUTPUT, @RelativeBase
				SET @Operand3 = (SELECT code from #OpCodes where Position = @CurrentPosition + 3) + CASE WHEN @Mode3 = 2 THEN @RelativeBase ELSE 0 END
				
				UPDATE #opcodes 
					SET Code = @Operand1 * @Operand2
						WHERE Position = @Operand3

				IF @@ROWCOUNT = 0
					INSERT INTO #opcodes (Position, Code)
					VALUES (@Operand3, @Operand1 * @Operand2)

				SET @currentPosition = @currentPosition + 4;
			END

		IF @CurrentOpCode = 3
			-- input
			BEGIN

				SET @Operand1 = (SELECT code from #OpCodes where Position = @CurrentPosition + 1) + CASE WHEN @Mode1 = 2 THEN @RelativeBase ELSE 0 END

				UPDATE #opcodes	
					SET Code = (SELECT Input FROM IntCodeInputs WHERE InputNumber = @InputOffset)
						WHERE Position = @Operand1

				IF @@ROWCOUNT = 0
					INSERT INTO #opcodes (Position, Code)
					SELECT @Operand1, Input FROM IntCodeInputs WHERE InputNumber = @InputOffset

				SET @InputOffset += 1;
				SET @currentPosition += 2;
			END

		IF @CurrentOpCode = 4
			-- output
			BEGIN

				EXEC FetchOperand @Mode1, @currentPosition, 1, @Operand1 OUTPUT, @RelativeBase

				INSERT INTO IntCodeOutputs (OutputNumber, Output)
				VALUES (@OutputOffset, @Operand1)

				SET @OutputOffset += 1;
				SET @currentPosition += 2;
			END

		IF @CurrentOpCode = 5
			-- jump if true
			BEGIN

				EXEC FetchOperand @Mode1, @currentPosition, 1, @Operand1 OUTPUT, @RelativeBase
				EXEC FetchOperand @Mode2, @currentPosition, 2, @Operand2 OUTPUT, @RelativeBase

				IF @Operand1 > 0
					SET @currentPosition = @Operand2
				ELSE 
					SET @currentPosition = @currentPosition + 3;

			END

		IF @CurrentOpCode = 6
			-- jump if false
			BEGIN
				EXEC FetchOperand @Mode1, @currentPosition, 1, @Operand1 OUTPUT, @RelativeBase
				EXEC FetchOperand @Mode2, @currentPosition, 2, @Operand2 OUTPUT, @RelativeBase

				IF @Operand1 = 0
					SET @currentPosition = @Operand2
				ELSE 
					SET @currentPosition = @currentPosition + 3;
			END

		IF @CurrentOpCode = 7
			-- is less than
			BEGIN

				EXEC FetchOperand @Mode1, @currentPosition, 1, @Operand1 OUTPUT, @RelativeBase
				EXEC FetchOperand @Mode2, @currentPosition, 2, @Operand2 OUTPUT, @RelativeBase
				SET @Operand3 = (SELECT code from #OpCodes where Position = @CurrentPosition + 3) + CASE WHEN @Mode3 = 2 THEN @RelativeBase ELSE 0 END

				UPDATE #opcodes SET Code = CASE WHEN @Operand1 < @Operand2 THEN 1 ELSE 0 END
					WHERE Position = @Operand3

				IF @@ROWCOUNT = 0
					INSERT INTO #opcodes (Position, Code)
					VALUES (@Operand3, CASE WHEN @Operand1 < @Operand2 THEN 1 ELSE 0 END)

				SET @currentPosition = @currentPosition + 4;
			END

		IF @CurrentOpCode = 8
			-- is equals
			BEGIN

				EXEC FetchOperand @Mode1, @currentPosition, 1, @Operand1 OUTPUT, @RelativeBase
				EXEC FetchOperand @Mode2, @currentPosition, 2, @Operand2 OUTPUT, @RelativeBase
				SET @Operand3 = (SELECT code from #OpCodes where Position = @CurrentPosition + 3) + CASE WHEN @Mode3 = 2 THEN @RelativeBase ELSE 0 END

				UPDATE #opcodes SET Code = CASE WHEN @Operand1 = @Operand2 THEN 1 ELSE 0 END
					WHERE Position = @Operand3

				IF @@ROWCOUNT = 0
					INSERT INTO #opcodes (Position, Code)
					VALUES (@Operand3, CASE WHEN @Operand1 = @Operand2 THEN 1 ELSE 0 END)

				SET @currentPosition = @currentPosition + 4;
			END

		IF @CurrentOpCode = 9
			--Opcode 9 adjusts the relative base by the value of its only parameter. The relative base increases (or decreases, if the value is negative) by the value of the parameter.
			BEGIN
				EXEC FetchOperand @Mode1, @currentPosition, 1, @Operand1 OUTPUT, @RelativeBase

				--SELECT @currentPosition, @Mode1, @Operand1, @RelativeBase

				SET @RelativeBase += @Operand1;
				
				--SELECT @currentPosition, @Mode1, @Operand1, @RelativeBase

				SET @currentPosition = @currentPosition + 2;
			END

		--SELECT @CurrentOpCode, @Operand1, @Operand2, @Operand3, @RelativeBase

	END

	SELECT * FROM #opcodes