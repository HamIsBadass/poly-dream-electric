# Parse-MarsFile.ps1 - Fixed version
param(
    [Parameter(Mandatory=$true)]
    [string]$MarsFilePath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath
)

Write-Host "Mars File Binary Parser v1.0" -ForegroundColor Cyan
Write-Host "Input: $MarsFilePath" -ForegroundColor Gray
Write-Host "Output: $OutputPath" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

$fileStream = [System.IO.File]::OpenRead($MarsFilePath)
$gzipStream = New-Object System.IO.Compression.GZipStream($fileStream, [System.IO.Compression.CompressionMode]::Decompress)
$reader = New-Object System.IO.BinaryReader($gzipStream)

$sectionIndex = 0
$sections = @()

try {
    while ($true) {
        Write-Host "Reading section $sectionIndex..." -ForegroundColor Yellow
        
        # Read name length
        $nameLength = $reader.ReadInt32()
        Write-Host "  Name length: $nameLength chars" -ForegroundColor Gray
        
        # Read name (UTF-16LE)
        $nameBytes = $reader.ReadBytes($nameLength * 2)
        $sectionName = [System.Text.Encoding]::Unicode.GetString($nameBytes)
        Write-Host "  Section name: $sectionName" -ForegroundColor Green
        
        # Read data length
        $dataLength = $reader.ReadInt32()
        Write-Host "  Data size: $dataLength bytes ($([Math]::Round($dataLength/1024,2)) KB)" -ForegroundColor Green
        
        # Read data
        $data = $reader.ReadBytes($dataLength)
        Write-Host "  Data read: $($data.Length) bytes" -ForegroundColor Gray
        
        # Save section
        switch -Regex ($sectionName) {
            "VersionInfo" {
                $jsonText = [System.Text.Encoding]::UTF8.GetString($data)
                $outPath = Join-Path $OutputPath "version_info.json"
                try {
                    $json = $jsonText | ConvertFrom-Json
                    $json | ConvertTo-Json -Depth 10 | Out-File -FilePath $outPath -Encoding UTF8
                    Write-Host "  Saved: version_info.json (formatted)" -ForegroundColor Magenta
                } catch {
                    $jsonText | Out-File -FilePath $outPath -Encoding UTF8
                    Write-Host "  Saved: version_info.json (raw)" -ForegroundColor Magenta
                }
            }
            
            default {
                # Save as binary
                $binPath = Join-Path $OutputPath "section_$sectionIndex`_$sectionName.bin"
                [System.IO.File]::WriteAllBytes($binPath, $data)
                Write-Host "  Saved: section_$sectionIndex`_$sectionName.bin" -ForegroundColor Magenta
                
                # Try to decode as text
                $text = [System.Text.Encoding]::UTF8.GetString($data)
                if ($text -match "format_version|nodes|roots|object_type") {
                    $txtPath = Join-Path $OutputPath "section_$sectionIndex`_$sectionName.txt"
                    $text | Out-File -FilePath $txtPath -Encoding UTF8
                    Write-Host "  Also saved as: section_$sectionIndex`_$sectionName.txt" -ForegroundColor Cyan
                }
            }
        }
        
        $sections += @{
            Index = $sectionIndex
            Name = $sectionName
            Size = $dataLength
        }
        
        $sectionIndex++
        Write-Host ""
    }
}
catch {
    Write-Host "End of file reached. Total sections: $sectionIndex" -ForegroundColor Green
}
finally {
    $reader.Close()
    $gzipStream.Close()
    $fileStream.Close()
}

Write-Host ""
Write-Host "=== Section Summary ===" -ForegroundColor Cyan
foreach ($section in $sections) {
    $sizeKB = [Math]::Round($section.Size / 1024, 2)
    Write-Host "$($section.Index): $($section.Name) - $sizeKB KB" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "All sections saved to: $OutputPath" -ForegroundColor Green
