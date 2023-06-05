﻿function Measure-TokenCount {
<#
	.SYNOPSIS
		Gets the total token count by calculating the average token length and dividing it by four.

	.DESCRIPTION
		The Measure-TokenCount function calculates the total token count of a string by dividing the length of the string by 4 and then rounding it.

	.PARAMETER Code
		The Code that is used to calculate the total token count of the given string.

	.EXAMPLE
		PS C:\> Measure-TokenCount -Code "Write-Host 'Hello, world!'"

		This command calculates the total token count of the string "Write-Host 'Hello, world!'" (7).
#>
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