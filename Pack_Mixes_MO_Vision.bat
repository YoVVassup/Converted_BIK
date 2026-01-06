@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem ===================================================
rem НАСТРОЙКИ ПУТЕЙ
rem ===================================================

rem Путь к утилите ccmix
set "CCMIX_TOOL=CCMIX\ccmix.exe"

rem Входные папки с BIK файлами
set "SOURCE_RA1=Final_BIK_RA1"
set "SOURCE_RA2=Final_BIK_RA2"
set "SOURCE_RA2YR=Final_BIK_RA2YR"

rem Выходные папки для сборки
set "BUILD_ROOT=Build\MOV"
set "OUTPUT_RA1=RA1_Remake"
set "OUTPUT_RA2_YURI=RA2_and_RA2YR_Remake"

rem Список разрешений для обработки
set "RESOLUTIONS_LIST=600p 720p 768p 900p 1080p"

rem Проверка наличия инструмента
if not exist "%CCMIX_TOOL%" (
    echo ОШИБКА: Не найден инструмент упаковки %CCMIX_TOOL%
    pause
    exit /b 1
)

rem Создание корневой папки сборки
if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"

rem ===================================================
rem БЛОК 1: RED ALERT 1 (RA1)
rem Специфичная логика для Original (разделение nolang)
rem и смена слотов для остальных групп.
rem ===================================================

if exist "%SOURCE_RA1%" (
    echo.
    echo [RA1] Начало упаковки...

    for /d %%G in ("%SOURCE_RA1%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "TARGET_DIR=%BUILD_ROOT%\%OUTPUT_RA1%\!AUDIO_GROUP!"
        
        echo -- Группа: !AUDIO_GROUP!
        if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"

        rem --- ЛОГИКА ДЛЯ ORIGINAL ---
        if /i "!AUDIO_GROUP!"=="Original" (
            
            rem Обработка разрешений (Original)
            for %%R in (%RESOLUTIONS_LIST%) do (
                set "RESOLUTION=%%R"
                set "SOURCE_DIR=%%G\!RESOLUTION!"

                rem 1. Упаковка nolang -> expandmo11
                if exist "!SOURCE_DIR!\nolang" (
                    "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR!\nolang" --mix "!TARGET_DIR!\expandmo11_!RESOLUTION!.mix" > nul
                    echo    Packed [Original]: expandmo11_!RESOLUTION!.mix ^(from nolang^)
                )

                rem 2. Упаковка основного -> expandmo13
                if exist "!SOURCE_DIR!" (
                    "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR!" --mix "!TARGET_DIR!\expandmo13_!RESOLUTION!.mix" > nul
                    echo    Packed [Original]: expandmo13_!RESOLUTION!.mix
                )
            )

            rem Обработка noformat (Original)
            set "SOURCE_DIR_NOFORMAT=%%G\noformat"
            
            rem 1. Упаковка nolang -> expandmo12
            if exist "!SOURCE_DIR_NOFORMAT!\nolang" (
                "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!\nolang" --mix "!TARGET_DIR!\expandmo12.mix" > nul
                echo    Packed [Original]: expandmo12.mix ^(from nolang^)
            )

            rem 2. Упаковка основного -> expandmo14
            if exist "!SOURCE_DIR_NOFORMAT!" (
                "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!" --mix "!TARGET_DIR!\expandmo14.mix" > nul
                echo    Packed [Original]: expandmo14.mix
            )

        ) else (
            rem --- ЛОГИКА ДЛЯ ОСТАЛЬНЫХ ГРУПП ---
            rem Используются expandmo13 и expandmo14

            rem Обработка разрешений
            for %%R in (%RESOLUTIONS_LIST%) do (
                set "RESOLUTION=%%R"
                set "SOURCE_DIR=%%G\!RESOLUTION!"
                
                if exist "!SOURCE_DIR!" (
                    "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR!" --mix "!TARGET_DIR!\expandmo13_!RESOLUTION!.mix" > nul
                    echo    Packed [!AUDIO_GROUP!]: expandmo13_!RESOLUTION!.mix
                )
            )

            rem Обработка noformat
            set "SOURCE_DIR_NOFORMAT=%%G\noformat"
            if exist "!SOURCE_DIR_NOFORMAT!" (
                "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!" --mix "!TARGET_DIR!\expandmo14.mix" > nul
                echo    Packed [!AUDIO_GROUP!]: expandmo14.mix
            )
        )
    )
)

