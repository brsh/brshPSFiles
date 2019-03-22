function Get-LicenseText {
	param (
		[string] $License = 'MIT',
		[string] $Author
	)
	<#
	https://choosealicense.com/
		https://choosealicense.com/community/
			https://choosealicense.com/licenses/mit/
			https://opensource.org/licenses/GPL-3.0
			https://opensource.org/licenses/Apache-2.0
			https://creativecommons.org/choose/
#>
	Switch ($License) {
		'Apache2' {
			"Copyright (c) $((Get-Date).Year) by $Author, under the Apache License, Version 2.0."
			break
		}
		'GNUv3' {
			"Copyright (c) $((Get-Date).Year) by $Author, under the GNUv3 license."
			break
		}
		'MIT' {
			"Copyright (c) $((Get-Date).Year) by $Author, under the MIT license."
			break
		}
		DEFAULT { 'To the extent within my power and possible under law, the author(s) have dedicated all copyright and related and neighboring rights to the public domain worldwide. This is distributed without any warranty.'; break }
	}
}

function Set-LicenseFile {
	param (
		[string] $License = 'MIT',
		[string] $Author,
		[System.IO.DirectoryInfo] $root
	)
	if (test-path $root) {
		try {
			Switch ($License) {
				'Apache2' {
					Copy-Item $script:scriptpath\config\Apachev2.txt $root\license.txt
					break
				}
				'GNUv3' {
					Copy-Item $script:scriptpath\config\GNUv3.txt $root\license.txt
					break
				}
				'MIT' {
					Copy-Item $script:scriptpath\config\mit.txt $root\license.txt
					break
				}
			}
			Write-Status -Message "License file created." -Type 'Good' -Level 1
		} catch {
			Write-Status -Message "License file not created." -Type "Error" -Level 1 -e $_
		}
	} else {
		Write-Status -Message "License not created. Path not found: ${Path}\${Name}" -Type "Error" -Level 1
	}
}
