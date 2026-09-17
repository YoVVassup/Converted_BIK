@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

rem ===================================================
rem CONFIGURATION
rem ===================================================

call "%~dp0config_loader.bat"

if not exist "%TEMP%" (
    echo ERROR: %%TEMP%% not accessible: %TEMP%
    pause
    endlocal & exit /b 1
)

set "SOURCE_RA1=%FINAL_RA1%"
set "SOURCE_RA2=%FINAL_RA2%"
set "SOURCE_RA2YR=%FINAL_RA2YR%"
set "OUTPUT_RA1=RA1_Remake"
set "OUTPUT_RA2_YURI=RA2_and_RA2YR_Remake"
set "RESOLUTIONS_LIST=600p 720p 768p 900p 1080p"

if not exist "%CCMIX_TOOL%" (
    echo ERROR: %CCMIX_TOOL% not found
    pause
    endlocal
    exit /b 1
)

rem ===================================================
rem PARSE FILTERS
rem ===================================================

set "FILTER_GROUP="
set "FILTER_GAME="
set "PACK_ERRORS=0"
set "DRY_RUN=0"
set "INCREMENTAL=0"
set "RETRY=0"

"%~dp0third-party\CMDParse\CMDParse.exe" --mode:pack_mo %* > "%TEMP%\pack_mo_args.txt"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\pack_mo_args.txt") do (
    set "%%A=%%B"
)
del "%TEMP%\pack_mo_args.txt" 2>nul

if defined FILTER_GROUP echo Group filter: !FILTER_GROUP!
if defined FILTER_GAME echo Game filter: !FILTER_GAME!
if "!DRY_RUN!"=="1" echo [DRY_RUN] Preview mode - no files will be modified
if "!INCREMENTAL!"=="1" echo [INCREMENTAL] Skipping existing MIX files
if "!RETRY!"=="1" echo [RETRY] Including previously failed files

if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"

rem ===================================================
rem BLOCK 1: RED ALERT 1 (RA1)
rem ===================================================

set "DO_RA1=1"
if defined FILTER_GAME (
    set "_found=0"
    for %%G in (!FILTER_GAME!) do if /i "%%G"=="RA1" set "_found=1"
    if !_found! equ 0 set "DO_RA1=0"
)

if !DO_RA1! equ 1 if exist "%SOURCE_RA1%" (
    echo.
    echo [RA1] Packing...
    for /d %%G in ("%SOURCE_RA1%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "skip_group=0"
        if defined FILTER_GROUP (
            set "_found=0"
            for %%I in (!FILTER_GROUP!) do if /i "%%I"=="!AUDIO_GROUP!" set "_found=1"
            if !_found! equ 0 set "skip_group=1"
        )
        if !skip_group! equ 0 (
            set "TARGET_DIR=%BUILD_ROOT%\%OUTPUT_RA1%\!AUDIO_GROUP!"
            echo -- Group: !AUDIO_GROUP!
            if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"
            if /i "!AUDIO_GROUP!"=="Original" (
                for %%R in (%RESOLUTIONS_LIST%) do (
                    set "RESOLUTION=%%R"
                    set "SOURCE_DIR=%%G\!RESOLUTION!"
                    if exist "!SOURCE_DIR!\nolang" (
                        call :create_mix "!SOURCE_DIR!\nolang" "!TARGET_DIR!\expandmo11_!RESOLUTION!.mix" "expandmo11_!RESOLUTION!.mix [Original]"
                        if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                    )
                    if exist "!SOURCE_DIR!" (
                        call :create_mix "!SOURCE_DIR!" "!TARGET_DIR!\expandmo13_!RESOLUTION!.mix" "expandmo13_!RESOLUTION!.mix [Original]"
                        if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                    )
                )
                set "SOURCE_DIR_NOFORMAT=%%G\noformat"
                if exist "!SOURCE_DIR_NOFORMAT!\nolang" (
                    call :create_mix "!SOURCE_DIR_NOFORMAT!\nolang" "!TARGET_DIR!\expandmo12.mix" "expandmo12.mix [Original]"
                    if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                )

                if exist "!SOURCE_DIR_NOFORMAT!" (
                    call :create_mix "!SOURCE_DIR_NOFORMAT!" "!TARGET_DIR!\expandmo14.mix" "expandmo14.mix [Original]"
                    if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                )
            ) else (
                for %%R in (%RESOLUTIONS_LIST%) do (
                    set "RESOLUTION=%%R"
                    set "SOURCE_DIR=%%G\!RESOLUTION!"
                    if exist "!SOURCE_DIR!" (
                        call :create_mix "!SOURCE_DIR!" "!TARGET_DIR!\expandmo13_!RESOLUTION!.mix" "expandmo13_!RESOLUTION!.mix [!AUDIO_GROUP!]"
                        if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                    )
                )
                set "SOURCE_DIR_NOFORMAT=%%G\noformat"
                if exist "!SOURCE_DIR_NOFORMAT!" (
                    call :create_mix "!SOURCE_DIR_NOFORMAT!" "!TARGET_DIR!\expandmo14.mix" "expandmo14.mix [!AUDIO_GROUP!]"
                    if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                )
            )
        )
    )
)

