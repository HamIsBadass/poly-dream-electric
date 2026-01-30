# 하이브리드 리소스 추출 실행 가이드

> 단계별로 Mars 파일의 리소스를 VS Code 워크스페이스에서 관리할 수 있는 실행 가이드

**작성일**: 2026-01-29  
**전략**: Option C - Hybrid (Thumbnail + Selective Extraction)  
**상태**: 단계 1 준비 완료

---

## 빠른 시작 (Quick Start)

### 지금 바로 (5분)

```powershell
# 1. PowerShell 관리자 권한 실행
# 2. 작업 디렉토리로 이동
cd "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric"

# 3. 썸네일 추출 (단계 1)
.\scripts\Extract-Thumbnails.ps1 -SourceFile "analysis_temp/intro/resource_manifest.json" -OutputDir "resource/intro"

# 4. 완료! resource/intro/RESOURCE_INVENTORY.json을 VS Code에서 확인
```

---

## 전체 워크플로우

```
단계 1: 즉시 완료 가능 ✅
├─ Extract-Thumbnails.ps1 실행
├─ RESOURCE_INVENTORY.json 생성
└─ VS Code에서 리소스 현황 파악

단계 2: 선택적 리소스 추출 (차주)
├─ resource_selection.txt에서 필요한 리소스 선택
├─ Extract-SelectedResources.ps1 실행 (개발 필요)
└─ 원본 파일 워크스페이스에 배치

단계 3: 변경 추적 및 통합
├─ Track-Changes.ps1으로 변경 감지
├─ resource_changes.json 생성
└─ Build-Mars.ps1로 최종 통합
```

---

## 상세 가이드

### 단계 1: 썸네일 추출 (Thumbnail-Only) - 즉시 실행

**목표**: 185개 리소스의 썸네일을 추출하여 빠르게 현황 파악

**실행 시간**: ~5-10초

**준비 사항**:
- ✅ analysis_temp/intro/resource_manifest.json (이미 생성됨)
- ✅ PowerShell 5.1 이상
- ✅ VS Code (선택사항)

**실행 명령**:

```powershell
# 기본 실행
.\scripts\Extract-Thumbnails.ps1

# 또는 자세한 로그와 함께 실행
.\scripts\Extract-Thumbnails.ps1 -Verbose
```

**결과 폴더 구조**:
```
resource/intro/
├── images/
│   ├── THUMB_intro_image_001.png
│   ├── THUMB_intro_image_002.png
│   └── ... (169개 이미지)
├── models/
│   ├── THUMB_motor_model_001.png
│   └── ... (14개 모델)
├── videos/
│   └── THUMB_background_video.png
├── audio/
│   └── THUMB_bgm_001.png
└── RESOURCE_INVENTORY.json
```

**생성되는 파일**:

1. **RESOURCE_INVENTORY.json** - 전체 리소스 메타데이터
   ```json
   {
     "metadata": {
       "source_mars": "인트로.mars",
       "extraction_date": "2026-01-29T10:00:00Z",
       "total_resources": 185,
       "strategy": "hybrid"
     },
     "resources": [
       {
         "id": "RES_00001",
         "name": "intro_image_001",
         "type": "Image",
         "format": "png",
         "thumbnail_path": "resource/intro/images/THUMB_intro_image_001.png",
         "resource_path": null,
         "extracted": false,
         "status": "available"
       },
       ...
     ],
     "statistics": {
       "images": { "total": 169, "extracted": 169 },
       "models": { "total": 14, "extracted": 14 },
       "videos": { "total": 1, "extracted": 1 },
       "audio": { "total": 1, "extracted": 1 }
     }
   }
   ```

2. **리소스 선택 목록** - analysis_temp/intro/resource_selection.txt
   ```txt
   # 추출할 리소스 목록 (필요시 이곳에 추가)
   ```

3. **변경 추적 템플릿** - analysis_temp/intro/resource_changes.json
   ```json
   {
     "tracking_metadata": {
       "created": "2026-01-29T10:00:00Z",
       "last_scan": "2026-01-29T10:00:00Z",
       "base_path": "resource/intro",
       "strategy": "hybrid"
     },
     "changes": []
   }
   ```

**다음 단계**:
```
✅ Step 1 완료 후:
1. resource/intro/RESOURCE_INVENTORY.json을 VS Code에서 열기
2. 썸네일을 보며 어떤 리소스가 있는지 확인
3. 필요한 리소스를 resource_selection.txt에 추가
4. 우선순위 결정 (높음/중간/낮음)
```

---

### 단계 2: 선택적 리소스 추출 (Optional) - 차주

**목표**: 필요한 리소스만 워크스페이스에 추출하여 직접 편집 가능하게 함

**실행 시간**: 선택된 리소스의 크기에 따라 다름
- 소규모 이미지 5개: ~10초
- 3D 모델 2개: ~20초

