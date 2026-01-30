<#
.SYNOPSIS
Mars 파일의 ResourceListInfo에서 썸네일을 추출하고 인벤토리 생성

.DESCRIPTION
하이브리드 전략 단계 1: 빠른 시각적 확인
- ResourceListInfo JSON에서 Base64 인코딩된 썸네일 추출
- 각 리소스 타입별 폴더(images, models, videos, audio)에 PNG로 저장
- RESOURCE_INVENTORY.json 생성 (메타데이터 + 통계)
- 변경 추적을 위한 초기 해시값 저장

.PARAMETER SourceFile
ResourceListInfo를 포함하는 JSON 파일 경로
기본값: analysis_temp/intro/resource_manifest.json

.PARAMETER OutputDir
추출된 썸네일과 인벤토리를 저장할 기본 경로
기본값: resource/intro

.PARAMETER CreateHashFiles
원본 해시값 저장 여부 (변경 추적용)
기본값: $true

.EXAMPLE
.\Extract-Thumbnails.ps1 -SourceFile "analysis_temp/intro/resource_manifest.json" -OutputDir "resource/intro"

.EXAMPLE
# 배치 실행
.\Extract-Thumbnails.ps1 -SourceFile "analysis_temp/overview/resource_manifest.json" -OutputDir "resource/overview"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SourceFile = "analysis_temp/intro/resource_manifest.json",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "resource/intro",
    
    [Parameter(Mandatory=$false)]
    [bool]$CreateHashFiles = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

#region Helper Functions
function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Status = 'Info'
    )
    
    $colors = @{
        'Info'    = 'Cyan'
        'Success' = 'Green'
        'Warning' = 'Yellow'
        'Error'   = 'Red'
    }
    
    $icons = @{
        'Info'    = '📂'
        'Success' = '✅'
        'Warning' = '⚠️ '
        'Error'   = '❌'
    }
    
    Write-Host "$($icons[$Status]) $Message" -ForegroundColor $colors[$Status]
}

function Convert-Base64ToImage {
    param(
        [string]$Base64String,
        [string]$OutputPath
    )
    
    if ([string]::IsNullOrWhiteSpace($Base64String)) {
        return $false
    }
    
    try {
        $bytes = [Convert]::FromBase64String($Base64String)
        [IO.File]::WriteAllBytes($OutputPath, $bytes)
        
        if ($Verbose) {
            Write-Host "  → 저장: $(Split-Path $OutputPath -Leaf) ($(($bytes.Length / 1024).ToString('F1'))KB)" -ForegroundColor DarkGray
        }
        
        return $true
    }
    catch {
        Write-Status "Base64 디코딩 실패: $_" 'Error'
        return $false
    }
}

function Get-FileHash256 {
    param([string]$Data)
    
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
        $sha256 = [System.Security.Cryptography.SHA256]::Create()
        $hashBytes = $sha256.ComputeHash($bytes)
        return [System.BitConverter]::ToString($hashBytes).Replace('-', '')
    }
    catch {
        return $null
    }
}

function New-ResourceInventory {
    param(
        [array]$Resources,
        [string]$SourceMars,
        [hashtable]$Statistics
    )
    
    return @{
        metadata = @{
            source_mars = $SourceMars
            extraction_date = (Get-Date -AsUTC).ToString("o")
            extraction_version = "1.0"
            total_resources = $Resources.Count
            strategy = "hybrid"
            description = "하이브리드 전략 단계 1: 썸네일 + 메타데이터"
        }
        resources = @($Resources)
        statistics = $Statistics
    }
}
#endregion

#region Main Logic
Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "🎯 Mars 리소스 추출: 하이브리드 전략 단계 1 (Thumbnail-Only)" -ForegroundColor Cyan
Write-Host "="*70 -ForegroundColor Cyan

# 1. 입력 파일 검증
if (-not (Test-Path $SourceFile)) {
    Write-Status "소스 파일을 찾을 수 없음: $SourceFile" 'Error'
    exit 1
}

Write-Status "소스 파일 로드: $SourceFile" 'Info'
try {
    $manifest = Get-Content $SourceFile -Encoding UTF8 | ConvertFrom-Json
    Write-Status "로드 완료: $($manifest.resources.Count)개 리소스" 'Success'
}
catch {
    Write-Status "JSON 파싱 오류: $_" 'Error'
    exit 1
}

