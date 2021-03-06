DROP TABLE IF EXISTS IntCodeInputs
CREATE TABLE IntCodeInputs (
	AmplifierCode CHAR(1),
	Iteration INT,
	InputNumber INT,
	Input INT
);

DROP TABLE IF EXISTS IntCodeOutputs
CREATE TABLE IntCodeOutputs (
	AmplifierCode CHAR(1),
	Iteration INT,
	OutputNumber INT,
	Output INT
);
GO

CREATE TRIGGER PassOutputToInput ON IntCodeOutputs
AFTER INSERT
AS

WITH AmplifierData AS (
SELECT CASE AmplifierCode
			WHEN 'A' THEN 'B'
			WHEN 'B' THEN 'C'
			WHEN 'C' THEN 'D'
			WHEN 'D' THEN 'E'
			WHEN 'E' THEN 'A'
		END as NextAmplifier, 
		Iteration,
		Output 
	FROM inserted
)
INSERT INTO IntCodeInputs (AmplifierCode, Iteration, InputNumber, Input)
SELECT NextAmplifier,
			Iteration,
			(SELECT MAX(InputNumber) + 1 FROM IntCodeInputs i WHERE i.AmplifierCode = a.NextAmplifier AND i.Iteration = a.Iteration),
			Output
		FROM AmplifierData a

GO

CREATE OR ALTER PROCEDURE FetchOperand (@Mode int, @ProgramPointer INT, @Offset int, @Operand INT OUTPUT)
AS

	IF @Mode = 0
		SELECT @Operand = code FROM #opcodes where Position = (SELECT code from #OpCodes where Position = @ProgramPointer + @Offset)
	if @Mode = 1
		SELECT @Operand = code FROM #opcodes where Position = @ProgramPointer + @Offset

GO

CREATE OR ALTER PROCEDURE dbo.TestIntMachine (@opcodes varchar(8000), @AmplifierCode CHAR(1), @Iteration INT)
as

CREATE TABLE #opcodes (
	Position int identity (0,1), 
	ParameterMode1 AS (substring(right('0000' + cast(code as varchar(6)),5), 3, 1)),
	ParameterMode2 AS (substring(right('0000' + cast(code as varchar(6)),5), 2, 1)),
	ParameterMode3 AS (substring(right('0000' + cast(code as varchar(6)),5), 1, 1)),
	Command AS cast((substring(right('0000' + cast(code as varchar(6)),5), 4, 2)) as int),
	Code int
)

INSERT INTO #opcodes (code)
SELECT value FROM STRING_SPLIT(@opcodes, ',')

declare @currentPosition int = 0,
	@CurrentOpCode int = 0,
	@Mode1 int,
	@Mode2 int,
	@Mode3 int,
	@Operand1 int, 
	@Operand2 int,
	@InputOffset INT = 1,
	@OutputOffset INT = 1;

WHILE @CurrentOpCode != 99
	begin
		select @CurrentOpCode = Command,
				@mode1 = ParameterMode1,
				@mode2 = ParameterMode2,
				@Mode3 = ParameterMode3
			from #opcodes where Position = @currentPosition

		if @CurrentOpCode = 1
			-- add
			begin

				EXEC FetchOperand @Mode1, @CurrentPosition, 1, @Operand1 OUTPUT
				EXEC FetchOperand @Mode2, @CurrentPosition, 2, @Operand2 OUTPUT
				
				UPDATE #opcodes 
					SET code = @Operand1 + @Operand2
						WHERE Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 3)

				set @currentPosition = @currentPosition + 4;
			end

		if @CurrentOpCode = 2
			-- multiply
			begin
				EXEC FetchOperand @Mode1, @CurrentPosition, 1, @Operand1 OUTPUT
				EXEC FetchOperand @Mode2, @CurrentPosition, 2, @Operand2 OUTPUT
				
				UPDATE #opcodes 
					SET code = @Operand1 * @Operand2
						WHERE Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 3)

				set @currentPosition = @currentPosition + 4;
			end

		if @CurrentOpCode = 3
			-- input
			begin
				
				WHILE NOT EXISTS (SELECT Input from IntCodeInputs WHERE AmplifierCode = @AmplifierCode AND Iteration = @Iteration AND InputNumber = @InputOffset)
				begin
					print 'waiting for ' + @AmplifierCode + cast(@Iteration as varchar(4)) + cast(@InputOffset as varchar(4))
					WAITFOR DELAY '00:00:01'
				end

				UPDATE #opcodes	
					SET code = (SELECT Input from IntCodeInputs WHERE AmplifierCode = @AmplifierCode AND Iteration = @Iteration AND InputNumber = @InputOffset)
					WHERE Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 1)

				SET @InputOffset += 1;
				SET @currentPosition += 2;
			end

		if @CurrentOpCode = 4
			-- output
			begin

				EXEC FetchOperand @Mode1, @CurrentPosition, 1, @Operand1 OUTPUT

				INSERT INTO IntCodeOutputs (AmplifierCode, Iteration, OutputNumber, Output)
				SELECT @AmplifierCode, @Iteration, @OutputOffset, @Operand1

				SET @OutputOffset += 1;
				SET @currentPosition += 2;
			END

		if @CurrentOpCode = 5
			-- jump if true
			BEGIN

				EXEC FetchOperand @Mode1, @CurrentPosition, 1, @Operand1 OUTPUT
				EXEC FetchOperand @Mode2, @CurrentPosition, 2, @Operand2 OUTPUT

				if @Operand1 > 0
					set @currentPosition = @Operand2
				else 
					set @currentPosition = @currentPosition + 3;

			end

		if @CurrentOpCode = 6
			-- jump if false
			begin
				EXEC FetchOperand @Mode1, @CurrentPosition, 1, @Operand1 OUTPUT
				EXEC FetchOperand @Mode2, @CurrentPosition, 2, @Operand2 OUTPUT

				if @Operand1 = 0
					set @currentPosition = @Operand2
				else 
					set @currentPosition = @currentPosition + 3;
			end

		if @CurrentOpCode = 7
			-- is less than
			begin

				EXEC FetchOperand @Mode1, @CurrentPosition, 1, @Operand1 OUTPUT
				EXEC FetchOperand @Mode2, @CurrentPosition, 2, @Operand2 OUTPUT

				update #opcodes set code = case when @Operand1 < @Operand2 then 1 else 0 end
					where Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 3)

				set @currentPosition = @currentPosition + 4;
			end

		if @CurrentOpCode = 8
			-- is equals
			begin

				EXEC FetchOperand @Mode1, @CurrentPosition, 1, @Operand1 OUTPUT
				EXEC FetchOperand @Mode2, @CurrentPosition, 2, @Operand2 OUTPUT

				update #opcodes set code = case when @Operand1 = @Operand2 then 1 else 0 end
					where Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 3)

				set @currentPosition = @currentPosition + 4;
			end

	end




