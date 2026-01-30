# Overview Mars 리소스 설정 가이드

## 📋 상황
- **Mars 파일**: `Contents/수배전반개요.mars` (기본 구조만 있음)
- **외부 리소스 위치**:
  - 2D 이미지: `..\..\05_디자인\2D\01_수배전개요\` (6개 파일)
  - 3D 모델: `..\..\05_디자인\3D\` (24개 FBX 파일, 하위 폴더 포함)
- **대상 폴더**: `resource\overview\{images,models,videos,audio}`

## 🚀 단계 1: 리소스 파일 복사

### 방법 A: Windows Explorer (수동)
1. Windows Explorer 열기
2. 다음 경로 열기:
   ```
   C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\2D\01_수배전개요
   ```
3. **모든 파일 선택** (Ctrl+A) → 복사 (Ctrl+C)
4. 다음 경로로 이동:
   ```
   poly-dream-electric\resource\overview\images
   ```
5. 붙여넣기 (Ctrl+V)

6. 마찬가지로 **3D 모델** 복사:
   - 원본: `..\..\05_디자인\3D` (하위의 모든 *.fbx 파일)
   - 대상: `poly-dream-electric\resource\overview\models`

### 방법 B: PowerShell (단일 명령)
VS Code Terminal에서 다음 명령 실행:
\`\`\`powershell
# 전체 명령어 (한 줄로 붙여넣기)
$img="C:\\Users\\VIRNECT\\Downloads\\[999999-99][폴리텍전기콘텐츠프로젝트]\\05_디자인\\2D\\01_수배전개요"; $mdl="C:\\Users\\VIRNECT\\Downloads\\[999999-99][폴리텍전기콘텐츠프로젝트]\\05_디자인\\3D"; Get-ChildItem $img -File|%{cp $_.FullName resource\\overview\\images\\};Get-ChildItem $mdl -Filter *.fbx -Recurse|%{cp $_.FullName resource\\overview\\models\\}; Write-Host "Done"
\`\`\`

## 🔍 단계 2: 복사 확인

파일이 제대로 복사되었는지 확인:
\`\`\`powershell
ls resource\\overview -Recurse | where {$_.PSIsContainer -eq $false} | measure
\`\`\`

예상 결과: **약 30개 파일** (6 이미지 + 24 모델)

## 📝 단계 3: 정리

복사 후:
- `resource/overview/images/` → 6개 이미지 파일
- `resource/overview/models/` → 24개 FBX 파일
- `resource/overview/videos/` → (빈 상태)
- `resource/overview/audio/` → (빈 상태)

## ✅ 완료 후

리소스 복사 완료 후, 다음 단계로:
1. 수배전반개요.mars에 오브젝트 생성
2. 리소스 참조 설정
3. 미리보기 구조 생성
