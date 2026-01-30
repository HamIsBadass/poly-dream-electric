# 🔴 폴더명 변경으로 인한 연결 끊김 분석 보고서

**분석 일시**: 2026-01-29  
**상태**: 🔴 **9개 파일에서 문제 발견**

---

## 📋 문제 요약

폴더 이름이 영문으로 변경되었는데, 여러 파일들에서 **여전히 한글 파일명/경로**를 참조하고 있어 연결이 끊어진 상태입니다.

### 현재 상황
- ❌ **기존 한글 파일명**: `인트로.mars`, `수배전반개요.mars`
- ✅ **변경된 영문 파일명**: `00_Intro.mars`, `01_Overview.mars`
- ❌ **기존 한글 폴더명**: `resource/intro/`, `resource/overview/`
- ✅ **변경된 영문 폴더명**: `resource/asset_00_intro/`, `resource/asset_01_overview/`

---

## 🔧 **연결 끊김 파일 목록**

### 1️⃣ [Sync-Resources.ps1](Sync-Resources.ps1) - **HIGH PRIORITY**
**문제**: 한글 파일명 참조
```powershell
# ❌ 잘못된 참조 (4번 줄)
$gz = [System.IO.Compression.GZipStream]::new([System.IO.File]::OpenRead("Contents/인트로.mars"), ...)

# ❌ 한글 폴더 참조 (13번 줄)
Get-ChildItem "resource\intro\$_" -File -ErrorAction SilentlyContinue | ...
```

**필요한 변경**:
- `Contents/인트로.mars` → `Contents/00_Intro.mars`
- `resource\intro\` → `resource\asset_00_intro\`

---

### 2️⃣ [Prepare-Preview.ps1](Prepare-Preview.ps1) - **HIGH PRIORITY**
**문제**: 한글 파일명 참조
```powershell
# ❌ 9번 줄
$gz = [System.IO.Compression.GZipStream]::new([System.IO.File]::OpenRead("Contents/인트로.mars"), ...)
```

**필요한 변경**:
- `Contents/인트로.mars` → `Contents/00_Intro.mars`

---

### 3️⃣ [root.code-workspace](root.code-workspace) - **MEDIUM PRIORITY**
**문제**: VS Code 터미널 자동완성에서 한글 경로 참조 (3곳)

```jsonc
// ❌ 19번 줄
"/^Get-Location; Expand-Archive -Path \"\\.\\\\Contents\\\\인트로\\.mars\" ..."

// ❌ 23번 줄
"...Expand-Archive -LiteralPath \"\\.\\\\Contents\\\\인트로\\.mars\"..."

// ❌ 27번 줄
"...\"Contents\\\\인트로\\.mars\"\\)..."
```

**필요한 변경**:
- `인트로.mars` → `00_Intro.mars`

---

### 4️⃣ [PROFILE_CLEAN.ps1](PROFILE_CLEAN.ps1) - **LOW PRIORITY**
**문제**: 폐기된 한글 문서 참조

```powershell
# ❌ 32번 줄
$guideFile = "$projectPath\인트로_콘텐츠_구조.md"

# ❌ 72번 줄
$guides = @("PowerShell_경로처리_가이드.md", "인트로_콘텐츠_구조.md", "AGENTS.md")
```

**상태**: 이 파일들이 실제로 없으므로 에러가 발생할 수 있습니다.  
**필요한 변경**: 문서가 없다면 참조 제거 또는 올바른 문서명으로 변경

---

### 5️⃣ [PowerShell_Profile_Fixed.ps1](PowerShell_Profile_Fixed.ps1) - **LOW PRIORITY**
**문제**: PROFILE_CLEAN.ps1과 동일한 문제

```powershell
# ❌ 33번 줄
$guideFile = "$polyDreamPath\인트로_콘텐츠_구조.md"

# ❌ 73번 줄
$guides = @("PowerShell_경로처리_가이드.md", "인트로_콘텐츠_구조.md", "AGENTS.md")
```

---

### 6️⃣ [open-guides.bat](open-guides.bat) - **LOW PRIORITY**
**문제**: 한글 파일명 참조

```batch
# ❌ 37번 줄
code "!projectRoot!인트로_콘텐츠_구조.md"

