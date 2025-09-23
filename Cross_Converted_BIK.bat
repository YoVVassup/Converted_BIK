@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem Установка путей к инструментам
set "NEW_RAD=Radtools_New\radvideo64.exe"
set "OLD_MIX=Radtools_Old\BinkMix.exe"

rem Основные папки
set "MP4_SOURCE=Clean_MP4"
set "SOUND_SOURCE=WAV_Sound"
set "CLEAN_BIK=Clean_BIK"
set "Final_BIK_RA1=Final_BIK_RA1"
set "Final_BIK_RA2=Final_BIK_RA2"
set "Final_BIK_RA2YR=Final_BIK_RA2YR"

rem Определяем какие игры обрабатывать
set "PROCESS_RA1=0"
set "PROCESS_RA2=0"
set "PROCESS_RA2YR=0"

rem Если параметры не указаны, обрабатываем все игры
if "%~1"=="" (
    set "PROCESS_RA1=1"
    set "PROCESS_RA2=1"
    set "PROCESS_RA2YR=1"
) else (
    rem Проверяем параметры
    if "%~1"=="-RA1" set "PROCESS_RA1=1"
    if "%~1"=="-RA2" set "PROCESS_RA2=1"
    if "%~1"=="-RA2YR" set "PROCESS_RA2YR=1"
    if "%~2"=="-RA1" set "PROCESS_RA1=1"
    if "%~2"=="-RA2" set "PROCESS_RA2=1"
    if "%~2"=="-RA2YR" set "PROCESS_RA2YR=1"
    if "%~3"=="-RA1" set "PROCESS_RA1=1"
    if "%~3"=="-RA2" set "PROCESS_RA2=1"
    if "%~3"=="-RA2YR" set "PROCESS_RA2YR=1"
)

rem Если ни одна игра не выбрана, выводим справку
if !PROCESS_RA1! equ 0 if !PROCESS_RA2! equ 0 if !PROCESS_RA2YR! equ 0 (
    echo Использование: %~n0.bat [-RA1] [-RA2] [-RA2YR]
    echo Если параметры не указаны, обрабатываются все игры.
    pause
    exit /b 0
)

rem Проверка существования необходимых инструментов
if not exist "%NEW_RAD%" (
    echo ОШИБКА: Не найден %NEW_RAD%
    pause
    exit /b 1
)
if not exist "%OLD_MIX%" (
    echo ОШИБКА: Не найден %OLD_MIX%
    pause
    exit /b 1
)

rem Проверка существования исходных папок
if not exist "%MP4_SOURCE%" (
    echo ОШИБКА: Не найдена папка %MP4_SOURCE%
    pause
    exit /b 1
)
if not exist "%SOUND_SOURCE%" (
    echo ОШИБКА: Не найдена папка %SOUND_SOURCE%
    pause
    exit /b 1
)

rem Создаем финальные папки для каждой игры
if !PROCESS_RA1! equ 1 if not exist "%Final_BIK_RA1%" mkdir "%Final_BIK_RA1%"
if !PROCESS_RA2! equ 1 if not exist "%Final_BIK_RA2%" mkdir "%Final_BIK_RA2%"
if !PROCESS_RA2YR! equ 1 if not exist "%Final_BIK_RA2YR%" mkdir "%Final_BIK_RA2YR%"

rem Создаем лог-файл
set "LOGFILE=conversion_log.txt"
echo Начало конвертации: %date% %time% > "%LOGFILE%"
echo Обрабатываемые игры: RA1=!PROCESS_RA1!, RA2=!PROCESS_RA2!, RA2YR=!PROCESS_RA2YR! >> "%LOGFILE%"
echo Проверка инструментов и папок... >> "%LOGFILE%"

rem Создаем структуру папок для RA2
if !PROCESS_RA2! equ 1 (
    for /d %%H in ("%SOUND_SOURCE%\RA2\*") do (
        set "group=%%~nxH"
        for %%R in (600p 720p 768p 900p 1080p) do (
            if not exist "Final_BIK_RA2\!group!\!%%R!\" (
                mkdir "Final_BIK_RA2\!group!\!%%R!\"
                echo Создана папка: Final_BIK_RA2\!group!\!%%R!\ >> "%LOGFILE%"
            )
        )
        if not exist "Final_BIK_RA2\!group!\noformat\" (
            mkdir "Final_BIK_RA2\!group!\noformat\"
            echo Создана папка: Final_BIK_RA2\!group!\noformat\ >> "%LOGFILE%"
        )
    )
)

