"""
FBX 파일 평탄화 스크립트

현재:
resource/overview/models/00.test/01_LBS/*.fbx
resource/overview/models/00.test/02_MOF/*.fbx
...

목표:
resource/overview/models/file1.fbx
resource/overview/models/file2.fbx
...
"""

import os
import shutil
from pathlib import Path

# 경로
base_path = r"C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_개발\poly-dream-electric\resource\asset_01_overview\models"

print("=" * 60)
print("FBX 파일 평탄화 진행 중")
print("=" * 60)

# 모든 FBX 파일 찾기
fbx_files = list(Path(base_path).rglob("*.fbx"))
print(f"\n찾은 FBX 파일: {len(fbx_files)}개\n")

# 파일 이동 (중복 방지)
moved_count = 0
for fbx_file in fbx_files:
    # 대상 경로
    dest_path = Path(base_path) / fbx_file.name
    
    # 이미 models 폴더 직하에 있으면 스킵
    if fbx_file.parent == Path(base_path):
        print(f"✓ 이미 위치: {fbx_file.name}")
        moved_count += 1
        continue
    
    # 중복 파일명 처리
    if dest_path.exists():
        # 파일명 변경: file.fbx → file_copy.fbx
        name, ext = fbx_file.stem, fbx_file.suffix
        new_name = f"{name}_copy{ext}"
        dest_path = Path(base_path) / new_name
        print(f"→ {fbx_file.name} 이름 변경: {new_name}")
    
    # 파일 이동
    try:
        shutil.move(str(fbx_file), str(dest_path))
        print(f"✓ 이동: {fbx_file.name}")
        moved_count += 1
    except Exception as e:
        print(f"✗ 실패: {fbx_file.name} - {e}")

print(f"\n총 {moved_count}개 파일 이동 완료")

# 빈 폴더 정리
print("\n빈 폴더 정리 중...")
for root, dirs, files in os.walk(base_path, topdown=False):
    for dir_name in dirs:
        dir_path = os.path.join(root, dir_name)
        try:
            if not os.listdir(dir_path):  # 폴더가 비어있으면
                os.rmdir(dir_path)
                print(f"삭제: {dir_name}")
        except Exception as e:
            print(f"정리 실패: {dir_name} - {e}")

print("\n" + "=" * 60)
print("평탄화 완료!")
print("=" * 60)

# 최종 확인
final_fbx = list(Path(base_path).glob("*.fbx"))
print(f"\n최종 FBX 파일 개수: {len(final_fbx)}")
print("\n파일 목록 (처음 10개):")
for i, f in enumerate(final_fbx[:10]):
    print(f"  {i+1}. {f.name}")
if len(final_fbx) > 10:
    print(f"  ... 그 외 {len(final_fbx) - 10}개")