rem ===================================================
rem BLOCK 2: RED ALERT 2 (RA2)
rem ===================================================

set "DO_RA2=1"
if defined FILTER_GAME (
    set "_found=0"
    for %%G in (!FILTER_GAME!) do if /i "%%G"=="RA2" set "_found=1"
    if !_found! equ 0 set "DO_RA2=0"
)

if !DO_RA2! equ 1 if exist "%SOURCE_RA2%" (
    echo.
    echo [RA2] Packing with prefix split...
    for /d %%G in ("%SOURCE_RA2%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "skip_group=0"
        if defined FILTER_GROUP (
            set "_found=0"
            for %%I in (!FILTER_GROUP!) do if /i "%%I"=="!AUDIO_GROUP!" set "_found=1"
            if !_found! equ 0 set "skip_group=1"
        )
        if !skip_group! equ 0 (
            set "TARGET_DIR=%BUILD_ROOT%\%OUTPUT_RA2_YURI%\!AUDIO_GROUP!"
            echo -- Group: !AUDIO_GROUP!
            if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"
            for %%R in (%RESOLUTIONS_LIST%) do (
                set "RESOLUTION=%%R"
                set "SOURCE_DIR=%%G\!RESOLUTION!"
                if exist "!SOURCE_DIR!" (
                    set "TEMP_DIR_A=%TEMP%\RA2_A_!AUDIO_GROUP!_!RESOLUTION!"
                    set "TEMP_DIR_S=%TEMP%\RA2_S_!AUDIO_GROUP!_!RESOLUTION!"
                    if exist "!TEMP_DIR_A!" rmdir /s /q "!TEMP_DIR_A!"
                    if exist "!TEMP_DIR_S!" rmdir /s /q "!TEMP_DIR_S!"
                    mkdir "!TEMP_DIR_A!"
                    mkdir "!TEMP_DIR_S!"
                    pushd "!SOURCE_DIR!"
                    for %%F in (*.bik) do (
                        set "FILENAME=%%~nF"
                        set "FIRST_CHAR=!FILENAME:~0,1!"
                        if /i "!FIRST_CHAR!"=="a" (
                            copy "%%F" "!TEMP_DIR_A!\" >nul
                        ) else if /i "!FILENAME!"=="westlogo" (
                            copy "%%F" "!TEMP_DIR_A!\" >nul
                        ) else if /i "!FIRST_CHAR!"=="s" (
                            copy "%%F" "!TEMP_DIR_S!\" >nul
                        ) else (
                            echo    [WARN] Skipped (not a*/s*/westlogo): %%~nxF
                        )
                    )
                    popd
                    if exist "!TEMP_DIR_A!\*.bik" (
                        call :create_mix "!TEMP_DIR_A!" "!TARGET_DIR!\expandmo11_!RESOLUTION!.mix" "expandmo11_!RESOLUTION!.mix [!AUDIO_GROUP!]"
                        if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                    )
                    if exist "!TEMP_DIR_S!\*.bik" (
                        call :create_mix "!TEMP_DIR_S!" "!TARGET_DIR!\expandmo12_!RESOLUTION!.mix" "expandmo12_!RESOLUTION!.mix [!AUDIO_GROUP!]"
                        if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                    )
                    rmdir /s /q "!TEMP_DIR_A!"
                    rmdir /s /q "!TEMP_DIR_S!"
                )
            )
            set "SOURCE_DIR_NOFORMAT=%%G\noformat"
            if exist "!SOURCE_DIR_NOFORMAT!" (
                call :create_mix "!SOURCE_DIR_NOFORMAT!" "!TARGET_DIR!\expandmo13.mix" "expandmo13.mix [!AUDIO_GROUP!]"
                if !errorlevel! neq 0 set /a PACK_ERRORS+=1
            )
        )
    )
)

rem ===================================================
rem BLOCK 3: YURI'S REVENGE (RA2YR)
rem ===================================================

set "DO_RA2YR=1"
if defined FILTER_GAME (
    set "_found=0"
    for %%G in (!FILTER_GAME!) do if /i "%%G"=="RA2YR" set "_found=1"
    if !_found! equ 0 set "DO_RA2YR=0"
)

