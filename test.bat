@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ========================================
echo Conversion Pipeline Test
echo ========================================
echo.

call "%~dp0config_loader.bat"

set PASS=0
set FAIL=0
set TEST_BIK=%TEMP%\test_pipeline.bik

echo [1/6] Checking tools...
set t_pass=1
if not exist "%NEW_RAD%" (echo    FAIL: %NEW_RAD% & set t_pass=0)
if not exist "%OLD_MIX%" (echo    FAIL: %OLD_MIX% & set t_pass=0)
if not exist "%CCMIX_TOOL%" (echo    FAIL: %CCMIX_TOOL% & set t_pass=0)
if !t_pass! equ 1 (echo    OK & set /a PASS+=1) else (set /a FAIL+=1)

echo [2/6] Checking folders...
set t_pass=1
if not exist "%MP4_SOURCE%\" (echo    FAIL: %MP4_SOURCE% & set t_pass=0)
if not exist "%SOUND_SOURCE%\" (echo    FAIL: %SOUND_SOURCE% & set t_pass=0)
if !t_pass! equ 1 (echo    OK & set /a PASS+=1) else (set /a FAIL+=1)

echo [3/6] Converting MP4 to BIK...
set t_pass=1
set TEST_MP4=
for %%F in ("%MP4_SOURCE%\RA2\*.mp4") do (
    if not defined TEST_MP4 set "TEST_MP4=%%F"
)
if not defined TEST_MP4 (
    echo    FAIL: No MP4 files found
    set t_pass=0
) else (
    powershell -NoProfile -Command "Start-Process -FilePath '%NEW_RAD%' -ArgumentList 'Binkc \"!TEST_MP4!\" \"%TEST_BIK%\" /N-1 /(800 /)600 /v100 /:0 /D400000 /L0 /O /Z0 /#' -WindowStyle Hidden -Wait"
    if !errorlevel! neq 0 (echo    FAIL: conversion error & set t_pass=0)
    if exist "%TEST_BIK%" (
        set bs=0
        for %%I in ("%TEST_BIK%") do set bs=%%~zI
        if !bs! equ 0 (echo    FAIL: empty file & del "%TEST_BIK%" 2>nul & set t_pass=0)
    ) else (echo    FAIL: file not created & set t_pass=0)
)
if !t_pass! equ 1 (echo    OK & set /a PASS+=1) else (set /a FAIL+=1)

echo [4/6] Checking BinkMix.exe...
set t_pass=1
if not exist "%OLD_MIX%" (echo    FAIL: %OLD_MIX% not found & set t_pass=0) else (echo    OK ^(GUI tool, existence check^))
if !t_pass! equ 1 (set /a PASS+=1) else (set /a FAIL+=1)

echo [5/6] Checking nolang config...
set t_pass=1
if not defined NOLANG_FILES_HD (
    echo    FAIL: NOLANG_FILES_HD not set in config.ini
    set t_pass=0
)
if !t_pass! equ 1 (echo    OK & set /a PASS+=1) else (set /a FAIL+=1)

echo [6/6] Testing DRY_RUN...
set t_pass=1
"%~dp0Cross_Converted_BIK.bat" -RA2 -GROUP:Original -RES:600p -DRY_RUN >nul 2>nul
if !errorlevel! neq 0 (echo    FAIL: DRY_RUN returned error & set t_pass=0)
if !t_pass! equ 1 (echo    OK & set /a PASS+=1) else (set /a FAIL+=1)

if exist "%TEST_BIK%" del "%TEST_BIK%"

echo.
echo ========================================
echo TEST RESULTS
echo ========================================
echo Passed: !PASS!/6
echo Failed: !FAIL!/6
echo.

if !FAIL! equ 0 (echo All tests passed! & exit /b 0) else (echo Errors found. Check dependencies. & exit /b 1)
