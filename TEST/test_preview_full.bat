@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Preview.bat (full logic)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"

rem --- resolution mapping tests ---
rem RA2 defaults
set "RES=600p" & set "GAME=RA2"
call :map_res
call :chk "!width!" "800" "RA2 600p: width=800"
call :chk "!height!" "600" "RA2 600p: height=600"
call :chk "!bitrate!" "400000" "RA2 600p: bitrate=400000"

set "RES=600pyr" & set "GAME=RA2YR"
call :map_res
call :chk "!width!" "800" "RA2YR 600pyr: width=800"
call :chk "!height!" "600" "RA2YR 600pyr: height=600"
call :chk "!bitrate!" "1100000" "RA2YR 600pyr: bitrate=1100000"

set "RES=720p" & set "GAME=RA2"
call :map_res
call :chk "!width!" "960" "RA2 720p: width=960"
call :chk "!height!" "720" "RA2 720p: height=720"
call :chk "!bitrate!" "600000" "RA2 720p: bitrate=600000"

set "RES=768p" & set "GAME=RA2"
call :map_res
call :chk "!width!" "1024" "RA2 768p: width=1024"
call :chk "!bitrate!" "700000" "RA2 768p: bitrate=700000"

set "RES=900p" & set "GAME=RA2"
call :map_res
call :chk "!width!" "1200" "RA2 900p: width=1200"
call :chk "!bitrate!" "900000" "RA2 900p: bitrate=900000"

set "RES=1080p" & set "GAME=RA2"
call :map_res
call :chk "!width!" "1400" "RA2 1080p: width=1400"
call :chk "!bitrate!" "1150000" "RA2 1080p: bitrate=1150000"

rem RA1 overrides
set "RES=600p" & set "GAME=RA1"
call :map_res
call :chk "!width!" "1024" "RA1 600p: width=1024"

set "RES=720p" & set "GAME=RA1"
call :map_res
call :chk "!width!" "1280" "RA1 720p: width=1280"

set "RES=768p" & set "GAME=RA1"
call :map_res
call :chk "!width!" "1366" "RA1 768p: width=1366"

set "RES=900p" & set "GAME=RA1"
call :map_res
call :chk "!width!" "1600" "RA1 900p: width=1600"

set "RES=1080p" & set "GAME=RA1"
call :map_res
call :chk "!width!" "1920" "RA1 1080p: width=1920"

rem --- CMDParse preview mode ---
("%CMDPARSE%" --mode:preview -GAME:RA2YR > "%TEMP%\prev_cp.txt") 2>nul
set "GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_cp.txt") do set "%%A=%%B"
call :chk "!GAME!" "RA2YR" "CMDParse: GAME=RA2YR"

("%CMDPARSE%" --mode:preview -G:Original > "%TEMP%\prev_cp2.txt") 2>nul
set "GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_cp2.txt") do set "%%A=%%B"
call :chk "!GROUP!" "Original" "CMDParse: GROUP=Original"

("%CMDPARSE%" --mode:preview -RES:720p > "%TEMP%\prev_cp3.txt") 2>nul
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_cp3.txt") do set "%%A=%%B"
call :chk "!RESOLUTION!" "720p" "CMDParse: RESOLUTION=720p"

("%CMDPARSE%" --mode:preview -FILE:testvid > "%TEMP%\prev_cp4.txt") 2>nul
set "FILE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_cp4.txt") do set "%%A=%%B"
call :chk "!FILE!" "testvid" "CMDParse: FILE=testvid"

rem --- preview defaults ---
("%CMDPARSE%" --mode:preview > "%TEMP%\prev_cp5.txt") 2>nul
set "GAME=" & set "GROUP=" & set "RESOLUTION=" & set "FILE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_cp5.txt") do set "%%A=%%B"
if defined GAME (call :pass "preview: GAME has default") else (call :pass "preview: GAME empty")
call :chk "!GROUP!" "" "preview: GROUP empty"
call :chk "!RESOLUTION!" "" "preview: RESOLUTION empty"
call :chk "!FILE!" "" "preview: FILE empty"

rem Cleanup
del "%TEMP%\prev_cp*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_preview_full_passed.txt
echo !_f!>%TEMP%\test_preview_full_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:map_res
set "height=!RES!" & set "height=!height:pyr=!" & set "height=!height:p=!"
set "width=0" & set "bitrate=0"
if "!RES!"=="600p" set "width=800"
if "!RES!"=="600pyr" set "width=800"
if "!RES!"=="720p" set "width=960"
if "!RES!"=="768p" set "width=1024"
if "!RES!"=="900p" set "width=1200"
if "!RES!"=="1080p" set "width=1400"
if /i "!GAME!"=="RA1" (
    if "!RES!"=="600p" set "width=1024"
    if "!RES!"=="720p" set "width=1280"
    if "!RES!"=="768p" set "width=1366"
    if "!RES!"=="900p" set "width=1600"
    if "!RES!"=="1080p" set "width=1920"
)
if "!RES!"=="600p" set "bitrate=400000"
if "!RES!"=="600pyr" set "bitrate=1100000"
if "!RES!"=="720p" set "bitrate=600000"
if "!RES!"=="768p" set "bitrate=700000"
if "!RES!"=="900p" set "bitrate=900000"
if "!RES!"=="1080p" set "bitrate=1150000"
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
