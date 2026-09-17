@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: MP3_to_WAV.bat (edge cases)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CWD_BAK=%CD%"
cd /d "%~dp0.."

cmd.exe /c "MP3_to_WAV.bat -SOURCE:nonexist_xyz_mp3" < nul > "%TEMP%\mp3_edge1.txt" 2>&1
findstr /i "No MP3\|no file\|not found\|not exist\|WAV_Sound" "%TEMP%\mp3_edge1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "nonexistent SOURCE shows info") else (call :fail "nonexistent SOURCE shows info")

"%~dp0..\third-party\CMDParse\CMDParse.exe" --mode:mp3_to_wav > "%TEMP%\mp3_edge_cp.txt" 2>nul
set "DRY_RUN=" & set "OVERWRITE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_edge_cp.txt") do set "%%A=%%B"
if "!DRY_RUN!"=="0" (call :pass "DRY_RUN default=0") else (call :fail "DRY_RUN default: got=!DRY_RUN!")
if "!OVERWRITE!"=="0" (call :pass "OVERWRITE default=0") else (call :fail "OVERWRITE default: got=!OVERWRITE!")

"%~dp0..\third-party\CMDParse\CMDParse.exe" --mode:mp3_to_wav -DRY_RUN > "%TEMP%\mp3_edge_cp2.txt" 2>nul
set "DRY_RUN=" & set "OVERWRITE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_edge_cp2.txt") do set "%%A=%%B"
if "!DRY_RUN!"=="1" (call :pass "DRY_RUN=1 parsed") else (call :fail "DRY_RUN=1: got=!DRY_RUN!")

"%~dp0..\third-party\CMDParse\CMDParse.exe" --mode:mp3_to_wav -OVERWRITE > "%TEMP%\mp3_edge_cp3.txt" 2>nul
set "DRY_RUN=" & set "OVERWRITE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_edge_cp3.txt") do set "%%A=%%B"
if "!OVERWRITE!"=="1" (call :pass "OVERWRITE=1 parsed") else (call :fail "OVERWRITE=1: got=!OVERWRITE!")

"%~dp0..\third-party\CMDParse\CMDParse.exe" --mode:mp3_to_wav -DRY_RUN -OVERWRITE > "%TEMP%\mp3_edge_cp4.txt" 2>nul
set "DRY_RUN=" & set "OVERWRITE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_edge_cp4.txt") do set "%%A=%%B"
if "!DRY_RUN!"=="1" if "!OVERWRITE!"=="1" (call :pass "DRY_RUN+OVERWRITE both=1") else (call :fail "DRY_RUN+OVERWRITE: dry=!DRY_RUN! ow=!OVERWRITE!")

cd /d "%CWD_BAK%"
del "%TEMP%\mp3_edge*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_mp3_edge_passed.txt
echo !_f!>%TEMP%\test_mp3_edge_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
