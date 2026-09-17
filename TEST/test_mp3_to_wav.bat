@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: MP3_to_WAV.bat
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "SCRIPT=%~dp0..\MP3_to_WAV.bat"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"

rem === CMDParse mode tests ===

rem --- Test: mp3_to_wav defaults ---
("%CMDPARSE%" --mode:mp3_to_wav > "%TEMP%\mp3_test.txt") 2>nul
set "DRY_RUN=0" & set "OVERWRITE=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_test.txt") do set "%%A=%%B"
call :chk "!DRY_RUN!" "0" "mp3_to_wav defaults: dry=0"
call :chk "!OVERWRITE!" "0" "mp3_to_wav defaults: ow=0"

rem --- Test: DRY_RUN flag ---
("%CMDPARSE%" --mode:mp3_to_wav -DRY_RUN > "%TEMP%\mp3_test.txt") 2>nul
set "DRY_RUN=0" & set "OVERWRITE=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_test.txt") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "mp3_to_wav -DRY_RUN: dry=1"
call :chk "!OVERWRITE!" "0" "mp3_to_wav -DRY_RUN: ow=0"

rem --- Test: OVERWRITE flag ---
("%CMDPARSE%" --mode:mp3_to_wav -OVERWRITE > "%TEMP%\mp3_test.txt") 2>nul
set "DRY_RUN=0" & set "OVERWRITE=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_test.txt") do set "%%A=%%B"
call :chk "!DRY_RUN!" "0" "mp3_to_wav -OVERWRITE: dry=0"
call :chk "!OVERWRITE!" "1" "mp3_to_wav -OVERWRITE: ow=1"

rem --- Test: both flags ---
("%CMDPARSE%" --mode:mp3_to_wav -DRY_RUN -OVERWRITE > "%TEMP%\mp3_test.txt") 2>nul
set "DRY_RUN=0" & set "OVERWRITE=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_test.txt") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "mp3_to_wav -DRY_RUN -OVERWRITE: dry=1"
call :chk "!OVERWRITE!" "1" "mp3_to_wav -DRY_RUN -OVERWRITE: ow=1"

rem === Script behavior tests ===

rem --- Test: Script creates temp file for args and cleans up ---
set "TEST_SOUND=%TEMP%\mp3_test_sound"
if exist "%TEST_SOUND%" rmdir /s /q "%TEST_SOUND%"
mkdir "%TEST_SOUND%"
echo. > "%TEST_SOUND%\test.mp3"

rem The script requires interactive input, so we test error paths
rem --- Test: No MP3 files found path ---
mkdir "%TEST_SOUND%\empty_group" 2>nul
cmd.exe /c "set SOUND_SOURCE=%TEST_SOUND%\empty_group && call "%SCRIPT%" -DRY_RUN" > "%TEMP%\mp3_out_empty.txt" 2>&1
findstr /c:"No MP3 files" "%TEMP%\mp3_out_empty.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Script: no MP3 files message") else (call :fail "Script: no MP3 files message")

rem Cleanup
rmdir /s /q "%TEST_SOUND%" 2>nul
del "%TEMP%\mp3_test.txt" 2>nul
del "%TEMP%\mp3_out_empty.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_mp3_to_wav_passed.txt
echo !_f!>%TEMP%\test_mp3_to_wav_failed.txt
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
