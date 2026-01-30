# Prepare-Preview.ps1 - Mars의 에셋만 resource/intro에 복사 및 정리

Add-Type -AssemblyName System.IO.Compression.FileSystem

Write-Host "=== 미리보기 리소스 준비 ===" -ForegroundColor Cyan
Write-Host ""

# 1. Mars 파일에서 사용 중인 리소스 추출
$gz = [System.IO.Compression.GZipStream]::new([System.IO.File]::OpenRead("Contents/00_Intro/00_Intro.mars"), [System.IO.Compression.CompressionMode]::Decompress)
$text = ([System.IO.StreamReader]::new($gz)).ReadToEnd()
$gz.Close()

$marsAssets = @()
[regex]::Matches($text, '"ResourceName"\s*:\s*"([^"]+)"') | ForEach-Object { 
  $marsAssets += $_.Groups[1].Value 
}

Write-Host "✓ Mars에서 사용 중인 에셋: $($marsAssets.Count)개" -ForegroundColor Green
Write-Host ""

# 2. resource/intro 폴더 초기화
Write-Host "리소스 폴더 정리 중..." -ForegroundColor Yellow

@("images","models","videos","audio") | ForEach-Object {
  $path = "resource\asset_00_intro\$_"
  if (Test-Path $path) {
    Remove-Item "$path\*" -Force
  } else {
    New-Item $path -ItemType Directory -Force | Out-Null
  }
}

Write-Host "✓ 기존 파일 제거 완료" -ForegroundColor Gray
Write-Host ""

# 3. analysis_temp의 썸네일을 resource/intro에 복사
Write-Host "Mars 에셋만 복사 중..." -ForegroundColor Yellow

$copyCount = 0
$marsAssets | ForEach-Object {
  $filename = $_
  
  @("images","models","videos","audio") | ForEach-Object {
    $cat = $_
    $source = "analysis_temp\intro\resource\$cat\$filename.thumb.png"
    
    if (Test-Path $source) {
      $dest = "resource\asset_00_intro\$cat\$filename.thumb.png"
      Copy-Item $source $dest -Force
      $copyCount++
    }
  }
}

Write-Host "✓ $copyCount 개 파일 복사 완료" -ForegroundColor Green
Write-Host ""

# 4. 최종 구조 표시
Write-Host "=== Final Preview Structure ===" -ForegroundColor Cyan
Write-Host ""

@("images","models","videos","audio") | ForEach-Object {
  $count = (ls "resource\asset_00_intro\$_" -File -ErrorAction SilentlyContinue | Measure-Object).Count
  if ($count -gt 0) {
    Write-Host "$_`: $count files" -ForegroundColor Cyan
    ls "resource\asset_00_intro\$_" -File | Select-Object -First 3 | ForEach-Object {
      Write-Host "    - $($_.Name)"
    }
    if ($count -gt 3) {
      Write-Host "    ... and $($count - 3) more"
    }
    Write-Host ""
  }
}

Write-Host "Complete! Preview ready in resource/asset_00_intro" -ForegroundColor Green
