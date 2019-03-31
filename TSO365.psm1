#region get public and private function definition files.
$Public  = @(
    Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue
)
$Private = @(
    Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue
)
#endregion

#region source the files
foreach ($Function in @($Public + $Private)) {
    $FunctionPath = $Function.fullname
    try {
	. $FunctionPath # dot source function
    } catch {
	Write-Error -Message "Failed to import function at $(FunctionPath): $_"
    }
}
#endregion

#region read in or create an initial config file and variable
$ConfigFile = "Config.psd1"
$Params     = @{
    BaseDirectory = $PSScriptRoot
    FileName      = $ConfigFile
}
if (Test-Path "$PSScriptRoot\$ConfigFile") {
    try {
	$Config			= Import-LocalizedData @Params
	$ExchangePwdFile	= $Config.ExchangePwdFile
	$ADGlobalCatalog	= $Config.ADGlobalCatalog
	$ExchangeUser		= $Config.ExchangeUser
	$O365User		= $Config.O365User
	$ExchangeConnectionUri	= $Config.ExchangeConnectionUri
	$O365ConnectionUri	= $Config.O365ConnectionUri
	$PSModulePath		= $Config.PSModulePath
	$MsolAddress            = $Config.MsolAddress
	$CodeLicense		= $Config.CodeLicense
	$LicenseCode		= $Config.LicenseCode
	$ExchangeCreds          = Get-Creds $ExchangePwdFile $ExchangeUser
	$O365Creds              = Get-Creds $ExchangePwdFile $O365User
    } catch {
	Write-Warning "Invalid configuration data in $ConfigFile."
	Write-Warning "Please fill out or correct $PSScriptRoot\$ConfigFile."
	Write-Verbose $_.Exception.Message
	Write-Verbose $_.InvocationInfo.ScriptName
	Write-Verbose $_.InvocationInfo.PositionMessage
    }
} else {
    @"
@{
    ExchangePwdFile				= ""
    ADGlobalCatalog				= ""
    ExchangeUser				= ""
    O365User					= ""
    ExchangeConnectionUri			= ""
    O365ConnectionUri				= ""
    PSModulePath				= ""
    MsolAddress                                 = ""
    LicenseCode					= @{
	""                                      = ""
	""                                      = ""
	""                                      = ""
    }
    CodeLicense					= @{
	""                                      = ""
	""                                      = ""
	""                                      = ""
	""                                      = ""
    }
}
"@ | Out-File -Encoding UTF8 -FilePath "$PSScriptRoot\$ConfigFile"
    Write-Warning "Generated $PSScriptRoot\$ConfigFile."
    Write-Warning "Please edit $ConfigFile and re-import module."
}
#endregion

#region set variables visible to the module and its functions only
$Date = Get-Date -UFormat "%Y.%m.%d"
$Time = Get-Date -UFormat "%H:%M:%S"
$Green = @{
    Background = 'Black'
    Foreground = 'Green'
}
$Cyan = @{
    Background = 'Black'
    Foreground = 'Cyan'
}
$Magenta = @{
    Background = 'Black'
    Foreground = 'Magenta'
}
#endregion

#region miscellaneous setup code
if (Get-MsolDomain -ErrorAction SilentlyContinue) {
    Write-Output "Already connected to Microsoft Online..."
} else {
    Write-Output "Connecting and authenticating with Microsoft Online..."
    Connect-MsolService -Credential $O365Creds
}
#endregion

#region export Public functions ($Public.BaseName) for WIP modules
Export-ModuleMember -Function $Public.Basename
#endregion
