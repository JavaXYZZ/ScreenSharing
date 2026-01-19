Clear-Host
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "        ALT CLEARER by JAVA     " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""

$find = Read-Host "Enter the word/text to FIND"
$replace = Read-Host "Enter the word/text to REPLACE it with"

Write-Host "`nScanning entire PC..." -ForegroundColor Yellow
Write-Host ""

function ScanAndReplace($filePath) {
    try {
        $content = Get-Content $filePath -Raw
        if ($content.Contains($find)) {
            $newContent = $content.Replace($find, $replace)

            $index = $content.IndexOf($find)
            $before = if ($index -gt 20) { $content.Substring($index - 20, 20) } else { $content.Substring(0, $index) }
            $after  = if (($index + $find.Length + 20) -lt $content.Length) { $content.Substring($index + $find.Length, 20) } else { "" }

            Write-Host "`nFile: $filePath" -ForegroundColor Cyan
            Write-Host "Replaced: '$find' => '$replace'" -ForegroundColor Green
            Write-Host "Context: ...$before[$find]$after..." -ForegroundColor Yellow

            Set-Content -Path $filePath -Value $newContent
            return $true
        }
    } catch {}
    return $false
}

$allFiles = @()
foreach ($drive in Get-PSDrive -PSProvider FileSystem) {
    $allFiles += Get-ChildItem $drive.Root -Recurse -File -ErrorAction SilentlyContinue |
                 Where-Object {
                     $_.Length -lt 10MB -and
                     $_.Extension -in '.txt','.json','.cfg','.log','.ini','.xml','.csv','.yml','.yaml' -and
                     $_.FullName -notmatch 'Windows|Program Files|ProgramData'
                 }
}

$totalFiles = $allFiles.Count
$matches = @()

for ($i = 0; $i -lt $totalFiles; $i++) {
    $file = $allFiles[$i]

    if (ScanAndReplace $file.FullName) { $matches += $file.FullName }

    # --- LIVE PROGRESS ---
    $percent = [math]::Round((($i + 1) / $totalFiles) * 100, 1)
    Write-Progress -Activity "Scanning Files" -Status "$($i+1)/$totalFiles files ($percent%)" -PercentComplete $percent
}

Write-Host "`nFirst scan complete"
if ($matches.Count -gt 0) {
    Write-Host "Files modified in first pass:" -ForegroundColor Green
    $matches | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "No files detected containing the word." -ForegroundColor Red
}

$missed = @()
for ($i = 0; $i -lt $totalFiles; $i++) {
    $file = $allFiles[$i]
    try {
        $content = Get-Content $file.FullName -Raw
        if ($content.Contains($find)) {
            ScanAndReplace $file.FullName
            $missed += $file.FullName
        }
    } catch {}

    # --- LIVE PROGRESS SECOND PASS ---
    $percent = [math]::Round((($i + 1) / $totalFiles) * 100, 1)
    Write-Progress -Activity "Second Pass Check" -Status "$($i+1)/$totalFiles files ($percent%)" -PercentComplete $percent
}

if ($missed.Count -gt 0) {
    Write-Host "`nSecond pass fixed additional files:" -ForegroundColor Green
    $missed | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "`nSecond pass found nothing new. All clear!" -ForegroundColor Green
}

Read-Host "`nPress Enter to close Alt Clearer by JAVA"
