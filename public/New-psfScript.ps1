function New-psfScript {
	<#
.SYNOPSIS
Creates PowerShell script skeleton file (ps1)

.DESCRIPTION
Creates a PowerShell script skeleton, complete with initial Comment Help section and basic param options.

.PARAMETER Name
Name of the script

.PARAMETER Path
Parent folder where it will create the script; it must already exist.

.PARAMETER Author
Specifies the author

.PARAMETER Synopsis
Description of the module

.PARAMETER NewFolder
Creates a separate folder for the script (this is the only way for this function to initialize a git repo)

.PARAMETER License
Sets a license for the project (defaults to MIT, but Apachev2, GNUv3, and Public Domain are supported)

.PARAMETER GitInit
Initialize the project as a git repo - adding all "base" files

.PARAMETER MinimumVersion
Sets the minimum supported version of Powershell for the Module. Default is 5.1, cuz it's 2019!

.EXAMPLE
New-psfScript -Name "Brontosaurus" -Path "C:\Scripts" -Synopsis 'A script about brontosauruses'

.EXAMPLE
New-psfScript -Name "Brontosaurus.ps1" -Path "C:\Scripts" -Synopsis 'A script about brontosauruses'

.EXAMPLE
New-psfScript -Name "Brontosaurus.ps1" -Path "C:\Scripts" -Synopsis 'A script about brontosauruses' -NewFolder -GitInit

#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias('FileName')]
		[string]$Name,
		[Parameter(Mandatory = $false)]
		[ValidateScript( {
				If (Test-Path -Path $_ -PathType Container) {
					$true
				} else {
					Throw "'$_' is not a valid directory."
				}
			})]
		[Alias('Directory', 'Folder')]
		[String]$Path = ($pwd.ProviderPath),
		[Parameter(Mandatory = $false)]
		[Alias('Description')]
		[string]$Synopsis,
		[Parameter(Mandatory = $false)]
		[string]$Author,
		[switch] $NewFolder = $false,
		[Parameter(Mandatory = $false)]
		[ValidateSet('Apache2', 'GNUv3', 'MIT', 'PublicDomain')]
		[string] $License = 'MIT',
		[Parameter(Mandatory = $false)]
		[switch] $GitInit = $false,
		[Parameter(Mandatory = $false)]
		[ValidateSet('2', '3', '5.1', '6')]
		[string] $MinimumVersion = "5.1"
	)

	Write-Status -Message 'Testing Path...' -Type 'Info' -Level 0
	if ($NewFolder) {
		$FullPath = Join-Path -path $Path -ChildPath ($Name -replace '.ps1$', '')
		Write-Status -Message 'New folder selected' -Type 'Info' -Level 1
		if (Test-Path $FullPath) {
			Write-Status -Message "Can't create a new folder - it already exists!" -Type 'Error' -Level 2
			return
		} else {
			Write-Status -Message "Creating Root..." -Type 'Info' -Level 2
			$root = New-Item -Path $Path -Name $Name -ItemType Directory -ErrorAction Stop
			Write-Status -Message "Created $($root.FullName)" -Type 'Good' -Level 2
		}
	} else {
		try {
			$root = Get-Item -Path $Path
		} catch {
			Write-Status -Message "Unable to access $path" -Type 'Error' -e $_ -Level 1
		}
	}

	if (-not $Name.ToUpper().EndsWith(".PS1")) { $Name = $Name.Trim() + ".ps1" }

	Try {
		Write-Status -Message 'Creating Script File...' -Type 'Info' -Level 0
		Write-Status -Message 'FileName', "$($root.FullName)\$Name" -Type 'Info', 'InfoHigh' -Level 1
		(Get-ScriptInfo -License $License -Synopsis $Synopsis -Name $Name -Author $Author) | Out-File -FilePath "$($root.FullName)\$Name" -Encoding utf8 -NoClobber	-ErrorAction Stop
		write-Status -Message 'Success' -Type 'Good' -Level 1
	} Catch {
		Write-Status -Message "Unable to create file in the path specified." -Type 'Error' -Level 1 -e $_
		return
	}

	if (($NewFolder) -and ($GitInit)) {
		Initialize-GitRepo -Root $root -InitialCommit
	}



}
