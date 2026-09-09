@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem ===================================================
rem CONFIGURATION
rem ===================================================

call "%~dp0config_loader.bat"

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

"%~dp0third-party\CMDParse\CMDParse.exe" --mode:pack_mo %* > "%TEMP%\pack_mo_args.txt"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\pack_mo_args.txt") do (
    set "%%A=%%B"
)
del "%TEMP%\pack_mo_args.txt" 2>nul

if defined FILTER_GROUP echo Group filter: !FILTER_GROUP!
if defined FILTER_GAME echo Game filter: !FILTER_GAME!

if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"

rem ===================================================
rem BLOCK 1: RED ALERT 1 (RA1)
rem ===================================================

set "DO_RA1=1"
if defined FILTER_GAME if /i not "!FILTER_GAME!"=="RA1" set "DO_RA1=0"

if !DO_RA1! equ 1 if exist "%SOURCE_RA1%" (
    echo.
    echo [RA1] Packing...
    for /d %%G in ("%SOURCE_RA1%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "skip_group=0"
        if defined FILTER_GROUP if /i not "!AUDIO_GROUP!"=="!FILTER_GROUP!" set "skip_group=1"
        if !skip_group! equ 0 (
            set "TARGET_DIR=%BUILD_ROOT%\%OUTPUT_RA1%\!AUDIO_GROUP!"
            echo -- Group: !AUDIO_GROUP!
            if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"
            if /i "!AUDIO_GROUP!"=="Original" (
                for %%R in (%RESOLUTIONS_LIST%) do (
                    set "RESOLUTION=%%R"
                    set "SOURCE_DIR=%%G\!RESOLUTION!"
                    if exist "!SOURCE_DIR!\nolang" (
                        set "_sz=0" & for %%F in ("!SOURCE_DIR!\nolang\*") do set /a _sz+=%%~zF
                        if !_sz! gtr 2147483647 (echo    [ERROR] expandmo11_!RESOLUTION!.mix exceeds 2GB) else (
                            "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR!\nolang" --mix "!TARGET_DIR!\expandmo11_!RESOLUTION!.mix" > nul
                            if !errorlevel! neq 0 (
                                echo    [ERROR] Failed: expandmo11_!RESOLUTION!.mix
                                set /a PACK_ERRORS+=1
                            ) else (
                                echo    Packed [Original]: expandmo11_!RESOLUTION!.mix
                            )
                        )
                    )
                    if exist "!SOURCE_DIR!" (
                        set "_sz=0" & for %%F in ("!SOURCE_DIR!\*") do set /a _sz+=%%~zF
                        if !_sz! gtr 2147483647 (echo    [ERROR] expandmo13_!RESOLUTION!.mix exceeds 2GB) else (
                            "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR!" --mix "!TARGET_DIR!\expandmo13_!RESOLUTION!.mix" > nul
                            if !errorlevel! neq 0 (
                                echo    [ERROR] Failed: expandmo13_!RESOLUTION!.mix
                                set /a PACK_ERRORS+=1
                            ) else (
                                echo    Packed [Original]: expandmo13_!RESOLUTION!.mix
                            )
                        )
                    )
                )
                set "SOURCE_DIR_NOFORMAT=%%G\noformat"
                if exist "!SOURCE_DIR_NOFORMAT!\nolang" (
                    set "_sz=0" & for %%F in ("!SOURCE_DIR_NOFORMAT!\nolang\*") do set /a _sz+=%%~zF
                    if !_sz! gtr 2147483647 (echo    [ERROR] expandmo12.mix exceeds 2GB) else (
                        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!\nolang" --mix "!TARGET_DIR!\expandmo12.mix" > nul
                        if !errorlevel! neq 0 (
                            echo    [ERROR] Failed: expandmo12.mix
                            set /a PACK_ERRORS+=1
                        ) else (
                            echo    Packed [Original]: expandmo12.mix
                        )
                    )
                )

                if exist "!SOURCE_DIR_NOFORMAT!" (
                    set "_sz=0" & for %%F in ("!SOURCE_DIR_NOFORMAT!\*") do set /a _sz+=%%~zF
                    if !_sz! gtr 2147483647 (echo    [ERROR] expandmo14.mix exceeds 2GB) else (
                        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!" --mix "!TARGET_DIR!\expandmo14.mix" > nul
                        if !errorlevel! neq 0 (
                            echo    [ERROR] Failed: expandmo14.mix
                            set /a PACK_ERRORS+=1
                        ) else (
                            echo    Packed [Original]: expandmo14.mix
                        )
                    )
                )
            ) else (
                for %%R in (%RESOLUTIONS_LIST%) do (
                    set "RESOLUTION=%%R"
                    set "SOURCE_DIR=%%G\!RESOLUTION!"
                    if exist "!SOURCE_DIR!" (
                        set "_sz=0" & for %%F in ("!SOURCE_DIR!\*") do set /a _sz+=%%~zF
                        if !_sz! gtr 2147483647 (echo    [ERROR] expandmo13_!RESOLUTION!.mix exceeds 2GB) else (
                            "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR!" --mix "!TARGET_DIR!\expandmo13_!RESOLUTION!.mix" > nul
                            if !errorlevel! neq 0 (
                                echo    [ERROR] Failed: expandmo13_!RESOLUTION!.mix
                                set /a PACK_ERRORS+=1
                            ) else (
                                echo    Packed [!AUDIO_GROUP!]: expandmo13_!RESOLUTION!.mix
                            )
                        )
                    )
                )
                set "SOURCE_DIR_NOFORMAT=%%G\noformat"
                if exist "!SOURCE_DIR_NOFORMAT!" (
                    set "_sz=0" & for %%F in ("!SOURCE_DIR_NOFORMAT!\*") do set /a _sz+=%%~zF
                    if !_sz! gtr 2147483647 (echo    [ERROR] expandmo14.mix exceeds 2GB) else (
                        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!" --mix "!TARGET_DIR!\expandmo14.mix" > nul
                        if !errorlevel! neq 0 (
                            echo    [ERROR] Failed: expandmo14.mix
                            set /a PACK_ERRORS+=1
                        ) else (
                            echo    Packed [!AUDIO_GROUP!]: expandmo14.mix
                        )
                    )
                )
            )
        )
    )
)

