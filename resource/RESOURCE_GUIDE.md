# 📚 리소스 관리 가이드

> resource 폴더의 파일들을 체계적으로 관리하는 방법

## 📂 폴더 구조 원칙

```
resource/
├── common/          # 두 콘텐츠 모두에서 사용하는 리소스
│   ├── images/      # 공통 이미지 (로고, UI 등)
│   ├── models/      # 공통 3D 모델
│   └── audio/       # 공통 음성/효음
│
├── intro/           # 인트로 콘텐츠만 사용하는 리소스
│   ├── images/
│   ├── models/
│   └── audio/
│
└── overview/        # 수배전반개요 콘텐츠만 사용하는 리소스
    ├── images/
    ├── models/
    └── audio/
```

## 📝 파일 명명 규칙

### PNG 이미지
```
kebab-case (소문자 + 하이픈)

✅ logo.png
✅ ui_button_primary.png
✅ intro_splash_screen.png
❌ Logo.png (대문자 X)
❌ ui_button_primary.PNG (대문자 확장자 X)
```

### FBX 3D 모델
```
kebab-case (소문자 + 하이픈)

✅ breaker_model.fbx
✅ transformer_unit.fbx
✅ cable_assembly.fbx
❌ BreakerModel.fbx
❌ transformer_Unit.fbx
```

### 오디오 파일
```
kebab-case (소문자 + 하이픈)

✅ ui_click.mp3
✅ background_music.mp3
✅ voice_intro.wav
❌ UIClick.mp3
❌ background-music.mp3
```

## 🗂️ 파일 배치 기준

### common/ 폴더에 배치할 파일

**언제 사용하나?**
- 인트로.mars와 수배전반개요.mars **둘 다**에서 사용

**예시:**
```
common/images/
├── logo.png              # 회사 로고 (모든 콘텐츠에 표시)
├── ui_button.png         # 공통 UI 버튼
└── background_base.png   # 기본 배경

common/audio/
├── ui_click.mp3          # 버튼 클릭 음
└── transition.mp3        # 화면 전환 효음
```

### intro/ 폴더에 배치할 파일

**언제 사용하나?**
- 인트로.mars **에서만** 사용

**예시:**
```
intro/images/
├── intro_splash.png      # 스플래시 이미지
├── title_animation.png   # 제목 애니메이션 이미지
└── intro_bg.png         # 인트로 배경

intro/models/
├── intro_text_3d.fbx     # 제목 3D 모델
└── intro_animation.fbx   # 인트로 애니메이션

intro/audio/
├── intro_music.mp3       # 인트로 배경음
└── intro_voiceover.mp3   # 보이스오버
```

### overview/ 폴더에 배치할 파일

**언제 사용하나?**
- 수배전반개요.mars **에서만** 사용

**예시:**
```
overview/images/
├── schematic_diagram.png # 회로도
├── component_breaker.png # 차단기 다이어그램
└── distribution_chart.png # 배전 차트

overview/models/
├── breaker.fbx           # 차단기 3D 모델
├── transformer.fbx       # 변압기 3D 모델
├── cable.fbx             # 케이블 3D 모델
└── panel.fbx             # 패널 3D 모델

overview/audio/
├── overview_music.mp3    # 배경음
└── explanation_voice.mp3 # 설명 음성
```

## 🔗 object.toml에서 참조 방법

### 공통 리소스 참조

```toml
# 이미지 참조
[components.Image]
[components.Resource]
resource_path = "common/images/logo.png"

# 모델 참조
[components.Model]
[components.Resource]
resource_path = "common/models/animation.fbx"

# 오디오 참조
[components.Audio]
[components.Resource]
resource_path = "common/audio/ui_click.mp3"
```

### 콘텐츠별 리소스 참조

```toml
# 인트로만 사용
[components.Resource]
resource_path = "intro/images/intro_splash.png"

# 수배전반개요만 사용
[components.Resource]
resource_path = "overview/models/breaker.fbx"
```

## 📊 리소스 추적 표

파일을 추가/삭제할 때마다 `.resource-index.json` 업데이트:

```json
{
  "common": {
    "logo.png": {
      "path": "common/images/logo.png",
      "type": "image/png",
      "usedIn": ["intro", "overview"],
      "status": "active"
    }
  },
  "intro": {
    "intro_splash.png": {
      "path": "intro/images/intro_splash.png",
      "type": "image/png",
      "usedIn": ["intro"],
      "status": "active"
    }
  }
}
```

## ✅ 체크리스트

새 리소스 추가 시:

- [ ] 올바른 폴더에 배치했는가? (common/intro/overview)
- [ ] 파일명이 kebab-case인가?
- [ ] 파일 확장자가 소문자인가?
- [ ] object.toml에서 resource_path를 정확히 설정했는가?
- [ ] ValidateContent로 경로 확인했는가?

## 🚀 빠른 참조

| 상황 | 폴더 | 예시 |
|------|------|------|
| 두 콘텐츠 모두 사용 | `common/` | `common/images/logo.png` |
| 인트로만 사용 | `intro/` | `intro/images/intro_splash.png` |
| 수배전반개요만 사용 | `overview/` | `overview/models/breaker.fbx` |

## 💡 팁

1. **파일 이동 후 검증**: ValidateContent로 리소스 경로 확인
2. **중복 제거**: 같은 파일을 여러 곳에 두지 말기
3. **이름 규칙 준수**: 팀 일관성을 위해 kebab-case 준수
4. **정기적 정리**: 사용하지 않는 리소스 정기적 삭제

---

**작성일**: 2026-01-29  
**버전**: 1.0
