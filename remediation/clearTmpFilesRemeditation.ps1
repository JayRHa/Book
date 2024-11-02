# Remediation Script: Clear temp files
Remove-Item "$env:TEMP\*" -Recurse -Force
Write-Host "Temp files cleared."
