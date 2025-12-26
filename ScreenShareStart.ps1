Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://github.com/JavaXYZZ/ScreenSharing/blob/main/McTools.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/zedoonvm1/powershell-scripts/refs/heads/main/DoomsDayDetector.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/Enr1c0o/Powershell-Scripts/refs/heads/main/Alt-Detector.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'
Start-Process cmd -Verb RunAs -ArgumentList '/k powershell Set-ExecutionPolicy -Scope Process Bypass; Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1)'

Start-Process explorer.exe $env:TEMP
Start-Process explorer.exe 'shell:recent'
