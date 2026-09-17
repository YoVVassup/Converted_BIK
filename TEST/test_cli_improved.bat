@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Non-interactive CLI (improved coverage)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"

rem ======================================================
rem  Validate_MIX
rem ======================================================
set "VALIDATE=%~dp0..\Validate_MIX.bat"
set "VDIR=%TEMP%\validate_improved_test"
if exist "%VDIR%" rmdir /s /q "%VDIR%"
mkdir "%VDIR%"

rem --- Test: minimal valid MIX (14 bytes) ---
powershell -NoProfile -Command "[byte[]]$h = @(0,0,0,0,0,0,0,0,0,0,0,0,0,0); [System.IO.File]::WriteAllBytes('%VDIR%\test.mix', $h)"
if exist "%VDIR%\test.mix" (call :pass "Validate_MIX: test MIX created") else (call :fail "Validate_MIX: test MIX created")

rem --- Test: CLI mode exits 0 ---
cmd.exe /c ""%VALIDATE%" -SCAN_DIR:%VDIR%" > "%TEMP%\validate_imp_out.txt" 2>&1
set "VEXIT=!errorlevel!"
call :chk "!VEXIT!" "0" "Validate_MIX: CLI exits 0 on valid MIX"

rem --- Test: statistics output (Valid/Invalid/Total lines) ---
findstr /c:"Valid:" "%TEMP%\validate_imp_out.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Validate_MIX: shows Valid stat") else (call :fail "Validate_MIX: shows Valid stat")
findstr /c:"Invalid:" "%TEMP%\validate_imp_out.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "Validate_MIX: shows Invalid stat") else (call :fail "Validate_MIX: shows Invalid stat")

rem --- Test: nonexistent folder exits non-zero ---
cmd.exe /c ""%VALIDATE%" -SCAN_DIR:%TEMP%\nonexist_validate_xyz" > "%TEMP%\validate_imp_err.txt" 2>&1
set "VERR=!errorlevel!"
if !VERR! neq 0 (call :pass "Validate_MIX: nonexistent folder exits non-zero") else (call :fail "Validate_MIX: nonexistent folder exits non-zero")

rmdir /s /q "%VDIR%" 2>nul

rem ======================================================
rem  MIX_Diff
rem ======================================================
set "DIFF=%~dp0..\MIX_Diff.bat"
set "DDIR_A=%TEMP%\diff_imp_a"
set "DDIR_B=%TEMP%\diff_imp_b"
if exist "%DDIR_A%" rmdir /s /q "%DDIR_A%"
if exist "%DDIR_B%" rmdir /s /q "%DDIR_B%"
mkdir "%DDIR_A%"
mkdir "%DDIR_B%"

rem --- Test: identical directories ---
echo same > "%DDIR_A%\file1.txt"
echo same > "%DDIR_B%\file1.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DDIR_A% -PATH2:%DDIR_B%" > "%TEMP%\diff_imp_out.txt" 2>&1
findstr /c:"Identical:" "%TEMP%\diff_imp_out.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: identical dirs shows Identical") else (call :fail "MIX_Diff: identical dirs shows Identical")

rem --- Test: added file detected ---
echo new > "%DDIR_B%\file2.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DDIR_A% -PATH2:%DDIR_B%" > "%TEMP%\diff_imp_out2.txt" 2>&1
findstr /c:"ONLY IN B: file2.txt" "%TEMP%\diff_imp_out2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: added file detected") else (call :fail "MIX_Diff: added file detected")
findstr /c:"Added:" "%TEMP%\diff_imp_out2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: summary shows Added") else (call :fail "MIX_Diff: summary shows Added")

rem --- Test: removed file detected ---
rmdir /s /q "%DDIR_B%"
mkdir "%DDIR_B%"
echo same > "%DDIR_B%\file1.txt"
echo extra > "%DDIR_A%\file_removed.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DDIR_A% -PATH2:%DDIR_B%" > "%TEMP%\diff_imp_out3.txt" 2>&1
findstr /c:"ONLY IN A: file_removed.txt" "%TEMP%\diff_imp_out3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: removed file detected") else (call :fail "MIX_Diff: removed file detected")
findstr /c:"Removed:" "%TEMP%\diff_imp_out3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: summary shows Removed") else (call :fail "MIX_Diff: summary shows Removed")

