# Analyze-ResourceListInfo.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$BinaryFilePath
)

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     ResourceListInfo Binary Structure Analyzer               " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $BinaryFilePath)) {
    Write-Host "ERROR: File not found: $BinaryFilePath" -ForegroundColor Red
    exit 1
}

$fileInfo = Get-Item $BinaryFilePath
Write-Host "File: $($fileInfo.Name)" -ForegroundColor White
Write-Host "Size: $($fileInfo.Length) bytes" -ForegroundColor White
Write-Host ""

$bytesToRead = [Math]::Min(200, $fileInfo.Length)
$bytes = [System.IO.File]::ReadAllBytes($BinaryFilePath)
$firstBytes = $bytes[0..($bytesToRead-1)]

Write-Host "=== HEX DUMP (first 200 bytes) ===" -ForegroundColor Yellow
Write-Host ""

for ($i = 0; $i -lt $firstBytes.Length; $i += 16) {
    $offset = "{0:X4}" -f $i
    Write-Host -NoNewline "$offset  " -ForegroundColor Gray
    
    $hex = ""
    $ascii = ""
    for ($j = 0; $j -lt 16; $j++) {
        if (($i + $j) -lt $firstBytes.Length) {
            $byte = $firstBytes[$i + $j]
            $hex += "{0:X2} " -f $byte
            if ($byte -ge 32 -and $byte -le 126) {
                $ascii += [char]$byte
            } else {
                $ascii += "."
            }
        } else {
            $hex += "   "
            $ascii += " "
        }
        if ($j -eq 7) { $hex += " " }
    }
    Write-Host -NoNewline $hex -ForegroundColor Cyan
    Write-Host "  $ascii" -ForegroundColor White
}

Write-Host ""
Write-Host "=== Structure Analysis ===" -ForegroundColor Yellow
Write-Host ""

if ($bytes.Length -ge 4) {
    $resourceCount = [System.BitConverter]::ToInt32($bytes, 0)
    Write-Host "Estimated resource count: $resourceCount" -ForegroundColor Green
    if ($resourceCount -ge 0 -and $resourceCount -le 1000) {
        Write-Host "  OK: Valid range (0-1000)" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Out of range" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Searching for UTF-16LE strings..." -ForegroundColor Cyan

$foundStrings = @()
$offset = 4

while ($offset -lt ($bytes.Length - 4)) {
    if ($offset + 4 -gt $bytes.Length) { break }
    try {
        $strLength = [System.BitConverter]::ToInt32($bytes, $offset)
        if ($strLength -gt 0 -and $strLength -lt 200) {
            $byteLength = $strLength * 2
            if ($offset + 4 + $byteLength -le $bytes.Length) {
                $stringBytes = $bytes[($offset + 4)..($offset + 3 + $byteLength)]
                $decodedString = [System.Text.Encoding]::Unicode.GetString($stringBytes)
                if ($decodedString -match '\.(png|jpg|jpeg|mp3|wav|ogg|fbx|glb|gltf|mp4|mov|avi)$') {
                    $foundStrings += [PSCustomObject]@{
                        Offset = "0x{0:X4}" -f $offset
                        Length = $strLength
                        String = $decodedString
                    }
                    Write-Host "  Found: $decodedString (offset: 0x{0:X4})" -f $offset -ForegroundColor Green
                    $offset += 4 + $byteLength
                    continue
                }
            }
        }
    } catch {}
    $offset++
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Found filenames: $($foundStrings.Count)" -ForegroundColor Green

if ($foundStrings.Count -gt 0) {
    Write-Host ""
    Write-Host "Sample (first 5):" -ForegroundColor Cyan
    $foundStrings | Select-Object -First 5 | Format-Table -AutoSize
}

Write-Host ""
Write-Host "Done! Next step: Extract-ResourceListInfo.ps1" -ForegroundColor Green