**준비 사항**:
- ✅ Step 1 완료 (RESOURCE_INVENTORY.json)
- ⏳ Extract-SelectedResources.ps1 (아직 개발 필요)
- resource_selection.txt에서 리소스 선택

**리소스 선택 방법**:

```txt
# resource_selection.txt 편집 예시
# 형식: 주석(#) 제거 → 선택됨

# 이미지 (고해상도 필요)
RES_00001|intro_image_001|1      # 높음 우선순위
RES_00003|hero_banner|1
RES_00005|product_image|2        # 중간 우선순위

# 3D 모델
RES_00150|motor_model_001|1
RES_00151|pump_model_001|2

# 오디오
RES_00180|background_music|1

# 나머지는 필요할 때 추가
```

**실행 명령** (차주 구현 예정):

```powershell
# 개발 예정
.\scripts\Extract-SelectedResources.ps1 -SelectionFile "analysis_temp/intro/resource_selection.txt" -OutputDir "resource/intro"
```

**예상 결과**:
```
resource/intro/
├── images/
│   ├── THUMB_intro_image_001.png    # 썸네일
│   ├── intro_image_001.png          # 원본 추출
│   ├── .intro_image_001.png.sha256  # 원본 해시 (변경 추적용)
│   ├── intro_image_001.png.status.json  # 메타데이터
│   └── ...
├── models/
│   ├── motor_model_001.fbx          # 추출된 원본
│   ├── .motor_model_001.fbx.sha256
│   └── ...
└── RESOURCE_INVENTORY.json (updated)
```

---

### 단계 3: 변경 추적 - 필요시 실행

**목표**: 수정된 리소스를 추적하고 Mars 재통합 준비

**실행 시간**: ~5초

**실행 조건**:
- 수정된 리소스가 있을 때
- 정기적 점검 (예: 주 1회)

**실행 명령**:

```powershell
# 변경사항 스캔
.\scripts\Track-Changes.ps1 -ResourceDir "resource/intro"

# 또는 자세한 로그
.\scripts\Track-Changes.ps1 -ResourceDir "resource/intro" -Verbose
```

**결과 파일**:

```json
// analysis_temp/intro/resource_changes.json
{
  "tracking_metadata": {
    "last_scan": "2026-01-29T15:00:00Z",
    "total_changes": 3,
    "summary": {
      "new": 1,
      "modified": 2,
      "deleted": 0,
      "unchanged": 182
    }
  },
  "changes": [
    {
      "file": "intro_image_001.png",
      "path": "images/intro_image_001.png",
      "status": "modified",
      "original_hash": "abc123...",
      "current_hash": "def456...",
      "timestamp": "2026-01-29T14:30:00Z",
      "action": "update_in_mars"
    },
    {
      "file": "new_resource.png",
      "path": "images/new_resource.png",
      "status": "new",
      "current_hash": "xyz789...",
      "timestamp": "2026-01-29T15:00:00Z",
      "action": "add_to_mars"
    }
  ]
}
```

---

## 실제 사용 시나리오

### 시나리오 1: 기존 리소스 재사용하기

```
상황: "인트로.mars"의 배경 이미지를 밝게 수정하고 싶음"

절차:
1️⃣ RESOURCE_INVENTORY.json에서 배경 이미지 확인 (RES_00005)
2️⃣ resource_selection.txt에 RES_00005 추가
3️⃣ Extract-SelectedResources.ps1 실행
4️⃣ resource/intro/images/hero_banner.png 파일 수정
   → Photoshop, Paint.net 등에서 열어서 수정
5️⃣ 파일 저장
6️⃣ Track-Changes.ps1 실행 (자동 감지)
7️⃣ resource_changes.json에서 "modified" 확인
8️⃣ Build-Mars.ps1 실행 (차주 구현)
9️⃣ 새로운 Mars 파일 생성 및 View에서 테스트
```

**핵심 파일 변화**:
```
Before:
resource/intro/images/
├── THUMB_hero_banner.png    (원본 썸네일)
└── (원본 파일 없음, 추출 안됨)

After Step 3:
resource/intro/images/
├── THUMB_hero_banner.png
├── hero_banner.png           (✅ 추출됨)
└── .hero_banner.png.sha256   (원본 해시)

After Step 5:
resource/intro/images/
├── THUMB_hero_banner.png
├── hero_banner.png           (✅ 수정됨, 다른 파일 크기)
└── .hero_banner.png.sha256   (원본 해시, 변경 전)

After Step 6 (Track-Changes):
analysis_temp/intro/resource_changes.json
{
  "changes": [{
    "file": "hero_banner.png",
    "status": "modified",
    "original_hash": "원본...",
    "current_hash": "수정본...",
    "action": "update_in_mars"
  }]
}
```

### 시나리오 2: 새로운 리소스 추가하기

