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
echo [1/30] CMDParse...
call "%TEST_DIR%test_cmdparse.bat"
call :collect test_cmdparse
echo.

rem --- Suite 2: config_loader ---
echo [2/30] config_loader...
call "%TEST_DIR%test_config_loader.bat"
call :collect test_config_loader
echo.

rem --- Suite 3: Filters ---
echo [3/30] Filters...
call "%TEST_DIR%test_filters.bat"
call :collect test_filters
echo.

rem --- Suite 4: Pack_Mixes_MO_Vision ---
echo [4/30] Pack_Mixes_MO_Vision...
call "%TEST_DIR%test_pack_mo.bat"
call :collect test_pack_mo
echo.

rem --- Suite 5: Pack_Mixes_Original ---
echo [5/30] Pack_Mixes_Original...
call "%TEST_DIR%test_pack_original.bat"
call :collect test_pack_original
echo.

rem --- Suite 6: Cross_Converted_BIK ---
echo [6/30] Cross_Converted_BIK...
call "%TEST_DIR%test_cross.bat"
call :collect test_cross
echo.

rem --- Suite 7: Non-interactive CLI ---
echo [7/30] Non-interactive CLI...
call "%TEST_DIR%test_cli.bat"
call :collect test_cli
echo.

rem --- Suite 8: Log Rotation ---
echo [8/30] Log Rotation...
call "%TEST_DIR%test_log_rotation.bat"
call :collect test_log_rotation
echo.

rem --- Suite 9: Resolution_Convert ---
echo [9/30] Resolution_Convert...
call "%TEST_DIR%test_resolution_convert.bat"
call :collect test_resolution_convert
echo.

rem --- Suite 10: MP3_to_WAV ---
echo [10/30] MP3_to_WAV...
call "%TEST_DIR%test_mp3_to_wav.bat"
call :collect test_mp3_to_wav
echo.

rem --- Suite 11: Preview ---
echo [11/30] Preview...
call "%TEST_DIR%test_preview.bat"
call :collect test_preview
echo.

rem --- Suite 12: CLI Improved ---
echo [12/30] CLI Improved...
call "%TEST_DIR%test_cli_improved.bat"
call :collect test_cli_improved
echo.

rem --- Suite 13: DRY_RUN/INCREMENTAL/RETRY ---
echo [13/30] DRY_RUN/INCREMENTAL/RETRY...
call "%TEST_DIR%test_dry_run_incremental.bat"
call :collect test_dry_run_incremental
echo.

rem --- Suite 14: Validate_MIX full ---
echo [14/30] Validate_MIX (full)...
call "%TEST_DIR%test_validate_mix.bat"
call :collect test_validate_mix
echo.

rem --- Suite 15: H265 full ---
echo [15/30] H265 (full)...
call "%TEST_DIR%test_h265.bat"
call :collect test_h265
echo.

rem --- Suite 16: MP3_to_WAV full ---
echo [16/30] MP3_to_WAV (full)...
call "%TEST_DIR%test_mp3_to_wav_full.bat"
call :collect test_mp3_full
echo.

rem --- Suite 17: Resolution_Convert full ---
echo [17/30] Resolution_Convert (full)...
call "%TEST_DIR%test_resolution_convert_full.bat"
call :collect test_res_full
echo.

rem --- Suite 18: Cross_Converted_BIK full ---
echo [18/30] Cross_Converted_BIK (full)...
call "%TEST_DIR%test_cross_full.bat"
call :collect test_cross_full
echo.

rem --- Suite 19: Preview full ---
echo [19/30] Preview (full)...
call "%TEST_DIR%test_preview_full.bat"
call :collect test_preview_full
echo.

rem --- Suite 20: Pack_Mixes_MO_Vision full ---
echo [20/30] Pack_Mixes_MO_Vision (full)...
call "%TEST_DIR%test_pack_mo_full.bat"
call :collect test_pmo_full
echo.

rem --- Suite 21: Pack_Mixes_Original full ---
echo [21/30] Pack_Mixes_Original (full)...
call "%TEST_DIR%test_pack_original_full.bat"
call :collect test_porig_full
echo.

rem --- Suite 22: MIX_Diff full ---
echo [22/30] MIX_Diff (full)...
call "%TEST_DIR%test_mix_diff_full.bat"
call :collect test_mdiff_full
echo.

rem --- Suite 23: config_loader full ---
echo [23/30] config_loader (full)...
call "%TEST_DIR%test_config_loader_full.bat"
call :collect test_config_full
echo.

rem --- Suite 24: config_loader edge cases ---
echo [24/30] config_loader (edge cases)...
call "%TEST_DIR%test_config_loader_edge.bat"
call :collect test_cfg_edge
echo.

rem --- Suite 25: Cross_Converted_BIK errors ---
echo [25/30] Cross_Converted_BIK (errors + stats)...
call "%TEST_DIR%test_cross_errors.bat"
call :collect test_cross_err
echo.

rem --- Suite 26: MP3_to_WAV edge cases ---
echo [26/30] MP3_to_WAV (edge cases)...
call "%TEST_DIR%test_mp3_edge.bat"
call :collect test_mp3_edge
echo.

rem --- Suite 27: H265 edge cases ---
echo [27/30] H265 (edge cases)...
call "%TEST_DIR%test_h265_edge.bat"
call :collect test_h265_edge
echo.

rem --- Suite 28: Preview edge cases ---
echo [28/30] Preview (validation)...
call "%TEST_DIR%test_preview_edge.bat"
call :collect test_prev_edge
echo.

rem --- Suite 29: Validate_MIX + MIX_Diff + Pack edge ---
echo [29/30] Validate_MIX + MIX_Diff + Pack (edge)...
call "%TEST_DIR%test_validate_mix_edge.bat"
call :collect test_vmix_edge
call "%TEST_DIR%test_mix_diff_edge.bat"
call :collect test_mdiff_edge
call "%TEST_DIR%test_pack_edge.bat"
call :collect test_pack_edge
echo.

rem --- Suite 30: Resolution_Convert edge ---
echo [30/30] Resolution_Convert (error paths)...
call "%TEST_DIR%test_resolution_convert_edge.bat"
call :collect test_res_edge
echo.

rem --- Summary ---
echo ===================================================
set /a _total=_total_passed+_total_failed
echo  TOTAL: !_total_passed!/!_total! passed, !_total_failed! failed
echo  Suites: !_suites_ok! ok, !_suites_fail! failed
echo ===================================================

for %%f in (%TEMP%\test_*_passed.txt %TEMP%\test_*_failed.txt) do del "%%f" 2>nul
if !_total_failed! gtr 0 (exit /b 1) else (exit /b 0)

:collect
set "_p=0" & set "_f=0"
if exist "%TEMP%\%~1_passed.txt" set /p _p=<"%TEMP%\%~1_passed.txt"
if exist "%TEMP%\%~1_failed.txt" set /p _f=<"%TEMP%\%~1_failed.txt"
set /a _total_passed+=!_p! & set /a _total_failed+=!_f!
if "!_f!"=="0" (set /a _suites_ok+=1) else (set /a _suites_fail+=1)
echo    --- ^<!_p!/!_p!+_f!^> ---
exit /b 0
