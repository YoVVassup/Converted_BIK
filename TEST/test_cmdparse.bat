@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: CMDParse.exe
echo ===================================================

set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
set "_t=0" & set "_p=0" & set "_f=0"
set "_out=%TEMP%\cp_test.txt"

rem ===== cross mode =====

("%CMDPARSE%" --mode:cross > "%_out%") 2>nul
set "PROCESS_RA1=0" & set "PROCESS_RA2=0" & set "PROCESS_RA2YR=0"
set "GROUP_FILTER=" & set "RESOLUTION_FILTER=" & set "INCLUDE_NOFORMAT=0" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!PROCESS_RA1!" "1" "cross no args: RA1=1"
call :chk "!PROCESS_RA2!" "1" "cross no args: RA2=1"
call :chk "!PROCESS_RA2YR!" "1" "cross no args: RA2YR=1"
call :chk "!GROUP_FILTER!" "" "cross no args: group empty"
call :chk "!RESOLUTION_FILTER!" "" "cross no args: res empty"
call :chk "!INCLUDE_NOFORMAT!" "0" "cross no args: nofmt=0"

("%CMDPARSE%" --mode:cross -GAME:RA2 > "%_out%") 2>nul
set "PROCESS_RA1=0" & set "PROCESS_RA2=0" & set "PROCESS_RA2YR=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!PROCESS_RA1!" "0" "cross -GAME:RA2: RA1=0"
call :chk "!PROCESS_RA2!" "1" "cross -GAME:RA2: RA2=1"
call :chk "!PROCESS_RA2YR!" "0" "cross -GAME:RA2: RA2YR=0"

("%CMDPARSE%" --mode:cross -GAME:RA2,RA2YR > "%_out%") 2>nul
set "PROCESS_RA1=0" & set "PROCESS_RA2=0" & set "PROCESS_RA2YR=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!PROCESS_RA1!" "0" "cross -GAME:RA2,RA2YR: RA1=0"
call :chk "!PROCESS_RA2!" "1" "cross -GAME:RA2,RA2YR: RA2=1"
call :chk "!PROCESS_RA2YR!" "1" "cross -GAME:RA2,RA2YR: RA2YR=1"

("%CMDPARSE%" --mode:cross -RES:600p,720p > "%_out%") 2>nul
set "RESOLUTION_FILTER=" & set "INCLUDE_NOFORMAT=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!RESOLUTION_FILTER!" "600p;720p" "cross -RES:600p,720p: filter"
call :chk "!INCLUDE_NOFORMAT!" "0" "cross -RES:600p,720p: nofmt=0"

("%CMDPARSE%" --mode:cross -RES:600p+ > "%_out%") 2>nul
set "RESOLUTION_FILTER=" & set "INCLUDE_NOFORMAT=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!RESOLUTION_FILTER!" "600p+" "cross -RES:600p+: filter"
call :chk "!INCLUDE_NOFORMAT!" "1" "cross -RES:600p+: nofmt=1"

("%CMDPARSE%" --mode:cross -G:Original > "%_out%") 2>nul
set "GROUP_FILTER="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!GROUP_FILTER!" "Original" "cross -G:Original: filter"

("%CMDPARSE%" --mode:cross -DRY_RUN > "%_out%") 2>nul
set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "cross -DRY_RUN: dry=1"

rem ===== pack_mo mode =====

("%CMDPARSE%" --mode:pack_mo > "%_out%") 2>nul
set "FILTER_GAME=" & set "FILTER_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!FILTER_GAME!" "RA1;RA2;RA2YR" "pack_mo no args: game defaults"
call :chk "!FILTER_GROUP!" "" "pack_mo no args: group empty"

("%CMDPARSE%" --mode:pack_mo -GAME:RA2YR > "%_out%") 2>nul
set "FILTER_GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!FILTER_GAME!" "RA2YR" "pack_mo -GAME:RA2YR"

("%CMDPARSE%" --mode:pack_mo -G:Original,7wolf > "%_out%") 2>nul
set "FILTER_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!FILTER_GROUP!" "Original;7wolf" "pack_mo -G:Original,7wolf"

("%CMDPARSE%" --mode:pack_mo -DRY_RUN > "%_out%") 2>nul
set "DRY_RUN=0" & set "INCREMENTAL=0" & set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "pack_mo -DRY_RUN: dry=1"
call :chk "!INCREMENTAL!" "0" "pack_mo -DRY_RUN: incr=0"
call :chk "!RETRY!" "0" "pack_mo -DRY_RUN: retry=0"

("%CMDPARSE%" --mode:pack_mo -INCREMENTAL -RETRY > "%_out%") 2>nul
set "DRY_RUN=0" & set "INCREMENTAL=0" & set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "0" "pack_mo -I -R: dry=0"
call :chk "!INCREMENTAL!" "1" "pack_mo -I -R: incr=1"
call :chk "!RETRY!" "1" "pack_mo -I -R: retry=1"

rem ===== pack_original mode =====

("%CMDPARSE%" --mode:pack_original > "%_out%") 2>nul
set "AUDIO_GROUP=" & set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!AUDIO_GROUP!" "" "pack_original no args: group empty"
call :chk "!RESOLUTION!" "" "pack_original no args: res empty"

("%CMDPARSE%" --mode:pack_original -G:Original,7wolf > "%_out%") 2>nul
set "AUDIO_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!AUDIO_GROUP!" "Original;7wolf" "pack_original -G:Original,7wolf"

("%CMDPARSE%" --mode:pack_original -DRY_RUN > "%_out%") 2>nul
set "DRY_RUN=0" & set "INCREMENTAL=0" & set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "pack_original -DRY_RUN: dry=1"
call :chk "!INCREMENTAL!" "0" "pack_original -DRY_RUN: incr=0"
call :chk "!RETRY!" "0" "pack_original -DRY_RUN: retry=0"

rem ===== mp3_to_wav mode =====

("%CMDPARSE%" --mode:mp3_to_wav -DRY_RUN > "%_out%") 2>nul
set "DRY_RUN=0" & set "OVERWRITE=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "mp3_to_wav -DRY_RUN: dry=1"
call :chk "!OVERWRITE!" "0" "mp3_to_wav -DRY_RUN: ow=0"

del "%_out%" 2>nul
echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_cmdparse_passed.txt
echo !_f!>%TEMP%\test_cmdparse_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:chk
set /a _t+=1
if "%~1"=="%~2" (set /a _p+=1 & echo   [PASS] %~3) else (set /a _f+=1 & echo   [FAIL] %~3: exp="%~2" got="%~1")
exit /b 0
