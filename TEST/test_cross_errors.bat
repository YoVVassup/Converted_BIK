@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Cross_Converted_BIK.bat (stats + modes)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CROSS=%~dp0..\Cross_Converted_BIK.bat"
set "CWD_BAK=%CD%"
cd /d "%~dp0.."

rem --- Test: STATISTICS line appears ---
cmd.exe /c ""%CROSS%" -GAME:RA2 -RES:600p -DRY_RUN" > "%TEMP%\cross_err1.txt" 2>&1
findstr /c:"STATISTICS" "%TEMP%\cross_err1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "STATISTICS output present") else (call :fail "STATISTICS output present")

rem --- Test: Time line appears ---
findstr /c:"Time:" "%TEMP%\cross_err1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Time line in statistics") else (call :fail "Time line in statistics")

rem --- Test: Total line appears ---
findstr /c:"Total:" "%TEMP%\cross_err1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Total line in statistics") else (call :fail "Total line in statistics")

rem --- Test: Processing RA2 present ---
findstr /c:"Processing: RA2" "%TEMP%\cross_err1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Processing: RA2 present") else (call :fail "Processing: RA2 present")

rem --- Test: DRY_RUN output ---
findstr /c:"DRY_RUN" "%TEMP%\cross_err1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "DRY_RUN output present") else (call :fail "DRY_RUN output present")

rem --- Test: Skipped count ---
findstr /c:"Skipped:" "%TEMP%\cross_err1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Skipped count in statistics") else (call :fail "Skipped count in statistics")

rem --- Test: -GAME:RA1 only processes RA1 ---
cmd.exe /c ""%CROSS%" -GAME:RA1 -DRY_RUN" > "%TEMP%\cross_err2.txt" 2>&1
findstr /c:"Processing: RA1" "%TEMP%\cross_err2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "-GAME:RA1 includes RA1") else (call :fail "-GAME:RA1 includes RA1")
findstr /c:"Processing: RA2" "%TEMP%\cross_err2.txt" >nul 2>nul
if !errorlevel! neq 0 (call :pass "-GAME:RA1 excludes RA2") else (call :fail "-GAME:RA1 excludes RA2")

rem --- Test: RETRY mode (RETRY flag in args means 0 errors) ---
cmd.exe /c ""%CROSS%" -GAME:RA2 -RES:600p -RETRY -DRY_RUN" > "%TEMP%\cross_err3.txt" 2>&1
findstr /c:"Total:" "%TEMP%\cross_err3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "RETRY mode runs and shows statistics") else (call :fail "RETRY mode runs and shows statistics")

rem --- Test: INCREMENTAL mode ---
cmd.exe /c ""%CROSS%" -GAME:RA2 -RES:600p -INCREMENTAL -DRY_RUN" > "%TEMP%\cross_err4.txt" 2>&1
findstr /c:"Total:" "%TEMP%\cross_err4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "INCREMENTAL mode runs and shows statistics") else (call :fail "INCREMENTAL mode runs and shows statistics")

rem Cleanup
cd /d "%CWD_BAK%"
del "%TEMP%\cross_err*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_cross_err_passed.txt
echo !_f!>%TEMP%\test_cross_err_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
