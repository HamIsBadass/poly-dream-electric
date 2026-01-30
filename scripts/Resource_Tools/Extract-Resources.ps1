# Extract-Resources.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$ManifestPath,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourcesBinPath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath
)

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     Extract Resources from Mars File               " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ManifestPath)) {
    Write-Host "ERROR: Manifest not found: $ManifestPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ResourcesBinPath)) {
    Write-Host "ERROR: Resources.bin not found: $ResourcesBinPath" -ForegroundColor Red
    exit 1
}

Write-Host "Loading manifest..." -ForegroundColor Cyan
$manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Host "Decompressing Resources section..." -ForegroundColor Cyan
$fileStream = [System.IO.File]::OpenRead($ResourcesBinPath)
$gzipStream = New-Object System.IO.Compression.GZipStream($fileStream, [System.IO.Compression.CompressionMode]::Decompress)
$memoryStream = New-Object System.IO.MemoryStream
$gzipStream.CopyTo($memoryStream)
$gzipStream.Close()
$fileStream.Close()

$decompressedBytes = $memoryStream.ToArray()
$memoryStream.Close()

Write-Host "Decompressed size: $($decompressedBytes.Length) bytes" -ForegroundColor Green
Write-Host ""

$resourcesData = [System.Text.Encoding]::UTF8.GetString($decompressedBytes) | ConvertFrom-Json

$stats = @{
    Total = 0
    Success = 0
    Failed = 0
    ByCategory = @{}
}

$manifest | ForEach-Object {
    $resourceId = $_.ResourceId
    $filename = $_.Filename
    $category = $_.Category
    
    $stats.Total++
    
    if (-not $stats.ByCategory.ContainsKey($category)) {
        $stats.ByCategory[$category] = 0
    }
    
    Write-Progress -Activity "Extracting resources" -Status "$filename" -PercentComplete (($stats.Success + $stats.Failed) / $stats.Total * 100)
    
    try {
        $resourceData = $resourcesData.$resourceId
        
        if ($null -eq $resourceData) {
            Write-Host "  [SKIP] $filename - Not found in Resources" -ForegroundColor Yellow
            $stats.Failed++
            return
        }
        
        $base64Data = $resourceData.Data
        if ([string]::IsNullOrEmpty($base64Data)) {
            Write-Host "  [SKIP] $filename - No data" -ForegroundColor Yellow
            $stats.Failed++
            return
        }
        
        $bytes = [System.Convert]::FromBase64String($base64Data)
        
        $categoryPath = Join-Path $OutputPath "resource\$category"
        if (-not (Test-Path $categoryPath)) {
            New-Item -ItemType Directory -Path $categoryPath -Force | Out-Null
        }
        
        $outputFile = Join-Path $categoryPath $filename
        [System.IO.File]::WriteAllBytes($outputFile, $bytes)
        
        $sizeMB = [Math]::Round($bytes.Length / 1MB, 2)
        Write-Host "  [OK] $filename ($sizeMB MB)" -ForegroundColor Green
        
        $stats.Success++
        $stats.ByCategory[$category]++
        
    } catch {
        Write-Host "  [FAIL] $filename - $($_.Exception.Message)" -ForegroundColor Red
        $stats.Failed++
    }
}

Write-Progress -Activity "Extracting resources" -Completed

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
Write-Host ""
Write-Host "Done! Resources extracted to: $OutputPath\resource\" -ForegroundColor Green