# 2. 출력 폴더 생성
Write-Host "`n📁 폴더 구조 생성 중..." -ForegroundColor Cyan

$folderStructure = @{
    'Image' = "$OutputDir/images"
    'Model' = "$OutputDir/models"
    'Video' = "$OutputDir/videos"
    'Audio' = "$OutputDir/audio"
}

foreach ($type in $folderStructure.Keys) {
    $folder = $folderStructure[$type]
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
        Write-Status "생성: $folder" 'Success'
    }
    else {
        Write-Host "  ℹ️  이미 존재: $folder" -ForegroundColor Gray
    }
}

# 3. 썸네일 추출
Write-Host "`n🖼️  썸네일 추출 중..." -ForegroundColor Cyan

$extractedCount = @{}
$failedCount = @{}
$inventoryResources = @()
$filePathMap = @{}

foreach ($type in $folderStructure.Keys) {
    $extractedCount[$type] = 0
    $failedCount[$type] = 0
}

$totalResources = $manifest.resources.Count
$currentIndex = 0

foreach ($resource in $manifest.resources) {
    $currentIndex++
    $progress = [math]::Round(($currentIndex / $totalResources) * 100)
    Write-Progress -Activity "썸네일 추출" -Status "$currentIndex/$totalResources" -PercentComplete $progress
    
    $type = $resource.type
    $name = $resource.name
    $thumbnail = $resource.thumbnail
    $resourcePath = $resource.resource_path
    
    # 파일 포맷 결정
    $format = switch ($type) {
        'Image' { 'png' }
        'Model' { 'fbx' }
        'Video' { 'mp4' }
        'Audio' { 'mp3' }
        default { 'unknown' }
    }
    
    # 썸네일 저장
    $targetFolder = $folderStructure[$type]
    $thumbnailFileName = "THUMB_$name.png"
    $thumbnailPath = Join-Path $targetFolder $thumbnailFileName
    
    $success = Convert-Base64ToImage -Base64String $thumbnail -OutputPath $thumbnailPath
    
    if ($success) {
        $extractedCount[$type]++
        
        # 썸네일 해시 생성 (변경 추적용)
        if ($CreateHashFiles) {
            $fileHash = Get-FileHash256 -Data $resource.thumbnail
            $hashFile = "$thumbnailPath.sha256"
            $fileHash | Set-Content $hashFile -Encoding UTF8 -ErrorAction SilentlyContinue
        }
        
        # 인벤토리 항목 추가
        $inventoryItem = @{
            id = "RES_$('{0:D5}' -f ($inventoryResources.Count + 1))"
            name = $name
            type = $type
            format = $format
            original_size = @{
                width = if ($resource.width) { [int]$resource.width } else { 0 }
                height = if ($resource.height) { [int]$resource.height } else { 0 }
            }
            file_size = if ($resource.file_size) { [int]$resource.file_size } else { 0 }
            thumbnail_path = "resource/$((Split-Path $OutputDir -Leaf))/images/$thumbnailFileName"
            resource_path = $null  # 아직 추출되지 않음
            extracted = $false
            original_resource_path = $resourcePath
            status = "available"
            hash = Get-FileHash256 -Data $thumbnail
        }
        
        $inventoryResources += $inventoryItem
        $filePathMap[$name] = $resourcePath
    }
    else {
        $failedCount[$type]++
    }
}

Write-Progress -Activity "썸네일 추출" -Completed

# 4. RESOURCE_INVENTORY.json 생성
Write-Host "`n📋 인벤토리 생성 중..." -ForegroundColor Cyan

$statistics = @{
    images = @{
        total = ($manifest.resources | Where-Object { $_.type -eq 'Image' }).Count
        extracted = $extractedCount['Image']
        failed = $failedCount['Image']
    }
    models = @{
        total = ($manifest.resources | Where-Object { $_.type -eq 'Model' }).Count
        extracted = $extractedCount['Model']
        failed = $failedCount['Model']
    }
    videos = @{
        total = ($manifest.resources | Where-Object { $_.type -eq 'Video' }).Count
        extracted = $extractedCount['Video']
        failed = $failedCount['Video']
    }
    audio = @{
        total = ($manifest.resources | Where-Object { $_.type -eq 'Audio' }).Count
        extracted = $extractedCount['Audio']
        failed = $failedCount['Audio']
    }
    total = @{
        total = $manifest.resources.Count
        extracted = $extractedCount.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        failed = $failedCount.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum
    }
}

