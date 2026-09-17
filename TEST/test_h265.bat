@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: H265.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "H265=%~dp0..\H265.bat"

rem --- nonexistent SOURCE ---
cmd.exe /c ""%H265%" -SOURCE:nonexist_h265 -OUTPUT:%TEMP%\h265out" > "%TEMP%\h265_out1.txt" 2>&1
findstr /c:"Error" "%TEMP%\h265_out1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "nonexistent SOURCE shows error") else (call :fail "nonexistent SOURCE shows error")

rem --- empty folder (no video files) ---
set "HD=%TEMP%\h265_empty"
if exist "%HD%" rmdir /s /q "%HD%"
mkdir "%HD%"
cmd.exe /c ""%H265%" -SOURCE:%HD% -OUTPUT:%TEMP%\h265out_empty" > "%TEMP%\h265_out2.txt" 2>&1
findstr /c:"No files found" "%TEMP%\h265_out2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "empty folder shows no files") else (call :fail "empty folder shows no files")
rmdir /s /q "%HD%" 2>nul

rem --- DRY_RUN with dummy MP4 ---
set "HD2=%TEMP%\h265_dry"
if exist "%HD2%" rmdir /s /q "%HD2%"
mkdir "%HD2%"
echo dummy > "%HD2%\test_video.mp4"
cmd.exe /c ""%H265%" -SOURCE:%HD2% -OUTPUT:%TEMP%\h265out_dry -DRY_RUN" > "%TEMP%\h265_out3.txt" 2>&1
findstr /c:"DRY_RUN" "%TEMP%\h265_out3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "DRY_RUN mode works") else (call :fail "DRY_RUN mode works")
findstr /c:"Would convert" "%TEMP%\h265_out3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "DRY_RUN shows would convert") else (call :fail "DRY_RUN shows would convert")
rmdir /s /q "%HD2%" 2>nul

rem --- CMDParse h265 mode ---
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
("%CMDPARSE%" --mode:h265 -SOURCE:mydir -OUTPUT:myout -DRY_RUN > "%TEMP%\h265_cp.txt") 2>nul
set "SOURCE=" & set "OUTPUT=" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\h265_cp.txt") do set "%%A=%%B"
call :chk "!SOURCE!" "mydir" "CMDParse: SOURCE parsed"
call :chk "!OUTPUT!" "myout" "CMDParse: OUTPUT parsed"
call :chk "!DRY_RUN!" "1" "CMDParse: DRY_RUN parsed"

rem --- h265 defaults ---
("%CMDPARSE%" --mode:h265 > "%TEMP%\h265_cp2.txt") 2>nul
set "SOURCE=" & set "OUTPUT=" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\h265_cp2.txt") do set "%%A=%%B"
call :chk "!SOURCE!" "" "CMDParse: SOURCE default empty"
call :chk "!DRY_RUN!" "0" "CMDParse: DRY_RUN default 0"

rem --- video file extensions handled ---
set "HD3=%TEMP%\h265_ext"
if exist "%HD3%" rmdir /s /q "%HD3%"
mkdir "%HD3%"
echo dummy > "%HD3%\test.mkv"
echo dummy > "%HD3%\test.mov"
echo dummy > "%HD3%\test.avi"
echo dummy > "%HD3%\test.ts"
echo dummy > "%HD3%\test.webm"
echo dummy > "%HD3%\test.flv"
echo dummy > "%HD3%\test.m4v"
cmd.exe /c ""%H265%" -SOURCE:%HD3% -OUTPUT:%TEMP%\h265out_ext -DRY_RUN" > "%TEMP%\h265_out4.txt" 2>&1
findstr /c:"Processing \[7\]" "%TEMP%\h265_out4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "counts 7 video files") else (call :fail "counts 7 video files")
findstr /c:"Processed: 7" "%TEMP%\h265_out4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "processed=7 summary") else (call :fail "processed=7 summary")
rmdir /s /q "%HD3%" 2>nul

rem Cleanup
del "%TEMP%\h265_out*.txt" 2>nul
del "%TEMP%\h265_cp*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_h265_passed.txt
echo !_f!>%TEMP%\test_h265_failed.txt
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
