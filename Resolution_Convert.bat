@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

call "%~dp0config_loader.bat"

set "INPUT="
set "OUTPUT="
set "DRY_RUN=0"

if not "%~1"=="" (
    "%~dp0third-party\CMDParse\CMDParse.exe" --mode:resolution %* > "%TEMP%\res_args.txt"
    for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\res_args.txt") do (
        set "%%A=%%B"
    )
    del "%TEMP%\res_args.txt" 2>nul
)

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

echo.
echo Enter bitrate (bps):
echo   Examples: 400000, 600000, 900000, 1150000
echo.
set /p "NEW_BITRATE=Bitrate: "

for %%I in ("!BIK_PATH!") do set "BIK_NAME=%%~dpnI"
set "OUT_FILE=!BIK_NAME!_!NEW_WIDTH!x!NEW_HEIGHT!.bik"

echo.
echo Converting: !BIK_PATH!
echo New resolution: !NEW_WIDTH!x!NEW_HEIGHT!, !NEW_BITRATE! bps
echo Output: !OUT_FILE!
echo.

powershell -NoProfile -Command "Start-Process -FilePath '%NEW_RAD%' -ArgumentList 'Binkc \"!BIK_PATH!\" \"!OUT_FILE!\" /N-1 /(!NEW_WIDTH! /)!NEW_HEIGHT! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /#' -WindowStyle Hidden -Wait"

if !errorlevel! equ 0 (
    set "OUT_SIZE=0"
    for %%I in ("!OUT_FILE!") do set "OUT_SIZE=%%~zI"
    if !OUT_SIZE! gtr 0 (echo OK: !OUT_SIZE! bytes) else (echo ERROR: empty file & del "!OUT_FILE!" 2>nul)
) else (echo ERROR: conversion failed)

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
set /p "NEW_BITRATE=Bitrate (bps): "

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

set "IDX=0"
for %%F in ("!SRC_DIR!\*.bik") do (
    set /a IDX+=1
    set "BIK_NAME=%%~nF"
    echo [!IDX!/!TOTAL!] Converting: !BIK_NAME!.bik
    powershell -NoProfile -Command "Start-Process -FilePath '%NEW_RAD%' -ArgumentList 'Binkc \"%%F\" \"!OUT_DIR!\!BIK_NAME!.bik\" /N-1 /(!NEW_WIDTH! /)!NEW_HEIGHT! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /#' -WindowStyle Hidden -Wait"
    if !errorlevel! equ 0 (
        set "OUT_SIZE=0"
        for %%I in ("!OUT_DIR!\!BIK_NAME!.bik") do set "OUT_SIZE=%%~zI"
        if !OUT_SIZE! gtr 0 (echo    OK & set /a DONE+=1) else (echo    ERROR: empty file & del "!OUT_DIR!\!BIK_NAME!.bik" 2>nul)
    ) else (echo    ERROR: conversion failed)
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
set /p "NEW_BITRATE=Bitrate (bps): "

for %%I in ("!MP4_PATH!") do set "MP4_NAME=%%~dpnI"
set "OUT_FILE=!MP4_NAME!.bik"

echo.
echo Converting: !MP4_PATH!
echo Resolution: !NEW_WIDTH!x!NEW_HEIGHT!, !NEW_BITRATE! bps
echo Output: !OUT_FILE!
echo.

powershell -NoProfile -Command "Start-Process -FilePath '%NEW_RAD%' -ArgumentList 'Binkc \"!MP4_PATH!\" \"!OUT_FILE!\" /N-1 /(!NEW_WIDTH! /)!NEW_HEIGHT! /v100 /:0 /D!NEW_BITRATE! /L0 /O /Z0 /#' -WindowStyle Hidden -Wait"

if !errorlevel! equ 0 (
    set "OUT_SIZE=0"
    for %%I in ("!OUT_FILE!") do set "OUT_SIZE=%%~zI"
    if !OUT_SIZE! gtr 0 (echo OK: !OUT_SIZE! bytes) else (echo ERROR: empty file & del "!OUT_FILE!" 2>nul)
) else (echo ERROR: conversion failed)

pause
endlocal
exit /b 0
