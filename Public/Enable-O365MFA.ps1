function Enable-O365MFA {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object[]]$User
    )

    begin {
	$TypeName =  Microsoft.Online.Administration.StrongAuthenticationRequirement
	$Requirement = New-Object -TypeName $TypeName
	$Requirement.RelyingParty = "*"
	$Requirement.RememberDevicesNotIssuedBefore = (Get-Date)
	$Requirement.State = "Enforced"
	$Properties = @(
	    'DisplayName'
	    'UserPrincipalName'
	    'IsLicensed'
	    @{
		Name = "MFA"
		Expression = {
		    if ( $_.StrongAuthenticationRequirements.State -ne $Null) {
			$_.StrongAuthenticationRequirements.State
		    } else {
			"Disabled"
		    }
		}
	    }
	)
    }

    process {
	foreach ($u in $User) {
	    $UPN = $u.UserPrincipalName
	    try {
		Set-MsolUser -UserPrincipalName $UPN -StrongAuthenticationRequirements $Requirement
		Write-SleepProgress 10 "Enable O365 MFA"
		$MsolUser = Get-MsolUser -UserPrincipalName $UPN | Select-Object $Properties
		if ($MsolUser.MFA -eq "Enforced") {
		    Write-Host "Successfully enabled O365 MFA for $UPN."
		} else {
		    Write-Warning "FAILED to enable O365 MFA for $UPN."
		}
	    } catch {
		Write-Warning "FAILED to enable O365 MFA for $UPN."
	    }
	}
    }
}
