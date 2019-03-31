function Enable-ExchangeMailbox {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object]$User
    )

    begin {
	$msg = ""
    }

    process {
	$UPN			= $User.UserPrincipalName
	$Sam			= $User.SamAccountName
	$RemoteRoutingAddress	= "$Sam@$MsolAddress"

	$ExchangeArgs = @{
	    Identity			= $UPN
	    RemoteRoutingAddress	= $RemoteRoutingAddress
	    ErrorAction                 = "Stop"
	}

	Write-Host "Enabling mailbox for $UPN..."

	if (Get-ExchangeRemoteMailbox $UPN -ErrorAction SilentlyContinue) {
	    $msg += "<b>$UPN already has an Exchange Remote Mailbox.<\/b>"
	    Write-Host -Back Black -Fore Cyan $msg
	} else {
	    try {
		$Mailbox = Enable-ExchangeRemoteMailbox @ExchangeArgs
	    } catch {
		Write-Warning $_
	    }
	    # try catch is inconsistent with exchange session...
	    if ($Mailbox) {
		$msg += "<b>Successfully enabled<\/b> mailbox for $UPN."
		$str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
		$str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
		Write-Host -Back Black -Fore Green $str
	    } else {
		$msg += "<b>FAILED<\/b> to enable remote mailbox for $UPN."
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
