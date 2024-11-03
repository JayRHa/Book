# Set API details
$endpoint_name = ""
$apiBase = "https://$($endpoint_name).openai.azure.com"
$apiVersion = "2023-07-01-preview"
$apiKey = [System.Environment]::GetEnvironmentVariable("OPENAI_API_KEY", "User")
$deployment = "gpt-35-turbo"

$headers = @{
    "Content-Type" = "application/json"
    "api-key" = $apiKey
}

$body = @{
    messages = @(
        @{
            role = "system"
            content = "You are an expert in Intune."
        },
        @{
            role = "user"
            content = "What is Intune?"
        }
    )
    max_tokens = 800
    temperature = 0.7
} | ConvertTo-Json

$url = "$apiBase/openai/deployments/$deployment/chat/completions?api-version=$apiVersion"
$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
$response | Out-String
