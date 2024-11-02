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

$reportName = 'DetectedAppsRawData'

$body = @"
{
"reportName": "$reportName",
"localizationType": "LocalizedValuesAsAdditionalColumn"
}
"@

$id = (Invoke-MgGraphRequest -Uri https://graph.microsoft.com/beta/deviceManagement/reports/exportJobs -Method POST -Body $body).id
$status = (Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/reports/exportJobs('$id')" -Method GET).status

while (-not ($status -eq 'completed')) {
    $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/reports/exportJobs('$id')" -Method Get
    $status = ($response).status
}

Invoke-WebRequest -Uri $response.url -OutFile "./intuneExport.zip"
Expand-Archive "./intuneExport.zip" -DestinationPath "./intuneExport"
