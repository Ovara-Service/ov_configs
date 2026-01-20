# build-zip.ps1
# Version 1.1.0
# Execute: .\build-zip.ps1
# Packt deterministisch eine ZIP mit sauberer Root-Struktur (PS 5.1 + 7.x kompatibel)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Ein zentraler Projekt-/Ordnername. Hier EINMAL anpassen, um ZIP-Datei und Root-Ordner in der ZIP zu ändern.
$ProjectName = 'ov_configs'

function Get-RelativePath {
    param([string]$Root, [string]$FullPath)
    $rootFull = (Resolve-Path -LiteralPath $Root).ProviderPath
    $fp = (Resolve-Path -LiteralPath $FullPath).ProviderPath
    if (-not $rootFull.EndsWith('\')) { $rootFull += '\' }
    if ($fp.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fp.Substring($rootFull.Length).Replace('\','/')
    } else {
        return (Split-Path -Leaf $fp).Replace('\','/')
    }
}

function Get-VersionFromFxManifest {
    param([string]$ManifestPath)
    if (!(Test-Path -LiteralPath $ManifestPath)) {
        throw "fxmanifest.lua nicht gefunden: $ManifestPath"
    }
    $content = Get-Content -LiteralPath $ManifestPath -Raw
    $m = [regex]::Match($content, "(?m)^\s*version\s*'([^']+)'")
    if (!$m.Success) {
        throw "Konnte Version aus fxmanifest.lua nicht lesen (erwarte: version 'x.y.z')."
    }
    return $m.Groups[1].Value
}

function Read-IncludePatterns {
    param([string]$IncludeFile)
    if (!(Test-Path -LiteralPath $IncludeFile)) {
        throw "include.txt nicht gefunden: $IncludeFile"
    }
    $lines = Get-Content -LiteralPath $IncludeFile | ForEach-Object { ($_ -as [string]).Trim() } |
            Where-Object { $_ -and -not $_.StartsWith('#') }

    $includes = New-Object System.Collections.Generic.List[string]
    $excludes = New-Object System.Collections.Generic.List[string]
    foreach ($l in $lines) {
        if ($l.StartsWith('!')) { $excludes.Add($l.Substring(1)) } else { $includes.Add($l) }
    }
    return [PSCustomObject]@{ Includes = $includes; Excludes = $excludes }
}

function Resolve-GlobsRelative {
    param(
        [string]$Root,
        [System.Collections.Generic.List[string]]$Patterns
    )
    $results = New-Object System.Collections.Generic.HashSet[string] ([StringComparer]::OrdinalIgnoreCase)

    foreach ($pat in $Patterns) {
        $fullPat = Join-Path $Root $pat

        # 1) Exakter Ordner?
        if (Test-Path -LiteralPath $fullPat -PathType Container -ErrorAction SilentlyContinue) {
            Get-ChildItem -LiteralPath $fullPat -Recurse -File | ForEach-Object {
                $results.Add((Get-RelativePath -Root $Root -FullPath $_.FullName)) | Out-Null
            }
            continue
        }

        # 2) Dateien/Globs
        $items = Get-ChildItem -Path $fullPat -Recurse -File -ErrorAction SilentlyContinue
        foreach ($i in $items) {
            $results.Add((Get-RelativePath -Root $Root -FullPath $i.FullName)) | Out-Null
        }

        # 3) Exakte Datei ohne Globs
        if (($pat -notmatch '[\*\?\[\]]') -and (Test-Path -LiteralPath $fullPat -ErrorAction SilentlyContinue)) {
            if (-not (Get-Item -LiteralPath $fullPat).PSIsContainer) {
                $results.Add((Get-RelativePath -Root $Root -FullPath $fullPat)) | Out-Null
            }
        }
    }
    return $results
}

function Apply-Excludes {
    param(
        [System.Collections.Generic.HashSet[string]]$RelFiles,
        [string]$Root,
        [System.Collections.Generic.List[string]]$ExcludePatterns
    )
    if ($ExcludePatterns.Count -eq 0) { return $RelFiles }

    $toRemove = New-Object System.Collections.Generic.HashSet[string] ([StringComparer]::OrdinalIgnoreCase)
    foreach ($pat in $ExcludePatterns) {
        $fullPat = Join-Path $Root $pat

        # Ordner-Excludes
        if (Test-Path -LiteralPath $fullPat -PathType Container -ErrorAction SilentlyContinue) {
            Get-ChildItem -LiteralPath $fullPat -Recurse -File | ForEach-Object {
                $toRemove.Add((Get-RelativePath -Root $Root -FullPath $_.FullName)) | Out-Null
            }
            continue
        }

        # Datei/Glob-Excludes
        $items = Get-ChildItem -Path $fullPat -Recurse -File -ErrorAction SilentlyContinue
        foreach ($i in $items) {
            $toRemove.Add((Get-RelativePath -Root $Root -FullPath $i.FullName)) | Out-Null
        }

        # Exakte Datei
        if (($pat -notmatch '[\*\?\[\]]') -and (Test-Path -LiteralPath $fullPat -ErrorAction SilentlyContinue)) {
            if (-not (Get-Item -LiteralPath $fullPat).PSIsContainer) {
                $toRemove.Add((Get-RelativePath -Root $Root -FullPath $fullPat)) | Out-Null
            }
        }
    }

    $RelFiles.RemoveWhere({ param($x) $toRemove.Contains($x) }) | Out-Null
    return $RelFiles
}

# --------- MAIN ---------
$root = $PSScriptRoot
if (-not $root) { $root = Split-Path -Parent $MyInvocation.MyCommand.Path }
Set-Location -LiteralPath $root

$fx = Join-Path $root 'fxmanifest.lua'
$version = Get-VersionFromFxManifest -ManifestPath $fx

$distDir = Join-Path $root 'dist'
if (!(Test-Path -LiteralPath $distDir)) { New-Item -ItemType Directory -Path $distDir | Out-Null }

$zipName = "$ProjectName-v$version.zip"
$zipPath = Join-Path $distDir $zipName
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }

$inc = Read-IncludePatterns -IncludeFile (Join-Path $root 'include.txt')

# Standard-Excludes ergänzen
$defaultEx = @('**/.git/**','**/node_modules/**','**/.DS_Store','**/Thumbs.db','**/.gitignore','**/.gitattributes')
foreach ($d in $defaultEx) { if (-not $inc.Excludes.Contains($d)) { $inc.Excludes.Add($d) } }

$relFiles = Resolve-GlobsRelative -Root $root -Patterns $inc.Includes
$relFiles = Apply-Excludes -RelFiles $relFiles -Root $root -ExcludePatterns $inc.Excludes

if ($relFiles.Count -eq 0) { throw "Die berechnete Include-Menge ist leer. Bitte include.txt prüfen." }

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

# ZIP erstellen: alle Entries unter einheitlichem Root-Ordner
$zip = $null
$zipStream = $null
try {
    $zipStream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::Create)

    # PS 5.1: ZipArchiveMode.Create (int Wert 1)
    $zip = New-Object System.IO.Compression.ZipArchive($zipStream, 1, $false)
    $zipRoot = "$ProjectName/"

    foreach ($rel in $relFiles) {
        $src = Join-Path $root $rel
        $entryName = ($zipRoot + $rel).Replace('\','/')
        $entry = $zip.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)

        $in = [System.IO.File]::OpenRead($src)
        try {
            $out = $entry.Open()
            try {
                $in.CopyTo($out)
            } finally { $out.Dispose() }
        } finally { $in.Dispose() }
    }
}
finally {
    if ($zip) { $zip.Dispose() }
    if ($zipStream) { $zipStream.Dispose() }
}

Write-Host "[SUCCESS] ZIP erstellt: $zipPath"