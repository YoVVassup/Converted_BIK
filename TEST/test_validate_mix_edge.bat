@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Validate_MIX.bat (edge cases)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CP=%~dp0..\third-party\CMDParse\CMDParse.exe"
set "CWD_BAK=%CD%"
cd /d "%~dp0.."

set /a _t+=1 & set /a _p+=1
if exist "%~dp0..\third-party\CCMIX\ccmix.exe" (echo   [PASS] CCMIX_TOOL exists) else (set /a _p-=1 & set /a _f+=1 & echo   [FAIL] CCMIX_TOOL exists)

("%CP%" --mode:validate_mix > "%TEMP%\vmix_edge_cp.txt") 2>nul
set "DRY_RUN=" & set "INCREMENTAL=" & set "RETRY=" & set "PROCESS_RA1=" & set "GROUP_FILTER=" & set "RESOLUTION_FILTER="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\vmix_edge_cp.txt") do set "%%A=%%B"

set /a _t+=1
if "!DRY_RUN!"=="0" (set /a _p+=1 & echo   [PASS] CMDParse DRY_RUN default 0) else (set /a _f+=1 & echo   [FAIL] CMDParse DRY_RUN: got=!DRY_RUN!)

set /a _t+=1
if "!INCREMENTAL!"=="0" (set /a _p+=1 & echo   [PASS] CMDParse INCREMENTAL default 0) else (set /a _f+=1 & echo   [FAIL] CMDParse INCREMENTAL: got=!INCREMENTAL!)

set /a _t+=1
if "!RETRY!"=="0" (set /a _p+=1 & echo   [PASS] CMDParse RETRY default 0) else (set /a _f+=1 & echo   [FAIL] CMDParse RETRY: got=!RETRY!)

("%CP%" --mode:validate_mix -DRY_RUN > "%TEMP%\vmix_edge_cp2.txt") 2>nul
set "DRY_RUN="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\vmix_edge_cp2.txt") do if "%%A"=="DRY_RUN" set "DRY_RUN=%%B"
set /a _t+=1
if "!DRY_RUN!"=="1" (set /a _p+=1 & echo   [PASS] CMDParse -DRY_RUN parsed) else (set /a _f+=1 & echo   [FAIL] CMDParse -DRY_RUN: got=!DRY_RUN!)

("%CP%" --mode:validate_mix -I > "%TEMP%\vmix_edge_cp3.txt") 2>nul
set "INCREMENTAL="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\vmix_edge_cp3.txt") do if "%%A"=="INCREMENTAL" set "INCREMENTAL=%%B"
set /a _t+=1
if "!INCREMENTAL!"=="0" (set /a _p+=1 & echo   [PASS] CMDParse -I not in validate_mix mode) else (set /a _f+=1 & echo   [FAIL] CMDParse -I: got=!INCREMENTAL!)

("%CP%" --mode:validate_mix -R > "%TEMP%\vmix_edge_cp4.txt") 2>nul
set "RETRY="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\vmix_edge_cp4.txt") do if "%%A"=="RETRY" set "RETRY=%%B"
set /a _t+=1
if "!RETRY!"=="0" (set /a _p+=1 & echo   [PASS] CMDParse -R not in validate_mix mode) else (set /a _f+=1 & echo   [FAIL] CMDParse -R: got=!RETRY!)

("%CP%" --mode:validate_mix -GAME:RA2 -GROUP:soviets -RES:720p > "%TEMP%\vmix_edge_cp5.txt") 2>nul
set "PROCESS_RA1=" & set "PROCESS_RA2=" & set "GROUP_FILTER=" & set "RESOLUTION_FILTER="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\vmix_edge_cp5.txt") do set "%%A=%%B"

set /a _t+=1
if "!PROCESS_RA2!"=="1" (set /a _p+=1 & echo   [PASS] GAME filters correct) else (set /a _f+=1 & echo   [FAIL] GAME filters: ra2=!PROCESS_RA2!)
set /a _t+=1
if "!GROUP_FILTER!"=="soviets" (set /a _p+=1 & echo   [PASS] GROUP_FILTER parsed) else (set /a _f+=1 & echo   [FAIL] GROUP_FILTER: got=!GROUP_FILTER!)
set /a _t+=1
if "!RESOLUTION_FILTER!"=="720p" (set /a _p+=1 & echo   [PASS] RESOLUTION_FILTER parsed) else (set /a _f+=1 & echo   [FAIL] RESOLUTION_FILTER: got=!RESOLUTION_FILTER!)

cd /d "%CWD_BAK%"
del "%TEMP%\vmix_edge*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_vmix_edge_passed.txt
echo !_f!>%TEMP%\test_vmix_edge_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)
