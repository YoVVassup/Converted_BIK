@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "!SCRIPT_DIR:~-1!"=="\" set "SCRIPT_DIR=!SCRIPT_DIR:~0,-1!"

call "%SCRIPT_DIR%\config_loader.bat"

set "PROCESS_RA1=0"
set "PROCESS_RA2=0"
set "PROCESS_RA2YR=0"
set "GROUP_FILTER="
set "RESOLUTION_FILTER="
set "INCLUDE_NOFORMAT=0"
set "DRY_RUN=0"
set "INCREMENTAL=0"
set "RETRY=0"

"%SCRIPT_DIR%\third-party\CMDParse\CMDParse.exe" %* > "%TEMP%\bik_args.txt"
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\bik_args.txt") do (
    set "%%A=%%B"
)
del "%TEMP%\bik_args.txt" 2>nul

if !PROCESS_RA1! equ 0 if !PROCESS_RA2! equ 0 if !PROCESS_RA2YR! equ 0 (
    set "PROCESS_RA1=1"
    set "PROCESS_RA2=1"
    set "PROCESS_RA2YR=1"
)

if not exist "%NEW_RAD%" (echo ERROR: %NEW_RAD% not found & pause & endlocal & exit /b 1)
if not exist "%OLD_MIX%" (echo ERROR: %OLD_MIX% not found & pause & endlocal & exit /b 1)
if not exist "%MP4_SOURCE%" (echo ERROR: Folder %MP4_SOURCE% not found & pause & endlocal & exit /b 1)
if not exist "%SOUND_SOURCE%" (echo ERROR: Folder %SOUND_SOURCE% not found & pause & endlocal & exit /b 1)

if !PROCESS_RA1! equ 1 if not exist "%FINAL_RA1%" mkdir "%FINAL_RA1%"
if !PROCESS_RA2! equ 1 if not exist "%FINAL_RA2%" mkdir "%FINAL_RA2%"
if !PROCESS_RA2YR! equ 1 if not exist "%FINAL_RA2YR%" mkdir "%FINAL_RA2YR%"

if !RETRY! equ 0 if exist "%FAILED_FILE%" del "%FAILED_FILE%"

set "STAT_TOTAL=0"
set "STAT_CONVERTED=0"
set "STAT_MIXED=0"
set "STAT_SKIPPED=0"
set "STAT_ERRORS=0"
set "_t=%time: =0%"
set /a "STAT_START_SEC=!_t:~0,2!*3600 + !_t:~3,2!*60 + !_t:~6,2!"
set "STAT_START=%time%"

if !RETRY! equ 1 (
    echo. >> "%LOGFILE%"
    echo === RETRY: %date% %time% === >> "%LOGFILE%"
) else (
    echo Start: %date% %time% > "%LOGFILE%"
)
echo Games: RA1=!PROCESS_RA1!, RA2=!PROCESS_RA2!, RA2YR=!PROCESS_RA2YR! >> "%LOGFILE%"
if defined GROUP_FILTER (echo Groups: !GROUP_FILTER! >> "%LOGFILE%") else (echo Groups: all >> "%LOGFILE%")
if defined RESOLUTION_FILTER (echo Resolutions: !RESOLUTION_FILTER! >> "%LOGFILE%") else (echo Resolutions: all >> "%LOGFILE%")
if !INCREMENTAL! equ 1 echo Incremental mode >> "%LOGFILE%"
if !RETRY! equ 1 echo Retry mode >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"

set "GAMES_LIST="
if !PROCESS_RA1! equ 1 set "GAMES_LIST=!GAMES_LIST! RA1"
if !PROCESS_RA2! equ 1 set "GAMES_LIST=!GAMES_LIST! RA2"
if !PROCESS_RA2YR! equ 1 set "GAMES_LIST=!GAMES_LIST! RA2YR"

