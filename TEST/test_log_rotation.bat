@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Log Rotation (config_loader.bat)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CFG=%~dp0..\config_loader.bat"

rem --- Test 1: Log rotation triggers on large file ---
set "TEST_LOG=%TEMP%\test_rotation_log.txt"

rem Remove old test files
if exist "%TEST_LOG%" del "%TEST_LOG%"
for %%F in ("%TEST_LOG%_*") do del "%%F" 2>nul

rem Create a 2MB test log file
powershell -NoProfile -Command "$buf = New-Object byte[] 2097152; [System.IO.File]::WriteAllBytes('%TEST_LOG%', $buf)"
for %%I in ("%TEST_LOG%") do call :chk "%%~zI" "2097152" "Log rotation: created 2MB file"

rem Run config_loader to trigger rotation (set LOGFILE AFTER calling config_loader)
call "%CFG%" 2>nul
set "LOGFILE=%TEST_LOG%"
call "%CFG%" 2>nul

rem Check if file was rotated (renamed with timestamp)
set "_found_rotated=0"
for %%F in ("%TEST_LOG%_*") do set "_found_rotated=1"
call :chk "!_found_rotated!" "1" "Log rotation: file was rotated"

rem --- Test 2: Small log is NOT rotated ---
set "SMALL_LOG=%TEMP%\test_small_log.txt"
if exist "%SMALL_LOG%" del "%SMALL_LOG%"
echo small > "%SMALL_LOG%"
call "%CFG%" 2>nul
set "LOGFILE=%SMALL_LOG%"
call "%CFG%" 2>nul
if exist "%SMALL_LOG%" (call :pass "Log rotation: small file NOT rotated") else (call :fail "Log rotation: small file NOT rotated")

rem Cleanup
if exist "%TEST_LOG%" del "%TEST_LOG%"
if exist "%SMALL_LOG%" del "%SMALL_LOG%"
for %%F in ("%TEMP%\test_rotation_log_*") do del "%%F" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_log_rotation_passed.txt
echo !_f!>%TEMP%\test_log_rotation_failed.txt
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
