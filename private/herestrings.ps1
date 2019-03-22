function Get-HelpFunction {
	param (
		[string] $Name,
		[string] $NickName
	)

	@"
Function Get-$(${NickName})Help {
	<#
	.SYNOPSIS
	List commands available in the $($Name) Module

	.DESCRIPTION
	List all available commands in this module

	.EXAMPLE
	Get-$(${NickName})Help
	#>
	Write-Host `"`"
	Write-Host "Getting available functions..." -ForegroundColor Yellow

	`$all = @()
	`$list = Get-Command -Type function -Module `"$($Name)`" | Where-Object { `$_.Name -in `$script:showhelp}
	`$list | ForEach-Object {
        if (`$PSVersionTable.PSVersion.Major -lt 6) {
			`$RetHelp = Get-Help `$_.Name -ShowWindow:`$false -ErrorAction SilentlyContinue
        } else {
            `$RetHelp = Get-Help `$_.Name -ErrorAction SilentlyContinue
        }
		if (`$RetHelp.Description) {
			`$Infohash = @{
				Command     = `$_.Name
				Description = `$RetHelp.Synopsis
			}
			`$out = New-Object -TypeName psobject -Property `$InfoHash
			`$all += `$out
		}
	}
	`$all | Select-Object Command, Description | format-table -Wrap -AutoSize | Out-String | Write-Host
}
"@
}

function Get-PSMModule {
	param (
		[string] $Name,
		[string] $NickName
	)

	@"
param (
    [switch] `$Quiet = `$False
)
#region Default Private Variables
# Current script path
[string] `$script:ScriptPath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent
[string[]] `$script:showhelp = @()
#endregion Default Private Variables

#region Load Private Helpers
# Dot sourcing private script files
Get-ChildItem `$script:ScriptPath/private -Recurse -Filter "*.ps1" -File | ForEach-Object {
	. `$_.FullName
}
#endregion Load Private Helpers

#region Load Public Helpers
# Dot sourcing public script files
Get-ChildItem `$ScriptPath/public -Recurse -Filter "*.ps1" -File | ForEach-Object {
	. `$_.FullName

	# From https://www.the-little-things.net/blog/2015/10/03/powershell-thoughts-on-module-design/
	# Find all the functions defined no deeper than the first level deep and export it.
	# This looks ugly but allows us to not keep any uneeded variables from poluting the module.
	([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path `$_.FullName -Raw), [ref] `$null, [ref] `$null)).FindAll( { `$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, `$false) | Foreach {
		Export-ModuleMember `$_.Name
		`$showhelp += `$_.Name
	}
}
#endregion Load Public Helpers

#region Load Formats
if (test-path `$ScriptPath\formats\$($Name).format.ps1xml) {
	Update-FormatData `$ScriptPath\formats\$($Name).format.ps1xml
}
#endregion Load Formats

if (-not `$Quiet) {
    Get-$(${NickName})Help
}

#region Module Cleanup
`$ExecutionContext.SessionState.Module.OnRemove = {
	# cleanup when unloading module (if any)
	Get-ChildItem alias: | Where-Object { `$_.Source -match `"$($Name)`" } | Remove-Item
	Get-ChildItem function: | Where-Object { `$_.Source -match `"$($Name)`" } | Remove-Item
	Get-ChildItem variable: | Where-Object { `$_.Source -match `"$($Name)`" } | Remove-Item
}
#endregion Module Cleanup

"@
}

function Get-PSMReadme {
	param (
		[string] $Name,
		[string] $Description
	)
	@"
# $Name - $Description

This is some text to describe what this is and what it does. Prolly want some instructions too.

"@
}
