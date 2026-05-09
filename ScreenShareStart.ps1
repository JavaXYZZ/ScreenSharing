#Requires -RunAsAdministrator

Write-Host "Launching tools..." -ForegroundColor Cyan

function Start-PersistentScript {
    param (
        [string]$Url
    )

    $psCommand = @"
try {
    iex (irm '$Url')
}
catch {
    Write-Host `$_ -ForegroundColor Red
}

Write-Host ''
Write-Host 'Script finished. Keeping window open...' -ForegroundColor Yellow

while (`$true) {
    Start-Sleep 3600
}
"@

    Start-Process cmd.exe -Verb RunAs -ArgumentList @(
        '/k',
        'powershell',
        '-NoExit',
        '-ExecutionPolicy', 'Bypass',
        '-Command', $psCommand
    )
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
Start-Process explorer.exe 'shell:recent'

Write-Host "All tools launched." -ForegroundColor Green
