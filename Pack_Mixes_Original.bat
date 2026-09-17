@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem ===================================================
rem CONFIGURATION
rem ===================================================

call "%~dp0config_loader.bat"

set "CURRENT_DIR=%~dp0"
set "SOURCE_RA2=%FINAL_RA2%"
set "SOURCE_RA2YR=%FINAL_RA2YR%"
set "KEY_SOURCE=%CURRENT_DIR%third-party\Original_MIX_Key"
set "BUILD_ROOT=%BUILD_ROOT%\OriginalGames"
set "OUTPUT_RA2=RA2_Original"
set "OUTPUT_RA2YR=YR_Original"

rem ===================================================
rem COMMAND LINE PARAMETERS
rem ===================================================

set "AUDIO_GROUP="
set "RESOLUTION="
set "PACK_ERRORS=0"
set "DRY_RUN=0"
set "INCREMENTAL=0"
set "RETRY=0"

"%~dp0third-party\CMDParse\CMDParse.exe" --mode:pack_original %* > "%TEMP%\pack_orig_args.txt"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\pack_orig_args.txt") do (
    set "%%A=%%B"
)
del "%TEMP%\pack_orig_args.txt" 2>nul

if "!DRY_RUN!"=="1" echo [DRY_RUN] Preview mode - no files will be modified
if "!INCREMENTAL!"=="1" echo [INCREMENTAL] Skipping existing MIX files
if "!RETRY!"=="1" echo [RETRY] Including previously failed files

rem No args → default Original / 600p
if not defined AUDIO_GROUP (
    set "AUDIO_GROUP=Original"
    set "RESOLUTION=600p"
    echo.
    echo ===================================================
    echo Original Games Packaging - Original / 600p
    echo ===================================================
    echo.
    
    if not exist "%CCMIX_TOOL%" (
        echo ERROR: ccmix.exe not found
        pause
        endlocal
        exit /b 1
    )
    
    if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"
    
    set "RA2_SOURCE_DIR=%SOURCE_RA2%\!AUDIO_GROUP!"
    set "RA2_OUTPUT_DIR=%BUILD_ROOT%\%OUTPUT_RA2%\!AUDIO_GROUP!"
    if not exist "!RA2_OUTPUT_DIR!" mkdir "!RA2_OUTPUT_DIR!"
    
    if exist "!RA2_SOURCE_DIR!\!RESOLUTION!\" (
        call :pack_ra2 "!AUDIO_GROUP!" "!RESOLUTION!"
    )
    
    if exist "%SOURCE_RA2YR%\!AUDIO_GROUP!\" (
        set "YR_SOURCE_DIR=%SOURCE_RA2YR%\!AUDIO_GROUP!"
        set "YR_OUTPUT_DIR=%BUILD_ROOT%\%OUTPUT_RA2YR%\!AUDIO_GROUP!"
        if not exist "!YR_OUTPUT_DIR!" mkdir "!YR_OUTPUT_DIR!"
        call :pack_yr "!AUDIO_GROUP!"
    )
    
    echo.
    echo ===================================================
    echo ALL PROCESSING COMPLETE
    echo ===================================================
    endlocal
    exit /b 0
)

echo.
echo ===================================================
echo Original Games Packaging
echo ===================================================
echo Voice group: !AUDIO_GROUP!
echo Resolution: !RESOLUTION!
echo.

if not exist "%CCMIX_TOOL%" (
    echo ERROR: ccmix.exe not found
    pause
    endlocal
    exit /b 1
)

if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"

for %%G in (!AUDIO_GROUP!) do (
    set "_current_group=%%G"
    echo.
    echo --- Group: !_current_group! ---

    if not exist "%SOURCE_RA2%\!_current_group!\" (
        echo WARNING: RA2 folder not found: %SOURCE_RA2%\!_current_group!\
    ) else (
        call :pack_ra2 "!_current_group!" "!RESOLUTION!"
    )

    if exist "%SOURCE_RA2YR%\!_current_group!\" (
        set "YR_SOURCE_DIR=%SOURCE_RA2YR%\!_current_group!"
        set "YR_OUTPUT_DIR=%BUILD_ROOT%\%OUTPUT_RA2YR%\!_current_group!"
        if not exist "!YR_OUTPUT_DIR!" mkdir "!YR_OUTPUT_DIR!"
        call :pack_yr "!_current_group!"
    )
)

