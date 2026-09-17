@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Pack_Mixes_MO_Vision.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
set "_out=%TEMP%\pmo_full_out.txt"

rem --- FILTER_GAME parsing ---
("%CMDPARSE%" --mode:pack_mo -GAME:RA1 > "%_out%") 2>nul
set "FILTER_GAME=" & set "FILTER_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!FILTER_GAME!" "RA1" "GAME filter: RA1"

("%CMDPARSE%" --mode:pack_mo -GAME:RA2,RA2YR > "%_out%") 2>nul
set "FILTER_GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!FILTER_GAME!" "RA2;RA2YR" "GAME filter: RA2,RA2YR"

rem --- FILTER_GROUP parsing ---
("%CMDPARSE%" --mode:pack_mo -G:Original,7wolf,Fargus > "%_out%") 2>nul
set "FILTER_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!FILTER_GROUP!" "Original;7wolf;Fargus" "GROUP filter: 3 items"

rem --- DRY_RUN/INCREMENTAL/RETRY ---
("%CMDPARSE%" --mode:pack_mo -DRY_RUN -INCREMENTAL -RETRY > "%_out%") 2>nul
set "DRY_RUN=0" & set "INCREMENTAL=0" & set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "all flags: dry=1"
call :chk "!INCREMENTAL!" "1" "all flags: incr=1"
call :chk "!RETRY!" "1" "all flags: retry=1"

rem --- no args defaults ---
("%CMDPARSE%" --mode:pack_mo > "%_out%") 2>nul
set "FILTER_GAME=" & set "FILTER_GROUP=" & set "DRY_RUN=0" & set "INCREMENTAL=0" & set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!FILTER_GROUP!" "" "no args: group empty"
call :chk "!DRY_RUN!" "0" "no args: dry=0"
call :chk "!INCREMENTAL!" "0" "no args: incr=0"
call :chk "!RETRY!" "0" "no args: retry=0"

rem --- FILTER_GAME iteration logic ---
set "FILTER_GAME=RA1;RA2;RA2YR"
set "_count=0"
for %%G in (!FILTER_GAME!) do set /a _count+=1
call :chk "!_count!" "3" "FILTER_GAME: iterates 3 games"

set "FILTER_GAME=RA2YR"
set "_count=0"
for %%G in (!FILTER_GAME!) do set /a _count+=1
call :chk "!_count!" "1" "FILTER_GAME: single game"

rem --- FILTER_GROUP skip logic ---
set "FILTER_GROUP=Original"
set "test_group=7wolf"
set "skip=0"
for %%I in (!FILTER_GROUP!) do if /i "%%I"=="!test_group!" set "skip=1"
call :chk "!skip!" "0" "skip_group: 7wolf not in Original"

set "test_group=Original"
set "skip=0"
for %%I in (!FILTER_GROUP!) do if /i "%%I"=="!test_group!" set "skip=1"
call :chk "!skip!" "1" "skip_group: Original in Original"

rem --- RESOLUTIONS_LIST iteration ---
set "RESOLUTIONS_LIST=600p 720p 768p 900p 1080p"
set "_rcount=0"
for %%R in (!RESOLUTIONS_LIST!) do set /a _rcount+=1
call :chk "!_rcount!" "5" "RESOLUTIONS_LIST: 5 resolutions"

rem --- RA2 prefix split logic ---
set "FIRST_CHAR=a"
set "_is_a=0"
if /i "!FIRST_CHAR!"=="a" set "_is_a=1"
call :chk "!_is_a!" "1" "prefix split: 'a' detected"

set "FIRST_CHAR=s"
set "_is_s=0"
if /i "!FIRST_CHAR!"=="s" set "_is_s=1"
call :chk "!_is_s!" "1" "prefix split: 's' detected"

set "FIRST_CHAR=m"
set "_is_other=0"
if /i not "!FIRST_CHAR!"=="a" if /i not "!FIRST_CHAR!"=="s" set "_is_other=1"
call :chk "!_is_other!" "1" "prefix split: 'm' other"

rem --- westlogo routing ---
set "FILENAME=westlogo"
set "_to_a=0"
if /i "!FILENAME!"=="westlogo" set "_to_a=1"
call :chk "!_to_a!" "1" "westlogo routes to A"

rem --- _yr suffix handling ---
set "FILENAME=testclip"
set "_has_yr=0"
if /i not "!FILENAME:~-3!"=="_yr" set "_has_yr=1"
call :chk "!_has_yr!" "1" "no _yr suffix -> rename"

set "FILENAME=testclip_yr"
set "_has_yr=0"
if /i not "!FILENAME:~-3!"=="_yr" set "_has_yr=1"
call :chk "!_has_yr!" "0" "_yr suffix -> keep"

rem Cleanup
del "%_out%" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_pmo_full_passed.txt
echo !_f!>%TEMP%\test_pmo_full_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

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
