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
    [bool]$StaticRuntime = $false,
    [Parameter(Mandatory=$false, Position=6)]
    [string]$AdditionalConfig = ""
)
Import-Module "$PSScriptRoot\Common\All.ps1" -Force

$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName

Nasm-GetEnv -Mandatory
Perl-GetEnv -Mandatory

cd $OpensslDir

$VSConfig = ""
$VSDoScript = ""
# get configure string
switch($Global:VSArch)
{
    "x64" 
    {
        if($DebugBuild) { $VSConfig = "debug-VC-WIN64A"; $VSDoScript = "ms\do_win64a"}
        else                       { $VSConfig = "VC-WIN64A"; $VSDoScript = "ms\do_win64a"}

        break;
    }
    "x86" 
    {
        if($DebugBuild) { $VSConfig = "debug-VC-WIN32"; $VSDoScript = "ms\do_nasm"}
        else                       { $VSConfig = "VC-WIN32"; $VSDoScript = "ms\do_nasm"}
        break;
    }
    default
    {
        throw "wrong configuration"
    }
}

$VTarget = New-Object System.Version($Global:VSOpensslVersion)
if($Static)
{
    $VSConfig += " no-shared"
}
$VSConfig += " $AdditionalConfig"

if($VTarget.Major -lt 1 -or ($VTarget.Major -eq 1 -and $VTarget.Minor -eq 0))
{
    $VSVersion =  New-Object System.Version($Global:VSVersion + ".0")

    $Makefile = "ms\ntdll.mak"
    if($Static)
    {
        $Makefile = "ms\nt.mak"
    }

    Write-Output "******************************"
    Write-Output "* Start Configuration"
    Write-Output "******************************"
    Process-StartInlineAndThrow "perl.exe" "Configure $VSConfig --prefix=`"$OutputTarget`" --openssldir=`"$OutputTarget/var/openssl`""
    Process-StartInlineAndThrow "cmd.exe" "/C $VSDoScript"

    # Openssl for higher VS Versions will fail because of changes in stdlibs
    # to avoid error LNK2019: unresolved external symbol __iob_func
    # Reffered to "http://openssl.6102.n7.nabble.com/Compiling-OpenSSl-Project-with-Visual-Studio-2015-td59416.html"
    # the os header file must be manipulated
    if($VSVersion.Major -gt 2013)
    {
        (Get-Content e_os.h) |  Foreach-Object {$_ -Replace '#      if _MSC_VER>=1300','#      if _MSC_VER >= 1300 && _MSC_VER <= 1800'}  | Out-File e_os.h

        # default warning is treated as error (-WX) but Microsoft increases sometimes very worhtless warnings
        # to avoid stopping build, wie pass warnings.
        # Look at INSTALL.W32 within openssl sources for more information
        if($Global:VSArch -eq "x86")
        {
            (Get-Content $Makefile) |  Foreach-Object {$_ -Replace '-WX',''}  | Out-File $Makefile
        }
    }

    Write-Output "******************************"
    Write-Output "* Start Build"
    Write-Output "******************************"
    nmake -f $Makefile
    if($LASTEXITCODE -ne 0)
    {
        throw("Failed: nmake -f $Makefile")
    }

    Write-Output "******************************"
    Write-Output "* Start Install"
    Write-Output "******************************"
    nmake -f $Makefile install
    if($LASTEXITCODE -ne 0)
    {
        throw("Failed: nmake -f $Makefile install")
    }
}
else
{
    Write-Output "******************************"
    Write-Output "* Start Configuration"
    Write-Output "******************************"
    Process-StartInlineAndThrow "perl.exe" "Configure $VSConfig --prefix=`"$OutputTarget`" --openssldir=`"$OutputTarget/var/openssl`""

    Write-Output "******************************"
    Write-Output "* Start Build"
    Write-Output "******************************"
    Process-StartInlineAndThrow "nmake"

    Write-Output "******************************"
    Write-Output "* Start Install"
    Write-Output "******************************"
    Process-StartInlineAndThrow "nmake" "install"
}
cd $CurrentDir