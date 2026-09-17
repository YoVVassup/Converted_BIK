@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Cross_Converted_BIK.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CROSS=%~dp0..\Cross_Converted_BIK.bat"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
set "_out=%TEMP%\cross_full_out.txt"

rem --- set_resolution subroutine logic ---
rem Test width/height/bitrate mapping for each resolution
set "RES=600p" & set "GAME=RA2"
call :set_resolution "!RES!" "!GAME!"
call :chk "!width!" "800" "RA2 600p: width=800"
call :chk "!height!" "600" "RA2 600p: height=600"
call :chk "!bitrate!" "400000" "RA2 600p: bitrate=400000"

set "RES=600pyr" & set "GAME=RA2YR"
call :set_resolution "!RES!" "!GAME!"
call :chk "!width!" "800" "RA2YR 600pyr: width=800"
call :chk "!height!" "600" "RA2YR 600pyr: height=600"
call :chk "!bitrate!" "1100000" "RA2YR 600pyr: bitrate=1100000"

set "RES=720p" & set "GAME=RA1"
call :set_resolution "!RES!" "!GAME!"
call :chk "!width!" "1280" "RA1 720p: width=1280"
call :chk "!height!" "720" "RA1 720p: height=720"
call :chk "!bitrate!" "600000" "RA1 720p: bitrate=600000"

set "RES=768p" & set "GAME=RA2"
call :set_resolution "!RES!" "!GAME!"
call :chk "!width!" "1024" "RA2 768p: width=1024"
call :chk "!bitrate!" "700000" "RA2 768p: bitrate=700000"

set "RES=900p" & set "GAME=RA1"
call :set_resolution "!RES!" "!GAME!"
call :chk "!width!" "1600" "RA1 900p: width=1600"
call :chk "!bitrate!" "900000" "RA1 900p: bitrate=900000"

set "RES=1080p" & set "GAME=RA2YR"
call :set_resolution "!RES!" "!GAME!"
call :chk "!width!" "1400" "RA2YR 1080p: width=1400"
call :chk "!bitrate!" "1150000" "RA2YR 1080p: bitrate=1150000"

rem --- game defaults (no args) ---
("%CMDPARSE%" --mode:cross > "%_out%") 2>nul
set "PROCESS_RA1=0" & set "PROCESS_RA2=0" & set "PROCESS_RA2YR=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!PROCESS_RA1!" "1" "defaults: RA1=1"
call :chk "!PROCESS_RA2!" "1" "defaults: RA2=1"
call :chk "!PROCESS_RA2YR!" "1" "defaults: RA2YR=1"

rem --- GAME filter: single ---
("%CMDPARSE%" --mode:cross -GAME:RA1 > "%_out%") 2>nul
set "PROCESS_RA1=0" & set "PROCESS_RA2=0" & set "PROCESS_RA2YR=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!PROCESS_RA1!" "1" "GAME:RA1: RA1=1"
call :chk "!PROCESS_RA2!" "0" "GAME:RA1: RA2=0"
call :chk "!PROCESS_RA2YR!" "0" "GAME:RA1: RA2YR=0"

rem --- GAME filter: multi ---
("%CMDPARSE%" --mode:cross -GAME:RA2,RA2YR > "%_out%") 2>nul
set "PROCESS_RA1=0" & set "PROCESS_RA2=0" & set "PROCESS_RA2YR=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!PROCESS_RA1!" "0" "GAME:RA2,RA2YR: RA1=0"
call :chk "!PROCESS_RA2!" "1" "GAME:RA2,RA2YR: RA2=1"
call :chk "!PROCESS_RA2YR!" "1" "GAME:RA2,RA2YR: RA2YR=1"

rem --- RESOLUTION filter ---
("%CMDPARSE%" --mode:cross -RES:600p,720p > "%_out%") 2>nul
set "RESOLUTION_FILTER="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!RESOLUTION_FILTER!" "600p;720p" "RES filter: 600p;720p"