for %%G in (!GAMES_LIST!) do (
    set "game=%%G"
    echo.
    echo ============================
    echo Processing: !game!
    echo ============================
    echo Processing: !game! >> "%LOGFILE%"
    
    if "!game!"=="RA1" (call :process_ra1)
    if "!game!"=="RA2" (call :process_game "RA2" "%MP4_SOURCE%\RA2" "%SOUND_SOURCE%\RA2" "%FINAL_RA2%")
    if "!game!"=="RA2YR" (call :process_game "RA2YR" "%MP4_SOURCE%\RA2YR" "%SOUND_SOURCE%\RA2YR" "%FINAL_RA2YR%")
)

if !PROCESS_RA2! equ 1 call :process_clean_bik "RA2"
if !PROCESS_RA2YR! equ 1 call :process_clean_bik "RA2YR"

set "_t=%time: =0%"
set /a "STAT_END_SEC=!_t:~0,2!*3600 + !_t:~3,2!*60 + !_t:~6,2!"
set /a "STAT_ELAPSED=STAT_END_SEC - STAT_START_SEC"
set /a "STAT_ELAPSED_H=STAT_ELAPSED / 3600"
set /a "STAT_ELAPSED_M=(STAT_ELAPSED %% 3600) / 60"
set /a "STAT_ELAPSED_S=STAT_ELAPSED %% 60"

echo. >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"
echo STATISTICS >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"
echo Time: !STAT_START! - %time% ^(!STAT_ELAPSED_H!h !STAT_ELAPSED_M!m !STAT_ELAPSED_S!s^) >> "%LOGFILE%"
echo Total: !STAT_TOTAL! ^| Converted: !STAT_CONVERTED! ^| Mixed: !STAT_MIXED! ^| Skipped: !STAT_SKIPPED! ^| Errors: !STAT_ERRORS! >> "%LOGFILE%"

echo.
echo ============================
echo STATISTICS
echo ============================
echo Time: !STAT_START! - %time% (!STAT_ELAPSED_H!h !STAT_ELAPSED_M!m !STAT_ELAPSED_S!s)
echo Total: !STAT_TOTAL! ^| Converted: !STAT_CONVERTED! ^| Mixed: !STAT_MIXED! ^| Skipped: !STAT_SKIPPED! ^| Errors: !STAT_ERRORS!

if !STAT_ERRORS! gtr 0 (
    echo.
    echo Errors saved to: %FAILED_FILE%
    echo Retry: Cross_Converted_BIK.bat -RETRY [flags]
)

echo. >> "%LOGFILE%"
echo All files processed >> "%LOGFILE%"
endlocal
exit /b 0

:log_msg
set "_ts=%time:~0,8%"
set "_ts=!_ts: =0!"
echo [!_ts!] %~1 >> "%LOGFILE%"
goto :eof

:run_binkc
set "_ts=%time:~0,8%"
set "_ts=!_ts: =0!"
echo [!_ts!] CMD: "%NEW_RAD%" Binkc "%~1" "%~2" /N-1 /(%~3 /)%~4 /v100 /:0 /D%~5 /L0 /O /Z0 /# >> "%LOGFILE%"
powershell -NoProfile -Command "Start-Process -FilePath '%NEW_RAD%' -ArgumentList 'Binkc \"%~1\" \"%~2\" /N-1 /(%~3 /)%~4 /v100 /:0 /D%~5 /L0 /O /Z0 /#' -WindowStyle Hidden -Wait"
goto :eof

:run_binkmix
set "_ts=%time:~0,8%"
set "_ts=!_ts: =0!"
echo [!_ts!] CMD: "%OLD_MIX%" "%~1" "%~2" "%~3" /L0 /O /# >> "%LOGFILE%"
powershell -NoProfile -Command "Start-Process -FilePath '%OLD_MIX%' -ArgumentList '\"%~1\" \"%~2\" \"%~3\" /L0 /O /#' -WindowStyle Hidden -Wait"
goto :eof

