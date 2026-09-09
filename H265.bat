@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

call "%~dp0config_loader.bat"

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1!"

set "SOURCE="
set "OUTPUT="
set "DRY_RUN=0"

if not "%~1"=="" (
    "%~dp0third-party\CMDParse\CMDParse.exe" --mode:h265 %* > "%TEMP%\h265_args.txt"
    for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\h265_args.txt") do (
        set "%%A=%%B"
    )
    del "%TEMP%\h265_args.txt" 2>nul
)

echo ---------------------------------------
echo H.265 to H.264 Converter (no audio)
echo ---------------------------------------
echo.

echo Script location: %SCRIPT_DIR%
echo.

if not defined FFMPEG_PATH (
    where ffmpeg >nul 2>nul
    if !errorlevel! equ 0 (
        set "FFMPEG_PATH=ffmpeg"
    ) else if exist "%SCRIPT_DIR%\third-party\ffmpeg.exe" (
        set "FFMPEG_PATH=%SCRIPT_DIR%\third-party\ffmpeg.exe"
    )
)

if not defined FFMPEG_PATH (
    echo ERROR: ffmpeg not found!
    echo Install ffmpeg or place ffmpeg.exe in the script directory.
    echo.
    pause
    endlocal
    exit /b 1
)

echo [OK] ffmpeg found: !FFMPEG_PATH!
echo.

if not exist "%SCRIPT_DIR%\Converted" mkdir "%SCRIPT_DIR%\Converted" 2>nul

:SELECT_FOLDER
if defined SOURCE (
    set "source_folder=!SOURCE!"
    set "source_folder=!source_folder:"=!"
) else (
    set "source_folder="
    set /p "source_folder=Enter path to video folder: "
    set "source_folder=!source_folder:"=!"
)

if "!source_folder!"=="" (
    set "source_folder=!SCRIPT_DIR!"
    echo Using script directory.
    echo.
)

if not "!source_folder:~0,1!"=="\" (
    if not "!source_folder:~1,1!"==":" (
        set "source_folder=!SCRIPT_DIR!\!source_folder!"
    )
)

if not exist "!source_folder!\" (
    echo.
    echo Error: Folder "!source_folder!" does not exist!
    if not defined SOURCE (echo. & goto SELECT_FOLDER)
    endlocal
    exit /b 1
)

for %%I in ("!source_folder!") do set "source_folder_abs=%%~fI"

echo.
echo Folder: !source_folder_abs!
echo.

set "output_dir=%SCRIPT_DIR%\Converted"
if defined OUTPUT set "output_dir=!OUTPUT!"

if not exist "!output_dir!" mkdir "!output_dir!" 2>nul

pushd "!source_folder_abs!" 2>nul
if errorlevel 1 (
    echo.
    echo Error: Cannot access folder!
    echo.
    popd
    if not defined SOURCE (goto SELECT_FOLDER)
    endlocal
    exit /b 1
)

echo Processing files...
echo.

set file_count=0

for %%i in (*.mp4 *.mkv *.mov *.avi *.m4v *.ts *.webm *.flv) do (
    set /a file_count+=1
    echo Processing [!file_count!]: %%~nxi
    
    set "logname=%%~ni_!RANDOM!!RANDOM!"
    
    if !DRY_RUN! equ 0 (
        "!FFMPEG_PATH!" -y -i "%%i" -c:v libx264 -b:v 15862k -maxrate 15862k -minrate 15862k -bufsize 15862k -preset slow -an -pass 1 -passlogfile "!logname!" -f mp4 NUL 2>nul
        
        "!FFMPEG_PATH!" -y -i "%%i" -c:v libx264 -b:v 15862k -maxrate 15862k -minrate 15862k -bufsize 15862k -preset slow -an -pass 2 -passlogfile "!logname!" -movflags +faststart "!output_dir!\%%~ni.mp4" 2>nul
        
        if exist "!logname!-0.log" del "!logname!-0.log"
        if exist "!logname!-0.log.mbtree" del "!logname!-0.log.mbtree"
    ) else (
        echo    [DRY_RUN] Would convert: %%~nxi
    )
    
    echo Done: %%~ni.mp4
    echo.
)

popd

echo ---------------------------------------
if !file_count! equ 0 (
    echo No files found.
) else (
    echo Processed: !file_count!
    echo Results saved to: "!output_dir!"
)
echo ---------------------------------------
echo.
endlocal
exit /b 0
