<#
.SYNOPSIS
리소스 폴더의 변경사항을 감지하고 추적

.DESCRIPTION
하이브리드 전략: 변경 추적 시스템
- 각 파일의 SHA256 해시 계산
- 원본 해시와 비교하여 변경 감지
- 신규 파일 감지
- 삭제된 파일 감지
- resource_changes.json 업데이트

변경 상태:
  - new: 새로 추가된 파일
  - modified: 기존 파일 수정됨
  - deleted: 삭제된 파일
  - unchanged: 변경 없음

.PARAMETER ResourceDir
모니터링할 리소스 폴더
기본값: resource/intro

.PARAMETER InventoryFile
RESOURCE_INVENTORY.json 경로
기본값: resource/intro/RESOURCE_INVENTORY.json

.PARAMETER SaveChanges
변경사항 JSON 저장 여부
기본값: $true

.PARAMETER RemoveUnchanged
변경 없는 항목 저장 여부
기본값: $false (용량 절감)

.EXAMPLE
.\Track-Changes.ps1 -ResourceDir "resource/intro" -InventoryFile "resource/intro/RESOURCE_INVENTORY.json"

.EXAMPLE
# 자동 실행 (스케줄 태스크)
.\Track-Changes.ps1 | Out-Null
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceDir = "resource/intro",
    
    [Parameter(Mandatory=$false)]
    [string]$InventoryFile = "resource/intro/RESOURCE_INVENTORY.json",
    
    [Parameter(Mandatory=$false)]
    [bool]$SaveChanges = $true,
    
    [Parameter(Mandatory=$false)]
    [bool]$RemoveUnchanged = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

#region Helper Functions
function Get-FileHash256 {
    param([string]$FilePath)
    
    try {
        return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
    }
    catch {
        Write-Warning "해시 계산 실패 ($FilePath): $_"
        return $null
    }
}

function Read-OriginalHash {
    param([string]$FilePath)
    
    $hashFile = "$FilePath.sha256"
    if (Test-Path $hashFile) {
        return (Get-Content $hashFile -Raw).Trim()
    }
    return $null
}

function Update-OriginalHash {
    param(
        [string]$FilePath,
        [string]$Hash
    )
    
    try {
        $Hash | Set-Content "$FilePath.sha256" -Encoding UTF8 -NoNewline -ErrorAction SilentlyContinue
        return $true
    }
    catch {
        return $false
    }
}

function New-ChangeRecord {
    param(
        [string]$FileName,
        [string]$RelativePath,
        [ValidateSet('new', 'modified', 'deleted', 'unchanged')]
        [string]$Status,
        [string]$OriginalHash = $null,
        [string]$CurrentHash = $null,
        [string]$ResourceId = $null
    )
    
    $record = @{
        file = $FileName
        path = $RelativePath
        status = $Status
        timestamp = (Get-Date -AsUTC).ToString("o")
    }
    
    if ($OriginalHash) { $record.original_hash = $OriginalHash }
    if ($CurrentHash) { $record.current_hash = $CurrentHash }
    if ($ResourceId) { $record.resource_id = $ResourceId }
    
    switch ($Status) {
        'modified' { $record.action = 'update_in_mars'; break }
        'new' { $record.action = 'add_to_mars'; break }
        'deleted' { $record.action = 'remove_from_mars'; break }
        'unchanged' { $record.action = 'none'; break }
    }
    
    return $record
}

function Write-ChangeLog {
    param(
        [array]$Changes,
        [string]$Status
    )
    
    $statusIcon = @{
        'new' = '➕'
        'modified' = '✏️ '
        'deleted' = '🗑️ '
        'unchanged' = '✔️ '
    }
    
    $statusColor = @{
        'new' = 'Green'
        'modified' = 'Yellow'
        'deleted' = 'Red'
        'unchanged' = 'Gray'
    }
    
    foreach ($change in $Changes) {
        if ($change.status -eq $Status) {
            Write-Host "  $($statusIcon[$Status]) $($change.path)" -ForegroundColor $statusColor[$Status]
            if ($Verbose -and ($Status -eq 'modified')) {
                Write-Host "      원본: $($change.original_hash.Substring(0, 8))..." -ForegroundColor DarkGray
                Write-Host "      현재: $($change.current_hash.Substring(0, 8))..." -ForegroundColor DarkGray
            }
        }
    }
}
#endregion

