PARAM(
    [switch]$Mandatory
)

if((Test-Path "C:\Tools\Perl\bin"))
{
    $env:PATH += ";C:\Tools\Perl\bin"
    Write-Host "Perl found at C:\Tools\Perl\bin"
}
elseif((Test-Path "C:\Tools\Perl\perl\bin"))
{
    $env:PATH += ";C:\Tools\Perl\perl\bin"
    Write-Host "Perl found at C:\Tools\Perl\perl\bin"
}
elseif($Mandatory)
{
    throw( "No Perl found" )
}
else
{
    Write-Host "No Perl found";
}