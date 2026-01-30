# 📊 3단계: .mars 파일 분석 및 추출 가이드

> 기존 인트로.mars와 수배전반개요.mars 파일을 분석하여 오브젝트와 리소스를 추출합니다

## 🎯 목표

1. 두 .mars 파일 압축 해제
2. tree.toml에서 오브젝트 계층 구조 파악
3. object.toml 파일들에서:
   - 오브젝트 GUID
   - 오브젝트 이름
   - 오브젝트 타입 (text, image, model_3d 등)
   - 사용 리소스 (resource_path)
4. 결과를 MarsCatalogue에 반영

## 🔧 실행 방법

### PowerShell에서 다음 명령 실행:

```powershell
# Parse-MarsFile.ps1 스크립트 사용 (새로운 방법)

# 1. 인트로.mars 분석
Write-Host "=== 인트로.mars 분석 ===" -ForegroundColor Cyan
.\Parse-MarsFile.ps1 -MarsFilePath "Contents/인트로.mars" -OutputPath "analysis_temp/intro"
Write-Host ""

# 2. 수배전반개요.mars 분석
Write-Host "=== 수배전반개요.mars 분석 ===" -ForegroundColor Cyan
.\Parse-MarsFile.ps1 -MarsFilePath "Contents/수배전반개요.mars" -OutputPath "analysis_temp/overview"
Write-Host ""

# 3. ContentsInfo.json 확인
Write-Host "=== ContentsInfo.json 내용 확인 ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "인트로 객체 목록:" -ForegroundColor Green
Import-Csv "analysis_temp/intro/object_list.csv" -Encoding UTF8 | Format-Table -AutoSize
Write-Host ""

Write-Host "수배전반개요 객체 목록:" -ForegroundColor Green
Import-Csv "analysis_temp/overview/object_list.csv" -Encoding UTF8 | Format-Table -AutoSize
Write-Host ""

Write-Host "✅ 분석 완료! 다음 파일을 확인하세요:" -ForegroundColor Green
Write-Host "   - analysis_temp/intro/ContentsInfo.json (전체 계층 구조)"
Write-Host "   - analysis_temp/intro/object_list.csv (객체 목록)"
Write-Host "   - analysis_temp/intro/version_info.json (메타데이터)"
Write-Host "   - analysis_temp/intro/section_*.bin (원본 바이너리)"
Write-Host ""
Write-Host "다음 단계:" -ForegroundColor Cyan
Write-Host "  1. STEP_3_RESULTS.md 문서 확인"
Write-Host "  2. ContentsInfo.json에서 Transform, Interaction 등 속성 확인"
Write-Host "  3. ResourceListInfo 섹션 파싱하여 리소스 파일 추출"
Write-Host "  4. TOML 변환 스크립트 작성 (Step 4)"
```

## 📋 분석 체크리스트

분석 후 다음 정보를 기록하세요:

### **인트로.mars**

```
오브젝트 목록:
┌─────────────────┬────────────┬────────────────┬──────────────────┐
│ GUID            │ 이름       │ 타입           │ 리소스 경로      │
├─────────────────┼────────────┼────────────────┼──────────────────┤
│ (분석 후 작성)  │            │                │                  │
└─────────────────┴────────────┴────────────────┴──────────────────┘
```

### **수배전반개요.mars**

```
오브젝트 목록:
┌─────────────────┬────────────┬────────────────┬──────────────────┐
│ GUID            │ 이름       │ 타입           │ 리소스 경로      │
├─────────────────┼────────────┼────────────────┼──────────────────┤
│ (분석 후 작성)  │            │                │                  │
└─────────────────┴────────────┴────────────────┴──────────────────┘
```

## 🎯 다음 단계

PowerShell 스크립트 실행 후:

1. **VS Code에서 확인**
   - `analysis_temp` 폴더를 VS Code에서 열기
   - 각 `tree.toml` 파일 내용 검토
   - 각 `object.toml` 파일 내용 검토

2. **정보 기록**
   - GUID, 이름, 타입, 리소스 경로 기록
   - 공통 리소스 vs 고유 리소스 분류

3. **다음 단계로 진행**
   - 4단계: 파일 배치 및 정렬 가이드 제공

## 💡 Tips

- `head -30`: 파일의 처음 30줄만 표시 (전체 내용이 길 때 유용)
- 리소스 경로에서 `resource/` 이후 부분만 기록
- 같은 리소스를 여러 오브젝트에서 사용하면 "공통"으로 분류

---

**다음 단계로 진행할 준비가 되었으면 "OK" 또는 "스크립트 실행 완료" 메시지를 보내주세요!**
