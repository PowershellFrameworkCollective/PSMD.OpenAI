# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Add-PsmdOaiFunctionHelp.Converting'     = 'Adding help to functions in {0}' # $fsItem.Name
	'Add-PsmdOaiFunctionHelp.Error.Syntax'   = 'Syntax error in file! Skipping {0}' # $fsItem.FullName
	'Add-PsmdOaiFunctionHelp.Path.Resolving' = 'Resolving {0}' # $pathEntry

	'Connect-PsmdOpenAI.NoDeployment'        = 'Failed to connect: No Deployment specified!' # 
	'Connect-PsmdOpenAI.NoResource'          = 'Failed to connect: No Resource specified!' # 
}