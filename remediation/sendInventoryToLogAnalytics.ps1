$workspaceId = ""
$workspaceKey = ""
$logType = "RemediationData"

function Send-LogAnalyticsData {
    param (
        [string]$CustomerId,
        [string]$SharedKey,
        [string]$Body,
        [string]$LogType
    )

    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $Body.Length

    $signature = Get-SignatureBuilded `
        -customerId $CustomerId `
        -sharedKey $SharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource

    $uri = "https://$CustomerId.ods.opinsights.azure.com$resource?api-version=2016-04-01"

    $headers = @{
        "Authorization"        = $signature
        "Log-Type"             = $LogType
        "x-ms-date"            = $rfc1123date
        "time-generated-field" = ""
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $Body -UseBasicParsing
    return $response.StatusCode
}

$inventory = @{
    "attribute1" = "value1"
    "attribute2" = "value2"
}

try {
    $data = $inventory | ConvertTo-Json -Depth 100
    $params = @{
        CustomerId = $workspaceId
        SharedKey  = $workspaceKey
        Body       = [System.Text.Encoding]::UTF8.GetBytes($data)
        LogType    = $logType
    }

    $logResponse = Send-LogAnalyticsData @params
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}

if ($logResponse -eq 200) {
    Write-Output "Data sent successfully"
}
else {
    Write-Error "Failed to send data. Response code: $logResponse"
    exit 1
}