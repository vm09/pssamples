@echo off
SETLOCAL EnableDelayedExpansion
SET backupLocation="E:\SeniorCPM\backup\"
SET dbBackupLocation=%backupLocation%db

SET boardDatabase="SecomDB"
SET boardUserName="Administrator"
SET boardPassword="P@ssword"
SET boardServerHost="localhost:9900"
SET backupProcedureName="[Backup] Backup"
SET boardLocation="C:\Board\"
SET boardServerInstallPath="C:\Program Files\Board\Board Server\"
SET curdir=%cd%

CD %boardServerInstallPath%Tools
BoardProcedureLauncher.exe /host %boardServerHost% /username %boardUserName% /password %boardPassword% /Procedure %backupProcedureName% /DataBase %boardDatabase%
XCOPY %dbBackupLocation% %backupLocation%Temp /s
XCOPY %boardLocation%Job %backupLocation%Temp\job\ /s
XCOPY %boardLocation%Capsules %backupLocation%\Temp\Capsules\ /s
CD %curdir%
REM USE WMIC IF AVAILABLE OR POWERSHELL
REM FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET backupTime=%%A
FOR /F %%A IN ('POWERSHELL get-date -format "yyyyMMdd_HHmm"') DO @SET backupTime=%%A
%boardLocation%Job\7za.exe a -tzip %backupLocation%"\automatic\backup_%backupTime%.zip" %backupLocation%Temp\*
rmdir /s /q %backupLocation%Temp\
mkdir %backupLocation%Temp

