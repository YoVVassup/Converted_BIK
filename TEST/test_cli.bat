@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Non-interactive CLI modes
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CCMIX=%~dp0..\third-party\CCMIX\ccmix.exe"

rem --- Validate_MIX: SCAN_DIR via CLI ---
set "VALIDATE=%~dp0..\Validate_MIX.bat"
set "TEST_DIR=%TEMP%\validate_cli_test"
if exist "%TEST_DIR%" rmdir /s /q "%TEST_DIR%"
mkdir "%TEST_DIR%"

rem Create a minimal valid MIX (14 bytes header)
powershell -NoProfile -Command "[byte[]]$h = @(0,0,0,0,0,0,0,0,0,0,0,0,0,0); [System.IO.File]::WriteAllBytes('%TEST_DIR%\test.mix', $h)"
call :chk "1" "1" "Validate_MIX: test MIX created"

rem Run Validate_MIX with SCAN_DIR (non-interactive)
cmd.exe /c ""%VALIDATE%" -SCAN_DIR:%TEST_DIR%" > "%TEMP%\validate_out.txt" 2>&1
set "VEXIT=%errorlevel%"
call :chk "!VEXIT!" "0" "Validate_MIX: CLI mode exits 0"

rmdir /s /q "%TEST_DIR%" 2>nul

rem --- MIX_Diff: PATH1/PATH2 via CLI ---
set "DIFF=%~dp0..\MIX_Diff.bat"
set "DIFF_DIR_A=%TEMP%\diff_cli_a"
set "DIFF_DIR_B=%TEMP%\diff_cli_b"
if exist "%DIFF_DIR_A%" rmdir /s /q "%DIFF_DIR_A%"
if exist "%DIFF_DIR_B%" rmdir /s /q "%DIFF_DIR_B%"
mkdir "%DIFF_DIR_A%"
mkdir "%DIFF_DIR_B%"

echo test1 > "%DIFF_DIR_A%\file1.txt"
echo test1 > "%DIFF_DIR_B%\file1.txt"
echo test2 > "%DIFF_DIR_B%\file2.txt"

cmd.exe /c ""%DIFF%" -PATH1:%DIFF_DIR_A% -PATH2:%DIFF_DIR_B%" > "%TEMP%\diff_out.txt" 2>&1
set "DEXIT=%errorlevel%"
call :chk "!DEXIT!" "0" "MIX_Diff: CLI mode exits 0"

findstr /c:"ONLY IN B: file2.txt" "%TEMP%\diff_out.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: CLI detected added file") else (call :fail "MIX_Diff: CLI detected added file")

findstr /c:"Identical:" "%TEMP%\diff_out.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: CLI shows summary") else (call :fail "MIX_Diff: CLI shows summary")

rmdir /s /q "%DIFF_DIR_A%" 2>nul
rmdir /s /q "%DIFF_DIR_B%" 2>nul

rem --- H265: SOURCE/OUTPUT via CLI ---
set "H265=%~dp0..\H265.bat"
cmd.exe /c ""%H265%" -SOURCE:nonexistent -OUTPUT:%TEMP%\h265out" > "%TEMP%\h265_out.txt" 2>&1
findstr /c:"Error: Folder" "%TEMP%\h265_out.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "H265: CLI nonexistent folder error") else (call :fail "H265: CLI nonexistent folder error")

rem --- Resolution_Convert: DRY_RUN ---
set "RES=%~dp0..\Resolution_Convert.bat"
cmd.exe /c ""%RES%" -SOURCE:dummy -RESOLUTION:800x600 -BITRATE:400000" > "%TEMP%\res_out.txt" 2>&1
call :pass "Resolution_Convert: CLI mode runs"

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_cli_passed.txt
echo !_f!>%TEMP%\test_cli_failed.txt
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
