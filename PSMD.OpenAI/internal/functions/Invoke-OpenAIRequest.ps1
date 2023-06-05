function Invoke-OpenAIRequest {
<#
	.SYNOPSIS
		Executes an OpenAI request.

	.DESCRIPTION
		Executes an OpenAI request.

	.PARAMETER Body
		The actual request payload to send.

	.PARAMETER Type
		The type of OpenAI request to invoke. 
		Defaults to ’completions’.
		
	.EXAMPLE
		PS C:\> Invoke-OpenAIRequest -Body @{ prompt = $prompt; max_tokens = 2000 }

		Sends the query in $prompt, expecting no more than 2000 tokens in the response.
#>
	[CmdletBinding()]
	param (
		$Body,

		[string]
		$Type = 'completions'
	)

	Assert-OpenAIConnection -Cmdlet $PSCmdlet

	$url = 'https://{0}.openai.azure.com/openai/deployments/{1}/{2}?api-version={3}' -f $script:token.Resource, $script:token.Deployment, $Type, $script:token.ApiVersion
	Invoke-RestMethod -Method 'Post' -Uri $url -Headers $script:token.GetHeader() -Body ($Body | ConvertTo-Json -Compress)
}