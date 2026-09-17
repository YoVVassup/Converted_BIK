@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: MP3_to_WAV.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "MP3=%~dp0..\MP3_to_WAV.bat"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"

rem --- empty directory (no MP3) ---
set "ED=%TEMP%\mp3_empty"
if exist "%ED%" rmdir /s /q "%ED%"
mkdir "%ED%"
cmd.exe /c ""%MP3%" -SOURCE:%ED%" > "%TEMP%\mp3_out1.txt" 2>&1
findstr /c:"No MP3 files found" "%TEMP%\mp3_out1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "empty dir shows no MP3") else (call :fail "empty dir shows no MP3")
rmdir /s /q "%ED%" 2>nul

rem --- DRY_RUN mode (feed custom path via stdin) ---
set "MD=%TEMP%\mp3_dry"
if exist "%MD%" rmdir /s /q "%MD%"
mkdir "%MD%"
mkdir "%MD%\Original"
echo dummy > "%MD%\Original\test.mp3"
(echo.%MD%) | cmd.exe /c ""%MP3%"" > "%TEMP%\mp3_out2.txt" 2>&1
findstr /c:"Found 1 MP3" "%TEMP%\mp3_out2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "found 1 MP3 via stdin path") else (call :fail "found 1 MP3 via stdin path")
rmdir /s /q "%MD%" 2>nul

rem --- multiple MP3s in subdirs ---
set "MM=%TEMP%\mp3_multi"
if exist "%MM%" rmdir /s /q "%MM%"
mkdir "%MM%\Original"
mkdir "%MM%\7wolf"
echo dummy > "%MM%\Original\test1.mp3"
echo dummy > "%MM%\Original\test2.mp3"
echo dummy > "%MM%\7wolf\test3.mp3"
(echo.%MM%) | cmd.exe /c ""%MP3%"" > "%TEMP%\mp3_out5.txt" 2>&1
findstr /c:"Found 3 MP3" "%TEMP%\mp3_out5.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "found 3 MP3 in subdirs") else (call :fail "found 3 MP3 in subdirs")
rmdir /s /q "%MM%" 2>nul

rem --- CMDParse defaults ---
("%CMDPARSE%" --mode:mp3_to_wav > "%TEMP%\mp3_cp.txt") 2>nul
set "OVERWRITE=0" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_cp.txt") do set "%%A=%%B"
call :chk "!DRY_RUN!" "0" "CMDParse: DRY_RUN default=0"
call :chk "!OVERWRITE!" "0" "CMDParse: OVERWRITE default=0"

rem --- CMDParse flags ---
("%CMDPARSE%" --mode:mp3_to_wav -DRY_RUN -OVERWRITE > "%TEMP%\mp3_cp2.txt") 2>nul
set "OVERWRITE=0" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\mp3_cp2.txt") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "CMDParse: DRY_RUN=1"
call :chk "!OVERWRITE!" "1" "CMDParse: OVERWRITE=1"

rem Cleanup
del "%TEMP%\mp3_out*.txt" 2>nul
del "%TEMP%\mp3_cp*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_mp3_full_passed.txt
echo !_f!>%TEMP%\test_mp3_full_failed.txt
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
