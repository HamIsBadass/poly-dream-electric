# FBX 모델 파일 수동 복사 가이드

## ✅ 완료됨
- resource/overview/images/에 6개 PNG 파일 복사 완료

## ⏳ 진행 중
- resource/overview/models/에 24개 FBX 파일 복사

---

## 🎯 FBX 파일 복사 방법

### 가장 간단한 방법: Windows Explorer 드래그앤드롭

#### 1단계: 두 개의 Explorer 창 열기
- **Window + E** (또는 Windows Explorer 두 번 열기)

#### 2단계: 좌측 창 - 원본 폴더
```
C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\3D
```
열기

#### 3단계: 우측 창 - 대상 폴더
```
C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric\resource\overview\models
```
열기

#### 4단계: FBX 파일 검색 및 선택

**좌측 창에서:**
1. Ctrl+F를 눌러 검색
2. "*.fbx" 입력
3. 모든 FBX 파일 표시됨

**파일 선택:**
1. 첫 번째 FBX 클릭
2. Ctrl+A로 모두 선택
3. 또는 Shift+클릭으로 범위 선택

#### 5단계: 드래그앤드롭
1. 선택한 파일들을 **우측 창으로 드래그**
2. 또는 **Ctrl+C(복사) → 우측 창에서 Ctrl+V(붙여넣기)**

---

## ⚡ 빠른 팁

### 검색으로 시간 단축
```
원본 폴더(좌측) 검색창에 "*.fbx" 입력
→ 모든 하위폴더의 FBX 파일이 자동으로 수집됨
→ 전체 선택 (Ctrl+A)
→ 드래그앤드롭
```

**예상 시간: 1-2분**

---

## ✅ 완료 확인

models 폴더에 다음과 같이 표시되어야 합니다:
```
resource\overview\models\
├── model_1.fbx
├── model_2.fbx
├── ...
└── model_24.fbx  (총 24개)
```

VS Code 터미널에서:
```powershell
ls resource\overview\models | Measure-Object
# Count: 24 가 나오면 성공!
```

---

## 💡 다른 방법: PowerShell 직접 입력

VS Code Terminal에서 다음 명령 한 줄씩 입력:

```powershell
# 1단계: 경로 저장
$src = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\3D"
$dst = "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric\resource\overview\models"

# 2단계: 복사
Get-ChildItem $src -Filter "*.fbx" -Recurse | % {Copy-Item $_.FullName $dst -Force}

# 3단계: 확인
ls $dst | Measure-Object
```

---

## 📋 체크리스트

- [ ] 원본 폴더 열기: `...\05_디자인\3D`
- [ ] 대상 폴더 열기: `...\resource\overview\models`
- [ ] FBX 파일 검색/선택
- [ ] 드래그앤드롭 또는 복사/붙여넣기
- [ ] 24개 파일 복사 확인

---

복사 완료 후 "완료됨"이라고 말씀해주세요!
