@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem Установка путей к инструментам
set "NEW_RAD=Radtools_New\radvideo64.exe"
set "OLD_MIX=Radtools_Old\BinkMix.exe"
set "FFMPEG=ffmpeg.exe"

rem Основные папки
set "MP4_SOURCE=Clean"
set "SOUND_SOURCE=Original_BIK_Sound"
set "FINAL_BIK=Final_BIK"
set "TEMP_MP4=Temp_MP4_Files"

rem Проверяем наличие параметра -h264
set "CONVERT_H264=0"
if "%~1"=="-h264" set "CONVERT_H264=1"

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
if not exist "%FFMPEG%" (
    echo ОШИБКА: Не найден %FFMPEG%
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

rem Создаем временную папку для конвертированных MP4-файлов
if not exist "%TEMP_MP4%" mkdir "%TEMP_MP4%"

rem Создаем лог-файл
set "LOGFILE=conversion_log.txt"
echo Начало конвертации: %date% %time% > "%LOGFILE%"
echo Проверка инструментов и папок... >> "%LOGFILE%"

rem Конвертируем все MP4 из H.265 в H.264 с помощью FFmpeg (только если указан параметр -h264)
if %CONVERT_H264% equ 1 (
    echo Конвертация H.265 в H.264... >> "%LOGFILE%"
    for %%F in ("%MP4_SOURCE%\*.mp4") do (
        set "filename=%%~nF"
        echo Конвертация !filename!.mp4 из H.265 в H.264... >> "%LOGFILE%"
        echo Конвертация !filename!.mp4 из H.265 в H.264...
        
        rem Конвертируем видео в H.264, аудио в AAC
        "%FFMPEG%" -i "%%F" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "%TEMP_MP4%\!filename!.mp4" -y
        if !errorlevel! neq 0 (
            echo ОШИБКА FFmpeg для файла !filename! >> "%LOGFILE%"
            echo ОШИБКА FFmpeg для файла !filename!
        ) else (
            echo Успешно сконвертирован: !filename! >> "%LOGFILE%"
        )
    )
) else (
    echo Пропущена конвертация H.265 in H.264. Используются существующие файлы в %TEMP_MP4%. >> "%LOGFILE%"
)

rem Создаем структуру папок для конечных результатов
for /d %%G in ("%SOUND_SOURCE%\*") do (
    set "group=%%~nxG"
    for %%R in (600p 720p 768p 900p 1080p) do (
        if not exist "%FINAL_BIK%\!group!\!%%R!\" (
            mkdir "%FINAL_BIK%\!group!\!%%R!\"
            echo Создана папка: %FINAL_BIK%\!group!\!%%R!\ >> "%LOGFILE%"
        )
    )
)

rem Проходим по всем MP4-файлам в TEMP_MP4
for %%F in ("%TEMP_MP4%\*.mp4") do (
    set "filename=%%~nF"
    set "group_found=0"
    
    echo. >> "%LOGFILE%"
    echo Обработка файла: !filename!.mp4 >> "%LOGFILE%"
    echo Обработка файла: !filename!.mp4
    
    rem Определяем группу по имени файла
    for /d %%G in ("%SOUND_SOURCE%\*") do (
        set "group=%%~nxG"
        if exist "%%G\!filename!.bik" (
            set "group_found=1"
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
                
                rem Устанавливаем битрейт в зависимости от разрешения
                if "!res!"=="600p" set "bitrate=400000"
                if "!res!"=="720p" set "bitrate=550000"
                if "!res!"=="768p" set "bitrate=600000"
                if "!res!"=="900p" set "bitrate=750000"
                if "!res!"=="1080p" set "bitrate=950000"
                
                echo Конвертация в разрешение: !res! ^(ширина: !width!, битрейт: !bitrate!^) >> "%LOGFILE%"
                echo Конвертация в разрешение: !res! ^(ширина: !width!, битрейт: !bitrate!^)
                
                rem Конвертируем видео в BIK без звука
                "%NEW_RAD%" Binkc "%%F" "%FINAL_BIK%\!group!\!res!\!filename!.bik" /N-1 /^)!height! /^(!width! /v100 /:0 /D!bitrate! /L0 /O /Z0 /#
                
                if !errorlevel! equ 0 (
                    echo Успешно сконвертирован: !filename! в разрешении !res! >> "%LOGFILE%"
                    
                    rem Добавляем звуковую дорожку из оригинала
                    echo Добавление звука к !filename! в разрешении !res! >> "%LOGFILE%"
                    echo Добавление звука к !filename! в разрешении !res!
                    
                    "%OLD_MIX%" "%FINAL_BIK%\!group!\!res!\!filename!.bik" "%SOUND_SOURCE%\!group!\!filename!.bik" "%FINAL_BIK%\!group!\!res!\!filename!.bik" /L0 /O /#
                    
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
    
    if !group_found! equ 0 (
        echo Не найдена группа для файла: !filename!.mp4 >> "%LOGFILE%"
        echo Не найдена группа для файла: !filename!.mp4
    )
)

echo. >> "%LOGFILE%"
echo Все файлы обработаны! >> "%LOGFILE%"
echo Процесс завершен. Проверьте лог-файл: %LOGFILE%
pause