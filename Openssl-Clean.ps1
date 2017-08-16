PARAM(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Target
)

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

cd $Target

git clean -dfx
if($LASTEXITCODE -ne 0)
{
    throw "git clean -dfx"
}

cd $CurrentDir