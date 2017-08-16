PARAM(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Target,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$Version = ""

)

Function OpenSslVersionToTag
{
    PARAM(
        [string]$Version
    )
    $oVersion  = New-Object System.Version($Version)
    $sVersion = "OpenSSL_" + $oVersion.Major + "_" + $oVersion.Minor + "_" + $oVersion.MajorRevision
    switch($oVersion.MinorRevision)
    {
        "0" {$sVersion += "a"; break}
        "1" {$sVersion += "b"; break}
        "2" {$sVersion += "c"; break}
        "3" {$sVersion += "d"; break}
        "4" {$sVersion += "e"; break}
        "5" {$sVersion += "f"; break}
        "6" {$sVersion += "g"; break}
        "7" {$sVersion += "h"; break}
        "8" {$sVersion += "i"; break}
        "9" {$sVersion += "j"; break}
    }
    return $sVersion
}

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)
$Tag = OpenSslVersionToTag $Version

$cmd = "git clone --branch $Tag  https://github.com/openssl/openssl.git `"$Target`""
cmd.exe /C $cmd
if($LASTEXITCODE -ne 0)
{
    throw "Cloning Openssl failed: $cmd"
}

cd $CurrentDir