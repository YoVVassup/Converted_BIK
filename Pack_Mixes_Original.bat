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

"%~dp0third-party\CMDParse\CMDParse.exe" --mode:pack_original %* > "%TEMP%\pack_orig_args.txt"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\pack_orig_args.txt") do (
    set "%%A=%%B"
)
del "%TEMP%\pack_orig_args.txt" 2>nul

rem No args → default Original / 600p
if not defined AUDIO_GROUP (
    set "AUDIO_GROUP=Original"
    set "RESOLUTION=600p"
    echo.
    echo ===================================================
    echo Original Games Packaging - Original / 600pyr
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

if not exist "%SOURCE_RA2%\!AUDIO_GROUP!\" (
    echo ERROR: RA2 folder not found: %SOURCE_RA2%\!AUDIO_GROUP!\
    if exist "%SOURCE_RA2%\" (dir "%SOURCE_RA2%\" /b /ad)
    pause
    endlocal
    exit /b 1
)

if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"

call :pack_ra2 "!AUDIO_GROUP!" "!RESOLUTION!"

if exist "%SOURCE_RA2YR%\!AUDIO_GROUP!\" (
    set "YR_SOURCE_DIR=%SOURCE_RA2YR%\!AUDIO_GROUP!"
    set "YR_OUTPUT_DIR=%BUILD_ROOT%\%OUTPUT_RA2YR%\!AUDIO_GROUP!"
    if not exist "!YR_OUTPUT_DIR!" mkdir "!YR_OUTPUT_DIR!"
    call :pack_yr "!AUDIO_GROUP!"
)

echo.
echo ===================================================
echo PROCESSING COMPLETE
echo ===================================================
echo Results saved to:
echo   RA2:   %BUILD_ROOT%\%OUTPUT_RA2%\!AUDIO_GROUP!\
if exist "%SOURCE_RA2YR%\!AUDIO_GROUP!\" (echo   RA2YR: %BUILD_ROOT%\%OUTPUT_RA2YR%\!AUDIO_GROUP!\)
echo.

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
set "TEMP_DIR=%TEMP%\ra2_m1_%RANDOM%"
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!"
mkdir "!TEMP_DIR!"
set FILE_COUNT=0

if exist "!_src_dir!\!_res!\" (
    pushd "!_src_dir!\!_res!"
    for %%F in (a*.bik) do (copy "%%F" "!TEMP_DIR!\" >nul & set /a FILE_COUNT+=1)
    if exist "westlogo.bik" (copy "westlogo.bik" "!TEMP_DIR!\" >nul & set /a FILE_COUNT+=1)
    popd
)
if exist "!_src_dir!\noformat\" (
    pushd "!_src_dir!\noformat"
    for %%F in (a*.bik) do (copy "%%F" "!TEMP_DIR!\" >nul & set /a FILE_COUNT+=1)
    if exist "westlogo.bik" (copy "westlogo.bik" "!TEMP_DIR!\" >nul & set /a FILE_COUNT+=1)
    popd
)

if exist "%KEY_SOURCE%\movies01\key.ini" (copy "%KEY_SOURCE%\movies01\key.ini" "!TEMP_DIR!\" >nul)
if !FILE_COUNT! GTR 0 (
    set "_sz=0" & for %%F in ("!TEMP_DIR!\*") do set /a _sz+=%%~zF
    if !_sz! gtr 2147483647 (echo    [ERROR] movies01.mix exceeds 2GB) else (
        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR!" --mix "!_out_dir!\movies01.mix" >nul
        echo    [OK] movies01.mix ^(!FILE_COUNT! files^)
    )
) else (echo    [WARN] No files for movies01.mix)
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" 2>nul

rem movies02.mix (s* + key.ini)
set "TEMP_DIR=%TEMP%\ra2_m2_%RANDOM%"
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!"
mkdir "!TEMP_DIR!"
set FILE_COUNT=0

if exist "!_src_dir!\!_res!\" (
    pushd "!_src_dir!\!_res!"
    for %%F in (s*.bik) do (copy "%%F" "!TEMP_DIR!\" >nul & set /a FILE_COUNT+=1)
    popd
)
if exist "!_src_dir!\noformat\" (
    pushd "!_src_dir!\noformat"
    for %%F in (s*.bik) do (copy "%%F" "!TEMP_DIR!\" >nul & set /a FILE_COUNT+=1)
    popd
)

if exist "%KEY_SOURCE%\movies02\key.ini" (copy "%KEY_SOURCE%\movies02\key.ini" "!TEMP_DIR!\" >nul)
if !FILE_COUNT! GTR 0 (
    set "_sz=0" & for %%F in ("!TEMP_DIR!\*") do set /a _sz+=%%~zF
    if !_sz! gtr 2147483647 (echo    [ERROR] movies02.mix exceeds 2GB) else (
        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR!" --mix "!_out_dir!\movies02.mix" >nul
        echo    [OK] movies02.mix ^(!FILE_COUNT! files^)
    )
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
    for %%F in (*.bik) do (copy "%%F" "!TEMP_DIR!\" >nul & set /a FILE_COUNT+=1)
    popd
)

rem noformat
if exist "!_src_dir!\noformat\" (
    pushd "!_src_dir!\noformat"
    for %%F in (*.bik) do (copy "%%F" "!TEMP_DIR!\" >nul & set /a FILE_COUNT+=1)
    popd
)

if exist "%KEY_SOURCE%\movmd03\key.ini" (copy "%KEY_SOURCE%\movmd03\key.ini" "!TEMP_DIR!\" >nul)
if !FILE_COUNT! GTR 0 (
    set "_sz=0" & for %%F in ("!TEMP_DIR!\*") do set /a _sz+=%%~zF
    if !_sz! gtr 2147483647 (echo    [ERROR] movmd03.mix exceeds 2GB) else (
        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR!" --mix "!_out_dir!\movmd03.mix" >nul
        echo    [OK] movmd03.mix ^(!FILE_COUNT! files^)
    )
) else (echo    [WARN] No files for movmd03.mix)
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" 2>nul
goto :eof
