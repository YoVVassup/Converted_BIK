@echo off
chcp 65001 > nul

rem ===================================================
rem УСТАНОВКА ПУТЕЙ
rem ===================================================

rem Текущая директория
set "CURRENT_DIR=%~dp0"

rem Путь к утилите ccmix
set "CCMIX_TOOL=%CURRENT_DIR%CCMIX\ccmix.exe"

rem Входные папки с BIK файлами
set "SOURCE_RA2=%CURRENT_DIR%Final_BIK_RA2"
set "SOURCE_RA2YR=%CURRENT_DIR%Final_BIK_RA2YR"

rem Папки с key.ini файлами
set "KEY_SOURCE=%CURRENT_DIR%Original_MIX_Key"

rem Выходные папки для сборки
set "BUILD_ROOT=%CURRENT_DIR%Build\OriginalGames"
set "OUTPUT_RA2=RA2_Original"
set "OUTPUT_RA2YR=YR_Original"

rem ===================================================
rem ПАРАМЕТРЫ КОМАНДНОЙ СТРОКИ
rem ===================================================

rem Обработка параметров с пробелами
setlocal enabledelayedexpansion

rem Первый параметр - озвучка (может содержать пробелы, нужно взять все кроме последнего)
rem Последний параметр - разрешение

rem Счетчик параметров
set param_count=0
for %%a in (%*) do set /a param_count+=1

if %param_count% lss 2 (
    echo.
    echo ОШИБКА: Не указаны обязательные параметры
    echo.
    echo Использование: %~nx0 ^"озвучка^" разрешение
    echo.
    echo Примеры:
    echo   %~nx0 "Russian project" 1080p
    echo   %~nx0 "XXI Vek [8 Bit]" 720p
    echo   %~nx0 "City [Dyadyushka Risyotch]" 600p
    echo.
    pause
    exit /b 1
)

rem Собираем озвучку (все параметры кроме последнего)
set AUDIO_GROUP=
set /a i=0
for %%a in (%*) do (
    set /a i+=1
    if !i! lss %param_count% (
        if "!AUDIO_GROUP!"=="" (
            set "AUDIO_GROUP=%%~a"
        ) else (
            set "AUDIO_GROUP=!AUDIO_GROUP! %%~a"
        )
    ) else (
        set "RESOLUTION=%%~a"
    )
)

rem Удаляем кавычки если они есть
set "AUDIO_GROUP=!AUDIO_GROUP:"=!"
set "RESOLUTION=!RESOLUTION:"=!"

echo.
echo ===================================================
echo Упаковка оригинальных игр
echo ===================================================
echo Озвучка: !AUDIO_GROUP!
echo Разрешение: !RESOLUTION!
echo.

rem Проверяем наличие инструмента ccmix
if not exist "%CCMIX_TOOL%" (
    echo ОШИБКА: Не найден инструмент ccmix.exe
    echo Проверьте путь: %CCMIX_TOOL%
    pause
    exit /b 1
)

echo [OK] Инструмент ccmix.exe найден

rem Проверяем наличие исходной папки для RA2
if not exist "%SOURCE_RA2%\!AUDIO_GROUP!\" (
    echo ОШИБКА: Не найдена папка для RA2
    echo Проверьте: %SOURCE_RA2%\!AUDIO_GROUP!\
    echo.
    echo Доступные озвучки в RA2:
    if exist "%SOURCE_RA2%\" (
        dir "%SOURCE_RA2%\" /b /ad
    )
    pause
    exit /b 1
)

echo [OK] Папка RA2 найдена

rem Проверяем наличие папки с key.ini
if not exist "%KEY_SOURCE%\" (
    echo [ВНИМАНИЕ] Папка с key.ini не найдена: %KEY_SOURCE%\
    echo Продолжаем без key.ini...
)

rem Создаем корневую папку сборки
if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"

rem ===================================================
rem ОБРАБОТКА RED ALERT 2
rem ===================================================

echo.
echo [RA2] Начало обработки...

set RA2_SOURCE_DIR=%SOURCE_RA2%\!AUDIO_GROUP!
set RA2_OUTPUT_DIR=%BUILD_ROOT%\%OUTPUT_RA2%\!AUDIO_GROUP!

if not exist "!RA2_OUTPUT_DIR!" mkdir "!RA2_OUTPUT_DIR!"

rem --- movies01.mix (файлы на "a" + westlogo.bik + key.ini) ---
echo.
echo Создание movies01.mix...

set TEMP_DIR=%TEMP%\ra2_m1_%RANDOM%
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!"
mkdir "!TEMP_DIR!"

set FILE_COUNT=0

rem 1. Копируем файлы из папки разрешения
if exist "!RA2_SOURCE_DIR!\!RESOLUTION!\" (
    pushd "!RA2_SOURCE_DIR!\!RESOLUTION!"
    for %%F in (a*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        set /a FILE_COUNT+=1
    )
    if exist "westlogo.bik" (
        copy "westlogo.bik" "!TEMP_DIR!\" >nul
        set /a FILE_COUNT+=1
    )
    popd
)

rem 2. Копируем файлы из noformat
if exist "!RA2_SOURCE_DIR!\noformat\" (
    pushd "!RA2_SOURCE_DIR!\noformat"
    for %%F in (a*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        set /a FILE_COUNT+=1
    )
    if exist "westlogo.bik" (
        copy "westlogo.bik" "!TEMP_DIR!\" >nul
        set /a FILE_COUNT+=1
    )
    popd
)