rem Создаем структуру папок для RA2YR
if !PROCESS_RA2YR! equ 1 (
    for /d %%H in ("%SOUND_SOURCE%\RA2YR\*") do (
        set "group=%%~nxH"
        for %%R in (600p 720p 768p 900p 1080p) do (
            if not exist "Final_BIK_RA2YR\!group!\!%%R!\" (
                mkdir "Final_BIK_RA2YR\!group!\!%%R!\"
                echo Создана папка: Final_BIK_RA2YR\!group!\!%%R!\ >> "%LOGFILE%"
            )
        )
        if not exist "Final_BIK_RA2YR\!group!\noformat\" (
            mkdir "Final_BIK_RA2YR\!group!\noformat\"
            echo Создана папка: Final_BIK_RA2YR\!group!\noformat\ >> "%LOGFILE%"
        )
    )
)

rem Создаем структуру папок для RA1 (HD с разрешениями)
if !PROCESS_RA1! equ 1 (
    for /d %%H in ("%SOUND_SOURCE%\RA1\*") do (
        set "group=%%~nxH"
        for %%R in (600p 720p 768p 900p 1080p) do (
            if not exist "%Final_BIK_RA1%\!group!\!%%R!\" (
                mkdir "%Final_BIK_RA1%\!group!\!%%R!\"
                echo Создана папка: %Final_BIK_RA1%\!group!\!%%R!\ >> "%LOGFILE%"
            )
        )
    )
)

rem Создаем структуру папок для RA1 (noformat)
if !PROCESS_RA1! equ 1 (
    for /d %%H in ("%SOUND_SOURCE%\RA1\*") do (
        set "group=%%~nxH"
        if not exist "%Final_BIK_RA1%\!group!\noformat\" (
            mkdir "%Final_BIK_RA1%\!group!\noformat\"
            echo Создана папка: %Final_BIK_RA1%\!group!\noformat\ >> "%LOGFILE%"
        )
    )
)

rem Обработка RA2
if !PROCESS_RA2! equ 1 (
    echo Обработка игры: RA2 >> "%LOGFILE%"
    echo Обработка игры: RA2
    
    for %%F in ("%MP4_SOURCE%\RA2\*.mp4") do (
        set "filename=%%~nF"
        set "processed=0"
        
        echo. >> "%LOGFILE%"
        echo Обработка файла: !filename!.mp4 >> "%LOGFILE%"
        echo Обработка файла: !filename!.mp4
        
        rem Ищем во всех группах
        for /d %%H in ("%SOUND_SOURCE%\RA2\*") do (
            set "group=%%~nxH"
            if exist "%%H\!filename!.wav" (
                set "processed=1"
                echo Найдена группа: !group! для файла !filename! >> "%LOGFILE%"
                echo Найдена группа: !group! для файла !filename!
                
                rem Конвертируем для каждого разрешения
                for %%R in (600p 720p 768p 900p 1080p) do (
                    set "res=%%R"
                    set "height=!res:p=!"
                    
                    rem Устанавливаем ширину в зависимости от разрешения
                    if "!res!"=="600p" set "width=800"
                    if "!res!"=="720p" set "width=960"
                    if "!res!"=="768p" set "width=1024"
                    if "!res!"=="900p" set "width=1200"
                    if "!res!"=="1080p" set "width=1400"
                    
                    rem Устанавливаем битрейт в зависимости от разрешения (в байтах/сек) для высокого качества
                    if "!res!"=="600p" set "bitrate=400000"
                    if "!res!"=="720p" set "bitrate=600000"
                    if "!res!"=="768p" set "bitrate=700000"
                    if "!res!"=="900p" set "bitrate=900000"
                    if "!res!"=="1080p" set "bitrate=1200000"
                    
                    echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^) >> "%LOGFILE%"
                    echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^)
                    
                    rem Конвертируем видео в BIK без звука
                    "%NEW_RAD%" Binkc "%%F" "Final_BIK_RA2\!group!\!res!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно сконвертирован: !filename! в разрешении !res! >> "%LOGFILE%"
                        
                        rem Добавляем звуковую дорожку из WAV
                        echo Добавление звука к !filename! в разрешении !res! >> "%LOGFILE%"
                        echo Добавление звука к !filename! в разрешении !res!
                        
                        "%NEW_RAD%" BinkMix "Final_BIK_RA2\!group!\!res!\!filename!.bik" "%SOUND_SOURCE%\RA2\!group!\!filename!.wav" "Final_BIK_RA2\!group!\!res!\!filename!.bik" /L0 /O /#
                        
                        if !errorlevel! equ 0 (
                            echo Успешно добавлен звук: !filename! в разрешении !res! >> "%LOGFILE%"
                        ) else (
                            echo ОШИБКА добавления звука: !filename! в разрешении !res! >> "%LOGFILE%"
                            echo ОШИБКА добавления звука: !filename! в разрешении !res!
                        )
                    ) else (
                        echo ОШИБКА конвертации: !filename! в разрешении !res! >> "%LOGFILE%"
                        echo ОШИБКА конвертации: !filename! в разрешении !res!
                    )
                )
            )
        )
        
        if !processed! equ 0 (
            echo Не найдена группа для файла: !filename!.mp4 >> "%LOGFILE%"
            echo Не найдена группа для файла: !filename!.mp4
        )
    )
)

