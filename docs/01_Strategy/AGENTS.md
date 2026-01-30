# MarsMaker AI 가이드 (초안)

> AI가 MarsMaker MCP를 통해 XR 콘텐츠를 생성하고 편집하기 위한 종합 가이드

## 목차

1. [개요](#1-개요)
2. [플랫폼 소개](#2-플랫폼-소개)
3. [콘텐츠 구조](#3-콘텐츠-구조)
4. [객체 타입](#4-객체-타입)
5. [Transform과 좌표계](#5-transform과-좌표계)
6. [리소스 관리](#6-리소스-관리)
7. [애니메이션 시스템](#7-애니메이션-시스템)
8. [인터랙션 시스템](#8-인터랙션-시스템)
9. [실전 예제](#9-실전-예제)
10. [TOML 포맷 규칙](#10-toml-포맷-규칙)
11. [Best Practices](#11-best-practices)
12. [Scripting](#12-scripting)

---

## 1. 개요

### MarsMaker란?
- **목적**: AI가 MCP(Model Context Protocol)를 통해 Make/View XR 콘텐츠를 생성/편집
- **역할**: 콘텐츠 구조 생성, 빌드 지원, 파일 시스템 관리
- **AI의 역할**: 콘텐츠 세부 설정, 객체 배치, 애니메이션/인터랙션 구성

### Mars 파일 형식
- **Mars**: Make 저작 도구에서 생성한 XR 콘텐츠의 압축 파일 포맷
- **View**: Mars 파일을 재생하는 플랫폼 (PC, Meta Quest, Mobile 지원)
- **특징**: 인터랙티브한 XR 콘텐츠, 크로스 플랫폼 동일 모듈 사용

### 워크플로우
```
1. AI: MCP로 콘텐츠 생성 (CreateContent)
   → MarsMaker: 기본 구조 생성 (씬그룹 1개 + 씬 1개)
   ⚠️ 주의: 기본 씬("Scene 1")이 자동 생성됨
   
   선택:
   a) 기본 씬 활용: 이름/내용 변경하여 첫 씬으로 사용 (권장 - 단일 씬)
   b) 기본 씬 삭제: 새 씬 생성 후 DeleteNodes로 제거 (권장 - 다중 씬)
   c) 기본 씬 유지: 빈 상태로 두고 새 씬 추가 (비권장 - 빈 씬이 먼저 표시됨)

2. AI: MCP로 노드 생성 (CreateNodes)
   → MarsMaker: tree.toml 업데이트 + 빈 object.toml 생성
   ⚠️ 주의: CreateNodes는 최소 템플릿만 제공 (Core 컴포넌트 누락)

3. AI: object.toml 파일 직접 작성
   - 필수 컴포넌트 추가 (Core, Transform, 타입별 컴포넌트)
   - text 타입은 BackGround, TTS 컴포넌트도 필수
   - TOML 포맷 규칙 준수 (배열, 문자열 등)

4. AI: 검증 (ValidateContent)
   → 빌드 전 필수! 누락/오류 사전 확인

5. AI: 빌드 (BuildContent)
   → MarsMaker: .mars 파일 생성

6. User: View에서 Mars 파일 재생
```

### 실전 작업 팁
- **단계별 검증**: 소수 객체 생성 → 검증 → 나머지 생성 (오류 조기 발견)
- **템플릿 활용**: 첫 객체 완성 후 복제하여 수정 (일관성 유지)
- **리소스 우선**: resource/ 폴더에 파일 먼저 배치 후 객체 생성

---

## 2. 플랫폼 소개

### Make (저작 도구)
- XR 콘텐츠를 시각적으로 제작하는 에디터
- Mars 파일로 내보내기 지원

### View (재생 플랫폼)
- **지원 플랫폼**: PC (Windows), Meta Quest (VR), Mobile (Android/iOS)
- **공통 기능**: 동일한 Mars 파일을 모든 플랫폼에서 재생
- **렌더링 모드**:
  - **World Mode**: 3D 공간에 배치 (VR/AR 환경)
  - **Screen Mode**: 2D UI 오버레이 (스크린 고정)

### 플랫폼별 고려사항
- **Meta Quest**: 손 트래킹, 컨트롤러 입력 지원
- **PC**: 마우스/키보드 입력
- **Mobile**: 터치 입력, 자이로 센서

---

## 3. 콘텐츠 구조

### 3.1 디렉토리 구조
```
Contents/<ContentName>/
├── tree.toml              # 계층 구조 정의
├── objects/               # 객체별 폴더
│   ├── <GUID_1>/
│   │   └── object.toml    # 객체 속성
│   ├── <GUID_2>/
│   │   └── object.toml
│   └── ...
└── resource/              # 리소스 파일
    ├── images/
    ├── videos/
    ├── models/
    └── audio/
```

### 3.2 계층 구조 (Hierarchy)
```
Root
└── SceneGroup (씬 그룹)
    ├── Scene (씬 1) - 수동/자동 전환
    │   ├── Object (텍스트)
    │   ├── Object (이미지)
    │   └── Object (3D 모델)
    ├── Scene (씬 2)
    │   └── ...
    └── Scene (씬 3)
```

**규칙**:
- **필수 계층**: SceneGroup → Scene → Objects
- **SceneGroup**: 여러 Scene을 묶는 컨테이너
- **Scene**: 하나의 화면/장면 (한 번에 하나만 활성화)
- **Objects**: Scene 내부의 실제 콘텐츠 (텍스트, 이미지, 모델 등)

### 3.3 tree.toml 구조
```toml
format_version = 1
roots = ["<SceneGroup_GUID>"]

[nodes."<SceneGroup_GUID>"]
name = "씬 그룹 1"
children = ["<Scene1_GUID>", "<Scene2_GUID>"]

[nodes."<Scene1_GUID>"]
name = "씬 1"
children = ["<Object1_GUID>", "<Object2_GUID>"]
```

### 3.4 object.toml 완전한 구조

```toml
format_version = 1
id = "<GUID>"               # GUID (대문자 16진수 + 하이픈)
name = "객체 이름"
active = true               # 초기 활성화 여부
object_type = "text"        # 객체 타입

# ====== 필수: 모든 객체 ======
[components.Core]
editing_color = [ 1.0, 1.0, 1.0, 1.0 ]

# ====== 필수: scene/scene_group 제외 ======
[components.Transform]
screen_mode = 1
pivot = [ 0.5, 0.5 ]
use_billboard = false
is_reversed_billboard = false
position = [ 0, 0, 0 ]
rotation = [ 0, 0, 0 ]
scale = [ 1, 1, 1 ]

# ====== 필수: object_type별 ======
[components.Text]
text = "텍스트"
font = "NotoSansCJKkr-Bold"
font_size = 32
alignment = "MiddleCenter"
color = [ 1.0, 1.0, 1.0, 1.0 ]
shadow = 0

# ====== 필수: text 타입만 ======
[components.BackGround]
use_back_ground = false
back_ground_color = [ 0.0, 0.0, 0.0, 0.5 ]
border_use = false
border_color = [ 1.0, 1.0, 1.0, 1.0 ]
border_thick = 1.0
back_ground_opacity = 1.0

[components.TTS]
use_tts = false
voice = "None"

# ====== 선택: 애니메이션 ======
[components.Animation]
clip_index = 0

# ====== 선택: 인터랙션 ======
[[components.Interaction.interactions]]
action = 1
```

**중요**: 
- 배열은 공백 포함: `[ 1.0, 2.0, 3.0 ]` (양쪽 공백)
- text 타입은 BackGround, TTS 필수 (누락 시 검증 실패)

---

## 4. 객체 타입

### 4.1 지원 타입 목록

**기본 타입** (AI가 생성 가능):

| ObjectType | 용도 | 주요 컴포넌트 | Animation | Interaction |
|------------|------|--------------|-----------|-------------|
| `scene_group` | 씬 그룹 | SceneGroupInfo | ✗ | ✗ |
| `scene` | 씬 | SceneInfo | ✗ | ✗ |
| `text` | 텍스트 | Transform, Text | ✓ | ✓ |
| `image` | 이미지 | Transform, Image, Resource | ✓ | ✓ |
| `video` | 비디오 | Transform, Video, Resource | ✓ | ✓ |
| `model_3d` | 3D 모델 | Transform, Model, Resource | ✓ | ✓ |
| `audio` | 오디오 | Transform, Audio, Resource | ✓ | ✓ |
| `shape` | 3D 도형 | Transform, Shape | ✓ | ✓ |
| `polygon_2d` | 2D 다각형 | Transform, Polygon2D | ✓ | ✓ |
| `user_script` | 사용자 스크립트 | Transform, UserScript | ✗ | ✗ |
| `empty` | 빈 객체 | Transform | ✓ | ✓ |

**참고**: Report, CheckList, Table, Graph 등 고급 UI 컴포넌트는 Make 에디터에서만 생성 가능합니다.

### 4.1.1 필수 컴포넌트

**모든 객체 공통**:
- `[components.Core]` - 편집 색상 (editing_color)

**object_type별 필수**:

| ObjectType | 필수 컴포넌트 | 비고 |
|------------|--------------|------|
| `scene_group` | Core, SceneGroupInfo | - |
| `scene` | Core, SceneInfo | - |
| `text` | Core, Transform, Text, **BackGround**, **TTS** | BackGround, TTS 누락 시 검증 실패 |
| `image` | Core, Transform, Image, Resource | - |
| `video` | Core, Transform, Video, Resource | - |
| `model_3d` | Core, Transform, Model, Resource | - |
| `audio` | Core, Transform, Audio, Resource | - |
| `shape` | Core, Transform, Shape | - |
| `polygon_2d` | Core, Transform, Polygon2D | - |
| `user_script` | Core, Transform, UserScript | 사용자 정의 스크립트 객체 |
| `empty` | Core, Transform | - |

**선택 컴포넌트**:
- `Animation` - 애니메이션이 필요한 경우
- `Interaction` - 인터랙션이 필요한 경우

### 4.2 타입별 상세 설명

#### scene_group
```toml
object_type = "scene_group"

[components.SceneGroupInfo]
scene_group_title = ""
scene_group_detail = ""
editing_color = [1.0, 1.0, 1.0, 1.0]  # RGBA
```

#### scene
```toml
object_type = "scene"

[components.SceneInfo]
enable_scene_info = true
scene_title = "씬 제목"
scene_type = "Manual"          # Manual | Auto
scene_detail = "설명"
ambient_light_intensity = 0.4  # 환경광 강도 (0.0 ~ 1.0)
environment_image_resource_id = "None"  # HDR 환경맵 ID
```

#### text
```toml
object_type = "text"

[components.Text]
text = "표시할 텍스트"
font = "NotoSansCJKkr-Bold"
font_size = 32
alignment = "MiddleCenter"    # 정렬: UpperLeft, UpperCenter, MiddleCenter 등
color = [1.0, 1.0, 1.0, 1.0]  # RGBA
shadow = 0.0                  # 그림자 오프셋
```

#### image
```toml
object_type = "image"

[components.Image]
color = [1.0, 1.0, 1.0, 1.0]
uv_rect = [0.0, 0.0, 1.0, 1.0]  # UV 좌표 (x, y, width, height)
size = [256.0, 256.0]            # 픽셀 크기
surface = 0                      # 0=Opaque, 1=Transparent
enable_cutout = false            # 알파 컷아웃
cutout = 1.0                     # 컷아웃 임계값

[components.Resource]
resource_path = "image.png"      # resource/ 폴더 기준 상대경로
```

#### video
```toml
object_type = "video"

[components.Video]
color = [1.0, 1.0, 1.0, 1.0]
size = [848.0, 480.0]
auto_play = true
loop = true
volume = 1.0                     # 0.0 ~ 1.0
source_type = 0                  # 0=File, 1=Streaming
url_path = ""                    # 스트리밍 URL (source_type=1)

[components.Resource]
resource_path = "video.mp4"
```

#### model_3d
```toml
object_type = "model_3d"

[components.Model]
auto_play = true                 # 내장 애니메이션 자동 재생
loop = true

[components.Resource]
resource_path = "model.fbx"      # FBX, GLB, GLTF 지원
```

#### polygon_2d
```toml
object_type = "polygon_2d"

[components.Polygon2D]
corner_count = 5                 # 꼭지점 수 (3~)
fill_use = true
fill_color = [1.0, 1.0, 1.0, 1.0]
edge_use = true
edge_color = [1.0, 1.0, 1.0, 1.0]
edge_thick = 5.0
alpha = 1.0
preset = 0                       # 0=Custom, 1=Triangle, 2=Rectangle, 3=Pentagon, 4=Hexagon
```
#### shape
```toml
object_type = "shape"

[components.Shape]
resource_name = "arrow_right1"  # or "cylinder", "square", etc.
color = [1.0, 0.5, 0.0, 1.0]
height = 100.0                  # World Mode: cm 단위 | Screen Mode: px 단위
width = 100.0                   # World Mode: cm 단위 | Screen Mode: px 단위
depth = 100.0                   # World Mode: cm 단위 | Screen Mode: px 단위
```

**Shape 크기 단위**:
- **World Mode** (`screen_mode = 0`): cm 단위 (예: width=100 → 1m)
- **Screen Mode** (`screen_mode = 1`): px 단위 (예: width=250 → 250픽셀)
- 내부적으로 Screen Mode에서 자동 보정 적용 (0.1배)

**⚠️ Screen Mode에서 Shape 사용 시 주의**:
- Shape는 두께(depth)가 있는 3D 도형이므로, Screen Mode에서 사용할 경우 다른 UI 요소를 가릴 수 있습니다.
- 두께만큼 **Z 값을 적용**하여 배경으로 보내거나, 더 뒤쪽에 배치하세요.
- 예: `depth = 100.0` → `position = [0.0, 0.0, 51.0]` (두께의 절반보다 더 뒤로)

**사용 가능한 resource_name 목록**:

기본 도형:
- `cylinder`, `Square`, `rectangle`, `Diamond`, `triangle1`, `triangle2`, `pentagon`, `Hexagon`, `decagon`, `trapezoid`, `star`, `star1`, `star2`, `star3`, `star4`, `heart`

화살표:
- `arrow_right1`, `arrow_right2`, `arrow_right3`, `arrow_right4`, `arrow_right5`, `arrow_right6`, `arrow_right7`, `arrow_right8`
- `arrow_left1`, `arrow_left2`, `arrow_left3`, `arrow_left4`, `arrow_left5`, `arrow_left6`
- `arrow_up`, `arrow_up2`, `arrow_down`, `arrow_down2`
- `arrow_back`, `arrow_back2`, `arrow_diagonal`, `arrow_in`, `arrow_out`
- `arrow_updown`, `arrow_updown2`, `arrow_side`, `arrow_side2`
- `arrow_corner1`, `arrow_corner2`, `arrow_corner3`, `arrow_uturn`
- `arrow_change1`, `arrow_change2`, `arrow_change3`, `arrow_change4`, `arrow_change5`, `arrow_change6`
- `arrow_exchange`, `arrow_rotate`, `arrow_rotate2`

사람:
- `person`, `person_stand1`, `person_stand2`, `person_stand3`, `person_walk`, `person_round`
- `person_add`, `person_subtract`, `person_ban`, `person_check`, `person_protect`
- `person_setting`, `person_tag`, `person_time`, `person_two`, `person_write`

손 방향:
- `hand_up`, `hand_down`, `hand_left`, `hand_right`

UI/인터페이스:
- `check_round`, `check_square`, `plus1`, `plus2`, `plus3`, `plus4`
- `minus1`, `minus2`, `minus3`, `minus4`, `closed`, `opened`
- `play_1`, `play_2`, `play_3`, `pause`, `stop`, `stop_1`, `stop_2`
- `toggle_1`, `toggle_2`, `mute`, `sound`

정보/알림:
- `info`, `info_round`, `question`, `question_round1`, `question_round2`
- `alert`, `waning`, `wanring_triangle`, `warning_round`, `caution_car`

금지/제한:
- `ban`, `ban_round`, `ban_square`, `call_prohibition`, `talk_prohibition`
- `video_prohibition`, `fluid_prohibition`, `link_prohibition`

안전/보호:
- `helmet`, `glove`, `protect`, `safe`, `extinguisher`
- `biohazard`, `radioactive`, `radioactive_round`, `chemical`, `fire`, `bomb`, `dead`

도구/장비:
- `gear1`, `gear2`, `hammer`, `spanner`, `pen`, `ruller1`, `ruller2`
- `key`, `lock1`, `lock2`, `lock3`, `lock4`, `power`, `plug`

의료/건강:
- `hospital`, `patient`, `pain`, `heartbeat`, `glass`

산업/시설:
- `factory`, `electronic`, `oil`, `fluid`, `drum`, `tube`, `panel`
- `gauge`, `server1`, `server2`

통신/미디어:
- `call_prohibition`, `chat`, `chat_add`, `headset`, `loudspeaker`
- `antena`, `wifi`, `podcast`, `video_prohibition`

문서/파일:
- `book1`, `book2`, `book3`, `docs`, `paper`, `tag`

위치/내비게이션:
- `home`, `exit_1`, `exit_2`, `position1`, `position2`
- `pin1`, `pin2`, `pointer1`, `pointer2`, `light`

수학/기호:
- `equal`, `not_equal`, `division`, `multiple`, `persent1`, `persent2`, `persent_2`
- `quot1`, `quot2`

---

## 5. Transform과 좌표계

### 5.1 Screen Mode vs World Mode

**Screen Mode (screen_mode = 1)**:
- 화면 고정 UI 요소
- 2D 좌표계 (픽셀 단위)
- 카메라 회전/이동에 영향 받지 않음
- 사용 예: HUD, 버튼, 텍스트 오버레이

**World Mode (screen_mode = 0)**:
- 3D 공간에 배치
- 월드 좌표계 (센티미터 단위)
- VR/AR 환경에서 입체감
- 사용 예: 3D 모델, 공간에 배치된 패널

### 5.2 Transform 컴포넌트
```toml
[components.Transform]
screen_mode = 0                         # 0=World, 1=Screen
pivot = [0.5, 0.5]                      # 중심점 (0~1)
use_billboard = false                   # 카메라 항상 바라보기
is_reversed_billboard = false

position = [0.0, 0.0, 0.0]              # X, Y, Z (World Mode: cm 단위 | Screen Mode: px 단위)
rotation = [0.0, 0.0, 0.0]              # Euler angles (도)
scale = [1.0, 1.0, 1.0]                 # 배율
```

### 5.3 좌표계

**World 좌표계** (Unity 기준):
- **X축**: 오른쪽 (+), 왼쪽 (-)
- **Y축**: 위 (+), 아래 (-)
- **Z축**: 앞 (+), 뒤 (-)
- **단위**: 센티미터 (cm)

**Screen 좌표계**:
- **원점**: 화면 중심
- **X**: 오른쪽 (+픽셀)
- **Y**: 위 (+픽셀)
- **Anchors**: 9분할 고정점
  ```
  0=UpperLeft, 1=UpperCenter, 2=UpperRight
  3=MiddleLeft, 4=MiddleCenter, 5=MiddleRight
  6=LowerLeft, 7=LowerCenter, 8=LowerRight
  9=Custom
  ```

---

## 6. 리소스 관리

### 6.1 리소스 경로 규칙
```
Contents/<ContentName>/resource/
├── image.png           → resource_path = "image.png"
├── folder/
│   └── texture.jpg     → resource_path = "folder/texture.jpg"
└── models/
    └── chair.fbx       → resource_path = "models/chair.fbx"
```

**규칙**:
- 모든 경로는 `resource/` 폴더 기준 **상대 경로**
- 슬래시(`/`) 사용 (백슬래시 `\` 사용 금지)
- 한글 파일명 지원
- 파일은 직접 `resource/` 폴더에 배치

### 6.2 지원 포맷

| 타입 | 확장자 | 비고 |
|------|--------|------|
| 이미지 | `.png`, `.jpg`, `.jpeg` | 2K 텍스처 권장 |
| 비디오 | `.mp4`, `.mov` | 1080p 이하 권장 |
| 3D 모델 | `.fbx`, `.glb`, `.gltf` | FBX 권장 (애니메이션 포함 가능) |
| 오디오 | `.mp3`, `.wav`, `.ogg` | MP3 권장 (용량) |
| 스크립트 | `.cs` | C# MonoBehaviour 스크립트 |

### 6.3 Resource 컴포넌트
모든 리소스 사용 객체는 `components.Resource` 필요:
```toml
[components.Resource]
resource_path = "path/to/resource.ext"
```

**주의**: 리소스 파일이 실제로 존재하지 않으면 빌드 시 오류가 발생합니다.

### 6.4 스크립트 리소스 (User Scripts)

사용자 스크립트도 리소스로 취급됩니다:

```
Contents/<ContentName>/resource/
└── scripts/
    ├── MyScript.cs
    └── PlayerController.cs
```

#### 6.4.1 스크립트 작성 규칙

**⚠️ 중요: 파일명과 클래스명은 반드시 일치해야 합니다**

```csharp
// 파일명: MyScript.cs
// 클래스명: MyScript (일치해야 함!)

using UnityEngine;

public class MyScript : MonoBehaviour
{
    void Start()
    {
        Debug.Log("Hello from MyScript!");
    }
    
    void Update()
    {
        // 매 프레임 실행
    }
}
```

**규칙**:
- 모든 스크립트는 `MonoBehaviour`를 상속해야 함
- 파일명과 클래스명이 동일해야 함 (예: `PlayerController.cs` → `class PlayerController`)
- 하나의 파일에 하나의 public 클래스만 정의
- Unity API 사용 가능 (UnityEngine 네임스페이스)

#### 6.4.2 user_script 객체

스크립트를 컨텐츠에 등록하려면 `user_script` 타입 객체를 생성:

```toml
format_version = 1
id = "01JH1234ABCD5678EFGH0"
name = "MyScript"
active = true
object_type = "user_script"

[components.Core]
editing_color = [1.0, 1.0, 1.0, 1.0]

[components.UserScript]
resource_path = "scripts/MyScript.cs"   # resource/ 폴더 기준
class_name = ""                          # 비어있으면 파일명 사용
```

**필드 설명**:
- `resource_path`: 스크립트 파일 경로 (resource/ 폴더 기준)
- `class_name`: (선택) 클래스명 오버라이드. 비어있으면 파일명 사용

#### 6.4.3 스크립트를 객체에 할당

다른 객체에서 스크립트를 실행하려면 `ScriptProperty` 컴포넌트 추가:

```toml
# 이미지 객체에 스크립트 할당 예시
object_type = "image"

[components.Core]
editing_color = [1.0, 1.0, 1.0, 1.0]

[components.Image]
size = [256.0, 256.0]

[components.ScriptProperty]
script_ids = ["01JH1234ABCD5678EFGH0"]  # user_script 객체의 ID 목록
```

**참고**: 여러 스크립트를 하나의 객체에 할당 가능

#### 6.4.4 .ref 파일로 스크립트 참조

스크립트도 `.ref` 파일로 참조 가능:

```
# objects/<id>/my_script.ref
@resource/scripts/MyScript.cs
```

```toml
[components.UserScript]
resource_path = "my_script.ref"  # .ref 파일 참조
```

#### 6.4.5 스크립트 컴파일 검증

빌드 전에 스크립트 컴파일 오류를 확인하려면 `CompileScripts` 도구 사용:

- **Fail-fast (기본)**: 첫 번째 오류에서 빌드 중단
- 컴파일 오류 시 상세 진단 정보 제공 (줄 번호, 오류 코드)

**컴파일 오류 예시**:
```
MyScript(15,10): CS0103: The name 'invalidVariable' does not exist in the current context
```

---

## 7. 애니메이션 시스템

### 7.1 구조
```
Animation
└── AnimationClips[] (여러 클립)
    └── SequenceList[] (순차 실행)
        └── SequenceItems[] (동시 실행)
```

### 7.2 TOML 구조
```toml
[components.Animation]
clip_index = 0  # 재생할 클립 인덱스 (-1=없음)

[[components.Animation.animation_clips]]
clip_uuid = "guid-string"           # 고유 ID (자동 생성)
clip_name = "페이드인"
animation_play_mode = 0             # 0=Count, 1=Loop, 2=Pingpong, 3=ClampForever
repeat = 1

# 시퀀스 1 (순차 실행)
[[components.Animation.animation_clips.sequence_list]]

# 시퀀스 내 아이템들 (동시 실행)
[[components.Animation.animation_clips.sequence_list.sequence_items]]
path = 0                            # 0=Position, 1=Rotation, 2=Scale, 3=Color, 4=AnimationClip
delay = 0.0
duration = 1.0
pingpong = false
repeat_count = 1
start_vector = [0.0, 0.0, 0.0]     # Vector3 (Position/Rotation/Scale)
end_vector = [0.0, 1.0, 0.0]

# 시퀀스 2 (시퀀스 1 종료 후 실행)
[[components.Animation.animation_clips.sequence_list]]
# ...
```

**중요 개념**:
- **Clip**: 하나의 완전한 애니메이션 (예: "등장 효과")
- **Sequence**: 순차적으로 실행되는 단계 (예: 시퀀스1 → 시퀀스2 → 시퀀스3)
- **SequenceItem**: 하나의 시퀀스 내에서 **동시에** 실행되는 애니메이션 (예: 위치 이동 + 회전)

### 7.3 Sampling Path 타입
- `0`: **Position** - 위치 이동 (start_vector, end_vector)
- `1`: **Rotation** - 회전 (Euler angles)
- `2`: **Scale** - 크기 변화
- `3`: **Color** - 색상 변화 (start_color, end_color)
- `4`: **AnimationClip** - 3D 모델 내장 애니메이션 (clip_name)

### 7.4 재생 모드
- `Count` (0): 지정 횟수 반복 후 정지
- `Loop` (1): 무한 반복
- `Pingpong` (2): 왕복 반복
- `ClampForever` (3): 1회 재생 후 마지막 프레임 유지

---

## 8. 인터랙션 시스템

### 8.1 구조
```
Interaction
└── Interactions[] (여러 인터랙션)
    ├── Action: 트리거 (탭, 더블탭 등)
    └── InteractionObjects[] (실행할 동작들)
        ├── TargetObjectID: 대상 객체
        └── Function: 수행 기능 (이동, 재생 등)
```

### 8.2 TOML 구조
```toml
[[components.Interaction.interactions]]
action = 1                      # 1=Tap, 7=OnEnable 등
playback_end_id = ""
action_target_object_id = ""

[[components.Interaction.interactions.interaction_objects]]
target_object_id = "<GUID>"     # 동작 대상
delay = 0.0                     # 지연 시간 (초)
function = 4                    # 4=Play, 7=Show 등

[components.Interaction.interactions.interaction_objects.condition]
expression_data = ""            # 조건 표현식

[components.Interaction.interactions.interaction_objects.value]
expression_data = ""            # 전송 값
```

### 8.3 Action 타입 (트리거)

| 값 | 이름 | 설명 | 사용 예 |
|----|------|------|--------|
| `0` | None | 없음 | - |
| `1` | Tap | 클릭/터치 | 버튼, 인터랙티브 오브젝트 |
| `2` | DoubleTap | 더블 클릭 | 고급 상호작용 |
| `3` | LongPress | 길게 누르기 | 컨텍스트 메뉴 |
| `4` | PressStart | 누르기 시작 | 드래그 시작 |
| `5` | PressEnd | 누르기 종료 | 드래그 종료 |
| `6` | Receive | 신호 수신 | Send와 함께 사용 |
| `7` | OnEnable | 객체 활성화 시 | 자동 재생, 초기화 |
| `8` | CollisionEnter | 충돌 시작 | VR/AR 물리 상호작용 |
| `9` | CollisionExit | 충돌 종료 | VR/AR 물리 상호작용 |
| `10` | PlaybackEnd | 재생 종료 시 | 비디오/애니메이션 완료 후 동작 |

### 8.4 Function 타입 (동작)

| 값 | 이름 | 설명 | 적용 대상 | 비고 |
|----|------|------|----------|------|
| `0` | None | 없음 | - | - |
| `1` | MoveScene | 씬 전환 | Scene | target_object_id에 Scene GUID |
| `2` | PlayPause | 재생/일시정지 토글 | Video, Audio, Animation | - |
| `3` | PlayStop | 재생/정지 토글 | Video, Audio, Animation | - |
| `4` | Play | 재생 | Video, Audio, Animation | - |
| `5` | Pause | 일시정지 | Video, Audio, Animation | - |
| `6` | Stop | 정지 | Video, Audio, Animation | - |
| `7` | Show | 표시 (active=true) | 모든 객체 | - |
| `8` | Hide | 숨기기 (active=false) | 모든 객체 | - |
| `9` | Send | 신호 전송 | 모든 객체 | Value 표현식과 함께 사용 |
| `10` | Set | 속성 설정 | Text 등 | Value로 text 값 변경 |
| `11` | Browser | 웹 브라우저 열기 | - | Value에 URL |
| `12` | Snap | 스냅샷 촬영 | - | 화면 캡처 |

### 8.5 Expression 문법

**ExpressionData**는 조건(Condition)과 값(Value)을 동적으로 계산하는 문자열 표현식입니다.

#### 8.5.1 기본 연산자
```
비교: <, >, <=, >=, <>, =
논리: AND, OR, NOT
산술: +, -, *, /, %
문자열: IN, LIKE
```

#### 8.5.2 조건 표현식 예시
```toml
# Condition.expression_data 예시

# 1. 단순 비교
"5 > 3"                    # true
"10 <= 20"                 # true

# 2. 문자열 비교
"'Hello' = 'Hello'"        # true
"'Cat' LIKE 'C%'"          # true (시작 문자)

# 3. 값 참조 (Receive Action에서)
"{값} > 100"               # 수신한 값이 100보다 큰지
"{VALUE} = 'start'"        # 수신한 값이 'start'인지

# 4. 복합 조건
"({값} >= 0) AND ({값} <= 10)"  # 0~10 범위
```

#### 8.5.3 값 표현식 예시
```toml
# Value.expression_data 예시

# 1. 고정 값
"'Next Scene'"             # 문자열
"42"                       # 숫자

# 2. 계산
"10 + 5"                   # 15
"100 * 0.5"                # 50

# 3. 조건부 값 (삼항 연산자 스타일)
"IIF({값} > 50, 'High', 'Low')"
```

#### 8.5.4 함수
```toml
# 내장 함수 (제한적)
RandomRange(0, 100)        # 0~100 랜덤 정수
GetTextFromTextProperty(<GUID>)  # 다른 객체의 텍스트 가져오기
```

#### 8.5.5 Send/Receive 패턴
```toml
# 송신 객체 (버튼)
[[components.Interaction.interactions]]
action = 1  # Tap

[[components.Interaction.interactions.interaction_objects]]
target_object_id = "<Receiver_GUID>"
function = 9  # Send

[components.Interaction.interactions.interaction_objects.value]
expression_data = "'ButtonClicked'"  # 전송할 값

# 수신 객체 (텍스트)
[[components.Interaction.interactions]]
action = 6  # Receive

[[components.Interaction.interactions.interaction_objects]]
target_object_id = "<Self_GUID>"
function = 10  # Set

[components.Interaction.interactions.interaction_objects.condition]
expression_data = "{값} = 'ButtonClicked'"  # 조건 확인

[components.Interaction.interactions.interaction_objects.value]
expression_data = "'Button was clicked!'"  # 텍스트 변경
```

---

## 9. 실전 예제

**주의**: 다음 예제들은 기술적 참고용입니다. 각 예제는 독립적으로 동작하며, 실제 콘텐츠 제작 시 조합하여 사용합니다.

### 9.1 예제 1: 버튼으로 씬 전환
```toml
# 버튼 이미지 (씬1)
object_type = "image"

[components.Transform]
screen_mode = 1
position = [0.0, -200.0, 0.0]
scale = [1.0, 1.0, 1.0]

[[components.Interaction.interactions]]
action = 1  # Tap

[[components.Interaction.interactions.interaction_objects]]
target_object_id = "<Scene2_GUID>"
function = 1  # MoveScene
```

### 9.2 예제 2: 자동 재생 비디오 (페이드인)
```toml
object_type = "video"

[components.Video]
auto_play = true

[components.Animation]
clip_index = 0

[[components.Animation.animation_clips]]
clip_name = "페이드인"
animation_play_mode = 3  # ClampForever

[[components.Animation.animation_clips.sequence_list]]
[[components.Animation.animation_clips.sequence_list.sequence_items]]
path = 3  # Color
duration = 2.0
start_color = [1.0, 1.0, 1.0, 0.0]
end_color = [1.0, 1.0, 1.0, 1.0]
```

### 9.3 예제 3: 복합 애니메이션 (여러 시퀀스 체인)
```toml
object_type = "text"

[components.Animation]
clip_index = 0

[[components.Animation.animation_clips]]
clip_name = "입장 애니메이션"
animation_play_mode = 0  # Count (1회)
repeat = 1

# 시퀀스 1: 오른쪽에서 등장하며 회전
[[components.Animation.animation_clips.sequence_list]]
[[components.Animation.animation_clips.sequence_list.sequence_items]]
path = 0  # Position
duration = 1.0
delay = 0.0
start_vector = [100.0, 0.0, 0.0]
end_vector = [0.0, 0.0, 0.0]

[[components.Animation.animation_clips.sequence_list.sequence_items]]
path = 1  # Rotation
duration = 1.0
start_vector = [0.0, 0.0, 180.0]
end_vector = [0.0, 0.0, 0.0]

# 시퀀스 2: 크기 확대 후 축소
[[components.Animation.animation_clips.sequence_list]]
[[components.Animation.animation_clips.sequence_list.sequence_items]]
path = 2  # Scale
duration = 0.5
start_vector = [1.0, 1.0, 1.0]
end_vector = [1.3, 1.3, 1.0]

# 시퀀스 3: 원래 크기로
[[components.Animation.animation_clips.sequence_list]]
[[components.Animation.animation_clips.sequence_list.sequence_items]]
path = 2  # Scale
duration = 0.3
start_vector = [1.3, 1.3, 1.0]
end_vector = [1.0, 1.0, 1.0]
```
**실행 흐름**: 시퀀스 1 (위치+회전 1초) → 시퀀스 2 (확대 0.5초) → 시퀀스 3 (축소 0.3초)

### 9.4 예제 4: 3D 모델 내장 애니메이션 재생
```toml
object_type = "model_3d"

[components.Model]
auto_play = false  # 수동 제어
loop = true

[components.Resource]
resource_path = "models/character.fbx"  # 내장 애니메이션 포함 FBX

[components.Animation]
clip_index = 0

[[components.Animation.animation_clips]]
clip_name = "Walk"
animation_play_mode = 1  # Loop

[[components.Animation.animation_clips.sequence_list]]
[[components.Animation.animation_clips.sequence_list.sequence_items]]
path = 4  # AnimationClip (3D 모델 내장 애니메이션)
clip_name = "Walk"  # FBX 내부의 애니메이션 클립 이름
duration = 2.0
```
**참고**: `path = 4`는 3D 모델에 포함된 애니메이션 클립을 재생합니다. `clip_name`은 FBX 파일 내부의 실제 애니메이션 이름과 일치해야 합니다.

### 9.5 예제 5: 회전하는 3D 모델 (Transform 애니메이션)
```toml
object_type = "model_3d"

[components.Animation]
clip_index = 0

[[components.Animation.animation_clips]]
clip_name = "회전"
animation_play_mode = 1  # Loop

[[components.Animation.animation_clips.sequence_list]]
[[components.Animation.animation_clips.sequence_list.sequence_items]]
path = 1  # Rotation
duration = 5.0
start_vector = [0.0, 0.0, 0.0]
end_vector = [0.0, 360.0, 0.0]
```

---

## 10. TOML 포맷 규칙

### 10.1 배열 포맷
**올바른 형식** (공백 포함):
```toml
position = [ 0.0, 1.0, 2.0 ]
color = [ 1.0, 1.0, 1.0, 1.0 ]
children = [ "GUID1", "GUID2" ]
```

**잘못된 형식** (공백 없음 - 검증 실패 가능):
```toml
position = [0.0, 1.0, 2.0]       # ✗
color = [1.0,1.0,1.0,1.0]        # ✗
```

### 10.2 문자열 이스케이핑
```toml
# 개행 문자
text = "첫 줄\n두 번째 줄"  # \n 사용

# 따옴표
text = "He said \"Hello\""  # \" 사용

# 한글은 이스케이핑 불필요
text = "반도체 공정"  # ✓
```

### 10.3 GUID 형식
```toml
# 올바른 GUID
id = "3F2504E0-4F89-11D3-9A0C-0305E82C3301"  # 32자 16진수 + 하이픈

# 잘못된 형식
id = "3f2504e0-4f89-11d3-9a0c-0305e82c3301"  # ✗ 소문자
id = "GUID123"                                # ✗ 길이 부족
```

### 10.4 숫자 포맷
```toml
# 정수
font_size = 32

# 실수 (소수점 필수)
opacity = 1.0  # ✓
opacity = 1    # ✗ 검증 실패 가능

# 과학적 표기법 지원
value = 1e-3  # 0.001
```

### 10.5 부울 값
```toml
active = true   # 소문자 필수
loop = false

# 잘못된 형식
active = True   # ✗
active = TRUE   # ✗
```

---

## 11. Best Practices

### 10.1 GUID 생성
- **형식**: 32자 16진수 + 하이픈 (대문자 권장)
- **생성**: MCP의 `createnode` 도구가 자동 생성
- **중복 금지**: 콘텐츠 내 모든 ID는 고유해야 함
- **직접 생성 금지**: AI가 임의로 ID를 생성하지 말 것

### 11.2 계층 구조
- SceneGroup → Scene → Object 순서 **반드시 준수**
- Scene은 SceneGroup의 직계 자식만 가능
- 일반 객체는 Scene의 자식으로만 배치
- Scene 간 객체 공유 불가 (각 Scene은 독립적)

### 11.3 기본 씬 처리
- **CreateContent 시 자동 생성**: "Scene 1"이라는 빈 씬이 기본 생성됨
- **단일 씬 콘텐츠**: 기본 씬의 이름/내용을 변경하여 활용 (권장)
- **다중 씬 콘텐츠**: 
  - **권장**: 기본 씬 삭제 후 새 씬들 생성 (명확한 구조)
  - **비권장**: 기본 씬 유지 시 빈 씬이 처음에 표시됨 (사용자 혼란)
- **주의**: View는 빈 씬을 자동 스킵하지 않음 - 빈 화면으로 표시됨
- **삭제 방법**: `DeleteNodes`로 기본 씬 제거 후 원하는 씬 구조 생성

### 11.4 리소스 경로
- 항상 `resource/` 폴더 기준 상대경로
- 슬래시(`/`) 사용 (백슬래시 `\` 금지)
- 한글 파일명 지원하지만 영문 권장
- 대소문자 구분 (Windows에서는 무시되지만 다른 플랫폼 고려)

### 11.5 좌표계 선택 가이드
- **UI 요소** (버튼, 메뉴, HUD): Screen Mode + Anchors
- **3D 콘텐츠** (모델, 공간 배치): World Mode
- **혼합 가능**: 하나의 씬에서 동시 사용 (예: 3D 모델 + 2D UI)
- **VR/AR**: World Mode 권장 (몰입감)

### 11.6 성능 최적화
- **비디오**: 1080p 이하, H.264 코덱 권장
- **3D 모델**: 폴리곤 수 최소화 (모바일: ~10K, PC: ~50K)
- **이미지**: 2K 텍스처 권장, PNG 투명도 필요 시에만 사용
- **애니메이션**: 복잡한 시퀀스는 3~5개 이하로 제한

### 11.7 Interaction 설계
- **명확한 피드백**: 버튼 클릭 시 애니메이션 추가
- **Send/Receive**: 복잡한 로직 대신 단순한 신호 전달
- **OnEnable 활용**: 씬 진입 시 자동 실행에 유용
- **지연 시간**: `delay`로 순차 실행 효과

### 11.8 애니메이션 설계
- **시퀀스 분리**: 개별 동작을 별도 시퀀스로 (재사용성)
- **Duration 조정**: 자연스러운 속도 (너무 빠르면 어색함)
- **Loop 주의**: 무한 반복은 성능 영향 고려
- **Color 애니메이션**: 페이드 효과에 유용 (alpha 채널)

### 11.9 디버깅 팁
- **단계별 테스트**: 객체 하나씩 추가하며 확인
- **ValidateContent 활용**: 빌드 전 필수 실행
- **리소스 경로**: 빌드 전 파일 존재 여부 확인
- **GUID 확인**: tree.toml과 object.toml ID 일치 여부
- **TOML 포맷**: 배열 공백, 문자열 이스케이핑 확인
- **JSON 검증**: 빌드 후 .mars를 압축 해제하여 JSON 확인 가능

---

### 12 Scripting
dotnow/IL2CPP Script Limitations:
When writing scripts for dotnow interpreter on IL2CPP builds:
✅ DO:

* Use List<object> instead of List<MyClass>
* Use Dictionary<string, object> instead of generic custom types
* Use class instead of struct for custom data types
* Use for loops with explicit casting instead of foreach

❌ DON'T:

* Use List<CustomClass>, List<CustomStruct>
* Use custom generic types like Dictionary<int, MyClass>
* Use struct for types stored in collections

Reason: IL2CPP doesn't support runtime MakeGenericType for types not pre-generated at AOT compile time. User-defined generic instantiations will throw PlatformNotSupportedException.
Example:

// ❌ Bad - will fail on IL2CPP
private List<PathSegment> allPaths = new List<PathSegment>();

// ✅ Good - works on IL2CPP  
private List<object> allPaths = new List<object>();
PathSegment segment = (PathSegment)allPaths[i];