function Measure-TokenCount {
	[OutputType([int])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Code
	)

	$Code -split "(?<=\s)" | ForEach-Object { 
		$div = $_.Length / 4
		$rounded = [math]::Round(($_.Length / 4), [System.MidpointRounding]::ToNegativeInfinity)
		if ($div -gt $rounded) { $rounded + 1 }
		else { $rounded }
	} | Measure-Object -Sum | ForEach-Object Sum
}