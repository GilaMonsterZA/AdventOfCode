USE [tempdb]
GO
/****** Object:  StoredProcedure [dbo].[TestIntMachine]    Script Date: 2019/12/04 11:50:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[TestIntMachine] (@Input1 int, @input2 int, @Result int OUTPUT)
as

declare @input varchar(2000) =
--	'1,1,1,4,99,5,6,0,99'
--	'1,9,10,3,2,3,11,0,99,30,40,50'
	'1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,6,1,19,1,19,5,23,2,9,23,27,1,5,27,31,1,5,31,35,1,35,13,39,1,39,9,43,1,5,43,47,1,47,6,51,1,51,13,55,1,55,9,59,1,59,13,63,2,63,13,67,1,67,10,71,1,71,6,75,2,10,75,79,2,10,79,83,1,5,83,87,2,6,87,91,1,91,6,95,1,95,13,99,2,99,13,103,1,103,9,107,1,10,107,111,2,111,13,115,1,10,115,119,1,10,119,123,2,13,123,127,2,6,127,131,1,13,131,135,1,135,2,139,1,139,6,0,99,2,0,14,0'


drop table if exists #opcodes
create table #opcodes (Position int identity (0,1), code int)

insert into #opcodes (code)
select value from string_split(@input, ',')

update #opcodes
	set code = @Input1 where Position = 1;

update #opcodes
	set code = @Input2 where Position = 2;

declare @currentPosition int = 0,
	@CurrentOpCode int = 0

while @CurrentOpCode != 99
	begin
		select @CurrentOpCode = code 
			from #opcodes where Position = @currentPosition

		if @CurrentOpCode = 1
			-- add
			UPDATE #opcodes 
				SET code = (SELECT code FROM #opcodes where Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 1)) + 
						(SELECT code FROM #opcodes where Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 2))
					WHERE Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 3)

		if @CurrentOpCode = 2
			-- multiply
			UPDATE #opcodes 
				SET code = (SELECT code FROM #opcodes where Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 1)) * 
						(SELECT code FROM #opcodes where Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 2))
					WHERE Position = (SELECT code from #OpCodes where Position = @CurrentPosition + 3)

		set @currentPosition = @currentPosition + 4;

	end

SELECT @Result = Code FROM #opcodes where Position = 0;

