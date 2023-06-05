function Assert-OpenAIConnection {
<#
	.SYNOPSIS
		Checks to make sure that a connection to OpenAI is established prior to running the calling command.

	.DESCRIPTION
		The Assert-OpenAIConnection function will check to see if a connection to OpenAI has been established before running the calling command.
		If a valid connection has not been established, the function will throw a terminating error.

	.PARAMETER Cmdlet
		The $PSCmdlet variable of the calling command.
		Used to throw a terminating error in the context of the caller, making this helper function invisible to the user.

	.EXAMPLE
		PS C:> Assert-OpenAIConnection -Cmdlet $PSCmdlet

		Checks to make sure that a connection to OpenAI is established prior to running the calling command.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)

	if ($script:token -and $script:token.Type -ne 'Empty') { return }

	$record = [PSFramework.Meta.PsfErrorRecord]::new(
		'Not connected to OpenAI! Call Connect-PsmdOpenAI first.',
		[System.Management.Automation.ErrorCategory]::InvalidOperation,
		'Not Connected'
	)
	$Cmdlet.ThrowTerminatingError($record)
}