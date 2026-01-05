# ==============================
# ALT CLEARER by JAVA – Fixed & Animated Version
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
            Start-Sleep -Milliseconds (Get-Random -Minimum 2 -Maximum 8)
        }
        Write-Host ""
    }
}

# Flicker effect
function Flicker-Header {
    for ($i=0; $i -lt 2; $i++) {
        Clear-Host
        Start-Sleep -Milliseconds 50
        Show-AnimatedHeader
        Start-Sleep -Milliseconds 50
    }
}

# --- Show banner
Flicker-Header
$subtitle = "Automated Find & Replace – Alt Clearer by JAVA"
Write-Host ""
foreach ($c in $subtitle.ToCharArray()) {
    Write-Host -NoNewline $c -ForegroundColor (Get-Random -InputObject $colors)
    Start-Sleep -Milliseconds 10
}
Write-Host "`n"

# --- Ask user for input (no forced exit)
$find = Read-Host "Enter the word/text to FIND"
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

# --- Scan & replace automatically with dual-pane display
foreach ($file in $allFiles) {
    try {
        # Display currently scanned file at bottom
        $consoleHeight = $Host.UI.RawUI.WindowSize.Height
        $topPane = $Host.UI.RawUI.BufferSize.Height - 5
        Write-Host ("Scanning: {0}" -f $file.FullName) -ForegroundColor DarkGray

        # If match, replace and log to top pane
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
    Write-Host "------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "                              SCAN COMPLETE!" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Cyan

    Write-Host "`nFiles where replacements were made:" -ForegroundColor Green

    # Enumerate each file path properly
    $matches | ForEach-Object { Write-Host $_ -ForegroundColor White }
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