:set_resolution
set "_res=%~1"
set "_game=%~2"
set "height=!_res!"
set "height=!height:pyr=!"
set "height=!height:p=!"
if "!_res!"=="600p" set "width=800"
if "!_res!"=="600pyr" set "width=800"
if "!_res!"=="720p" set "width=960"
if "!_res!"=="768p" set "width=1024"
if "!_res!"=="900p" set "width=1200"
if "!_res!"=="1080p" set "width=1400"
if /i "!_game!"=="RA1" (
    if "!_res!"=="600p" set "width=1024"
    if "!_res!"=="720p" set "width=1280"
    if "!_res!"=="768p" set "width=1366"
    if "!_res!"=="900p" set "width=1600"
    if "!_res!"=="1080p" set "width=1920"
)
if "!_res!"=="600p" set "bitrate=400000"
if "!_res!"=="600pyr" set "bitrate=1100000"
if "!_res!"=="720p" set "bitrate=600000"
if "!_res!"=="768p" set "bitrate=700000"
if "!_res!"=="900p" set "bitrate=900000"
if "!_res!"=="1080p" set "bitrate=1150000"
goto :eof

:ensure_group_folder
set "_grp=%~1"
if not exist "!_grp!\" mkdir "!_grp!"
if not exist "!_grp!\noformat\" mkdir "!_grp!\noformat!"
goto :eof

:ensure_folder
set "_dir=%~1"
if not exist "!_dir!\" mkdir "!_dir!"
goto :eof

:process_game
set "_game=%~1"
set "_mp4_dir=%~2"
set "_sound_dir=%~3"
set "_final_dir=%~4"

set "_file_idx=0"
set "_file_total=0"
for %%F in ("!_mp4_dir!\*.mp4") do set /a _file_total+=1

set "_res_list=600p 720p 768p 900p 1080p"
if "!_game!"=="RA2YR" set "_res_list=600pyr 600p 720p 768p 900p 1080p"

set "_t=%time: =0%"
set /a "LOOP_START=!_t:~0,2!*3600 + !_t:~3,2!*60 + !_t:~6,2!"

