function Resolve-FunctionCode {
<#
	.SYNOPSIS
		Resolves the function code to send to OpenAI based on the provided PowerShell AST object

	.DESCRIPTION
		Resolves the function code to send to OpenAI based on the provided PowerShell AST object.
		It ensures the total token count is below the limit given, truncating code parts as needed.

	.PARAMETER Ast
		The PowerShell AST object representing the function code.

	.PARAMETER TokenLimit
		The maximum token count to be allowed.
		Defaults to: 3000

	.EXAMPLE 
		PS C:\> Resolve-FunctionCode -Ast $ast

		Returns the text value of the function AST provided, as should be sent to OpenAI
#>
	[OutputType([string])]
	[CmdletBinding()]
	param (
		[System.Management.Automation.Language.FunctionDefinitionAst]
		$Ast,

		[int]
		$TokenLimit = 3000
	)

	if ((Measure-TokenCount -Code $Ast.Extent.Text) -lt $TokenLimit) {
		return $Ast.Extent.Text | Set-String -OldValue '\s+' -NewValue ' '
	}

	$keyWord = 'function'
	if ($Ast.IsFilter) { $keyWord = 'filter' }
	if ($Ast.IsWorkflow) { $keyWord = 'workflow' }

	$textHeader = @(
		'{0} {1} {{' -f $keyWord, $Ast.Name
	) + @(
		$Ast.Body.ParamBlock.Attributes.Extent.Text | Split-String "`n" | Set-String "^\s+" | Join-String "`n"
	) + @(
		$Ast.Body.ParamBlock.Extent.Text | Split-String "`n" | Set-String "^\s+" | Join-String "`n"
	)

	$beginBlock = ''
	if ($Ast.Body.BeginBlock) {
		$beginBlock = @"
begin {
$($Ast.Body.BeginBlock.Statements.Extent.Text | Split-String "`n" | Set-String "^\s+" | Join-String "`n")
}
"@
	}
	$processBlock = ''
	if ($Ast.Body.ProcessBlock) {
		$processBlock = @"
process {
$($Ast.Body.ProcessBlock.Statements.Extent.Text | Split-String "`n" | Set-String "^\s+" | Join-String "`n")
}
"@
	}
	$endBlock = ''
	if ($Ast.Body.EndBlock) {
		$endBlock = @"
end {
$($Ast.Body.EndBlock.Statements.Extent.Text | Split-String "`n" | Set-String "^\s+" | Join-String "`n")
}
"@
	}

	$cases = @(
		@($textHeader) + @($beginBlock) + @($processBlock) + @($endBlock) + @('}') | Join-String "`n"
		@($textHeader) + @($beginBlock) + @($processBlock) + @('}') | Join-String "`n"
		@($textHeader) + @($processBlock) + @('}') | Join-String "`n"
	)

	foreach ($case in $cases) {
		if ((Measure-TokenCount -Code $case) -lt $TokenLimit) {
			return $case | Set-String -OldValue '\s+' -NewValue ' '
		}	
	}

	$lines = $processBlock -split "`n"
	foreach ($index in 0..$lines.Count) {
		$newProcess = $lines[0..($lines.Count - 1 - $index)]
		$newText = @($textHeader) + @($newProcess) + @('}') | Join-String "`n"
		if ((Measure-TokenCount -Code $newText) -lt $TokenLimit) {
			return $newText | Set-String -OldValue '\s+' -NewValue ' '
		}
	}

	throw "Unable to generate a scanable function code with $TokenLimit tokens. This usually only happens when the param block is too large to accomodate anything else. Param block size: $($Ast.Body.ParamBlock.Extent.Text.Length)"
}