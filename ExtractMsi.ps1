$targetdir = "e:\teste\"
msiexec /a $targetdir"SeniorERP Services x64.msi" -qb targetdir=$targetdir"Services"
msiexec /a $targetdir"Senior.ClientSetup.msi" -qb targetdir=$targetdir"Client"
msiexec /a $targetdir"SeniorERPJobScheduler_x64.msi" -qb targetdir=$targetdir"JobScheduler"
