param (
    [switch] $Quiet = $False
)
#region Default Private Variables
# Current script path
[string] $script:ScriptPath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent
[string[]] $script:showhelp = @()
#endregion Default Private Variables

#region Load Private Helpers
# Dot sourcing private script files
Get-ChildItem $script:ScriptPath/private -Recurse -Filter "*.ps1" -File | ForEach-Object {
	. $_.FullName
}
#endregion Load Private Helpers

#region Load Public Helpers
# Dot sourcing public script files
Get-ChildItem $ScriptPath/public -Recurse -Filter "*.ps1" -File | ForEach-Object {
	. $_.FullName

	# From https://www.the-little-things.net/blog/2015/10/03/powershell-thoughts-on-module-design/
	# Find all the functions defined no deeper than the first level deep and export it.
	# This looks ugly but allows us to not keep any uneeded variables from poluting the module.
	([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref] $null, [ref] $null)).FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | Foreach {
		Export-ModuleMember $_.Name
		$showhelp += $_.Name
	}
}
#endregion Load Public Helpers

#region Load Formats
if (test-path $ScriptPath\formats\brshPSFiles.format.ps1xml) {
	Update-FormatData $ScriptPath\formats\brshPSFiles.format.ps1xml
}
#endregion Load Formats

if (-not $Quiet) {
    Get-Help
}

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
	# cleanup when unloading module (if any)
	Get-ChildItem alias: | Where-Object { $_.Source -match "brshPSFiles" } | Remove-Item
	Get-ChildItem function: | Where-Object { $_.Source -match "brshPSFiles" } | Remove-Item
	Get-ChildItem variable: | Where-Object { $_.Source -match "brshPSFiles" } | Remove-Item
}
#endregion Module Cleanup

