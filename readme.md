# brshPSFiles - Create the base folder/files for PSCode Work

Everybody needs a handy template/skeleton for coding... it's a fact (I looked it up).
This module consolidates older scripts I used to create new PowerShell modules and
script files (granted, the script files weren't as complex but a keystroke saved is
um... a keystroked ... earned).

## New-psfScript
.SYNOPSIS<br/>
Creates PowerShell script skeleton file (ps1)

.DESCRIPTION<br/>
Creates a PowerShell script skeleton, complete with initial Comment Help section and basic param options.

.PARAMETER Name<br/>
Name of the script

.PARAMETER Path<br/>
Parent folder where it will create the script; it must already exist.

.PARAMETER Author<br/>
Specifies the author

.PARAMETER Synopsis<br/>
Description of the module

.PARAMETER NewFolder<br/>
Creates a separate folder for the script (this is the only way for this functon to initialize a git repo)

.PARAMETER License<br/>
Sets a license for the project (defaults to MIT, but Apachev2, GNUv3, and Public Domain are supported)

.PARAMETER GitInit<br/>
Initialize the project as a git repo - adding all "base" files

.PARAMETER MinimumVersion<br/>
Sets the minimum supported version of Powershell for the Module. Default is 5.1, cuz it's 2019!

.EXAMPLE<br/>
New-psfScript -Name "Brontosaurus" -Path "C:\Scripts" -Synopsis 'A script about brontosauruses'

.EXAMPLE<br/>
New-psfScript -Name "Brontosaurus.ps1" -Path "C:\Scripts" -Synopsis 'A script about brontosauruses'

.EXAMPLE<br/>
New-psfScript -Name "Brontosaurus.ps1" -Path "C:\Scripts" -Synopsis 'A script about brontosauruses' -NewFolder -GitInit

## New-psfModule
.SYNOPSIS<br/>
Creates PowerShell module skeleton files (psm and psd)

.DESCRIPTION<br/>
Creates a PowerShell module skeleton, complete with manifest and requisite folders. In general,
that equates to the following:

	* Root - based on the module name
	* Root/Private - Private Code
	* Root/Public - Public functions
	* Root/Config - Any data/storage files
	* Root/Format - ps1xml format files
	* Root/*.psm1 - the main module file
	* Root/*.psd1 - the Module Definition file
	* Root/readme.md - the base readme markdown file
	* Root/licenst.txt - the license file (if any; default is MIT)
	* Root/.gitignore - win/mac/msoffice/etc files/folders for git to ignore by default
	* Root/Public/Information.ps1 - the Get-Help function
	* Root/Private/Write-Status.ps1 - a Write-Host wrapper

This is based on how I code modules at the moment (early 2019), and is subject to change.

.PARAMETER Name<br/>
Name of the module

.PARAMETER Path<br/>
Parent folder where it will create the script module; it must already exist.

.PARAMETER Author<br/>
Specifies the author (defaults to AD Full Name)

.PARAMETER Description<br/>
Description of the module

.PARAMETER Abbreviate<br/>
Tells the function to abbreviate the Capital Letters into Function names (so in MyBronto module, will create Get-mbHelp vs Get-MybrontoHelp)

.PARAMETER License<br/>
Sets a license for the project (defaults to MIT, but Apachev2, GNUv3, and Public Domain are supported)

.PARAMETER GitInit<br/>
Initialize the project as a git repo - adding all "base" files

.PARAMETER MinimumVersion<br/>
Sets the minimum supported version of Powershell for the Module. Default is 5.1, cuz it's 2019!

.EXAMPLE<br/>
New-psfModule -Name Brontosaurus -Path "$env:ProgramFiles\WindowsPowerShell\Modules" -Author 'Anne Elk' -Description 'This is my module of brontosauruses'


