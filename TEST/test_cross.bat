@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Cross_Converted_BIK.bat logic
echo ===================================================

set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
set "_tests_run=0"
set "_tests_passed=0"
set "_tests_failed=0"
set "_out=%TEMP%\cross_test_out.txt"

"%CMDPARSE%" --mode:cross > "%_out%" 2>nul
call :load_vars
call :assert "!PROCESS_RA1!" "1" "cross no args: RA1=1"
call :assert "!PROCESS_RA2!" "1" "cross no args: RA2=1"
call :assert "!PROCESS_RA2YR!" "1" "cross no args: RA2YR=1"

"%CMDPARSE%" --mode:cross -GAME:RA1 > "%_out%" 2>nul
call :load_vars
call :assert "!PROCESS_RA1!" "1" "cross -GAME:RA1: RA1=1"
call :assert "!PROCESS_RA2!" "0" "cross -GAME:RA1: RA2=0"
call :assert "!PROCESS_RA2YR!" "0" "cross -GAME:RA1: RA2YR=0"

rem RESOLUTION_FILTER findstr tests
set "RESOLUTION_FILTER=600p"
set "res=600p"
echo ";!RESOLUTION_FILTER!;" | findstr /i /c:";!res!;" >nul
if !errorlevel! equ 0 (call :pass "findstr: 600p in 600p") else (call :fail "findstr: 600p in 600p")

set "RESOLUTION_FILTER=600p;720p"
set "res=720p"
echo ";!RESOLUTION_FILTER!;" | findstr /i /c:";!res!;" >nul
if !errorlevel! equ 0 (call :pass "findstr: 720p in 600p;720p") else (call :fail "findstr: 720p in 600p;720p")

set "RESOLUTION_FILTER=600p;720p"
set "res=900p"
echo ";!RESOLUTION_FILTER!;" | findstr /i /c:";!res!;" >nul
if !errorlevel! equ 1 (call :pass "findstr: 900p rejected") else (call :fail "findstr: 900p rejected")

del "%_out%" 2>nul
echo.
echo Results: !_tests_passed!/!_tests_run! passed, !_tests_failed! failed
echo !_tests_passed!>%TEMP%\test_cross_passed.txt
echo !_tests_failed!>%TEMP%\test_cross_failed.txt
if !_tests_failed! gtr 0 (exit /b 1) else (exit /b 0)

:assert
set /a _tests_run+=1
if "%~1"=="%~2" (
    set /a _tests_passed+=1
    echo   [PASS] %~3
) else (
    set /a _tests_failed+=1
    echo   [FAIL] %~3: expected="%~2" actual="%~1"
)
exit /b 0

:pass
set /a _tests_passed+=1
set /a _tests_run+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _tests_failed+=1
set /a _tests_run+=1
echo   [FAIL] %~1
exit /b 0

:load_vars
set "PROCESS_RA1=0"
set "PROCESS_RA2=0"
set "PROCESS_RA2YR=0"
set "GROUP_FILTER="
set "RESOLUTION_FILTER="
set "INCLUDE_NOFORMAT=0"
set "DRY_RUN=0"
set "INCREMENTAL=0"
set "RETRY=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
exit /b 0
