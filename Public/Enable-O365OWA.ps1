function Enable-O365OWA {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[Microsoft.ActiveDirectory.Management.ADAccount[]]$User
    )

    begin {
	try {
	    Get-Command Get-O365CASMailbox -ErrorAction Stop | Out-Null
	} catch {
	    Write-Warning "Can't connect to Office 365."
	    Write-Warning (
		"Please create (using New-O365Session) and import (Using Import-PSSession)."
	    )
	    Write-Warning $_.InvocationInfo.ScriptName
	    Write-Warning $_.InvocationInfo.Line
	    Write-Warning $_.Exception.Message
	    break
	}
    }

    process {
	$UPN = $User.UserPrincipalName

	$OWAEnabled = (Get-O365CASMailbox $UPN).OWAEnabled

	if ($OWAEnabled -ne $Null -And $OWAEnabled -eq $False) {
	    try {
		Set-O365CASMailbox $UPN -OWAEnabled $True -ErrorAction Stop | Out-Null
		Write-SleepProgress 10 "Enable O365 OWA"
		$OWAEnabled = (Get-O365CASMailbox $UPN).OWAEnabled
		if ($OWAEnabled -eq $Null -Or $OWAEnabled -eq $True) {
		    Write-Host @Cyan (
			"Successfully enabled Office 365 Online Web Access for $UPN."
		    )
		} else {
		    Write-Warning (
			"Failed to enable Office 365 Online Web Access for $UPN"
		    )
		}
	    } catch {
		Write-Warning (
		    "Failed to enable Office 365 Online Web Access for $UPN"
		)
		Write-Warning $_.InvocationInfo.ScriptName
		Write-Warning $_.InvocationInfo.Line
		Write-Warning $_.Exception.Message
	    }
	} else {
	    Write-Host @Cyan (
		"Office 365 Online Web Access is already enabled for $UPN."
	    )
	}
    }
}
