@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

call "%~dp0config_loader.bat"

set "INPUT="
set "OUTPUT="
set "DRY_RUN=0"
set "BITRATE="
set "RESOLUTION="
set "CLI_MODE=0"

if not "%~1"=="" (
    "%~dp0third-party\CMDParse\CMDParse.exe" --mode:resolution %* > "%TEMP%\res_args.txt"
    for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\res_args.txt") do (
        set "%%A=%%B"
    )
    del "%TEMP%\res_args.txt" 2>nul
    if defined INPUT set "CLI_MODE=1"
)

if "!CLI_MODE!"=="1" goto :cli_mode

if not exist "%NEW_RAD%" (
    echo ERROR: %NEW_RAD% not found
    pause
    endlocal
    exit /b 1
)

echo Work mode:
echo   1. Convert one BIK file to new resolution
echo   2. Convert all BIK in folder to new resolution
echo   3. Convert MP4 to BIK with custom resolution
echo.
set /p "MODE=Select mode (1-3): "

if "!MODE!"=="1" goto :single_file
if "!MODE!"=="2" goto :batch_dir
if "!MODE!"=="3" goto :mp4_convert
echo Invalid choice.
pause
endlocal
exit /b 1

:cli_mode
set "BIK_PATH=!INPUT!"
if not exist "!BIK_PATH!" (echo ERROR: File not found: !BIK_PATH! & endlocal & exit /b 1)

for %%I in ("!BIK_PATH!") do set "BIK_EXT=%%~xI"
if /i "!BIK_EXT!"==".mp4" goto :cli_mp4

if not defined RESOLUTION (echo ERROR: -RES:WIDTHxHEIGHT required & endlocal & exit /b 1)
for /f "tokens=1,2 delims=x" %%A in ("!RESOLUTION!") do (
    set "NEW_WIDTH=%%A"
    set "NEW_HEIGHT=%%B"
)
if not defined NEW_WIDTH (echo ERROR: Invalid resolution format & endlocal & exit /b 1)
if not defined NEW_HEIGHT (echo ERROR: Invalid resolution format - use WIDTHxHEIGHT & endlocal & exit /b 1)
if not defined BITRATE (echo ERROR: -BITRATE:bps required & endlocal & exit /b 1)
set "CHECK_BITRATE=!BITRATE!"
call :validate_bitrate
if !errorlevel! neq 0 (endlocal & exit /b 1)

for %%I in ("!BIK_PATH!") do set "BIK_NAME=%%~dpnI"
set "OUT_FILE=!BIK_NAME!_!NEW_WIDTH!x!NEW_HEIGHT!.bik"
set "RES_ARG=/(!NEW_WIDTH! /)!NEW_HEIGHT!"

echo Converting: !BIK_PATH!
echo New resolution: !NEW_WIDTH!x!NEW_HEIGHT!, !BITRATE! bps
echo Output: !OUT_FILE!

if "!DRY_RUN!"=="1" (
    echo [DRY_RUN] Skipping conversion
) else (
    set "_tool_out=%TEMP%\resconv_out.tmp"
    if "!HIDE_WINDOW!"=="1" (
        cscript //nologo "%RUN_HIDDEN%" "%NEW_RAD%" Binkc "!BIK_PATH!" "!OUT_FILE!" /N-1 !RES_ARG! /v100 /:0 /D!BITRATE! /L0 /O /Z0 /# >"!_tool_out!" 2>&1
    ) else (
        "%NEW_RAD%" Binkc "!BIK_PATH!" "!OUT_FILE!" /N-1 !RES_ARG! /v100 /:0 /D!BITRATE! /L0 /O /Z0 /# >"!_tool_out!" 2>&1
    )
    if !errorlevel! equ 0 (
        set "OUT_SIZE=0"
        for %%I in ("!OUT_FILE!") do set "OUT_SIZE=%%~zI"
        if !OUT_SIZE! gtr 0 (echo OK: !OUT_SIZE! bytes) else (echo ERROR: empty file & del "!OUT_FILE!" 2>nul)
    ) else (
        echo    [ERROR] Binkc failed
        type "!_tool_out!" 2>nul
    )
    del "!_tool_out!" 2>nul
)
endlocal
exit /b 0

