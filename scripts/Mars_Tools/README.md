# Mars Tools

Mars 파일 분석 및 파싱 도구들입니다.

## 스크립트 설명

### Parse-MarsFile.ps1
- **목적**: Mars 파일의 구조를 파싱하여 메타데이터 추출
- **사용 방법**: .\Parse-MarsFile.ps1 -MarsPath "path/to/file.mars"

### Analyze-ResourceListInfo.ps1
- **목적**: Mars 파일 내 ResourceListInfo 섹션 분석

### Extract-ResourceListInfo.ps1
- **목적**: ResourceListInfo 섹션을 별도 파일로 추출

## 실행 순서
1. Parse-MarsFile.ps1 (구조 파악)
2. Analyze-ResourceListInfo.ps1 (리소스 분석)
3. Extract-ResourceListInfo.ps1 (데이터 추출)

## 다음 단계
→ ../Resource_Tools/의 스크립트로 추출된 리소스 관리
