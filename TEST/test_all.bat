@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo  BIK Pipeline - Full Test Suite
echo ===================================================
echo.

set "TEST_DIR=%~dp0"
set "_total_passed=0"
set "_total_failed=0"
set "_suites_ok=0"
set "_suites_fail=0"

rem Clean old results
for %%f in (%TEMP%\test_*_passed.txt %TEMP%\test_*_failed.txt) do del "%%f" 2>nul

rem --- Suite 1: CMDParse ---
echo [1/9] CMDParse...
call "%TEST_DIR%test_cmdparse.bat"
set "_p=0" & set "_f=0"
if exist "%TEMP%\test_cmdparse_passed.txt" set /p _p=<"%TEMP%\test_cmdparse_passed.txt"
if exist "%TEMP%\test_cmdparse_failed.txt" set /p _f=<"%TEMP%\test_cmdparse_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
echo.

rem --- Suite 2: config_loader ---
echo [2/9] config_loader...
call "%TEST_DIR%test_config_loader.bat"
set "_p=0" & set "_f=0"
if exist "%TEMP%\test_config_loader_passed.txt" set /p _p=<"%TEMP%\test_config_loader_passed.txt"
if exist "%TEMP%\test_config_loader_failed.txt" set /p _f=<"%TEMP%\test_config_loader_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
echo.

rem --- Suite 3: Filters ---
echo [3/9] Filters...
call "%TEST_DIR%test_filters.bat"
set "_p=0" & set "_f=0"
if exist "%TEMP%\test_filters_passed.txt" set /p _p=<"%TEMP%\test_filters_passed.txt"
if exist "%TEMP%\test_filters_failed.txt" set /p _f=<"%TEMP%\test_filters_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
echo.

rem --- Suite 4: Pack_Mixes_MO_Vision ---
echo [4/9] Pack_Mixes_MO_Vision...
call "%TEST_DIR%test_pack_mo.bat"
set "_p=0" & set "_f=0"
if exist "%TEMP%\test_pack_mo_passed.txt" set /p _p=<"%TEMP%\test_pack_mo_passed.txt"
if exist "%TEMP%\test_pack_mo_failed.txt" set /p _f=<"%TEMP%\test_pack_mo_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
echo.

rem --- Suite 5: Pack_Mixes_Original ---
echo [5/9] Pack_Mixes_Original...
call "%TEST_DIR%test_pack_original.bat"
set "_p=0" & set "_f=0"
if exist "%TEMP%\test_pack_original_passed.txt" set /p _p=<"%TEMP%\test_pack_original_passed.txt"
if exist "%TEMP%\test_pack_original_failed.txt" set /p _f=<"%TEMP%\test_pack_original_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
echo.

rem --- Suite 6: Cross_Converted_BIK ---
echo [6/9] Cross_Converted_BIK...
call "%TEST_DIR%test_cross.bat"
set "_p=0" & set "_f=0"
if exist "%TEMP%\test_cross_passed.txt" set /p _p=<"%TEMP%\test_cross_passed.txt"
if exist "%TEMP%\test_cross_failed.txt" set /p _f=<"%TEMP%\test_cross_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
echo.

rem --- Suite 7: Non-interactive CLI ---
echo [7/9] Non-interactive CLI...
call "%TEST_DIR%test_cli.bat"
set "_p=0" & set "_f=0"
if exist "%TEMP%\test_cli_passed.txt" set /p _p=<"%TEMP%\test_cli_passed.txt"
if exist "%TEMP%\test_cli_failed.txt" set /p _f=<"%TEMP%\test_cli_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
echo.

rem --- Suite 8: Log Rotation ---
echo [8/9] Log Rotation...
call "%TEST_DIR%test_log_rotation.bat"
set "_p=0" & set "_f=0"
if exist "%TEMP%\test_log_rotation_passed.txt" set /p _p=<"%TEMP%\test_log_rotation_passed.txt"
if exist "%TEMP%\test_log_rotation_failed.txt" set /p _f=<"%TEMP%\test_log_rotation_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
echo.

rem --- Summary ---
echo ===================================================
set /a _total=_total_passed+_total_failed
echo  TOTAL: !_total_passed!/!_total! passed, !_total_failed! failed
echo  Suites: !_suites_ok! ok, !_suites_fail! failed
echo ===================================================

for %%f in (%TEMP%\test_*_passed.txt %TEMP%\test_*_failed.txt) do del "%%f" 2>nul
if !_total_failed! gtr 0 (exit /b 1) else (exit /b 0)
