@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: config_loader.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"

rem --- defaults are set when calling config_loader ---
call "%~dp0..\config_loader.bat"

rem --- core defaults exist ---
if defined NEW_RAD (call :pass "NEW_RAD is set") else (call :fail "NEW_RAD is set")
if defined OLD_MIX (call :pass "OLD_MIX is set") else (call :fail "OLD_MIX is set")
if defined CCMIX_TOOL (call :pass "CCMIX_TOOL is set") else (call :fail "CCMIX_TOOL is set")
if defined BINK_PLAY (call :pass "BINK_PLAY is set") else (call :fail "BINK_PLAY is set")
if defined MP4_SOURCE (call :pass "MP4_SOURCE is set") else (call :fail "MP4_SOURCE is set")
if defined SOUND_SOURCE (call :pass "SOUND_SOURCE is set") else (call :fail "SOUND_SOURCE is set")
if defined CLEAN_BIK (call :pass "CLEAN_BIK is set") else (call :fail "CLEAN_BIK is set")
if defined FINAL_RA1 (call :pass "FINAL_RA1 is set") else (call :fail "FINAL_RA1 is set")
if defined FINAL_RA2 (call :pass "FINAL_RA2 is set") else (call :fail "FINAL_RA2 is set")
if defined FINAL_RA2YR (call :pass "FINAL_RA2YR is set") else (call :fail "FINAL_RA2YR is set")
if defined BUILD_ROOT (call :pass "BUILD_ROOT is set") else (call :fail "BUILD_ROOT is set")
if defined LOGFILE (call :pass "LOGFILE is set") else (call :fail "LOGFILE is set")
if defined FAILED_FILE (call :pass "FAILED_FILE is set") else (call :fail "FAILED_FILE is set")

rem --- HIDE_WINDOW default (downgraded to 0 when run_hidden.vbs missing) ---
call :chk "!HIDE_WINDOW!" "0" "HIDE_WINDOW=0 no run_hidden.vbs"

rem --- config.ini values override defaults ---
call :chk "!MP4_SOURCE!" "Clean_MP4" "MP4_SOURCE from config.ini"
call :chk "!SOUND_SOURCE!" "WAV_Sound" "SOUND_SOURCE from config.ini"
call :chk "!BUILD_ROOT!" "Build" "BUILD_ROOT from config.ini"
call :chk "!FINAL_RA1!" "Final_BIK_RA1" "FINAL_RA1 from config.ini"
call :chk "!FINAL_RA2!" "Final_BIK_RA2" "FINAL_RA2 from config.ini"
call :chk "!FINAL_RA2YR!" "Final_BIK_RA2YR" "FINAL_RA2YR from config.ini"
call :chk "!CLEAN_BIK!" "Clean_BIK" "CLEAN_BIK from config.ini"
call :chk "!LOGFILE!" "conversion_log.txt" "LOGFILE from config.ini"
call :chk "!FAILED_FILE!" "failed.txt" "FAILED_FILE from config.ini"

rem --- LOGFILE/FAILED_FILE accessible after call ---
if defined LOGFILE (call :pass "LOGFILE accessible after config_loader") else (call :fail "LOGFILE accessible after config_loader")
if defined FAILED_FILE (call :pass "FAILED_FILE accessible after config_loader") else (call :fail "FAILED_FILE accessible after config_loader")

rem --- RUN_HIDDEN ---
if defined RUN_HIDDEN (call :pass "RUN_HIDDEN is set") else (call :fail "RUN_HIDDEN is set")

rem --- CONFIG_FILE path exists ---
if exist "%CONFIG_FILE%" (call :pass "config.ini found") else (call :fail "config.ini found")

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_config_full_passed.txt
echo !_f!>%TEMP%\test_config_full_failed.txt
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
