function Revoke-O365ActiveSync {
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

	$ActiveSyncEnabled = (Get-O365CASMailbox $UPN).ActiveSyncEnabled
	if ($ActiveSyncEnabled -ne $Null -And $ActiveSyncEnabled -eq $False) {
	    $msg += "<b>Already revoked O365 ActiveSync<\/b> for $UPN."
	    Write-Host -Back Black -Fore Cyan $msg
	} else {
	    try {
		Set-O365CASMailbox $UPN -ActiveSyncEnabled $False -ErrorAction Stop
		Write-SleepProgress 10 "Revoke O365 Active Sync"
		$ActiveSyncEnabled = (Get-O365CASMailbox $UPN).ActiveSyncEnabled
		if ($ActiveSyncEnabled -eq $Null -Or $ActiveSyncEnabled -eq $True) {
		    $msg += "<b>FAILED to revoke O365 ActiveSync<\/b> for $UPN."
		    $str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
		    $str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
		    Write-Warning $str
		} else {
		    $msg += "<b>Successfully revoked O365 ActiveSync<\/b> for $UPN."
		    $str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
		    $str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
		    Write-Host -Back Black -Fore Green $str
		}
	    } catch {
		$msg += "<b>FAILED to revoke O365 ActiveSync<\/b> for $UPN."
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