rem ===================================================
rem БЛОК 2: RED ALERT 2 (RA2)
rem Стандартная упаковка в expandmo11 и expandmo12
rem ===================================================

if exist "%SOURCE_RA2%" (
    echo.
    echo [RA2] Начало упаковки...

    for /d %%G in ("%SOURCE_RA2%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "TARGET_DIR=%BUILD_ROOT%\%OUTPUT_RA2_YURI%\!AUDIO_GROUP!"
        
        echo -- Группа: !AUDIO_GROUP!
        if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"

        rem Разрешения -> expandmo11
        for %%R in (%RESOLUTIONS_LIST%) do (
            set "RESOLUTION=%%R"
            set "SOURCE_DIR=%%G\!RESOLUTION!"
            
            if exist "!SOURCE_DIR!" (
                "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR!" --mix "!TARGET_DIR!\expandmo11_!RESOLUTION!.mix" > nul
                echo    Packed: expandmo11_!RESOLUTION!.mix
            )
        )

        rem Noformat -> expandmo12
        set "SOURCE_DIR_NOFORMAT=%%G\noformat"
        if exist "!SOURCE_DIR_NOFORMAT!" (
            "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!" --mix "!TARGET_DIR!\expandmo12.mix" > nul
            echo    Packed: expandmo12.mix
        )
    )
)

rem ===================================================
rem БЛОК 3: YURI'S REVENGE (RA2YR)
rem + суффикс _yr и пакует в expandmo13 и expandmo14
rem ===================================================

if exist "%SOURCE_RA2YR%" (
    echo.
    echo [RA2YR] Начало переименования и упаковки...

    for /d %%G in ("%SOURCE_RA2YR%\*") do (
        set "AUDIO_GROUP=%%~nxG"
        set "TARGET_DIR=%BUILD_ROOT%\%OUTPUT_RA2_YURI%\!AUDIO_GROUP!"
        
        echo -- Группа: !AUDIO_GROUP!
        if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"

        rem --- Обработка разрешений ---
        for %%R in (%RESOLUTIONS_LIST%) do (
            set "RESOLUTION=%%R"
            set "SOURCE_DIR=%%G\!RESOLUTION!"
            
            if exist "!SOURCE_DIR!" (
                rem Переименование файлов (_yr)
                pushd "!SOURCE_DIR!"
                for %%F in (*.bik) do (
                    set "FILENAME=%%~nF"
                    if /i not "!FILENAME:~-3!"=="_yr" (
                        ren "%%F" "!FILENAME!_yr.bik"
                    )
                )
                popd

                rem Упаковка -> expandmo13
                "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR!" --mix "!TARGET_DIR!\expandmo13_!RESOLUTION!.mix" > nul
                echo    Packed: expandmo13_!RESOLUTION!.mix
            )
        )

        rem --- Обработка noformat ---
        set "SOURCE_DIR_NOFORMAT=%%G\noformat"
        if exist "!SOURCE_DIR_NOFORMAT!" (
            rem Переименование файлов (_yr)
            pushd "!SOURCE_DIR_NOFORMAT!"
            for %%F in (*.bik) do (
                set "FILENAME=%%~nF"
                if /i not "!FILENAME:~-3!"=="_yr" (
                    ren "%%F" "!FILENAME!_yr.bik"
                )
            )
            popd

            rem Упаковка -> expandmo14
            "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!SOURCE_DIR_NOFORMAT!" --mix "!TARGET_DIR!\expandmo14.mix" > nul
            echo    Packed: expandmo14.mix
        )
    )
)

echo.
echo Все операции завершены.
pause