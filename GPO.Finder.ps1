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
    # check for IncludeDisabled or IncludeUnlinked needs to happen here so unnecessary processing doesn't take place
    <#
    if (!$IncludeUnlinked and no links are found) {
        continue to the next $g
    }
    if (!$IncludeDisabled and the gpo is disabled) {
        continue to the next $g
    }
    #>

    # Folder Redirection
    if ($Report.GPO.User.ExtensionData.Name -contains "Folder Redirection") {
        $obj = [PSCustomObject]@{
            Setting = "Folder Redirection"
            GPO = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        if ($IncludeUnlinked) {
            $obj | Add-Member @{ 'Linked' = $Report.GPO.LinksTo.SOMPath }
        }
        $Result += $obj
    }
}
Write-Output $Result