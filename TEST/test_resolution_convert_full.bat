@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Resolution_Convert.bat (full CLI paths)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "RES=%~dp0..\Resolution_Convert.bat"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"

set "RDT=%TEMP%\res_full_test"
if exist "%RDT%" rmdir /s /q "%RDT%"
mkdir "%RDT%"
echo dummy > "%RDT%\test.bik"

set /a _t+=1
cmd.exe /c ""%RES%" -INPUT:nonexist_xyz.bik -RES:800x600 -BITRATE:400000" > "%TEMP%\res_out1.txt" 2>&1
findstr /c:"not found" "%TEMP%\res_out1.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] nonexistent file shows error) else (set /a _f+=1 & echo   [FAIL] nonexistent file shows error)

set /a _t+=1
cmd.exe /c ""%RES%" -INPUT:%RDT%\test.bik -BITRATE:400000" > "%TEMP%\res_out2.txt" 2>&1
findstr /c:"-RES:WIDTHxHEIGHT required" "%TEMP%\res_out2.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] missing RESOLUTION shows error) else (set /a _f+=1 & echo   [FAIL] missing RESOLUTION shows error)

set /a _t+=1
cmd.exe /c ""%RES%" -INPUT:%RDT%\test.bik -RES:800x600" > "%TEMP%\res_out3.txt" 2>&1
findstr /c:"-BITRATE:bps required" "%TEMP%\res_out3.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] missing BITRATE shows error) else (set /a _f+=1 & echo   [FAIL] missing BITRATE shows error)

set /a _t+=1
cmd.exe /c ""%RES%" -INPUT:%RDT%\test.bik -RES:badformat -BITRATE:400000" > "%TEMP%\res_out4.txt" 2>&1
findstr /c:"Invalid resolution" "%TEMP%\res_out4.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] invalid resolution shows error) else (set /a _f+=1 & echo   [FAIL] invalid resolution shows error)

set /a _t+=1
cmd.exe /c ""%RES%" -INPUT:%RDT%\test.bik -RES:800x600 -BITRATE:9999999" > "%TEMP%\res_out5.txt" 2>&1
findstr /c:"exceeds" "%TEMP%\res_out5.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] bitrate exceeding limit rejected) else (set /a _f+=1 & echo   [FAIL] bitrate exceeding limit rejected)

set /a _t+=1
cmd.exe /c ""%RES%" -INPUT:%RDT%\test.bik -RES:800x600 -BITRATE:0" > "%TEMP%\res_out6.txt" 2>&1
findstr /c:"positive" "%TEMP%\res_out6.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] bitrate 0 rejected) else (set /a _f+=1 & echo   [FAIL] bitrate 0 rejected)

set /a _t+=1
cmd.exe /c ""%RES%" -INPUT:nonexist.mp4 -RES:800x600 -BITRATE:400000" > "%TEMP%\res_out7.txt" 2>&1
findstr /c:"not found" "%TEMP%\res_out7.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] MP4 routing shows error) else (set /a _f+=1 & echo   [FAIL] MP4 routing shows error)

set /a _t+=1
cmd.exe /c ""%RES%" -INPUT:%RDT%\test.bik -RES:800x600 -BITRATE:400000 -DRY_RUN" > "%TEMP%\res_out8.txt" 2>&1
findstr /c:"DRY_RUN" "%TEMP%\res_out8.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] DRY_RUN mode works) else (set /a _f+=1 & echo   [FAIL] DRY_RUN mode works)

set /a _t+=1
findstr /c:"New resolution: 800x600" "%TEMP%\res_out8.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] shows resolution info) else (set /a _f+=1 & echo   [FAIL] shows resolution info)

set /a _t+=1 & set "INPUT=" & set "RESOLUTION=" & set "BITRATE=" & set "DRY_RUN=0"
("%CMDPARSE%" --mode:resolution -INPUT:test.bik -RES:1280x720 -BITRATE:600000 -DRY_RUN > "%TEMP%\res_cp.txt") 2>nul
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\res_cp.txt") do set "%%A=%%B"
if "!INPUT!"=="test.bik" (set /a _p+=1 & echo   [PASS] CMDParse: INPUT parsed) else (set /a _f+=1 & echo   [FAIL] CMDParse: INPUT parsed)

set /a _t+=1
if "!RESOLUTION!"=="1280x720" (set /a _p+=1 & echo   [PASS] CMDParse: RESOLUTION parsed) else (set /a _f+=1 & echo   [FAIL] CMDParse: RESOLUTION parsed)

set /a _t+=1
if "!BITRATE!"=="600000" (set /a _p+=1 & echo   [PASS] CMDParse: BITRATE parsed) else (set /a _f+=1 & echo   [FAIL] CMDParse: BITRATE parsed)

set /a _t+=1
if "!DRY_RUN!"=="1" (set /a _p+=1 & echo   [PASS] CMDParse: DRY_RUN parsed) else (set /a _f+=1 & echo   [FAIL] CMDParse: DRY_RUN parsed)

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_res_full_passed.txt
echo !_f!>%TEMP%\test_res_full_failed.txt

rmdir /s /q "%RDT%" 2>nul
del "%TEMP%\res_out*.txt" 2>nul
del "%TEMP%\res_cp.txt" 2>nul

if !_f! gtr 0 (exit /b 1) else (exit /b 0)
