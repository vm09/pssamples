#ERP internal version (always use 3 numbers like 2.x.y)
$erpInternalVersion ='2.18.0'  

$filesParentFolder = '\\hv04\kituri seniorerp\Kituri livrate\Versiuni SeniorERP'
$destinationServer='sstestare02'

$splitVersion = $erpInternalVersion.Split('.');
$majorVersion = $splitVersion[0] + '.' +$splitVersion[1];
Write-Host "Major version: $majorVersion."

$filesLocation = $filesParentFolder + "\$majorVersion" + "\$erpInternalVersion"
Write-Host "Files will be copied from $filesLocation."

$commercialVersion = Get-ChildItem "$filesLocation\Client and Server extracted files" | where {$_.PSIsContainer -eq $true -and $_.Name -like "SeniorERP * Client" }
$commercialVersion = $commercialVersion = $commercialVersion.Name.Split()[1]
Write-Host "Commercial version: $commercialVersion."

$erpInternalVersionForDeploy = $erpInternalVersion.Replace(".","_");
"ERP internal version for deploy: $erpInternalVersionForDeploy."

$username = [Environment]::UserName
$credentials = Get-Credential -Credential "senior\$username"

$commandsBlock =  
{
    param($commercialVersion, $majorversion, $erpinternalversionfordeploy)

    $applicationsName = "SeniorERP $commercialVersion"    
    $iisVersion = Get-ItemProperty "HKLM:\software\microsoft\InetStp";
        if ($iisVersion.MajorVersion -eq 7)
        {
            if ($iisVersion.MinorVersion -ge 5)
            {
                Import-Module WebAdministration;
            }          
            else
            {
                if (-not (Get-PSSnapIn | Where {$_.Name -eq "WebAdministration";}))
                {
                    Add-PSSnapIn WebAdministration;
                }
            }
        }

    #backup IIS Configuration
    $timestamp = Get-Date -UFormat "%Y-%m-%d-%H-%M-%S"   
    Write-Host "Backing up IIS configuration to c:\windows\system32\inetsvr\backup\Before$erpInternalVersionForDeploy - $timestamp"
    Backup-WebConfiguration -Name "Before$erpInternalVersionForDeploy - $timestamp" |Out-Null
    
    #test if application pool exists 
    if (-Not(Test-Path "IIS:\AppPools\$applicationsName")) 
    { 
        Write-Host "Application pool $applicationsName does not exists. It will be created."
        New-WebAppPool -Name $applicationsName |Out-Null

        #set identity = NetworkService
        Set-ItemProperty -Path "IIS:\AppPools\$applicationsName" -Name processmodel.identityType -Value 2

        #set .NET Framework version = v4.0
        Set-ItemProperty -Path "IIS:\AppPools\$applicationsName" -Name managedRuntimeVersion -Value v4.0

        #stop application pool
        $appPoolState = Get-WebAppPoolState -Name $applicationsName
        if($appPoolState.Value -eq "Started")
        {
            Stop-WebAppPool -Name $applicationsName 
        }
    }
    else
    {
        Write-Host "Application pool $applicationsName exists."
    }

    #test if virtual directory exists
    if(-Not(Test-Path "IIS:\Sites\Default Web Site\$applicationsName"))
    {
        Write-Host "Virtual directory $applicationsName does not exists. It will be created."
        New-WebVirtualDirectory -Site 'Default Web Site' -Name "$applicationsName" -PhysicalPath "c:\Senior\versiuni kits\SeniorERP$majorversion" |Out-Null
    }
    else 
    {
        Write-Host "Virtual directory $applicationsName exists."
    }

    #add web application
    New-WebApplication -Site "Default Web Site\$applicationsName" -Name "SeniorERP$erpinternalVersionForDeploy" -PhysicalPath "C:\Senior\Versiuni kits\SeniorERP$majorVersion\SeniorERP$erpinternalversionfordeploy" -ApplicationPool $applicationsName |Out-Null

    Set-ItemProperty "IIS:\Sites\Default Web Site\$applicationsName\SeniorERP$erpinternalVersionForDeploy" -name EnabledProtocols -Value "http,net.pipe"    
}

#functions
function CreateDatabase ($databaseName, $serverName, $scriptSourceFolder, $scriptDestinationFolder)
{    
    Write-Host "Reading create database script contents from $scriptSourceFolder\Database_Create.sql..."
    $scriptContent = Get-Content "$scriptSourceFolder\Database_Create.sql";    

    Write-Host "Updating script content with database name $databaseName..."
    $scriptContent = $scriptContent.Replace(":setvar DatabaseName ""Database""",":setvar DatabaseName ""$databaseName""");    
    
	Write-Host "Writing modified script to $scriptDestinationFolder\Database_Create.sql..."
	$streamWriter = [System.IO.StreamWriter] "$scriptDestinationFolder\Database_Create.sql"
	foreach($line in $scriptContent)
	{		
		$streamWriter.WriteLine($line)
	} 
    $streamWriter.Close();

    Start-Sleep -Seconds 2

    Write-Host "Creating database $databaseName..."
    sqlcmd -S $serverName -i "$scriptDestinationFolder\Database_Create.sql" |Out-Null 

    Remove-Item "$scriptDestinationFolder\Database_Create.sql";
}

