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

Function NumberOpenSslVersion
{
    PARAM(
        [string]$Version
    )
    $sLastChar = $Version.Substring($Version.Length - 1, 1);
    $sVersion = $Version.Substring(0, $Version.Length - 1);
    switch($sLastChar)
    {
        "a" { $sVersion += ".0"; break; }
        "b" { $sVersion += ".1"; break; }
        "c" { $sVersion += ".2"; break; }
        "d" { $sVersion += ".3"; break; }
        "e" { $sVersion += ".4"; break; }
        "f" { $sVersion += ".5"; break; }
        "g" { $sVersion += ".6"; break; }
        "h" { $sVersion += ".7"; break; }
        "i" { $sVersion += ".8"; break; }
        "j" { $sVersion += ".9"; break; }
        default { $sVersion = $Version}
    }
    return $sVersion
}

Function OpenSslVersionFromNumber
{
    PARAM(
        [string]$Version
    )
    $oVersion  = New-Object System.Version("Version")
    $sVersion = $oVersion.Major + "." + $oVersion.Minor + "." + $oVersion.MajorRevision
    swith($oVersion.MinorRevision)
    {
        0: {$sVersion += "a"; break}
        1: {$sVersion += "b"; break}
        2: {$sVersion += "c"; break}
        3: {$sVersion += "d"; break}
        4: {$sVersion += "e"; break}
        5: {$sVersion += "f"; break}
        6: {$sVersion += "g"; break}
        7: {$sVersion += "h"; break}
        8: {$sVersion += "i"; break}
        9: {$sVersion += "j"; break}
    }
}
$Version = NumberOpenSslVersion $Version
$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName
$OutputName     = "openssl-$Version-${VisualStudio}-${Architecture}"
$OpensslDir     = "$PSScriptRoot\openssl-$Version"
if([string]::IsNullOrEmpty($OverrideOutput))
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
