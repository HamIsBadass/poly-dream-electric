# ============================================
# PowerShell Profile - poly-dream-electric
# FIXED VERSION (2026-01-29)
# ============================================

# 프로젝트 경로 정의
$projectBase = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발"
$polyDreamPath = "$projectBase\poly-dream-electric"

# ============================================
# 함수 정의 (Function)
# ============================================

# 1. 프로젝트 폴더로 이동
function cdpoly {
    Set-Location -LiteralPath $polyDreamPath
    Write-Host "프로젝트 폴더로 이동: $polyDreamPath" -ForegroundColor Green
}

# 2. 경로 처리 가이드 열기
function pathguide {
    $guideFile = "$polyDreamPath\PowerShell_경로처리_가이드.md"
    if (Test-Path -LiteralPath $guideFile) {
        Write-Host "경로 처리 가이드를 VS Code에서 엽니다..." -ForegroundColor Cyan
        code $guideFile
    } else {
        Write-Host "파일을 찾을 수 없습니다: $guideFile" -ForegroundColor Red
    }
}

# 3. 콘텐츠 구조 가이드 열기
function contentguide {
    $guideFile = "$polyDreamPath\Intro_Content_Structure.md"
    if (Test-Path -LiteralPath $guideFile) {
        Write-Host "콘텐츠 구조 가이드를 VS Code에서 엽니다..." -ForegroundColor Cyan
        code $guideFile
    } else {
        Write-Host "파일을 찾을 수 없습니다: $guideFile" -ForegroundColor Red
    }
}

# 4. AGENTS 가이드 열기
function agentsguide {
    $guideFile = "$polyDreamPath\AGENTS.md"
    if (Test-Path -LiteralPath $guideFile) {
        Write-Host "MarsMaker AI 가이드를 VS Code에서 엽니다..." -ForegroundColor Cyan
        code $guideFile
    } else {
        Write-Host "파일을 찾을 수 없습니다: $guideFile" -ForegroundColor Red
    }
}

# 5. 프로젝트 상태 확인
function Show-ProjectStatus {
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   프로젝트 상태 (poly-dream-electric)  ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    if (Test-Path -LiteralPath $polyDreamPath) {
        Write-Host "✅ 프로젝트 폴더: $polyDreamPath" -ForegroundColor Green
        
        # Contents 폴더 확인
        $contentsPath = "$polyDreamPath\Contents"
        if (Test-Path -LiteralPath $contentsPath) {
            Write-Host "✅ Contents 폴더 존재" -ForegroundColor Green
            Get-ChildItem -LiteralPath $contentsPath -Recurse -Filter "*.mars" | ForEach-Object {
                $sizeMB = [Math]::Round($_.Length/1MB, 2)
                $relPath = $_.FullName -replace [regex]::Escape($contentsPath), ""
                Write-Host "   📦 $relPath ($sizeMB MB)" -ForegroundColor Yellow
            }
        }
        
        # 가이드 문서 확인
        $guides = @("PowerShell_Path_Guide.md", "Intro_Content_Structure.md", "AGENTS.md")
        Write-Host "`n📚 가이드 문서:" -ForegroundColor Cyan
        $guides | ForEach-Object {
            if (Test-Path -LiteralPath "$polyDreamPath\$_") {
                Write-Host "   ✅ $_" -ForegroundColor Green
            } else {
                Write-Host "   ❌ $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "❌ 프로젝트 폴더를 찾을 수 없습니다!" -ForegroundColor Red
    }
    
    Write-Host ""
}

# ============================================
# 시작 메시지
# ============================================

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  poly-dream-electric 프로젝트        ║" -ForegroundColor Cyan
Write-Host "║  PowerShell 환경 로드 완료! 🚀       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📌 사용 가능한 함수:" -ForegroundColor Yellow
Write-Host "  • cdpoly         - 프로젝트 폴더로 이동" -ForegroundColor Green
Write-Host "  • pathguide      - 경로 처리 가이드 열기 ⭐" -ForegroundColor Green
Write-Host "  • agentsguide    - MarsMaker AI 가이드 열기" -ForegroundColor Green
Write-Host "  • contentguide   - 콘텐츠 구조 가이드 열기" -ForegroundColor Green
Write-Host "  • Show-ProjectStatus - 프로젝트 상태 확인" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  경로에 특수문자가 있을 때는 반드시 변수에 저장 후 사용하세요!" -ForegroundColor Yellow
Write-Host "   참고: pathguide 명령으로 가이드를 확인하세요." -ForegroundColor Yellow
Write-Host ""
