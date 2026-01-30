# PowerShell 특수 문자 경로 처리 가이드

> 대괄호, 공백, 한글 등이 포함된 경로를 PowerShell에서 안전하게 처리하는 방법

---

## 📌 문제 상황

**경로 예시:**
```
C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric
```

**발생하는 오류:**
```
cd : '경로' 경로는 존재하지 않으므로 찾을 수 없습니다.
Expand-Archive : '경로'가 없거나 유효한 파일 시스템 경로가 아닙니다.
```

---

## 🔴 원인 분석

### 1. **대괄호 `[ ]` - PowerShell의 특수 문자**

PowerShell에서 대괄호는 배열 인덱싱과 정규표현식 문자 클래스로 사용됩니다.

```powershell
# 예시
$array[0]           # 배열 인덱싱
[a-z]              # 정규표현식 (a부터 z까지)
[999999-99]        # PowerShell: "99부터 99까지의 범위"로 해석 ❌
```

**결과:**
```
경로: [999999-99][폴리텍전기콘텐츠프로젝트]
↓ PowerShell 해석
결과: `[999999-99`]`[폴리텍전기콘텐츠프로젝트`]  # 자동으로 백틱(`) 추가됨
```

### 2. **백슬래시 이스케이프 문제**

```powershell
# PowerShell은 문자열 내 특수 문자 자동 이스케이프 시도
"Contents\인트로.mars"
# 실제 전달되는 값: "Contents\인트로.mars" (또는 재해석됨)
```

### 3. **상대 경로 + 특수 문자의 조합**

```powershell
# 현재 위치가 명확하지 않을 때
Expand-Archive -Path "Contents\인트로.mars"  # 어느 폴더의 Contents인가?
# 경로가 애매하면 특수 문자는 더욱 심각해짐
```

---

## ✅ 해결 방법

### 방법 1: **Join-Path + 변수 저장** (권장) ⭐

```powershell
# 1. 현재 위치를 변수에 저장
$workDir = Get-Location
# 또는 절대 경로로 지정
$workDir = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"

# 2. 경로를 변수에 저장 (PowerShell이 문자 그대로 처리)
$marsFile = Join-Path $workDir "Contents\인트로.mars"
$extractPath = Join-Path $workDir "temp_intro"

# 3. 변수를 파라미터로 전달
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($marsFile, $extractPath)

# 또는
Expand-Archive -Path $marsFile -DestinationPath $extractPath -Force
```

**장점:**
- ✅ PowerShell이 변수값을 재해석하지 않음
- ✅ 경로가 명확함
- ✅ 코드 재사용성 높음

---

### 방법 2: **Set-Location -LiteralPath** (명시적 지정)

```powershell
# -LiteralPath: "문자 그대로" 경로로 해석
Set-Location -LiteralPath "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"

# 이제 상대 경로 사용 가능
Get-ChildItem "Contents"
Expand-Archive -Path "Contents\인트로.mars" -DestinationPath "temp_intro" -Force
```

**주의사항:**
- `-Path` 대신 `-LiteralPath` 사용 필수
- 절대 경로와 함께 사용

---

### 방법 3: **따옴표 + 이스케이프** (복잡함, 비권장)

```powershell
# 대괄호 앞에 백틱(`) 붙이기
cd "C:\Users\VIRNECT\Downloads\`[999999-99`]`[폴리텍전기콘텐츠프로젝트`]..."
```

**단점:**
- ❌ 가독성 나쁨
- ❌ 유지보수 어려움
- ❌ 특수 문자가 많을수록 복잡해짐

---

## 🎯 실전 예제

### 예제 1: .mars 파일 압축 해제

```powershell
# ✅ 권장 방법
$projectPath = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"
$marsFile = Join-Path $projectPath "Contents\인트로.mars"
$extractPath = Join-Path $projectPath "temp_intro"

# .mars를 .zip으로 복사
Copy-Item -Path $marsFile -Destination ($marsFile.Replace(".mars", ".zip"))

# 압축 해제
$zipFile = $marsFile.Replace(".mars", ".zip")
Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force

# 파일 확인
Get-ChildItem $extractPath -Recurse
```

---

### 예제 2: 여러 파일 처리

```powershell
# 모든 .mars 파일 처리
$projectPath = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"
$contentsDir = Join-Path $projectPath "Contents"

Get-ChildItem -Path $contentsDir -Filter "*.mars" | ForEach-Object {
    $marsFile = $_.FullName
    $extractPath = Join-Path $projectPath "temp_$($_.BaseName)"
    
    Write-Host "압축 해제: $($_.Name)"
    Copy-Item -Path $marsFile -Destination ($marsFile.Replace(".mars", ".zip"))
    $zipFile = $marsFile.Replace(".mars", ".zip")
    Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force
}
```

---

### 예제 3: 상대 경로로 전환

```powershell
# 먼저 위치 이동
Set-Location -LiteralPath "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"

# 이제 상대 경로로 처리 가능
$marsFile = Join-Path (Get-Location) "Contents\인트로.mars"
$extractPath = Join-Path (Get-Location) "temp_intro"

# 변수로 처리하면 안전
Expand-Archive -Path $marsFile -DestinationPath $extractPath -Force
```

---

## 📋 체크리스트

PowerShell에서 경로를 다룰 때:

- [ ] **경로에 대괄호가 있는가?** → 변수에 저장하기
- [ ] **경로에 공백이 있는가?** → 따옴표로 감싸기
- [ ] **한글이 포함되어 있는가?** → Join-Path 사용하기
- [ ] **상대 경로인가?** → Set-Location -LiteralPath 먼저 사용
- [ ] **특수 문자가 많은가?** → 변수 여러 개로 분해하기

---

## 🔑 핵심 원칙

| 상황 | 해결책 | 예시 |
|------|--------|------|
| **대괄호 `[ ]`** | 변수에 저장 | `$path = "...\[abc]..."` |
| **공백** | 따옴표 사용 | `"C:\Program Files\..."` |
| **한글** | Join-Path 사용 | `Join-Path $dir "폴더"` |
| **경로 이동** | Set-Location -LiteralPath | `Set-Location -LiteralPath "..."` |
| **파일 읽기** | -Path가 아닌 변수 전달 | `Get-Content $filePath` |

---

## ⚠️ 주의사항

### ❌ 하면 안 되는 것

```powershell
# 1. 상대 경로 + 특수 문자
cd "폴더명"  # 실패할 가능성 높음

# 2. 경로 직접 파라미터 전달
Expand-Archive -Path "C:\[특수]문자\경로"  # 특수 문자 재해석 위험

# 3. 복잡한 이스케이프
$path = "`[`[복잡`]`한`]경로"  # 가독성 떨어짐
```

### ✅ 해야 할 것

```powershell
# 1. 변수에 먼저 저장
$path = "C:\[특수]문자\경로"

# 2. 변수를 파라미터로 전달
Expand-Archive -Path $path -DestinationPath $extract

# 3. 또는 -LiteralPath 사용
Set-Location -LiteralPath $path
```

---

## 🔗 참고 자료

- PowerShell 대괄호 해석: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules
- Join-Path 사용법: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/join-path
- Expand-Archive: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive

---

**작성일**: 2026-01-29  
**프로젝트**: poly-dream-electric  
**태그**: #PowerShell #경로처리 #특수문자 #문제해결
