@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Preview.bat (CMDParse validation)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"
set "CP=%~dp0..\third-party\CMDParse\CMDParse.exe"

rem --- Test: defaults ---
("%CP%" --mode:preview > "%TEMP%\prev_edge_cp.txt") 2>nul
set "GAME=" & set "GROUP=" & set "RESOLUTION=" & set "FILE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp.txt") do set "%%A=%%B"
if "!RESOLUTION!"=="" (call :pass "RESOLUTION default empty") else (call :fail "RESOLUTION default: got=!RESOLUTION!")
if "!FILE!"=="" (call :pass "FILE default empty") else (call :fail "FILE default: got=!FILE!")

rem --- Test: -GAME:RA2 ---
("%CP%" --mode:preview -GAME:RA2 > "%TEMP%\prev_edge_cp2.txt") 2>nul
set "GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp2.txt") do if "%%A"=="GAME" set "GAME=%%B"
if "!GAME!"=="RA2" (call :pass "-GAME:RA2 parsed") else (call :fail "-GAME:RA2: got=!GAME!")

rem --- Test: -GAME:RA1 ---
("%CP%" --mode:preview -GAME:RA1 > "%TEMP%\prev_edge_cp3.txt") 2>nul
set "GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp3.txt") do if "%%A"=="GAME" set "GAME=%%B"
if "!GAME!"=="RA1" (call :pass "-GAME:RA1 parsed") else (call :fail "-GAME:RA1: got=!GAME!")

rem --- Test: -GAME:RA2YR ---
("%CP%" --mode:preview -GAME:RA2YR > "%TEMP%\prev_edge_cp4.txt") 2>nul
set "GAME="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp4.txt") do if "%%A"=="GAME" set "GAME=%%B"
if "!GAME!"=="RA2YR" (call :pass "-GAME:RA2YR parsed") else (call :fail "-GAME:RA2YR: got=!GAME!")

rem --- Test: -GROUP:soviets ---
("%CP%" --mode:preview -GROUP:soviets > "%TEMP%\prev_edge_cp5.txt") 2>nul
set "GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp5.txt") do if "%%A"=="GROUP" set "GROUP=%%B"
if "!GROUP!"=="soviets" (call :pass "-GROUP:soviets parsed") else (call :fail "-GROUP:soviets: got=!GROUP!")

rem --- Test: -GROUP:allies ---
("%CP%" --mode:preview -GROUP:allies > "%TEMP%\prev_edge_cp6.txt") 2>nul
set "GROUP="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp6.txt") do if "%%A"=="GROUP" set "GROUP=%%B"
if "!GROUP!"=="allies" (call :pass "-GROUP:allies parsed") else (call :fail "-GROUP:allies: got=!GROUP!")

rem --- Test: -RES:600p ---
("%CP%" --mode:preview -RES:600p > "%TEMP%\prev_edge_cp7.txt") 2>nul
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp7.txt") do if "%%A"=="RESOLUTION" set "RESOLUTION=%%B"
if "!RESOLUTION!"=="600p" (call :pass "-RES:600p parsed") else (call :fail "-RES:600p: got=!RESOLUTION!")

rem --- Test: -RES:720p ---
("%CP%" --mode:preview -RES:720p > "%TEMP%\prev_edge_cp8.txt") 2>nul
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp8.txt") do if "%%A"=="RESOLUTION" set "RESOLUTION=%%B"
if "!RESOLUTION!"=="720p" (call :pass "-RES:720p parsed") else (call :fail "-RES:720p: got=!RESOLUTION!")

rem --- Test: -RES:1080p ---
("%CP%" --mode:preview -RES:1080p > "%TEMP%\prev_edge_cp9.txt") 2>nul
set "RESOLUTION="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp9.txt") do if "%%A"=="RESOLUTION" set "RESOLUTION=%%B"
if "!RESOLUTION!"=="1080p" (call :pass "-RES:1080p parsed") else (call :fail "-RES:1080p: got=!RESOLUTION!")

rem --- Test: combined args ---
("%CP%" --mode:preview -GAME:RA2 -RES:720p -GROUP:soviets -FILE:test.bik > "%TEMP%\prev_edge_cp10.txt") 2>nul
set "GAME=" & set "RESOLUTION=" & set "GROUP=" & set "FILE="
for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\prev_edge_cp10.txt") do set "%%A=%%B"
if "!GAME!"=="RA2" if "!RESOLUTION!"=="720p" if "!GROUP!"=="soviets" if "!FILE!"=="test.bik" (
    call :pass "combined args all parsed"
) else (
    call :fail "combined: game=!GAME! res=!RESOLUTION! grp=!GROUP! file=!FILE!"
)

del "%TEMP%\prev_edge*.txt" 2>nul

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_prev_edge_passed.txt
echo !_f!>%TEMP%\test_prev_edge_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:pass
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:fail
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
