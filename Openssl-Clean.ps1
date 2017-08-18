PARAM(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Target
)
Import-Module "$PSScriptRoot\Common\Git.ps1" -Force

Git-Clean $Target