echo.
echo ===================================================
echo PROCESSING COMPLETE
echo ===================================================

endlocal
exit /b 0

rem ===================================================
rem SUBROUTINES
rem ===================================================

:pack_ra2
set "_group=%~1"
set "_res=%~2"
set "_src_dir=%SOURCE_RA2%\!_group!"
set "_out_dir=%BUILD_ROOT%\%OUTPUT_RA2%\!_group!"
if not exist "!_out_dir!" mkdir "!_out_dir!"

rem movies01.mix (a* + westlogo + key.ini)
set "_ts=%time: =0%"
set "_ts=!_ts:~0,2!!_ts:~3,2!!_ts:~6,2!"
set "TEMP_DIR=%TEMP%\ra2_m1_%RANDOM%_!_ts!"
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!"
mkdir "!TEMP_DIR!"
set FILE_COUNT=0

if exist "!_src_dir!\!_res!\" (
    pushd "!_src_dir!\!_res!"
    for %%F in (a*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        if exist "!TEMP_DIR!\%%~nxF" (set /a FILE_COUNT+=1) else (echo    [WARN] Copy failed: %%~nxF)
    )
    if exist "westlogo.bik" (
        copy "westlogo.bik" "!TEMP_DIR!\" >nul
        if exist "!TEMP_DIR!\westlogo.bik" (set /a FILE_COUNT+=1) else (echo    [WARN] Copy failed: westlogo.bik)
    )
    popd
)
if exist "!_src_dir!\noformat\" (
    pushd "!_src_dir!\noformat"
    for %%F in (a*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        if exist "!TEMP_DIR!\%%~nxF" (set /a FILE_COUNT+=1) else (echo    [WARN] Copy failed: %%~nxF)
    )
    if exist "westlogo.bik" (
        copy "westlogo.bik" "!TEMP_DIR!\" >nul
        if exist "!TEMP_DIR!\westlogo.bik" (set /a FILE_COUNT+=1) else (echo    [WARN] Copy failed: westlogo.bik)
    )
    popd
)

if exist "%KEY_SOURCE%\movies01\key.ini" (copy "%KEY_SOURCE%\movies01\key.ini" "!TEMP_DIR!\" >nul)
if !FILE_COUNT! GTR 0 (
    call :create_mix "!TEMP_DIR!" "!_out_dir!\movies01.mix" "movies01.mix"
    if !errorlevel! neq 0 set /a PACK_ERRORS+=1
) else (echo    [WARN] No files for movies01.mix)
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" 2>nul

rem movies02.mix (s* + key.ini)
set "_ts=%time: =0%"
set "_ts=!_ts:~0,2!!_ts:~3,2!!_ts:~6,2!"
set "TEMP_DIR=%TEMP%\ra2_m2_%RANDOM%_!_ts!"
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!"
mkdir "!TEMP_DIR!"
set FILE_COUNT=0

if exist "!_src_dir!\!_res!\" (
    pushd "!_src_dir!\!_res!"
    for %%F in (s*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        if exist "!TEMP_DIR!\%%~nxF" (set /a FILE_COUNT+=1) else (echo    [WARN] Copy failed: %%~nxF)
    )
    popd
)
if exist "!_src_dir!\noformat\" (
    pushd "!_src_dir!\noformat"
    for %%F in (s*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        if exist "!TEMP_DIR!\%%~nxF" (set /a FILE_COUNT+=1) else (echo    [WARN] Copy failed: %%~nxF)
    )
    popd
)

