function Get-O365OldLicenses {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[int]$NumberOfMonths=1,
	[switch]$CheckAll
    )

    $Date = (Get-Date).AddMonths(-$NumberOfMonths)
    $OldMsolUsers = @()

    if ($CheckAll) {
	Write-Host "Getting all licensed users (this may take a while)..."
	$MsolLicensedUsers = Get-MsolUser -All |
	  Where { $_.IsLicensed -eq $True }
    } else {
	Write-Host "Getting all disabled, but still licensed users (this may take a while)..."
	$MsolLicensedUsers = Get-MsolUser -All |
	  Where { ($_.IsLicensed -eq $True) -And ($_.BlockCredential -eq $True) }
    }

    foreach ($User in $MsolLicensedUsers) {
	$UPN = $User.UserPrincipalName

	$ADUserArgs = @{
	    Filter = {UserPrincipalname -eq $UPN}
	    Server = $ADGlobalCatalog
	    Properties = @(
		"AccountExpirationDate",
		"LastLogonDate",
		"Enabled"
	    )
	}

	$ADUser		= Get-ADUser @ADUserArgs
	$ExpirationDate	= $ADUser.AccountExpirationDate
	$LastLogonDate	= $ADUser.LastLogonDate
	$Enabled        = $ADUser.Enabled

	if ($ExpirationDate -And $ExpirationDate -lt $Date) {
	    Write-Host -Back Black -Fore Magenta (
		"$UPN expiration date ($ExpirationDate) is older than $Date."
	    )
	    $OldMsolUsers += $User
	    continue
	}

	if ($Enabled -eq $False -And $LastLogonDate -lt $Date) {
	    Write-Host -Back Black -Fore Magenta (
		"$UPN is disabled, and hasn't logged on later than $Date."
	    )
	    $OldMsolUsers += $User
	}
    }

    return $OldMsolUsers
}
