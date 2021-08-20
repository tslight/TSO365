function Remove-O365License {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object[]]$MsolUser
    )

    process {
	$UPN = $MsolUser.UserPrincipalName
	$License = $MsolUser |
	  Select-Object -ExpandProperty Licenses |
	  Select-Object -ExpandProperty AccountSkuId

	try {
	    $Params = @{
		UserPrincipalName = $UPN
		RemoveLicenses    = $License
		ErrorAction       = 'Stop'
	    }
	    Set-MsolUserLicense @Params
	    Write-Host @Green "Removed $license license for $UPN."
	} catch {
	    Write-Warning "FAILED to remove $License for $UPN."
	    Write-Warning $_.InvocationInfo.ScriptName
	    Write-Warning $_.InvocationInfo.Line
	    Write-Warning $_.Exception.Message
	}
    }
}
