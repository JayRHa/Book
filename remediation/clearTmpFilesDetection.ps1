# Detect Script: Check if temp files are larger than 500MB
$TempPath = $env:TEMP
$TempSize = (Get-ChildItem $TempPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB

if ($TempSize -gt 500) {
    Write-Host "Temp folder size is greater than 500MB."
    exit 1  # Non-zero exit code indicates remediation is needed
} else {
    Write-Host "Temp folder size is within acceptable limits."
    exit 0
}
