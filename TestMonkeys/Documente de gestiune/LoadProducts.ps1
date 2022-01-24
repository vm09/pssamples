if (Test-Path 'ProductsList.txt')
{
    $productsList=gc 'ProductsList.txt'
}
else
{
    $productsNumber=3 #nr articole
    $prefix='articol'
    $productsList=1..$productsNumber | % {$prefix+$_}
}