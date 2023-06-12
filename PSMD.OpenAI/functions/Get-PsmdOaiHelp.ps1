function Get-PsmdOaiHelp {
<#
    .SYNOPSIS
    	Get help from the OpenAI Service for given code or command.

    .DESCRIPTION
    	Get help from the OpenAI Service for given code or command.

    .PARAMETER Command
    	The command for which help is being requested

    .PARAMETER Code
    	The code for which help is being requested

    .EXAMPLE
    	PS C:\> Get-PsmdOaiHelp -Command mkdir

    	Gets the help for the mkdir command from the OpenAI service.

    .EXAMPLE
    	PS C:\> Get-PsmdOaiHelp -Code $sourceCode

		Gets the help for the command specified in the code from the OpenAI service.
#>
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
			try { $help = Get-PsmdOaiCompletion -MaxTokens (4097 - $tokenCount - 200) -Prompt ($basePrompt -f $Code) -ErrorAction Stop }
			catch {
				$PSCmdlet.WriteError($_)
				return
			}
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
				try { $help = Get-PsmdOaiCompletion -MaxTokens (4097 - $tokenCount - 200) -Prompt ($basePrompt -f $commandText) -ErrorAction Stop }
				catch {
					$PSCmdlet.WriteError($_)
					continue
				}
				[PSCustomObject]@{
					Command = $commandObject.Name
					Code = $Code
					Help = $help
				}
			}
		}
	}
}