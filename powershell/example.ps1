# Check if Microsoft Graph module is installed
$module = Get-Module -Name Microsoft.Graph -ListAvailable
if ($module -eq $null) {
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
    Import-Module -Name Microsoft.Graph
} else {
    Write-Host "Microsoft Graph module is already installed."
}

# Authentication
Connect-MgGraph

# Execute Graph call
Get-MgBetaDeviceManagementDeviceConfiguration -Property "id,displayName,lastModifiedDateTime,roleScopeTagIds,microsoft.graph.unsupportedDeviceConfiguration/originalEntityTypeName" -ExpandProperty "deviceStatusOverview,assignments" -Top 120 -CountVariable CountVar
