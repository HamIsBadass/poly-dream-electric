# Extract-Thumbnails.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceListInfoPath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath
)

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     Extract Resource Thumbnails from Mars File               " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ResourceListInfoPath)) {
    Write-Host "ERROR: ResourceListInfo not found: $ResourceListInfoPath" -ForegroundColor Red
    exit 1
}

Write-Host "Loading ResourceListInfo..." -ForegroundColor Cyan
$json = Get-Content $ResourceListInfoPath -Raw -Encoding UTF8 | ConvertFrom-Json

$stats = @{
    Total = 0
    Success = 0
    Failed = 0
    ByCategory = @{}
}

$thumbnails = @()

$json.PSObject.Properties | ForEach-Object {
    $resourceId = $_.Name
    $resource = $_.Value
    
    $filename = [System.IO.Path]::GetFileName($resource.ResourceName)
    $ext = [System.IO.Path]::GetExtension($filename).ToLower()
    
    $category = switch -Regex ($ext) {
        '\.(png|jpg|jpeg|bmp|tga)$' { "images" }
        '\.(mp3|wav|ogg|m4a|flac)$' { "audio" }
        '\.(fbx|glb|gltf|obj|dae)$' { "models" }
        '\.(mp4|mov|avi|webm|mkv)$' { "videos" }
        default { "other" }
    }
    
    $stats.Total++
    
    if (-not $stats.ByCategory.ContainsKey($category)) {
        $stats.ByCategory[$category] = 0
    }
    
    try {
        if ([string]::IsNullOrEmpty($resource.ResourceThumbnail)) {
            Write-Host "  [SKIP] $filename - No thumbnail" -ForegroundColor Yellow
            $stats.Failed++
            return
        }
        
        $categoryPath = Join-Path $OutputPath "resource\$category"
        if (-not (Test-Path $categoryPath)) {
            New-Item -ItemType Directory -Path $categoryPath -Force | Out-Null
        }
        
        $thumbnailBytes = [System.Convert]::FromBase64String($resource.ResourceThumbnail)
        $thumbnailFile = Join-Path $categoryPath "$filename.thumb.png"
        [System.IO.File]::WriteAllBytes($thumbnailFile, $thumbnailBytes)
        
        $sizeMB = [Math]::Round($thumbnailBytes.Length / 1KB, 2)
        Write-Host "  [OK] $filename ($sizeMB KB)" -ForegroundColor Green
        
        $thumbnails += [PSCustomObject]@{
            ResourceId = $resourceId
            Filename = $filename
            Category = $category
            Type = $resource.ResourceType
            Size = $resource.ResourceSize
            ThumbnailSize = $thumbnailBytes.Length
            Path = $resource.ResourcePath
            Modified = $false
        }
        
        $stats.Success++
        $stats.ByCategory[$category]++
        
    } catch {
        Write-Host "  [FAIL] $filename - $($_.Exception.Message)" -ForegroundColor Red
        $stats.Failed++
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host "=== Extraction Summary ===" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host "Total: $($stats.Total)" -ForegroundColor White
Write-Host "Success: $($stats.Success)" -ForegroundColor Green
Write-Host "Failed: $($stats.Failed)" -ForegroundColor $(if ($stats.Failed -gt 0) { "Red" } else { "Green" })
Write-Host ""
Write-Host "By Category:" -ForegroundColor Cyan
$stats.ByCategory.GetEnumerator() | Sort-Object Key | ForEach-Object {
    Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor White
}

$inventoryPath = Join-Path $OutputPath "RESOURCE_INVENTORY.json"
Write-Host ""
Write-Host "Saving inventory to: $inventoryPath" -ForegroundColor Cyan
$thumbnails | ConvertTo-Json -Depth 10 | Out-File $inventoryPath -Encoding utf8

Write-Host ""
Write-Host "Done! $($stats.Success) thumbnails extracted" -ForegroundColor Green
Write-Host "Location: $OutputPath\resource\" -ForegroundColor Green