#region Main Logic
Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "🔍 리소스 변경사항 추적" -ForegroundColor Cyan
Write-Host "="*70 -ForegroundColor Cyan

# 1. 인벤토리 로드
if (-not (Test-Path $InventoryFile)) {
    Write-Host "⚠️  인벤토리 파일을 찾을 수 없음: $InventoryFile" -ForegroundColor Yellow
    Write-Host "💡 먼저 Extract-Thumbnails.ps1을 실행하세요." -ForegroundColor Cyan
    exit 1
}

Write-Host "`n📋 인벤토리 로드 중..." -ForegroundColor Cyan
try {
    $inventory = Get-Content $InventoryFile -Encoding UTF8 | ConvertFrom-Json
    Write-Host "✅ 인벤토리 로드 완료: $($inventory.resources.Count)개 항목" -ForegroundColor Green
}
catch {
    Write-Host "❌ 인벤토리 파싱 오류: $_" -ForegroundColor Red
    exit 1
}

# 2. 리소스 폴더 스캔
Write-Host "`n🔎 리소스 폴더 스캔 중..." -ForegroundColor Cyan

if (-not (Test-Path $ResourceDir)) {
    Write-Host "❌ 리소스 폴더를 찾을 수 없음: $ResourceDir" -ForegroundColor Red
    exit 1
}

$allFiles = @()
$validExtensions = @('.png', '.jpg', '.jpeg', '.fbx', '.glb', '.gltf', '.mp3', '.wav', '.ogg', '.mp4', '.mov')

Get-ChildItem -Path $ResourceDir -Recurse -File |
Where-Object {
    $ext = $_.Extension.ToLower()
    $name = $_.Name
    # 썸네일, 메타데이터, 해시 파일 제외
    -not ($name.StartsWith('THUMB_') -or $name.EndsWith('.sha256') -or $name.EndsWith('.status.json') -or $name -match '\.meta\.json$') -and
    $ext -in $validExtensions
} |
ForEach-Object {
    $allFiles += $_
}

Write-Host "✅ 스캔 완료: $($allFiles.Count)개 파일 발견" -ForegroundColor Green

# 3. 변경사항 분석
Write-Host "`n📊 변경사항 분석 중..." -ForegroundColor Cyan

$changes = @()
$allExtractedFiles = @{}

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace("$ResourceDir\", "").Replace("\", "/")
    $currentHash = Get-FileHash256 -FilePath $file.FullName
    $originalHash = Read-OriginalHash -FilePath $file.FullName
    
    # 인벤토리에서 해당 리소스 찾기 (파일명 기반)
    $baseName = $file.BaseName
    $inventoryItem = $inventory.resources | Where-Object { $_.name -eq $baseName }
    $resourceId = if ($inventoryItem) { $inventoryItem.id } else { $null }
    
    $allExtractedFiles[$relativePath] = @{
        hash = $currentHash
        resourceId = $resourceId
    }
    
    if ($originalHash) {
        # 기존 파일 - 변경 감지
        if ($originalHash -ne $currentHash) {
            # 수정됨
            $changes += New-ChangeRecord -FileName $file.Name -RelativePath $relativePath -Status 'modified' -OriginalHash $originalHash -CurrentHash $currentHash -ResourceId $resourceId
            
            # 새 해시값 저장
            Update-OriginalHash -FilePath $file.FullName -Hash $currentHash
        }
        else {
            # 변경 없음
            if ($RemoveUnchanged) {
                # 변경 없음 항목은 저장하지 않음 (용량 절감)
            }
            else {
                $changes += New-ChangeRecord -FileName $file.Name -RelativePath $relativePath -Status 'unchanged' -CurrentHash $currentHash -ResourceId $resourceId
            }
        }
    }
    else {
        # 새 파일
        $changes += New-ChangeRecord -FileName $file.Name -RelativePath $relativePath -Status 'new' -CurrentHash $currentHash -ResourceId $resourceId
        
        # 해시값 기록
        Update-OriginalHash -FilePath $file.FullName -Hash $currentHash
    }
}

# 4. 삭제된 파일 감지
Write-Host "`n🗑️  삭제된 파일 확인 중..." -ForegroundColor Cyan

