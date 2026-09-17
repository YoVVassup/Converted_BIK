@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: DRY_RUN / INCREMENTAL / RETRY flags
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"

rem === Cross mode ===
call :test_flags "cross" "" "0" "0" "0" "cross defaults"
call :test_flags "cross" "-DRY_RUN" "1" "0" "0" "cross -DRY_RUN"
call :test_flags "cross" "-INCREMENTAL" "0" "1" "0" "cross -INCREMENTAL"
call :test_flags "cross" "-RETRY" "0" "0" "1" "cross -RETRY"
call :test_flags "cross" "-DRY_RUN -INCREMENTAL -RETRY" "1" "1" "1" "cross all flags"

rem === Pack_MO mode ===
call :test_flags "pack_mo" "-DRY_RUN" "1" "0" "0" "pack_mo -DRY_RUN"
call :test_flags "pack_mo" "-INCREMENTAL -RETRY" "0" "1" "1" "pack_mo -I -R"
call :test_flags "pack_mo" "-DRY_RUN -INCREMENTAL" "1" "1" "0" "pack_mo -DRY_RUN -I"

rem === Pack_Original mode ===
call :test_flags "pack_original" "-INCREMENTAL -RETRY" "0" "1" "1" "pack_orig -I -R"
call :test_flags "pack_original" "-DRY_RUN -INCREMENTAL" "1" "1" "0" "pack_orig -DRY_RUN -I"

rem === Resolution mode ===
call :test_flags "resolution" "-INPUT:test.bik -RES:800x600 -BITRATE:400000 -DRY_RUN" "1" "0" "0" "resolution -DRY_RUN"

rem === H265 mode ===
call :test_flags "h265" "-SOURCE:test -OUTPUT:test -DRY_RUN" "1" "0" "0" "h265 -DRY_RUN"

rem Cleanup
del "%TEMP%\dry_flag_test_*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_dry_run_incremental_passed.txt
echo !_f!>%TEMP%\test_dry_run_incremental_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

rem === Subroutines ===

:test_flags
set "_mode=%~1"
set "_args=%~2"
set "_exp_dry=%~3"
set "_exp_incr=%~4"
set "_exp_retry=%~5"
set "_name=%~6"
set "_outfile=%TEMP%\dry_flag_test_%_mode%.txt"
cmd.exe /c ""%CMDPARSE%" --mode:!_mode! !_args!" > "!_outfile!" 2>&1
set "_got_dry=0" & set "_got_incr=0" & set "_got_retry=0"
for /f "usebackq tokens=1,* delims==" %%A in ("!_outfile!") do (
    if "%%A"=="DRY_RUN" set "_got_dry=%%B"
    if "%%A"=="INCREMENTAL" set "_got_incr=%%B"
    if "%%A"=="RETRY" set "_got_retry=%%B"
)
call :chk "!_got_dry!" "!_exp_dry!" "!_name!: dry=!_exp_dry!"
call :chk "!_got_incr!" "!_exp_incr!" "!_name!: incr=!_exp_incr!"
call :chk "!_got_retry!" "!_exp_retry!" "!_name!: retry=!_exp_retry!"
exit /b 0

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
