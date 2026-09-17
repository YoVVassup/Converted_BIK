@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Validate_MIX.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "VALIDATE=%~dp0..\Validate_MIX.bat"
set "VD=%TEMP%\vmix_full_test"
set "CMDBAT=%~dp0create_mix.bat"

if exist "%VD%" rmdir /s /q "%VD%"
mkdir "%VD%"

call "%CMDBAT%" "%VD%\valid.mix"
cmd.exe /c ""%VALIDATE%" -SCAN_DIR:%VD%" > "%TEMP%\vmix_out1.txt" 2>&1

set /a _t+=1
findstr /c:"Total MIX files:" "%TEMP%\vmix_out1.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] shows Total stat) else (set /a _f+=1 & echo   [FAIL] shows Total stat)

set /a _t+=1
findstr /c:"Valid:" "%TEMP%\vmix_out1.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] shows Valid stat) else (set /a _f+=1 & echo   [FAIL] shows Valid stat)

set /a _t+=1
findstr /c:"Invalid:" "%TEMP%\vmix_out1.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] shows Invalid stat) else (set /a _f+=1 & echo   [FAIL] shows Invalid stat)

set /a _t+=1
findstr /c:"All MIX files OK" "%TEMP%\vmix_out1.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] shows all MIX files OK) else (set /a _f+=1 & echo   [FAIL] shows all MIX files OK)

set /a _t+=1
cmd.exe /c ""%VALIDATE%" -SCAN_DIR:%VD%\nonexist_xyz" > "%TEMP%\vmix_out4.txt" 2>&1
set "VEXIT=!errorlevel!"
if !VEXIT! neq 0 (set /a _p+=1 & echo   [PASS] nonexistent folder exits non-zero) else (set /a _f+=1 & echo   [FAIL] nonexistent folder exits non-zero)

set /a _t+=1
findstr /c:"ERROR" "%TEMP%\vmix_out4.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] nonexistent folder shows ERROR) else (set /a _f+=1 & echo   [FAIL] nonexistent folder shows ERROR)

mkdir "%VD%\empty_dir"
set /a _t+=1
cmd.exe /c ""%VALIDATE%" -SCAN_DIR:%VD%\empty_dir" > "%TEMP%\vmix_out5.txt" 2>&1
findstr /c:"Total MIX files: 0" "%TEMP%\vmix_out5.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] empty dir total=0) else (set /a _f+=1 & echo   [FAIL] empty dir total=0)

set /a _t+=1
findstr /c:"All MIX files OK" "%TEMP%\vmix_out5.txt" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] empty dir shows all OK) else (set /a _f+=1 & echo   [FAIL] empty dir shows all OK)

set /a _t+=1
cmd.exe /c ""%VALIDATE%" -SCAN_DIR:%VD%" >nul 2>nul
if !errorlevel! equ 0 (set /a _p+=1 & echo   [PASS] exit 0 for valid MIXes) else (set /a _f+=1 & echo   [FAIL] exit 0 for valid MIXes)

rmdir /s /q "%VD%" 2>nul
del "%TEMP%\vmix_out*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_validate_mix_passed.txt
echo !_f!>%TEMP%\test_validate_mix_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)
