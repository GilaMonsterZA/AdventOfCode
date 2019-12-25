DROP TABLE IF EXISTS ShipPanels;
DROP TABLE IF EXISTS Painting;

CREATE TABLE ShipPanels (
	PanelX INT,
	PanelY INT,
	Colour BIT
);

CREATE TABLE Painting (
	X INT,
	Y INT,
	ColourBefore BIT,
	ColourAfter BIT
);
GO

CREATE OR ALTER PROCEDURE PaintRobot
AS

DECLARE @Facing INT = 0,
	@IntCodeInputNumber INT = 1,
	@IntCodeOutputNumber INT = 1,
	@Rotation INT = 0,
	@Paintcolour INT = 0,
	@LocationX INT = 0,
	@LocationY INT = 0,
	@HullColour INT;

	-- Part 1 first panel starts as black
	--SET @HullColour = 0; 

	-- Part 2, first panel starts as white
		SET @HullColour = 1; 

	INSERT INTO IntCodeInputs (InputNumber, Input)
	VALUES (@IntCodeInputNumber, @HullColour)

	SET @IntCodeInputNumber += 1;

	WHILE (1=1)
		BEGIN

			WHILE NOT EXISTS (SELECT Output from IntCodeOutputs WHERE OutputNumber = @IntCodeOutputNumber)
				BEGIN
					PRINT 'Waiting for computer ' + cast(@IntCodeOutputNumber as Varchar(4))
					WAITFOR DELAY '00:00:01'
				END
			
			SELECT @Paintcolour = Output FROM dbo.IntCodeOutputs
				WHERE OutputNumber = @IntCodeOutputNumber

			IF (@Paintcolour = -1)
				BREAK;

			SET @IntCodeOutputNumber += 1;


			print 'painting ' + cast(@Paintcolour as varchar(4)) + ' at ' + cast(@LocationX as varchar(4)) + ',' + cast(@LocationY as varchar(4))

			IF EXISTS (SELECT 1 FROM ShipPanels WHERE PanelX = @LocationX AND PanelY = @LocationY)
				UPDATE dbo.ShipPanels
					SET Colour = @Paintcolour
					WHERE PanelX = @LocationX AND PanelY = @LocationY
			ELSE
				BEGIN
					INSERT INTO dbo.ShipPanels (PanelX, PanelY, Colour)
						VALUES (@LocationX, @LocationY, @Paintcolour);

				end

			insert into Painting
			values (@LocationX, @LocationY, @HullColour, @Paintcolour)

			WHILE NOT EXISTS (SELECT Output from IntCodeOutputs WHERE OutputNumber = @IntCodeOutputNumber)
			BEGIN
				PRINT 'Waiting for computer'
				WAITFOR DELAY '00:00:01'
			END
			
			SELECT @Rotation = Output FROM dbo.IntCodeOutputs
				WHERE OutputNumber = @IntCodeOutputNumber
				
			SET @IntCodeOutputNumber += 1;

			-- Rotate robot
			
			IF @Rotation = 0   -- rotate left
				SET @Facing = CASE @Facing
								WHEN 0 THEN 270
								WHEN 90 THEN 0
								WHEN 180 THEN 90
								WHEN 270 THEN 180
							  END
			ELSE  -- rotate right
				SET @Facing = CASE @Facing
								WHEN 0 THEN 90
								WHEN 90 THEN 180
								WHEN 180 THEN 270
								WHEN 270 THEN 0
							  END
			
			-- move robot
			SET @LocationX = @LocationX + CASE @Facing
								WHEN 0 THEN 0
								WHEN 90 THEN 1
								WHEN 180 THEN 0
								WHEN 270 THEN -1
							  END

			SET @LocationY = @LocationY + CASE @Facing
								WHEN 0 THEN -1
								WHEN 90 THEN 0
								WHEN 180 THEN 1
								WHEN 270 THEN 0
							  END
			
			-- input colour to intcode	
			SET @HullColour = NULL;
			SELECT  @HullColour = Colour
				FROM ShipPanels
				WHERE PanelX = @LocationX AND PanelY = @LocationY

			if @HullColour IS NULL
				set @HullColour = 0;

			INSERT INTO IntCodeInputs (InputNumber, Input)
			VALUES (@IntCodeInputNumber, @HullColour)

			SET @IntCodeInputNumber += 1;

		END
GO