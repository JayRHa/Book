# Detect Script: Check if the device is experiencing Wi-Fi connection issues
$wifi = Get-NetAdapter | Where-Object {$_.Status -eq 'Up' -and $_.MediaType -eq 'Native 802.11'}
if ($wifi) {
    Write-Host "Wi-Fi is connected."
    exit 0
} else {
    Write-Host "Wi-Fi is not connected."
    exit 1  # Non-zero exit code indicates remediation is needed
}
