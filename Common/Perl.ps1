Import-Module "$PSScriptRoot\Process.ps1" -Force

Function Perl-GetEnv
{
    PARAM(
        [Parameter(Mandatory=$True, Position=1)]
        [switch]$Mandatory
    )

    if(Get-Command perl.exe -ErrorAction SilentlyContinue)
    {
        Write-Output "Perl already in PATH"
    }
    elseif((Test-Path "C:\Tools\Perl\bin"))
    {
        $env:PATH += ";C:\Tools\Perl\bin"
        Write-Output "Perl found at C:\Tools\Perl\bin"
    }
    elseif((Test-Path "C:\Tools\Perl\perl\bin"))
    {
        $env:PATH += ";C:\Tools\Perl\perl\bin"
        Write-Output "Perl found at C:\Tools\Perl\perl\bin"
    }
    elseif($Mandatory)
    {
        Write-Output "Mandatory Perl not found, try to download portable Version"
        $TempZip   = "$PSScriptRoot\Tools\StrawberryPerl.zip"
        $Target    = "$PSScriptRoot\Tools\StrawberryPerl"
        $TargetBin = "$Target\perl\bin"
        Import-Module "$PSScriptRoot\Web.ps1" -Force
        Import-Module "$PSScriptRoot\Compress.ps1" -Force
        if(-not (Test-Path "$PSScriptRoot\Tools"))
        {
            New-Item -ItemType Directory -Path "$PSScriptRoot\Tools"
        }
        if(Web-Download "http://mirror.adirmeier.de/projects/ThirdParty/StrawberryPerl/binaries/5.24.1.1/StrawberryPerl.32bit.portable.zip" $TempZip)
        {
            Compress-Unzip $TempZip $Target
            Remove-Item $TempZip
            Write-Output "Perl now available at TargetBin"
            $env:PATH += ";$TargetBin"
        }
        else
        {
            throw( "StrawberryPerl not found, download failed" )
        }
    }
    else
    {
        Write-Output "No Perl found";
    }
}
