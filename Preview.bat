@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

call "%~dp0config_loader.bat"

set "GAME="
set "GROUP="
set "RESOLUTION="
set "FILE="

if not "%~1"=="" (
    "%~dp0third-party\CMDParse\CMDParse.exe" --mode:preview %* > "%TEMP%\preview_args.txt"
    for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_args.txt") do (
        set "%%A=%%B"
    )
    del "%TEMP%\preview_args.txt" 2>nul
)

echo ========================================
echo BIK Preview - quick video check
echo ========================================
echo.

set "TEMP_BIK=%TEMP%\preview_%RANDOM%_%RANDOM%.bik"

if not exist "!NEW_RAD!" (echo ERROR: !NEW_RAD! not found & pause & endlocal & exit /b 1)
if not exist "!BINK_PLAY!" (echo ERROR: !BINK_PLAY! not found & pause & endlocal & exit /b 1)
if not exist "!MP4_SOURCE!" (echo ERROR: Folder !MP4_SOURCE! not found & pause & endlocal & exit /b 1)

rem === GAME ===
if not defined GAME (
    echo Select game:
    echo   1. Red Alert 1 (RA1^)
    echo   2. Red Alert 2 (RA2^)
    echo   3. Red Alert 2 Yuri's Revenge (RA2YR^)
    echo.
    set /p "GAME_CHOICE=Your choice (1-3): "
    if "!GAME_CHOICE!"=="1" set "GAME=RA1"
    if "!GAME_CHOICE!"=="2" set "GAME=RA2"
    if "!GAME_CHOICE!"=="3" set "GAME=RA2YR"
    if not defined GAME (echo Invalid choice. & pause & endlocal & exit /b 1)
)

if not defined GAME (echo Invalid game. & pause & endlocal & exit /b 1)

if "!GAME!"=="RA1" (set "MP4_DIR=%MP4_SOURCE%\RA1\HD\WAV" & set "SOUND_DIR=%SOUND_SOURCE%\RA1")
if "!GAME!"=="RA2" (set "MP4_DIR=%MP4_SOURCE%\RA2" & set "SOUND_DIR=%SOUND_SOURCE%\RA2")
if "!GAME!"=="RA2YR" (set "MP4_DIR=%MP4_SOURCE%\RA2YR" & set "SOUND_DIR=%SOUND_SOURCE%\RA2YR")

if not exist "!MP4_DIR!\" (echo ERROR: Folder !MP4_DIR! not found & pause & endlocal & exit /b 1)

echo Game: !GAME!
echo.

rem === FILE ===
if not defined FILE (
    echo Available MP4 files:
    echo ---------------------
    set "FILE_IDX=0"
    for %%F in ("!MP4_DIR!\*.mp4") do (
        set /a FILE_IDX+=1
        set "file_!FILE_IDX!=%%~nF"
        echo   !FILE_IDX!. %%~nF.mp4
    )
    if !FILE_IDX! equ 0 (echo No MP4 files found. & pause & endlocal & exit /b 0)
    echo.
    set /p "FILE_NUM=Select file number (1-!FILE_IDX!): "
    if defined FILE_NUM (
        if !FILE_NUM! lss 1 (echo Invalid number. & pause & endlocal & exit /b 1)
        if !FILE_NUM! gtr !FILE_IDX! (echo Invalid number. & pause & endlocal & exit /b 1)
        set "FILENAME=!file_%FILE_NUM%!"
    )
) else (
    set "FILENAME=!FILE!"
)

set "MP4_FILE=!MP4_DIR!\!FILENAME!.mp4"
if not exist "!MP4_FILE!" (echo ERROR: File !MP4_FILE! not found & pause & endlocal & exit /b 1)
echo Selected: !FILENAME!.mp4
echo.

rem === RESOLUTION ===
if not defined RESOLUTION (
    echo Select resolution:
    echo   1. 600p   (800x600,  400 kbps^)
    if "!GAME!"=="RA2YR" echo   2. 600pyr (800x600,  1100 kbps^)
    echo   3. 720p   (960x720,  600 kbps^)
    echo   4. 768p   (1024x768, 700 kbps^)
    echo   5. 900p   (1200x900, 900 kbps^)
    echo   6. 1080p  (1400x1080, 1150 kbps^)
    if "!GAME!"=="RA1" echo   (RA1 uses wider: 1024x600, 1280x720 etc.^)
    echo.
    set /p "RES_CHOICE=Your choice: "
    if defined RES_CHOICE (
        if "!RES_CHOICE!"=="1" set "RESOLUTION=600p"
        if "!RES_CHOICE!"=="2" if "!GAME!"=="RA2YR" set "RESOLUTION=600pyr"
        if "!RES_CHOICE!"=="3" set "RESOLUTION=720p"
        if "!RES_CHOICE!"=="4" set "RESOLUTION=768p"
        if "!RES_CHOICE!"=="5" set "RESOLUTION=900p"
        if "!RES_CHOICE!"=="6" set "RESOLUTION=1080p"
    )
)

