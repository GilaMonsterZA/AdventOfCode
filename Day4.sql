drop table if exists PasswordCharacters

CREATE TABLE PasswordCharacters (
	Password CHAR(6),
	C1 AS cast(Substring(Password,1,1) as Tinyint),
	C2 AS cast(Substring(Password,2,1) as Tinyint),
	C3 AS cast(Substring(Password,3,1) as Tinyint),
	C4 AS cast(Substring(Password,4,1) as Tinyint),
	C5 AS cast(Substring(Password,5,1) as Tinyint),
	C6 AS cast(Substring(Password,6,1) as Tinyint),
	ISValid BIT DEFAULT 1
)

-- range 357253-892942

insert into PasswordCharacters (Password)
SELECT Number 
FROM Numbers
	where Number between 357253 and 892942;

update PasswordCharacters
	set ISValid = 0
	where NOT (C1=C2 OR C2=C3 OR C3=C4 OR C4=C5 OR C5=C6) 
		OR NOT (C2>=C1 AND C3>=C2 AND C4>=C3 AND C5>=C4 and C6>=C5)

-- answer to part 1
SELECT Count(*) FROM PasswordCharacters
WHERE ISValid = 1

select Password, PasswordCharacter, Position 
INTO PasswordCharactersStage2
from 
(SELECT Password, C1, C2, C3, C4, C5, C6
FROM PasswordCharacters
WHERE ISValid = 1) p
UNPIVOT (PasswordCharacter FOR Position IN (C1, C2, C3, C4, C5, C6)) as unpvt

-- rowcount is the answer to part 2
SELECT DISTINCT Password, Count(*)
FROM PasswordCharactersStage2
group by Password, PasswordCharacter
Having COUNT(*) = 2
order by password