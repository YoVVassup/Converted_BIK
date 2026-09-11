@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: config_loader.bat
echo ===================================================

set "_tests_run=0"
set "_tests_passed=0"
set "_tests_failed=0"

call "%~dp0..\config_loader.bat"

call :assert "!CCMIX_TOOL!" "third-party\CCMIX\ccmix.exe" "CCMIX_TOOL default path"
call :assert "!FINAL_RA2!" "Final_BIK_RA2" "FINAL_RA2 default path"
call :assert "!LOGFILE!" "conversion_log.txt" "LOGFILE from config.ini"
call :assert "!BUILD_ROOT!" "Build" "BUILD_ROOT default path"
set "_t=0"
if defined CCMIX_TOOL set "_t=1"
call :assert "!_t!" "1" "Variables accessible after call"

echo.
echo Results: !_tests_passed!/!_tests_run! passed, !_tests_failed! failed
echo !_tests_passed!>%TEMP%\test_config_loader_passed.txt
echo !_tests_failed!>%TEMP%\test_config_loader_failed.txt
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
