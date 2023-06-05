function Add-OaiHelp {
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