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
$find    = Read-Host "Enter the word/text to FIND"
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
            $_.Extension -in '.txt','.json','.cfg','.log','.ini','.xml','.csv','.yml','.yaml' -and
            $_.FullName -notmatch 'Windows|Program Files|ProgramData'
        }

    foreach ($file in $files) {
        try {
            $content = Get-Content $file.FullName -Raw
            if ($content.Contains($find)) {
                $newContent = $content.Replace($find, $replace)

                # Show what is replaced (first 50 chars before & after)
                $index = $content.IndexOf($find)
                $before = if ($index -gt 20) { $content.Substring($index - 20, 20) } else { $content.Substring(0, $index) }
                $after  = if (($index + $find.Length + 20) -lt $content.Length) { $content.Substring($index + $find.Length, 20) } else { "" }

                Write-Host "File: $($file.FullName)" -ForegroundColor Cyan
                Write-Host "Replaced: '$find' => '$replace'" -ForegroundColor Green
                Write-Host "Context: ...$before[$find]$after..." -ForegroundColor Yellow
                Write-Host ""

                # Save the replacement
                Set-Content -Path $file.FullName -Value $newContent
                $matches += $file.FullName
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
    foreach ($match in $matches) {
        Write-Host $match -ForegroundColor White
    }
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
