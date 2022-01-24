if ($args)
{
    Write-Host 'Argumente primite:' $args
    $path = $args[0]
    $server=$args[1]
    $database=$args[2]
    $output=$args[3]
    $outputName=$args[4]
}

else
{
    #folder-ul aplicatiei
    $path ="C:\Program Files (x86)\Senior Software\SeniorERP 2013.1 Client"
    $server = "testare03" 
    $database = "Feedback1_20130415_1"
    #tipul output-ului (0=tabel in baza primita ca argument, 1=fisier csv)
    $output=0
    #denumirea fisierului sau a tabelului
    $outputName="SeniorERPClasses"
     
}
$missingClassesOutputName = $outputName + "Missing"
$wrongAssemblyNameClassesOutputName = $outputName + "WrongAssemblyName"
#connection string-ul catre baza
$connectionString="Data Source=$server;Integrated Security=SSPI;Application Name=SeniorERP;Initial Catalog=$database"

$query ="select 
            s.FullClassName,
            a.Nume as Assembly
        from 
            [dbo].[A_Subiecte] s 
                inner join [dbo].[A_Assemblies] a on s.FK_Assembly=a.Assemblies_Id"                

$databaseClasses = invoke-sqlcmd -ServerInstance $server -Database $database -Query $query|sort Assembly, FullClassName 

Set-Location -Path $path

$clientClasses=Get-ChildItem $path -filter "Senior.*.dll"|%{
[System.Reflection.Assembly]::LoadFrom($_.FullName).GetTypes()}|select  @{Name = 'FullClassName'; Expression = {$_.FullName}}, 
               @{Name = 'Assembly'; Expression ={$_.Module.Name}}| 
               sort Assembly, FullClassName 

$problematicClasses = Compare-Object -DifferenceObject $ClientClasses -ReferenceObject $databaseClasses -Property FullClassName, Assembly | 
        ? SideIndicator -eq "<="| 
        select  FullClassName, Assembly| 
        sort  FullClassName, Assembly 

$missingClasses = Compare-Object -DifferenceObject $ClientClasses -ReferenceObject $problematicClasses -Property FullClassName -PassThru | 
        ? SideIndicator -eq "<="| 
        select  FullClassName, Assembly| 
        sort  FullClassName, Assembly 

$wrongAssemblyNameClasses = Compare-Object -DifferenceObject $missingClasses -ReferenceObject $problematicClasses -Property FullClassName -PassThru | 
        ? SideIndicator -eq "<="| 
        select  FullClassName, Assembly| 
        sort  FullClassName, Assembly 
        
       

switch($output)
{
    0
    {
        $csb = new-object System.Data.SqlClient.SqlConnectionStringBuilder($connectionString)
        $sqlConnection = new-object System.Data.SqlClient.SqlConnection 
        $sqlConnection.ConnectionString = $csb.ConnectionString
        $sqlConnection.Open()	
        $command = $sqlConnection.CreateCommand()
        $command.CommandText = "create table $missingClassesOutputName (FullClassName nvarchar(200), Assembly nvarchar(200))
                                create table $wrongAssemblyNameClassesOutputName (FullClassName nvarchar(200), Assembly nvarchar(200))"
        $command.ExecuteNonQuery()|Out-NUll
        $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString 
        $bulkCopy.DestinationTableName = $missingClassesOutputName 
        $dtMissingClasses = New-Object System.Data.DataTable 
        $dtMissingClasses.Columns.Add("FullClassName",[System.String])  | Out-Null
        $dtMissingClasses.Columns.Add("Assembly",[System.String])   | Out-Null
        $missingClasses|%{$dtMissingClasses.LoadDataRow(@($_.FullClassName,$_.Assembly),$true)}|Out-Null    
        $bulkCopy.WriteToServer($dtmissingClasses) 

        $bulkCopy.DestinationTableName = $wrongAssemblyNameClassesOutputName 
        $dtWrongAssemblyNameClasses = New-Object System.Data.DataTable 
        $dtWrongAssemblyNameClasses.Columns.Add("FullClassName",[System.String])  | Out-Null
        $dtWrongAssemblyNameClasses.Columns.Add("Assembly",[System.String])   | Out-Null
        $wrongAssemblyNameClasses|%{$dtWrongAssemblyNameClasses.LoadDataRow(@($_.FullClassName,$_.Assembly),$true)}|Out-Null    
        $bulkCopy.WriteToServer($dtWrongAssemblyNameClasses) 
        $sqlconnection.Close()
    }    

    1
    {
        $missingClasses|export-csv ( (Split-Path -Parent $MyInvocation.MyCommand.Path).ToString()+"\$missingClassesOutputName.csv") -NoTypeInformation
        $wrongAssemblyNameClasses|export-csv ( (Split-Path -Parent $MyInvocation.MyCommand.Path).ToString()+"\$wrongAssemblyNameClassesOutputName.csv") -NoTypeInformation
    }

    default
    {
        Write-Host "Tipul output-ului poate fi doar 0 sau 1"
    }
}
