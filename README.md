# Build OpenSSL for Windows with Powershell

This build scripts are created for Powershell in Windows.
Sources will be downloaded from original repository on https://github.com/openssl/openssl

Primarily this script was created for my BuildSystem wich is described [here](https://adirmeier.de/0_Blog/ID_157/index.html).  
This scripts should work on other systems too.  
If something goes wrong feel free to debug with *Powershell ISE* or write a Message.

## Requirements

 - Visual Studio
 - Cmake (for creating zip)
 - Perl
 - NASM

## How to build

For example, to build the Version 59.1, execute the following command:

    .\Make.ps1 -VisualStudio 2017 -Architecture x64 -Version 1.1.0e
    
Options (bold are mandatory):
 - **VisualStudio**: 2012/2013/2015/2017
 - **Architectrue**: x64/x86
 - **Version**: Version of OpenSSL
 - Static: $true/$false (default: $false)
 - Debug: $true/$false (default: $false)
 - DoPackage: $true/$false (default: $false) for creating zip of output
 - AdditionalConfig: String to append on configure command (default: "")
 
