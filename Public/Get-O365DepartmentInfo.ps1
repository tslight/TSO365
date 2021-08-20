function Get-O365DepartmentInfo {
    <#
.SYNOPSIS
Query a department for licensed O365 users.

.DESCRIPTION
Lookup Microsoft Office 365 Online licensed user information for a
particular department.

.PARAMETER Department
An MSOL department name string.

.INPUTS
A string correlating to a name of an O365 department.

.OUTPUTS
An object with various pertinent properties of each user and license.

.EXAMPLE
Get-MsolUser -All | Select -Expand Department -Unique | Get-O365DepartmentInfo

.LINK
https://github.com/tslight/TSO365
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[string[]]$Department
    )

    begin {
	$Properties = @(
	    @{
		Name = "Name"
		Expression = {$_.DisplayName}
	    }
	    'Title'
	    'Department'
	    @{
		Name = "Location"
		Expression = {$_.State}
	    }
	    'City'
	    'Country'
	    @{
		Name = "Licensed"
		Expression = {$_.IsLicensed}
	    }
	    @{
		Name = "Disabled"
		Expression = {$_.BlockCredential}
	    }
	    @{
		Name = "License ID"
		Expression = {$_.Licenses.AccountSKUid}
	    }
	    @{
		Name = "License Code"
		Expression = {$LicenseCode[$_.Licenses.AccountSKUid]}
	    }
	)
	Write-Verbose "Starting department processing..."
    }

    process {
	# You need both - foreach to  manage an array of parameters values.
	# process block - To manage an array of piped values.
	foreach ($Dep in $Department) {
	    Write-Verbose "Getting info for $Dep.."
	    Get-MsolUser -All |
	      Where-Object {
		  ($_.Department -eq $Dep) -And ($_.IsLicensed -eq $True)
	      } | Select-Object $Properties
	}
    }

    end {
	Write-Verbose "Finished processing departments."
    }
}
