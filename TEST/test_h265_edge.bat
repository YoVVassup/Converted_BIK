@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: H265.bat (ffmpeg discovery + edge cases)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CWD_BAK=%CD%"
cd /d "%~dp0.."

cmd.exe /c "H265.bat -SOURCE:nonexist_xyz_h265" < nul > "%TEMP%\h265_edge1.txt" 2>&1
findstr /i "error\|not found\|not exist\|does not exist" "%TEMP%\h265_edge1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "nonexistent SOURCE shows error") else (call :fail "nonexistent SOURCE shows error")

set "HD2=%TEMP%\h265_edge_dry"
if exist "%HD2%" rmdir /s /q "%HD2%"
mkdir "%HD2%"
echo dummy > "%HD2%\test.mp4"
echo dummy > "%HD2%\test2.mkv"
cmd.exe /c "H265.bat -SOURCE:%HD2% -OUTPUT:%TEMP%\h265_edge_out2 -DRY_RUN" < nul > "%TEMP%\h265_edge3.txt" 2>&1
findstr /i "DRY_RUN" "%TEMP%\h265_edge3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "DRY_RUN mode works") else (call :fail "DRY_RUN mode works")
findstr /i "Would convert\|Found\|file" "%TEMP%\h265_edge3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "DRY_RUN shows file count") else (call :fail "DRY_RUN shows file count")
findstr /i "Processed: 2\|2 video" "%TEMP%\h265_edge3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Processed: 2 summary") else (call :fail "Processed: 2 summary")
rmdir /s /q "%HD2%" 2>nul

set "HD3=%TEMP%\h265_edge_nonvid"
if exist "%HD3%" rmdir /s /q "%HD3%"
mkdir "%HD3%"
echo dummy > "%HD3%\video.mp4"
echo dummy > "%HD3%\readme.txt"
echo dummy > "%HD3%\image.jpg"
cmd.exe /c "H265.bat -SOURCE:%HD3% -OUTPUT:%TEMP%\h265_edge_out3 -DRY_RUN" < nul > "%TEMP%\h265_edge4.txt" 2>&1
findstr /i "Processed: 1\|1 video\|Found 1" "%TEMP%\h265_edge4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "only video files processed") else (call :fail "only video files processed")
rmdir /s /q "%HD3%" 2>nul

"%~dp0..\third-party\CMDParse\CMDParse.exe" --mode:h265 > "%TEMP%\h265_edge_cp.txt" 2>nul
set "SOURCE=" & set "OUTPUT=" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\h265_edge_cp.txt") do set "%%A=%%B"
if "!SOURCE!"=="" (call :pass "CMDParse: SOURCE default empty") else (call :fail "CMDParse: SOURCE default: got=!SOURCE!")
if "!DRY_RUN!"=="0" (call :pass "CMDParse: DRY_RUN default 0") else (call :fail "CMDParse: DRY_RUN default: got=!DRY_RUN!")

cd /d "%CWD_BAK%"
del "%TEMP%\h265_edge*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_h265_edge_passed.txt
echo !_f!>%TEMP%\test_h265_edge_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
