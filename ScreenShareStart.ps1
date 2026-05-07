# Usage tracking NOTE THIS IS NOT A RAT
Write-Host "This tool sends a simple usage ping (timestamp only) for analytics. No personal data is collected." -ForegroundColor Yellow

try {
    $webhook = "Fuck Tech and Harley"

    $payload = @{
        content = "Tool used at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $webhook -Method Post -Body $payload -ContentType "application/json" -ErrorAction SilentlyContinue
} catch {}

Start-Process cmd -Verb RunAs -ArgumentList '/k powershell set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/JavaXYZZ/ScreenSharing/main/McTools.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/zedoonvm1/powershell-scripts/refs/heads/main/DoomsDayDetector.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/Enr1c0o/Powershell-Scripts/refs/heads/main/Alt-Detector.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/Ferman9/DIFR-tools/main/dillfindernew.ps1)'

Start-Process explorer.exe $env:TEMP
Start-Process explorer.exe 'shell:recent'