# ❌ 51번 줄 (2회)
if exist "!projectRoot!인트로_콘텐츠_구조.md" echo [OK] 인트로_콘텐츠_구조.md
```

---

### 7️⃣ [Scripts/Extract-Thumbnails.ps1](Scripts/Extract-Thumbnails.ps1) - **MEDIUM PRIORITY**
**문제**: 한글 파일명 참조

```powershell
# ❌ 288번 줄
$inventory = New-ResourceInventory -Resources $inventoryResources -SourceMars "인트로.mars" ...
```

**필요한 변경**:
- `"인트로.mars"` → `"00_Intro.mars"`

---

### 8️⃣ [setup_overview.py](setup_overview.py) - **INFO**
**문제**: 외부 경로 참조 (폴더명 변경 불가)

```python
# ℹ️ 11번 줄 - 외부 경로이므로 실제 폴더명을 확인 필요
img_src = r"C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\2D\01_수배전개요"

# ℹ️ 11번 줄 - 프로젝트 내부
base_dest = r"resource\overview"  # → resource\asset_01_overview로 변경 필요
```

---

### 9️⃣ [setup_overview.bat](setup_overview.bat) - **INFO**
**문제**: 한글 외부 경로 + 프로젝트 내부 경로 모두 문제

```batch
# ❌ 5, 6번 줄 - 외부 경로
for %%F in ("..\..\05_디자인\2D\01_수배전개요\*.*") do (

# ❌ 6, 12번 줄 - 프로젝트 내부 경로
copy "%%F" "resource\overview\images\" /Y >nul
copy "%%F" "resource\overview\models\" /Y >nul
```

**필요한 변경**:
- `resource\overview\` → `resource\asset_01_overview\`

---

## 📊 우선순위별 정리

### 🔴 HIGH PRIORITY (즉시 수정 필요)
1. **Sync-Resources.ps1** - 실행 불가능
2. **Prepare-Preview.ps1** - 실행 불가능

### 🟡 MEDIUM PRIORITY (곧 수정)
3. **root.code-workspace** - VS Code 자동완성 오류
4. **Scripts/Extract-Thumbnails.ps1** - 스크립트 실행 오류

### 🟢 LOW PRIORITY (나중에 수정)
5. **PROFILE_CLEAN.ps1** - PowerShell 프로필 로드 오류
6. **PowerShell_Profile_Fixed.ps1** - PowerShell 프로필 로드 오류
7. **open-guides.bat** - 가이드 파일 오픈 실패
8. **setup_overview.py** - 리소스 복사 실패
9. **setup_overview.bat** - 리소스 복사 실패

---

## ✅ 권장 조치 사항

### 변경 맵핑

```
한글 이름                          →  영문 이름
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Contents/00_Intro/00_Intro.mars         →  이동 완료
Contents/01_Overview/01_Overview.mars   →  이동 완료
resource/asset_00_intro/                →  resource/asset_00_intro/
resource/asset_01_overview/             →  resource/asset_01_overview/
Contents/00_Intro/tree.toml             →  이동 완료
Contents/01_Overview/tree.toml          →  이동 완료
```

---

## 🔍 추가 정보

### 정상 참조 파일들
✅ [Contents/00_Intro/tree.toml](Contents/00_Intro/tree.toml)  
✅ [Contents/01_Overview/tree.toml](Contents/01_Overview/tree.toml)  
✅ [resource/RESOURCE_GUIDE.md](resource/RESOURCE_GUIDE.md) - 가이드 문서 (참조용)  
✅ [docs/README.md](docs/README.md) - 설명서들 (참조용)

---

## 📌 결론

**폴더/파일 이름 변경은 완료되었으나, 참조하는 파일들이 아직 한글 이름을 사용 중입니다.**

HIGH PRIORITY 파일 2개(`Sync-Resources.ps1`, `Prepare-Preview.ps1`)부터 먼저 수정하면  
대부분의 자동화 스크립트가 정상 작동할 것으로 예상됩니다.
