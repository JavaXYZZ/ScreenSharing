#Requires -RunAsAdministrator

# -----------------------
# Usage tracking
# NOTE THIS IS NOT A RAT
# -----------------------

Write-Host "This tool sends a simple usage ping (timestamp only) for analytics. No personal data is collected." -ForegroundColor Yellow

try {
    $webhook = "Fuck Tech and Harley / This tool no longer does it :/"

    $payload = @{
        content = "Tool used at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    } | ConvertTo-Json

    Invoke-RestMethod `
        -Uri $webhook `
        -Method Post `
        -Body $payload `
        -ContentType "application/json" `
        -ErrorAction SilentlyContinue
}
catch {
    Write-Host "Webhook failed." -ForegroundColor DarkGray
}

# -----------------------
# Function
# -----------------------

function Start-PersistentScript {
    param (
        [string]$Url
    )

    $cmd = @"
powershell -NoExit -ExecutionPolicy Bypass -Command "
try {
    iex (irm '$Url')
}
catch {
    Write-Host \$_ -ForegroundColor Red
}

Write-Host ''
Write-Host 'Script finished. Window will stay open forever.' -ForegroundColor Cyan

while (`$true) {
    Start-Sleep 3600
}
"
"@

    Start-Process cmd -Verb RunAs -ArgumentList "/k $cmd"
}

# -----------------------
# Launch scripts
# -----------------------

Start-PersistentScript "https://raw.githubusercontent.com/JavaXYZZ/ScreenSharing/main/McTools.ps1"

Start-PersistentScript "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1"

Start-PersistentScript "https://raw.githubusercontent.com/zedoonvm1/powershell-scripts/refs/heads/main/DoomsDayDetector.ps1"

Start-PersistentScript "https://raw.githubusercontent.com/Enr1c0o/Powershell-Scripts/refs/heads/main/Alt-Detector.ps1"

Start-PersistentScript "https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1"

Start-PersistentScript "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1"

Start-PersistentScript "https://raw.githubusercontent.com/Ferman9/DIFR-tools/main/dillfindernew.ps1"

# -----------------------
# Open folders
# -----------------------

Start-Process explorer.exe $env:TEMP
Start-Process explorer.exe "shell:recent"

Write-Host ""
Write-Host "All tools launched." -ForegroundColor Green