:cli_mp4
if not defined RESOLUTION (echo ERROR: -RES:WIDTHxHEIGHT required & endlocal & exit /b 1)
for /f "tokens=1,2 delims=x" %%A in ("!RESOLUTION!") do (
    set "NEW_WIDTH=%%A"
    set "NEW_HEIGHT=%%B"
)
if not defined NEW_WIDTH (echo ERROR: Invalid resolution format & endlocal & exit /b 1)
if not defined NEW_HEIGHT (echo ERROR: Invalid resolution format - use WIDTHxHEIGHT & endlocal & exit /b 1)
if not defined BITRATE (echo ERROR: -BITRATE:bps required & endlocal & exit /b 1)
set "CHECK_BITRATE=!BITRATE!"
call :validate_bitrate
if !errorlevel! neq 0 (endlocal & exit /b 1)

for %%I in ("!BIK_PATH!") do set "MP4_NAME=%%~dpnI"
set "OUT_FILE=!MP4_NAME!.bik"
set "RES_ARG=/(!NEW_WIDTH! /)!NEW_HEIGHT!"

echo Converting: !BIK_PATH!
echo Resolution: !NEW_WIDTH!x!NEW_HEIGHT!, !BITRATE! bps
echo Output: !OUT_FILE!

if "!DRY_RUN!"=="1" (
    echo [DRY_RUN] Skipping conversion
) else (
    set "_tool_out=%TEMP%\resconv_out.tmp"
    if "!HIDE_WINDOW!"=="1" (
        cscript //nologo "%RUN_HIDDEN%" "%NEW_RAD%" Binkc "!BIK_PATH!" "!OUT_FILE!" /N-1 !RES_ARG! /v100 /:0 /D!BITRATE! /L0 /O /Z0 /# >"!_tool_out!" 2>&1
    ) else (
        "%NEW_RAD%" Binkc "!BIK_PATH!" "!OUT_FILE!" /N-1 !RES_ARG! /v100 /:0 /D!BITRATE! /L0 /O /Z0 /# >"!_tool_out!" 2>&1
    )
    if !errorlevel! equ 0 (
        set "OUT_SIZE=0"
        for %%I in ("!OUT_FILE!") do set "OUT_SIZE=%%~zI"
        if !OUT_SIZE! gtr 0 (echo OK: !OUT_SIZE! bytes) else (echo ERROR: empty file & del "!OUT_FILE!" 2>nul)
    ) else (
        echo    [ERROR] Binkc failed
        type "!_tool_out!" 2>nul
        del "!OUT_FILE!" 2>nul
    )
    del "!_tool_out!" 2>nul
)
endlocal
exit /b 0

:single_file
echo.
echo Enter path to BIK file:
set /p "BIK_PATH= "
set "BIK_PATH=!BIK_PATH:"=!"

if not exist "!BIK_PATH!" (echo ERROR: File not found & pause & endlocal & exit /b 1)

echo.
echo Enter new resolution:
echo   Format: WIDTHxHEIGHT
echo   Examples: 1280x720, 1920x1080, 800x600
echo.
set /p "NEW_RES=Resolution: "

for /f "tokens=1,2 delims=x" %%A in ("!NEW_RES!") do (
    set "NEW_WIDTH=%%A"
    set "NEW_HEIGHT=%%B"
)

if not defined NEW_WIDTH (echo ERROR: Invalid resolution format & pause & endlocal & exit /b 1)
if not defined NEW_HEIGHT (echo ERROR: Invalid resolution format - use WIDTHxHEIGHT & pause & endlocal & exit /b 1)

echo.
echo Enter bitrate (bps):
echo   Max safe: 1150000 (Bink 1.0 hard limit: 1200000)
echo   Examples: 400000, 600000, 900000, 1150000
echo.
set /p "NEW_BITRATE=Bitrate: "
set "CHECK_BITRATE=!NEW_BITRATE!"
call :validate_bitrate
if !errorlevel! neq 0 (pause & endlocal & exit /b 1)

