<#
$GPO = Get-GPO -All
foreach ($g in $GPO) {
    Get-GPOReport -Guid $g.Id.Guid -ReportType XML
    foreach ($s in $Setting) {
        see if the xml path to the desired settings exists
        if (it exists) {
            create a custom obj with the GPO Name, Guid, and Settings controlling it
            return the obj
        }
        if it doesn't exist, continue to the next item in the loop
    }
}
#>

$GPO = Get-GPO -All
foreach ($g in $GPO) {
    [xml]$Report = Get-GPOReport -Guid $g.Id.Guid -ReportType 'XML'
    if ($Report.GPO.User.ExtensionData.Name -contains "Folder Redirection") {
        Write-Output $g.DisplayName
    }
}