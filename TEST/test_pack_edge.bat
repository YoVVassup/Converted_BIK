@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Pack_Mixes_*.bat (CMDParse + edge cases)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CP=%~dp0..\third-party\CMDParse\CMDParse.exe"

rem --- PMO mode defaults ---
("%CP%" --mode:pack_mo > "%TEMP%\pack_edge_cp.txt") 2>nul
set "SOURCE=" & set "GROUP=" & set "RESOLUTION=" & set "DRY_RUN=0" & set "INCREMENTAL=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\pack_edge_cp.txt") do set "%%A=%%B"
if "!SOURCE!"=="" (call :pass "PMO: SOURCE default empty") else (call :fail "PMO: SOURCE: got=!SOURCE!")
if "!DRY_RUN!"=="0" (call :pass "PMO: DRY_RUN default 0") else (call :fail "PMO: DRY_RUN: got=!DRY_RUN!")
if "!INCREMENTAL!"=="0" (call :pass "PMO: INCREMENTAL default 0") else (call :fail "PMO: INCREMENTAL: got=!INCREMENTAL!")

rem --- PMO with args ---
("%CP%" --mode:pack_mo -GAME:RA2 -DRY_RUN > "%TEMP%\pack_edge_cp2.txt") 2>nul
set "FILTER_GAME=" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\pack_edge_cp2.txt") do set "%%A=%%B"
if "!FILTER_GAME!"=="RA2" (call :pass "PMO: -GAME:RA2 parsed") else (call :fail "PMO: -GAME:RA2: got=!FILTER_GAME!")
if "!DRY_RUN!"=="1" (call :pass "PMO: -DRY_RUN parsed") else (call :fail "PMO: -DRY_RUN: got=!DRY_RUN!")

rem --- PORIG mode defaults ---
("%CP%" --mode:pack_original > "%TEMP%\pack_edge_cp3.txt") 2>nul
set "SOURCE=" & set "DRY_RUN=0" & set "INCREMENTAL=0" & set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\pack_edge_cp3.txt") do set "%%A=%%B"
if "!SOURCE!"=="" (call :pass "PORIG: SOURCE default empty") else (call :fail "PORIG: SOURCE: got=!SOURCE!")
if "!DRY_RUN!"=="0" (call :pass "PORIG: DRY_RUN default 0") else (call :fail "PORIG: DRY_RUN: got=!DRY_RUN!")
if "!INCREMENTAL!"=="0" (call :pass "PORIG: INCREMENTAL default 0") else (call :fail "PORIG: INCREMENTAL: got=!INCREMENTAL!")
if "!RETRY!"=="0" (call :pass "PORIG: RETRY default 0") else (call :fail "PORIG: RETRY: got=!RETRY!")

del "%TEMP%\pack_edge*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_pack_edge_passed.txt
echo !_f!>%TEMP%\test_pack_edge_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
