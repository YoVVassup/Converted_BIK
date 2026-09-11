@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo TEST: Filter Logic (findstr + semicolons)
echo ===================================================

set "_t=0" & set "_p=0" & set "_f=0"

echo ;Original; | findstr /i /c:";Original;" >nul 2>nul
if !errorlevel! equ 0 (call :p "findstr: exact match Original") else (call :f "findstr: exact match Original")

echo ;Original;7wolf; | findstr /i /c:";Orig;" >nul 2>nul
if !errorlevel! equ 1 (call :p "findstr: substring 'Orig' rejected") else (call :f "findstr: substring 'Orig' rejected")

echo ;Original;7wolf; | findstr /i /c:";7wolf;" >nul 2>nul
if !errorlevel! equ 0 (call :p "findstr: multi-group match 7wolf") else (call :f "findstr: multi-group match 7wolf")

echo ;Original;7wolf; | findstr /i /c:";Fargus;" >nul 2>nul
if !errorlevel! equ 1 (call :p "findstr: multi-group Fargus not found") else (call :f "findstr: multi-group Fargus not found")

echo ;600p; | findstr /i /c:";600p;" >nul 2>nul
if !errorlevel! equ 0 (call :p "findstr: single res 600p") else (call :f "findstr: single res 600p")

echo ;600p;720p; | findstr /i /c:";720p;" >nul 2>nul
if !errorlevel! equ 0 (call :p "findstr: multi res 720p") else (call :f "findstr: multi res 720p")

echo ;600p;720p; | findstr /i /c:";900p;" >nul 2>nul
if !errorlevel! equ 1 (call :p "findstr: multi res 900p rejected") else (call :f "findstr: multi res 900p rejected")

echo ;RA1;RA2;RA2YR; | findstr /i /c:";RA2YR;" >nul 2>nul
if !errorlevel! equ 0 (call :p "findstr: game RA2YR") else (call :f "findstr: game RA2YR")

echo.
echo Results: !_p!/!_t! passed, !_f! failed
echo !_p!>%TEMP%\test_filters_passed.txt
echo !_f!>%TEMP%\test_filters_failed.txt
if !_f! gtr 0 (exit /b 1) else (exit /b 0)

:p
set /a _t+=1 & set /a _p+=1
echo   [PASS] %~1
exit /b 0

:f
set /a _t+=1 & set /a _f+=1
echo   [FAIL] %~1
exit /b 0
