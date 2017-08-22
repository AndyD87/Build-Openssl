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
    [string]$Target,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$Version = ""

)

Function OpenSslVersionToTag
{
    PARAM(
        [string]$Version
    )
    $oVersion  = New-Object System.Version($Version)
    $sVersion = "OpenSSL_" + $oVersion.Major + "_" + $oVersion.Minor + "_" + $oVersion.MajorRevision
    switch($oVersion.MinorRevision)
    {
        "0" {$sVersion += "a"; break}
        "1" {$sVersion += "b"; break}
        "2" {$sVersion += "c"; break}
        "3" {$sVersion += "d"; break}
        "4" {$sVersion += "e"; break}
        "5" {$sVersion += "f"; break}
        "6" {$sVersion += "g"; break}
        "7" {$sVersion += "h"; break}
        "8" {$sVersion += "i"; break}
        "9" {$sVersion += "j"; break}
    }
    return $sVersion
}

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

$Tag = OpenSslVersionToTag $Version

if((Process-StartInline "git" "clone --branch $Tag  https://github.com/openssl/openssl.git `"$Target`"") -ne 0)
{
    throw "Cloning Openssl failed: $cmd"
}

cd $CurrentDir