rem Обработка RA2YR
if !PROCESS_RA2YR! equ 1 (
    echo Обработка игры: RA2YR >> "%LOGFILE%"
    echo Обработка игры: RA2YR
    
    for %%F in ("%MP4_SOURCE%\RA2YR\*.mp4") do (
        set "filename=%%~nF"
        set "processed=0"
        
        echo. >> "%LOGFILE%"
        echo Обработка файла: !filename!.mp4 >> "%LOGFILE%"
        echo Обработка файла: !filename!.mp4
        
        rem Ищем во всех группах
        for /d %%H in ("%SOUND_SOURCE%\RA2YR\*") do (
            set "group=%%~nxH"
            if exist "%%H\!filename!.wav" (
                set "processed=1"
                echo Найдена группа: !group! для файла !filename! >> "%LOGFILE%"
                echo Найдена группа: !group! для файла !filename!
                
                rem Конвертируем для каждого разрешения
                for %%R in (600p 720p 768p 900p 1080p) do (
                    set "res=%%R"
                    set "height=!res:p=!"
                    
                    rem Устанавливаем ширину в зависимости от разрешения
                    if "!res!"=="600p" set "width=800"
                    if "!res!"=="720p" set "width=960"
                    if "!res!"=="768p" set "width=1024"
                    if "!res!"=="900p" set "width=1200"
                    if "!res!"=="1080p" set "width=1400"
                    
                    rem Устанавливаем битрейт в зависимости от разрешения (в байтах/сек) для высокого качества
                    if "!res!"=="600p" set "bitrate=400000"
                    if "!res!"=="720p" set "bitrate=600000"
                    if "!res!"=="768p" set "bitrate=700000"
                    if "!res!"=="900p" set "bitrate=900000"
                    if "!res!"=="1080p" set "bitrate=1200000"
                    
                    echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^) >> "%LOGFILE%"
                    echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^)
                    
                    rem Конвертируем видео в BIK без звука
                    "%NEW_RAD%" Binkc "%%F" "Final_BIK_RA2YR\!group!\!res!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно сконвертирован: !filename! в разрешении !res! >> "%LOGFILE%"
                        
                        rem Добавляем звуковую дорожку из WAV
                        echo Добавление звука к !filename! в разрешении !res! >> "%LOGFILE%"
                        echo Добавление звука к !filename! в разрешении !res!
                        
                        "%NEW_RAD%" BinkMix "Final_BIK_RA2YR\!group!\!res!\!filename!.bik" "%SOUND_SOURCE%\RA2YR\!group!\!filename!.wav" "Final_BIK_RA2YR\!group!\!res!\!filename!.bik" /L0 /O /#
                        
                        if !errorlevel! equ 0 (
                            echo Успешно добавлен звук: !filename! в разрешении !res! >> "%LOGFILE%"
                        ) else (
                            echo ОШИБКА добавления звука: !filename! в разрешении !res! >> "%LOGFILE%"
                            echo ОШИБКА добавления звука: !filename! в разрешении !res!
                        )
                    ) else (
                        echo ОШИБКА конвертации: !filename! в разрешении !res! >> "%LOGFILE%"
                        echo ОШИБКА конвертации: !filename! в разрешении !res!
                    )
                )
            )
        )
        
        if !processed! equ 0 (
            echo Не найдена группа для файла: !filename!.mp4 >> "%LOGFILE%"
            echo Не найдена группа для файла: !filename!.mp4
        )
    )
)