rem ===================================================
rem BLOCK 2: RED ALERT 2 (RA2)
rem ===================================================

set "DO_RA2=1"
if defined FILTER_GAME if /i not "!FILTER_GAME!"=="RA2" set "DO_RA2=0"

if !DO_RA2! equ 1 if exist "%SOURCE_RA2%" (
    echo.
    echo [RA2] Packing with prefix split...
    for /d %%G in ("%SOURCE_RA2%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "skip_group=0"
        if defined FILTER_GROUP if /i not "!AUDIO_GROUP!"=="!FILTER_GROUP!" set "skip_group=1"
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
                            copy "%%F" "!TEMP_DIR_A!\" > nul
                        ) else if /i "!FILENAME!"=="westlogo" (
                            copy "%%F" "!TEMP_DIR_A!\" > nul
                        ) else if /i "!FIRST_CHAR!"=="s" (
                            copy "%%F" "!TEMP_DIR_S!\" > nul
                        )
                    )
                    popd
                    if exist "!TEMP_DIR_A!\*.bik" (
                        set "_sz=0" & for %%F in ("!TEMP_DIR_A!\*") do set /a _sz+=%%~zF
                        if !_sz! gtr 2147483647 (echo    [ERROR] expandmo11_!RESOLUTION!.mix exceeds 2GB) else (
                            "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR_A!" --mix "!TARGET_DIR!\expandmo11_!RESOLUTION!.mix" > nul
                            if !errorlevel! neq 0 (
                                echo    [ERROR] Failed: expandmo11_!RESOLUTION!.mix
                                set /a PACK_ERRORS+=1
                            ) else (
                                echo    Packed [!AUDIO_GROUP!]: expandmo11_!RESOLUTION!.mix
                            )
                        )
                    )
                    if exist "!TEMP_DIR_S!\*.bik" (
                        set "_sz=0" & for %%F in ("!TEMP_DIR_S!\*") do set /a _sz+=%%~zF
                        if !_sz! gtr 2147483647 (echo    [ERROR] expandmo12_!RESOLUTION!.mix exceeds 2GB) else (
                            "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR_S!" --mix "!TARGET_DIR!\expandmo12_!RESOLUTION!.mix" > nul
                            if !errorlevel! neq 0 (
                                echo    [ERROR] Failed: expandmo12_!RESOLUTION!.mix
                                set /a PACK_ERRORS+=1
                            ) else (
                                echo    Packed [!AUDIO_GROUP!]: expandmo12_!RESOLUTION!.mix
                            )
                        )
                    )
                    rmdir /s /q "!TEMP_DIR_A!"
                    rmdir /s /q "!TEMP_DIR_S!"
                )
            )
            set "SOURCE_DIR_NOFORMAT=%%G\noformat"
                if exist "!SOURCE_DIR_NOFORMAT!" (
                    set "_sz=0" & for %%F in ("!SOURCE_DIR_NOFORMAT!\*") do set /a _sz+=%%~zF
                    if !_sz! gtr 2147483647 (echo    [ERROR] expandmo13.mix exceeds 2GB) else (
                        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!" --mix "!TARGET_DIR!\expandmo13.mix" > nul
                        if !errorlevel! neq 0 (
                            echo    [ERROR] Failed: expandmo13.mix
                            set /a PACK_ERRORS+=1
                        ) else (
                            echo    Packed [!AUDIO_GROUP!]: expandmo13.mix
                        )
                    )
            )
        )
    )
)