rem --- Test: modified file detected ---
rmdir /s /q "%DDIR_B%"
mkdir "%DDIR_B%"
echo original > "%DDIR_A%\file_mod.txt"
echo changed > "%DDIR_B%\file_mod.txt"
cmd.exe /c ""%DIFF%" -PATH1:%DDIR_A% -PATH2:%DDIR_B%" > "%TEMP%\diff_imp_out4.txt" 2>&1
findstr /c:"MODIFIED: file_mod.txt" "%TEMP%\diff_imp_out4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: modified file detected") else (call :fail "MIX_Diff: modified file detected")
findstr /c:"Modified:" "%TEMP%\diff_imp_out4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: summary shows Modified") else (call :fail "MIX_Diff: summary shows Modified")

rem --- Test: nonexistent path shows error ---
cmd.exe /c ""%DIFF%" -PATH1:%TEMP%\nonexist_diff_a -PATH2:%TEMP%\nonexist_diff_b" > "%TEMP%\diff_imp_out5.txt" 2>&1
findstr /i /c:"ERROR" "%TEMP%\diff_imp_out5.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "MIX_Diff: nonexistent path shows error") else (call :fail "MIX_Diff: nonexistent path shows error")

rmdir /s /q "%DDIR_A%" 2>nul
rmdir /s /q "%DDIR_B%" 2>nul

rem ======================================================
rem  H265
rem ======================================================
set "H265=%~dp0..\H265.bat"

rem --- Test: nonexistent SOURCE folder ---
cmd.exe /c ""%H265%" -SOURCE:nonexist_h265_src -OUTPUT:%TEMP%\h265out_imp" > "%TEMP%\h265_imp_out.txt" 2>&1
findstr /c:"Error" "%TEMP%\h265_imp_out.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "H265: nonexistent SOURCE error") else (call :fail "H265: nonexistent SOURCE error")

rem --- Test: empty folder (no video files) ---
set "H265_EMPTY=%TEMP%\h265_empty_test"
if exist "%H265_EMPTY%" rmdir /s /q "%H265_EMPTY%"
mkdir "%H265_EMPTY%"
cmd.exe /c ""%H265%" -SOURCE:%H265_EMPTY% -OUTPUT:%TEMP%\h265out_imp2" > "%TEMP%\h265_imp_out2.txt" 2>&1
findstr /c:"No files found" "%TEMP%\h265_imp_out2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "H265: empty folder message") else (call :fail "H265: empty folder message")
rmdir /s /q "%H265_EMPTY%" 2>nul

rem --- Test: DRY_RUN mode ---
set "H265_DRY=%TEMP%\h265_dry_test"
if exist "%H265_DRY%" rmdir /s /q "%H265_DRY%"
mkdir "%H265_DRY%"
echo dummy > "%H265_DRY%\test.mp4"
cmd.exe /c ""%H265%" -SOURCE:%H265_DRY% -OUTPUT:%TEMP%\h265out_dry -DRY_RUN" > "%TEMP%\h265_imp_out3.txt" 2>&1
findstr /c:"DRY_RUN" "%TEMP%\h265_imp_out3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "H265: DRY_RUN mode") else (call :fail "H265: DRY_RUN mode")
rmdir /s /q "%H265_DRY%" 2>nul

rem --- Test: CMDParse h265 mode ---
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
("%CMDPARSE%" --mode:h265 -SOURCE:testdir -OUTPUT:outdir > "%TEMP%\h265_cp.txt") 2>nul
set "SOURCE=" & set "OUTPUT=" & set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\h265_cp.txt") do set "%%A=%%B"
call :chk "!SOURCE!" "testdir" "CMDParse h265: SOURCE parsed"
if defined OUTPUT (call :pass "CMDParse h265: OUTPUT defined") else (call :fail "CMDParse h265: OUTPUT defined")

rem Cleanup
del "%TEMP%\h265_imp_out*.txt" 2>nul
del "%TEMP%\h265_cp.txt" 2>nul
del "%TEMP%\diff_imp_out*.txt" 2>nul
del "%TEMP%\validate_imp_out*.txt" 2>nul
del "%TEMP%\validate_imp_err.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_cli_improved_passed.txt
echo !_f!>%TEMP%\test_cli_improved_failed.txt
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
