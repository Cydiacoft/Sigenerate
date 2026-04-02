param(
  [string]$ManifestPath = "D:\Sigenerator\assets\road_signs_info\manifest.json",
  [string]$SvgDir = "D:\Sigenerator\assets\road_signs_info\svg"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ManifestPath)) {
  throw "Manifest not found: $ManifestPath"
}
if (-not (Test-Path $SvgDir)) {
  throw "SVG dir not found: $SvgDir"
}

$items = Get-Content $ManifestPath -Raw | ConvertFrom-Json
if ($items -isnot [array]) { $items = @($items) }

$missing = @()
$seen = @{}

foreach ($item in $items) {
  $localFile = [string]$item.localFile
  if ([string]::IsNullOrWhiteSpace($localFile)) {
    $missing += "Empty localFile for title: $($item.title)"
    continue
  }
  $path = Join-Path $SvgDir $localFile
  if (-not (Test-Path $path)) {
    $missing += "Missing file: $path"
  }
  if ($seen.ContainsKey($localFile)) {
    $missing += "Duplicate localFile in manifest: $localFile"
  } else {
    $seen[$localFile] = $true
  }
}

if ($missing.Count -gt 0) {
  Write-Host "Validation failed ($($missing.Count) issues):"
  $missing | ForEach-Object { Write-Host " - $_" }
  exit 1
}

$svgCount = (Get-ChildItem $SvgDir -File -Filter *.svg | Measure-Object).Count
Write-Host "Validation passed."
Write-Host "Manifest entries: $($items.Count)"
Write-Host "SVG files: $svgCount"
