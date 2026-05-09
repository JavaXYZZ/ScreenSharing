#Requires -RunAsAdministrator

function Start-PersistentScript {
    param (
        [string]$Url
    )

    $command = "powershell -NoExit -ExecutionPolicy Bypass -Command `"try { iex (irm '$Url') } catch { Write-Host `$_ -ForegroundColor Red }; Write-Host ''; Write-Host 'Keeping window open...' -ForegroundColor Cyan; while (`$true) { Start-Sleep 3600 }`""

    Start-Process cmd.exe -Verb RunAs -ArgumentList "/k $command"
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

Write-Host "All tools launched." -ForegroundColor Green
