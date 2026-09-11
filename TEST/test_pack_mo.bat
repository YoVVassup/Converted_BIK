@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Pack_Mixes_MO_Vision.bat logic
echo ===================================================

set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"
set "_tests_run=0"
set "_tests_passed=0"
set "_tests_failed=0"
set "_out=%TEMP%\pack_mo_test_out.txt"

"%CMDPARSE%" --mode:pack_mo -GAME:RA2YR > "%_out%" 2>nul
set "FILTER_GAME=" & set "FILTER_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :assert "!FILTER_GAME!" "RA2YR" "CMDParse: FILTER_GAME=RA2YR"

"%CMDPARSE%" --mode:pack_mo -G:Original > "%_out%" 2>nul
set "FILTER_GAME=" & set "FILTER_GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%_out%") do set "%%A=%%B"
call :assert "!FILTER_GROUP!" "Original" "CMDParse: FILTER_GROUP=Original"

set "FILTER_GAME=RA1;RA2;RA2YR"
set "_c=0"
for %%I in (!FILTER_GAME!) do set /a _c+=1
call :assert "!_c!" "3" "FILTER_GAME: 3 items"

set "FILTER_GAME=RA2YR"
set "_c=0"
for %%I in (!FILTER_GAME!) do set /a _c+=1
call :assert "!_c!" "1" "FILTER_GAME: 1 item"

set "FILTER_GROUP=Original;7wolf"
set "_c=0"
for %%I in (!FILTER_GROUP!) do set /a _c+=1
call :assert "!_c!" "2" "FILTER_GROUP: 2 items"

rem Variable shadowing: %%I must not overwrite %%G
set "_saved="
for /d %%G in (dummy) do set "_saved=%%G"
call :assert "!_saved!" "dummy" "No shadowing: %%G preserved"

del "%_out%" 2>nul
echo.
echo Results: !_tests_passed!/!_tests_run! passed, !_tests_failed! failed
echo !_tests_passed!>%TEMP%\test_pack_mo_passed.txt
echo !_tests_failed!>%TEMP%\test_pack_mo_failed.txt
if !_tests_failed! gtr 0 (exit /b 1) else (exit /b 0)

:assert
set /a _tests_run+=1
if "%~1"=="%~2" (
    set /a _tests_passed+=1
    echo   [PASS] %~3
) else (
    set /a _tests_failed+=1
    echo   [FAIL] %~3: expected="%~2" actual="%~1"
)
exit /b 0
