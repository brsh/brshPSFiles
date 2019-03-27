function New-psfModule {
	<#
	.SYNOPSIS
	Creates PowerShell module skeleton files (psm and psd)

	.DESCRIPTION
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
		* Root/license.txt - the license file (if any; default is MIT)
		* Root/.gitignore - win/mac/msoffice/etc files/folders for git to ignore by default
		* Root/Public/Information.ps1 - the Get-Help function
		* Root/Private/Write-Status.ps1 - a Write-Host wrapper

	This is based on how I code modules at the moment (early 2019), and is subject to change.

	.PARAMETER Name
	Name of the module

	.PARAMETER Path
	Parent folder where it will create the script module; it must already exist.

	.PARAMETER Author
	Specifies the author (defaults to AD Full Name)

	.PARAMETER Description
	Description of the module

	.PARAMETER Abbreviate
	Tells the function to abbreviate the Capital Letters into Function names (so in MyBronto module, will create Get-mbHelp vs Get-MybrontoHelp)

	.PARAMETER License
	Sets a license for the project (defaults to MIT, but Apachev2, GNUv3, and Public Domain are supported)

	.PARAMETER GitInit
	Initialize the project as a git repo - adding all "base" files

	.PARAMETER MinimumVersion
	Sets the minimum supported version of Powershell for the Module. Default is 5.1, cuz it's 2019!

	.EXAMPLE
	New-psfModule -Name Brontosaurus -Path "$env:ProgramFiles\WindowsPowerShell\Modules" -Author 'Anne Elk' -Description 'This is my module of brontosauruses'
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]$Name,
		[ValidateScript( {
				If (Test-Path -Path $_ -PathType Container) {
					$true
				} else {
					Throw "'$_' is not a valid directory."
				}
			})]
		[String]$Path = (($env:PSModulePath).ToString().Split(";") -like "*\Users\*"),
		[Parameter(Mandatory = $false)]
		[string]$Author,
		[Parameter(Mandatory = $true)]
		[Alias('Synopsis')]
		[string]$Description,
		[Parameter(Mandatory = $false)]
		[switch] $Abbreviate = $false,
		[Parameter(Mandatory = $false)]
		[ValidateSet('Apache2', 'GNUv3', 'MIT', 'PublicDomain')]
		[string] $License = 'MIT',
		[Parameter(Mandatory = $false)]
		[switch] $GitInit = $false,
		[Parameter(Mandatory = $false)]
		[ValidateSet('2.0', '3.0', '4.0', '5.1', '6.0')]
		[string] $MinimumVersion = "5.1"
	)

	Try {
		Write-Status -Message "Creating Root..." -Type 'Info' -Level 0
		$root = New-Item -Path $Path -Name $Name -ItemType Directory -ErrorAction Stop
		Write-Status -Message "Created $($root.FullName)" -Type 'Good' -Level 1

		Write-Status -Message "Creating Private..." -Type 'Info' -Level 0
		$ret = New-Item -Path $Path\$Name -Name "private" -ItemType Directory -ErrorAction Stop
		Write-Status -Message "Created $($ret.FullName)" -Type 'Good' -Level 1

		Write-Status -Message "Creating Public..." -Type 'Info' -Level 0
		$ret = New-Item -Path $Path\$Name -Name "public" -ItemType Directory -ErrorAction Stop
		Write-Status -Message "Created $($ret.FullName)" -Type 'Good' -Level 1

		Write-Status -Message "Creating Config..." -Type 'Info' -Level 0
		$ret = New-Item -Path $Path\$Name -Name "config" -ItemType Directory -ErrorAction Stop
		Write-Status -Message "Created $($ret.FullName)" -Type 'Good' -Level 1

		Write-Status -Message "Creating Formats..." -Type 'Info' -Level 0
		$ret = New-Item -Path $Path\$Name -Name "formats" -ItemType Directory -ErrorAction Stop
		Write-Status -Message "Created $($ret.FullName)" -Type 'Good' -Level 1
	} Catch {
		Write-Status -Message "Could not create the directory structure." -Type "Error" -Level 1 -e $_
		return
	}

	[string] $NickName = $Name
	if ($Abbreviate) {
		$NickName = ($Name -creplace '[a-z0-9]', '').ToLower()
	}

	#PSM File
	Try {
		write-Status -Message 'Creating Module File...' -Type 'Info' -Level 0
		(Get-PSMModule -Name $Name -NickName $NickName) | Out-File -FilePath "$Path\$Name\$Name.psm1" -Encoding utf8 -NoClobber -ErrorAction Stop
		write-Status -Message 'Success' -Type 'Good' -Level 1
	} Catch {
		Write-Status -Message "Could not create the Module file." -Type "Error" -Level 1 -e $_
		return
	}

	#Readme
	Try {
		write-Status -Message 'Creating Readme File...' -Type 'Info' -Level 0
		(Get-PSMReadme -Name $Name -Description $Description) | Out-File -FilePath "$Path\$Name\readme.md" -Encoding utf8 -NoClobber -ErrorAction Stop
		write-Status -Message 'Success' -Type 'Good' -Level 1
	} Catch {
		Write-Status -Message "Could not create the Readme file." -Type "Error" -Level 1 -e $_
		return
	}

	#Information File / Get-Help
	Try {
		write-Status -Message 'Creating Help/Information File...' -Type 'Info' -Level 0
		(Get-HelpFunction -Name $Name -NickName $NickName) | Out-File -FilePath "$Path\$Name\public\Information.ps1" -Encoding utf8 -NoClobber -ErrorAction Stop
		Write-Status -Message 'Success' -Type 'Good' -Level 1
	} Catch {
		Write-Status -Message 'Could not add skeleton help content to file.' -Type "Error" -Level 1 -e $_
		return
	}

	#Write-Status File
	Try {
		write-Status -Message 'Creating Write-Status.ps1 File...' -Type 'Info' -Level 0
		Copy-Item $script:scriptpath\private\Write-Status.ps1 $root\private\Write-Status.ps1 -ErrorAction Stop
		Write-Status -Message 'Success' -Type 'Good' -Level 1
	} Catch {
		Write-Status -Message 'Could not add Write-Status.ps1 file.' -Type "Error" -Level 1 -e $_
		return
	}

	#License / Copyright
	Write-Status -Message "Establishing Copyright: $($License.ToUpper())..." -Type 'Info' -Level 0
	[string] $Copyright = Get-LicenseText -License $license -Author $Author -ErrorAction Stop
	if ($Copyright.Length -gt 0) {
		Write-Status 'Success' -Type 'Good' -Level 1
	}
	Set-LicenseFile -License $License -Author $Author -Root $root

	#Manifest / PSD
	Try {
		write-Status -Message 'Creating Manifest...' -Type 'Info' -Level 0
		$splat = @{
			Author            = $Author
			Copyright         = $Copyright
			Description       = $Description
			Path              = "$Path\$Name\$Name.psd1"
			PowerShellVersion = $MinimumVersion
			RootModule        = $Name
			AliasesToExport   = $null
			FunctionsToExport = $null
			VariablesToExport = $null
			CmdletsToExport   = $null
		}
		New-ModuleManifest @Splat -ErrorAction Stop
		Write-Status -Message 'Success' -Type 'Good' -Level 1
	} Catch {
		Write-Status -Message 'Could not create the manifest.' -Type "Error" -Level 1 -e $_
		return
	}

	#Git
	if ($GitInit) {
		Initialize-GitRepo -Root $root -InitialCommit
	}
}
