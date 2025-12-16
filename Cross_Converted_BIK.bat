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

rem Исправленная проверка - используем вложенные IF
if !PROCESS_RA1! equ 0 (
    if !PROCESS_RA2! equ 0 (
        if !PROCESS_RA2YR! equ 0 (
            echo Использование: %~n0.bat [-RA1] [-RA2] [-RA2YR]
            echo Если параметры не указаны, обрабатываются все игры.
            pause
            exit /b 0
        )
    )
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
                
                rem Создаем папку группы, если ее еще нет
                set "group_folder=Final_BIK_RA2\!group!"
                if not exist "!group_folder!\" (
                    mkdir "!group_folder!"
                    echo Создана папка группы: !group_folder! >> "%LOGFILE%"
                )
                
                rem Создаем папку noformat, если ее еще нет
                set "noformat_folder=!group_folder!\noformat"
                if not exist "!noformat_folder!\" (
                    mkdir "!noformat_folder!"
                    echo Создана папка noformat: !noformat_folder! >> "%LOGFILE%"
                )
                
                rem Конвертируем для каждого разрешения
                for %%R in (600p 720p 768p 900p 1080p) do (
                    set "res=%%R"
                    set "height=!res:p=!"
                    
                    rem Создаем папку разрешения, если ее еще нет
                    set "res_folder=!group_folder!\!res!"
                    if not exist "!res_folder!\" (
                        mkdir "!res_folder!"
                        echo Создана папка разрешения: !res_folder! >> "%LOGFILE%"
                    )
                    
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
                    "%NEW_RAD%" Binkc "%%F" "!res_folder!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно сконвертирован: !filename! в разрешении !res! >> "%LOGFILE%"
                        
                        rem Добавляем звуковую дорожку из WAV
                        echo Добавление звука к !filename! в разрешении !res! >> "%LOGFILE%"
                        echo Добавление звука к !filename! в разрешении !res!
                        
                        "%OLD_MIX%" "!res_folder!\!filename!.bik" "%SOUND_SOURCE%\RA2\!group!\!filename!.wav" "!res_folder!\!filename!.bik" /L0 /O /#
                        
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
                
                rem Создаем папку группы, если ее еще нет
                set "group_folder=Final_BIK_RA2YR\!group!"
                if not exist "!group_folder!\" (
                    mkdir "!group_folder!"
                    echo Создана папка группы: !group_folder! >> "%LOGFILE%"
                )
                
                rem Создаем папку noformat, если ее еще нет
                set "noformat_folder=!group_folder!\noformat"
                if not exist "!noformat_folder!\" (
                    mkdir "!noformat_folder!"
                    echo Создана папка noformat: !noformat_folder! >> "%LOGFILE%"
                )
                
                rem Конвертируем для каждого разрешения
                for %%R in (600p 720p 768p 900p 1080p) do (
                    set "res=%%R"
                    set "height=!res:p=!"
                    
                    rem Создаем папку разрешения, если ее еще нет
                    set "res_folder=!group_folder!\!res!"
                    if not exist "!res_folder!\" (
                        mkdir "!res_folder!"
                        echo Создана папка разрешения: !res_folder! >> "%LOGFILE%"
                    )
                    
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
                    "%NEW_RAD%" Binkc "%%F" "!res_folder!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно сконвертирован: !filename! в разрешении !res! >> "%LOGFILE%"
                        
                        rem Добавляем звуковую дорожку из WAV
                        echo Добавление звука к !filename! в разрешении !res! >> "%LOGFILE%"
                        echo Добавление звука к !filename! в разрешении !res!
                        
                        "%OLD_MIX%" "!res_folder!\!filename!.bik" "%SOUND_SOURCE%\RA2YR\!group!\!filename!.wav" "!res_folder!\!filename!.bik" /L0 /O /#
                        
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

    rem Создаем списки файлов для nolang
    set "NOLANG_FILES_HD=ALLIESMAP_01 ALLIESMAP_02 ALLIESMAP_03 ALLIESMAP_04 ALLIESMAP_05 ALLIESMAP_06 ALLIESMAP_07 ALLIESMAP_08 ALLIESMAP_09 ALLIESMAP_10 ALLIESMAP_11 ALLIESMAP_12 ALLIESMAP_13 ALLIESMAP_14 RA_CREDITS REDINTRO RETALIATION_INTRO RETALIATION_WINA RETALIATION_WINS SOVIETMAP_01 SOVIETMAP_02 SOVIETMAP_03 SOVIETMAP_04 SOVIETMAP_05 SOVIETMAP_06 SOVIETMAP_07 SOVIETMAP_08 SOVIETMAP_09 SOVIETMAP_10 SOVIETMAP_11 SOVIETMAP_12 SOVIETMAP_13 SOVIETMAP_14"
    set "NOLANG_FILES_NOFORMAT=AFTRMATH AIRFIELD ALLYMORF ANTEND ANTINTRO APCESCPE ASSESS BATTLE BEACHEAD BINOC BMAP BOMBRUN BRDGTILT CRONFAIL CRONTEST DESTROYR DOUBLE DPTHCHRG DUD ELEVATOR EXECUTE FLARE FROZEN GRVESTNE LANDING MASASSLT MCV MCV_LAND MCVBRDGE MIG MONTPASS MOVINGIN MTNKFACT NUKESTOK OILDRUM ONTHPRWL PERISCOP RADRRAID SEARCH SFROZEN SHIPSINK SHORBOM1 SHORBOM2 SHORBOMB SITDUCK SLNTSRVC SNOWBASE SNOWBOMB SNSTRAFE SOVBATL SOVCEMET SOVMCV SOVTSTAR SPOTTER SPY STRAFE TAKE_OFF TESLA TOOFAR TRINITY V2ROCKET AAGUN"

    rem Обработка RA1\HD\noWAV (без звука)
    for %%F in ("%MP4_SOURCE%\RA1\HD\noWAV\*.mp4") do (
        set "filename=%%~nF"
        
        echo. >> "%LOGFILE%"
        echo Обработка файла RA1\HD\noWAV: !filename!.mp4 >> "%LOGFILE%"
        echo Обработка файла RA1\HD\noWAV: !filename!.mp4
        
        rem Создаем папку Original, если ее еще нет
        set "original_folder=%Final_BIK_RA1%\Original"
        if not exist "!original_folder!\" (
            mkdir "!original_folder!"
            echo Создана папка: !original_folder! >> "%LOGFILE%"
        )
        
        rem Конвертируем для каждого разрешения без звука
        for %%R in (600p 720p 768p 900p 1080p) do (
            set "res=%%R"
            set "height=!res:p=!"
            
            rem Создаем папку разрешения, если ее еще нет
            set "res_folder=!original_folder!\!res!"
            if not exist "!res_folder!\" (
                mkdir "!res_folder!"
                echo Создана папка: !res_folder! >> "%LOGFILE%"
            )
            
            rem Создаем папку nolang для файлов из первого списка
            set "nolang_folder=!res_folder!\nolang"
            if not exist "!nolang_folder!\" (
                mkdir "!nolang_folder!"
                echo Создана папка nolang: !nolang_folder! >> "%LOGFILE%"
            )
            
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
            
            rem Проверяем, нужно ли поместить файл в папку nolang
            set "in_nolang_list=0"
            for %%I in (!NOLANG_FILES_HD!) do (
                if "!filename!"=="%%I" set "in_nolang_list=1"
            )
            
            if !in_nolang_list! equ 1 (
                rem Конвертируем в папку nolang
                set "output_folder=!nolang_folder!"
                echo Файл !filename! будет помещен в папку nolang >> "%LOGFILE%"
            ) else (
                rem Конвертируем в обычную папку разрешения
                set "output_folder=!res_folder!"
            )
            
            echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^) >> "%LOGFILE%"
            echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^)
            
            rem Конвертируем видео в BIK без звука
            "%NEW_RAD%" Binkc "%%F" "!output_folder!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
            
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
                
                rem Создаем папку группы, если ее еще нет
                set "group_folder=%Final_BIK_RA1%\!group!"
                if not exist "!group_folder!\" (
                    mkdir "!group_folder!"
                    echo Создана папка группы: !group_folder! >> "%LOGFILE%"
                )
                
                rem Создаем папку noformat, если ее еще нет
                set "noformat_folder=!group_folder!\noformat"
                if not exist "!noformat_folder!\" (
                    mkdir "!noformat_folder!"
                    echo Создана папка noformat: !noformat_folder! >> "%LOGFILE%"
                )
                
                rem Если группа Original, создаем папку nolang в noformat для второго списка файлов
                if "!group!"=="Original" (
                    set "noformat_nolang_folder=!noformat_folder!\nolang"
                    if not exist "!noformat_nolang_folder!\" (
                        mkdir "!noformat_nolang_folder!"
                        echo Создана папка noformat\nolang: !noformat_nolang_folder! >> "%LOGFILE%"
                    )
                )
                
                rem Конвертируем для каждого разрешения
                for %%R in (600p 720p 768p 900p 1080p) do (
                    set "res=%%R"
                    set "height=!res:p=!"
                    
                    rem Создаем папку разрешения, если ее еще нет
                    set "res_folder=!group_folder!\!res!"
                    if not exist "!res_folder!\" (
                        mkdir "!res_folder!"
                        echo Создана папка разрешения: !res_folder! >> "%LOGFILE%"
                    )
                    
                    rem Если группа Original, создаем папку nolang для первого списка файлов
                    if "!group!"=="Original" (
                        set "res_nolang_folder=!res_folder!\nolang"
                        if not exist "!res_nolang_folder!\" (
                            mkdir "!res_nolang_folder!"
                            echo Создана папка разрешения\nolang: !res_nolang_folder! >> "%LOGFILE%"
                        )
                    )
                    
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
                    
                    rem Определяем, куда конвертировать
                    if "!group!"=="Original" (
                        rem Проверяем, входит ли файл в первый список
                        set "in_nolang_list1=0"
                        for %%I in (!NOLANG_FILES_HD!) do (
                            if "!filename!"=="%%I" set "in_nolang_list1=1"
                        )
                        
                        if !in_nolang_list1! equ 1 (
                            rem Конвертируем в папку nolang
                            set "output_folder=!res_nolang_folder!"
                            echo Файл !filename! будет помещен в папку nolang >> "%LOGFILE%"
                        ) else (
                            rem Конвертируем в обычную папку разрешения
                            set "output_folder=!res_folder!"
                        )
                    ) else (
                        rem Для других групп всегда конвертируем в обычную папку разрешения
                        set "output_folder=!res_folder!"
                    )
                    
                    echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^) >> "%LOGFILE%"
                    echo Конвертация в разрешение: !res! ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^)
                    
                    rem Конвертируем видео в BIK без звука
                    "%NEW_RAD%" Binkc "%%F" "!output_folder!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                    
                    if !errorlevel! equ 0 (
                        echo Успешно сконвертирован: !filename! в разрешении !res! >> "%LOGFILE%"
                        
                        rem Добавляем звуковую дорожку из WAV
                        echo Добавление звука к !filename! в разрешении !res! >> "%LOGFILE%"
                        echo Добавление звука к !filename! в разрешении !res!
                        
                        "%OLD_MIX%" "!output_folder!\!filename!.bik" "%SOUND_SOURCE%\RA1\!group!\!filename!.wav" "!output_folder!\!filename!.bik" /L0 /O /#
                        
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
                
                rem Создаем папку группы, если ее еще нет
                set "group_folder=%Final_BIK_RA1%\!group!"
                if not exist "!group_folder!\" (
                    mkdir "!group_folder!"
                    echo Создана папка группы: !group_folder! >> "%LOGFILE%"
                )
                
                rem Создаем папку noformat, если ее еще нет
                set "noformat_folder=!group_folder!\noformat"
                if not exist "!noformat_folder!\" (
                    mkdir "!noformat_folder!"
                    echo Создана папка noformat: !noformat_folder! >> "%LOGFILE%"
                )
                
                rem Только для группы Original создаем папку nolang внутри noformat для второго списка файлов
                if "!group!"=="Original" (
                    set "noformat_nolang_folder=!noformat_folder!\nolang"
                    if not exist "!noformat_nolang_folder!\" (
                        mkdir "!noformat_nolang_folder!"
                        echo Создана папка noformat\nolang: !noformat_nolang_folder! >> "%LOGFILE%"
                    )
                )
                
                rem Устанавливаем параметры для noformat
                set "width=1024"
                set "height=564"
                set "bitrate=400000"
                
                rem Определяем, куда конвертировать
                if "!group!"=="Original" (
                    rem Проверяем, входит ли файл во второй список
                    set "in_nolang_list2=0"
                    for %%I in (!NOLANG_FILES_NOFORMAT!) do (
                        if "!filename!"=="%%I" set "in_nolang_list2=1"
                    )
                    
                    if !in_nolang_list2! equ 1 (
                        rem Конвертируем в папку nolang
                        set "output_folder=!noformat_nolang_folder!"
                        echo Файл !filename! будет помещен в папку nolang >> "%LOGFILE%"
                    ) else (
                        rem Конвертируем в обычную папку noformat
                        set "output_folder=!noformat_folder!"
                    )
                ) else (
                    rem Для других групп всегда конвертируем в обычную папку noformat
                    set "output_folder=!noformat_folder!"
                )
                
                echo Конвертация в разрешение: noformat ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^) >> "%LOGFILE%"
                echo Конвертация в разрешение: noformat ^(ширина: !width!, высота: !height!, битрейт: !bitrate!^)
                
                rem Конвертируем видео в BIK без звука
                "%NEW_RAD%" Binkc "%%F" "!output_folder!\!filename!.bik" /N-1 /^(!width! /^)!height! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                
                if !errorlevel! equ 0 (
                    echo Успешно сконвертирован: !filename! в разрешении noformat >> "%LOGFILE%"
                    
                    rem Добавляем звуковую дорожку из WAV
                    echo Добавление звука к !filename! в разрешении noformat >> "%LOGFILE%"
                    echo Добавление звука к !filename! в разрешении noformat
                    
                    "%OLD_MIX%" "!output_folder!\!filename!.bik" "%SOUND_SOURCE%\RA1\!group!\!filename!.wav" "!output_folder!\!filename!.bik" /L0 /O /#
                    
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
                    
                    rem Создаем папку группы, если ее еще нет
                    set "group_folder=Final_BIK_RA2\!group!"
                    if not exist "!group_folder!\" (
                        mkdir "!group_folder!"
                        echo Создана папка группы: !group_folder! >> "%LOGFILE%"
                    )
                    
                    rem Создаем папку noformat, если ее еще нет
                    set "noformat_folder=!group_folder!\noformat"
                    if not exist "!noformat_folder!\" (
                        mkdir "!noformat_folder!"
                        echo Создана папка noformat: !noformat_folder! >> "%LOGFILE%"
                    )
                    
                    rem Добавляем звуковую дорожку из WAV
                    echo Добавление звука к !filename! из Clean_BIK >> "%LOGFILE%"
                    echo Добавление звука к !filename! из Clean_BIK
                    
                    "%OLD_MIX%" "%%F" "%SOUND_SOURCE%\RA2\!group!\!filename!.wav" "!noformat_folder!\!filename!.bik" /L0 /O /#
                    
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
                    echo Найдена группа: !group! для файла !filename!"
                    
                    rem Создаем папку группы, если ее еще нет
                    set "group_folder=Final_BIK_RA2YR\!group!"
                    if not exist "!group_folder!\" (
                        mkdir "!group_folder!"
                        echo Создана папка группы: !group_folder! >> "%LOGFILE%"
                    )
                    
                    rem Создаем папку noformat, если ее еще нет
                    set "noformat_folder=!group_folder!\noformat"
                    if not exist "!noformat_folder!\" (
                        mkdir "!noformat_folder!"
                        echo Создана папка noformat: !noformat_folder! >> "%LOGFILE%"
                    )
                    
                    rem Добавляем звуковую дорожку из WAV
                    echo Добавление звука к !filename! из Clean_BIK >> "%LOGFILE%"
                    echo Добавление звука к !filename! из Clean_BIK
                    
                    "%OLD_MIX%" "%%F" "%SOUND_SOURCE%\RA2YR\!group!\!filename!.wav" "!noformat_folder!\!filename!.bik" /L0 /O /#
                    
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