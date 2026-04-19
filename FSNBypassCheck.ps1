param(
    [string]$OutDir = "$env:USERPROFILE\Desktop\Evidence"
)

$ErrorActionPreference = "SilentlyContinue"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# 1) Directory listings
Get-ChildItem "C:\Information" -Recurse -Force |
    Select FullName, Length, CreationTime, LastWriteTime, Attributes |
    Export-Csv "$OutDir\information_listing.csv" -NoTypeInformation

Get-ChildItem "$env:APPDATA\.minecraft" -Recurse -Force |
    Select FullName, Length, CreationTime, LastWriteTime |
    Export-Csv "$OutDir\minecraft_listing.csv" -NoTypeInformation

Get-ChildItem "C:\Users\lunal\.lunarclient" -Recurse -Force |
    Select FullName, Length, CreationTime, LastWriteTime |
    Export-Csv "$OutDir\lunar_listing.csv" -NoTypeInformation

# 2) USN state
cmd /c 'fsutil usn queryjournal C:' > "$OutDir\usn_query.txt" 2>&1

# 3) Prefetch
Get-ChildItem "C:\Windows\Prefetch" -Force |
    Where-Object { $_.Name -match '^(FSUTIL|CMD|POWERSHELL|JAVA|JAVAW).*\.pf$' } |
    Select Name, CreationTime, LastWriteTime, Length |
    Export-Csv "$OutDir\prefetch_hits.csv" -NoTypeInformation

# 4) Process creation logs
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688; StartTime=(Get-Date).AddDays(-14)} |
    Where-Object { $_.Message -match 'fsutil\.exe|cmd\.exe|powershell\.exe|javaw?\.exe|deletejournal|hardlink|shutdown\.exe' } |
    Select TimeCreated, Id, Message |
    Export-Csv "$OutDir\security_4688.csv" -NoTypeInformation

Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; Id=1; StartTime=(Get-Date).AddDays(-14)} |
    Where-Object { $_.Message -match 'fsutil\.exe|cmd\.exe|powershell\.exe|javaw?\.exe|deletejournal|hardlink|shutdown\.exe' } |
    Select TimeCreated, Id, Message |
    Export-Csv "$OutDir\sysmon_1.csv" -NoTypeInformation

# 5) PowerShell history
$hist = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
if (Test-Path $hist) {
    Select-String -Path $hist -Pattern 'fsutil|deletejournal|hardlink|type .*?>|shutdown\.exe|javaw|java\.exe|cmd /c' |
        ForEach-Object { $_.Line } |
        Set-Content "$OutDir\powershell_history_hits.txt"
}

Write-Host "Saved to $OutDir"
