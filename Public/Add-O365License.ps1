function Add-O365License {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object]$User
    )

    begin {
	$msg = ""
    }

    process {
	$UPN = $User.UserPrincipalName
	$Country = $User.Country
	$MsolUser = Get-MsolUser -UserPrincipalName $User.UserPrincipalName -ErrorAction SilentlyContinue

	if ($MsolUser.IsLicensed) {
	    $Licenses = $MsolUser.Licenses.AccountSkuid | % { $LicenseCode[$_] }
	    $msg += "<b>$UPN already has $Licenses<\/b> Office 365 license(s)."
	    Write-Host -Back Black -Fore Cyan $msg
	} else {
	    if ($User.co -eq "Singapore" -and $User.Company -eq "Clear" -and $User.Contract -eq "Temp") {
		$LicenseCode = "E1"
	    } else {
		$LicenseCode = $User.extensionattribute12
	    }
	    if ($LicenseCode) {
		if ($CodeLicense.ContainsKey($LicenseCode)) {
		    $LicenseSku = $CodeLicense[$LicenseCode]
		    Write-Host "Adding $LicenseCode license to $UPN..."
		    try {
			Set-MsolUser -UserPrincipalName $UPN -UsageLocation $Country -ErrorAction Stop
			Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses $LicenseSku -ErrorAction Stop
		    } catch {
			Write-Warning $_
		    }
		    $MsolUser = Get-MsolUser -UserPrincipalName $User.UserPrincipalName -ErrorAction SilentlyContinue
		    if ($MsolUser.IsLicensed) {
			$msg += "<b>Successfully added $LicenseCode<\/b> ($LicenseSku) license to $UPN."
			$str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
			$str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
			Write-Host -Back Black -Fore Green $str
		    } else {
			$msg += "<b>FAILED to add $LicenseCode<\/b> ($LicenseSku) license to $UPN."
			$str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
			$str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
			Write-Warning $str
		    }
		} else {
		    $msg += "<b>Unknown license type $LicenseCode for $UPN. ABORTING.<\/b>"
		    $str = $msg -Replace "<br>| <br>|<ul>|<\\/li>|<\\/ul>","`n`r"
		    $str = $msg -Replace "<b>|<\\/b>|<\/b>|<i>|<i> |<\\/i>|<li>",""
		    Write-Warning $str
		}
	    } else {
		$msg += "<b>Cannot find an O365 license type for $UPN. ABORTING.<\/b>"
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
