$basePath = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric\resource\asset_01_overview\models"

Write-Host "FBX 파일 평탄화 시작" -ForegroundColor Cyan

# 모든 FBX 파일 찾기
$fbxFiles = @(Get-ChildItem -Path $basePath -Filter "*.fbx" -File -Recurse)
Write-Host "찾은 FBX 파일: $($fbxFiles.Count)개`n"

# 파일 이동
$movedCount = 0
foreach ($fbxFile in $fbxFiles) {
    $destPath = Join-Path $basePath $fbxFile.Name
    
    # 이미 models 폴더 직하에 있으면 스킵
    if ($fbxFile.DirectoryName -eq $basePath) {
        Write-Host "✓ 이미 위치: $($fbxFile.Name)"
        $movedCount++
        continue
    }
    
    # 중복 파일명 처리
    if (Test-Path $destPath) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($fbxFile.Name)
        $ext = [System.IO.Path]::GetExtension($fbxFile.Name)
        $newName = "${name}_copy${ext}"
        $destPath = Join-Path $basePath $newName
        Write-Host "→ $($fbxFile.Name) 이름 변경: $newName"
    }
    
    # 파일 이동
    try {
        Move-Item -Path $fbxFile.FullName -Destination $destPath -Force
        Write-Host "✓ 이동: $($fbxFile.Name)"
        $movedCount++
    } catch {
        Write-Host "✗ 실패: $($fbxFile.Name) - $_"
    }
}

Write-Host "`n총 $movedCount 개 파일 이동 완료" -ForegroundColor Green

# 빈 폴더 정리
Write-Host "`n빈 폴더 정리 중..."
$folders = Get-ChildItem -Path $basePath -Directory -Recurse | Sort-Object FullName -Descending

foreach ($folder in $folders) {
    $files = @(Get-ChildItem -Path $folder.FullName -Recurse)
    if ($files.Count -eq 0) {
        Remove-Item -Path $folder.FullName -Force
        Write-Host "삭제: $($folder.Name)"
    }
}

Write-Host "`n평탄화 완료!" -ForegroundColor Green

# 최종 확인
$finalFbx = @(Get-ChildItem -Path $basePath -Filter "*.fbx" -File)
Write-Host "`n최종 FBX 파일 개수: $($finalFbx.Count)"
Write-Host "첫 10개 파일:"
$finalFbx | Select-Object -First 10 | ForEach-Object { Write-Host "  - $($_.Name)" }
if ($finalFbx.Count -gt 10) {
    Write-Host "  ... 그 외 $($finalFbx.Count - 10)개"
}
