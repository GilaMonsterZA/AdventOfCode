SET NOCOUNT ON;

DROP TABLE IF EXISTS Moons;
CREATE TABLE Moons (
	SimulationID bigint identity,
	TimeStep int,
	MoonNumber int,
	PositionX int,
	PositionY int,
	PositionZ int,
	VelocityX int default 0,
	VelocityY int default 0,
	VelocityZ int default 0
);

create clustered index idx_Moons_Time on Moons (TimeStep, MoonNumber)

INSERT INTO Moons (TimeStep, MoonNumber, PositionX, PositionY, PositionZ)
VALUES 
----<x=-1, y=0, z=2>
----<x=2, y=-10, z=-7>
----<x=4, y=-8, z=8>
----<x=3, y=5, z=-1>
--(0,1,-1,0,2),
--(0,2,2,-10,-7),
--(0,3,4,-8,8),
--(0,4,3,5,-1)
/*
<x=-13, y=14, z=-7>
<x=-18, y=9, z=0>
<x=0, y=-3, z=-3>
<x=-15, y=3, z=-13>
*/
(0,1,-13,14,-7),
(0,2,-18,9,0),
(0,3,0,-3,-3),
(0,4,-15,3,-13)


declare @EndSimulation int = 1000,
	@CurrentTimestep int = 1,
	@MatchingPositions tinyint,
	@PeriodX int,
	@PeriodY int,
	@PeriodZ int;


while (1=1)
	begin

		with MoonPairs as (
		select m1.TimeStep, m1.MoonNumber, m1.PositionX as m1X, m1.PositionY as m1Y, m1.PositionZ as m1Z, m2.PositionX as m2X, m2.PositionY as m2Y, m2.PositionZ as m2Z,
			m1.VelocityX, m1.VelocityY, m2.VelocityZ
			from Moons m1 inner join Moons m2 on m1.TimeStep = m2.TimeStep
		where m1.MoonNumber != m2.MoonNumber and m1.TimeStep = @CurrentTimestep-1
		)
		insert into Moons (TimeStep, MoonNumber, PositionX, PositionY, PositionZ, VelocityX, VelocityY, VelocityZ)
		select Moons.TimeStep + 1, Moons.MoonNumber, 
			PositionX + VelocityX + DeltaVX as NewPositionX,
			PositionY + VelocityY + DeltaVY as NewPositionY,
			PositionZ + VelocityZ + DeltaVZ as NewPositionZ,
			VelocityX + DeltaVX as NewVelocityX,
			VelocityY + DeltaVY as NewVelocityY,
			VelocityZ + DeltaVZ as NewVelocityZ
		from Moons inner join (
		select TimeStep, MoonNumber,
			sum(case when m1X > m2X then -1 when m1X < m2X then 1 else 0 end) as DeltaVX,
			sum(case when m1Y > m2Y then -1 when m1Y < m2Y then 1 else 0 end) as DeltaVY,
			sum(case when m1Z > m2Z then -1 when m1Z < m2Z then 1 else 0 end) as DeltaVZ
		from MoonPairs
		Group by TimeStep, MoonNumber
		) AggregatedVelocity on Moons.TimeStep = AggregatedVelocity.TimeStep and Moons.MoonNumber = AggregatedVelocity.MoonNumber

		if (@CurrentTimestep = @EndSimulation)
			-- answer to part 1
			select sum((abs(PositionX) + abs(PositionY) + abs(PositionZ)) * (abs(VelocityX) + abs(VelocityY) + abs(VelocityZ))) 
			from Moons
			where TimeStep = @CurrentTimestep

		-- calculate the resonance of the moons in each dimension
		if @PeriodX IS NULL AND (select count(*) from Moons mCurrent inner join Moons mFirst on mCurrent.MoonNumber = mFirst.MoonNumber
				where mCurrent.TimeStep = @CurrentTimestep and mFirst.TimeStep = 0
					and mCurrent.PositionX = mFirst.PositionX and mCurrent.VelocityX = mFirst.VelocityX
			) = 4
			set @PeriodX = @CurrentTimestep

		if @PeriodY IS NULL AND (select count(*) from Moons mCurrent inner join Moons mFirst on mCurrent.MoonNumber = mFirst.MoonNumber
				where mCurrent.TimeStep = @CurrentTimestep and mFirst.TimeStep = 0
					and mCurrent.PositionY = mFirst.PositionY and mCurrent.VelocityY = mFirst.VelocityY
			) = 4
			set @PeriodY = @CurrentTimestep

		if @PeriodZ IS NULL AND (select count(*) from Moons mCurrent inner join Moons mFirst on mCurrent.MoonNumber = mFirst.MoonNumber
				where mCurrent.TimeStep = @CurrentTimestep and mFirst.TimeStep = 0
					and mCurrent.PositionZ = mFirst.PositionZ and mCurrent.VelocityZ = mFirst.VelocityZ
			) = 4
			set @PeriodZ = @CurrentTimestep

		if @PeriodX is not null and @PeriodY is not null and @PeriodZ is not null
			break;

		set @CurrentTimestep += 1;
	end

select @PeriodX, @PeriodY, @PeriodZ

---231614	193052	102356
-- used LCM calculator at https://www.calculator.net/lcm-calculator.html




-- hint from the Reddit solutions thread https://www.reddit.com/r/adventofcode/comments/e9j0ve/2019_day_12_solutions/
/**
 * This was a tough one. Not sure I would have been able to
 * figure it out on my own; the trick is fairly subtle.
 * 
 * The idea is that, the planets are periodic _on a single dimension_.
 * So imagine if they only moved in the 'x' dimension. If after n_x ticks
 * all the planets were back at their original position and original
 * velocity, then we'd begin the period again.
 * 
 * Since the planets can only affect each other within
 * a single dimension at a time, what we do is calculate the period
 * for _each_ dimension separately. Once we have those periods,
 * we get the least common multiple (LCM) between them.
 * 
 * So the trick is two-fold:
 * 
 * - Calculate the period for the four planets _within each dimension separately._
 * - Calculate the _LCM_ between those periods.
 */
