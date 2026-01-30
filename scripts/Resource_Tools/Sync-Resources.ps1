# Sync-Resources.ps1
Add-Type -AssemblyName System.IO.Compression.FileSystem

$gz = [System.IO.Compression.GZipStream]::new([System.IO.File]::OpenRead("Contents/00_Intro/00_Intro.mars"), [System.IO.Compression.CompressionMode]::Decompress)
$text = ([System.IO.StreamReader]::new($gz)).ReadToEnd()
$gz.Close()

$mars = @()
[regex]::Matches($text, '"ResourceName"\s*:\s*"([^"]+)"') | ForEach-Object { $mars += $_.Groups[1].Value }

$folder = @()
@("images","models","videos","audio") | ForEach-Object {
  Get-ChildItem "resource\asset_00_intro\$_" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $folder += ($_.Name -replace '\.thumb\.png$', '')
  }
}

$delete = @()
$folder | ForEach-Object {
  if ($mars -notcontains $_) { $delete += $_ }
}

Write-Host "=== Sync ===" -ForegroundColor Cyan
Write-Host "Mars: $($mars.Count) | Folder: $($folder.Count) | Delete: $($delete.Count)" -ForegroundColor Yellow
Write-Host ""

if ($delete.Count -eq 0) {
  Write-Host "OK: All match!" -ForegroundColor Green
  exit
}

Write-Host "Delete targets:" -ForegroundColor Red
$delete | ForEach-Object { Write-Host "  - $_" }
Write-Host ""

$cnt = 0
$delete | ForEach-Object {
  $fn = $_
  @("images","models","videos","audio") | ForEach-Object {
    $p = "resource\asset_00_intro\$_\$fn.thumb.png"
    if (Test-Path $p) {
      Remove-Item $p
      $cnt++
      Write-Host "  OK: $_/$fn"
    }
  }
}

Write-Host ""
Write-Host "Done: $cnt deleted" -ForegroundColor Green
