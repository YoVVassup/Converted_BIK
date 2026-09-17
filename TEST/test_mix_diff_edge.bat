@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: MIX_Diff.bat (edge cases)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "MDIFF=%~dp0..\MIX_Diff.bat"
set "TEST_DIR=%TEMP%\mdiff_edge"
set "DIR_A=%TEST_DIR%\dir_a"
set "DIR_B=%TEST_DIR%\dir_b"
if exist "%TEST_DIR%" rmdir /s /q "%TEST_DIR%"
mkdir "%DIR_A%"
mkdir "%DIR_B%"

powershell -File "%~dp0create_mix.ps1" "%DIR_A%\test1.mix" 2>nul
cmd.exe /c "copy /y "%DIR_A%\test1.mix" "%DIR_B%\test1.mix" >nul"

cmd.exe /c ""%MDIFF%" -PATH1:"%DIR_A%" -PATH2:"%DIR_B%"" < nul > "%TEMP%\mdiff_edge1.txt" 2>&1
findstr /i "Identical: 1" "%TEMP%\mdiff_edge1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "identical dirs recognized") else (call :fail "identical dirs recognized")

cmd.exe /c "echo dummy > "%DIR_B%\added.mix""
cmd.exe /c ""%MDIFF%" -PATH1:"%DIR_A%" -PATH2:"%DIR_B%"" < nul > "%TEMP%\mdiff_edge2.txt" 2>&1
findstr /i "ONLY IN B: added.mix" "%TEMP%\mdiff_edge2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "added file detected") else (call :fail "added file detected")
findstr /i "Added: 1" "%TEMP%\mdiff_edge2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Added count correct") else (call :fail "Added count correct")

cmd.exe /c "del "%DIR_B%\added.mix" >nul 2>nul"
cmd.exe /c "echo different > "%DIR_B%\test1.mix""
cmd.exe /c ""%MDIFF%" -PATH1:"%DIR_A%" -PATH2:"%DIR_B%"" < nul > "%TEMP%\mdiff_edge3.txt" 2>&1
findstr /i "MODIFIED: test1.mix" "%TEMP%\mdiff_edge3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "modified file detected") else (call :fail "modified file detected")
findstr /i "Modified: 1" "%TEMP%\mdiff_edge3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Modified count correct") else (call :fail "Modified count correct")

findstr /i "Added:" "%TEMP%\mdiff_edge3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Added summary line") else (call :fail "Added summary line")
findstr /i "Removed:" "%TEMP%\mdiff_edge3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Removed summary line") else (call :fail "Removed summary line")

mkdir "%DIR_A%\sub1" 2>nul
mkdir "%DIR_B%\sub1" 2>nul
cmd.exe /c "copy /y "%DIR_A%\test1.mix" "%DIR_A%\sub1\test2.mix" >nul"
cmd.exe /c "copy /y "%DIR_A%\test1.mix" "%DIR_B%\sub1\test2.mix" >nul"
cmd.exe /c "copy /y "%DIR_B%\test1.mix" "%DIR_A%\test1.mix" >nul"
cmd.exe /c ""%MDIFF%" -PATH1:"%DIR_A%" -PATH2:"%DIR_B%"" < nul > "%TEMP%\mdiff_edge4.txt" 2>&1
findstr /i "Identical: 3" "%TEMP%\mdiff_edge4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "subdir files counted") else (call :fail "subdir files counted")

rmdir /s /q "%TEST_DIR%" 2>nul
del "%TEMP%\mdiff_edge*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_mdiff_edge_passed.txt
echo !_f!>%TEMP%\test_mdiff_edge_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
