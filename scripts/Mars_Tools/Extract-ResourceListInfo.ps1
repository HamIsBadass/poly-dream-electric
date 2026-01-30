# Extract-ResourceListInfo.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceListInfoPath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputManifestPath
)

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     Extract Resource List Info to Manifest               " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ResourceListInfoPath)) {
    Write-Host "ERROR: ResourceListInfo file not found: $ResourceListInfoPath" -ForegroundColor Red
    exit 1
}

Write-Host "Reading JSON data..." -ForegroundColor Cyan
$jsonContent = Get-Content $ResourceListInfoPath -Raw -Encoding UTF8
$resourceData = $jsonContent | ConvertFrom-Json

$resources = @()
$resourceData.PSObject.Properties | ForEach-Object {
    $res = $_.Value
    $filename = [System.IO.Path]::GetFileName($res.ResourceName)
    $extension = [System.IO.Path]::GetExtension($filename).ToLower()
    
    # Determine category
    $category = switch -Regex ($extension) {
        '\.(png|jpg|jpeg|bmp|tga|tiff)$' { "images" }
        '\.(mp3|wav|ogg|m4a|flac)$' { "audio" }
        '\.(fbx|glb|gltf|obj|dae)$' { "models" }
        '\.(mp4|mov|avi|webm|mkv)$' { "videos" }
        default { "other" }
    }
    
    $resources += [PSCustomObject]@{
        ResourceId = $_.Name
        Filename = $filename
        Category = $category
        Type = $res.ResourceType
        OriginalPath = $res.ResourcePath
    }
    
    Write-Host "  [$category] $filename" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Yellow
Write-Host "Total resources: $($resources.Count)" -ForegroundColor White
Write-Host "  Images: $(($resources | Where-Object { $_.Category -eq 'images' }).Count)" -ForegroundColor Green
Write-Host "  Audio: $(($resources | Where-Object { $_.Category -eq 'audio' }).Count)" -ForegroundColor Green
Write-Host "  Models: $(($resources | Where-Object { $_.Category -eq 'models' }).Count)" -ForegroundColor Green
Write-Host "  Videos: $(($resources | Where-Object { $_.Category -eq 'videos' }).Count)" -ForegroundColor Green
Write-Host "  Other: $(($resources | Where-Object { $_.Category -eq 'other' }).Count)" -ForegroundColor Yellow
Write-Host ""

$outputDir = Split-Path $OutputManifestPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "Saving manifest to: $OutputManifestPath" -ForegroundColor Cyan
$resources | ConvertTo-Json -Depth 10 | Set-Content $OutputManifestPath -Encoding UTF8

Write-Host ""
Write-Host "Done! Manifest saved with $($resources.Count) resources" -ForegroundColor Green
