# ==============================
# ALT CLEARER by JAVA – Full Animated Version
# ==============================
$ErrorActionPreference = "SilentlyContinue"

# --- ASCII banner & colors
$headerLines = @(
" █████╗ ██╗     ████████╗     ██████╗██╗     ███████╗ █████╗ ██████╗ ███████╗██████╗ ",
"██╔══██╗██║     ╚══██╔══╝    ██╔════╝██║     ██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗",
"███████║██║        ██║       ██║     ██║     █████╗  ███████║██████╔╝█████╗  ██████╔╝",
"██╔══██║██║        ██║       ██║     ██║     ██╔══╝  ██╔══██║██╔══██╗██╔══╝  ██╔══██╗",
"██║  ██║███████╗   ██║       ╚██████╗███████╗███████╗██║  ██║██║  ██║███████╗██║  ██║",
"╚═╝  ╚═╝╚══════╝   ╚═╝        ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
)
$colors = @('Cyan','Green','Magenta','Yellow','White','DarkCyan')

function Show-AnimatedHeader {
    Clear-Host
    Write-Host ""
    foreach ($line in $headerLines) {
        foreach ($char in $line.ToCharArray()) {
            $color = Get-Random -InputObject $colors
            Write-Host -NoNewline $char -ForegroundColor $color
            Start-Sleep -Milliseconds (Get-Random -Minimum 5 -Maximum 15)
        }
        Write-Host ""
    }
}

function Flicker-Header {
    for ($i=0; $i -lt 3; $i++) {
        Clear-Host
        Start-Sleep -Milliseconds 100
        Show-AnimatedHeader
        Start-Sleep -Milliseconds 100
    }
}

# --- Show banner & subtitle
Flicker-Header
$subtitle = "Automated Find & Replace – Alt Clearer by JAVA"
Write-Host ""
foreach ($c in $subtitle.ToCharArray()) {
    Write-Host -NoNewline $c -ForegroundColor (Get-Random -InputObject $colors)
    Start-Sleep -Milliseconds 25
}
Write-Host "`n"

# --- Ask user for input
$find = Read-Host "Enter the word/text to FIND"
if ([string]::IsNullOrWhiteSpace($find)) {
    Write-Host "Nothing entered. Exiting." -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit
}

$replace = Read-Host "Enter the word/text to REPLACE it with"

Write-Host "`nScanning entire PC... This may take a while." -ForegroundColor Yellow
Write-Host ""

# --- Prepare storage
$matches = @()
$totalFiles = 0
$scannedFiles = 0

# --- Collect drives
$drives = Get-PSDrive -PSProvider FileSystem

# --- Gather files
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
    try {
        if (Select-String -Path $file.FullName -SimpleMatch $find -Quiet) {
            $matches += $file.FullName
            (Get-Content $file -Raw) -replace [regex]::Escape($find), $replace |
                Set-Content $file
            Write-Host ("[✓] Replaced in: {0}" -f $file.FullName) -ForegroundColor Cyan
        }
    } catch {}
}

# --- Done scanning & replacing
Write-Host "`n"
if ($matches.Count -eq 0) {
    Write-Host "No matches found." -ForegroundColor Red
} else {
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "           DONE!               " -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "`nReplacements made in the following files:" -ForegroundColor Green
    $matches | ForEach-Object { Write-Host $_ -ForegroundColor White }
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
