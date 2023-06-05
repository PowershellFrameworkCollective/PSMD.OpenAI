function New-Token {
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
		[string]
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
					'api-key' = $this.ApiKey
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