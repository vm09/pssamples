select 
	DATEPART(HH, l.StartTime) Hour, sum(l.duration)/1000/60 Minutes,  count(1) as Apeluri, min(StartTime) MinStartTime, max(StartTime) MaxStartTime
from 
	logs.WcfExecutionTime l
where 
	l.StartTime between '2012-11-27 16:00' and '2012-11-28 17:00'
group by
	DATEPART(HH, l.StartTime)
select *, AVG(duration) over(partition by MethodName) AvgByMethodName, count(1) over(partition by MethodName) NumberOfExecution from  logs.WcfExecutionTime
where StartTime > '2012-12-06'
--and MethodName ='ICommercialDocumentsService/SaveCommercialDocument'
order by Duration desc