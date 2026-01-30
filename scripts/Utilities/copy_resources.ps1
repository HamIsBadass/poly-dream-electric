Set-Location -LiteralPath "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_Development\poly-dream-electric"

$imgSrc = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\2D\01_수배전개요"
$mdlSrc = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\3D"

# 2D 이미지 복사
Write-Host "Copying images..." -ForegroundColor Cyan
Get-ChildItem -Path $imgSrc -File | ForEach-Object {
  Copy-Item -Path $_.FullName -Destination "resource\asset_01_overview\images\" -Force
  Write-Host ("  copied: " + $_.Name)
}

# 3D 모델 복사
Write-Host "Copying FBX models..." -ForegroundColor Cyan
Get-ChildItem -Path $mdlSrc -Filter "*.fbx" -File -Recurse | ForEach-Object {
  Copy-Item -Path $_.FullName -Destination "resource\asset_01_overview\models\" -Force
  Write-Host ("  copied: " + $_.Name)
}

Write-Host "Done!" -ForegroundColor Green
