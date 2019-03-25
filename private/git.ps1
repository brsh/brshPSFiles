function Initialize-GitRepo {
	param (
		[System.IO.DirectoryInfo] $root,
		[switch] $InitialCommit = $false,
		[Parameter(Mandatory = $false)]
		[string] $GitRemoteRepoURI = ''
	)
	Write-Status -Message 'Attempting to initialize Git repository' -Type 'Info' -Level 0
	try {
		$response = (git.exe init $root.FullName *>&1)
		Write-Status -Message $response -Type 'Info' -Level 1
		Write-Status -Message 'Repository initialized successfully' -Type 'Good' -Level 1
	} catch {
		Write-Status -Message 'Could not initialize repository.' -Type "Error" -Level 1 -e $_
	}
	if ($InitialCommit) {
		Write-Status -Message 'Attempting first commit' -Type 'Info' -Level 1
		try {
			$currdir = $pwd
			Set-Location $root
			Write-Status -Message 'Adding all files...' -Type 'Info' -Level 2
			$response = (git add . *>&1)
			#Write-Status -Message $response -Type 'Info' -Level 3
			Write-Status -Message 'Committing...' -Type 'Info' -Level 2
			$response = (git commit -m 'Initial Commit' *>&1)
			#Write-Status -Message (($response) -split '`r') -Type 'Info' -Level 3
			Write-Status -Message 'Initial commit successful' -Type 'Good' -Level 1
			if ($GitRemoteRepoURI.Length -gt 0) {
				#Yeah, haven't tested this and don't think I will quite yet :)
				Write-Status -Message 'Attempting to push to remote origin...' -Type 'Info' -Level 1
				$response = (git remote add origin $GitRemoteRepoURI *>&1)
				$response = (git push -u origin master *>&1)
				Write-Status -Message $response -Type 'Warning' -Level 2
			}
			Set-Location $currdir
		} catch {
			Write-Status -Message "Could not perform initial commit." -Type "Error" -Level 2 -e $_
		}
	}
}
