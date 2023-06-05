function Assert-OpenAIConnection {
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