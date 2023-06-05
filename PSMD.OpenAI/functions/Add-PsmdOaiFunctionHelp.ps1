function Add-PsmdOaiFunctionHelp {
<#
    .SYNOPSIS
    	Adds PowerShell Comment-Based Help to function definitions in a script file.

    .DESCRIPTION
	    Adds PowerShell Comment-Based Help to function definitions in a script file.
		Reads the script file, parses the syntax trees of the function definitions, and adds the Comment-Based Help.
		The script file is updated with the help included.

    .PARAMETER Path
    	Specifies the path to the script file to read.

	.PARAMETER OutPath
		The folder-path where to write the results to.
		If specified, input files will not be modified.

    .PARAMETER PassThru
    	Return the result objects.
		By default, files are updated silently.

	.PARAMETER Backup
		Whether to create a backup of the file before modifying it.

    .PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.

	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
		PS C:\> Add-PsmdOaiFunctionHelp -Path C:\Scripts\test.ps1

    	The script file located at C:\Scripts\test.ps1 is modified to include Comment-Based Help for each function definition.

#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
	[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'default')]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path,

		[Parameter(ParameterSetName = 'outpath')]
		[string]
		$OutPath,

		[switch]
		$PassThru,

		[Parameter(ParameterSetName = 'inplace')]
		[switch]
		$Backup,

		[switch]
		$EnableException
	)

	begin {
		$param = @{
			PassThru = $PassThru
		}
		if ($OutPath) { $param.OutPath = $OutPath }
		if ($Backup) { $param.Backup = $Backup }
	}
	process {
		foreach ($pathEntry in $Path) {
			Invoke-PSFProtectedCommand -ActionString 'Add-PsmdOaiFunctionHelp.Path.Resolving' -ActionStringValues $pathEntry -Target $pathEntry -ScriptBlock {
				$resolvedPaths = Resolve-PSFPath -Path $pathEntry -Provider FileSystem
			} -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue

			foreach ($resolvedPath in $resolvedPaths) {
				$fsItem = Get-Item -LiteralPath $resolvedPath
				if ($fsItem.PSIsContainer) { continue }

				if (Test-ReSyntax -LiteralPath $fsItem.FullName -Not) {
					Stop-PSFFunction -String 'Add-PsmdOaiFunctionHelp.Error.Syntax' -StringValues $fsItem.FullName -EnableException $EnableException -Cmdlet $PSCmdlet -Continue -Target $fsItem
				}

				$scriptParts = Read-ReAstComponent -LiteralPath $fsItem.FullName -Select FunctionDefinitionAst
				if (-not $scriptParts) { continue }
				$scriptParts | Where-Object Type -EQ FunctionDefinitionAst | Add-OaiHelp
				Invoke-PSFProtectedCommand -ActionString 'Add-PsmdOaiFunctionHelp.Converting' -ActionStringValues $fsItem.Name -Target $fsItem -ScriptBlock {
					Write-ReAstComponent @param -Components $scriptParts
				} -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue
			}
		}
	}
}