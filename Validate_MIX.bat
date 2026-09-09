@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

call "%~dp0config_loader.bat"

set "SCAN_DIR="

if not "%~1"=="" (
    "%~dp0third-party\CMDParse\CMDParse.exe" --mode:validate %* > "%TEMP%\validate_args.txt"
    for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\validate_args.txt") do (
        set "%%A=%%B"
    )
    del "%TEMP%\validate_args.txt" 2>nul
)

set "VALID=0"
set "INVALID=0"
set "TOTAL_FILES=0"

if not defined SCAN_DIR (
    echo ========================================
    echo MIX Archive Validation
    echo ========================================
    echo.
    echo Source:
    echo   1. Build\MOV (MO Vision)
    echo   2. Build\OriginalGames
    echo   3. Custom path
    echo.
    set /p "MODE=Select (1-3): "
    if "!MODE!"=="1" set "SCAN_DIR=Build\MOV"
    if "!MODE!"=="2" set "SCAN_DIR=Build\OriginalGames"
    if "!MODE!"=="3" (
        echo Enter path:
        set /p "SCAN_DIR= "
        set "SCAN_DIR=!SCAN_DIR:"=!"
    )
)

if not exist "!SCAN_DIR!\" (
    echo ERROR: Folder not found
    pause
    endlocal
    exit /b 1
)

echo.
echo Checking: !SCAN_DIR!
echo.

for /r "!SCAN_DIR!" %%F in (*.mix) do (
    set /a TOTAL_FILES+=1
    set "mix_file=%%F"
    set "mix_name=%%~nxF"
    set "mix_size=%%~zF"
    set "is_valid=1"
    
    if !mix_size! equ 0 (echo   EMPTY: !mix_name! & set "is_valid=0")
    if !mix_size! lss 14 (
        if !is_valid! equ 1 (echo   TOO SMALL: !mix_name! ^(!mix_size! bytes^) & set "is_valid=0")
    )
    if !is_valid! equ 1 (
        "%CCMIX_TOOL%" --verify --lmd --game=ra2 --mix="!mix_file!" >nul 2>nul
        if !errorlevel! neq 0 (echo   INVALID: !mix_name! & set "is_valid=0")
    )
    
    if !is_valid! equ 1 (
        set /a VALID+=1
        echo   OK: !mix_name! ^(!mix_size! bytes^)
    ) else (set /a INVALID+=1)
)

echo.
echo ========================================
echo RESULT
echo ========================================
echo Total MIX files: !TOTAL_FILES!
echo Valid: !VALID!
echo Invalid: !INVALID!
echo.

if !INVALID! equ 0 (echo All MIX files OK! & endlocal & exit /b 0) else (echo Issues found. Rebuild problematic archives. & endlocal & exit /b 1)
