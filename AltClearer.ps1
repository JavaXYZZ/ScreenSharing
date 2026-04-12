param(
    [switch]$ScanOnly,
    [switch]$DeleteAll,
    [switch]$NoBackup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host ("=" * 78) -ForegroundColor DarkGray
    Write-Host $Text -ForegroundColor Cyan
    Write-Host ("=" * 78) -ForegroundColor DarkGray
}

function Expand-EnvPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    return [Environment]::ExpandEnvironmentVariables($Path)
}

function New-HashSet {
    return [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
}

function Add-UniquePath {
    param(
        [System.Collections.Generic.HashSet[string]]$Set,
        [System.Collections.Generic.List[string]]$List,
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    try {
        $expanded = Expand-EnvPath $Path
        if (-not $expanded) { return }
        if (Test-Path -LiteralPath $expanded) {
            $full = [System.IO.Path]::GetFullPath($expanded)
            if ($Set.Add($full)) {
                $List.Add($full)
            }
        }
    } catch {
    }
}

function Get-AccountHintsFromFile {
    param([string]$Path)

    $hints = New-Object System.Collections.Generic.List[string]
    $seen = New-HashSet

    try {
        $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($raw)) { return @() }

        $patterns = @(
            '(?i)"username"\s*:\s*"([^"]+)"',
            '(?i)"displayName"\s*:\s*"([^"]+)"',
            '(?i)"profileName"\s*:\s*"([^"]+)"',
            '(?i)"gamertag"\s*:\s*"([^"]+)"',
            '(?i)"name"\s*:\s*"([A-Za-z0-9_]{3,32})"',
            '(?i)"email"\s*:\s*"([^"]+)"'
        )

        foreach ($pattern in $patterns) {
            foreach ($match in [regex]::Matches($raw, $pattern)) {
                $value = $match.Groups[1].Value.Trim()
                if ($value.Length -gt 0 -and $value.Length -le 80) {
                    if ($seen.Add($value)) {
                        $hints.Add($value)
                    }
                }
            }
        }

        foreach ($match in [regex]::Matches($raw, '(?i)\b[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}\b')) {
            $value = $match.Value.Trim()
            if ($seen.Add($value)) {
                $hints.Add($value)
            }
        }
    } catch {
    }

    return $hints | Select-Object -First 8
}

function Get-DirectoriesLimited {
    param(
        [string]$Root,
        [int]$MaxDepth = 4,
        [string[]]$SkipNames = @()
    )

    $results = New-Object System.Collections.Generic.List[string]
    if (-not (Test-Path -LiteralPath $Root -PathType Container)) { return $results }

    $queue = New-Object System.Collections.Queue
    $queue.Enqueue([pscustomobject]@{ Path = $Root; Depth = 0 })

    while ($queue.Count -gt 0) {
        $item = $queue.Dequeue()
        $currentPath = $item.Path
        $currentDepth = [int]$item.Depth
        $results.Add($currentPath)

        if ($currentDepth -ge $MaxDepth) { continue }

        try {
            $children = Get-ChildItem -LiteralPath $currentPath -Directory -Force -ErrorAction Stop
            foreach ($child in $children) {
                if ($SkipNames -contains $child.Name) { continue }
                $queue.Enqueue([pscustomobject]@{
                    Path  = $child.FullName
                    Depth = $currentDepth + 1
                })
            }
        } catch {
        }
    }

    return $results
}

function Resolve-MinecraftAppName {
    param([string]$Path)

    $p = $Path.ToLowerInvariant()
    if ($p -match '\\\.minecraft(\\|$)') { return 'Vanilla / Forge / Fabric (.minecraft)' }
    if ($p -match 'modrinth') { return 'Modrinth' }
    if ($p -match 'prismlauncher|prism launcher') { return 'Prism Launcher' }
    if ($p -match 'polymc') { return 'PolyMC' }
    if ($p -match 'multimc') { return 'MultiMC' }
    if ($p -match 'gdlauncher') { return 'GDLauncher' }
    if ($p -match 'curseforge') { return 'CurseForge' }
    if ($p -match 'atlauncher') { return 'ATLauncher' }
    if ($p -match 'technic') { return 'Technic Launcher' }
    if ($p -match 'feather') { return 'Feather' }
    if ($p -match 'lunar') { return 'Lunar Client' }
    if ($p -match 'badlion') { return 'Badlion Client' }
    if ($p -match 'sklauncher') { return 'SKLauncher' }
    if ($p -match 'hmcl') { return 'HMCL' }
    if ($p -match 'tlauncher') { return 'TLauncher' }
    if ($p -match '\\forge(\\|$)') { return 'Forge-related launcher root' }
    return 'Minecraft launcher'
}

function Get-MinecraftRootTargets {
    param([string]$Root)

    $targets = New-Object System.Collections.Generic.List[string]
    $seen = New-HashSet

    $skip = @(
        'assets','libraries','versions','logs','crash-reports','screenshots',
        'resourcepacks','shaderpacks','saves','mods','config','natives'
    )

    $dirs = Get-DirectoriesLimited -Root $Root -MaxDepth 4 -SkipNames $skip
    foreach ($dir in $dirs) {
        try {
            $files = Get-ChildItem -LiteralPath $dir -File -Force -ErrorAction Stop
            foreach ($file in $files) {
                $name = $file.Name.ToLowerInvariant()
                if (
                    $name -eq 'launcher_accounts.json' -or
                    $name -eq 'launcher_profiles.json' -or
                    $name -eq 'accounts.json' -or
                    $name -eq 'account.json' -or
                    $name -eq 'accounts.txt' -or
                    $name -eq 'launcher_msa_credentials.bin' -or
                    $name -like '*account*.json' -or
                    $name -like '*credential*' -or
                    $name -like '*auth*.json'
                ) {
                    if ($seen.Add($file.FullName)) {
                        $targets.Add($file.FullName)
                    }
                }
            }
        } catch {
        }
    }

    return $targets
}

function Get-MinecraftFindings {
    $results = New-Object System.Collections.Generic.List[object]
    $rootsSeen = New-HashSet

    $roaming = $env:APPDATA
    $local = $env:LOCALAPPDATA
    $profile = $env:USERPROFILE

    $knownRoots = @(
        "$roaming\.minecraft",
        "$roaming\PrismLauncher",
        "$roaming\PolyMC",
        "$roaming\MultiMC",
        "$roaming\ATLauncher",
        "$roaming\technic",
        "$roaming\feather",
        "$roaming\Feather",
        "$roaming\Badlion Client",
        "$roaming\SKLauncher",
        "$roaming\TLauncher",
        "$roaming\HMCL",
        "$roaming\GDLauncher",
        "$roaming\ModrinthApp",
        "$local\ModrinthApp",
        "$local\Packages\Microsoft.4297127D64EC6_8wekyb3d8bbwe",
        "$roaming\CurseForge",
        "$local\CurseForge",
        "$local\Programs\CurseForge",
        "$profile\.lunarclient",
        "$profile\.feather",
        "$profile\curseforge",
        "$profile\Documents\CurseForge",
        "$profile\Documents\PrismLauncher",
        "$profile\Documents\MultiMC",
        "$profile\Documents\ModrinthApp",
        "$profile\Downloads\PrismLauncher",
        "$profile\Downloads\MultiMC",
        "$profile\Downloads\ModrinthApp",
        "$profile\Desktop\PrismLauncher",
        "$profile\Desktop\MultiMC",
        "$profile\Desktop\ModrinthApp"
    )

    foreach ($root in $knownRoots) {
        if (Test-Path -LiteralPath $root -PathType Container) {
            $full = [System.IO.Path]::GetFullPath($root)
            [void]$rootsSeen.Add($full)
        }
    }

    $portableBases = @(
        $profile,
        (Join-Path $profile 'Desktop'),
        (Join-Path $profile 'Documents'),
        (Join-Path $profile 'Downloads'),
        (Join-Path $profile 'OneDrive')
    ) | Select-Object -Unique

    foreach ($base in $portableBases) {
        if (-not (Test-Path -LiteralPath $base -PathType Container)) { continue }
        try {
            $dirs = Get-ChildItem -LiteralPath $base -Directory -Force -ErrorAction Stop
            foreach ($dir in $dirs) {
                if ($dir.Name -match '(?i)(minecraft|modrinth|prism|multimc|polymc|gdlauncher|curseforge|atlauncher|technic|feather|lunar|badlion|sklauncher|hmcl|tlauncher|forge)') {
                    [void]$rootsSeen.Add($dir.FullName)
                }
            }
        } catch {
        }
    }

    foreach ($root in ($rootsSeen | Sort-Object)) {
        $targets = Get-MinecraftRootTargets -Root $root
        if ($targets.Count -eq 0) { continue }

        $hints = New-Object System.Collections.Generic.List[string]
        $hintsSeen = New-HashSet
        foreach ($target in $targets) {
            foreach ($hint in (Get-AccountHintsFromFile -Path $target)) {
                if ($hintsSeen.Add($hint)) {
                    $hints.Add($hint)
                }
            }
        }

        $summary = if ($hints.Count -gt 0) {
            "Found $($targets.Count) account/auth file(s): " + (($hints | Select-Object -First 6) -join ', ')
        } else {
            "Found $($targets.Count) account/auth file(s)"
        }

        $results.Add([pscustomobject]@{
            Category      = 'Minecraft'
            App           = Resolve-MinecraftAppName -Path $root
            RootPath      = $root
            Summary       = $summary
            DeleteTargets = @($targets | Sort-Object -Unique)
        })
    }

    return $results
}

function Get-DiscordFindings {
    $results = New-Object System.Collections.Generic.List[object]

    $variants = @(
        'Discord',
        'DiscordPTB',
        'DiscordCanary',
        'DiscordDevelopment',
        'Lightcord',
        'Vesktop',
        'ArmCord'
    )

    foreach ($variant in $variants) {
        $roamingRoot = Join-Path $env:APPDATA $variant
        $localRoot = Join-Path $env:LOCALAPPDATA $variant

        $targets = New-Object System.Collections.Generic.List[string]
        $seen = New-HashSet

        $interesting = @(
            (Join-Path $roamingRoot 'Local Storage'),
            (Join-Path $roamingRoot 'Session Storage'),
            (Join-Path $roamingRoot 'Network'),
            (Join-Path $roamingRoot 'IndexedDB'),
            (Join-Path $roamingRoot 'Cookies'),
            (Join-Path $roamingRoot 'Code Cache'),
            (Join-Path $roamingRoot 'GPUCache'),
            (Join-Path $roamingRoot 'Local State'),
            $roamingRoot,
            $localRoot
        )

        foreach ($item in $interesting) {
            Add-UniquePath -Set $seen -List $targets -Path $item
        }

        if ($targets.Count -eq 0) { continue }

        $hasLevelDb = $false
        $levelDbPath = Join-Path $roamingRoot 'Local Storage\leveldb'
        if (Test-Path -LiteralPath $levelDbPath) { $hasLevelDb = $true }

        $summary = if ($hasLevelDb) {
            'Detected local signed-in/session storage (including LevelDB session data)'
        } else {
            'Detected local app/session data'
        }

        $results.Add([pscustomobject]@{
            Category      = 'Discord'
            App           = $variant
            RootPath      = $roamingRoot
            Summary       = $summary
            DeleteTargets = @($targets | Sort-Object -Unique)
        })
    }

    return $results
}

function Show-Findings {
    param([object[]]$Findings)

    if (-not $Findings -or $Findings.Count -eq 0) {
        Write-Host "Nothing matching the current scan rules was found." -ForegroundColor Yellow
        return
    }

    $i = 1
    foreach ($finding in $Findings) {
        $finding | Add-Member -NotePropertyName Id -NotePropertyValue $i -Force
        $i++
    }

    Write-Section "Detected local accounts / session stores"
    foreach ($finding in $Findings) {
        Write-Host ("[{0}] {1} | {2}" -f $finding.Id, $finding.Category, $finding.App) -ForegroundColor Green
        Write-Host ("    Root    : {0}" -f $finding.RootPath)
        Write-Host ("    Summary : {0}" -f $finding.Summary)
        Write-Host ("    Targets : {0}" -f $finding.DeleteTargets.Count)
        Write-Host ""
    }
}

function New-BackupRoot {
    $backupRoot = Join-Path ([Environment]::GetFolderPath('Desktop')) ("AccountWipeBackup_{0}" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
    [void](New-Item -ItemType Directory -Path $backupRoot -Force)
    return $backupRoot
}

function Backup-Target {
    param(
        [string]$Source,
        [string]$BackupRoot
    )

    if (-not (Test-Path -LiteralPath $Source)) { return }

    $full = [System.IO.Path]::GetFullPath($Source)
    $relative = $full -replace '^[A-Za-z]:', ''
    $relative = $relative.TrimStart('\')
    $destination = Join-Path $BackupRoot $relative
    $destinationDir = Split-Path -Parent $destination

    if (-not (Test-Path -LiteralPath $destinationDir)) {
        [void](New-Item -ItemType Directory -Path $destinationDir -Force)
    }

    if (Test-Path -LiteralPath $Source -PathType Container) {
        Copy-Item -LiteralPath $Source -Destination $destination -Recurse -Force
    } else {
        Copy-Item -LiteralPath $Source -Destination $destination -Force
    }
}

function Remove-Targets {
    param(
        [object[]]$SelectedFindings,
        [switch]$SkipBackup
    )

    if (-not $SelectedFindings -or $SelectedFindings.Count -eq 0) {
        Write-Host "Nothing selected." -ForegroundColor Yellow
        return
    }

    $allTargets = New-Object System.Collections.Generic.List[string]
    $seen = New-HashSet
    foreach ($finding in $SelectedFindings) {
        foreach ($target in $finding.DeleteTargets) {
            if ($seen.Add($target)) {
                $allTargets.Add($target)
            }
        }
    }

    if ($allTargets.Count -eq 0) {
        Write-Host "There were no delete targets." -ForegroundColor Yellow
        return
    }

    $backupRoot = $null
    if (-not $SkipBackup) {
        $backupRoot = New-BackupRoot
        Write-Host ("Backup folder: {0}" -f $backupRoot) -ForegroundColor DarkCyan
        foreach ($target in $allTargets) {
            try {
                Backup-Target -Source $target -BackupRoot $backupRoot
            } catch {
                Write-Host ("Backup failed for: {0}" -f $target) -ForegroundColor Yellow
            }
        }
    }

    foreach ($target in $allTargets | Sort-Object Length -Descending) {
        try {
            if (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction Stop
                Write-Host ("Deleted: {0}" -f $target) -ForegroundColor Red
            }
        } catch {
            Write-Host ("Failed to delete: {0}" -f $target) -ForegroundColor Yellow
            Write-Host ("  {0}" -f $_.Exception.Message) -ForegroundColor DarkYellow
        }
    }

    Write-Host ""
    Write-Host "Finished." -ForegroundColor Green
    if ($backupRoot) {
        Write-Host ("Backup saved to: {0}" -f $backupRoot) -ForegroundColor DarkCyan
    }
}

function Read-Selection {
    param([object[]]$Findings)

    $raw = Read-Host "Enter item numbers to delete (comma-separated), A for all, or Q to quit"
    if ([string]::IsNullOrWhiteSpace($raw)) { return @() }

    if ($raw -match '^(?i)q$') { return @() }
    if ($raw -match '^(?i)a$') { return $Findings }

    $numbers = $raw -split '[,\s]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
    if (-not $numbers -or $numbers.Count -eq 0) { return @() }

    $selected = New-Object System.Collections.Generic.List[object]
    $seen = New-Object System.Collections.Generic.HashSet[int]
    foreach ($n in $numbers) {
        if ($seen.Add($n)) {
            $match = $Findings | Where-Object { $_.Id -eq $n } | Select-Object -First 1
            if ($match) { $selected.Add($match) }
        }
    }

    return $selected
}

Write-Section "Scanning Minecraft launchers and Discord variants"
$minecraftFindings = Get-MinecraftFindings
$discordFindings = Get-DiscordFindings
$findings = @($minecraftFindings) + @($discordFindings)

Show-Findings -Findings $findings

if (-not $findings -or $findings.Count -eq 0) {
    return
}

if ($ScanOnly) {
    Write-Host "ScanOnly was set. No files were deleted." -ForegroundColor Yellow
    return
}

if ($DeleteAll) {
    Remove-Targets -SelectedFindings $findings -SkipBackup:$NoBackup
    return
}

Write-Host "Delete options:" -ForegroundColor Cyan
Write-Host "  [1] Delete selected items"
Write-Host "  [2] Delete everything detected"
Write-Host "  [3] Quit"
$choice = Read-Host "Choose 1, 2, or 3"

switch ($choice) {
    '1' {
        $selected = Read-Selection -Findings $findings
        if (-not $selected -or $selected.Count -eq 0) {
            Write-Host "Nothing selected. Exiting." -ForegroundColor Yellow
            return
        }

        Write-Host ""
        Write-Host "You selected:" -ForegroundColor Cyan
        foreach ($item in $selected) {
            Write-Host ("  [{0}] {1} | {2}" -f $item.Id, $item.Category, $item.App)
        }

        $confirm = Read-Host "Type DELETE to confirm"
        if ($confirm -ceq 'DELETE') {
            Remove-Targets -SelectedFindings $selected -SkipBackup:$NoBackup
        } else {
            Write-Host "Cancelled." -ForegroundColor Yellow
        }
    }
    '2' {
        $confirm = Read-Host "Type WIPEALL to confirm deleting everything detected"
        if ($confirm -ceq 'WIPEALL') {
            Remove-Targets -SelectedFindings $findings -SkipBackup:$NoBackup
        } else {
            Write-Host "Cancelled." -ForegroundColor Yellow
        }
    }
    default {
        Write-Host "Exiting." -ForegroundColor Yellow
    }
}
