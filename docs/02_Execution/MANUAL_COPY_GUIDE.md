# 수배전반개요.mars 리소스 통합 지침

## 현재 상황
- ✅ `resource/overview/` 폴더 구조 생성됨 (images, models, videos, audio)
- ✅ 외부 리소스 위치 확인됨:
  - 2D: `..\..\05_디자인\2D\01_수배전개요\` (6개)
  - 3D: `..\..\05_디자인\3D\` (24개 FBX)
- ❌ Terminal 한글 경로 문제로 자동 복사 불가

## 🎯 해결 방법 (우선순위 순)

### 방법 1: VS Code 파일 탐색기 사용 (권장)

1. **VS Code 좌측 탐색기** → `resource/overview/images` 폴더 우클릭
   - "터미널에서 열기" 또는 "파일 탐색기에서 열기"

2. **별도의 창에서** 다음 경로 열기:
   ```
   C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\2D\01_수배전개요
   ```

3. **모든 파일 선택** (Ctrl+A) → **복사** (Ctrl+C)

4. **VS Code 탐색기의 images 폴더에 붙여넣기** (Ctrl+V)

5. **3D 모델도 동일하게**:
   - 원본: `..\..\05_디자인\3D` (하위의 *.fbx 파일만)
   - 대상: `resource/overview/models`

### 방법 2: Windows 탐색기 직접 복사

1. Windows 탐색기 두 개 열기 (윈도우 + E 두 번)

2. **좌측 창**: 
   ```
   C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인
   ```

3. **우측 창**:
   ```
   C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric\resource\overview
   ```

4. 좌측에서 파일 선택 → 우측에 드래그앤드롭

### 방법 3: 한글 경로 우회 심볼릭 링크

```powershell
# 관리자 권한 PowerShell에서 실행
cd C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric

# 심볼릭 링크 생성 (한글 경로를 우회)
New-Item -ItemType SymbolicLink -Path "resource\overview\source_2d" -Target "..\..\05_디자인\2D\01_수배전개요" -Force
New-Item -ItemType SymbolicLink -Path "resource\overview\source_3d" -Target "..\..\05_디자인\3D" -Force

# 이후 탐색기에서 링크된 폴더로 접근 가능
```

## ⚠️ Terminal 문제 원인

PowerShell에서 한글 경로 처리 시 인코딩 문제로 인해:
- 자동 스크립트 실행 불가
- 배치 파일도 동일 문제 발생
- 수동 복사가 가장 안정적

## 📋 복사 완료 후 체크리스트

- [ ] `resource/overview/images/` - 6개 파일 확인
- [ ] `resource/overview/models/` - 24개 FBX 파일 확인
- [ ] 파일명이 원본과 동일한지 확인

## ✅ 다음 단계

복사 완료 후 다음을 수행합니다:
1. `수배전반개요.mars`에 새 오브젝트 추가 (image, model_3d 타입)
2. 각 오브젝트의 Resource 경로 설정
3. 미리보기 구조 생성 (resource_changes.json)
4. STEP_3_ANALYSIS_GUIDE.md 업데이트

**작업 완료 후 보고** → 자동으로 다음 단계 진행
