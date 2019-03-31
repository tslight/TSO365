function New-ExchangeSession {
    [cmdletbinding(SupportsShouldProcess)]
    Param (
	[Parameter(Position=0)]
	[object]$ExchangeCreds=$ExchangeCreds,
	[Parameter(Position=1)]
	[string]$ExchangeConnectionUri=$ExchangeConnectionUri
    )

    $Name = "ExchangeSession"

    if (Get-PSSession -Name $Name -ErrorAction SilentlyContinue) {
	Write-Verbose "Found $Name. Removing and re-creating..."
	Remove-PSSession -Name $Name
    }

    $SessionArgs = @{
	ConfigurationName	= "Microsoft.Exchange"
	Authentication		= "Kerberos"
	Credential		= $ExchangeCreds
	ConnectionUri		= $ExchangeConnectionUri
	Name                    = $Name
	AllowRedirection	= $True
    }

    $ExchangeSession = New-PSSession @SessionArgs

    if ($ExchangeSession) {
	Write-Host "Successfully created new $Name."
	return $ExchangeSession
    } else {
	Write-Warning "FAILED to create $Name."
    }
}
