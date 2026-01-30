"""
리소스 복사 및 overview.mars 구성 계획

현재 상황:
- ✅ PowerShell 영문 경로명 변경 완료
- ⏳ 외부 리소스 복사 (Terminal 제약)
- ⏳ overview.mars 오브젝트 추가

전략:
1. Python을 사용해 파일 복사
2. overview 리소스 메타데이터 생성
3. overview.mars에 필요한 오브젝트 정의
"""

import shutil
import os
from pathlib import Path

# 경로 정의 (절대 경로 사용)
img_src = r"C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\2D\01_수배전개요"
mdl_src = r"C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\3D"
base_dest = r"C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric\resource\asset_01_overview"

def copy_resources():
    """외부 리소스를 workspace로 복사"""
    
    # 폴더 생성
    for folder in [base_dest, f"{base_dest}\\images", f"{base_dest}\\models"]:
        Path(folder).mkdir(parents=True, exist_ok=True)
    
    # 2D 이미지 복사
    print("=" * 50)
    print("Copying 2D Images")
    print("=" * 50)
    if Path(img_src).exists():
        for file in Path(img_src).glob("*"):
            if file.is_file():
                dest = Path(base_dest) / "images" / file.name
                shutil.copy2(file, dest)
                print(f"✓ {file.name}")
        img_count = len(list(Path(base_dest).joinpath("images").glob("*")))
        print(f"\nTotal images: {img_count}")
    else:
        print(f"❌ Source not found: {img_src}")
    
    # 3D 모델 복사
    print("\n" + "=" * 50)
    print("Copying 3D Models")
    print("=" * 50)
    if Path(mdl_src).exists():
        fbx_count = 0
        for file in Path(mdl_src).rglob("*.fbx"):
            dest = Path(base_dest) / "models" / file.name
            shutil.copy2(file, dest)
            fbx_count += 1
        print(f"✓ {fbx_count} FBX files copied")
    else:
        print(f"❌ Source not found: {mdl_src}")
    
    # 최종 확인
    print("\n" + "=" * 50)
    print("Final Structure")
    print("=" * 50)
    for root, dirs, files in os.walk(base_dest):
        level = root.replace(base_dest, '').count(os.sep)
        indent = '  ' * level
        print(f"{indent}{os.path.basename(root)}/")
        subindent = '  ' * (level + 1)
        for file in files:
            print(f"{subindent}{file}")

if __name__ == "__main__":
    copy_resources()
