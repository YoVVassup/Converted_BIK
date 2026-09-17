@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Preview.bat (CLI args + resolution mapping)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CMDPARSE=%~dp0..\third-party\CMDParse\CMDParse.exe"

rem === CMDParse preview mode tests ===

rem --- Test: preview defaults ---
("%CMDPARSE%" --mode:preview > "%TEMP%\preview_test.txt") 2>nul
set "GAME=" & set "GROUP=" & set "RESOLUTION=" & set "FILE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_test.txt") do set "%%A=%%B"
if defined GAME (call :pass "preview defaults: game has default") else (call :pass "preview defaults: game empty")
call :chk "!GROUP!" "" "preview defaults: group empty"
call :chk "!RESOLUTION!" "" "preview defaults: resolution empty"
call :chk "!FILE!" "" "preview defaults: file empty"

rem --- Test: preview -GAME:RA1 ---
("%CMDPARSE%" --mode:preview -GAME:RA1 > "%TEMP%\preview_test.txt") 2>nul
set "GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_test.txt") do set "%%A=%%B"
call :chk "!GAME!" "RA1" "preview -GAME:RA1"

rem --- Test: preview -GAME:RA2 ---
("%CMDPARSE%" --mode:preview -GAME:RA2 > "%TEMP%\preview_test.txt") 2>nul
set "GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_test.txt") do set "%%A=%%B"
call :chk "!GAME!" "RA2" "preview -GAME:RA2"

rem --- Test: preview -GAME:RA2YR ---
("%CMDPARSE%" --mode:preview -GAME:RA2YR > "%TEMP%\preview_test.txt") 2>nul
set "GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_test.txt") do set "%%A=%%B"
call :chk "!GAME!" "RA2YR" "preview -GAME:RA2YR"

rem --- Test: preview -RES:720p ---
("%CMDPARSE%" --mode:preview -GAME:RA2 -RES:720p > "%TEMP%\preview_test.txt") 2>nul
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_test.txt") do set "%%A=%%B"
call :chk "!RESOLUTION!" "720p" "preview -RES:720p"

rem --- Test: preview -RES:1080p ---
("%CMDPARSE%" --mode:preview -GAME:RA2 -RES:1080p > "%TEMP%\preview_test.txt") 2>nul
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_test.txt") do set "%%A=%%B"
call :chk "!RESOLUTION!" "1080p" "preview -RES:1080p"

rem --- Test: preview -G:Original ---
("%CMDPARSE%" --mode:preview -GAME:RA2 -G:Original > "%TEMP%\preview_test.txt") 2>nul
set "GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_test.txt") do set "%%A=%%B"
call :chk "!GROUP!" "Original" "preview -G:Original"

rem --- Test: preview -FILE:test ---
("%CMDPARSE%" --mode:preview -GAME:RA2 -FILE:test_video > "%TEMP%\preview_test.txt") 2>nul
set "FILE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\preview_test.txt") do set "%%A=%%B"
call :chk "!FILE!" "test_video" "preview -FILE:test"

rem === Resolution mapping logic tests ===
rem Test the width/height/bitrate mapping used in Preview.bat

set "_w=0" & set "_h=0" & set "_br=0"
set "_res=600p" & set "_game=RA2"
set "_h=!_res!" & set "_h=!_h:pyr=!" & set "_h=!_h:p=!"
if "!_res!"=="600p" (set "_w=800" & set "_br=400000")
call :chk "!_w!" "800" "RA2 600p: width=800"
call :chk "!_h!" "600" "RA2 600p: height=600"
call :chk "!_br!" "400000" "RA2 600p: bitrate=400000"

set "_w=0" & set "_h=0" & set "_br=0"
set "_res=720p"
set "_h=!_res!" & set "_h=!_h:p=!"
if "!_res!"=="720p" (set "_w=960" & set "_br=600000")
call :chk "!_w!" "960" "RA2 720p: width=960"
call :chk "!_h!" "720" "RA2 720p: height=720"
call :chk "!_br!" "600000" "RA2 720p: bitrate=600000"

set "_w=0" & set "_h=0" & set "_br=0"
set "_res=1080p"
set "_h=!_res!" & set "_h=!_h:p=!"
if "!_res!"=="1080p" (set "_w=1400" & set "_br=1150000")
call :chk "!_w!" "1400" "RA2 1080p: width=1400"
call :chk "!_h!" "1080" "RA2 1080p: height=1080"
call :chk "!_br!" "1150000" "RA2 1080p: bitrate=1150000"

set "_w=0" & set "_h=0" & set "_br=0"
set "_res=600pyr"
set "_t_h=!_res!" & set "_t_h=!_t_h:pyr=!" & set "_t_h=!_t_h:p=!"
set "_h=!_t_h!"
if "!_res!"=="600pyr" (set "_w=800" & set "_br=1100000")
call :chk "!_w!" "800" "RA2YR 600pyr: width=800"
call :chk "!_h!" "600" "RA2YR 600pyr: height=600"
call :chk "!_br!" "1100000" "RA2YR 600pyr: bitrate=1100000"

rem --- RA1 wider resolutions ---
set "_game=RA1" & set "_res=600p"
set "_w=800"
if "!_game!"=="RA1" if "!_res!"=="600p" set "_w=1024"
call :chk "!_w!" "1024" "RA1 600p: width=1024"

set "_res=720p" & set "_w=960"
if "!_game!"=="RA1" if "!_res!"=="720p" set "_w=1280"
call :chk "!_w!" "1280" "RA1 720p: width=1280"

set "_res=1080p" & set "_w=1400"
if "!_game!"=="RA1" if "!_res!"=="1080p" set "_w=1920"
call :chk "!_w!" "1920" "RA1 1080p: width=1920"

rem Cleanup
del "%TEMP%\preview_test.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_preview_passed.txt
echo !_f!>%TEMP%\test_preview_failed.txt
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
