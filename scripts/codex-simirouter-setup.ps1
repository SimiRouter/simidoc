# SimiRouter Codex configuration manager. Uses one API key for inference and model discovery.
# Run locally: powershell -File .\codex-simirouter-setup.ps1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$scriptVersion = '1.2.0'
$inferenceBaseUrl = 'https://api.dwchainless.com/v1'
$modelCatalogUrl = 'https://api.dwchainless.com/v1/models'
$codexHomeDir = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$configPath = Join-Path $codexHomeDir 'config.toml'
$modelsPath = Join-Path $codexHomeDir 'models.json'
$catalogValue = $modelsPath
$backupRoot = Join-Path $codexHomeDir 'backup-simirouter'
$lockPath = Join-Path $codexHomeDir '.simirouter-config.lock'

function Read-Line([string]$Prompt) {
    Write-Host -NoNewline $Prompt
    return [Console]::ReadLine()
}

function Read-ApiKey {
    $secure = Read-Host 'SimiRouter API key (input hidden)' -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

function Protect-Path([string]$Path) {
    $acl = Get-Acl -LiteralPath $Path
    $acl.SetAccessRuleProtection($true, $false)
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $rule = New-Object Security.AccessControl.FileSystemAccessRule($identity, 'FullControl', 'Allow')
    $acl.SetAccessRule($rule)
    Set-Acl -LiteralPath $Path -AclObject $acl
}

function Ensure-Home {
    if (-not (Test-Path -LiteralPath $codexHomeDir)) { New-Item -ItemType Directory -Path $codexHomeDir -Force | Out-Null }
}

function Acquire-Lock {
    New-Item -ItemType Directory -Path $lockPath -ErrorAction Stop | Out-Null
    try { Set-Content -LiteralPath (Join-Path $lockPath 'pid') -Value $PID -NoNewline -Encoding ascii } catch { throw 'Cannot write lock file.' }
}

function Write-AtomicText([string]$Path, [string]$Text) {
    Assert-ConfigText $Text
    $temporary = "$Path.tmp.$([Guid]::NewGuid().ToString('N'))"
    try {
        [IO.File]::WriteAllText($temporary, $Text, [Text.UTF8Encoding]::new($false))
        Protect-Path $temporary
        Move-Item -LiteralPath $temporary -Destination $Path -Force
    } catch {
        Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue
        throw
    }
}

function Assert-ConfigText([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { throw 'Generated config.toml is empty.' }
    if (([regex]::Matches($Text, '(?m)^\s*model_provider\s*=')).Count -ne 1) { throw 'Generated config.toml must contain exactly one model_provider.' }
    if (([regex]::Matches($Text, '(?m)^\s*model\s*=')).Count -ne 1) { throw 'Generated config.toml must contain exactly one model.' }
    if (([regex]::Matches($Text, '(?m)^\s*model_catalog_json\s*=')).Count -ne 1) { throw 'Generated config.toml must contain exactly one model_catalog_json.' }
    if (([regex]::Matches($Text, '(?m)^\s*\[model_providers\.simirouter\]\s*$')).Count -ne 1) { throw 'Generated config.toml must contain one SimiRouter provider table.' }
    foreach ($key in @('name', 'base_url', 'wire_api', 'supports_websockets', 'experimental_bearer_token')) {
        if (-not [regex]::IsMatch($Text, "(?ms)^\s*\[model_providers\.simirouter\].*?^\s*$key\s*=")) { throw "Generated config.toml is missing provider field: $key" }
    }
}

function Assert-RestorableConfigText([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { throw 'Backup config.toml is empty.' }
    if ($Text.IndexOf([char]0) -ge 0) { throw 'Backup config.toml contains a NUL byte.' }
}

function Write-ModelCatalog([string]$Path, [string]$Token) {
    $response = Invoke-RestMethod -Uri $modelCatalogUrl -Headers @{ Authorization = "Bearer $Token"; Accept = 'application/json' } -TimeoutSec 30
    if ($null -eq $response.data -or @($response.data).Count -eq 0) { throw 'Model catalog response must contain a non-empty data array.' }
    $models = @()
    $seen = @{}
    $priority = 0
    foreach ($row in @($response.data)) {
        if ($null -eq $row.id -or [string]::IsNullOrWhiteSpace([string]$row.id)) { continue }
        $slug = ([string]$row.id).Trim()
        if ($seen.ContainsKey($slug)) { continue }
        $seen[$slug] = $true
        $entry = [ordered]@{
            slug = $slug
            display_name = if ($row.name) { [string]$row.name } else { $slug }
            description = "SimiRouter model ($([string]$row.owned_by))"
            supported_reasoning_levels = @()
            shell_type = 'shell_command'
            visibility = 'list'
            supported_in_api = $true
            priority = $priority
            support_verbosity = $false
            truncation_policy = [ordered]@{ mode = 'tokens'; limit = 10000 }
        }
        $contextLength = 0L
        if ([long]::TryParse([string]$row.context_length, [ref]$contextLength) -and $contextLength -gt 0) {
            $entry.context_window = $contextLength
            $entry.max_context_window = $contextLength
        }
        $models += [pscustomobject]$entry
        $priority++
    }
    if ($models.Count -eq 0) { throw 'Model catalog did not contain usable model IDs.' }
    $json = ([ordered]@{ models = $models } | ConvertTo-Json -Depth 10)
    [IO.File]::WriteAllText($Path, $json + "`n", [Text.UTF8Encoding]::new($false))
    $parsed = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($null -eq $parsed.models -or @($parsed.models).Count -eq 0) { throw 'Generated models.json failed validation.' }
}

function Assert-ModelAvailable([string]$Path, [string]$Model) {
    $parsed = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    $ids = @($parsed.models | ForEach-Object { [string]$_.slug })
    if ($ids -notcontains $Model) {
        $shown = if ($ids.Count -gt 20) { ($ids[0..19] -join ', ') + ', ...' } else { $ids -join ', ' }
        throw "Selected model '$Model' is not in the fetched catalog: $shown"
    }
}

function Convert-ToTomlString([string]$Value) { return ($Value | ConvertTo-Json -Compress) }

function Write-Config([string]$Path, [string]$Model, [string]$Token) {
    if ($Model -match '[\r\n]' -or $Token -match '[\r\n]') { throw 'Model ID and API key cannot contain newlines.' }
    $source = if (Test-Path -LiteralPath $Path) { Get-Content -LiteralPath $Path -Raw } else { '' }
    $lines = [regex]::Split($source, '(?<=\r?\n)')
    $managed = @{
        base_url = "base_url = $(Convert-ToTomlString $inferenceBaseUrl)`r`n"
        wire_api = "wire_api = `"responses`"`r`n"
        supports_websockets = "supports_websockets = false`r`n"
        name = "name = `"simirouter`"`r`n"
        experimental_bearer_token = "experimental_bearer_token = $(Convert-ToTomlString $Token)`r`n"
    }
    $modelLine = "model = $(Convert-ToTomlString $Model)`r`n"
    $catalogLine = "model_catalog_json = $(Convert-ToTomlString $catalogValue)`r`n"
    $providerLine = "model_provider = `"simirouter`"`r`n"
    $output = New-Object System.Collections.Generic.List[string]
    $section = $null
    $inProvider = $false
    $providerSeen = @{}
    $globalSeen = @{}
    $providerFlush = {
        foreach ($key in @('name', 'base_url', 'wire_api', 'supports_websockets', 'experimental_bearer_token')) {
            if (-not $providerSeen.ContainsKey($key)) { $output.Add($managed[$key]) }
        }
    }
    foreach ($line in $lines) {
        $header = [regex]::Match($line, '^\s*\[([^]]+)\]')
        if ($header.Success) {
            if ($inProvider) { & $providerFlush }
            $section = $header.Groups[1].Value.Trim()
            $inProvider = $section.Equals('model_providers.simirouter', [StringComparison]::OrdinalIgnoreCase)
            $providerSeen = @{}
            $output.Add($line)
            continue
        }
        if ($inProvider) {
            $match = [regex]::Match($line, '^\s*([A-Za-z0-9_-]+)\s*=')
            $key = if ($match.Success) { $match.Groups[1].Value } else { $null }
            if ($null -ne $key -and $managed.ContainsKey($key)) {
                if (-not $providerSeen.ContainsKey($key)) { $providerSeen[$key] = $true; $output.Add($managed[$key]) }
                continue
            }
            $output.Add($line)
            continue
        }
        if ($null -eq $section) {
            $match = [regex]::Match($line, '^\s*(model_provider|model|model_catalog_json)\s*=')
            if ($match.Success) {
                $key = $match.Groups[1].Value
                if (-not $globalSeen.ContainsKey($key)) {
                    $globalSeen[$key] = $true
                    $output.Add($(if ($key -eq 'model_provider') { $providerLine } elseif ($key -eq 'model') { $modelLine } else { $catalogLine }))
                }
                continue
            }
        }
        $output.Add($line)
    }
    if ($inProvider) { & $providerFlush }
    if (-not $inProvider -and -not ($output | Where-Object { $_ -match '^\s*\[model_providers\.simirouter\]' })) {
        if ($output.Count -gt 0 -and -not $output[$output.Count - 1].EndsWith("`n")) { $output[$output.Count - 1] += "`r`n" }
        $output.Add("`r`n[model_providers.simirouter]`r`n")
        $output.Add($managed.name); $output.Add($managed.base_url); $output.Add($managed.wire_api); $output.Add($managed.supports_websockets); $output.Add($managed.experimental_bearer_token)
    }
    $prefix = New-Object System.Collections.Generic.List[string]
    if (-not $globalSeen.ContainsKey('model_provider')) { $prefix.Add($providerLine) }
    if (-not $globalSeen.ContainsKey('model')) { $prefix.Add($modelLine) }
    if (-not $globalSeen.ContainsKey('model_catalog_json')) { $prefix.Add($catalogLine) }
    $text = (($prefix + $output) -join '')
    Write-AtomicText $Path $text
    Protect-Path $Path
}

function New-Snapshot {
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    Protect-Path $backupRoot
    $stamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ')
    $temporary = Join-Path $backupRoot ".tmp.$([Guid]::NewGuid().ToString('N'))"
    $final = Join-Path $backupRoot $stamp
    if (Test-Path -LiteralPath $final) { $final = "$final-$PID" }
    New-Item -ItemType Directory -Path $temporary | Out-Null
    if (Test-Path -LiteralPath $configPath) { Copy-Item $configPath (Join-Path $temporary 'config.toml'); Protect-Path (Join-Path $temporary 'config.toml') } else { New-Item -ItemType File (Join-Path $temporary 'config.toml.absent') | Out-Null; Protect-Path (Join-Path $temporary 'config.toml.absent') }
    if (Test-Path -LiteralPath $modelsPath) { Copy-Item $modelsPath (Join-Path $temporary 'models.json'); Protect-Path (Join-Path $temporary 'models.json') } else { New-Item -ItemType File (Join-Path $temporary 'models.json.absent') | Out-Null; Protect-Path (Join-Path $temporary 'models.json.absent') }
    [IO.File]::WriteAllText((Join-Path $temporary 'manifest.txt'), "version=$scriptVersion`ncreated_at=$stamp`ninference_base_url=$inferenceBaseUrl`nmodel_catalog_url=$modelCatalogUrl`n", [Text.UTF8Encoding]::new($false))
    Protect-Path (Join-Path $temporary 'manifest.txt')
    Move-Item -LiteralPath $temporary -Destination $final
    Protect-Path $final
    return $final
}

function Read-ExistingToken {
    if (-not (Test-Path -LiteralPath $configPath)) { return '' }
    $text = Get-Content -LiteralPath $configPath -Raw
    $match = [regex]::Match($text, '(?ms)^\s*\[model_providers\.simirouter\].*?^\s*experimental_bearer_token\s*=\s*"((?:\\.|[^"\\])*)"')
    if ($match.Success) { return $match.Groups[1].Value }
    return ''
}

function Restore-Latest {
    if (-not (Test-Path -LiteralPath $backupRoot)) { throw 'No backup snapshots found.' }
    $requested = Read-Line 'Backup name (blank = latest): '
    if ($requested) {
        if ($requested -notmatch '^[A-Za-z0-9_.-]+$') { throw 'Invalid backup name.' }
        $snapshot = Get-Item -LiteralPath (Join-Path $backupRoot $requested) -ErrorAction Stop
    } else {
        $snapshot = Get-ChildItem -LiteralPath $backupRoot -Directory | Where-Object { $_.Name -notlike '.tmp.*' } | Sort-Object Name | Select-Object -Last 1
    }
    if ($null -eq $snapshot) { throw 'No backup snapshots found.' }
    $confirm = Read-Line "Type RESTORE to restore $($snapshot.Name): "
    if ($confirm -cne 'RESTORE') { Write-Host 'Restore cancelled.'; return }
    $currentBackup = New-Snapshot
    foreach ($name in @('config.toml')) {
        $source = Join-Path $snapshot.FullName $name
        $temporary = Join-Path $codexHomeDir ".${name}.restore.$([Guid]::NewGuid().ToString('N'))"
        if (Test-Path -LiteralPath $source) {
            Copy-Item $source $temporary
            Protect-Path $temporary
            try {
                $restored = Get-Content -LiteralPath $temporary -Raw
                Assert-RestorableConfigText $restored
                Move-Item $temporary (Join-Path $codexHomeDir $name) -Force
            }
            finally {
                Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue
            }
            Protect-Path (Join-Path $codexHomeDir $name)
        }
        elseif (Test-Path -LiteralPath ("$source.absent")) { Remove-Item -LiteralPath (Join-Path $codexHomeDir $name) -Force -ErrorAction SilentlyContinue }
    }
    $modelsSource = Join-Path $snapshot.FullName 'models.json'
    $modelsTemporary = Join-Path $codexHomeDir ".models.json.restore.$([Guid]::NewGuid().ToString('N'))"
    if (Test-Path -LiteralPath $modelsSource) {
        Copy-Item $modelsSource $modelsTemporary
        try {
            $parsed = Get-Content -LiteralPath $modelsTemporary -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($null -eq $parsed.models -or @($parsed.models).Count -eq 0) { throw 'Backup models.json is invalid.' }
            Move-Item $modelsTemporary $modelsPath -Force
        } finally { Remove-Item -LiteralPath $modelsTemporary -Force -ErrorAction SilentlyContinue }
    } elseif (Test-Path -LiteralPath ("$modelsSource.absent")) { Remove-Item -LiteralPath $modelsPath -Force -ErrorAction SilentlyContinue }
    else { Remove-Item -LiteralPath $modelsPath -Force -ErrorAction SilentlyContinue }
    Write-Host "Restored $($snapshot.Name). Current state backed up at $([IO.Path]::GetFileName($currentBackup))."
}

Ensure-Home
Acquire-Lock
try {
Write-Host "SimiRouter Codex setup $scriptVersion"
Write-Host "CODEX_HOME: $codexHomeDir"
Write-Host '1) Configure SimiRouter'
Write-Host '2) Restore latest backup'
Write-Host 'q) Exit'
$choice = Read-Line 'Choose [1/2/q]: '
switch ($choice) {
    { $_ -eq '1' -or $_ -eq '' } {
        Write-Host "Inference URL: $inferenceBaseUrl"
        Write-Host "Model catalog URL: $modelCatalogUrl"
        Write-Host 'Model 1: gpt-6-astra (documented default)'
        Write-Host 'Model 2: custom model ID'
        $modelChoice = Read-Line 'Choose model [1/2] (default 1): '
        if ($modelChoice -eq '2') { $model = Read-Line 'Model ID: '; if ([string]::IsNullOrWhiteSpace($model)) { throw 'Model ID cannot be empty.' } } else { $model = 'gpt-6-astra' }
        $token = Read-ApiKey
        if ([string]::IsNullOrWhiteSpace($token)) { $token = Read-ExistingToken }
        if ([string]::IsNullOrWhiteSpace($token)) { throw 'API key is required for first-time setup.' }
        $snapshotPath = New-Snapshot
        $modelsTemporary = Join-Path $codexHomeDir ".models.json.stage.$([Guid]::NewGuid().ToString('N'))"
        $configTemporary = Join-Path $codexHomeDir ".config.toml.stage.$([Guid]::NewGuid().ToString('N'))"
        try {
            Write-ModelCatalog $modelsTemporary $token
            Protect-Path $modelsTemporary
            Assert-ModelAvailable $modelsTemporary $model
            if (Test-Path -LiteralPath $configPath) { Copy-Item $configPath $configTemporary } else { New-Item -ItemType File -Path $configTemporary | Out-Null }
            Protect-Path $configTemporary
            Write-Config $configTemporary $model $token
            Move-Item -LiteralPath $configTemporary -Destination $configPath -Force
            Protect-Path $configPath
            Move-Item -LiteralPath $modelsTemporary -Destination $modelsPath -Force
            Protect-Path $modelsPath
        } catch {
            Remove-Item -LiteralPath $modelsTemporary -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $configTemporary -Force -ErrorAction SilentlyContinue
            $savedConfig = Join-Path $snapshotPath 'config.toml'
            $savedModels = Join-Path $snapshotPath 'models.json'
            if (Test-Path -LiteralPath $savedConfig) { Copy-Item -LiteralPath $savedConfig -Destination $configPath -Force } else { Remove-Item -LiteralPath $configPath -Force -ErrorAction SilentlyContinue }
            if (Test-Path -LiteralPath $savedModels) { Copy-Item -LiteralPath $savedModels -Destination $modelsPath -Force } else { Remove-Item -LiteralPath $modelsPath -Force -ErrorAction SilentlyContinue }
            throw
        }
        Write-Host "Configured $model. Backup: $snapshotPath"
    }
    '2' { Restore-Latest }
    'q' { Write-Host 'Cancelled.' }
    'Q' { Write-Host 'Cancelled.' }
    default { throw 'Invalid choice.' }
}
finally {
    Remove-Item -LiteralPath $lockPath -Recurse -Force -ErrorAction SilentlyContinue
}
