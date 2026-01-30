@echo off
REM ============================================
REM Quick Guide Launcher
REM ============================================
REM This script opens important guides in VS Code
REM Run from the project root folder

setlocal enabledelayedexpansion

REM Determine project root
set "projectRoot=%~dp0"

REM List of important guides
echo.
echo ============================================
echo   poly-dream-electric Project Guides
echo ============================================
echo.
echo Select a guide to open:
echo.
echo   1. PowerShell Path Handling Guide (MOST IMPORTANT!)
echo   2. MarsMaker AI Guide
echo   3. Content Structure Guide  
echo   4. View Project Status
echo   5. Exit
echo.
set /p choice="Enter choice [1-5]: "

if "%choice%"=="1" (
    echo Opening PowerShell Path Handling Guide...
    code "!projectRoot!PowerShell_경로처리_가이드.md"
) else if "%choice%"=="2" (
    echo Opening MarsMaker AI Guide...
    code "!projectRoot!AGENTS.md"
) else if "%choice%"=="3" (
    echo Opening Content Structure Guide...
    code "!projectRoot!Intro_Content_Structure.md"
) else if "%choice%"=="4" (
    echo.
    echo ====== Project Status ======
    if exist "!projectRoot!Contents" (
        echo [OK] Contents folder found
        dir "!projectRoot!Contents\*.mars"
    ) else (
        echo [ERROR] Contents folder not found
    )
    echo.
    echo Guides available:
    if exist "!projectRoot!PowerShell_Path_Guide.md" echo [OK] PowerShell_Path_Guide.md
    if exist "!projectRoot!AGENTS.md" echo [OK] AGENTS.md
    if exist "!projectRoot!Intro_Content_Structure.md" echo [OK] Intro_Content_Structure.md
    echo.
) else (
    echo Exiting...
)

endlocal
