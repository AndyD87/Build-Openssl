##
# This file is part of Powershell-Common, a collection of powershell-scrips
# 
# Copyright (c) 2017 Andreas Dirmeier
# License   MIT
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##
Import-Module "$PSScriptRoot\7Zip.ps1" -Force

Function Compress-Zip
{
    PARAM(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$OutputFile,
        [Parameter(Mandatory=$False, Position=2)]
        [string]$Single = "",
        [Parameter(Mandatory=$False)]
        [string[]]$Array = $null
    )

    if($OutputFile.EndsWith(".7z"))
    {
        7Zip-GetEnv -Mandatory
        7Zip-Compress $OutputFile $Single
    }
    # If no other detected, use default zip
    else
    {
        # First, do it with powershell
        try
        {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
        
            if(-not [string]::IsNullOrEmpty($Single))
            {
                $oFile = Get-Item $Single
                [System.IO.Compression.ZipFile]::CreateFromDirectory($Single, $OutputFile, [System.IO.Compression.CompressionLevel]::Optimal, $false)
            }
            else
            {
                throw "No Compression of multiple files"
            }
        }
        catch
        {
            Write-Host $_.Exception.Message
            if(Get-Command cmake -ErrorAction SilentlyContinue)
            {
                # Create CMD
                $cmd = "cmake -E tar "

                if(-not [string]::IsNullOrEmpty($Single))
                {
                    $oFile = Get-Item $Single
                    if($oFile.PSIsContainer)
                    {
                        $cmd += "cf `"$OutputFile`" --format=zip "
                        $oFileList = Get-ChildItem $Single
                        foreach($oFile in $oFileList)
                        {
                            $cmd += " `"$Single\"
                            $cmd += $oFile.Name
                            $cmd += "`""
                        }
                    }
                    else
                    {
                        $cmd += "cf `"$OutputFile`" --format=zip "
                        $cmd += "`"$Single`" "
                    }
                }
                elseif ($Array -ne $null -and $Array.Count -gt 0)
                {
                    $cmd += "cf `"$OutputFile`" --format=zip "
                    foreach($Folder in $Array)
                    {
                        $cmd += "`"$Folder`" "
                    }
                }
                else
                {
                    throw "No Input given"
                }

                $cmd
                cmd /C $cmd
                if($LASTEXITCODE -ne 0)
                {
                    throw "Fail on creating zip: $cmd"
                }
            }
            else
            {
                throw "Unable to zip Archive"
            }
        }
    }
}

Function Compress-Unzip
{
    PARAM(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$ZipFile,
        [Parameter(Mandatory=$True, Position=2)]
        [string]$Target
    )
    $CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)
    
    if($ZipFile.EndsWith(".7z"))
    {
        7Zip-GetEnv -Mandatory
        7Zip-Uncompress $ZipFile $Target
    }
    # If no other detected, use default zip
    else
    {
        # First, do it with powershell
        try
        {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            function Unzip
            {
                param([string]$zipfile, [string]$outpath)

                [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
            }

            Unzip $ZipFile $Target
        }
        catch
        {
            if(-not (Test-Path $Target))
            {
                New-Item -ItemType Directory -Path "$Target"
            }

            cd $Target

            if(Get-Command cmake -ErrorAction SilentlyContinue)
            {
                # Create CMD
                $cmd = "-E tar xf `"$ZipFile`""
                Process-StartInlineAndThrow "cmake" "$Cmd"
            }
            else
            {
                cd $CurrentDir
                throw "Unable to extract Archive"
            }
        }
    }
    cd $CurrentDir
}