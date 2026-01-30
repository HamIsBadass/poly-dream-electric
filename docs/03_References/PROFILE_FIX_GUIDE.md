# 🔧 PowerShell 프로필 수정 방법

> Set-Alias 오류를 수정하는 단계별 가이드

## ⚠️ 문제점

기존 프로필(`Microsoft.PowerShell_profile.ps1`)에서 다음 오류 발생:
```
Set-Alias : 'Value' 매개 변수의 인수가 스크립트 블록으로 지정되어 있으며 
입력이 없으므로 해당 매개 변수를 평가할 수 없습니다.
```

**원인:** `Set-Alias`가 스크립트 블록 `{ }` 을 지원하지 않음

---

## ✅ 해결 방법

### **방법 1: 프로필 파일 직접 수정** (권장)

1. **프로필 파일 열기**
   ```powershell
   # PowerShell에서 실행
   code $PROFILE
   ```

2. **문제 부분 찾기**
   ```powershell
   # ❌ 찾아서 삭제할 부분 (라인 10 주변)
   Set-Alias -Name cdpoly -Value {
       Set-Location -LiteralPath "..."
   } -Force
   ```

3. **올바른 코드로 교체**
   ```powershell
   # ✅ 이 코드로 교체
   function cdpoly {
       Set-Location -LiteralPath "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"
       Write-Host "프로젝트 폴더로 이동!" -ForegroundColor Green
   }
   ```

4. **전체 함수 부분을 올바르게 수정**
   - `pathguide`, `contentguide`, `agentsguide` 함수들도 마찬가지로 수정
   - 각각 `function 이름 { ... }` 형식으로 변경

---

### **방법 2: 완전히 새로운 프로필 사용** (빠른 방법)

1. **기존 프로필 백업**
   ```powershell
   $PROFILE
   # 출력: C:\Users\VIRNECT\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
   
   # 백업
   Copy-Item -Path $PROFILE -Destination "$PROFILE.backup"
   ```

2. **워크스페이스의 수정된 프로필 복사**
   ```powershell
   $projectPath = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"
   $fixedProfile = Join-Path $projectPath "PowerShell_Profile_Fixed.ps1"
   
   # 내용 복사
   Get-Content $fixedProfile | Set-Content -Path $PROFILE -Force
   
   Write-Host "프로필 업데이트 완료!" -ForegroundColor Green
   ```

3. **새 PowerShell 창 열기**
   - 기존 창은 닫고 새 PowerShell 창을 열면 자동으로 로드됨

---

## 🔍 **수정 내용 확인**

새 PowerShell 창에서:

```powershell
# 1. 프로필이 올바르게 로드되었는지 확인
$PROFILE | Get-Content | Select-String "function"

# 2. 함수들이 정의되었는지 확인
Get-Command -Name cdpoly, pathguide, agentsguide, Show-ProjectStatus

# 3. 함수 실행 테스트
Show-ProjectStatus
```

---

## 📋 **수정된 프로필의 주요 변경사항**

| 항목 | 변경 전 | 변경 후 |
|------|--------|--------|
| **별칭 설정** | `Set-Alias -Name ... -Value { }` | `function 이름 { }` |
| **입력 방식** | 스크립트 블록 ❌ | 함수 정의 ✅ |
| **에러** | ScriptBlockArgumentNoInput | 없음 ✅ |
| **복잡성** | 낮음 (별칭) | 중간 (함수) |

---

## ⚡ **빠른 수정 단계**

```powershell
# 1단계: 워크스페이스의 수정된 파일 경로
$projectPath = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"
$fixedProfile = Join-Path $projectPath "PowerShell_Profile_Fixed.ps1"

# 2단계: 프로필에 복사
Get-Content $fixedProfile | Set-Content -Path $PROFILE -Force

# 3단계: 새 PowerShell 창 열기 (자동으로 로드됨)
```

---

## ✅ 완료!

- ✅ Set-Alias 오류 제거
- ✅ 함수 방식으로 변경
- ✅ 모든 기능 유지
- ✅ 더 안정적인 구조

**새 PowerShell 창을 열고 `cdpoly` 또는 `pathguide` 명령을 실행해보세요!** 🚀

---

**수정 완료 날짜**: 2026-01-29
