@echo off
rem ===================================================
rem Configuration for Converted_BIK
rem ===================================================
rem Usage: call config_loader.bat
rem Sets variables from config.ini (or uses defaults)
rem ===================================================

set "CONFIG_FILE=%~dp0config.ini"

rem Defaults
set "NEW_RAD=third-party\Radtools_New\radvideo64.exe"
set "OLD_MIX=third-party\Radtools_Old\BinkMix.exe"
set "CCMIX_TOOL=third-party\CCMIX\ccmix.exe"
set "FFMPEG_PATH=third-party\ffmpeg.exe"
set "BINK_PLAY=third-party\Radtools_New\binkplay.exe"
set "RUN_HIDDEN=third-party\run_hidden.vbs"
set "HIDE_WINDOW=1"
set "MP4_SOURCE=Clean_MP4"
set "SOUND_SOURCE=WAV_Sound"
set "CLEAN_BIK=Clean_BIK"
set "FINAL_RA1=Final_BIK_RA1"
set "FINAL_RA2=Final_BIK_RA2"
set "FINAL_RA2YR=Final_BIK_RA2YR"
set "BUILD_ROOT=Build"
set "NOLANG_FILES_HD="
set "NOLANG_FILES_NOFORMAT="

if not exist "%CONFIG_FILE%" (
    echo [CONFIG] config.ini not found, using defaults >&2
    if not defined LOGFILE set "LOGFILE=conversion_log.txt"
    if not defined FAILED_FILE set "FAILED_FILE=failed.txt"
    goto :eof
)

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "key=%%A"
    set "val=%%B"
    if defined val (
        if /i "!key!"=="radtools_new" set "NEW_RAD=!val!"
        if /i "!key!"=="radtools_old" set "OLD_MIX=!val!"
        if /i "!key!"=="ccmix" set "CCMIX_TOOL=!val!"
        if /i "!key!"=="ffmpeg" set "FFMPEG_PATH=!val!"
        if /i "!key!"=="binkplay" set "BINK_PLAY=!val!"
        if /i "!key!"=="mp4_source" set "MP4_SOURCE=!val!"
        if /i "!key!"=="sound_source" set "SOUND_SOURCE=!val!"
        if /i "!key!"=="clean_bik" set "CLEAN_BIK=!val!"
        if /i "!key!"=="final_ra1" set "FINAL_RA1=!val!"
        if /i "!key!"=="final_ra2" set "FINAL_RA2=!val!"
        if /i "!key!"=="final_ra2yr" set "FINAL_RA2YR=!val!"
        if /i "!key!"=="build_root" set "BUILD_ROOT=!val!"
        if /i "!key!"=="files_hd" set "NOLANG_FILES_HD=!val!"
        if /i "!key!"=="files_noformat" set "NOLANG_FILES_NOFORMAT=!val!"
        if /i "!key!"=="hide_window" (
            if /i "!val!"=="true" (set "HIDE_WINDOW=1") else if /i "!val!"=="false" (set "HIDE_WINDOW=0")
        )
        if /i "!key!"=="log_file" if not defined _cfg_logfile set "_cfg_logfile=!val!"
        if /i "!key!"=="failed_file" if not defined _cfg_failedfile set "_cfg_failedfile=!val!"
    )
)

if not defined LOGFILE if defined _cfg_logfile set "LOGFILE=!_cfg_logfile!"
if not defined FAILED_FILE if defined _cfg_failedfile set "FAILED_FILE=!_cfg_failedfile!"
if not defined LOGFILE set "LOGFILE=conversion_log.txt"
if not defined FAILED_FILE set "FAILED_FILE=failed.txt"

if "!HIDE_WINDOW!"=="1" if not exist "%RUN_HIDDEN%" (
    echo [CONFIG] WARNING: run_hidden.vbs not found: %RUN_HIDDEN% >&2
    echo [CONFIG] Hidden window mode disabled, using visible mode >&2
    set "HIDE_WINDOW=0"
)

echo [CONFIG] Configuration loaded from config.ini >&2

rem ===================================================
rem Log rotation: if LOGFILE > 1MB, rename with timestamp
rem ===================================================
if exist "%LOGFILE%" (
    for %%I in ("%LOGFILE%") do if %%~zI gtr 1048576 (
        set "STAMP="
        for /f "tokens=2 delims==" %%D in ('wmic os get localdatetime /value 2^>nul') do set "DT=%%D"
        if defined DT set "STAMP=!DT:~0,4!!DT:~4,2!!DT:~6,2!_!DT:~8,2!!DT:~10,2!!DT:~12,2!"
        if not defined STAMP set "STAMP=!RANDOM!!RANDOM!"
        set "ROTATED=%LOGFILE%_!STAMP!.log"
        move "%LOGFILE%" "!ROTATED!" >nul 2>&1
        echo [CONFIG] Log rotated: !ROTATED! >&2
    )
)
