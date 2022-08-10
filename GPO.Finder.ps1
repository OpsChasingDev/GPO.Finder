<#
    - progress bar
    - add in more settings to check
        - drive mapping
        - printer deployment
        - software deployment
#>
param (
    [switch]$IncludeDisabled
)

$Result = @()
$GPO = Get-GPO -All
$Count = $GPO.Count
$Iteration = 0

foreach ($g in $GPO) {
    $Iteration += 1
    Write-Progress -Activity "Scanning GPOs..." -Status "$([math]::Round((($Iteration / $Count) * 100), 0))%" -PercentComplete (($Iteration / $Count) * 100)
    [xml]$Report = Get-GPOReport -Guid $g.Id.Guid -ReportType 'XML'
    
    # skip the GPO if disabled and user has not specified to include disabled
    if (
        $Report.GPO.LinksTo.Enabled     -ne 'true' -or
        $Report.GPO.Computer.Enabled    -ne 'true' -or
        $Report.GPO.User.Enabled        -ne 'true' -and
        !$IncludeDisabled
    ) { Continue }

    # Folder Redirection
    if ($Report.GPO.User.ExtensionData.Name -contains "Folder Redirection") {
        $obj = [PSCustomObject]@{
            Setting = "Folder Redirection"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Workstation Administrator
    if ($Report.GPO.Computer.ExtensionData.Extension.LocalUsersandGroups.Group.Name -eq 'Administrators (built-in)') {
        $obj = [PSCustomObject]@{
            Setting = 'Workstation Administrator'
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }
}

Write-Output $Result