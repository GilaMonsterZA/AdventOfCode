DROP TABLE IF EXISTS Orbits;

CREATE TABLE Orbits (
	Parent varCHAR(4),
	Satellite varCHAR(4)
);

-- data split and loaded via Excel

-- answer 1
With OrbitUnroll AS (
	SELECT Parent, Satellite, cast(Parent + ')' + Satellite as varchar(50)) as Path
		from Orbits o 
		--where Parent = 'COM'
	union all
	SELECT o.Parent, o.Satellite, cast(ou.Path + ')' + ou.Satellite as varchar(50)) as Path
		FROM Orbits o inner join OrbitUnroll ou on o.Parent = ou.Satellite
)
SELECT count(*) FROM OrbitUnroll
OPTION (maxrecursion 0);

-- answer 2
With TransferOrbitsYou AS (
	SELECT Parent, Satellite, 0 as Transfers
		from Orbits o 
		where Satellite = 'You'
	union all
	SELECT o.Parent, o.Satellite, Transfers + 1 as Transfers
		FROM Orbits o inner join TransferOrbitsYou ty on ty.Parent = o.Satellite
),
TransferOrbitsSanta AS (
SELECT Parent, Satellite, 0 as Transfers
		from Orbits o 
		where Satellite = 'san'
	union all
	SELECT o.Parent, o.Satellite, Transfers + 1 as Transfers
		FROM Orbits o inner join TransferOrbitsSanta ts on ts.Parent = o.Satellite
)
select top(1) y.Transfers + s.Transfers from TransferOrbitsYou y inner join TransferOrbitsSanta s on y.Parent = s.parent
order by y.Transfers + s.Transfers 
option (maxrecursion 0)