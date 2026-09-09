@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

call "%~dp0config_loader.bat"

echo ========================================
echo MP3 to WAV Converter for audio tracks
echo ========================================
echo.

if not defined FFMPEG_PATH (
    where ffmpeg >nul 2>nul
    if !errorlevel! equ 0 (
        set "FFMPEG_PATH=ffmpeg"
    ) else if exist "%~dp0third-party\ffmpeg.exe" (
        set "FFMPEG_PATH=%~dp0third-party\ffmpeg.exe"
    )
)

if not defined FFMPEG_PATH (
    echo ERROR: ffmpeg not found!
    echo Install ffmpeg or place ffmpeg.exe in the script directory.
    pause
    endlocal
    exit /b 1
)

echo [OK] ffmpeg found: !FFMPEG_PATH!
echo.

set "OVERWRITE=0"
set "DRY_RUN=0"

"%~dp0third-party\CMDParse\CMDParse.exe" --mode:mp3_to_wav %* > "%TEMP%\mp3_args.txt"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_args.txt") do (
    set "%%A=%%B"
)
del "%TEMP%\mp3_args.txt" 2>nul

echo Source: %SOUND_SOURCE%
echo.
echo Enter path to MP3 folder (or press Enter for default: %SOUND_SOURCE%):
set /p "CUSTOM_PATH= "
if not "!CUSTOM_PATH!"=="" (
    set "CUSTOM_PATH=!CUSTOM_PATH:"=!"
    set "SOUND_SOURCE=!CUSTOM_PATH!"
    echo Using custom path: !SOUND_SOURCE!
)
echo.

set "TOTAL=0"
set "CONVERTED=0"
set "SKIPPED=0"
set "ERRORS=0"

for /r "%SOUND_SOURCE%" %%F in (*.mp3) do set /a TOTAL+=1

if !TOTAL! equ 0 (
    echo No MP3 files found in %SOUND_SOURCE%
    echo Place MP3 files in voice group subfolders.
    pause
    endlocal
    exit /b 0
)

echo Found !TOTAL! MP3 files
echo.

set "IDX=0"

for /r "%SOUND_SOURCE%" %%F in (*.mp3) do (
    set /a IDX+=1
    set "mp3_file=%%F"
    set "wav_file=%%~dpnF.wav"
    set "filename=%%~nF"
    set "rel_path=%%F"
    set "rel_path=!rel_path:%CD%\=!"
    set "should_convert=1"
    
    if exist "!wav_file!" if !OVERWRITE! equ 0 (
        echo [!IDX!/!TOTAL!] Skip (WAV exists): !rel_path!
        set /a SKIPPED+=1
        set "should_convert=0"
    )
    
    if !should_convert! equ 1 (
        echo [!IDX!/!TOTAL!] Converting: !rel_path!
        
        if !DRY_RUN! equ 0 (
            "!FFMPEG_PATH!" -y -i "!mp3_file!" -acodec pcm_s16le -ar 44100 -ac 2 "!wav_file!" 2>nul
            
            if !errorlevel! equ 0 (
                set "wav_size=0"
                for %%I in ("!wav_file!") do set "wav_size=%%~zI"
                if !wav_size! gtr 0 (
                    echo    OK
                    set /a CONVERTED+=1
                ) else (
                    echo    ERROR: empty output file
                    del "!wav_file!" 2>nul
                    set /a ERRORS+=1
                )
            ) else (
                echo    ERROR: conversion failed
                set /a ERRORS+=1
            )
        ) else (
            echo    [DRY_RUN] Would convert
        )
    )
)

echo.
echo ============================
echo STATISTICS
echo ============================
echo Total MP3: !TOTAL!
echo Converted: !CONVERTED!
echo Skipped: !SKIPPED!
echo Errors: !ERRORS!
echo.

if !ERRORS! gtr 0 (
    echo Check ffmpeg installation and try again.
    endlocal
    exit /b 1
)

endlocal
exit /b 0
