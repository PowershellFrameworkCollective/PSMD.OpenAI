function Add-PsmdOaiFunctionHelp {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path,

		[switch]
		$PassThru,

		[switch]
		$EnableException
	)

	process {
		foreach ($pathEntry in $Path) {
			Invoke-PSFProtectedCommand -ActionString 'Add-PsmdOaiFunctionHelp.Path.Resolving' -Target $pathEntry -ScriptBlock {
				$resolvedPaths = Resolve-PSFPath -Path $pathEntry -Provider FileSystem
			} -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue

			foreach ($resolvedPath in $resolvedPaths) {
				$fsItem = Get-Item -LiteralPath $resolvedPath
				if ($fsItem.PSIsContainer) { continue }

				if (Test-ReSyntax -LiteralPath $fsItem.FullName -Not) {
					Stop-PSFFunction -String 'Add-PsmdOaiFunctionHelp.Error.Syntax' -StringValues $fsItem.FullName -EnableException $EnableException -Cmdlet $PSCmdlet -Continue -Target $fsItem
				}

				$scriptParts = Read-ReAstComponent -LiteralPath $fsItem.FullName -Select FunctionDefinitionAst
				$scriptParts | Where-Object Type -EQ FunctionDefinitionAst | Add-OaiHelp
				Invoke-PSFProtectedCommand -ActionString 'Add-PsmdOaiFunctionHelp.Converting' -ActionStringValues $fsItem.Name -Target $fsItem -ScriptBlock {
					Write-ReAstComponent -Components $scriptParts -PassThru:$PassThru
				} -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue
			}
		}
	}
}