$inventory = New-ResourceInventory -Resources $inventoryResources -SourceMars "00_Intro.mars" -Statistics $statistics

$inventoryPath = "$OutputDir/RESOURCE_INVENTORY.json"
$inventory | ConvertTo-Json -Depth 10 -Encoding UTF8 | Set-Content $inventoryPath -Encoding UTF8

Write-Status "인벤토리 저장: $inventoryPath" 'Success'

# 5. 변경 추적 초기화
if ($CreateHashFiles) {
    Write-Host "`n🔍 변경 추적 파일 생성 중..." -ForegroundColor Cyan
    
    $changesTemplate = @{
        tracking_metadata = @{
            created = (Get-Date -AsUTC).ToString("o")
            last_scan = (Get-Date -AsUTC).ToString("o")
            base_path = $OutputDir
            strategy = "hybrid"
        }
        changes = @()
    }
    
    $changesPath = "analysis_temp/$(Split-Path $OutputDir -Leaf)/resource_changes.json"
    $changesDir = Split-Path $changesPath
    if (-not (Test-Path $changesDir)) {
        New-Item -ItemType Directory -Path $changesDir -Force | Out-Null
    }
    
    $changesTemplate | ConvertTo-Json -Depth 10 | Set-Content $changesPath -Encoding UTF8
    Write-Status "변경 추적 파일: $changesPath" 'Success'
}

# 6. 선택 목록 템플릿 생성
$selectionTemplate = @"
# Extract-SelectedResources.ps1에서 사용할 리소스 선택 목록
# 형식: ID|이름|우선순위
# 우선순위: 1=높음, 2=중간, 3=낮음
# 필요한 리소스의 줄 앞 주석(#)을 제거하면 선택됨

# --- 이미지 (고해상도 필요) ---
# RES_00001|name|1

# --- 3D 모델 (편집 필요) ---
# RES_00150|name|1

# --- 오디오/비디오 ---
# RES_00180|name|2

# 추가 선택이 필요하면 위 형식에 맞춰 줄을 추가하세요
"@

$selectionPath = "analysis_temp/$(Split-Path $OutputDir -Leaf)/resource_selection.txt"
$selectionTemplate | Set-Content $selectionPath -Encoding UTF8
Write-Status "선택 목록 템플릿: $selectionPath" 'Success'

# 7. 결과 요약
Write-Host "`n" + ("="*70) -ForegroundColor Yellow
Write-Host "📊 추출 결과 요약" -ForegroundColor Yellow
Write-Host "="*70 -ForegroundColor Yellow

$summaryTable = @(
    @{ 유형 = 'Images'; 성공 = $statistics.images.extracted; 실패 = $statistics.images.failed; 합계 = $statistics.images.total }
    @{ 유형 = 'Models'; 성공 = $statistics.models.extracted; 실패 = $statistics.models.failed; 합계 = $statistics.models.total }
    @{ 유형 = 'Videos'; 성공 = $statistics.videos.extracted; 실패 = $statistics.videos.failed; 합계 = $statistics.videos.total }
    @{ 유형 = 'Audio'; 성공 = $statistics.audio.extracted; 실패 = $statistics.audio.failed; 합계 = $statistics.audio.total }
    @{ 유형 = '전체'; 성공 = $statistics.total.extracted; 실패 = $statistics.total.failed; 합계 = $statistics.total.total }
)

$summaryTable | Format-Table -AutoSize | Write-Host

# 8. 다음 단계 안내
Write-Host "`n📌 다음 단계:" -ForegroundColor Cyan
Write-Host "  1. RESOURCE_INVENTORY.json을 VS Code에서 검토" -ForegroundColor Gray
Write-Host "  2. 필요한 리소스를 resource_selection.txt에 추가" -ForegroundColor Gray
Write-Host "  3. Extract-SelectedResources.ps1 실행 (개발 필요)" -ForegroundColor Gray
Write-Host "  4. MarsCatalogue에서 참조 추가" -ForegroundColor Gray

Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "✨ 썸네일 추출 완료!" -ForegroundColor Green
Write-Host "="*70 -ForegroundColor Cyan + "`n"

#endregion
