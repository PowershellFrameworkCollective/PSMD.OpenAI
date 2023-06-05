function Get-PsmdOaiCompletion {
<#
.SYNOPSIS
    Gets completion suggestions from the OpenAI-driven Autocomplete model

.DESCRIPTION
    Invokes the OpenAI Autocomplete model for the specified prompt and returns choices.

.PARAMETER Prompt
    The prompt to pass to the OpenAI Autocomplete model.

.PARAMETER MaxTokens
    The maximum amount of tokens to return.
	The sent token plus the expected result must not be above 4097!

.PARAMETER Raw
    Returns the raw response object instead of the just the choices.

.EXAMPLE
    PS C:\> Get-PsmdOaiCompletion -Prompt "The quick "

    Returns completion suggestons for the input prompt "The quick " as strings.

.EXAMPLE
    PS C:\> Get-PsmdOaiCompletion -Prompt "The quick " -Raw
    
    Returns the raw response object from the OpenAI Autocomplete model.
#>
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