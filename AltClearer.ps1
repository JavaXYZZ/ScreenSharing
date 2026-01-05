# Alt Clearer by JAVA
# PowerShell script to find & replace text across PC, only reports files containing the word, no backups

$ErrorActionPreference = "SilentlyContinue"

Clear-Host
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "      Alt Clearer by JAVA      " -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""

# --- Ask user for input
$find = Read-Host "Enter the word/text to FIND"
if ([string]::IsNullOrWhiteSpace($find)) {
    Write-Host "Nothing entered. Exiting." -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit
}

$replace = Read-Host "Enter the word/text to REPLACE it with"

Write-Host ""
Write-Host "Scanning entire PC... This may take a while." -ForegroundColor Yellow
Write-Host ""

# --- Prepare storage
$matches = @()
$totalFiles = 0
$scannedFiles = 0

# --- Collect all drives
$drives = Get-PSDrive -PSProvider FileSystem

# --- Gather files first to calculate progress
Write-Host "Gathering files to scan..." -ForegroundColor Green
$allFiles = @()
foreach ($drive in $drives) {
    $allFiles += Get-ChildItem $drive.Root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Length -lt 10MB -and
            $_.Extension -match '\.(txt|json|cfg|log|ini|xml|csv|yml|yaml)$' -and
            $_.FullName -notmatch 'Windows|Program Files|ProgramData'
        }
}
$totalFiles = $allFiles.Count
Write-Host "Total files to scan: $totalFiles" -ForegroundColor Green
Write-Host ""

# --- Scan files and find matches
foreach ($file in $allFiles) {
    $scannedFiles++
    try {
        if (Select-String -Path $file.FullName -SimpleMatch $find -Quiet) {
            $matches += $file.FullName
            Write-Host ("FOUND in: {0}" -f $file.FullName) -ForegroundColor Cyan
        }
    } catch {}
}

# --- Done scanning
Write-Host "`n"
if ($matches.Count -eq 0) {
    Write-Host "No matches found." -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit
}

# --- Ask confirmation to replace
$confirm = Read-Host "`nReplace text in ALL these files? (Y/N)"
if ($confirm -ne "Y") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    Read-Host "Press Enter to close"
    exit
}

# --- Perform replacement (NO BACKUPS)
Write-Host "`nReplacing..." -ForegroundColor Yellow
foreach ($file in $matches) {
    (Get-Content $file -Raw) -replace [regex]::Escape($find), $replace |
        Set-Content $file
}

# --- Done
Write-Host "`n===============================" -ForegroundColor Cyan
Write-Host "           DONE!               " -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

Write-Host "`nReplacements made in the following files:" -ForegroundColor Green
$matches | ForEach-Object { Write-Host $_ -ForegroundColor White }

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
