<#
    - add in more settings to check
        - drive mapping
        - printer deployment
        - software deployment
#>
param (
    [switch]$IncludeDisabled
)

# setup info
$Result = @()
try { $GPO = Get-GPO -All -ErrorAction 'Stop' }
catch {
    Write-Error "You must have access to the GroupPolicy module in order to use Get-GPO and Get-GPOReport."
    break
}
$Count = $GPO.Count
$Iteration = 0

foreach ($g in $GPO) {
    # writing progress
    $Iteration += 1
    $PercentComplete = (($Iteration / $Count) * 100)
    $ProgressSplat = @{
        Activity        = "Scanning GPOs..."
        Status          = "$([math]::Round($PercentComplete, 0))%"
        PercentComplete = $PercentComplete
    }
    Write-Progress @ProgressSplat

    # generate XML report for the current GPO
    [xml]$Report = Get-GPOReport -Guid $g.Id.Guid -ReportType 'XML'
    
    # skip the GPO if disabled and user has not specified to include disabled
    if (
        $Report.GPO.LinksTo.Enabled -ne 'true' -or
        $Report.GPO.Computer.Enabled -ne 'true' -or
        $Report.GPO.User.Enabled -ne 'true' -and
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

    # Printer Deployments
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Printers" -or
        $Report.GPO.User.ExtensionData.Name -contains "Printers") {
        $obj = [PSCustomObject]@{
            Setting = "Printer Deployment"
            GPO = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }
}

Write-Output $Result