function Revoke-O365OWA {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object[]]$User
    )

    begin {
	$msg = ""
    }

    process {
	$UPN = $User.UserPrincipalName

	$OWAEnabled = (Get-O365CASMailbox $UPN).OWAEnabled
	if ($OWAEnabled -ne $Null -And $OWAEnabled -eq $False) {
	    $msg += "<b>Already revoked O365 OWA<\/b> for $UPN."
	    Write-Host -Back Black -Fore Cyan $msg
	} else {
	    try {
		Set-O365CASMailbox $UPN -OWAEnabled $False -ErrorAction Stop
		Write-SleepProgress 10 "Revoke O365 OWA"
		$OWAEnabled = (Get-O365CASMailbox $UPN).OWAEnabled
		if ($OWAEnabled -eq $Null -Or $OWAEnabled -eq $True) {
		    $msg += "<b>FAILED to revoke O365 OWA<\/b> for $UPN."
		    $str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
		    $str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
		    Write-Warning $str
		} else {
		    $msg += "<b>Successfully revoked O365 OWA<\/b> for $UPN."
		    $str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
		    $str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
		    Write-Host -Back Black -Fore Green $str
		}
	    } catch {
		$msg += "<b>FAILED to revoke O365 OWA<\/b> for $UPN."
		$str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
		$str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
		Write-Warning $str
	    }
	}
    }

    end {
	return $msg
    }
}
