function Connect-PsmdOpenAI {
<#
	.SYNOPSIS
		Creates a connection to an OpenAI resource.

	.DESCRIPTION
		Creates a connection to an OpenAI resource.

	.PARAMETER Resource
		The resource name of the OpenAI resource.

	.PARAMETER Deployment
		The name of the specific deployment within the resource to use.

	.PARAMETER ApiKey
		The API key required for authentication.

	.PARAMETER Identity
		Use the current MSI account to connect to the OpenAI resource.
		Not implemented yet.

	.PARAMETER User
		Connect as the current Azure User.
		Not implemented yet.

	.PARAMETER DynamicKey
		While connecting as the current identity, use that access to dynamically retrieve the ApiKey and then continue using the ApiKey.
		Not implemented yet.

	.PARAMETER ApiVersion
		The version of the API to use.
		Default is 2022-12-01.

	.EXAMPLE
		PS C:\> Connect-PsmdOpenAI -Resource "resourcename" -Deployment "mydeployment" -ApiKey $key

		Creates a connection to an Azure Cognitive Services OpenAI resource using an API key.
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
	[CmdletBinding(DefaultParameterSetName = 'User')]
	param (
		[string]
		$Resource = (Get-PSFConfigValue -FullName 'PSMD.OpenAI.Default.Resource'),

		[Parameter(Mandatory = $true)]
		[string]
		$Deployment = (Get-PSFConfigValue -FullName 'PSMD.OpenAI.Default.Resource'),

		[Parameter(ParameterSetName = 'Token')]
		$ApiKey,

		[Parameter(ParameterSetName = 'MSI')]
		[switch]
		$Identity,

		[Parameter(ParameterSetName = 'User')]
		[switch]
		$User,

		[Parameter(ParameterSetName = 'DynamicKey')]
		[switch]
		$DynamicKey,

		[string]
		$ApiVersion = '2022-12-01'
	)

	begin {
		if (-not $Resource) { Stop-PSFFunction -String 'Connect-PsmdOpenAI.NoResource' -EnableException $true -Cmdlet $PSCmdlet }
		if (-not $Deployment) { Stop-PSFFunction -String 'Connect-PsmdOpenAI.NoDeployment' -EnableException $true -Cmdlet $PSCmdlet }
	}
	Process {
		switch ($PSCmdlet.ParameterSetName) {
			'Token' {
				if ($ApiKey -is [securestring]) { $secret = $ApiKey }
				elseif ($ApiKey -is [PSCredential]) { $secret = $ApiKey.Password}
				else { $secret = $ApiKey | ConvertTo-SecureString -AsPlainText -Force }
				$script:token = New-Token -Resource $Resource -Deployment $Deployment -ApiKey $secret -ApiVersion $ApiVersion
			}
			default {
				throw "Not Implemented Yet"
			}
		}
<#
		If ($ManagedIdentity -eq $true) {
			"managed"
			try {
				Connect-AzAccount -Identity

				$MyTokenRequest = Get-AzAccessToken -ResourceUrl "https://cognitiveservices.azure.com"
				$MyToken = $MyTokenRequest.token
				If (!$MyToken) {
					Write-Warning "Failed to get API access token!"
					Exit 1
				}
				$Global:MyHeader = @{"Authorization" = "Bearer $MyToken" }
			}
			catch [System.Exception] {
				Write-Warning "Failed to get Access Token, Error message: $($_.Exception.Message)"; break
			}

		}
		If ($User -eq $true) {
			"USER"
			try {
				Connect-AzAccount

				$MyTokenRequest = Get-AzAccessToken -ResourceUrl "https://cognitiveservices.azure.com"
				$MyToken = $MyTokenRequest.token
				If (!$MyToken) {
					Write-Warning "Failed to get API access token!"
					Exit 1
				}
				$Global:MyHeader = @{"Authorization" = "Bearer $MyToken" }
			}
			catch [System.Exception] {
				Write-Warning "Failed to get Access Token, Error message: $($_.Exception.Message)"; break
			}
		}
		If ($APIkey) {
			"APIKEY"
			$Global:MyHeader = @{"api-key" = $apikey }
		}
		#>
	}
}