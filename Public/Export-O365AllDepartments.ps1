function Export-O365AllDepartments {
    <#
    .SYNOPSIS
    Creates a spreadsheet showing O365 usage details.

    .DESCRIPTION
    Generate an Excel spreadsheet containing details of each departments usage
    and users. Each department is first exported to a Csv and then each Csv
    becomes a worksheet in Excel.

    .PARAMETER Path

    A path to store the resulting Csvs and Excel spreadsheet under. Csvs will be
    stored in $Path\Csv\$Date and the Excel sheet will be named
    O365-Report-$Date, where $Date is today's date..

    .PARAMETER Force
    A swttch to force overwriting of existing files under the path.

    .EXAMPLE
    Export-O365AllDepartments -Path C:\Reports\O365
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)]
	[System.IO.FileInfo]$Path,
	[switch]$Force
    )

    $Date     = Get-Date -UFormat "%Y.%m.%d"
    $CsvPath  = "$Path\O365\Csv\$Date"
    $XlsxPath = "$Path\O365"

    New-Path -Type Directory $CsvPath
    New-Path -Type Directory $XlsxPath

    Write-Host "Finding all departments (this may take a while)..."
    $Departments = Get-MsolUser -All | Select-Object -ExpandProperty Department -Unique

    foreach ($Department in $Departments) {
	if ((Test-Path -Path "$CsvPath\$Department.csv" -PathType leaf) -And -Not $Force) {
	    Write-Warning "$CsvPath\$Department.csv already exists (use -Force to overwrite)."
	} else {
	    Write-Host -Back Black -Fore Cyan "Creating $CsvPath\$Department.csv..."
	    if ($DepartmentInfo = Get-O365DepartmentInfo $Department) {
		$DepartmentInfo | Export-Csv "$CsvPath\$Department.csv" -NoTypeInformation
	    } else {
		Write-Host -Back Black -Fore Magenta (
		    "$Department has no licensed users. Not creating Csv."
		)
	    }
	}
    }

    Write-Host "Creating Excel Spreadsheet From Csvs at $XlsxPath\O365-Report-$Date.xlsx"
    Get-ChildItem "$CsvPath\*.csv" | Convert-CsvToXls -Xlsx "$XlsxPath\O365-Report-$Date"
}
