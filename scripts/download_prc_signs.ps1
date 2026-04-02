param(
  [string]$OutDir = "D:\Sigenerator\assets\road_signs_info\svg",
  [string]$ManifestPath = "D:\Sigenerator\assets\road_signs_info\manifest.json",
  [string]$FailedPath = "D:\Sigenerator\assets\road_signs_info\failed.json",
  [string]$CategoryTitle = "Category:SVG_information_road_signs_of_China"
)

$ErrorActionPreference = "Stop"

function Build-Query([hashtable]$params) {
  $pairs = @()
  foreach ($key in ($params.Keys | Sort-Object)) {
    $pairs += ("{0}={1}" -f $key, [System.Uri]::EscapeDataString([string]$params[$key]))
  }
  return ($pairs -join "&")
}

function Sanitize-FileName([string]$name) {
  $name = $name -replace '^File:', ''
  $name = $name -replace '\s+', '_'
  $name = $name -replace '[<>:"/\\|?*]', ''
  return $name
}

function Test-SvgFile([string]$path) {
  if (-not (Test-Path $path)) { return $false }
  try {
    $head = (Get-Content -Path $path -TotalCount 5 -ErrorAction Stop) -join "`n"
    return ($head -match '<svg' -or $head -match '<\\?xml')
  } catch {
    return $false
  }
}

function Download-With-Retry([string]$url, [string]$outFile, [int]$maxRetry = 6) {
  $attempt = 0
  while ($true) {
    try {
      Invoke-WebRequest -Uri $url -OutFile $outFile -Headers @{ "User-Agent" = "SigeneratorAssetFetcher/1.0"; "Accept" = "image/svg+xml" } -TimeoutSec 120
      if (-not (Test-SvgFile $outFile)) {
        Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
        throw "Invalid SVG content"
      }
      return $true
    } catch {
      $attempt++
      $resp = $_.Exception.Response
      if ($resp) {
        $statusCode = [int]$resp.StatusCode
        if ($statusCode -eq 429) {
          if ($attempt -ge $maxRetry) { return $false }
          Start-Sleep -Seconds 20
          continue
        }
      }
      if ($attempt -ge $maxRetry) { return $false }
      $sleep = [math]::Min(30, [math]::Pow(2, $attempt))
      Start-Sleep -Seconds $sleep
    }
  }
}

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path $ManifestPath) -Force | Out-Null

$api = "https://commons.wikimedia.org/w/api.php"
$category = $CategoryTitle
$files = @()
$cmcontinue = $null

do {
  $params = @{
    action   = "query"
    list     = "categorymembers"
    cmtitle  = $category
    cmtype   = "file"
    cmlimit  = 500
    format   = "json"
  }
  if ($cmcontinue) { $params.cmcontinue = $cmcontinue }
  $query = Build-Query $params
  $builder = [System.UriBuilder]$api
  $builder.Query = $query
  $resp = Invoke-RestMethod -Uri $builder.Uri -Headers @{ "User-Agent" = "SigeneratorAssetFetcher/1.0"; "Accept"="application/json" }
  if ($resp.query.categorymembers) {
    $files += $resp.query.categorymembers
  }
  $cmcontinue = $resp.continue.cmcontinue
} while ($cmcontinue)

$manifest = @()
$failed = @()
$index = 0
foreach ($file in $files) {
  $index++
  $title = $file.title
  $infoParams = @{
    action  = "query"
    prop    = "imageinfo"
    iiprop  = "url|mime"
    titles  = $title
    format  = "json"
  }
  $infoQuery = Build-Query $infoParams
  $infoBuilder = [System.UriBuilder]$api
  $infoBuilder.Query = $infoQuery
  $info = Invoke-RestMethod -Uri $infoBuilder.Uri -Headers @{ "User-Agent" = "SigeneratorAssetFetcher/1.0"; "Accept"="application/json" }
  $page = $info.query.pages.psobject.Properties.Value | Select-Object -First 1
  $url = $page.imageinfo[0].url
  if (-not $url) { continue }

  $localName = Sanitize-FileName $title
  $localPath = Join-Path $OutDir $localName
  $suffix = 1
  while ((Test-Path $localPath) -and (-not (Test-SvgFile $localPath))) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($localName)
    $ext = [System.IO.Path]::GetExtension($localName)
    $localName = "${base}_$suffix$ext"
    $localPath = Join-Path $OutDir $localName
    $suffix++
  }

  try {
    if (Test-SvgFile $localPath) {
      Write-Host "[$index/$($files.Count)] $localName (cached)"
    } else {
      Write-Host "[$index/$($files.Count)] $localName"
      $ok = Download-With-Retry -url $url -outFile $localPath
      if (-not $ok) { throw "Download failed after retries" }
      Start-Sleep -Seconds 2
    }

    $manifest += [pscustomobject]@{
      title = $title
      localFile = $localName
      sourceUrl = $url
    }
  } catch {
    $failed += [pscustomobject]@{
      title = $title
      localFile = $localName
      sourceUrl = $url
      error = $_.Exception.Message
    }
    Write-Host "Skip failed: $title"
  }
}

$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $ManifestPath -Encoding UTF8
Write-Host "Saved manifest to $ManifestPath"
$failed | ConvertTo-Json -Depth 6 | Set-Content -Path $FailedPath -Encoding UTF8
Write-Host "Saved failed list to $FailedPath"
