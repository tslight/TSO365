function Remove-O365OldLicenses {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[int]$NumberOfMonths=1,
	[switch]$CheckAll
    )

    if ($O365Session = New-O365Session) {
	$Params = @{
	    Session = $O365Session
	    Prefix = 'O365'
	    DisableNameChecking = $True
	    AllowClobber = $True
	}
	Import-PSSession @Params | Out-Null
    }

    $OldLicenses = Get-O365OldLicenses -CheckAll:$CheckAll

    $Count = $OldLicenses.Count
    Write-Host @Cyan "Found $Count licenses to remove."
    $OldLicenses | Remove-O365License

    if ($O365Session) {
	Remove-PSSession $O365Session
    }
}
