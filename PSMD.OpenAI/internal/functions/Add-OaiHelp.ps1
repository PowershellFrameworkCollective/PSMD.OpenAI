function Add-OaiHelp {
<#
.SYNOPSIS
    Adds help to the provided function, if needed.

.DESCRIPTION
    Adds help to the provided function, if needed.
	If the command already has ANY help, no action will be taken.

.PARAMETER Component
    Function definitions as parsed from the Read-ReAstComponent command.

.EXAMPLE
    PS C:\> Read-ReAstComponent -Path "C:\Temp\MyScript.ps1" -Select FunctionDefinitionAst | Add-OaiHelp | Write-ReAstComponent
	
	Reads all function definitions from 'C:\Temp\MyScript.ps1' and adds help to them if needed.
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		[Refactor.Component.AstResult[]]
		$Component
	)
	process {
		:main foreach ($componentObject in $Component) {
			if ($componentObject.Ast.GetHelpContent()) {
				$componentObject
				continue
			}

			$textToScan = Resolve-FunctionCode -Ast $componentObject.Ast
			$attempt = 0
			while ($attempt -lt 3) {
				$helpResult = $null
				try { $helpResult = Get-PsmdOaiHelp -Code $textToScan -ErrorAction Stop }
				catch {
					$PSCmdlet.WriteError($_)
					$componentObject
					continue main
				}

				if (-not $helpResult) { $attempt++; continue }
				$insertIndex = $componentObject.Text.IndexOf("`n",$componentObject.Text.IndexOf("{"))
				$newText = $componentObject.Text.SubString(0, $insertIndex), "`n", $helpResult.Help.Trim(), $componentObject.Text.SubString($insertIndex) -join ""
				if (Test-ReSyntax -Code $newText) { break }
				$attempt++
			}
			if ($attempt -lt 3) {
				$componentObject.NewText = $newText
			}
			$componentObject
		}
	}
}