<#
$GPO = Get-GPO -All
foreach ($g in $GPO) {
    Get-GPOReport -Guid $g.Id.Guid -ReportType XML
    foreach ($s in $Setting) {
        see if the xml path to the desired settings exists
        if (it exists) {
            create a custom obj with the GPO Name, Guid, and Settings controlling it
            (also needs to include whether or not the gpo is linked and enabled)
            return the obj
        }
        if it doesn't exist, continue to the next item in the loop
    }
}

- default output should be only GPOs enabled and linked
    - param for -IncludeDisabled
    - param for -IncludeUnlinked

#>
param (
    [switch]$IncludeDisabled,
    [switch]$IncludeUnlinked
)
$Result = @()
$GPO = Get-GPO -All

foreach ($g in $GPO) {
    [xml]$Report = Get-GPOReport -Guid $g.Id.Guid -ReportType 'XML'

    # Folder Redirection
    if ($Report.GPO.User.ExtensionData.Name -contains "Folder Redirection") {
        $obj = [PSCustomObject]@{
            Setting = "Folder Redirection"
            GPO = $g.DisplayName
            Linked = $Report.GPO.LinksTo.SOMPath
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }
}
Write-Output $Result