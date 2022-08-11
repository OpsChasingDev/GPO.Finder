<#
    - add in more settings to check
        - drive mapping
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

    # Printers
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Printers" -or
        $Report.GPO.User.ExtensionData.Name -contains "Printers") {
        $obj = [PSCustomObject]@{
            Setting = "Printer Deployment"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Environment Variables
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Environment Variables" -or
        $Report.GPO.User.ExtensionData.Name -contains "Environment Variables") {
        $obj = [PSCustomObject]@{
            Setting = "Environment Variables"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Files
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Files" -or
        $Report.GPO.User.ExtensionData.Name -contains "Files") {
        $obj = [PSCustomObject]@{
            Setting = "Files"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Folders
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Folders" -or
        $Report.GPO.User.ExtensionData.Name -contains "Folders") {
        $obj = [PSCustomObject]@{
            Setting = "Folders"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Registry
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Registry" -or
        $Report.GPO.User.ExtensionData.Name -contains "Registry") {
        $obj = [PSCustomObject]@{
            Setting = "Registry"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Shortcuts
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Shortcuts" -or
        $Report.GPO.User.ExtensionData.Name -contains "Shortcuts") {
        $obj = [PSCustomObject]@{
            Setting = "Shortcuts"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Network Shares
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Network Shares" -or
        $Report.GPO.User.ExtensionData.Name -contains "Network Shares") {
        $obj = [PSCustomObject]@{
            Setting = "Network Shares"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Folder Options
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Folder Options" -or
        $Report.GPO.User.ExtensionData.Name -contains "Folder Options") {
        $obj = [PSCustomObject]@{
            Setting = "Folder Options"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Internet Settings
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Internet Options" -or
        $Report.GPO.User.ExtensionData.Name -contains "Internet Options") {
        $obj = [PSCustomObject]@{
            Setting = "Internet Options"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Local Users and Groups
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Local Users and Groups" -or
        $Report.GPO.User.ExtensionData.Name -contains "Local Users and Groups") {
        $obj = [PSCustomObject]@{
            Setting = "Local Users and Groups"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Network Options
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Network Options" -or
        $Report.GPO.User.ExtensionData.Name -contains "Network Options") {
        $obj = [PSCustomObject]@{
            Setting = "Network Options"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Power Options
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Power Options" -or
        $Report.GPO.User.ExtensionData.Name -contains "Power Options") {
        $obj = [PSCustomObject]@{
            Setting = "Power Options"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Regional Options
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Regional Options" -or
        $Report.GPO.User.ExtensionData.Name -contains "Regional Options") {
        $obj = [PSCustomObject]@{
            Setting = "Regional Options"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Scheduled Tasks
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Scheduled Tasks" -or
        $Report.GPO.User.ExtensionData.Name -contains "Scheduled Tasks") {
        $obj = [PSCustomObject]@{
            Setting = "Scheduled Tasks"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Services
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Services" -or
        $Report.GPO.User.ExtensionData.Name -contains "Services") {
        $obj = [PSCustomObject]@{
            Setting = "Services"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Start Menu
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Start Menu" -or
        $Report.GPO.User.ExtensionData.Name -contains "Start Menu") {
        $obj = [PSCustomObject]@{
            Setting = "Start Menu"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }

    # Drive Maps
    if ($Report.GPO.Computer.ExtensionData.Name -contains "Drive Maps" -or
        $Report.GPO.User.ExtensionData.Name -contains "Drive Maps") {
        $obj = [PSCustomObject]@{
            Setting = "Drive Maps"
            GPO     = $g.DisplayName
        }
        if ($IncludeDisabled) {
            $obj | Add-Member @{ 'Enabled' = $Report.GPO.LinksTo.Enabled }
        }
        $Result += $obj
    }
}

Write-Output $Result