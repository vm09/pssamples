# execute function
param(
    $inputFile ="C:\Users\vasile minea\Desktop\temp\psexcel\BHE_Q2_Q3.zip",
    $outputFolder ="",
    $buildNumber ="2010.11.2"
    )
function extractFile(){
    param($inputFile)
    $zipFile = ((Get-Item $inputFile).DirectoryName+"\"+(Get-Item $inputFile).BaseName+".zip" )
    Move-Item $inputFile -Destination $zipFile
    Expand-Archive $zipFile -DestinationPath ((Get-Item $zipFile).DirectoryName+"\"+(Get-Item $zipFile).BaseName)
}
function execute{
    if ($inputFile -eq ""){ return }
    if ($outputFolder -eq ""){ $outputFolder = (Get-Item $inputFile).DirectoryName+"\"+(Get-Item $inputFile).BaseName}
    #remove output if exists
    if (Test-Path $outputFolder){Remove-Item $outputFolder -Recurse}
    #extract archive
    Expand-Archive -LiteralPath $inputFile -DestinationPath $outputFolder
    #add subfolder
    $customGroupFolder = New-Item -path $outputFolder -name "CustomGroup" -ItemType "directory"
    $buildFolder = New-Item -path $customGroupFolder -name $buildNumber -ItemType "directory"
    $ixbrlFolder = New-Item -path $buildFolder -name "ixbrl" -ItemType "directory"
    #copy only
    #Copy-Item $outputFolder"\*.gif" $ixbrlFolder    
    #move
    Move-Item $outputFolder"\*.gif" $ixbrlFolder
    Move-Item $outputFolder"\Support Files\ItemBookmarkMap.xml" $ixbrlFolder  
    
    #iterate and extract all *.cdmmetadata
    Get-ChildItem $outputFolder"\Support Files\*.cdmmetadata" | %{extractFile $_}
    
    extractFile $outputFolder"\Support Files\MainDocument.docx"
}

execute


