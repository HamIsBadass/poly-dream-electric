# Resource Tools

리소스 추출, 동기화, 변경 추적 도구들입니다.

## 스크립트 설명

### Sync-Resources.ps1
- **목적**: Mars 파일 기준으로 리소스 폴더 동기화
- **사용 방법**: .\Sync-Resources.ps1

### Prepare-Preview.ps1
- **목적**: Mars에서 사용하는 에셋만 preview 폴더에 복사

### Extract-Resources.ps1
- **목적**: 전체 리소스 추출 (자동화)

### Track-Changes.ps1
- **목적**: 리소스 변경 사항 추적 (SHA256 기반)

## 권장 실행 순서
1. Sync-Resources.ps1 (기존 리소스 정렬)
2. Prepare-Preview.ps1 (미리보기 준비)
3. Track-Changes.ps1 (변경 추적 시작)
