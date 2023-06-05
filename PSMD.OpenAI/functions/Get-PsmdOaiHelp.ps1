function Get-PsmdOaiHelp {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Command')]
		[string]
		$Command,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Code')]
		[string]
		$Code
	)

	begin {
		Assert-OpenAIConnection -Cmdlet $PSCmdlet

		$basePrompt = @'
Write the help for the following PowerShell Function in the PowerShell Comment Based Help format.

{0}
'@
	}
	process {
		if ($Code) {
			$tokenCount = Measure-TokenCount -Code ($basePrompt -f $Code)
			$help = Get-PsmdOaiCompletion -MaxTokens (4097 - $tokenCount - 200) -Prompt ($basePrompt -f $Code)
			[PSCustomObject]@{
				Command = ''
				Code = $Code
				Help = $help
			}
		}

		if ($Command) {
			foreach ($commandObject in Get-Command -Name $Command) {
				$commandText = @"
function $($commandObject.Name) {
$($commandObject.Definition)
}
"@
				$tokenCount = Measure-TokenCount -Code ($basePrompt -f $commandText)
				$help = Get-PsmdOaiCompletion -MaxTokens (4097 - $tokenCount - 200) -Prompt ($basePrompt -f $commandText)
				[PSCustomObject]@{
					Command = $commandObject.Name
					Code = $Code
					Help = $help
				}
			}
		}
	}
}