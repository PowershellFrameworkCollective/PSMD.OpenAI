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
		foreach ($componentObject in $Component) {
			if ($componentObject.Ast.GetHelpContent()) {
				$componentObject
				continue
			}

			$textToScan = Resolve-FunctionCode -Ast $componentObject.Ast
			$attempt = 0
			while ($attempt -lt 3) {
				$helpResult = Get-PsmdOaiHelp -Code $textToScan
				$newText = $componentObject.Text.SubString(0, $componentObject.Text.IndexOf("`n")), $helpResult.Help.Trim(), $componentObject.Text.SubString($componentObject.Text.IndexOf("`n")) -join ""
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