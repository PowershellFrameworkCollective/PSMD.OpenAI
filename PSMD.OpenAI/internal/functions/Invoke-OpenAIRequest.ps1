function Invoke-OpenAIRequest {
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