for %%F in ("!_mp4_dir!\*.mp4") do (
    set /a _file_idx+=1
    set "filename=%%~nF"
    set "processed=0"
    set "should_process=1"
    set "dry_run_groups="
    set "dry_run_count=0"
    
    if !RETRY! equ 1 (
        set "in_failed=0"
        if exist "%FAILED_FILE%" findstr /i /c:"!filename!" "%FAILED_FILE%" >nul 2>nul && set "in_failed=1"
        if !in_failed! equ 0 (set /a STAT_SKIPPED+=1 & set "should_process=0")
    )
    
    if !should_process! equ 1 (
        set "processed=0"
        set "_t=%time: =0%"
        set /a "NOW_SEC=!_t:~0,2!*3600 + !_t:~3,2!*60 + !_t:~6,2!"
        set /a "ELAPSED=NOW_SEC - LOOP_START"
        set "ETA_INFO="
        if !_file_idx! gtr 1 if !ELAPSED! gtr 0 (
            set /a "REMAIN=ELAPSED * (_file_total - _file_idx) / (_file_idx - 1)"
            set /a "R_H=REMAIN / 3600"
            set /a "R_M=(REMAIN %% 3600) / 60"
            set /a "R_S=REMAIN %% 60"
            set /a "PCT=_file_idx * 100 / _file_total"
            set "ETA_INFO= !PCT!%% ETA:!R_H!h!R_M!m!R_S!s"
        )
        echo [!_file_idx!/!_file_total!]!ETA_INFO! - !filename!.mp4
        
        for /d %%H in ("!_sound_dir!\*") do (
            set "group=%%~nxH"
            set "skip_group=0"
            if defined GROUP_FILTER (
                echo ";!GROUP_FILTER!;" | findstr /i /c:";!group!;" >nul
                if errorlevel 1 set "skip_group=1"
            )
            if !skip_group! equ 0 (
                if exist "%%H\!filename!.wav" (
                    set "processed=1"
                    if !DRY_RUN! equ 0 (
                        if not exist "!_final_dir!\!group!\" mkdir "!_final_dir!\!group!\"
                        if not exist "!_final_dir!\!group!\noformat\" mkdir "!_final_dir!\!group!\noformat\"
                        for %%R in (!_res_list!) do (
                            set "res=%%R"
                            set "skip_res=1"
                            if defined RESOLUTION_FILTER (
                                if "!RESOLUTION_FILTER!"=="!res!" set "skip_res=0"
                            ) else (set "skip_res=0")
                            if !skip_res! equ 0 (
                                set "res_folder=!_final_dir!\!group!\!res!"
                                if not exist "!res_folder!\" mkdir "!res_folder!"
                                set "bik_file=!res_folder!\!filename!.bik"
                                set "should_convert=1"
                                if !INCREMENTAL! equ 1 if exist "!bik_file!" (
                                    set /a STAT_SKIPPED+=1
                                    set "should_convert=0"
                                )
                                if !should_convert! equ 1 (
                                    call :set_resolution "!res!" "!_game!"
                                    echo    Convert: !filename! to !res! ^(!width!x!height!, !bitrate!^)
                                    call :run_binkc "%%F" "!bik_file!" !width! !height! !bitrate!
                                    if !errorlevel! equ 0 (
                                        set "bik_size=0"
                                        for %%I in ("!bik_file!") do set "bik_size=%%~zI"
                                        if !bik_size! gtr 0 (
                                            set /a STAT_CONVERTED+=1
                                            call :run_binkmix "!bik_file!" "%SOUND_SOURCE%\!_game!\!group!\!filename!.wav" "!bik_file!"
                                            if !errorlevel! equ 0 (
                                                set /a STAT_MIXED+=1
                                            ) else (
                                                echo    ERROR mix: !filename! !res!
                                                echo !filename! [!_game!/!group!/!res!/mix] >> "%FAILED_FILE%"
                                                set /a STAT_ERRORS+=1
                                            )
                                        ) else (
                                            del "!bik_file!" 2>nul
                                            echo    ERROR empty: !filename! !res!
                                            echo !filename! [!_game!/!group!/!res!/empty] >> "%FAILED_FILE%"
                                            set /a STAT_ERRORS+=1
                                        )
                                    ) else (
                                        echo    ERROR convert: !filename! !res!
                                        echo !filename! [!_game!/!group!/!res!/convert] >> "%FAILED_FILE%"
                                        set /a STAT_ERRORS+=1
                                    )
                                    set /a STAT_TOTAL+=1
                                )
                            )
                        )
                    ) else (
                        set /a dry_run_count+=1
                        if defined dry_run_groups (set "dry_run_groups=!dry_run_groups!, !group!") else (set "dry_run_groups=!group!")
                    )
                )
            )
        )
        if !DRY_RUN! equ 1 if defined dry_run_groups (
            echo [%time%] DRY_RUN !filename! ^(!dry_run_count! groups: !dry_run_groups!^) >> "%LOGFILE%"
            echo    [DRY_RUN] !dry_run_count! groups: !dry_run_groups!
        )
        if !DRY_RUN! equ 0 if !processed! equ 0 (echo [!_file_idx!/!_file_total!] Group not found: !filename!)
        if !DRY_RUN! equ 1 if !processed! equ 0 (echo [!_file_idx!/!_file_total!] No WAV found: !filename!)
    )
)
goto :eof

:process_ra1
echo [%time%] Processing RA1 >> "%LOGFILE%"

set "_file_idx=0"
set "_file_total=0"
for %%F in ("%MP4_SOURCE%\RA1\HD\noWAV\*.mp4") do set /a _file_total+=1

