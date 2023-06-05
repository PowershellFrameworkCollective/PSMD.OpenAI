function New-Token {
<#
    .SYNOPSIS
    	Creates a new token object for a given resource and deployment.

    .DESCRIPTION
    	Creates a new token object for a given resource and deployment.
		A token object is repsonsible for generating the authentication header for OpenAI API requests.

		Depending on just how we are connected, this might require renewing session tokens.

    .PARAMETER Resource
    	The name of the resource for the token

    .PARAMETER Deployment
    	The name of the deployment for the token

    .PARAMETER Empty
    	If the token should be empty

    .PARAMETER ApiKey
    	The ApiKey that will be used to create a token

    .PARAMETER ApiVersion
    	The API version that will be used for the request.
		Defaults to 2022-12-01

    .EXAMPLE
    	PS C:\> New-Token -Resource 'user_data' -Deployment 'test-production' -ApiKey $ApiKey

    	Creates a new ApiKey token with the specified resource and deployment, as well as the ApiKey supplied.
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
	[CmdletBinding()]
	param (
		[string]
		$Resource,

		[string]
		$Deployment,

		[Parameter(Mandatory = $true, ParameterSetName = 'Empty')]
		[switch]
		$Empty,

		[Parameter(Mandatory = $true, ParameterSetName = 'Token')]
		[SecureString]
		$ApiKey,

		[string]
		$ApiVersion = '2022-12-01'
	)

	$data = @{
		Created    = Get-Date
		Type       = 'Empty'
		Resource   = $Resource
		Deployment = $Deployment
		ApiVersion = $ApiVersion
	}
	

	switch ($PSCmdlet.ParameterSetName) {
		'Empty' {
			$object = [PSCustomObject]$data
			Add-Member -InputObject $object -MemberType ScriptMethod -Name GetHeader -Value { @{} }
			return $object
		}
		'Token' {
			$data.ApiKey = $ApiKey
			$data.Type = 'ApiKey'
			$object = [PSCustomObject]$data
			Add-Member -InputObject $object -MemberType ScriptMethod -Name GetHeader -Value {
				@{
					'api-key' = [PSCredential]::new("whatever", $this.ApiKey).GetNetworkCredential().Password
					'Content-Type' = 'application/json'
				}
			}
			return $object
		}
		default {
			throw "Not Implemented!"
		}
	}
}