rem Обработка RA1
if !PROCESS_RA1! equ 1 (
    echo Обработка игры: RA1 >> "%LOGFILE%"
    echo Обработка игры: RA1

    rem Обработка RA1\HD\noWAV (без звука)
    for %%F in ("%MP4_SOURCE%\RA1\HD\noWAV\*.mp4") do (
        set "filename=%%~nF"
        
        echo. >> "%LOGFILE%"
        echo Обработка файла RA1\HD\noWAV: !filename!.mp4 >> "%LOGFILE%"
        echo Обработка файла RA1\HD\noWAV: !filename!.mp4
        
        rem Конвертируем для каждого разрешения без звука
        for %%R in (600p 720p 768p 900p 1080p) do (
            set "res=%%R"
            set "height=!res:p=!"
            
            rem Устанавливаем ширину в зависимости от разрешения
            if "!res!"=="600p" set "width=1024"
            if "!res!"=="720p" set "width=1280"
            if "!res!"=="768p" set "width=1366"
            if "!res!"=="900p" set "width=1600"
            if "!res!"=="1080p" set "width=1920"
            
            rem Устанавливаем битрейт в зависимости от разрешения (в байтах/сек) для высокого качества
            if "!res!"=="600p" set "bitrate=400000"
            if "!res!"=="720p" set "bitrate=600000"
            if "!res!"=="768p" set "bitrate=700000"
            if "!res!"=="900p" set "bitrate=900000"
            if "!res!"=="1080p" set "bitrate=1200000"
            
            echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^) >> "%LOGFILE%"
            echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^)
            
            rem Конвертируем видео в BIK без звука
            "%NEW_RAD%" Binkc "%%F" "%Final_BIK_RA1%\Original\!res!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
            
            if !errorlevel! equ 0 (
                echo Успешно сконвертирован: !filename! в разрешении !res! >> "%LOGFILE%"
            ) else (
                echo ОШИБКА конвертации: !filename! в разрешении !res! >> "%LOGFILE%"
                echo ОШИБКА конвертации: !filename! в разрешении !res!
            )
        )
    )

    rem Обработка RA1\HD\WAV (со звуком)
    for %%F in ("%MP4_SOURCE%\RA1\HD\WAV\*.mp4") do (
        set "filename=%%~nF"
        set "processed=0"
        
        echo. >> "%LOGFILE%"
        echo Обработка файла RA1\HD\WAV: !filename!.mp4 >> "%LOGFILE%"
        echo Обработка файла RA1\HD\WAV: !filename!.mp4
        
        rem Ищем во всех группах
        for /d %%H in ("%SOUND_SOURCE%\RA1\*") do (
            set "group=%%~nxH"
            if exist "%%H\!filename!.wav" (
                set "processed=1"
                echo Найдена группа: !group! для файла !filename! >> "%LOGFILE%"
                echo Найдена группа: !group! для файла !filename!
                
                rem Конвертируем для каждого разрешения
                for %%R in (600p 720p 768p 900p 1080p) do (
                    set "res=%%R"
                    set "height=!res:p=!"
                    
                    rem Устанавливаем ширину в зависимости от разрешения
                    if "!res!"=="600p" set "width=1024"
                    if "!res!"=="720p" set "width=1280"
                    if "!res!"=="768p" set "width=1366"
                    if "!res!"=="900p" set "width=1600"
                    if "!res!"=="1080p" set "width=1920"
                    
                    rem Устанавливаем битрейт в зависимости от разрешения (в байтах/сек) для высокого качества
                    if "!res!"=="600p" set "bitrate=400000"
                    if "!res!"=="720p" set "bitrate=600000"
                    if "!res!"=="768p" set "bitrate=700000"
                    if "!res!"=="900p" set "bitrate=900000"
                    if "!res!"=="1080p" set "bitrate=1200000"
                    
                    echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^) >> "%LOGFILE%"
                    echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^)
                    
                    rem Конвертируем видео в BIK без звука
                    "%NEW_RAD%" Binkc "%%F" "%Final_BIK_RA1%\!group!\!res!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно сконвертирован: !filename! в разрешении !res! >> "%LOGFILE%"
                        
                        rem Добавляем звуковую дорожку из WAV
                        echo Добавление звука к !filename! в разрешении !res! >> "%LOGFILE%"
                        echo Добавление звука к !filename! в разрешении !res!
                        
                        "%NEW_RAD%" BinkMix "%Final_BIK_RA1%\!group!\!res!\!filename!.bik" "%SOUND_SOURCE%\RA1\!group!\!filename!.wav" "%Final_BIK_RA1%\!group!\!res!\!filename!.bik" /L0 /O /#
                        
                        if !errorlevel! equ 0 (
                            echo Успешно добавлен звук: !filename! в разрешении !res! >> "%LOGFILE%"
                        ) else (
                            echo ОШИБКА добавления звука: !filename! в разрешении !res! >> "%LOGFILE%"
                            echo ОШИБКА добавления звука: !filename! в разрешении !res!
                        )
                    ) else (
                        echo ОШИБКА конвертации: !filename! в разрешении !res! >> "%LOGFILE%"
                        echo ОШИБКА конвертации: !filename! в разрешении !res!
                    )
                )
            )
        )
        
        if !processed! equ 0 (
            echo Не найдена группа для файла: !filename!.mp4 >> "%LOGFILE%"
            echo Не найдена группа для файла: !filename!.mp4
        )
    )

    rem Обработка RA1\noHD (со звуком, одно разрешение)
    for %%F in ("%MP4_SOURCE%\RA1\noHD\*.mp4") do (
        set "filename=%%~nF"
        set "processed=0"
        
        echo. >> "%LOGFILE%"
        echo Обработка файла RA1\noHD: !filename!.mp4 >> "%LOGFILE%"
        echo Обработка файла RA1\noHD: !filename!.mp4
        
        rem Ищем во всех группах
        for /d %%H in ("%SOUND_SOURCE%\RA1\*") do (
            set "group=%%~nxH"
            if exist "%%H\!filename!.wav" (
                set "processed=1"
                echo Найдена группа: !group! для файла !filename! >> "%LOGFILE%"
                echo Найдена группа: !group! для файла !filename!
                
                rem Устанавливаем параметры для noformat
                set "width=1024"
                set "height=564"
                set "bitrate=400000"
                
                echo Конвертация в разрешение: noformat ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^) >> "%LOGFILE%"
                echo Конвертация в разрешение: noformat ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^)
                
                rem Конвертируем видео в BIK без звука
                "%NEW_RAD%" Binkc "%%F" "%Final_BIK_RA1%\!group!\noformat\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                
                if !errorlevel! equ 0 (
                    echo Успешно сконвертирован: !filename! в разрешении noformat >> "%LOGFILE%"
                    
                    rem Добавляем звуковую дорожку из WAV
                    echo Добавление звука к !filename! в разрешении noformat >> "%LOGFILE%"
                    echo Добавление звука к !filename! в разрешении noformat
                    
                    "%NEW_RAD%" BinkMix "%Final_BIK_RA1%\!group!\noformat\!filename!.bik" "%SOUND_SOURCE%\RA1\!group!\!filename!.wav" "%Final_BIK_RA1%\!group!\noformat\!filename!.bik" /L0 /O /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно добавлен звук: !filename! в разрешении noformat >> "%LOGFILE%"
                    ) else (
                        echo ОШИБКА добавления звука: !filename! в разрешении noformat >> "%LOGFILE%"
                        echo ОШИБКА добавления звука: !filename! в разрешении noformat
                    )
                ) else (
                    echo ОШИБКА конвертации: !filename! в разрешении noformat >> "%LOGFILE%"
                    echo ОШИБКА конвертации: !filename! в разрешении noformat
                )
            )
        )
        
        if !processed! equ 0 (
            echo Не найдена группа для файла: !filename!.mp4 >> "%LOGFILE%"
            echo Не найдена группа для файла: !filename!.mp4
        )
    )
)

