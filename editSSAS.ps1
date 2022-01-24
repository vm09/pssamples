$db = "BB"
CD "SQLSERVER:\SQLAS\localhost\default\databases\$db\cubes\"
$cube = (Get-Item "controlling")
$cube.Dimensions["CostCenter"].Attributes["Departament"].AttributeHierarchyVisible = $true
$cube.Update()
$cube = (Get-Item "controllingbudget")
$cube.Dimensions["CostCenter"].Attributes["Departament"].AttributeHierarchyVisible = $true
$cube.Update()
$cube = (Get-Item "senioranalytics")
$cube.Dimensions["CostCenter"].Attributes["Departament"].AttributeHierarchyVisible = $true
$cube.Update() 
