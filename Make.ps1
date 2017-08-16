PARAM(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$VisualStudio,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$Architecture,
    [Parameter(Mandatory=$true, Position=3)]
    [string]$Version,
    [Parameter(Mandatory=$false, Position=4)]
    [bool]$Static = $false,
    [Parameter(Mandatory=$false, Position=5)]
    [bool]$DebugBuild = $false,
    [Parameter(Mandatory=$false, Position=6)]
    [string]$AdditionalConfig = "",

    [switch]$DoPackage,
    [switch]$NoClean,
    [string]$OverrideOutput
)

Function OpenSslVersionFromNumber
{
    PARAM(
        [string]$Version
    )
    $oVersion  = New-Object System.Version("Version")
    $sVersion = $oVersion.Major + "." + $oVersion.Minor + "." + $oVersion.MajorRevision
    swith($oVersion.MinorRevision)
    {
        0: {$sVersion += "a"}
        1: {$sVersion += "b"}
        2: {$sVersion += "c"}
        3: {$sVersion += "d"}
        4: {$sVersion += "e"}
        5: {$sVersion += "f"}
        6: {$sVersion += "g"}
        7: {$sVersion += "h"}
        8: {$sVersion += "i"}
        9: {$sVersion += "j"}
    }
}

$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName
$OutputName     = "openssl-$Version-${VisualStudio}-${Architecture}"
$OpensslDir     = "openssl-$PSScriptRoot\$Version"
if([string]::IsNullOrEmpty($OutputOverride))
{
    $Output         = "$CurrentDir\$OutputName"
    if($Static)
    {
        $Output += "_static"
        $OutputName += "_static"
    }

    if($DebugBuild)
    {
        $Output += "_debug"
        $OutputName += "_debug"
    }
}
else
{
    $Output     = $OverrideOutput
}

cd $PSScriptRoot


Try
{
    if(-not (Test-Path $OpensslDir))
    {
        .\Openssl-Get.ps1 -Version $Version -Target $OpensslDir
    }
    else
    {
        .\Openssl-Clean.ps1 $OpensslDir
    }
    .\Common\VisualStudio-GetEnv.ps1 $VisualStudio $Architecture
    .\Openssl-Build.ps1 $OpensslDir $Output $Static $DebugBuild $AdditionalConfig
    if($DoPackage)
    {
        .\Common\Zip.ps1 -OutputFile "$CurrentDir\$OutputName.zip" -Single $Output
    }
    Add-Content "$CurrentDir\Build.log" "Success: $OutputName"
}
Catch
{
    Add-Content "$CurrentDir\Build.log" "Failed: $OutputName"
}
Finally
{
    cd $PSScriptRoot
    # Always Endup visual studio
    .\Common\VisualStudio-PostBuild.ps1
}
