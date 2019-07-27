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
			"Copyright (c) $((Get-Date).ToString('yyyy')) by $Author, under the Apache License, Version 2.0."
			break
		}
		'GNUv3' {
			"Copyright (c) $((Get-Date).ToString('yyyy')) by $Author, under the GNUv3 license."
			break
		}
		'MIT' {
			"Copyright (c) $((Get-Date).ToString('yyyy')) by $Author, under the MIT license."
			break
		}
		'WTFPL' {
			"Copyright (c) $((Get-Date).ToString('yyyy')) by $Author. This work is free. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See http://www.wtfpl.net/ for more details."
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
			[bool] $FileCreated = $false
			Switch ($License) {
				'Apache2' {
					Copy-Item $script:scriptpath\config\Apachev2.txt $root\license.txt
					$FileCreated = $true
					break
				}
				'GNUv3' {
					Copy-Item $script:scriptpath\config\GNUv3.txt $root\license.txt
					$FileCreated = $true
					break
				}
				'MIT' {
					$LicenseFile = (Get-Content $script:scriptpath\config\mit.txt).Replace('Copyright (c) [year] [fullname]', "Copyright (c) $((Get-Date).ToString('yyyy')) $Author")
					$LicenseFile | Out-File -FilePath "$root\license.txt" -Encoding utf8 -NoClobber -ErrorAction Stop
					$FileCreated = $true
					break
				}
				'WTFPL' {
					Copy-Item $script:scriptpath\config\wtfpl.txt $root\license.txt
					$FileCreated = $true
					break
				}
				DEFAULT {
					Write-Status -Message 'No License specified - defaulting to Public Domain' -Type 'Warning' -Level 1
					$FileCreated = $false
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
