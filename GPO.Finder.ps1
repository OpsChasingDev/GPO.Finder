<#
    - add in more settings to check
#>
param (
    [switch]$IncludeDisabled
)

$Result = @()
$GPO = Get-GPO -All

foreach ($g in $GPO) {
    [xml]$Report = Get-GPOReport -Guid $g.Id.Guid -ReportType 'XML'
    
    # skip the GPO if disabled and user has not specified to include disabled
    if (
        $Report.GPO.LinksTo.Enabled -ne 'true' -and
        !$IncludeDisabled
        ) { Continue }

    # Folder Redirection
    if ($Report.GPO.User.ExtensionData.Name -contains "Folder Redirection") {
        $obj = [PSCustomObject]@{
            Setting = "Folder Redirection"
            GPO = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }
}

Write-Output $Result