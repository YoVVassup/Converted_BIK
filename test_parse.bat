@echo off
setlocal enabledelayedexpansion

call "%~dp0config_loader.bat"

set "PROCESS_RA1=0"
set "PROCESS_RA2=0"
set "PROCESS_RA2YR=0"
set "GROUP_FILTER="
set "RESOLUTION_FILTER="
set "INCLUDE_NOFORMAT=0"
set "DRY_RUN=0"
set "INCREMENTAL=0"
set "RETRY=0"

"%~dp0third-party\CMDParse\CMDParse.exe" %* > "%TEMP%\bik_args.txt"

for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\bik_args.txt") do (
    set "%%A=%%B"
)
del "%TEMP%\bik_args.txt" 2>nul

echo === Variables set by exe ===
echo PROCESS_RA1=!PROCESS_RA1!
echo PROCESS_RA2=!PROCESS_RA2!
echo PROCESS_RA2YR=!PROCESS_RA2YR!
echo GROUP_FILTER=!GROUP_FILTER!
echo RESOLUTION_FILTER=!RESOLUTION_FILTER!
echo INCLUDE_NOFORMAT=!INCLUDE_NOFORMAT!
echo DRY_RUN=!DRY_RUN!
echo INCREMENTAL=!INCREMENTAL!
echo RETRY=!RETRY!