for %%I in ("!BIK_PATH!") do set "BIK_NAME=%%~dpnI"
set "OUT_FILE=!BIK_NAME!_!NEW_WIDTH!x!NEW_HEIGHT!.bik"
set "RES_ARG=/(!NEW_WIDTH! /)!NEW_HEIGHT!"

echo.
echo Converting: !BIK_PATH!
echo New resolution: !NEW_WIDTH!x!NEW_HEIGHT!, !NEW_BITRATE! bps
echo Output: !OUT_FILE!
echo.

if "!DRY_RUN!"=="1" (
    echo [DRY_RUN] Skipping conversion
) else (
    if "!HIDE_WINDOW!"=="1" (
        cscript //nologo "%RUN_HIDDEN%" "%NEW_RAD%" Binkc "!BIK_PATH!" "!OUT_FILE!" /N-1 !RES_ARG! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /# >nul 2>&1
    ) else (
        "%NEW_RAD%" Binkc "!BIK_PATH!" "!OUT_FILE!" /N-1 !RES_ARG! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /# >nul 2>&1
    )

    if !errorlevel! equ 0 (
        set "OUT_SIZE=0"
        for %%I in ("!OUT_FILE!") do set "OUT_SIZE=%%~zI"
        if !OUT_SIZE! gtr 0 (echo OK: !OUT_SIZE! bytes) else (echo ERROR: empty file & del "!OUT_FILE!" 2>nul)
    ) else (echo ERROR: conversion failed & del "!OUT_FILE!" 2>nul)
)

pause
endlocal
exit /b 0

:batch_dir
echo.
echo Enter path to folder with BIK files:
set /p "SRC_DIR= "
set "SRC_DIR=!SRC_DIR:"=!"

if not exist "!SRC_DIR!\" (echo ERROR: Folder not found & pause & endlocal & exit /b 1)

echo.
echo Enter new resolution:
set /p "NEW_RES=Resolution (WIDTHxHEIGHT): "

for /f "tokens=1,2 delims=x" %%A in ("!NEW_RES!") do (
    set "NEW_WIDTH=%%A"
    set "NEW_HEIGHT=%%B"
)

if not defined NEW_WIDTH (echo ERROR: Invalid resolution format ( WIDTHxHEIGHT ) & pause & endlocal & exit /b 1)
if not defined NEW_HEIGHT (echo ERROR: Invalid resolution format ( WIDTHxHEIGHT ) & pause & endlocal & exit /b 1)

echo.
echo Enter bitrate (bps):
echo   Max safe: 1150000 (Bink 1.0 hard limit: 1200000)
echo.
set /p "NEW_BITRATE=Bitrate: "
set "CHECK_BITRATE=!NEW_BITRATE!"
call :validate_bitrate
if !errorlevel! neq 0 (pause & endlocal & exit /b 1)

set "OUT_DIR=!SRC_DIR!\_!NEW_WIDTH!x!NEW_HEIGHT!"
if not exist "!OUT_DIR!" mkdir "!OUT_DIR!"

echo.
echo Input: !SRC_DIR!
echo Output: !OUT_DIR!
echo.

set "TOTAL=0"
set "DONE=0"

for %%F in ("!SRC_DIR!\*.bik") do set /a TOTAL+=1

echo Found !TOTAL! BIK files
echo.

set "RES_ARG=/(!NEW_WIDTH! /)!NEW_HEIGHT!"
set "IDX=0"
for %%F in ("!SRC_DIR!\*.bik") do (
    set /a IDX+=1
    set "BIK_NAME=%%~nF"
    echo [!IDX!/!TOTAL!] Converting: !BIK_NAME!.bik
    if "!DRY_RUN!"=="1" (
        echo    [DRY_RUN] Skipping
    ) else (
        if "!HIDE_WINDOW!"=="1" (
            cscript //nologo "%RUN_HIDDEN%" "%NEW_RAD%" Binkc "%%F" "!OUT_DIR!\!BIK_NAME!.bik" /N-1 !RES_ARG! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /# >nul 2>&1
        ) else (
            "%NEW_RAD%" Binkc "%%F" "!OUT_DIR!\!BIK_NAME!.bik" /N-1 !RES_ARG! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /# >nul 2>&1
        )
        if !errorlevel! equ 0 (
            set "OUT_SIZE=0"
            for %%I in ("!OUT_DIR!\!BIK_NAME!.bik") do set "OUT_SIZE=%%~zI"
            if !OUT_SIZE! gtr 0 (echo    OK & set /a DONE+=1) else (echo    ERROR: empty file & del "!OUT_DIR!\!BIK_NAME!.bik" 2>nul)
        ) else (echo    ERROR: conversion failed & del "!OUT_DIR!\!BIK_NAME!.bik" 2>nul)
    )
)

