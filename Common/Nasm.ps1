
Function Nasm-GetEnv
{
    PARAM(
        [Parameter(Mandatory=$True, Position=1)]
        [switch]$Mandatory
    )

    if(Get-Command nasm.exe -ErrorAction SilentlyContinue)
    {
        Write-Output "NASM already in PATH"
    }
    elseif((Test-Path "C:\Program Files\NASM"))
    {
        $env:PATH += "C:\Program Files\NASM"
        Write-Output "NASM found at C:\Program Files\NASM"
    }
    elseif($Mandatory)
    {
        Write-Output "Mandatory Perl not found, try to download portable Version"
        $TempZip   = "$PSScriptRoot\Tools\NASM.zip"
        $Target    = "$PSScriptRoot\Tools\NASM"
        $TargetBin = "$Target"
        Import-Module "$PSScriptRoot\Web.ps1" -Force
        Import-Module "$PSScriptRoot\Compress.ps1" -Force
        if(-not (Test-Path "$PSScriptRoot\Tools"))
        {
            New-Item -ItemType Directory -Path "$PSScriptRoot\Tools"
        }
        if(Web-Download "http://mirror.adirmeier.de/projects/ThirdParty/NASM/binaries/2.12.02/NASM.portable.zip" $TempZip)
        {
            Compress-Unzip $TempZip $Target
            Remove-Item $TempZip
            Write-Output "NASM now available at TargetBin"
            $env:PATH += ";$TargetBin"
        }
        else
        {
            throw( "NASM not found, download failed" )
        }
    }
    else
    {
        Write-Output "No NASM found"
    }
}

