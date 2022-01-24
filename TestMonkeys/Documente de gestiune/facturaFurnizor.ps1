add-type -AssemblyName System.Windows.Forms
. .\LoadPartners.ps1
. .\LoadProducts.ps1
$documentsNumber=5
$maxNumberDetails=5 #numar maxim de detalii 
$maxQuantity=3 #cantitate maxima permisa pe detalii 
$top='fftest'
$firstNumber=1
start-sleep -Milliseconds 5000
for ($i=1; $i-le $documentsNumber; $i++)
{
    [System.Windows.Forms.SendKeys]::SendWait("^n")
    $p=$partnersList|Get-Random    
    [System.Windows.Forms.SendKeys]::SendWait("$p")
    [System.Windows.Forms.SendKeys]::SendWait("{F9}")
    start-sleep -Milliseconds 2000
    $t=$top+'/'+($i+$firstNumber - 1)
    [System.Windows.Forms.SendKeys]::SendWait("$t")
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    for ($j=1; $j-le (get-random -Minimum 1 -maximum ($maxNumberDetails+1)); $j++)    
    {
       $pr=$productsList|get-random
       [System.Windows.Forms.SendKeys]::SendWait($pr)
       [System.Windows.Forms.SendKeys]::SendWait("{F9}")
       [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
       $q=get-random -Minimum 1 -Maximum ($maxQuantity+1)
       [System.Windows.Forms.SendKeys]::SendWait("$q")
       [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
       [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
       [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
       start-sleep -Milliseconds 2000
    }
    [System.Windows.Forms.SendKeys]::SendWait("^s")    
}