for %%F in ("%MP4_SOURCE%\RA1\HD\noWAV\*.mp4") do (
    set /a _file_idx+=1
    set "filename=%%~nF"
    set "should_process=1"
    if !RETRY! equ 1 (
        set "in_failed=0"
        if exist "%FAILED_FILE%" findstr /i /c:"!filename!" "%FAILED_FILE%" >nul 2>nul && set "in_failed=1"
        if !in_failed! equ 0 (set /a STAT_SKIPPED+=1 & set "should_process=0")
    )
    if !should_process! equ 1 (
        echo [!_file_idx!/!_file_total!] RA1\noWAV: !filename!.mp4
        if !DRY_RUN! equ 0 (
            if not exist "%FINAL_RA1%\Original\" mkdir "%FINAL_RA1%\Original\"
            for %%R in (600p 720p 768p 900p 1080p) do (
                set "res=%%R"
                set "skip_res=1"
                if defined RESOLUTION_FILTER (
                    if "!RESOLUTION_FILTER!"=="!res!" set "skip_res=0"
                ) else (set "skip_res=0")
                if !skip_res! equ 0 (
                    set "res_folder=%FINAL_RA1%\Original\!res!"
                    if not exist "!res_folder!\" mkdir "!res_folder!"
                    set "nolang_folder=!res_folder!\nolang"
                    if not exist "!nolang_folder!\" mkdir "!nolang_folder!"
                    set "in_nolang_list=0"
                    for %%I in (!NOLANG_FILES_HD!) do (if "!filename!"=="%%I" set "in_nolang_list=1")
                    if !in_nolang_list! equ 1 (set "output_folder=!nolang_folder!") else (set "output_folder=!res_folder!")
                    set "bik_file=!output_folder!\!filename!.bik"
                    set "should_convert=1"
                    if !INCREMENTAL! equ 1 if exist "!bik_file!" (
                        set /a STAT_SKIPPED+=1
                        set "should_convert=0"
                    )
                    if !should_convert! equ 1 (
                        call :set_resolution "!res!" "RA1"
                        echo [%time%] Convert RA1 noWAV: !filename! to !res! >> "%LOGFILE%"
                        call :run_binkc "%%F" "!bik_file!" !width! !height! !bitrate!
                        if !errorlevel! equ 0 (
                            set "bik_size=0"
                            for %%I in ("!bik_file!") do set "bik_size=%%~zI"
                            if !bik_size! gtr 0 (
                                set /a STAT_CONVERTED+=1
                                echo [%time%] OK: !filename! !res! ^(!bik_size! bytes^) >> "%LOGFILE%"
                            ) else (
                                del "!bik_file!" 2>nul
                                echo [%time%] ERROR empty: !filename! !res! >> "%LOGFILE%"
                                set /a STAT_ERRORS+=1
                            )
                        ) else (
                            echo [%time%] ERROR convert: !filename! !res! >> "%LOGFILE%"
                            set /a STAT_ERRORS+=1
                        )
                        set /a STAT_TOTAL+=1
                    )
                )
            )
        )
    )
)

set "_file_idx=0"
set "_file_total=0"
for %%F in ("%MP4_SOURCE%\RA1\HD\WAV\*.mp4") do set /a _file_total+=1

