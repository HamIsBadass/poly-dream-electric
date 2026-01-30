Set-Location "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_Development\poly-dream-electric"

$imgSrc = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\2D\01_수배전개요"
$mdlSrc = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\3D"

# Create folder structure
@("resource\asset_01_overview", "resource\asset_01_overview\images", "resource\asset_01_overview\models", "resource\asset_01_overview\videos", "resource\asset_01_overview\audio") | ForEach-Object {
  if (-not (Test-Path $_)) { mkdir $_ }
}

# Copy images
Get-ChildItem $imgSrc -File | ForEach-Object {
  Copy-Item $_.FullName "resource\asset_01_overview\images\$($_.Name)" -Force
}

# Copy FBX models
Get-ChildItem $mdlSrc -Filter "*.fbx" -File -Recurse | ForEach-Object {
  Copy-Item $_.FullName "resource\asset_01_overview\models\$($_.Name)" -Force
}

Write-Host "Done"
