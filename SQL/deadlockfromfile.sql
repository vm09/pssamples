CREATE TABLE #errorlog (
            LogDate DATETIME 
            , ProcessInfo VARCHAR(100)
            , [Text] VARCHAR(MAX)
            );
DECLARE @tag VARCHAR (MAX) , @path VARCHAR(MAX);
INSERT INTO #errorlog EXEC sp_readerrorlog;
SELECT @tag = text
FROM #errorlog 
WHERE [Text] LIKE 'Logging%MSSQL/Log%';
DROP TABLE #errorlog;
SET @path = SUBSTRING(@tag, 38, CHARINDEX('MSSQL/Log', @tag) - 29);
select @path
SELECT 
  CONVERT(xml, event_data).query('/event/data/value/child::*') AS DeadlockReport,
  CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]', 'datetime') 
  AS Execution_Time
FROM sys.fn_xe_file_target_read_file(@path + '/system_health*.xel', NULL, NULL, NULL)
WHERE OBJECT_NAME like 'xml_deadlock_report'
and cast(timestamp_utc as datetime2(7)) > dateadd(day, -5, GETUTCDATE())
