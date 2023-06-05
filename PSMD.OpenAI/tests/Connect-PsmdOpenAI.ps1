function Connect-PsmdOpenAI {
	[CmdletBinding(DefaultParameterSetName = 'User')]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Resource,

		[Parameter(Mandatory = $true)]
		[string]
		$Deployment,

		[Parameter(ParameterSetName = 'Token')]
		[string]
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

	Process {
		switch ($PSCmdlet.ParameterSetName) {
			'Token' {
				$script:token = New-Token -Resource $Resource -Deployment $Deployment -ApiKey $ApiKey -ApiVersion $ApiVersion
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