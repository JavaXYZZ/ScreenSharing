# ==============================
# ALT CLEARER by JAVA – Full Automated Version
# ==============================

$ErrorActionPreference = "SilentlyContinue"

# --- ASCII banner & colors
$headerLines = @(
" █████╗ ██╗     ████████╗     ██████╗██╗     ███████╗ █████╗ ██████╗ ███████╗██████╗ ",
"██╔══██╗██║     ╚══██╔══╝    ██╔════╝██║     ██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗",
"███████║██║        ██║       ██║     ██║     █████╗  ███████║██████╔╝█████╗  ██████╔╝",
"██╔══██║██║        ██║       ██║     ██║     ██╔══╝  ██╔══██║██╔══██╗╚═══██║██╔══██╗",
"██║  ██║███████╗   ██║       ╚██████╗███████╗███████╗██║  ██║██║  ██║███████╗██║  ██║",
"╚═╝  ╚═╝╚══════╝   ╚═╝        ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
)

# Tropical colors
$colors = @('Cyan','Green','Magenta','Yellow','DarkCyan','White')

# --- Show header instantly, tropical theme
Clear-Host
foreach ($line in $headerLines) {
    Write-Host $line -ForegroundColor (Get-Random -InputObject $colors)
}

Write-Host "`nAutomated Find & Replace – Alt Clearer by JAVA" -ForegroundColor Cyan
Write-Host ""

# --- Ask user for input (no forced exit)
$find = Read-Host "Enter the word/text to FIND"
$replace = Read-Host "Enter the word/text to REPLACE it with"

Write-Host "`nScanning entire PC... This may take a while." -ForegroundColor Yellow
Write-Host ""

# --- Prepare storage
$matches = @()
$totalFiles = 0
$scannedFiles = 0

# --- Collect all drives
$drives = Get-PSDrive -PSProvider FileSystem

# --- Gather files first
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

# --- Scan & replace automatically
foreach ($file in $allFiles) {
    $scannedFiles++
    try {
        if (Select-String -Path $file.FullName -SimpleMatch $find -Quiet) {
            $matches += $file.FullName
            (Get-Content $file.FullName -Raw) -replace [regex]::Escape($find), $replace |
                Set-Content $file.FullName
        }
    } catch {}
    # --- Display scanning progress at bottom
    Write-Host ("Scanning: {0}/{1}" -f $scannedFiles, $totalFiles) -NoNewline -ForegroundColor DarkGray
    Write-Host "`r"
}

# --- Done scanning & replacing
Write-Host "`n------------------------------------------------------------------------------------------------------------------------"
Write-Host "                              SCAN COMPLETE!" -ForegroundColor Green
Write-Host "------------------------------------------------------------------------------------------------------------------------`n"

# --- Only show files that were replaced (full paths)
if ($matches.Count -eq 0) {
    Write-Host "No matches found." -ForegroundColor Red
} else {
    Write-Host "Files where replacements were made:" -ForegroundColor Green
    $matches | ForEach-Object { Write-Host $_ -ForegroundColor White }
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