for %%F in ("%MP4_SOURCE%\RA1\HD\WAV\*.mp4") do (
    set /a _file_idx+=1
    set "filename=%%~nF"
    set "processed=0"
    set "should_process=1"
    if !RETRY! equ 1 (
        set "in_failed=0"
        if exist "%FAILED_FILE%" findstr /i /c:"!filename!" "%FAILED_FILE%" >nul 2>nul && set "in_failed=1"
        if !in_failed! equ 0 (set /a STAT_SKIPPED+=1 & set "should_process=0")
    )
    if !should_process! equ 1 (
        echo [!_file_idx!/!_file_total!] RA1\WAV: !filename!.mp4
        for /d %%H in ("%SOUND_SOURCE%\RA1\*") do (
            set "group=%%~nxH"
            set "skip_group=0"
            if defined GROUP_FILTER (
                echo ";!GROUP_FILTER!;" | findstr /i /c:";!group!;" >nul
                if errorlevel 1 set "skip_group=1"
            )
            if !skip_group! equ 0 (
                if exist "%%H\!filename!.wav" (
                    set "processed=1"
                    echo [%time%] Found group !group! for !filename!.wav >> "%LOGFILE%"
                    if !DRY_RUN! equ 0 (
                        if not exist "%FINAL_RA1%\!group!\" mkdir "%FINAL_RA1%\!group!\"
                        if not exist "%FINAL_RA1%\!group!\noformat\" mkdir "%FINAL_RA1%\!group!\noformat\"
                        if /i "!group!"=="Original" if not exist "%FINAL_RA1%\!group!\noformat\nolang\" mkdir "%FINAL_RA1%\!group!\noformat\nolang\"
                        for %%R in (600p 720p 768p 900p 1080p) do (
                            set "res=%%R"
                            set "skip_res=1"
                            if defined RESOLUTION_FILTER (
                                if "!RESOLUTION_FILTER!"=="!res!" set "skip_res=0"
                            ) else (set "skip_res=0")
                            if !skip_res! equ 0 (
                                set "res_folder=%FINAL_RA1%\!group!\!res!"
                                if not exist "!res_folder!\" mkdir "!res_folder!"
                                set "bik_file=!res_folder!\!filename!.bik"
                                set "should_convert=1"
                                if !INCREMENTAL! equ 1 if exist "!bik_file!" (
                                    set /a STAT_SKIPPED+=1
                                    set "should_convert=0"
                                )
                                if !should_convert! equ 1 (
                                    call :set_resolution "!res!" "RA1"
                                    echo    Convert: !filename! to !res! ^(!width!x!height!, !bitrate!^)
                                    call :run_binkc "%%F" "!bik_file!" !width! !height! !bitrate!
                                    if !errorlevel! equ 0 (
                                        set "bik_size=0"
                                        for %%I in ("!bik_file!") do set "bik_size=%%~zI"
                                        if !bik_size! gtr 0 (
                                            set /a STAT_CONVERTED+=1
                                            call :run_binkmix "!bik_file!" "%SOUND_SOURCE%\RA1\!group!\!filename!.wav" "!bik_file!"
                                            if !errorlevel! equ 0 (
                                                set /a STAT_MIXED+=1
                                            ) else (
                                                echo    ERROR mix: !filename! !res!
                                                echo !filename! [RA1/!group!/!res!/mix] >> "%FAILED_FILE%"
                                                set /a STAT_ERRORS+=1
                                            )
                                        ) else (
                                            del "!bik_file!" 2>nul
                                            echo    ERROR empty: !filename! !res!
                                            echo !filename! [RA1/!group!/!res!/empty] >> "%FAILED_FILE%"
                                            set /a STAT_ERRORS+=1
                                        )
                                    ) else (
                                        echo    ERROR convert: !filename! !res!
                                        echo !filename! [RA1/!group!/!res!/convert] >> "%FAILED_FILE%"
                                        set /a STAT_ERRORS+=1
                                    )
                                    set /a STAT_TOTAL+=1
                                )
                            )
                        )
                    ) else (
                        echo [%time%] DRY_RUN RA1 !filename! group=!group! >> "%LOGFILE%"
                    )
                    )
                )
            )
        )
        if !processed! equ 0 (echo    Group not found: !filename!)
    )
)

set "skip_res_noformat=1"
if !INCLUDE_NOFORMAT! equ 1 (set "skip_res_noformat=0")
if !skip_res_noformat! equ 1 if defined RESOLUTION_FILTER (if "!RESOLUTION_FILTER!"=="noformat" set "skip_res_noformat=0")

