# ==============================
# ALT CLEARER by JAVA – Tropical Theme
# ==============================
$ErrorActionPreference = "SilentlyContinue"

# --- Tropical ASCII banner
$headerLines = @(
" █████╗ ██╗     ████████╗     ██████╗██╗     ███████╗ █████╗ ██████╗ ███████╗██████╗ ",
"██╔══██╗██║     ╚══██╔══╝    ██╔════╝██║     ██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗",
"███████║██║        ██║       ██║     ██║     █████╗  ███████║██████╔╝█████╗  ██████╔╝",
"██╔══██║██║        ██║       ██║     ██║     ██╔══╝  ██╔══██║██╔══██╗██╔══╝  ██╔══██╗",
"██║  ██║███████╗   ██║       ╚██████╗███████╗███████╗██║  ██║██║  ██║███████╗██║  ██║",
"╚═╝  ╚═╝╚══════╝   ╚═╝        ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
)

# Tropical colors palette
$colors = @('Green','Yellow','DarkYellow','Magenta','Cyan','DarkMagenta')

# Display banner instantly with random colors
function Show-Banner {
    Clear-Host
    Write-Host ""
    foreach ($line in $headerLines) {
        $color = Get-Random -InputObject $colors
        Write-Host $line -ForegroundColor $color
    }
}

Show-Banner

# Subtitle in tropical colors, instant
$subtitle = "Automated Find & Replace – Alt Clearer by JAVA"
Write-Host ""
$color = Get-Random -InputObject $colors
Write-Host $subtitle -ForegroundColor $color
Write-Host "`n"

# --- Ask user for input
$find = Read-Host "Enter the word/text to FIND"
$replace = Read-Host "Enter the word/text to REPLACE it with"

Write-Host "`nScanning entire PC... This may take a while." -ForegroundColor Yellow
Write-Host ""

# --- Prepare storage
$matches = @()
$totalFiles = 0

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

# --- Scan & replace automatically with dual-pane style
foreach ($file in $allFiles) {
    try {
        # Show scanning file at bottom
        Write-Host ("Scanning: {0}" -f $file.FullName) -ForegroundColor DarkGray

        # Replace if match
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

    # Properly list file paths
    $matches | ForEach-Object { Write-Host $_ -ForegroundColor White }
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
