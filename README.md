# Build OpenSSL for Windows with Powershell

This build scripts are created for Powershell in Windows.
Sources will be downloaded from original repository on https://github.com/openssl/openssl

Primarily this script was created for my BuildSystem wich is described [here](https://adirmeier.de/0_Blog/ID_157/index.html).  
This scripts should work on other systems too.  
If something goes wrong feel free to debug with *Powershell ISE* or write a Message.

## Requirements

Mandatory Requirements:
 - Git
 - Visual Studio 2012/2013/2015/2017
 - Cmake (for working with Zip-Files)

Recommended Requirements:
 - Perl 2.7
    Common Scripts will download a Portable Version of StrawberryPerl if not available
 - NASM
    Common Scripts will download a Portable Version of NASM if not available

## How to build

For example, to build the Version 1.1.0e, execute the following command:

    .\Make.ps1 -VisualStudio 2017 -Architecture x64 -Version 1.1.0e
    
Options (bold are mandatory):
 - **VisualStudio**: 2012/2013/2015/2017
 - **Architectrue**: x64/x86
 - **Version**: Version of OpenSSL
 - Static: $true/$false (default: $false)
 - DebugBuild: $true/$false (default: $false)
 - StaticRuntime: $true/$false (default: $false)
 - DoPackage: $true/$false (default: $false) for creating zip of output
 - AdditionalConfig: String to append on configure command (default: "")
 
