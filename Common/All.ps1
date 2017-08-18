$Scripts = Get-ChildItem $PSScriptRoot -Exclude "All.ps1"

foreach($Script in $Scripts)
{
    Import-Module $Script -Force
}