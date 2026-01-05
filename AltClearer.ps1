# Alt Clearer by JAVA - Auto Replace
# Automatically replaces text across your PC and shows only files where replacements were made

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

# --- Scan files, replace text, and store matches
foreach ($file in $allFiles) {
    try {
        $content = Get-Content $file.FullName -Raw
        if ($content -match [regex]::Escape($find)) {
            $matches += $file.FullName
            # Replace text directly
            $newContent = $content -replace [regex]::Escape($find), $replace
            Set-Content $file.FullName $newContent
            Write-Host ("REPLACED in: {0}" -f $file.FullName) -ForegroundColor Cyan
        }
    } catch {}
}

# --- Done
Write-Host "`n===============================" -ForegroundColor Cyan
Write-Host "           DONE!               " -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

if ($matches.Count -gt 0) {
    Write-Host "`nReplacements made in the following files:" -ForegroundColor Green
    $matches | ForEach-Object { Write-Host $_ -ForegroundColor White }
} else {
    Write-Host "`nNo matches found." -ForegroundColor Red
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
