function Test-MsolStatus {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[string[]]$Sam
    )

    begin {
	$Params = @{
	    DisableNameChecking = $True
	    AllowClobber        = $True
	}
	if ($O365Session = New-O365Session) {
	    Import-PSSession $O365Session -Prefix O365 @Params | Out-Null
	}
	if ($ExchangeSession = New-ExchangeSession) {
	    Import-PSSession $ExchangeSession -Prefix Exchange @Params | Out-Null
	    Set-ExchangeAdServerSettings -ViewEntireForest $True
	}
	$MsolProperties = @(
	    'DisplayName'
	    'UserPrincipalName'
	    'IsLicensed'
	    'Licenses'
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
	$Users = @()
    }

    process {
	if ($User = Get-ADUserBySam $Sam) {
	    $UPN                = $User.UserPrincipalName
	    $MsolUser		= Get-MsolUser -UserPrincipalName $UPN |
	      Select-Object $MsolProperties
	    $ExchangeMailbox	= Get-ExchangeRemoteMailbox $User.SamAccountName
	    $CASMailbox		= Get-O365CASMailbox $User.SamAccountName
	    $IsLicensed		= $MsolUser.IsLicensed
	    $License		= $MsolUser |
	      Select-Object -ExpandProperty Licenses |
	      Select-Object -ExpandProperty AccountSkuId
	    $HasRemoteMailbox	= $ExchangeMailbox.isValid
	    $ActiveSyncEnabled	= $CASMailbox.ActiveSyncEnabled
	    $OWAEnabled		= $CASMailbox.OWAEnabled
	    $MFAEnabled		= $MsolUser.MFA

	    $Properties                 = [ordered]@{
		"Name"			= $User.Name
		"O365 License"		= $IsLicensed
		"O365 License Type"     = $License
		"Exchange Mailbox"	= $HasRemoteMailbox
		"Active Sync Enabled"	= $ActiveSyncEnabled
		"OWA Enabled"		= $OWAEnabled
		"MFA Status"		= $MFAEnabled
	    }
	    New-Object PSObject -Property $Properties
	} else {
	    Write-Warning "Cannot find $Sam in Active Directory."
	}
    }

    end {
	Remove-PSSession $O365Session
	Remove-PSSession $ExchangeSession
    }

}
