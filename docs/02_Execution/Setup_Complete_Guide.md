# 프로젝트 설정 완료 가이드

> PowerShell_Path_Guide.md를 항상 확인하도록 설정된 상태

---

## ✅ 설정 완료 사항

### 1. **VS Code Workspace 설정** (`root.code-workspace`)
   - ✅ 경로 처리 주의사항 주석 추가
   - ✅ 참고 문서 명시: `PowerShell_Path_Guide.md`
   - ✅ 핵심 원칙 표시

### 2. **PowerShell 프로필** (`Microsoft.PowerShell_profile.ps1`)
   - ✅ 자동 로드 설정
   - ✅ 프로젝트 로딩 시 가이드 참고 메시지 표시
   - ✅ 실행 정책 변경 (RemoteSigned)

### 3. **README.md 업데이트**
   - ✅ 필독 문서 섹션 추가
   - ✅ 빠른 시작 명령어 포함
   - ✅ 경로 처리 핵심 주의사항 명시

### 4. **빠른 접근 도구** (`open-guides.bat`)
   - ✅ 가이드 메뉴 스크립트 생성
   - ✅ 클릭으로 쉽게 가이드 열기 가능

---

## 🚀 사용 방법

### 방법 1: PowerShell 프로필 자동 로드
```powershell
# 새 PowerShell 창을 열면 자동으로 프로필이 로드되고 메시지가 표시됨
# 더 자세한 내용은 README.md 참고
```

### 방법 2: 가이드 빠르게 열기

**Windows에서:**
```bash
# 프로젝트 폴더에서 더블 클릭
open-guides.bat
```

**VS Code 터미널에서:**
```powershell
# 경로 처리 가이드 열기
code PowerShell_Path_Guide.md
```

**VS Code 파일 탐색기에서:**
- `PowerShell_Path_Guide.md` 파일을 클릭하면 즉시 열림

### 방법 3: VS Code의 "Quick Open" 사용
```
Ctrl+P (또는 Cmd+P)
→ "PowerShell" 입력
→ 가이드 파일 선택
```

---

## 📋 체크리스트

### 매번 터미널 작업 전에:

- [ ] 경로에 대괄호 `[ ]`가 있나? → **PowerShell_Path_Guide.md 참고!**
- [ ] 경로에 공백이나 한글이 있나? → **변수에 저장 후 사용**
- [ ] 상대 경로를 사용하나? → **Set-Location -LiteralPath 사용**
- [ ] 파일을 직접 파라미터로 전달하나? → **변수에 저장 후 전달**

---

## 🔑 핵심 패턴 (항상 기억!)

**경로에 특수문자가 있을 때:**

```powershell
# ✅ 올바른 방법
$path = "C:\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"
$file = Join-Path $path "Contents\intro.mars"
Expand-Archive -Path $file -DestinationPath $extract

# ❌ 잘못된 방법
cd "C:\[999999-99][폴리텍전기콘텐츠프로젝트]\..."  # 실패!
Expand-Archive -Path "C:\...\Contents\intro.mars"  # 위험!
```

---

## 📚 가이드 문서 위치

| 가이드 | 파일 | 용도 |
|--------|------|------|
| **경로 처리** | `PowerShell_Path_Guide.md` | ⭐ **작업 전 필수** |
| **콘텐츠 구조** | `Intro_Content_Structure.md` | 콘텐츠 분석 시 |
| **MarsMaker API** | `AGENTS.md` | 콘텐츠 생성 시 |
| **프로젝트 설정** | `README.md` | 프로젝트 개요 |

---

## ⚡ 빠른 팁

**PowerShell에서:**
```powershell
# VS Code에서 가이드 바로 열기
code PowerShell_Path_Guide.md

# 또는
code .\PowerShell_Path_Guide.md
```

**File Explorer에서:**
```
프로젝트 폴더 → PowerShell_Path_Guide.md → 더블클릭
```

**명령줄에서:**
```bash
# 모든 가이드 한 번에 VS Code에서 열기
code PowerShell_Path_Guide.md AGENTS.md Intro_Content_Structure.md
```

---

## 🎯 목표

✅ **매번 경로 처리로 시간 낭비하지 않기**
✅ **특수 문자 오류로 인한 재작업 없기**
✅ **한 번의 클릭으로 필요한 정보 찾기**
✅ **프로젝트 생산성 향상**

---

## 💡 추가 팁

### 터미널에서 바로 .bat 실행
```powershell
# 현재 위치에서
.\open-guides.bat

# 또는 절대 경로로
& "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric\open-guides.bat"
```

### VS Code 설정에서 빠른 접근
프로젝트 루트의 `.vscode\settings.json`에 아래를 추가하면 가이드 링크가 표시됩니다:

```json
{
  "workbench.startupEditor": "readme",
  "[markdown]": {
    "editor.wordWrap": "on"
  }
}
```

---

**설정 완료일**: 2026-01-29  
**프로젝트**: poly-dream-electric  
**상태**: ✅ 완료
