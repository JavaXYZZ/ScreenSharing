# ==============================
# ALT CLEARER by JAVA – Coding Sucks
# ==============================
$ErrorActionPreference = "SilentlyContinue"

Clear-Host
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "        ALT CLEARER by JAVA     " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""

# --- Ask user for input
$find = Read-Host "Enter the word/text to FIND"
$replace = Read-Host "Enter the word/text to REPLACE it with"

Write-Host "`nScanning entire PC..." -ForegroundColor Yellow
Write-Host ""

# --- Prepare storage
$matches = @()
$drives = Get-PSDrive -PSProvider FileSystem

# --- Gather files and scan
foreach ($drive in $drives) {
    $files = Get-ChildItem $drive.Root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Length -lt 10MB -and
            $_.Extension -match '\.(txt|json|cfg|log|ini|xml|csv|yml|yaml)$' -and
            $_.FullName -notmatch 'Windows|Program Files|ProgramData'
        }

    foreach ($file in $files) {
        try {
            if (Select-String -Path $file.FullName -SimpleMatch $find -Quiet) {
                # Replace the text immediately
                (Get-Content $file -Raw) -replace [regex]::Escape($find), $replace |
                    Set-Content $file

                # Store the **full path string** explicitly
                $matches += $file.FullName.ToString()
            }
        } catch {}
    }
}

# --- Done scanning & replacing
Write-Host "`n--------------------------------------------------------"
Write-Host "                    SCAN COMPLETE!                      "
Write-Host "--------------------------------------------------------`n"

if ($matches.Count -eq 0) {
    Write-Host "No files detected containing the word." -ForegroundColor Red
} else {
    Write-Host "Files where replacements were made:" -ForegroundColor Green
    $matches | ForEach-Object { Write-Host $_ -ForegroundColor White }
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
