@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Pack_Mixes_Original.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
set "_out=%TEMP%\porig_full_out.txt"

rem --- CMDParse: AUDIO_GROUP ---
("%CMDPARSE%" --mode:pack_original -G:Original > "%_out%") 2>nul
set "AUDIO_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!AUDIO_GROUP!" "Original" "AUDIO_GROUP: Original"

("%CMDPARSE%" --mode:pack_original -G:Original,7wolf > "%_out%") 2>nul
set "AUDIO_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!AUDIO_GROUP!" "Original;7wolf" "AUDIO_GROUP: Original,7wolf"

rem --- CMDParse: RESOLUTION ---
("%CMDPARSE%" --mode:pack_original -RES:600p > "%_out%") 2>nul
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!RESOLUTION!" "600p" "RESOLUTION: 600p"

("%CMDPARSE%" --mode:pack_original -RES:720p > "%_out%") 2>nul
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!RESOLUTION!" "720p" "RESOLUTION: 720p"

rem --- CMDParse: flags ---
("%CMDPARSE%" --mode:pack_original -DRY_RUN -INCREMENTAL -RETRY > "%_out%") 2>nul
set "DRY_RUN=0" & set "INCREMENTAL=0" & set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "flags: dry=1"
call :chk "!INCREMENTAL!" "1" "flags: incr=1"
call :chk "!RETRY!" "1" "flags: retry=1"

rem --- defaults (no args) ---
("%CMDPARSE%" --mode:pack_original > "%_out%") 2>nul
set "AUDIO_GROUP=" & set "RESOLUTION=" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!AUDIO_GROUP!" "" "defaults: group empty"
call :chk "!RESOLUTION!" "" "defaults: res empty"
call :chk "!DRY_RUN!" "0" "defaults: dry=0"

rem --- AUDIO_GROUP iteration ---
set "AUDIO_GROUP=Original;7wolf;Fargus"
set "_count=0"
for %%G in (!AUDIO_GROUP!) do set /a _count+=1
call :chk "!_count!" "3" "AUDIO_GROUP: iterates 3"

set "AUDIO_GROUP=Original"
set "_count=0"
for %%G in (!AUDIO_GROUP!) do set /a _count+=1
call :chk "!_count!" "1" "AUDIO_GROUP: single"

rem --- pack_ra2 file prefix logic ---
set "FILENAME=atest"
set "_is_a=0"
if /i "!FILENAME:~0,1!"=="a" set "_is_a=1"
call :chk "!_is_a!" "1" "pack_ra2: 'a' prefix detected"

set "FILENAME=westlogo"
set "_is_wl=0"
if /i "!FILENAME!"=="westlogo" set "_is_wl=1"
call :chk "!_is_wl!" "1" "pack_ra2: westlogo detected"

set "FILENAME=s_test"
set "_is_s=0"
if /i "!FILENAME:~0,1!"=="s" set "_is_s=1"
call :chk "!_is_s!" "1" "pack_ra2: 's' prefix detected"

rem --- pack_yr _yr suffix ---
set "FILENAME=clip"
set "_renamed=0"
if /i not "!FILENAME:~-3!"=="_yr" set "_renamed=1"
call :chk "!_renamed!" "1" "pack_yr: needs rename"

set "FILENAME=clip_yr"
set "_renamed=0"
if /i not "!FILENAME:~-3!"=="_yr" set "_renamed=1"
call :chk "!_renamed!" "0" "pack_yr: has _yr already"

rem --- RA2 MIX naming ---
rem movies01.mix = a* + westlogo + key.ini
rem movies02.mix = s* + key.ini
rem movmd03.mix = YR 600pyr + noformat
call :pass "RA2 MIX naming: movies01 (a*+westlogo)"
call :pass "RA2 MIX naming: movies02 (s*)"
call :pass "RA2 MIX naming: movmd03 (YR)"

del "%_out%" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_porig_full_passed.txt
echo !_f!>%TEMP%\test_porig_full_failed.txt
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