if !DO_RA2YR! equ 1 if exist "%SOURCE_RA2YR%" (
    echo.
    echo [RA2YR] Copying, renaming and packing...
    for /d %%G in ("%SOURCE_RA2YR%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "skip_group=0"
        if defined FILTER_GROUP (
            set "_found=0"
            for %%I in (!FILTER_GROUP!) do if /i "%%I"=="!AUDIO_GROUP!" set "_found=1"
            if !_found! equ 0 set "skip_group=1"
        )
        if !skip_group! equ 0 (
            set "TARGET_DIR=%BUILD_ROOT%\%OUTPUT_RA2_YURI%\!AUDIO_GROUP!"
            echo -- Group: !AUDIO_GROUP!
            if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"
            for %%R in (%RESOLUTIONS_LIST%) do (
                set "RESOLUTION=%%R"
                set "SOURCE_DIR=%%G\!RESOLUTION!"
                if exist "!SOURCE_DIR!" (
                    set "TEMP_DIR_YR=%TEMP%\RA2YR_!AUDIO_GROUP!_!RESOLUTION!"
                    if exist "!TEMP_DIR_YR!" rmdir /s /q "!TEMP_DIR_YR!"
                    mkdir "!TEMP_DIR_YR!"
                    pushd "!SOURCE_DIR!"
                    for %%F in (*.bik) do (
                        set "FILENAME=%%~nF"
                        if /i not "!FILENAME:~-3!"=="_yr" (
                            copy "%%F" "!TEMP_DIR_YR!\!FILENAME!_yr.bik" >nul
                        ) else (
                            copy "%%F" "!TEMP_DIR_YR!\" >nul
                        )
                    )
                    popd
                    if exist "!TEMP_DIR_YR!\*.bik" (
                        call :create_mix "!TEMP_DIR_YR!" "!TARGET_DIR!\expandmo14_!RESOLUTION!.mix" "expandmo14_!RESOLUTION!.mix"
                        if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                    )
                    rmdir /s /q "!TEMP_DIR_YR!"
                )
            )
            set "SOURCE_DIR_NOFORMAT=%%G\noformat"
            if exist "!SOURCE_DIR_NOFORMAT!" (
                set "TEMP_DIR_YR_NOFORMAT=%TEMP%\RA2YR_!AUDIO_GROUP!_noformat"
                if exist "!TEMP_DIR_YR_NOFORMAT!" rmdir /s /q "!TEMP_DIR_YR_NOFORMAT!"
                mkdir "!TEMP_DIR_YR_NOFORMAT!"
                pushd "!SOURCE_DIR_NOFORMAT!"
                for %%F in (*.bik) do (
                    set "FILENAME=%%~nF"
                    if /i not "!FILENAME:~-3!"=="_yr" (
                        copy "%%F" "!TEMP_DIR_YR_NOFORMAT!\!FILENAME!_yr.bik" >nul
                    ) else (
                        copy "%%F" "!TEMP_DIR_YR_NOFORMAT!\" >nul
                    )
                )
                popd
                if exist "!TEMP_DIR_YR_NOFORMAT!\*.bik" (
                    call :create_mix "!TEMP_DIR_YR_NOFORMAT!" "!TARGET_DIR!\expandmo15.mix" "expandmo15.mix"
                    if !errorlevel! neq 0 set /a PACK_ERRORS+=1
                )
                rmdir /s /q "!TEMP_DIR_YR_NOFORMAT!"
            )
        )
    )
)

echo.
if !PACK_ERRORS! gtr 0 (
    echo All operations completed with !PACK_ERRORS! error^(s^).
    endlocal
    exit /b 1
) else (
    echo All operations completed successfully.
    endlocal
    exit /b 0
)

rem ===================================================
rem Subroutine: create_mix
rem Creates a mix file from a directory with 64-bit size check
rem Usage: call :create_mix "source_dir" "target.mix" "display_name"
rem ===================================================
:create_mix
    set "_src=%~1"
    set "_dst=%~2"
    set "_name=%~3"
    if not exist "%CCMIX_TOOL%" (
        echo    [ERROR] ccmix.exe not found: %CCMIX_TOOL%
        exit /b 1
    )
    if not exist "%_src%" (
        echo    [ERROR] Source directory not found: %_src%
        exit /b 1
    )
    if "!RETRY!"=="1" (
        set "_found=0"
        if exist "%FAILED_FILE%" (
            for /f "usebackq tokens=*" %%F in ("%FAILED_FILE%") do (
                if "%%F"=="%_dst%" set "_found=1"
            )
        )
        if "!_found!"=="0" (
            echo    [SKIP] Not in failed list: !_name!
            exit /b 0
        )
        echo    [RETRY] Retrying: !_name!
    )
    if "!INCREMENTAL!"=="1" if exist "%_dst%" (
        for %%I in ("%_dst%") do if %%~zI gtr 0 (
            echo    [SKIP] Already exists: !_name!
            exit /b 0
        )
    )
    if "!DRY_RUN!"=="1" (
        echo    [DRY_RUN] Would pack: !_name!
        exit /b 0
    )
    for /f "tokens=*" %%A in ('powershell -command "(Get-ChildItem -Path '%_src%' -File | Measure-Object -Property Length -Sum).Sum"') do set "_sz=%%A"
    if not defined _sz set "_sz=0"
    if !_sz! gtr 2147483647 (
        echo    [ERROR] !_name! exceeds 2GB ^(!_sz! bytes^)
        exit /b 1
    )
    "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "%_src%" --mix "%_dst%" >nul
    if !errorlevel! neq 0 (
        echo    [ERROR] Failed: !_name!
        echo !_dst!>> "%FAILED_FILE%"
        exit /b 1
    )
    echo    Packed: !_name!
    exit /b 0
