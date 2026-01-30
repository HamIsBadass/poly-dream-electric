# Overview Mars 리소스 통합 - 단계별 가이드

## 현재 상황

✅ **완료됨:**
- 한글 파일명 영문화 완료 (PowerShell_Path_Guide.md 등)
- overview 폴더 구조 생성 (resource/overview/{images,models,videos,audio})
- overview.mars 분석 완료 (기본 씬 그룹 + 씬 1)

⏳ **진행 중:**
- 외부 리소스 복사 (Terminal 환경 제약)

---

## 🎯 대안 방법: 수동 파일 복사 가이드

### Step 1: 외부 파일 준비

#### 1-1. 2D 이미지 복사 (6개 파일)
```
원본 경로:
C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\2D\01_수배전개요

대상 경로:
poly-dream-electric\resource\overview\images\
```

**방법:**
1. Windows Explorer에서 위 원본 폴더 열기
2. 모든 파일 선택 (Ctrl+A)
3. 복사 (Ctrl+C)
4. `resource\overview\images\` 폴더에 붙여넣기 (Ctrl+V)

#### 1-2. 3D 모델 복사 (24개 FBX 파일)
```
원본 경로:
C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\3D\

대상 경로:
poly-dream-electric\resource\overview\models\
```

**방법:**
1. Windows Explorer에서 위 원본 폴더 열기
2. **모든 하위 폴더의 *.fbx 파일만 선택**
   - Ctrl+F로 "*.fbx" 검색 후 모두 선택
   - 또는 수동으로 각 .fbx 파일 선택 (Shift+클릭)
3. 복사 (Ctrl+C)
4. `resource\overview\models\` 폴더에 붙여넣기 (Ctrl+V)

---

### Step 2: 파일 복사 확인

파일이 제대로 복사되었는지 확인:
```
resource\overview\
├── images\          (6개 이미지 파일)
├── models\          (24개 FBX 파일)
├── videos\          (비어있음)
└── audio\           (비어있음)
```

---

### Step 3: overview.mars에 오브젝트 추가 (다음 단계)

파일 복사 완료 후, 다음 작업을 진행합니다:
1. overview.mars 파일 분석
2. 리소스를 참조하는 오브젝트 정의 (TOML)
3. 오브젝트를 overview.mars에 추가
4. 미리보기 구조 생성

---

## 📝 수동 복사 체크리스트

- [ ] 2D 이미지 6개 파일이 `resource\overview\images\`에 복사됨
- [ ] 3D FBX 모델 24개 파일이 `resource\overview\models\`에 복사됨
- [ ] 파일명이 원본과 동일하게 유지됨 (공백, 특수문자 포함)
- [ ] 폴더 구조 확인:
  ```
  ls resource\overview -Recurse
  ```
  명령으로 30개 파일 확인 가능

---

## ⚠️ 주의사항

1. **폴더 복사 금지**: 폴더 구조는 무시하고, **파일만 models 폴더에 복사**
2. **대소문자 유지**: 파일명의 대소문자 정확히 유지
3. **특수문자 유지**: 한글, 공백 등이 있으면 그대로 복사

---

## ✅ 복사 완료 후 다음 단계

복사가 완료되면 VS Code 터미널에서:

```powershell
# 리소스 메타데이터 생성 및 overview.mars 업데이트
# (자동 스크립트 실행)
```

로 계속 진행합니다.

---

**예상 소요 시간**: 5~10분 (드래그앤드롭 방식)

파일 복사 완료 후 "완료됨"이라고 말씀해주세요!