if !skip_res_noformat! equ 0 (
    set "_file_idx=0"
    set "_file_total=0"
    for %%F in ("%MP4_SOURCE%\RA1\noHD\*.mp4") do set /a _file_total+=1
    
    for %%F in ("%MP4_SOURCE%\RA1\noHD\*.mp4") do (
        set /a _file_idx+=1
        set "filename=%%~nF"
        set "processed=0"
        set "should_process=1"
        if !RETRY! equ 1 (
            set "in_failed=0"
            if exist "%FAILED_FILE%" findstr /i /c:"!filename!" "%FAILED_FILE%" >nul 2>nul && set "in_failed=1"
            if !in_failed! equ 0 (set /a STAT_SKIPPED+=1 & set "should_process=0")
        )
        if !should_process! equ 1 (
            echo [!_file_idx!/!_file_total!] RA1\noHD: !filename!.mp4
            for /d %%H in ("%SOUND_SOURCE%\RA1\*") do (
                set "group=%%~nxH"
                set "skip_group=0"
                if defined GROUP_FILTER (
                    echo ";!GROUP_FILTER!;" | findstr /i /c:";!group!;" >nul
                    if errorlevel 1 set "skip_group=1"
                )
                if !skip_group! equ 0 (
                    if exist "%%H\!filename!.wav" (
                        set "processed=1"
                        echo [%time%] Found group !group! for !filename!.wav >> "%LOGFILE%"
                        if !DRY_RUN! equ 0 (
                            if not exist "%FINAL_RA1%\!group!\" mkdir "%FINAL_RA1%\!group!\"
                            if not exist "%FINAL_RA1%\!group!\noformat\" mkdir "%FINAL_RA1%\!group!\noformat\"
                            if /i "!group!"=="Original" if not exist "%FINAL_RA1%\!group!\noformat\nolang\" mkdir "%FINAL_RA1%\!group!\noformat\nolang\"
                            set "width=1024"
                            set "height=564"
                            set "bitrate=400000"
                            set "group_folder=%FINAL_RA1%\!group!"
                            set "noformat_folder=!group_folder!\noformat"
                            set "in_nolang_list=0"
                            for %%I in (!NOLANG_FILES_NOFORMAT!) do (if "!filename!"=="%%I" set "in_nolang_list=1")
                            if /i "!group!"=="Original" (
                                if !in_nolang_list! equ 1 (set "output_folder=!noformat_folder!\nolang") else (set "output_folder=!noformat_folder!")
                            ) else (set "output_folder=!noformat_folder!")
                            set "bik_file=!output_folder!\!filename!.bik"
                            set "should_convert=1"
                            if !INCREMENTAL! equ 1 if exist "!bik_file!" (
                                set /a STAT_SKIPPED+=1
                                set "should_convert=0"
                            )
                            if !should_convert! equ 1 (
                                echo [%time%] Convert RA1 noHD: !filename! noformat >> "%LOGFILE%"
                                call :run_binkc "%%F" "!bik_file!" !width! !height! !bitrate!
                                if !errorlevel! equ 0 (
                                    set "bik_size=0"
                                    for %%I in ("!bik_file!") do set "bik_size=%%~zI"
                                    if !bik_size! gtr 0 (
                                        set /a STAT_CONVERTED+=1
                                        echo [%time%] OK: !filename! noformat >> "%LOGFILE%"
                                        call :run_binkmix "!bik_file!" "%SOUND_SOURCE%\RA1\!group!\!filename!.wav" "!bik_file!"
                                        if !errorlevel! equ 0 (
                                            set /a STAT_MIXED+=1
                                        ) else (
                                            echo [%time%] ERROR mixing: !filename! noformat >> "%LOGFILE%"
                                            set /a STAT_ERRORS+=1
                                        )
                                    ) else (
                                        del "!bik_file!" 2>nul
                                        echo [%time%] ERROR empty: !filename! noformat >> "%LOGFILE%"
                                        set /a STAT_ERRORS+=1
                                    )
                                ) else (
                                    echo [%time%] ERROR convert: !filename! noformat >> "%LOGFILE%"
                                    set /a STAT_ERRORS+=1
                                )
                                set /a STAT_TOTAL+=1
                            )
                        ) else (
                            echo [%time%] DRY_RUN RA1 noHD !filename! group=!group! >> "%LOGFILE%"
                        )
                    )
                )
            )
            if !processed! equ 0 (echo    Group not found: !filename!)
        )
    )
)
goto :eof

