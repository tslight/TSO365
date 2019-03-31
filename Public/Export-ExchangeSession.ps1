function Export-ExchangeSession {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[object]$Session=$(New-ExchangeSession)
    )

    $ExportSessionArgs = @{
	Session		= $Session
	OutputModule	= "$PSModulePath\MSExchange"
	AllowClobber	= $True
	Force		= $True
    }

    Export-PSSession @ExportSessionArgs
}