rem 3. Копируем key.ini для movies01
if exist "%KEY_SOURCE%\movies01\key.ini" (
    copy "%KEY_SOURCE%\movies01\key.ini" "!TEMP_DIR!\" >nul
    echo [INFO] Добавлен key.ini для movies01
) else (
    if exist "%KEY_SOURCE%\" (
        echo [ВНИМАНИЕ] Не найден key.ini для movies01
    )
)

rem Упаковываем файлы
if !FILE_COUNT! GTR 0 (
    "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR!" --mix "!RA2_OUTPUT_DIR!\movies01.mix" >nul
    echo [OK] Создан movies01.mix (файлов: !FILE_COUNT!^)
) else (
    echo [ВНИМАНИЕ] Не найдено файлов для movies01.mix
)

if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" 2>nul

rem --- movies02.mix (файлы на "s" + key.ini) ---
echo.
echo Создание movies02.mix...

set TEMP_DIR=%TEMP%\ra2_m2_%RANDOM%
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!"
mkdir "!TEMP_DIR!"

set FILE_COUNT=0

rem 1. Копируем файлы из папки разрешения
if exist "!RA2_SOURCE_DIR!\!RESOLUTION!\" (
    pushd "!RA2_SOURCE_DIR!\!RESOLUTION!"
    for %%F in (s*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        set /a FILE_COUNT+=1
    )
    popd
)

rem 2. Копируем файлы из noformat
if exist "!RA2_SOURCE_DIR!\noformat\" (
    pushd "!RA2_SOURCE_DIR!\noformat"
    for %%F in (s*.bik) do (
        copy "%%F" "!TEMP_DIR!\" >nul
        set /a FILE_COUNT+=1
    )
    popd
)

rem 3. Копируем key.ini для movies02
if exist "%KEY_SOURCE%\movies02\key.ini" (
    copy "%KEY_SOURCE%\movies02\key.ini" "!TEMP_DIR!\" >nul
    echo [INFO] Добавлен key.ini для movies02
) else (
    if exist "%KEY_SOURCE%\" (
        echo [ВНИМАНИЕ] Не найден key.ini для movies02
    )
)

rem Упаковываем файлы
if !FILE_COUNT! GTR 0 (
    "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR!" --mix "!RA2_OUTPUT_DIR!\movies02.mix" >nul
    echo [OK] Создан movies02.mix (файлов: !FILE_COUNT!^)
) else (
    echo [ВНИМАНИЕ] Не найдено файлов для movies02.mix
)

if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" 2>nul

rem ===================================================
rem ОБРАБОТКА YURI'S REVENGE
rem ===================================================

rem Проверяем наличие папки RA2YR
if exist "%SOURCE_RA2YR%\!AUDIO_GROUP!\" (
    echo.
    echo [RA2YR] Начало обработки...
    
    set YR_SOURCE_DIR=%SOURCE_RA2YR%\!AUDIO_GROUP!
    set YR_OUTPUT_DIR=%BUILD_ROOT%\%OUTPUT_RA2YR%\!AUDIO_GROUP!
    
    if not exist "!YR_OUTPUT_DIR!" mkdir "!YR_OUTPUT_DIR!"
    
    rem --- movmd03.mix (все файлы + key.ini) ---
    echo.
    echo Создание movmd03.mix...
    
    set TEMP_DIR=%TEMP%\ra2yr_m3_%RANDOM%
    if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!"
    mkdir "!TEMP_DIR!"
    
    set FILE_COUNT=0
    
    rem 1. Копируем все файлы из папки разрешения
    if exist "!YR_SOURCE_DIR!\!RESOLUTION!\" (
        pushd "!YR_SOURCE_DIR!\!RESOLUTION!"
        for %%F in (*.bik) do (
            copy "%%F" "!TEMP_DIR!\" >nul
            set /a FILE_COUNT+=1
        )
        popd
    )
    
    rem 2. Копируем все файлы из noformat
    if exist "!YR_SOURCE_DIR!\noformat\" (
        pushd "!YR_SOURCE_DIR!\noformat"
        for %%F in (*.bik) do (
            copy "%%F" "!TEMP_DIR!\" >nul
            set /a FILE_COUNT+=1
        )
        popd
    )
    
    rem 3. Копируем key.ini для movmd03
    if exist "%KEY_SOURCE%\movmd03\key.ini" (
        copy "%KEY_SOURCE%\movmd03\key.ini" "!TEMP_DIR!\" >nul
        echo [INFO] Добавлен key.ini для movmd03
    ) else (
        if exist "%KEY_SOURCE%\" (
            echo [ВНИМАНИЕ] Не найден key.ini для movmd03
        )
    )
    
    rem Упаковываем файлы
    if !FILE_COUNT! GTR 0 (
        "%CCMIX_TOOL%" --create --lmd --game=ra2 --dir "!TEMP_DIR!" --mix "!YR_OUTPUT_DIR!\movmd03.mix" >nul
        echo [OK] Создан movmd03.mix (файлов: !FILE_COUNT!^)
    ) else (
        echo [ВНИМАНИЕ] Не найдено файлов для movmd03.mix
    )
    
    if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" 2>nul
    
) else (
    echo.
    echo [ИНФО] Папка RA2YR не найдена, пропускаем...
)

echo.
echo ===================================================
echo ОБРАБОТКА ЗАВЕРШЕНА
echo ===================================================

echo.
echo Результаты сохранены в:
echo   RA2:   !RA2_OUTPUT_DIR!\
if exist "%SOURCE_RA2YR%\!AUDIO_GROUP!\" (
    echo   RA2YR: !YR_OUTPUT_DIR!\
)
echo.

pause
exit /b 0