:process_clean_bik
set "_game=%~1"
set "skip_res_noformat=1"
if !INCLUDE_NOFORMAT! equ 1 (set "skip_res_noformat=0")
if !skip_res_noformat! equ 1 if defined RESOLUTION_FILTER (if "!RESOLUTION_FILTER!"=="noformat" set "skip_res_noformat=0")

if !skip_res_noformat! equ 0 if exist "%CLEAN_BIK%\!_game!\" (
    echo.
    echo [%time%] Clean_BIK !_game! >> "%LOGFILE%"
    echo Clean_BIK !_game!
    set "_file_idx=0"
    set "_file_total=0"
    for %%F in ("%CLEAN_BIK%\!_game!\*.bik") do set /a _file_total+=1
    
    for %%F in ("%CLEAN_BIK%\!_game!\*.bik") do (
        set /a _file_idx+=1
        set "filename=%%~nF"
        set "processed=0"
        set "should_process=1"
        if !RETRY! equ 1 (
            set "in_failed=0"
            if exist "%FAILED_FILE%" findstr /i /c:"!filename!" "%FAILED_FILE%" >nul 2>nul && set "in_failed=1"
            if !in_failed! equ 0 (set /a STAT_SKIPPED+=1 & set "should_process=0")
        )
        if !should_process! equ 1 (
            echo [!_file_idx!/!_file_total!] Clean_BIK: !filename!.bik
            for /d %%H in ("%SOUND_SOURCE%\!_game!\*") do (
                set "group=%%~nxH"
            set "skip_group=0"
            if defined GROUP_FILTER (
                echo ";!GROUP_FILTER!;" | findstr /i /c:";!group!;" >nul
                if errorlevel 1 set "skip_group=1"
            )
                        if !skip_group! equ 0 (
                    if exist "%%H\!filename!.wav" (
                        set "processed=1"
                        echo [%time%] Found group !group! for !filename!.wav >> "%LOGFILE%"
                        if !DRY_RUN! equ 0 (
                            call :ensure_group_folder "Final_BIK_!_game!\!group!"
                            call :ensure_folder "Final_BIK_!_game!\!group!\noformat"
                            set "dst=Final_BIK_!_game!\!group!\noformat\!filename!.bik"
                            set "should_mix=1"
                            if !INCREMENTAL! equ 1 if exist "!dst!" (
                                set /a STAT_SKIPPED+=1
                                set "should_mix=0"
                            )
                            if !should_mix! equ 1 (
                                call :run_binkmix "%%F" "%SOUND_SOURCE%\!_game!\!group!\!filename!.wav" "!dst!"
                                if !errorlevel! equ 0 (
                                    set /a STAT_MIXED+=1
                                    echo [%time%] Mixed OK: !filename! >> "%LOGFILE%"
                                ) else (
                                    echo [%time%] ERROR mixing: !filename! >> "%LOGFILE%"
                                    echo !filename! [!_game!/!group!/noformat/sound] >> "%FAILED_FILE%"
                                    set /a STAT_ERRORS+=1
                                )
                            )
                        ) else (
                            echo [%time%] DRY_RUN Clean_BIK !filename! group=!group! >> "%LOGFILE%"
                        )
                    )
                )
            )
            if !processed! equ 0 (echo    Group not found: !filename!)
        )
    )
)
goto :eof
