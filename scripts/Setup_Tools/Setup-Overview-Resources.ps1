# Setup-Overview-Resources.ps1

Write-Host "=== Setup Overview Resources ===" -ForegroundColor Cyan
Write-Host ""

# 1. Design folder paths
$path2d = "..\..\05_diazin\2D\01_overview"
$path3d = "..\..\05_diazin\3D"

# 2. 리소스 폴더 생성
Write-Host "1. 리소스 폴더 생성" -ForegroundColor Yellow
$dirs = @("resource\overview\images", "resource\overview\models", "resource\overview\videos", "resource\overview\audio")
$dirs | ForEach-Object {
  if (-not (Test-Path $_)) {
    New-Item $_ -ItemType Directory -Force | Out-Null
    Write-Host "   ✓ $_"
  }
}

Write-Host ""
Write-Host "2. 2D 이미지 파일 복사" -ForegroundColor Yellow

# 2D 이미지 복사 (PNG, JPG, etc)
$images = Get-ChildItem $path2d -File -Recurse
$imgCnt = 0
$images | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|bmp)$' } | ForEach-Object {
  $destName = $_.BaseName + "_thumb" + $_.Extension
  Copy-Item $_.FullName "resource\overview\images\$destName" -Force
  $imgCnt++
}
Write-Host "   ✓ 복사됨: $imgCnt개"

Write-Host ""
Write-Host "3. 3D 모델 파일 복사" -ForegroundColor Yellow

# 3D FBX 파일 복사
$models = Get-ChildItem $path3d -Filter "*.fbx" -File -Recurse
$mdlCnt = 0
$models | ForEach-Object {
  $relPath = $_.FullName.Replace($path3d, "").TrimStart("\")
  $destDir = "resource\overview\models"
  Copy-Item $_.FullName "$destDir\$($_.Name)" -Force
  $mdlCnt++
}
Write-Host "   ✓ 복사됨: $mdlCnt개"

Write-Host ""
Write-Host "4. 최종 구조" -ForegroundColor Yellow
$totImg = (Get-ChildItem "resource\overview\images" -File -ErrorAction SilentlyContinue | Measure-Object).Count
$totMdl = (Get-ChildItem "resource\overview\models" -File -ErrorAction SilentlyContinue | Measure-Object).Count

Write-Host "   Images: $totImg" -ForegroundColor Green
Write-Host "   Models: $totMdl" -ForegroundColor Green
Write-Host ""
Write-Host "✅ 완료! resource/overview에서 미리보기 가능" -ForegroundColor Green
