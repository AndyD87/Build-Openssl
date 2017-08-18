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
Import-Module "$PSScriptRoot\Common\All.ps1" -Force

$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName

Nasm-GetEnv -Mandatory
Perl-GetEnv -Mandatory

cd $OpensslDir


Write-Output "******************************"
Write-Output "* Start Configuration"
Write-Output "******************************"
Process-StartInlineAndThrow "perl.exe" "Configure debug-VC-WIN64A --prefix=`"$OutputTarget`" --openssldir=`"$OutputTarget/var/openssl`""

Write-Output "******************************"
Write-Output "* Start Build"
Write-Output "******************************"
Process-StartInlineAndThrow "nmake"

Write-Output "******************************"
Write-Output "* Start Install"
Write-Output "******************************"
Process-StartInlineAndThrow "nmake" "install"

cd $CurrentDir