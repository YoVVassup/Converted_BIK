@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Resolution_Convert.bat (error paths)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "RES=%~dp0..\Resolution_Convert.bat"
set "PROJ=%~dp0.."
set "CWD_BAK=%CD%"
cd /d "%PROJ%"

set "DUMMY=%TEMP%\res_edge_dummy.bik"
echo dummy > "%DUMMY%"

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:%TEMP%\nonexist_xyz.bik -RES:800x600 -BITRATE:400000" > "%TEMP%\res_edge2.txt" 2>&1
findstr /i "File not found" "%TEMP%\res_edge2.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] nonexistent file shows error) else (set /a _f+=1 & echo   [FAIL] nonexistent file shows error)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -BITRATE:400000" > "%TEMP%\res_edge3.txt" 2>&1
findstr /i "ERROR" "%TEMP%\res_edge3.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] missing RESOLUTION shows error) else (set /a _f+=1 & echo   [FAIL] missing RESOLUTION shows error)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -RES:800x600" > "%TEMP%\res_edge4.txt" 2>&1
findstr /i "ERROR" "%TEMP%\res_edge4.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] missing BITRATE shows error) else (set /a _f+=1 & echo   [FAIL] missing BITRATE shows error)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -RES:badformat -BITRATE:400000" > "%TEMP%\res_edge5.txt" 2>&1
findstr /i "ERROR" "%TEMP%\res_edge5.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] invalid resolution format) else (set /a _f+=1 & echo   [FAIL] invalid resolution format)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -RES:800x600 -BITRATE:9999999" > "%TEMP%\res_edge6.txt" 2>&1
findstr /i "ERROR" "%TEMP%\res_edge6.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] bitrate exceeding limit) else (set /a _f+=1 & echo   [FAIL] bitrate exceeding limit)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -RES:800x600 -BITRATE:0" > "%TEMP%\res_edge7.txt" 2>&1
findstr /i "ERROR" "%TEMP%\res_edge7.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] bitrate 0 rejected) else (set /a _f+=1 & echo   [FAIL] bitrate 0 rejected)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -RES:800x600 -BITRATE:-100" > "%TEMP%\res_edge8.txt" 2>&1
findstr /i "ERROR" "%TEMP%\res_edge8.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] negative bitrate rejected) else (set /a _f+=1 & echo   [FAIL] negative bitrate rejected)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -RES:800x600 -BITRATE:1200000 -DRY_RUN" > "%TEMP%\res_edge9.txt" 2>&1
findstr /i "ERROR" "%TEMP%\res_edge9.txt" >nul 2>nul
if !errorlevel! neq 0 (set /a _p+=1 & echo   [PASS] bitrate 1200000 at limit accepted) else (set /a _f+=1 & echo   [FAIL] bitrate 1200000 at limit accepted)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -RES:800x600 -BITRATE:1200001" > "%TEMP%\res_edge10.txt" 2>&1
findstr /i "ERROR" "%TEMP%\res_edge10.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] bitrate 1200001 rejected) else (set /a _f+=1 & echo   [FAIL] bitrate 1200001 rejected)

set /a _t+=1
cmd.exe /c "cd /d "%PROJ%" && "%RES%" -INPUT:!DUMMY! -RES:800x600 -BITRATE:400000 -DRY_RUN" > "%TEMP%\res_edge11.txt" 2>&1
findstr /i "DRY_RUN" "%TEMP%\res_edge11.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] DRY_RUN mode works) else (set /a _f+=1 & echo   [FAIL] DRY_RUN mode works)

del "%DUMMY%" 2>nul
cd /d "%CWD_BAK%"
del "%TEMP%\res_edge*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_res_edge_passed.txt
echo !_f!>%TEMP%\test_res_edge_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)