$deletedCount = 0
foreach ($resource in $inventory.resources) {
    if ($resource.resource_path) {
        $fullPath = $resource.resource_path
        if (-not (Test-Path $fullPath) -and -not ($fullPath.StartsWith('THUMB_'))) {
            $changes += New-ChangeRecord -FileName $resource.name -RelativePath $resource.resource_path -Status 'deleted' -ResourceId $resource.id
            $deletedCount++
        }
    }
}

if ($deletedCount -gt 0) {
    Write-Host "✅ $deletedCount개 삭제된 파일 감지" -ForegroundColor Green
}

# 5. 변경사항 요약
Write-Host "`n" + ("="*70) -ForegroundColor Yellow
Write-Host "📈 변경사항 요약" -ForegroundColor Yellow
Write-Host "="*70 -ForegroundColor Yellow

$newCount = ($changes | Where-Object { $_.status -eq 'new' }).Count
$modifiedCount = ($changes | Where-Object { $_.status -eq 'modified' }).Count
$deletedCount = ($changes | Where-Object { $_.status -eq 'deleted' }).Count
$unchangedCount = ($changes | Where-Object { $_.status -eq 'unchanged' }).Count

Write-Host "`n新규 파일:" -ForegroundColor Green
Write-ChangeLog -Changes $changes -Status 'new'
Write-Host "  총: $newCount개" -ForegroundColor Green

Write-Host "`n수정된 파일:" -ForegroundColor Yellow
Write-ChangeLog -Changes $changes -Status 'modified'
Write-Host "  총: $modifiedCount개" -ForegroundColor Yellow

Write-Host "`n삭제된 파일:" -ForegroundColor Red
Write-ChangeLog -Changes $changes -Status 'deleted'
Write-Host "  총: $deletedCount개" -ForegroundColor Red

if (-not $RemoveUnchanged) {
    Write-Host "`n변경 없음:" -ForegroundColor Gray
    $unchanged = ($changes | Where-Object { $_.status -eq 'unchanged' })
    if ($unchanged.Count -gt 0) {
        Write-Host "  총: $unchangedCount개 (상세 출력 생략)" -ForegroundColor Gray
    }
    else {
        Write-Host "  총: 0개" -ForegroundColor Gray
    }
}

# 6. 변경사항 JSON 저장
if ($SaveChanges) {
    Write-Host "`n💾 변경사항 저장 중..." -ForegroundColor Cyan
    
    $changesData = @{
        tracking_metadata = @{
            last_scan = (Get-Date -AsUTC).ToString("o")
            base_path = $ResourceDir
            inventory_file = $InventoryFile
            total_changes = $changes.Count
            summary = @{
                new = $newCount
                modified = $modifiedCount
                deleted = $deletedCount
                unchanged = $unchangedCount
            }
        }
        changes = @($changes | Where-Object { $_.status -ne 'unchanged' })
    }
    
    $changesPath = "analysis_temp/$(Split-Path $ResourceDir -Leaf)/resource_changes.json"
    $changesDir = Split-Path $changesPath
    
    if (-not (Test-Path $changesDir)) {
        New-Item -ItemType Directory -Path $changesDir -Force | Out-Null
    }
    
    $changesData | ConvertTo-Json -Depth 10 | Set-Content $changesPath -Encoding UTF8
    Write-Host "✅ 저장됨: $changesPath" -ForegroundColor Green
}

# 7. 마이그레이션 가이드
if ($newCount -gt 0 -or $modifiedCount -gt 0) {
    Write-Host "`n" + ("="*70) -ForegroundColor Cyan
    Write-Host "📌 다음 단계" -ForegroundColor Cyan
    Write-Host "="*70 -ForegroundColor Cyan
    Write-Host "`n변경된 리소스를 Mars에 통합하려면:" -ForegroundColor Yellow
    Write-Host "  1. resource_changes.json 검토" -ForegroundColor Gray
    Write-Host "  2. Build-Mars.ps1 실행 (미개발)" -ForegroundColor Gray
    Write-Host "  3. View에서 최종 테스트" -ForegroundColor Gray
}

Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "✨ 변경 추적 완료!" -ForegroundColor Green
Write-Host "="*70 -ForegroundColor Cyan + "`n"

#endregion