rem Обработка файлов из Clean_BIK для RA2
if !PROCESS_RA2! equ 1 (
    if exist "%CLEAN_BIK%\RA2\" (
        echo Обработка Clean_BIK для RA2 >> "%LOGFILE%"
        echo Обработка Clean_BIK для RA2
        
        for %%F in ("%CLEAN_BIK%\RA2\*.bik") do (
            set "filename=%%~nF"
            set "processed=0"
            
            echo. >> "%LOGFILE%"
            echo Обработка файла Clean_BIK\RA2: !filename!.bik >> "%LOGFILE%"
            echo Обработка файла Clean_BIK\RA2: !filename!.bik
            
            rem Ищем во всех группах
            for /d %%H in ("%SOUND_SOURCE%\RA2\*") do (
                set "group=%%~nxH"
                if exist "%%H\!filename!.wav" (
                    set "processed=1"
                    echo Найдена группа: !group! для файла !filename! >> "%LOGFILE%"
                    echo Найдена группа: !group! для файла !filename!
                    
                    rem Добавляем звуковую дорожку из WAV
                    echo Добавление звука к !filename! из Clean_BIK >> "%LOGFILE%"
                    echo Добавление звука к !filename! из Clean_BIK
                    
                    "%NEW_RAD%" BinkMix "%%F" "%SOUND_SOURCE%\RA2\!group!\!filename!.wav" "Final_BIK_RA2\!group!\noformat\!filename!.bik" /L0 /O /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно добавлен звук: !filename! >> "%LOGFILE%"
                    ) else (
                        echo ОШИБКА добавления звука: !filename! >> "%LOGFILE%"
                        echo ОШИБКА добавления звука: !filename!
                    )
                )
            )
            
            if !processed! equ 0 (
                echo Не найдена группа для файла: !filename!.bik >> "%LOGFILE%"
                echo Не найдена группа для файла: !filename!.bik
            )
        )
    ) else (
        echo Папка %CLEAN_BIK%\RA2 не существует, пропускаем обработку >> "%LOGFILE%"
    )
)

