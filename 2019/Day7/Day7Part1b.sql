-- set up all possible permutations of 0,1,2,3,4

DECLARE @opcodeInput varchar(8000) = '3,8,1001,8,10,8,105,1,0,0,21,34,55,68,85,106,187,268,349,430,99999,3,9,1001,9,5,9,1002,9,5,9,4,9,99,3,9,1002,9,2,9,1001,9,2,9,1002,9,5,9,1001,9,2,9,4,9,99,3,9,101,3,9,9,102,3,9,9,4,9,99,3,9,1002,9,5,9,101,3,9,9,102,5,9,9,4,9,99,3,9,1002,9,4,9,1001,9,2,9,102,3,9,9,101,3,9,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,99',
	@Result INT;

DECLARE @Phases TABLE (Phase INT);

INSERT INTO @Phases 
VALUES (0),(1),(2),(3),(4)

DROP TABLE IF EXISTS #AmplifierChecks
CREATE TABLE #AmplifierChecks (
	Iteration INT IDENTITY(1,1),
	PhaseA INT,
	PhaseB INT,
	PhaseC INT,
	PhaseD INT,
	PhaseE INT,
	FinalOutput INT
);

INSERT INTO #AmplifierChecks (PhaseA, PhaseB, PhaseC, PhaseD, PhaseE)
SELECT p0.Phase, p1.Phase, p2.Phase, p3.Phase, p4.Phase
	FROM @Phases p0 CROSS JOIN @Phases p1 CROSS JOIN @Phases p2 CROSS JOIN @Phases p3 CROSS JOIN @Phases p4
	WHERE p0.Phase != p1.Phase AND p0.Phase != p2.Phase AND p0.Phase != p3.Phase AND p0.Phase != p4.Phase
		AND p1.Phase != p2.Phase AND p1.Phase != p3.Phase AND p1.Phase != p4.Phase 
		AND p2.Phase != p3.Phase AND p2.Phase != p4.Phase
		AND p3.Phase != p4.Phase 

DECLARE @Iteration INT, @EndIteration INT;
SELECT @Iteration = MIN(Iteration), @EndIteration = MAX(Iteration) FROM #AmplifierChecks;

WHILE (@Iteration <= @EndIteration)
	BEGIN

		DECLARE @Input IntcodeInputs;

		INSERT INTO @Input 
		SELECT 1, PhaseA
			FROM #AmplifierChecks
			WHERE Iteration = @Iteration;

		INSERT INTO @Input
		SELECT 2, 0

		EXEC TestIntMachine @opcodeInput, @Input, @Result OUTPUT;

		DELETE FROM @Input;

		INSERT INTO @Input 
		SELECT 1, PhaseB
			FROM #AmplifierChecks
			WHERE Iteration = @Iteration;

		INSERT INTO @Input
		VALUES (2,@Result);

		EXEC TestIntMachine @opcodeInput, @Input, @Result OUTPUT;

		DELETE FROM @Input;

		INSERT INTO @Input
		SELECT 1, PhaseC
			FROM #AmplifierChecks
			WHERE Iteration = @Iteration;

		INSERT INTO @Input
		VALUES (2,@Result);

		EXEC TestIntMachine @opcodeInput, @Input, @Result OUTPUT;

		DELETE FROM @Input;

		INSERT INTO @Input
		SELECT 1, PhaseD
			FROM #AmplifierChecks
			WHERE Iteration = @Iteration;

		INSERT INTO @Input
		VALUES (2,@Result);

		EXEC TestIntMachine @opcodeInput, @Input, @Result OUTPUT;

		DELETE FROM @Input;

		INSERT INTO @Input
		SELECT 1, PhaseE
			FROM #AmplifierChecks
			WHERE Iteration = @Iteration;

		INSERT INTO @Input
		VALUES (2,@Result);

		EXEC TestIntMachine @opcodeInput, @Input, @Result OUTPUT;

		DELETE FROM @Input;

		UPDATE #AmplifierChecks 
			SET FinalOutput = @Result
			WHERE Iteration = @Iteration;

		SET @Iteration += 1;

	END

	SELECT top(1) * 
		FROM #AmplifierChecks
		ORDER BY FinalOutput DESC