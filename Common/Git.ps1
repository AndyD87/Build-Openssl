Import-Module "$PSScriptRoot\Process.ps1"

Function Git-Clone
{
    PARAM(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Source,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$Target
    )
    $Cmd =  "clone `"$Source`" `"$Target`""
    if((Process-StartInline "git" $Cmd )-ne 0)
    {
        throw "Failed: git $Cmd"
    }
}

Function Git-Clean
{
    PARAM(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Target
    )
    
    $CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

    cd $Target

    if((Process-StartInline "git" "submodule foreach --recursive `"git clean -dfx`"" )-ne 0)
    {
        cd $CurrentDir
        throw "Failed: git submodule foreach --recursive `"git clean -dfx`""
    }
    if((Process-StartInline "git" "clean -dfx" )-ne 0)
    {
        cd $CurrentDir
        throw "Failed git clean -dfx"
    }
    cd $CurrentDir
}