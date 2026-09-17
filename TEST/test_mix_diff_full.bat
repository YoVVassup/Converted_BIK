@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: MIX_Diff.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "DIFF=%~dp0..\MIX_Diff.bat"

set "DA=%TEMP%\mdiff_full_a"
set "DB=%TEMP%\mdiff_full_b"
if exist "%DA%" rmdir /s /q "%DA%"
if exist "%DB%" rmdir /s /q "%DB%"
mkdir "%DA%" & mkdir "%DB%"

rem --- identical directories ---
echo data > "%DA%\file1.txt"
echo data > "%DB%\file1.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DA% -PATH2:%DB%" > "%TEMP%\mdiff_out1.txt" 2>&1
findstr /c:"Identical:" "%TEMP%\mdiff_out1.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "identical dirs: Identical found") else (call :fail "identical dirs: Identical found")

rem --- added file (only in B) ---
echo new > "%DB%\newfile.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DA% -PATH2:%DB%" > "%TEMP%\mdiff_out2.txt" 2>&1
findstr /c:"ONLY IN B: newfile.txt" "%TEMP%\mdiff_out2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "added file detected") else (call :fail "added file detected")
findstr /c:"Added:" "%TEMP%\mdiff_out2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "summary shows Added count") else (call :fail "summary shows Added count")

rem --- removed file (only in A) ---
echo extra > "%DA%\removed.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DA% -PATH2:%DB%" > "%TEMP%\mdiff_out3.txt" 2>&1
findstr /c:"ONLY IN A: removed.txt" "%TEMP%\mdiff_out3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "removed file detected") else (call :fail "removed file detected")
findstr /c:"Removed:" "%TEMP%\mdiff_out3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "summary shows Removed count") else (call :fail "summary shows Removed count")

rem --- modified file (same name, different size) ---
echo original > "%DA%\mod_file.txt"
echo changed_content > "%DB%\mod_file.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DA% -PATH2:%DB%" > "%TEMP%\mdiff_out4.txt" 2>&1
findstr /c:"MODIFIED: mod_file.txt" "%TEMP%\mdiff_out4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "modified file detected") else (call :fail "modified file detected")
findstr /c:"Modified:" "%TEMP%\mdiff_out4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "summary shows Modified count") else (call :fail "summary shows Modified count")

rem --- subdirectory traversal ---
mkdir "%DA%\subdir"
mkdir "%DB%\subdir"
echo a > "%DA%\subdir\sub.txt"
echo long_content_here > "%DB%\subdir\sub.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DA% -PATH2:%DB%" > "%TEMP%\mdiff_out5.txt" 2>&1
findstr /c:"sub.txt" "%TEMP%\mdiff_out5.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "subdir file found in output") else (call :fail "subdir file found in output")
findstr /c:"MODIFIED:" "%TEMP%\mdiff_out5.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "subdir modification detected") else (call :fail "subdir modification detected")

rem --- nonexistent path ---
cmd.exe /c ""%DIFF%" -PATH1:%DA%\nonexist -PATH2:%DB%" > "%TEMP%\mdiff_out6.txt" 2>&1
findstr /i /c:"ERROR" "%TEMP%\mdiff_out6.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "nonexistent path shows error") else (call :fail "nonexistent path shows error")

rem --- mixed file/dir type error ---
echo file > "%DA%\is_a_file.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DA%\is_a_file.txt -PATH2:%DB%" > "%TEMP%\mdiff_out7.txt" 2>&1
findstr /i /c:"ERROR" "%TEMP%\mdiff_out7.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "mixed file/dir shows error") else (call :fail "mixed file/dir shows error")

rem Cleanup
rmdir /s /q "%DA%" 2>nul
rmdir /s /q "%DB%" 2>nul
del "%TEMP%\mdiff_out*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_mdiss_full_passed.txt
echo !_f!>%TEMP%\test_mdiss_full_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
