PARAM(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$OpensslDir,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$OutputTarget,
    [Parameter(Mandatory=$false, Position=3)]
    [bool]$Static = $false,
    [Parameter(Mandatory=$false, Position=4)]
    [bool]$DebugBuild = $false,
    [Parameter(Mandatory=$false, Position=5)]
    [string]$AdditionalConfig = ""
)

$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName

.\Common\Nasm-GetEnv.ps1 -Mandatory
.\Common\Perl-GetEnv.ps1 -Mandatory

cd $OpensslDir

$Cmd = "perl.exe Configure debug-VC-WIN64A --prefix=`"$OutputTarget`" --openssldir=`"$OutputTarget/var/openssl`""
cmd.exe /C $Cmd
if($LASTEXITCODE -ne 0)
{
    throw "Configure failed: $Cmd"
}

nmake
if($LASTEXITCODE -ne 0)
{
    throw "Failed: nmake"
}
nmake install
if($LASTEXITCODE -ne 0)
{
    throw "Failed: nmake install"
}

cd $CurrentDir