
function Zip($folder, $zipArchive){
    
    [System.Reflection.Assembly]::Load("WindowsBase,Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")

    $ZipPackage=[System.IO.Packaging.ZipPackage]::Open($zipArchive, [System.IO.FileMode]"OpenOrCreate", [System.IO.FileAccess]"ReadWrite")
    $files = gci $folder | select -expand fullName

    ForEach ($file In $files)
    {
       $fileName = [System.IO.Path]::GetFileName($file)
       $uri =  New-Object System.Uri(".\$fileName", [System.UriKind]"Relative")
       $partUri = [System.IO.Packaging.PackUriHelper]::CreatePartUri($uri)
       $part=$ZipPackage.CreatePart($partUri, "text/plain", [System.IO.Packaging.CompressionOption]"Maximum")
       $stream=$part.GetStream()
       $binary = [System.IO.File]::ReadAllBytes($file)
       $stream.Write($binary,0, $binary.LongLength)
       $stream.Close()
    }
    $ZipPackage.Close()
}
Zip -folder "C:\ProgramData\Senior Software\Senior.StateForms.Client\2" -zipArchive "C:\ProgramData\Senior Software\Senior.StateForms.Client\SeniorStateFormsClient.zip"