function InsertInitialData ($databaseName, $serverName, $scriptsSourceFolder)
{
    Write-Host "Running scripts for inserting initial data on database $databaseName on server $serverName..."
    
	$sqlScripts = Get-ChildItem  "$scriptsSourceFolder\*.sql" | sort		
	
	foreach($script in $sqlScripts) 
	{		    
		sqlcmd.exe -S $serverName -E -d "$databaseName" -i $script -b -I |Out-Null
		if($? -eq $false)
		{			
		    Write-Host 'An error has occured durring the execution of a script.'
			return	
		}
	}	
    
    $cubeDefinitionFile = "$scriptsSourceFolder\SeniorBI.xmla"
    & "$scriptsSourceFolder\InsertAnalysisDeploymentScript.ps1" $serverName $databaseName $cubeDefinitionFile |Out-Null
    
    #inserting data in admin.licenses and d_date_societate
    $currentYear = get-date -Format yyyy;
    $query= "IF NOT EXISTS (SELECT TOP 1 1 FROM [admin].[Licenses])
            BEGIN 
				UPDATE dbo.D_Persoane_Juridice 
				SET Cod_Fiscal = '2115198' 
				WHERE Persoane_Juridice_Id = 1

				INSERT [admin].[Licenses] VALUES ('$databaseName','<Licenta><Client Nume=""""Development"""" CodFiscal=""""2115198"""" NumarUtilizatori=""""100"""" /><Semnatura>ThZ7aKtFIcC9puhPRtN2mU76yc0N2+jf6VbJv18c52SOHwQsavpNLg==</Semnatura></Licenta>')
            END
            IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[D_Date_Societate])
            BEGIN
                INSERT [dbo].[D_Date_Societate](Denumire, Persoane_Juridice_Id,An, Nr_Angajati, Parteneri_Ramuri_Industriale_Id, TvaLaPlata) values ('Societate', 1, $currentYear, 100, 1, 0)
            END"                 
    sqlcmd -S $serverName -d $databaseName -Q $query|Out-Null

    Write-Host 'Finished executing sql scripts for inserting initial data.'	
}

#copy files
Write-Host "Copying files from $filesparentfolder\$majorversion\$erpinternalversion\client and server extracted files\seniorerp $commercialVersion Server to \\$destinationServer\c$\senior\versiuni kits\seniorerp$majorversion\SeniorERP$erpinternalversionfordeploy...";
copy-item -path "$filesparentfolder\$majorversion\$erpinternalversion\client and server extracted files\seniorerp $commercialVersion Server\" -destination "\\$destinationServer\c$\senior\versiuni kits\seniorerp$majorversion\SeniorERP$erpinternalversionfordeploy"  -recurse |Out-Null
new-item "\\$destinationServer\c$\senior\versiuni kits\seniorerp$majorversion\seniorerp$erpinternalversionfordeploy\Instalare client si server" -itemtype directory |Out-Null
copy-item -path "$filesparentfolder\$majorversion\$erpinternalversion\*.exe" -destination "\\$destinationServer\c$\senior\versiuni kits\seniorerp$majorversion\seniorerp$erpinternalversionfordeploy\instalare client si server" |Out-Null
copy-item -path "$filesparentfolder\$majorversion\$erpinternalversion\*.msi" -destination "\\$destinationServer\c$\senior\versiuni kits\seniorerp$majorversion\seniorerp$erpinternalversionfordeploy\instalare client si server" |Out-Null


#cofigure IIS
$session= New-PSSession -ComputerName $destinationServer -Credential $credentials 

Write-Host "Adding web application..."
Invoke-Command -Session $session -Scriptblock $commandsBlock -ArgumentList $commercialVersion, $majorversion, $erpinternalversionfordeploy
 
Remove-PSSession -session $session


#create and configure databases
CreateDatabase -serverName $destinationServer -databaseName "TestareInterna_FIFO$erpInternalVersionForDeploy" -scriptSourceFolder "$filesparentfolder\$majorversion\$erpinternalversion\SeniorERP $commercialVersion Sql Scripts" -scriptDestinationFolder "\\$destinationServer\c$\senior\versiuni kits\seniorerp$majorversion\seniorerp$erpinternalversionfordeploy\instalare client si server"
InsertInitialData -databaseName "TestareInterna_FIFO$erpInternalVersionForDeploy" -serverName $destinationServer -scriptsSourceFolder "$filesparentfolder\$majorversion\$erpinternalversion\SeniorERP $commercialVersion Sql Scripts\InitialData"

CreateDatabase -serverName $destinationServer -databaseName "TestareInterna_CMP$erpInternalVersionForDeploy" -scriptSourceFolder "$filesparentfolder\$majorversion\$erpinternalversion\SeniorERP $commercialVersion Sql Scripts" -scriptDestinationFolder "\\$destinationServer\c$\senior\versiuni kits\seniorerp$majorversion\seniorerp$erpinternalversionfordeploy\instalare client si server"
InsertInitialData -databaseName "TestareInterna_CMP$erpInternalVersionForDeploy" -serverName $destinationServer -scriptsSourceFolder "$filesparentfolder\$majorversion\$erpinternalversion\SeniorERP $commercialVersion Sql Scripts\InitialData"

$queryText = "IF  EXISTS (SELECT TOP 1 1 FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[GeneralConfigurationChanges]'))
BEGIN
	ALTER TABLE [dbo].[A_Configurari_Generale] DISABLE TRIGGER [GeneralConfigurationChanges]
END
GO
 UPDATE [dbo].[A_Configurari_Generale] set Valoare = 1 where Configurari_Generale_Id = 6
 UPDATE [dbo].[A_Configurari_Generale] set Valoare = 0 where Configurari_Generale_Id = 21  
 UPDATE [dbo].[A_Configurari_Generale] set Valoare = 0 where Configurari_Generale_Id = 43
 GO
IF  EXISTS (SELECT TOP 1 1 FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[GeneralConfigurationChanges]'))
BEGIN
	ALTER TABLE [dbo].[A_Configurari_Generale] ENABLE TRIGGER [GeneralConfigurationChanges]
END
GO"

sqlcmd.exe -S $destinationServer -d "TestareInterna_CMP$erpInternalVersionForDeploy" -Q $queryText |Out-Null