rem ===================================================
rem BLOCK 3: YURI'S REVENGE (RA2YR)
rem ===================================================

set "DO_RA2YR=1"
if defined FILTER_GAME if /i not "!FILTER_GAME!"=="RA2YR" set "DO_RA2YR=0"

if !DO_RA2YR! equ 1 if exist "%SOURCE_RA2YR%" (
    echo.
    echo [RA2YR] Copying, renaming and packing...
    for /d %%G in ("%SOURCE_RA2YR%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "skip_group=0"
        if defined FILTER_GROUP if /i not "!AUDIO_GROUP!"=="!FILTER_GROUP!" set "skip_group=1"
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
                            copy "%%F" "!TEMP_DIR_YR!\!FILENAME!_yr.bik" > nul
                        ) else (
                            copy "%%F" "!TEMP_DIR_YR!\" > nul
                        )
                    )
                    popd
                    if exist "!TEMP_DIR_YR!\*.bik" (
                        set "_sz=0" & for %%F in ("!TEMP_DIR_YR!\*") do set /a _sz+=%%~zF
                        if !_sz! gtr 2147483647 (echo    [ERROR] expandmo14_!RESOLUTION!.mix exceeds 2GB) else (
                            "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR_YR!" --mix "!TARGET_DIR!\expandmo14_!RESOLUTION!.mix" > nul
                            if !errorlevel! neq 0 (
                                echo    [ERROR] Failed: expandmo14_!RESOLUTION!.mix
                                set /a PACK_ERRORS+=1
                            ) else (
                                echo    Packed: expandmo14_!RESOLUTION!.mix
                            )
                        )
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
                        copy "%%F" "!TEMP_DIR_YR_NOFORMAT!\!FILENAME!_yr.bik" > nul
                    ) else (
                        copy "%%F" "!TEMP_DIR_YR_NOFORMAT!\" > nul
                    )
                )
                popd
                if exist "!TEMP_DIR_YR_NOFORMAT!\*.bik" (
                    set "_sz=0" & for %%F in ("!TEMP_DIR_YR_NOFORMAT!\*") do set /a _sz+=%%~zF
                    if !_sz! gtr 2147483647 (echo    [ERROR] expandmo15.mix exceeds 2GB) else (
                        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR_YR_NOFORMAT!" --mix "!TARGET_DIR!\expandmo15.mix" > nul
                        if !errorlevel! neq 0 (
                            echo    [ERROR] Failed: expandmo15.mix
                            set /a PACK_ERRORS+=1
                        ) else (
                            echo    Packed: expandmo15.mix
                        )
                    )
                )
                rmdir /s /q "!TEMP_DIR_YR_NOFORMAT!"
            )
        )
    )
)

echo.
if !PACK_ERRORS! gtr 0 (
    echo All operations completed with !PACK_ERRORS! error(s).
    endlocal
    exit /b 1
) else (
    echo All operations completed successfully.
    endlocal
    exit /b 0
)
