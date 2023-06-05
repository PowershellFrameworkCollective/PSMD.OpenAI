function Get-PsmdOaiCompletion {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Prompt,

		[int]
		$MaxTokens = 1000,

		[switch]
		$Raw
	)

	begin {
		Assert-OpenAIConnection -Cmdlet $PSCmdlet
	}
	process {
		$results = Invoke-OpenAIRequest -Body @{
			prompt     = $Prompt
			max_tokens = $MaxTokens
		}
		if ($Raw) { return $results }
		$results.choices.text
	}
}