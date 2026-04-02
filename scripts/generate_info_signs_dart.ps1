param(
  [string]$ManifestPath = "D:\Sigenerator\assets\road_signs_info\manifest.json",
  [string]$OutFile = "D:\Sigenerator\lib\signs\china_information_signs.dart"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ManifestPath)) {
  throw "Manifest not found: $ManifestPath"
}

$items = Get-Content $ManifestPath -Raw | ConvertFrom-Json
if ($items -isnot [array]) { $items = @($items) }
$items = $items | Sort-Object localFile

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("import 'package:flutter/material.dart';")
$lines.Add("import '../models/traffic_sign.dart';")
$lines.Add("")
$lines.Add("// Generated from assets/road_signs_info/manifest.json.")
$lines.Add("// Run scripts/generate_info_signs_dart.ps1 after manifest updates.")
$lines.Add("const List<TrafficSign> chinaInformationSigns = <TrafficSign>[")

$index = 1
foreach ($item in $items) {
  $title = [string]$item.title
  $name = ($title -replace '^File:\s*', '') -replace "'", "\\'"
  $localFile = ([string]$item.localFile) -replace "'", "\\'"
  $sourceUrl = ([string]$item.sourceUrl) -replace "'", "\\'"
  $id = "info-cn-{0:d3}" -f $index

  $lines.Add("  TrafficSign(")
  $lines.Add("    id: '$id',")
  $lines.Add("    name: '$name',")
  $lines.Add("    code: 'GB 5768.2-2022',")
  $lines.Add("    category: SignCategory.information,")
  $lines.Add("    shape: SignShape.rectangle,")
  $lines.Add("    primaryColor: Color(0xFF1A5FB4),")
  $lines.Add("    secondaryColor: Color(0xFFFFFFFF),")
  $lines.Add("    assetPath: 'assets/road_signs_info/svg/$localFile',")
  $lines.Add("    description: '$sourceUrl',")
  $lines.Add("  ),")

  $index++
}

$lines.Add("];")

New-Item -ItemType Directory -Path (Split-Path $OutFile) -Force | Out-Null
[System.IO.File]::WriteAllLines($OutFile, $lines, [System.Text.Encoding]::UTF8)
Write-Host "Generated $OutFile with $($items.Count) entries."
