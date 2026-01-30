@echo off
cd /d "C:\Users\VIRNECT\Downloads\[999999-99][폴리텍전기콘텐츠프로젝트]\06_Development\poly-dream-electric"

REM 2D images 복사
for %%F in ("..\..\05_디자인\2D\01_수배전개요\*.*") do (
    copy "%%F" "resource\asset_01_overview\images\" /Y >nul
    echo Copied: %%~nF
)

REM 3D FBX 모델 복사
for /R "..\..\05_디자인\3D" %%F in (*.fbx) do (
    copy "%%F" "resource\asset_01_overview\models\" /Y >nul
    echo Copied: %%~nF
)

echo.
echo All resources copied successfully!
pause
