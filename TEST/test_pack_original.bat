@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Pack_Mixes_Original.bat logic
echo ===================================================

set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
set "_tests_run=0"
set "_tests_passed=0"
set "_tests_failed=0"
set "_out=%TEMP%\pack_orig_test_out.txt"

"%CMDPARSE%" --mode:pack_original -G:Original,7wolf > "%_out%" 2>nul
set "AUDIO_GROUP=" & set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :assert "!AUDIO_GROUP!" "Original;7wolf" "CMDParse: AUDIO_GROUP=Original;7wolf"

"%CMDPARSE%" --mode:pack_original -RES:720p > "%_out%" 2>nul
set "AUDIO_GROUP=" & set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :assert "!RESOLUTION!" "720p" "CMDParse: RESOLUTION=720p"

set "AUDIO_GROUP=Original;7wolf"
set "_g="
for %%G in (!AUDIO_GROUP!) do (
    if defined _g (set "_g=!_g! %%G") else (set "_g=%%G")
)
call :assert "!_g!" "Original 7wolf" "AUDIO_GROUP: splits"

set "AUDIO_GROUP=Original"
set "_c=0"
for %%G in (!AUDIO_GROUP!) do set /a _c+=1
call :assert "!_c!" "1" "AUDIO_GROUP: single count=1"

rem Default: CMDParse outputs nothing, so vars stay empty
"%CMDPARSE%" --mode:pack_original > "%_out%" 2>nul
set "AUDIO_GROUP="
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :assert "!AUDIO_GROUP!" "" "Default: AUDIO_GROUP empty"
call :assert "!RESOLUTION!" "" "Default: RESOLUTION empty"

del "%_out%" 2>nul
echo.
echo Results: !_tests_passed!/!_tests_run! passed, !_tests_failed! failed
echo !_tests_passed!>%TEMP%\test_pack_original_passed.txt
echo !_tests_failed!>%TEMP%\test_pack_original_failed.txt
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
