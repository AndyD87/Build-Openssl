###############################################################################
# Example to build many different types of one Version
###############################################################################

$Version       = "1.1.1.7"# 1.1.1g
$VisualStudios = @("2015","2017", "2019") # 
$Architectures = @("x64", "x86")
$Static        = $false
$StaticRuntime = $true
$DoPackage     = $true

Set-Content "Build.log" ""

$global:oAllEnv = Get-ChildItem Env:

function CleanupEnv
{
    $oCurrentEnv = Get-ChildItem Env:
    foreach($oCurrent in $oCurrentEnv)
    {
        $bFound = $false
        foreach($oAll in $oCurrentEnv)
        {
            if($oAll.Name -eq $oCurrent.NAME)
            {
                $bFound = $true
                break
            }
        }
        if($bFound)
        {
            [System.Environment]::SetEnvironmentVariable($oAll.Name, $oAll.Value)
        }
        else
        {
            Remove-Item ("Env:\" + $oCurrent.Name)
        }
    }
}

function VerifyLastExit()
{
    CleanupEnv
    if($LASTEXITCODE -eq 0)
    {
        Add-Content "Build.log" "Succeeded"
    }
    else
    {
        Add-Content "Build.log" "Failed"
        throw "Build failed"
    }
}

foreach($VisualStudio in $VisualStudios)
{
    foreach($Architecture in $Architectures)
    {   
        .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $true -StaticRuntime $StaticRuntime -DoPackage $DoPackage -DebugBuild $false
        VerifyLastExit
        .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $true -StaticRuntime $StaticRuntime -DoPackage $DoPackage -DebugBuild $true
        VerifyLastExit
        .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $false -StaticRuntime $StaticRuntime -DoPackage $DoPackage -DebugBuild $false
        VerifyLastExit
        .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $false -StaticRuntime $StaticRuntime -DoPackage $DoPackage -DebugBuild $true
        VerifyLastExit
    }
}
