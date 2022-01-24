if (Test-Path 'PartnersList.txt')
{
    $partnersList=gc 'PartnersList.txt'
}
else
{
    $partnersNumber=2 #numar parteneri
    $prefix='client'
    $partnersList=1..$partnersNumber | % {$prefix+$_}
}