if exist "%KEY_SOURCE%\movies02\key.ini" (copy "%KEY_SOURCE%\movies02\key.ini" "!TEMP_DIR!\" >nul)
if !FILE_COUNT! GTR 0 (
    call :create_mix "!TEMP_DIR!" "!_out_dir!\movies02.mix" "movies02.mix"
    if !errorlevel! neq 0 set /a PACK_ERRORS+=1
) else (echo    [WARN] No files for movies02.mix)
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" 2>nul
goto :eof

:pack_yr
set "_group=%~1"
set "_src_dir=%SOURCE_RA2YR%\!_group!"
set "_out_dir=%BUILD_ROOT%\%OUTPUT_RA2YR%\!_group!"
if not exist "!_out_dir!" mkdir "!_out_dir!"

set "TEMP_DIR=%TEMP%\ra2yr_%RANDOM%"
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!"
mkdir "!TEMP_DIR!"
set FILE_COUNT=0

rem 600pyr (original game auto-scales)
if exist "!_src_dir!\600pyr\" (
    pushd "!_src_dir!\600pyr"
    for %%F in (*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        if exist "!TEMP_DIR!\%%~nxF" (set /a FILE_COUNT+=1) else (echo    [WARN] Copy failed: %%~nxF)
    )
    popd
)

rem noformat
if exist "!_src_dir!\noformat\" (
    pushd "!_src_dir!\noformat"
    for %%F in (*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        if exist "!TEMP_DIR!\%%~nxF" (set /a FILE_COUNT+=1) else (echo    [WARN] Copy failed: %%~nxF)
    )
    popd
)

if exist "%KEY_SOURCE%\movmd03\key.ini" (copy "%KEY_SOURCE%\movmd03\key.ini" "!TEMP_DIR!\" >nul)
if !FILE_COUNT! GTR 0 (
    call :create_mix "!TEMP_DIR!" "!_out_dir!\movmd03.mix" "movmd03.mix"
    if !errorlevel! neq 0 set /a PACK_ERRORS+=1
) else (echo    [WARN] No files for movmd03.mix)
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" 2>nul
goto :eof

rem ===================================================
rem HELPER: Check directory size and create MIX archive
rem   %~1 = source directory
rem   %~2 = output .mix path
rem   %~3 = display name for messages
rem   Returns: errorlevel 0 = OK, 1 = error
rem ===================================================
:create_mix
set "_cm_src=%~1"
set "_cm_dst=%~2"
set "_cm_name=%~3"
set "_cm_sz=0"
if not exist "%CCMIX_TOOL%" (
    echo    [ERROR] ccmix.exe not found: %CCMIX_TOOL%
    exit /b 1
)
if "!RETRY!"=="1" (
    set "_found=0"
    if exist "%FAILED_FILE%" (
        for /f "usebackq tokens=*" %%F in ("%FAILED_FILE%") do (
            if "%%F"=="%_cm_dst%" set "_found=1"
        )
    )
    if "!_found!"=="0" (
        echo    [SKIP] Not in failed list: !_cm_name!
        exit /b 0
    )
    echo    [RETRY] Retrying: !_cm_name!
)
if "!INCREMENTAL!"=="1" if exist "%_cm_dst%" (
    for %%I in ("%_cm_dst%") do if %%~zI gtr 0 (
        echo    [SKIP] Already exists: !_cm_name!
        exit /b 0
    )
)
if "!DRY_RUN!"=="1" (
    echo    [DRY_RUN] Would pack: !_cm_name!
    exit /b 0
)
for /f "usebackq delims=" %%X in (`powershell -NoProfile -Command "(Get-ChildItem -File '%_cm_src%') | Measure-Object -Property Length -Sum | ForEach-Object { $_.Sum }"`) do set "_cm_sz=%%X"
if not defined _cm_sz set "_cm_sz=0"
if !_cm_sz! gtr 2147483647 (
    echo    [ERROR] !_cm_name! exceeds 2GB ^(!_cm_sz! bytes^)
    exit /b 1
)
"%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "%_cm_src%" --mix "%_cm_dst%" > nul
if !errorlevel! neq 0 (
    echo    [ERROR] Failed: !_cm_name!
    echo !_cm_dst!>> "%FAILED_FILE%"
    exit /b 1
)
echo    [OK] !_cm_name!
exit /b 0
