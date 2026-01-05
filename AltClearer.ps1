# ==============================
# ALT CLEARER by JAVA – Dual Pane Version
# ==============================
$ErrorActionPreference = "SilentlyContinue"

# --- Colors
$colors = @('Cyan','Green','Magenta','Yellow','White','DarkCyan')

# --- Banner
$headerLines = @(
" █████╗ ██╗     ████████╗     ██████╗██╗     ███████╗ █████╗ ██████╗ ███████╗██████╗ ",
"██╔══██╗██║     ╚══██╔══╝    ██╔════╝██║     ██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗",
"███████║██║        ██║       ██║     ██║     █████╗  ███████║██████╔╝█████╗  ██████╔╝",
"██╔══██║██║        ██║       ██║     ██║     ██╔══╝  ██╔══██║██╔══██╗╚════╝  ██╔══██╗",
"██║  ██║███████╗   ██║       ╚██████╗███████╗███████║██║  ██║███████║███████╗██║  ██║",
"╚═╝  ╚═╝╚══════╝   ╚═╝        ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝"
)
Clear-Host
foreach ($line in $headerLines) { Write-Host $line -ForegroundColor (Get-Random -InputObject $colors) }
Write-Host "`nAutomated Find & Replace – Alt Clearer by JAVA`n" -ForegroundColor Yellow

# --- Ask user input
$find = Read-Host "Enter the word/text to FIND (leave blank to skip)"
$replace = Read-Host "Enter the word/text to REPLACE it with (leave blank to skip)"
Write-Host "`nScanning entire PC... This may take a while." -ForegroundColor Yellow

# --- Storage
$matches = @()
$allFiles = @()

# --- Collect drives
$drives = Get-PSDrive -PSProvider FileSystem

# --- Gather all target files
Write-Host "`nGathering files to scan..." -ForegroundColor Green
foreach ($drive in $drives) {
    $allFiles += Get-ChildItem $drive.Root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Length -lt 10MB -and $_.Extension -match '\.(txt|json|cfg|log|ini|xml|csv|yml|yaml)$' -and $_.FullName -notmatch 'Windows|Program Files|ProgramData' }
}
$totalFiles = $allFiles.Count
Write-Host "Total files to scan: $totalFiles" -ForegroundColor Green

# --- Prepare console layout
$Host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size (120, 40)
$splitLine = "`n" + ("-" * 120)

# --- Scan files
$counter = 0
foreach ($file in $allFiles) {
    $counter++
    # Bottom half: show progress
    Write-Host ("Scanning [{0}/{1}]: {2}" -f $counter, $totalFiles, $file.FullName) -ForegroundColor DarkGray

    try {
        if (-not [string]::IsNullOrWhiteSpace($find)) {
            if (Select-String -Path $file.FullName -SimpleMatch $find -Quiet) {
                $matches += $file.FullName
                # Top half: files containing search term
                Write-Host ("[✓] Found in: {0}" -f $file.FullName) -ForegroundColor Cyan
                if (-not [string]::IsNullOrWhiteSpace($replace)) {
                    (Get-Content $file -Raw) -replace [regex]::Escape($find), $replace | Set-Content $file
                }
            }
        }
    } catch {}
}

# --- Done
Write-Host $splitLine -ForegroundColor Yellow
Write-Host "           SCAN COMPLETE!" -ForegroundColor Green
Write-Host $splitLine -ForegroundColor Yellow

if ($matches.Count -eq 0) {
    Write-Host "No matches found or input was empty." -ForegroundColor Red
} else {
    Write-Host "`nFiles where replacements were made:" -ForegroundColor Green
    $matches | ForEach-Object { Write-Host $_ -ForegroundColor White }
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
