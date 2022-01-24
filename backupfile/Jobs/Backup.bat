@echo off
SETLOCAL EnableDelayedExpansion
SET backupLocation="D:\SeniorCPM\backup\"
SET boardDatabase="Macro"
SET boardUserName="Administrator"
SET boardPassword="P@ssword"
SET	boardServerHost="localhost:9700"
SET backupProcedureName="[Backup] Backup"
SET boardLocation="C:\Board\"
SET boardServerInstallPath="C:\Program Files\Board\Board Server\"

SET curdir=%cd%
CD %boardServerInstallPath%"Tools"
BoardProcedureLauncher.exe /host %boardServerHost% /username %boardUserName% /password %boardPassword% /Procedure %backupProcedureName% /DataBase %boardDatabase%
XCOPY %boardLocation%"Job" %backupLocation%"Temp\job\"
XCOPY %boardLocation%"Capsules" %backupLocation%"\Temp\Capsules\"
CD %curdir%
FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET backupTime=%%A
%boardLocation%Job\7za.exe a -tzip %backupLocation%"\automatic\backup_"%backupTime%".zip" %backupLocation%"Temp\*"
rmdir /s /q %backupLocation%"Temp"

