# ==============================
# ALT CLEARER by JAVA – Auto Replace (Only show replaced files)
# ==============================

$ErrorActionPreference = "SilentlyContinue"

# --- Banner
$headerLines = @(
" █████╗ ██╗     ████████╗     ██████╗██╗     ███████╗ █████╗ ██████╗ ███████╗██████╗ ",
"██╔══██╗██║     ╚══██╔══╝    ██╔════╝██║     ██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗",
"███████║██║        ██║       ██║     ██║     █████╗  ███████║██████╔╝█████╗  ██████╔╝",
"██╔══██║██║        ██║       ██║     ██║     ██╔══╝  ██╔══██║██╔══██╗╚═══██║██╔══██╗",
"██║  ██║███████╗   ██║       ╚██████╗███████╗███████╗██║  ██║██║  ██║███████╗██║  ██║",
"╚═╝  ╚═╝╚══════╝   ╚═╝        ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
)

$colors = @('Cyan','Green','Magenta','Yellow','DarkCyan','White')

# Instant banner display
Clear-Host
foreach ($line in $headerLines) {
    Write-Host $line -ForegroundColor (Get-Random -InputObject $colors)
}

Write-Host "`nAutomated Find & Replace – Alt Clearer by JAVA`n" -ForegroundColor Cyan

# --- Input
$find = Read-Host "Enter the word/text to FIND"
$replace = Read-Host "Enter the word/text to REPLACE it with"

Write-Host "`nScanning entire PC..." -ForegroundColor Yellow

# --- Storage
$matches = @()

# --- Collect all drives
$drives = Get-PSDrive -PSProvider FileSystem

# --- Gather files
$allFiles = @()
foreach ($drive in $drives) {
    $allFiles += Get-ChildItem $drive.Root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Length -lt 10MB -and
            $_.Extension -match '\.(txt|json|cfg|log|ini|xml|csv|yml|yaml)$' -and
            $_.FullName -notmatch 'Windows|Program Files|ProgramData'
        }
}

# --- Scan & replace automatically
foreach ($file in $allFiles) {
    try {
        if (Select-String -Path $file.FullName -SimpleMatch $find -Quiet) {
            $matches += $file.FullName
            (Get-Content $file.FullName -Raw) -replace [regex]::Escape($find), $replace |
                Set-Content $file.FullName
        }
    } catch {}
}

# --- Done
Write-Host "`n------------------------------------------------------------------------------------------------------------------------"
Write-Host "                              SCAN COMPLETE!" -ForegroundColor Green
Write-Host "------------------------------------------------------------------------------------------------------------------------`n"

if ($matches.Count -eq 0) {
    Write-Host "No matches found." -ForegroundColor Red
} else {
    Write-Host "Files where replacements were made:" -ForegroundColor Green
    $matches | ForEach-Object { Write-Host $_ -ForegroundColor White }
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
