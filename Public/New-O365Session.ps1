function New-O365Session {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Position=0)]
	[object]$O365Creds=$O365Creds,
	[Parameter(Position=1)]
	[string]$O365ConnectionUri=$O365ConnectionUri
    )

    $Name = "O365Session"

    if (Get-PSSession -Name $Name -ErrorAction SilentlyContinue) {
	Write-Verbose "Found $Name. Removing and re-creating..."
	Remove-PSSession -Name $Name
    }

    $SessionArgs = @{
	ConfigurationName	= "Microsoft.Exchange"
	Authentication		= "Basic"
	Credential		= $O365Creds
	ConnectionUri		= $O365ConnectionUri
	Name                    = $Name
	AllowRedirection	= $True
    }

    $O365Session = New-PSSession @SessionArgs

    if ($O365Session) {
	Write-Host "Successfully created new $Name."
	return $O365Session
    } else {
	Write-Warning "FAILED to create $Name."
    }
}
