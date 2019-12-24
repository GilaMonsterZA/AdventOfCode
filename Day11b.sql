DROP TABLE IF EXISTS ShipPanels;

CREATE TABLE ShipPanels (
	PanelX INT,
	PanelY INT,
	Colour BIT
);
GO

INSERT INTO dbo.ShipPanels (PanelX, PanelY, Colour)
VALUES (0, 0, 0)
GO


CREATE OR ALTER PROCEDURE PaintRobot
AS

DECLARE @Facing INT = 0,
	@Input INT = 1,
	@Rotation INT = 0,
	@Paintcolour INT = 0,
	@LocationX INT = 0,
	@LocationY INT = 0;

	WHILE @Paintcolour != -1
		BEGIN
        
			WHILE NOT EXISTS (SELECT Output from IntCodeOutputs WHERE OutputNumber = @Input)
			BEGIN
				PRINT 'Waiting for computer'
				WAITFOR DELAY '00:00:01'
			END
			
			SELECT @Paintcolour = Output FROM dbo.IntCodeOutputs
				WHERE OutputNumber = @Input

			UPDATE dbo.ShipPanels
				SET Colour = @Paintcolour
				WHERE PanelX = @LocationX AND PanelY = @LocationY

			IF @@ROWCOUNT = 0
				INSERT INTO dbo.ShipPanels (PanelX, PanelY, Colour)
					VALUES (@Paintcolour, @LocationX, @LocationY)

			SET @Input += 1;

			WHILE NOT EXISTS (SELECT Output from IntCodeOutputs WHERE OutputNumber = @Input)
			BEGIN
				PRINT 'Waiting for computer'
				WAITFOR DELAY '00:00:01'
			END
			
			SELECT @Rotation = Output FROM dbo.IntCodeOutputs
				WHERE OutputNumber = @Input		
				
			-- Rotate robot
			
			
			-- move robot
			
			-- input colour to intcode	

			SET @Input += 1;

		END
        

GO