echo.
echo Done: !DONE!/!TOTAL!
echo Results in: !OUT_DIR!
pause
endlocal
exit /b 0

:mp4_convert
echo.
echo Enter path to MP4 file:
set /p "MP4_PATH= "
set "MP4_PATH=!MP4_PATH:"=!"

if not exist "!MP4_PATH!" (echo ERROR: File not found & pause & endlocal & exit /b 1)

echo.
echo Enter resolution:
set /p "NEW_RES=Resolution (WIDTHxHEIGHT): "

for /f "tokens=1,2 delims=x" %%A in ("!NEW_RES!") do (
    set "NEW_WIDTH=%%A"
    set "NEW_HEIGHT=%%B"
)

if not defined NEW_WIDTH (echo ERROR: Invalid resolution format ( WIDTHxHEIGHT ) & pause & endlocal & exit /b 1)
if not defined NEW_HEIGHT (echo ERROR: Invalid resolution format ( WIDTHxHEIGHT ) & pause & endlocal & exit /b 1)

echo.
echo Enter bitrate (bps):
echo   Max safe: 1150000 (Bink 1.0 hard limit: 1200000)
echo.
set /p "NEW_BITRATE=Bitrate: "
set "CHECK_BITRATE=!NEW_BITRATE!"
call :validate_bitrate
if !errorlevel! neq 0 (pause & endlocal & exit /b 1)

for %%I in ("!MP4_PATH!") do set "MP4_NAME=%%~dpnI"
set "OUT_FILE=!MP4_NAME!.bik"
set "RES_ARG=/(!NEW_WIDTH! /)!NEW_HEIGHT!"

echo.
echo Converting: !MP4_PATH!
echo Resolution: !NEW_WIDTH!x!NEW_HEIGHT!, !NEW_BITRATE! bps
echo Output: !OUT_FILE!
echo.

if "!DRY_RUN!"=="1" (
    echo [DRY_RUN] Skipping conversion
) else (
    if "!HIDE_WINDOW!"=="1" (
        cscript //nologo "%RUN_HIDDEN%" "%NEW_RAD%" Binkc "!MP4_PATH!" "!OUT_FILE!" /N-1 !RES_ARG! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /# >nul 2>&1
    ) else (
        "%NEW_RAD%" Binkc "!MP4_PATH!" "!OUT_FILE!" /N-1 !RES_ARG! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /# >nul 2>&1
    )

    if !errorlevel! equ 0 (
        set "OUT_SIZE=0"
        for %%I in ("!OUT_FILE!") do set "OUT_SIZE=%%~zI"
        if !OUT_SIZE! gtr 0 (echo OK: !OUT_SIZE! bytes) else (echo ERROR: empty file & del "!OUT_FILE!" 2>nul)
    ) else (echo ERROR: conversion failed & del "!OUT_FILE!" 2>nul)
)

pause
endlocal
exit /b 0

:validate_bitrate
if not defined CHECK_BITRATE (exit /b 1)
set /a "CHECK_BITRATE_NUM=CHECK_BITRATE" 2>nul
if !errorlevel! neq 0 (echo ERROR: Bitrate must be a number & exit /b 1)
if !CHECK_BITRATE! leq 0 (echo ERROR: Bitrate must be positive & exit /b 1)
if !CHECK_BITRATE! gtr 1200000 (echo ERROR: Bitrate !CHECK_BITRATE! exceeds Bink 1.0 hard limit of 1200000 bps & echo Video will drop frames during playback & echo Recommended max: 1150000 bps (accounts for VBR fluctuation) & exit /b 1)
exit /b 0
