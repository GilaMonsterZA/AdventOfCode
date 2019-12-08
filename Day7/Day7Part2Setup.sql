DECLARE @Phases TABLE (Phase INT);

INSERT INTO @Phases 
VALUES (5),(6),(7),(8),(9)

DROP TABLE IF EXISTS AmplifierChecks;
CREATE TABLE AmplifierChecks (
	Iteration INT IDENTITY(1,1),
	PhaseA INT,
	PhaseB INT,
	PhaseC INT,
	PhaseD INT,
	PhaseE INT,
	FinalOutput INT
);

INSERT INTO AmplifierChecks (PhaseA, PhaseB, PhaseC, PhaseD, PhaseE)
SELECT p0.Phase, p1.Phase, p2.Phase, p3.Phase, p4.Phase
	FROM @Phases p0 CROSS JOIN @Phases p1 CROSS JOIN @Phases p2 CROSS JOIN @Phases p3 CROSS JOIN @Phases p4
	WHERE p0.Phase != p1.Phase AND p0.Phase != p2.Phase AND p0.Phase != p3.Phase AND p0.Phase != p4.Phase
		AND p1.Phase != p2.Phase AND p1.Phase != p3.Phase AND p1.Phase != p4.Phase 
		AND p2.Phase != p3.Phase AND p2.Phase != p4.Phase
		AND p3.Phase != p4.Phase;

INSERT INTO IntCodeInputs (AmplifierCode, Iteration, InputNumber, Input)
SELECT 'A', 1, 1, PhaseA FROM AmplifierChecks WHERE Iteration = 1;

INSERT INTO IntCodeInputs (AmplifierCode, Iteration, InputNumber, Input)
SELECT 'B', 1, 1, PhaseB FROM AmplifierChecks WHERE Iteration = 1;

INSERT INTO IntCodeInputs (AmplifierCode, Iteration, InputNumber, Input)
SELECT 'C', 1, 1, PhaseC FROM AmplifierChecks WHERE Iteration = 1;

INSERT INTO IntCodeInputs (AmplifierCode, Iteration, InputNumber, Input)
SELECT 'D', 1, 1, PhaseD FROM AmplifierChecks WHERE Iteration = 1;

INSERT INTO IntCodeInputs (AmplifierCode, Iteration, InputNumber, Input)
SELECT 'E', 1, 1, PhaseE FROM AmplifierChecks WHERE Iteration = 1;

INSERT INTO IntCodeInputs (AmplifierCode, Iteration, InputNumber, Input)
SELECT 'A', 1, 2, 0;