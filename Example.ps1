﻿###############################################################################
# Example to build many different types of one Version
###############################################################################

$Version       = "1.1.0.5"
$VisualStudios = @("2019") # "2015", "2017",
$Architectures = @("x64", "x86")
$Static        = $false
$StaticRuntime = $false
$DebugToo      = $true
$DoPackage     = $true

Set-Content "Build.log" ""

foreach($VisualStudio in $VisualStudios)
{
    foreach($Architecture in $Architectures)
    {
        .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $Static -StaticRuntime $StaticRuntime -DoPackage $DoPackage
        if($LASTEXITCODE -eq 0)
        {
            Add-Content "Build.log" "Succeeded"
        }
        else
        {
            Add-Content "Build.log" "Failed"
        }
    }
}