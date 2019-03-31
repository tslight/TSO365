function Export-O365Session {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[object]$Session=$(New-O365Session)
    )

    $ExportSessionArgs = @{
	Session		= $Session
	OutputModule	= "$PSModulePath\MSO365"
	AllowClobber	= $True
	Force		= $True
    }

    Export-PSSession @ExportSessionArgs
}