if not defined RESOLUTION (echo Invalid resolution. & pause & endlocal & exit /b 1)

set "RES=!RESOLUTION!"
set "height=!RES!"
set "height=!height:pyr=!"
set "height=!height:p=!"
if "!RES!"=="600p" (set "width=800" & set "bitrate=400000")
if "!RES!"=="600pyr" (set "width=800" & set "bitrate=1100000")
if "!RES!"=="720p" (set "width=960" & set "bitrate=600000")
if "!RES!"=="768p" (set "width=1024" & set "bitrate=700000")
if "!RES!"=="900p" (set "width=1200" & set "bitrate=900000")
if "!RES!"=="1080p" (set "width=1400" & set "bitrate=1150000")
if "!GAME!"=="RA1" (
    if "!RES!"=="600p" set "width=1024"
    if "!RES!"=="720p" set "width=1280"
    if "!RES!"=="768p" set "width=1366"
    if "!RES!"=="900p" set "width=1600"
    if "!RES!"=="1080p" set "width=1920"
)

echo Resolution: !RES! (!WIDTH!x!HEIGHT!, !BITRATE! bps)
echo.

rem === GROUP ===
set "HAS_AUDIO=0"
if not defined GROUP (
    echo Select audio source:
    echo   0. No audio
    set "GROUP_IDX=0"
    for /d %%D in ("!SOUND_DIR!\*") do (
        set /a GROUP_IDX+=1
        set "group_!GROUP_IDX!=%%~nxD"
        echo   !GROUP_IDX!. %%~nxD
    )
    echo.
    set /p "GROUP_CHOICE=Your choice (0-!GROUP_IDX!): "
    if defined GROUP_CHOICE (
        if "!GROUP_CHOICE!"=="0" (set "HAS_AUDIO=0")
        if !GROUP_CHOICE! gtr 0 if !GROUP_CHOICE! leq !GROUP_IDX! (
            set "HAS_AUDIO=1"
            set "AUDIO_GROUP=!group_%GROUP_CHOICE%!"
        )
    )
) else (
    if "!GROUP!"=="none" (
        set "HAS_AUDIO=0"
    ) else (
        set "HAS_AUDIO=1"
        set "AUDIO_GROUP=!GROUP!"
    )
)

if !HAS_AUDIO! equ 1 if defined AUDIO_GROUP echo Group: !AUDIO_GROUP!
echo.

rem === CONVERT ===
echo ---------------------
echo Converting...
echo ---------------------

if exist "!TEMP_BIK!" del "!TEMP_BIK!"

echo [1/2] Converting MP4 to BIK...
powershell -NoProfile -Command "Start-Process -FilePath '%NEW_RAD%' -ArgumentList 'Binkc \"!MP4_FILE!\" \"!TEMP_BIK!\" /N-1 /(!WIDTH! /)!HEIGHT! /v100 /:0 /D!BITRATE! /L0 /O /Z0 /#' -WindowStyle Hidden -Wait"

if !errorlevel! neq 0 (echo ERROR: Conversion failed & pause & endlocal & exit /b 1)

set "BIK_SIZE=0"
for %%I in ("!TEMP_BIK!") do set "BIK_SIZE=%%~zI"
if !BIK_SIZE! equ 0 (echo ERROR: Output file is empty & del "!TEMP_BIK!" 2>nul & pause & endlocal & exit /b 1)
echo    OK: !BIK_SIZE! bytes

rem === MIX ===
if !HAS_AUDIO! equ 1 (
    set "WAV_FILE=!SOUND_DIR!\!AUDIO_GROUP!\!FILENAME!.wav"
    if exist "!WAV_FILE!" (
        echo [2/2] Mixing WAV into BIK...
        powershell -NoProfile -Command "Start-Process -FilePath '%OLD_MIX%' -ArgumentList '\"!TEMP_BIK!\" \"!WAV_FILE!\" \"!TEMP_BIK!\" /L0 /O /#' -WindowStyle Hidden -Wait"
        if !errorlevel! equ 0 (echo    OK: Audio added) else (echo    ERROR: Mixing failed)
    ) else (
        echo    WAV not found: !WAV_FILE!
    )
) else (
    echo [2/2] No audio
)

rem === PREVIEW ===
echo.
echo ---------------------
echo Launching player...
echo ---------------------

start "" "%BINK_PLAY%" "!TEMP_BIK!"
echo Player launched. Close it when done.
echo File saved: !TEMP_BIK!
echo.

if "%~1"=="" (
    pause
    echo.
    set /p "DELETE=Delete temporary file? (y/n): "
    if /i "!DELETE!"=="y" (del "!TEMP_BIK!" 2>nul & echo Deleted.) else (echo File saved: !TEMP_BIK!)
) else (
    echo Non-interactive mode: temp file kept at !TEMP_BIK!
)

endlocal
exit /b 0
