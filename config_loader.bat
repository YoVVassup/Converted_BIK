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
set "MP4_SOURCE=Clean_MP4"
set "SOUND_SOURCE=WAV_Sound"
set "CLEAN_BIK=Clean_BIK"
set "FINAL_RA1=Final_BIK_RA1"
set "FINAL_RA2=Final_BIK_RA2"
set "FINAL_RA2YR=Final_BIK_RA2YR"
set "BUILD_ROOT=Build"
set "NOLANG_FILES_HD="
set "NOLANG_FILES_NOFORMAT="
set "LOGFILE=conversion_log.txt"
set "FAILED_FILE=failed.txt"

if not exist "%CONFIG_FILE%" (
    echo [CONFIG] config.ini not found, using defaults >&2
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
        if /i "!key!"=="log_file" set "LOGFILE=!val!"
        if /i "!key!"=="failed_file" set "FAILED_FILE=!val!"
    )
)

echo [CONFIG] Configuration loaded from config.ini >&2