```
상황: "새로운 이미지를 추가하고 싶음"

절차:
1️⃣ 새 이미지를 resource/intro/images/에 저장
   → 파일명: new_electric_diagram.png
2️⃣ Track-Changes.ps1 실행
3️⃣ resource_changes.json에서 "new" 상태 확인
4️⃣ RESOURCE_INVENTORY.json에 수동으로 항목 추가 (또는 MCP로 생성)
5️⃣ MarsCatalogue에서 새 객체 생성
6️⃣ Build-Mars.ps1 실행
```

**변경 추적 기록**:
```json
{
  "file": "new_electric_diagram.png",
  "path": "images/new_electric_diagram.png",
  "status": "new",
  "action": "add_to_mars"
}
```

### 시나리오 3: 정기적 리소스 모니터링

```
매주 월요일 아침: 리소스 변경사항 확인

1️⃣ Track-Changes.ps1 자동 실행 (PowerShell 스케줄 태스크 가능)
2️⃣ resource_changes.json 생성
3️⃣ VS Code에서 변경 파일 검토
4️⃣ 필요시 Build-Mars.ps1 실행
```

---

## VS Code 설정 (선택사항)

### 권장 확장 기능

```json
// VS Code Extensions
{
  "extensions": [
    "PKief.material-icon-theme",        // 파일 아이콘
    "ms-vscode.live-server",            // 로컬 서버
    "jebbs.plantuml",                   // 구조도 (선택)
    "ms-python.vscode-pylance",         // JSON 검증
    "esbenp.prettier-vscode",           // 포맷팅
  ]
}
```

### VS Code Tasks (자동화)

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Extract Thumbnails",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-File",
        ".\\scripts\\Extract-Thumbnails.ps1"
      ],
      "problemMatcher": [],
      "group": {
        "kind": "build",
        "isDefault": false
      }
    },
    {
      "label": "Track Changes",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-File",
        ".\\scripts\\Track-Changes.ps1"
      ],
      "problemMatcher": [],
      "group": {
        "kind": "build",
        "isDefault": false
      }
    }
  ]
}
```

사용:
```
Ctrl+Shift+B → "Extract Thumbnails" 또는 "Track Changes" 선택
```

---

## 문제 해결 (Troubleshooting)

### 문제 1: "Cannot find path" 오류

```powershell
오류:
Cannot find path 'C:\...\analysis_temp\intro\resource_manifest.json'

해결:
1. 경로 확인: 현재 디렉토리가 poly-dream-electric인지 확인
2. 파일 존재 확인:
   Test-Path "analysis_temp/intro/resource_manifest.json"
3. 경로 대소문자 확인 (Windows에서는 무시되지만 확인)
```

### 문제 2: PowerShell 실행 정책 오류

```powershell
오류:
... cannot be loaded because running scripts is disabled on this system

해결:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

또는 스크립트 없이 직접 실행:
powershell -File .\scripts\Extract-Thumbnails.ps1
```

### 문제 3: Base64 디코딩 실패

```powershell
오류:
Base64 디코딩 실패

원인:
- 손상된 ResourceListInfo JSON
- 메모리 부족 (매우 많은 리소스)

해결:
1. JSON 파일 검증:
   Get-Content "analysis_temp/intro/resource_manifest.json" | ConvertFrom-Json | Out-Null

2. 일부만 처리 (테스트):
   $manifest = Get-Content "..." | ConvertFrom-Json
   $manifest.resources[0..10] | ForEach-Object { ... }
```

### 문제 4: 변경 추적이 모든 파일을 수정으로 감지

```powershell
원인:
- 처음 실행 후 .sha256 파일이 없음
- 파일 복사 시 타임스탬프 변경

해결:
1. 첫 실행은 모든 파일이 "new" 상태 → 정상
2. 두 번째 실행부터 정상 감지 시작
3. 필요시 .sha256 파일 수동 삭제하여 초기화
```

---

## 다음 단계

### 차주 (Week 2-3)

- [ ] Extract-Thumbnails.ps1 실행 및 검증
- [ ] RESOURCE_INVENTORY.json 검토
- [ ] resource_selection.txt에서 상위 5개 리소스 선택

### 2주차 (Week 4-5)

- [ ] Extract-SelectedResources.ps1 개발 및 테스트
- [ ] 선택된 리소스 추출
- [ ] Track-Changes.ps1으로 변경 추적 테스트

### 3주차 (Week 6-8)

- [ ] Build-Mars.ps1 개발
- [ ] 수정된 리소스 Mars 재통합
- [ ] View에서 최종 테스트
- [ ] MarsCatalogue와 통합

---

## 참고 문서

- `RESOURCE_EXTRACTION_STRATEGY.md` - 전체 전략 문서
- `AGENTS.md` - MarsMaker MCP 가이드
- `analysis_temp/intro/resource_manifest.json` - 리소스 메타데이터
- 스크립트: `scripts/Extract-Thumbnails.ps1`, `Track-Changes.ps1`

---

**마지막 업데이트**: 2026-01-29  
**작성**: AI Assistant  
**상태**: ✅ 단계 1 준비 완료
