@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

call "%~dp0config_loader.bat"

set "PATH1="
set "PATH2="

if not "%~1"=="" (
    "%~dp0third-party\CMDParse\CMDParse.exe" --mode:mix_diff %* > "%TEMP%\diff_args.txt"
    for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\diff_args.txt") do (
        set "%%A=%%B"
    )
    del "%TEMP%\diff_args.txt" 2>nul
)

set "DIFF_TOOL=%TEMP%\mixdiff"
set "DIFF_LOG=%TEMP%\mixdiff_result.txt"

echo Comparison mode:
echo   1. Compare two directories with BIK files
echo   2. Compare two MIX files
echo   3. Compare MIX file with directory
echo.
set /p "MODE=Select mode (1-3): "

if "!MODE!"=="1" goto :mode_dirs
if "!MODE!"=="2" goto :mode_mixes
if "!MODE!"=="3" goto :mode_mix_dir
echo Invalid choice.
pause
endlocal
exit /b 1

:mode_dirs
echo.
echo Enter path to first directory:
set /p "DIR1= "
set "DIR1=!DIR1:"=!"
echo Enter path to second directory:
set /p "DIR2= "
set "DIR2=!DIR2:"=!"

if not exist "!DIR1!\" (echo ERROR: Directory not found: !DIR1! & pause & endlocal & exit /b 1)
if not exist "!DIR2!\" (echo ERROR: Directory not found: !DIR2! & pause & endlocal & exit /b 1)

echo.
echo Comparing:
echo   A: !DIR1!
echo   B: !DIR2!
echo.

call :compare_dirs "!DIR1!" "!DIR2!"
goto :done

:mode_mixes
echo.
echo Enter path to first MIX file:
set /p "MIX1= "
set "MIX1=!MIX1:"=!"
echo Enter path to second MIX file:
set /p "MIX2= "
set "MIX2=!MIX2:"=!"

if not exist "!MIX1!" (echo ERROR: File not found: !MIX1! & pause & endlocal & exit /b 1)
if not exist "!MIX2!" (echo ERROR: File not found: !MIX2! & pause & endlocal & exit /b 1)

echo.
echo Extracting MIX files...

set "TEMP1=%DIFF_TOOL%\mix1"
set "TEMP2=%DIFF_TOOL%\mix2"
if exist "!TEMP1!" rmdir /s /q "!TEMP1!"
if exist "!TEMP2!" rmdir /s /q "!TEMP2!"
mkdir "!TEMP1!"
mkdir "!TEMP2!"

"%CCMIX_TOOL%" --extract --lmd --game=ra2 --mix="!MIX1!" --dir="!TEMP1!" >nul 2>nul
"%CCMIX_TOOL%" --extract --lmd --game=ra2 --mix="!MIX2!" --dir="!TEMP2!" >nul 2>nul

echo.
echo Comparing:
echo   A: !MIX1!
echo   B: !MIX2!
echo.

call :compare_dirs "!TEMP1!" "!TEMP2!"
goto :done

:mode_mix_dir
echo.
echo Enter path to MIX file:
set /p "MIX_PATH= "
set "MIX_PATH=!MIX_PATH:"=!"
echo Enter path to directory:
set /p "DIR_PATH= "
set "DIR_PATH=!DIR_PATH:"=!"

if not exist "!MIX_PATH!" (echo ERROR: File not found: !MIX_PATH! & pause & endlocal & exit /b 1)
if not exist "!DIR_PATH!\" (echo ERROR: Directory not found: !DIR_PATH! & pause & endlocal & exit /b 1)

echo.
echo Extracting MIX file...

set "TEMP_MIX=%DIFF_TOOL%\mix_extract"
if exist "!TEMP_MIX!" rmdir /s /q "!TEMP_MIX!"
mkdir "!TEMP_MIX!"

"%CCMIX_TOOL%" --extract --lmd --game=ra2 --mix="!MIX_PATH!" --dir="!TEMP_MIX!" >nul 2>nul

echo.
echo Comparing:
echo   A (MIX): !MIX_PATH!
echo   B (DIR): !DIR_PATH!
echo.

call :compare_dirs "!TEMP_MIX!" "!DIR_PATH!"
goto :done

:compare_dirs
set "_d1=%~1"
set "_d2=%~2"
set "ADDED=0"
set "REMOVED=0"
set "MODIFIED=0"
set "SAME=0"

echo.
echo Results:
echo =======================================

> "!DIFF_LOG!" echo Comparing directories:
>> "!DIFF_LOG!" echo   A: !_d1!
>> "!DIFF_LOG!" echo   B: !_d2!
>> "!DIFF_LOG!" echo.

rem Check files from D1 against D2 (SAME, MODIFIED, ONLY IN A)
for /r "!_d1!" %%F in (*) do (
    set "full=%%F"
    set "rel=!full:!_d1!=!"
    if "!rel:~0,1!"=="\" set "rel=!rel:~1!"
    if exist "!_d2!\!rel!" (
        set "size_a=0"
        set "size_b=0"
        for %%I in ("!_d1!\!rel!") do set "size_a=%%~zI"
        for %%I in ("!_d2!\!rel!") do set "size_b=%%~zI"
        if !size_a! neq !size_b! (
            echo   MODIFIED: !rel! ^(!size_a! to !size_b!^)
            >> "!DIFF_LOG!" echo   MODIFIED: !rel! ^(!size_a! to !size_b!^)
            set /a MODIFIED+=1
        ) else (set /a SAME+=1)
    ) else (
        echo   ONLY IN A: !rel!
        >> "!DIFF_LOG!" echo   ONLY IN A: !rel!
        set /a REMOVED+=1
    )
)

rem Check files from D2 that don't exist in D1 (ONLY IN B)
for /r "!_d2!" %%F in (*) do (
    set "full=%%F"
    set "rel=!full:!_d2!=!"
    if "!rel:~0,1!"=="\" set "rel=!rel:~1!"
    if not exist "!_d1!\!rel!" (
        echo   ONLY IN B: !rel!
        >> "!DIFF_LOG!" echo   ONLY IN B: !rel!
        set /a ADDED+=1
    )
)

echo.
echo =======================================
echo SUMMARY:
echo   Identical:      !SAME!
echo   Added:          !ADDED!
echo   Removed:        !REMOVED!
echo   Modified:       !MODIFIED!
echo =======================================

>> "!DIFF_LOG!" echo.
>> "!DIFF_LOG!" echo SUMMARY:
>> "!DIFF_LOG!" echo   Identical:      !SAME!
>> "!DIFF_LOG!" echo   Added:          !ADDED!
>> "!DIFF_LOG!" echo   Removed:        !REMOVED!
>> "!DIFF_LOG!" echo   Modified:       !MODIFIED!

echo.
echo Full report: !DIFF_LOG!
goto :eof

:done
if exist "%DIFF_TOOL%" rmdir /s /q "%DIFF_TOOL%" 2>nul
echo.
pause
endlocal
exit /b 0
