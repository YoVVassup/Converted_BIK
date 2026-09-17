@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: config_loader.bat (edge cases)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"

rem --- Test: defaults are set when calling config_loader ---
call "%~dp0..\config_loader.bat"
if defined NEW_RAD (call :pass "defaults: NEW_RAD set") else (call :fail "defaults: NEW_RAD set")
if defined OLD_MIX (call :pass "defaults: OLD_MIX set") else (call :fail "defaults: OLD_MIX set")
if defined CCMIX_TOOL (call :pass "defaults: CCMIX_TOOL set") else (call :fail "defaults: CCMIX_TOOL set")
if defined FFMPEG_PATH (call :pass "defaults: FFMPEG_PATH set") else (call :fail "defaults: FFMPEG_PATH set")
if defined BINK_PLAY (call :pass "defaults: BINK_PLAY set") else (call :fail "defaults: BINK_PLAY set")
if defined MP4_SOURCE (call :pass "defaults: MP4_SOURCE set") else (call :fail "defaults: MP4_SOURCE set")
if defined SOUND_SOURCE (call :pass "defaults: SOUND_SOURCE set") else (call :fail "defaults: SOUND_SOURCE set")
if defined FINAL_RA1 (call :pass "defaults: FINAL_RA1 set") else (call :fail "defaults: FINAL_RA1 set")
if defined FINAL_RA2 (call :pass "defaults: FINAL_RA2 set") else (call :fail "defaults: FINAL_RA2 set")
if defined FINAL_RA2YR (call :pass "defaults: FINAL_RA2YR set") else (call :fail "defaults: FINAL_RA2YR set")
if defined BUILD_ROOT (call :pass "defaults: BUILD_ROOT set") else (call :fail "defaults: BUILD_ROOT set")
if defined LOGFILE (call :pass "defaults: LOGFILE set") else (call :fail "defaults: LOGFILE set")
if defined FAILED_FILE (call :pass "defaults: FAILED_FILE set") else (call :fail "defaults: FAILED_FILE set")

rem --- Test: config.ini overrides loaded ---
if "!MP4_SOURCE!"=="Clean_MP4" (call :pass "config.ini: MP4_SOURCE default") else (call :fail "MP4_SOURCE: got=!MP4_SOURCE!")
if "!SOUND_SOURCE!"=="WAV_Sound" (call :pass "config.ini: SOUND_SOURCE default") else (call :fail "SOUND_SOURCE: got=!SOUND_SOURCE!")
if "!BUILD_ROOT!"=="Build" (call :pass "config.ini: BUILD_ROOT default") else (call :fail "BUILD_ROOT: got=!BUILD_ROOT!")
if "!FINAL_RA1!"=="Final_BIK_RA1" (call :pass "config.ini: FINAL_RA1 default") else (call :fail "FINAL_RA1: got=!FINAL_RA1!")
if "!FINAL_RA2!"=="Final_BIK_RA2" (call :pass "config.ini: FINAL_RA2 default") else (call :fail "FINAL_RA2: got=!FINAL_RA2!")
if "!FINAL_RA2YR!"=="Final_BIK_RA2YR" (call :pass "config.ini: FINAL_RA2YR default") else (call :fail "FINAL_RA2YR: got=!FINAL_RA2YR!")
if "!CLEAN_BIK!"=="Clean_BIK" (call :pass "config.ini: CLEAN_BIK default") else (call :fail "CLEAN_BIK: got=!CLEAN_BIK!")
if "!LOGFILE!"=="conversion_log.txt" (call :pass "config.ini: LOGFILE default") else (call :fail "LOGFILE: got=!LOGFILE!")
if "!FAILED_FILE!"=="failed.txt" (call :pass "config.ini: FAILED_FILE default") else (call :fail "FAILED_FILE: got=!FAILED_FILE!")
if "!NEW_RAD!"=="third-party\Radtools_New\radvideo64.exe" (call :pass "config.ini: radtools_new") else (call :fail "radtools_new: got=!NEW_RAD!")
if "!OLD_MIX!"=="third-party\Radtools_Old\BinkMix.exe" (call :pass "config.ini: radtools_old") else (call :fail "radtools_old: got=!OLD_MIX!")
if "!CCMIX_TOOL!"=="third-party\CCMIX\ccmix.exe" (call :pass "config.ini: ccmix") else (call :fail "ccmix: got=!CCMIX_TOOL!")
if "!FFMPEG_PATH!"=="third-party\ffmpeg.exe" (call :pass "config.ini: ffmpeg") else (call :fail "ffmpeg: got=!FFMPEG_PATH!")
if "!BINK_PLAY!"=="third-party\Radtools_New\binkplay.exe" (call :pass "config.ini: binkplay") else (call :fail "binkplay: got=!BINK_PLAY!")

rem --- Test: HIDE_WINDOW downgrades when run_hidden.vbs missing ---
if "!HIDE_WINDOW!"=="0" (call :pass "HIDE_WINDOW=0 when run_hidden.vbs missing") else (call :fail "HIDE_WINDOW: got=!HIDE_WINDOW!")

rem --- Test: RUN_HIDDEN is set ---
if defined RUN_HIDDEN (call :pass "RUN_HIDDEN is set") else (call :fail "RUN_HIDDEN is set")

rem --- Test: config.ini file exists ---
if exist "%CONFIG_FILE%" (call :pass "config.ini found") else (call :fail "config.ini found")

rem --- Test: variables accessible after config_loader call ---
if defined LOGFILE (call :pass "LOGFILE accessible after call") else (call :fail "LOGFILE accessible after call")
if defined FAILED_FILE (call :pass "FAILED_FILE accessible after call") else (call :fail "FAILED_FILE accessible after call")

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_cfg_edge_passed.txt
echo !_f!>%TEMP%\test_cfg_edge_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