rem Обработка файлов из Clean_BIK для RA2YR
if !PROCESS_RA2YR! equ 1 (
    if exist "%CLEAN_BIK%\RA2YR\" (
        echo Обработка Clean_BIK для RA2YR >> "%LOGFILE%"
        echo Обработка Clean_BIK для RA2YR
        
        for %%F in ("%CLEAN_BIK%\RA2YR\*.bik") do (
            set "filename=%%~nF"
            set "processed=0"
            
            echo. >> "%LOGFILE%"
            echo Обработка файла Clean_BIK\RA2YR: !filename!.bik >> "%LOGFILE%"
            echo Обработка файла Clean_BIK\RA2YR: !filename!.bik
            
            rem Ищем во всех группах
            for /d %%H in ("%SOUND_SOURCE%\RA2YR\*") do (
                set "group=%%~nxH"
                if exist "%%H\!filename!.wav" (
                    set "processed=1"
                    echo Найдена группа: !group! для файла !filename! >> "%LOGFILE%"
                    echo Найдена группа: !group! для файла !filename!
                    
                    rem Добавляем звуковую дорожку из WAV
                    echo Добавление звука к !filename! из Clean_BIK >> "%LOGFILE%"
                    echo Добавление звука к !filename! из Clean_BIK
                    
                    "%NEW_RAD%" BinkMix "%%F" "%SOUND_SOURCE%\RA2YR\!group!\!filename!.wav" "Final_BIK_RA2YR\!group!\noformat\!filename!.bik" /L0 /O /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно добавлен звук: !filename! >> "%LOGFILE%"
                    ) else (
                        echo ОШИБКА добавления звука: !filename! >> "%LOGFILE%"
                        echo ОШИБКА добавления звука: !filename!
                    )
                )
            )
            
            if !processed! equ 0 (
                echo Не найдена группа для файла: !filename!.bik >> "%LOGFILE%"
                echo Не найдена группа для файла: !filename!.bik
            )
        )
    ) else (
        echo Папка %CLEAN_BIK%\RA2YR не существует, пропускаем обработку >> "%LOGFILE%"
    )
)

echo. >> "%LOGFILE%"
echo Все файлы обработаны! >> "%LOGFILE%"
echo Процесс завершен. Проверьте лог-файл: %LOGFILE%
pause