#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import shutil
from pathlib import Path

# 경로 정의
img_src = r"C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\2D\01_수배전개요"
mdl_src = r"C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\05_디자인\3D"
base_dest = r"resource\asset_01_overview"

# 폴더 생성
for folder in [base_dest, f"{base_dest}/images", f"{base_dest}/models", f"{base_dest}/videos", f"{base_dest}/audio"]:
    Path(folder).mkdir(parents=True, exist_ok=True)
    print(f"✓ Created: {folder}")

# 2D 이미지 복사
print(f"\nCopying images from {img_src}...")
for file in Path(img_src).glob("*"):
    if file.is_file():
        dest = Path(base_dest) / "images" / file.name
        shutil.copy2(file, dest)
        print(f"  ✓ {file.name}")

# 3D 모델 복사
print(f"\nCopying FBX models from {mdl_src}...")
fbx_count = 0
for file in Path(mdl_src).rglob("*.fbx"):
    dest = Path(base_dest) / "models" / file.name
    shutil.copy2(file, dest)
    fbx_count += 1

print(f"  ✓ {fbx_count} FBX files copied")

# 확인
print("\nResource structure created:")
for root, dirs, files in os.walk(base_dest):
    level = root.replace(base_dest, '').count(os.sep)
    indent = ' ' * 2 * level
    print(f'{indent}{os.path.basename(root)}/')
    subindent = ' ' * 2 * (level + 1)
    for file in files[:3]:  # 처음 3개만 표시
        print(f'{subindent}{file}')
    if len(files) > 3:
        print(f'{subindent}... and {len(files)-3} more')

print("\nDone!")
