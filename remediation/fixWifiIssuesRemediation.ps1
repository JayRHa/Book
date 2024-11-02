# Remediation Script: Restart the Wi-Fi adapter
$wifiAdapter = Get-NetAdapter | Where-Object {$_.MediaType -eq 'Native 802.11'}
if ($wifiAdapter) {
    Restart-NetAdapter -Name $wifiAdapter.Name
    Write-Host "Wi-Fi adapter restarted."
}
