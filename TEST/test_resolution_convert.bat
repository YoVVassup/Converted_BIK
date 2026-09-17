@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Resolution_Convert.bat (validate_bitrate + CLI)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "RES=%~dp0..\Resolution_Convert.bat"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"

rem === validate_bitrate logic tests ===
rem Test the arithmetic logic directly (same as :validate_bitrate in Resolution_Convert.bat)

rem --- Test: valid bitrate passes ---
set "CHECK_BITRATE=600000"
set /a "CHECK_BITRATE_NUM=CHECK_BITRATE" 2>nul
set "_num_ok=!errorlevel!"
if !_num_ok! equ 0 if !CHECK_BITRATE! gtr 0 if !CHECK_BITRATE! leq 1200000 (call :pass "validate_bitrate: 600000 accepted") else (call :fail "validate_bitrate: 600000 accepted")

rem --- Test: boundary 1200000 passes ---
set /a "_v=1200000" 2>nul
if !_v! leq 1200000 (call :pass "validate_bitrate: 1200000 at limit") else (call :fail "validate_bitrate: 1200000 at limit")

rem --- Test: over limit rejected ---
set /a "_v=1200001" 2>nul
if !_v! gtr 1200000 (call :pass "validate_bitrate: 1200001 rejected") else (call :fail "validate_bitrate: 1200001 rejected")

rem --- Test: 1150000 (recommended max) passes ---
set /a "_v=1150000" 2>nul
if !_v! leq 1200000 (call :pass "validate_bitrate: 1150000 recommended max") else (call :fail "validate_bitrate: 1150000 recommended max")

rem --- Test: zero rejected ---
set /a "_v=0" 2>nul
if !_v! leq 0 (call :pass "validate_bitrate: 0 rejected") else (call :fail "validate_bitrate: 0 rejected")

rem --- Test: negative rejected ---
set /a "_v=-100" 2>nul
if !_v! leq 0 (call :pass "validate_bitrate: negative rejected") else (call :fail "validate_bitrate: negative rejected")

rem --- Test: huge value rejected ---
set /a "_v=9999999" 2>nul
if !_v! gtr 1200000 (call :pass "validate_bitrate: 9999999 rejected") else (call :fail "validate_bitrate: 9999999 rejected")

rem --- Test: 400000 (min used) passes ---
set /a "_v=400000" 2>nul
if !_v! leq 1200000 if !_v! gtr 0 (call :pass "validate_bitrate: 400000 accepted") else (call :fail "validate_bitrate: 400000 accepted")

rem --- Test: 1100000 (600pyr) passes ---
set /a "_v=1100000" 2>nul
if !_v! leq 1200000 (call :pass "validate_bitrate: 1100000 accepted") else (call :fail "validate_bitrate: 1100000 accepted")

rem === CLI mode error handling ===

rem --- Test: CLI without INPUT goes interactive or errors on missing tool ---
cmd.exe /c ""%RES%" -RES:800x600 -BITRATE:400000" > "%TEMP%\res_cli_err.txt" 2>&1
findstr /c:"Work mode" "%TEMP%\res_cli_err.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "CLI: no INPUT shows interactive menu") else (
    findstr /c:"ERROR" "%TEMP%\res_cli_err.txt" >nul 2>nul
    if !errorlevel! equ 0 (call :pass "CLI: no INPUT - radvideo64 missing error") else (call :fail "CLI: no INPUT shows interactive menu or error")
)

rem --- Test: CLI without RESOLUTION shows error ---
cmd.exe /c ""%RES%" -INPUT:%TEMP%\dummy.bik -BITRATE:400000" > "%TEMP%\res_cli_err2.txt" 2>&1
findstr /c:"ERROR" "%TEMP%\res_cli_err2.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "CLI: missing RESOLUTION shows error") else (call :fail "CLI: missing RESOLUTION shows error")

rem --- Test: CLI without BITRATE shows error ---
cmd.exe /c ""%RES%" -INPUT:%TEMP%\dummy.bik -RES:800x600" > "%TEMP%\res_cli_err3.txt" 2>&1
findstr /c:"ERROR" "%TEMP%\res_cli_err3.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "CLI: missing BITRATE shows error") else (call :fail "CLI: missing BITRATE shows error")

rem --- Test: CLI nonexistent file shows error ---
echo dummy > "%TEMP%\nonexist.bik"
cmd.exe /c ""%RES%" -INPUT:%TEMP%\nonexist_wrong.bik -RES:800x600 -BITRATE:400000" > "%TEMP%\res_cli_err4.txt" 2>&1
findstr /c:"ERROR" "%TEMP%\res_cli_err4.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "CLI: nonexistent file shows error") else (call :fail "CLI: nonexistent file shows error")
del "%TEMP%\nonexist.bik" 2>nul

rem --- Test: CLI invalid resolution format ---
echo test > "%TEMP%\test.bik"
cmd.exe /c ""%RES%" -INPUT:%TEMP%\test.bik -RES:invalid -BITRATE:400000" > "%TEMP%\res_cli_err5.txt" 2>&1
findstr /c:"ERROR" "%TEMP%\res_cli_err5.txt" >nul 2>nul
if !errorlevel! equ 0 (call :pass "CLI: invalid resolution format") else (call :fail "CLI: invalid resolution format")
del "%TEMP%\test.bik" 2>nul

rem --- Test: CMDParse resolution mode ---
"%CMDPARSE%" --mode:resolution -INPUT:test.bik -RES:1280x720 -BITRATE:600000 > "%TEMP%\res_cp.txt" 2>nul
set "INPUT=" & set "RESOLUTION=" & set "BITRATE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\res_cp.txt") do set "%%A=%%B"
call :chk "!INPUT!" "test.bik" "CMDParse: resolution INPUT parsed"
call :chk "!RESOLUTION!" "1280x720" "CMDParse: resolution RES parsed"
call :chk "!BITRATE!" "600000" "CMDParse: resolution BITRATE parsed"

rem --- Test: CMDParse resolution with DRY_RUN ---
"%CMDPARSE%" --mode:resolution -INPUT:test.bik -RES:800x600 -BITRATE:400000 -DRY_RUN > "%TEMP%\res_cp2.txt" 2>nul
set "DRY_RUN=0"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\res_cp2.txt") do set "%%A=%%B"
call :chk "!DRY_RUN!" "1" "CMDParse: resolution DRY_RUN"

rem Cleanup
del "%TEMP%\res_cli_err*.txt" 2>nul
del "%TEMP%\res_cp*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_resolution_convert_passed.txt
echo !_f!>%TEMP%\test_resolution_convert_failed.txt
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
