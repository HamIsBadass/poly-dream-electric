# ============================================
# PowerShell Profile - poly-dream-electric
# CLEAN VERSION (2026-01-29) - UTF-8 Encoding
# ============================================

# Project Path Definition
$projectPath = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"

# ============================================
# Function Definitions
# ============================================

# 1. Navigate to project folder
function cdpoly {
    Set-Location -LiteralPath $projectPath
    Write-Host "Moving to project folder: $projectPath" -ForegroundColor Green
}

# 2. Open path handling guide
function pathguide {
    $guideFile = "$projectPath\PowerShell_경로처리_가이드.md"
    if (Test-Path -LiteralPath $guideFile) {
        Write-Host "Opening path handling guide..." -ForegroundColor Cyan
        code $guideFile
    } else {
        Write-Host "Guide file not found: $guideFile" -ForegroundColor Red
    }
}

# 3. Open content structure guide
function contentguide {
    $guideFile = "$projectPath\Intro_Content_Structure.md"
    if (Test-Path -LiteralPath $guideFile) {
        Write-Host "Opening content structure guide..." -ForegroundColor Cyan
        code $guideFile
    } else {
        Write-Host "Guide file not found: $guideFile" -ForegroundColor Red
    }
}

# 4. Open MarsMaker AI guide
function agentsguide {
    $guideFile = "$projectPath\AGENTS.md"
    if (Test-Path -LiteralPath $guideFile) {
        Write-Host "Opening MarsMaker AI guide..." -ForegroundColor Cyan
        code $guideFile
    } else {
        Write-Host "Guide file not found: $guideFile" -ForegroundColor Red
    }
}

# 5. Show project status
function Show-ProjectStatus {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  Project Status (poly-dream-electric)" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    if (Test-Path -LiteralPath $projectPath) {
        Write-Host "Project folder: $projectPath" -ForegroundColor Green
        
        # Check Contents folder
        $contentsPath = "$projectPath\Contents"
        if (Test-Path -LiteralPath $contentsPath) {
            Write-Host "Contents folder exists" -ForegroundColor Green
            Get-ChildItem -LiteralPath $contentsPath -Recurse -Filter "*.mars" | ForEach-Object {
                $sizeMB = [Math]::Round($_.Length/1MB, 2)
                $relPath = $_.FullName -replace [regex]::Escape($contentsPath), ""
                Write-Host "  - $relPath ($sizeMB MB)" -ForegroundColor Yellow
            }
        }
        
        # Check guide documents
        $guides = @("PowerShell_Path_Guide.md", "Intro_Content_Structure.md", "AGENTS.md")
        Write-Host "`nGuide documents:" -ForegroundColor Cyan
        $guides | ForEach-Object {
            if (Test-Path -LiteralPath "$projectPath\$_") {
                Write-Host "  - $_" -ForegroundColor Green
            } else {
                Write-Host "  - $_ (missing)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Project folder not found!" -ForegroundColor Red
    }
    
    Write-Host ""
}

# ============================================
# Startup Message
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  poly-dream-electric Project" -ForegroundColor Cyan
Write-Host "  PowerShell Environment Loaded!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available Commands:" -ForegroundColor Yellow
Write-Host "  - cdpoly          : Navigate to project folder" -ForegroundColor Green
Write-Host "  - pathguide       : Open path handling guide" -ForegroundColor Green
Write-Host "  - agentsguide     : Open MarsMaker AI guide" -ForegroundColor Green
Write-Host "  - contentguide    : Open content structure guide" -ForegroundColor Green
Write-Host "  - Show-ProjectStatus : Show project status" -ForegroundColor Green
Write-Host ""
Write-Host "Tip: Use 'pathguide' to learn about special character handling" -ForegroundColor Yellow
Write-Host ""
