function Set-O365ForGB {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object[]]$User
    )

    process {
	if (Get-O365CASMailbox $User.UserPrincipalName -ErrorAction SilentlyContinue) {
	    if ($User.Country -eq "GB") {
		Revoke-O365ActiveSync $User
		Revoke-O365OWA $User
		# This is pointless if Bradley is disabling it to set up user profiles..
		# Enable-O365MFA $User
	    }
	} else {
	    Write-Warning "$($User.Name) does not have a O365 account."
	}
    }
}
