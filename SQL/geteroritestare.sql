declare @exceptionMessage nvarchar(max) =  'The wait operation timed out'
select  'exec sp_executesql N''select ''''select * from ['+name+'].dbo.Exceptions where Id between '''' + cast(Id -2 as varchar) +'''' and '''' +cast(Id +2 as varchar) as OtherExceptions,'''''+name+''''' as Name,* from ['+name+'].dbo.Exceptions where Message = '''''+@exceptionMessage+''''' '''
from sys.databases