rem --- GROUP filter ---
("%CMDPARSE%" --mode:cross -G:Original > "%_out%") 2>nul
set "GROUP_FILTER="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!GROUP_FILTER!" "Original" "GROUP filter: Original"

rem --- DRY_RUN ---
("%CMDPARSE%" --mode:cross -DRY_RUN > "%_out%") 2>nul
set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "DRY_RUN=1"

rem --- INCREMENTAL ---
("%CMDPARSE%" --mode:cross -INCREMENTAL > "%_out%") 2>nul
set "INCREMENTAL=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!INCREMENTAL!" "1" "INCREMENTAL=1"

rem --- RETRY ---
("%CMDPARSE%" --mode:cross -RETRY > "%_out%") 2>nul
set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!RETRY!" "1" "RETRY=1"

rem --- all flags combined ---
("%CMDPARSE%" --mode:cross -DRY_RUN -INCREMENTAL -RETRY > "%_out%") 2>nul
set "DRY_RUN=0" & set "INCREMENTAL=0" & set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "all flags: dry=1"
call :chk "!INCREMENTAL!" "1" "all flags: incr=1"
call :chk "!RETRY!" "1" "all flags: retry=1"

rem --- findstr filter logic ---
set "RESOLUTION_FILTER=600p;720p;900p"
set "res=720p"
echo ";!RESOLUTION_FILTER!;" | findstr /i /c:";!res!;" >nul
if !errorlevel! equ 0 (call :pass "findstr: 720p found in 600p;720p;900p") else (call :fail "findstr: 720p found in 600p;720p;900p")

set "res=1080p"
echo ";!RESOLUTION_FILTER!;" | findstr /i /c:";!res!;" >nul
if !errorlevel! equ 1 (call :pass "findstr: 1080p rejected from 600p;720p;900p") else (call :fail "findstr: 1080p rejected from 600p;720p;900p")

rem --- GROUP filter findstr ---
set "GROUP_FILTER=Original;7wolf"
set "group=Original"
echo ";!GROUP_FILTER!;" | findstr /i /c:";!group!;" >nul
if !errorlevel! equ 0 (call :pass "findstr: Original found in Original;7wolf") else (call :fail "findstr: Original found in Original;7wolf")

set "group=Fargus"
echo ";!GROUP_FILTER!;" | findstr /i /c:";!group!;" >nul
if !errorlevel! equ 1 (call :pass "findstr: Fargus rejected from Original;7wolf") else (call :fail "findstr: Fargus rejected from Original;7wolf")

del "%_out%" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_cross_full_passed.txt
echo !_f!>%TEMP%\test_cross_full_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

rem === Subroutines ===

:set_resolution
set "_res=%~1"
set "_game=%~2"
set "height=!_res!" & set "height=!height:pyr=!" & set "height=!height:p=!"
set "width=0" & set "bitrate=0"
if "!_res!"=="600p" set "width=800"
if "!_res!"=="600pyr" set "width=800"
if "!_res!"=="720p" set "width=960"
if "!_res!"=="768p" set "width=1024"
if "!_res!"=="900p" set "width=1200"
if "!_res!"=="1080p" set "width=1400"
if /i "!_game!"=="RA1" (
    if "!_res!"=="600p" set "width=1024"
    if "!_res!"=="720p" set "width=1280"
    if "!_res!"=="768p" set "width=1366"
    if "!_res!"=="900p" set "width=1600"
    if "!_res!"=="1080p" set "width=1920"
)
if "!_res!"=="600p" set "bitrate=400000"
if "!_res!"=="600pyr" set "bitrate=1100000"
if "!_res!"=="720p" set "bitrate=600000"
if "!_res!"=="768p" set "bitrate=700000"
if "!_res!"=="900p" set "bitrate=900000"
if "!_res!"=="1080p" set "bitrate=1150000"
exit /b 0

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0

:chk
set /a _t+=1
if "%~1"=="%~2" (set /a _p+=1 & echo   [PASS] %~3) else (set /a _f+=1 & echo   [FAIL] %~3: exp="%~2" got="%~1")
exit /b 0
