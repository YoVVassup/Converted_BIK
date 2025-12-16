@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ---------------------------------------
echo Конвертер H.265 to H.264 (без аудио)
echo ---------------------------------------
echo.

rem Определяем текущую директорию (где находится скрипт)
set "SCRIPT_DIR=%~dp0"
rem Убираем завершающий обратный слеш
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo Скрипт расположен в: %SCRIPT_DIR%
echo.

rem Проверяем наличие папки Converted и создаем если нужно
if not exist "%SCRIPT_DIR%\Converted" (
    echo Создаю папку Converted...
    mkdir "%SCRIPT_DIR%\Converted"
    echo Папка Converted создана.
    echo.
)

:SELECT_FOLDER
rem Запрос пути к папке с видеофайлами
set "source_folder="
set /p "source_folder=Введите путь к папке с видеофайлами: "

rem Убираем кавычки если они есть
set "source_folder=!source_folder:"=!"

rem Если путь пустой, используем текущую директорию скрипта
if "!source_folder!"=="" (
    set "source_folder=!SCRIPT_DIR!"
    echo Использую текущую директорию скрипта.
    echo.
)

rem Преобразуем относительный путь в абсолютный
if not "!source_folder:~0,1!"=="\" (
    if not "!source_folder:~1,1!"==":" (
        rem Это относительный путь - преобразуем его в абсолютный относительно директории скрипта
        set "source_folder=!SCRIPT_DIR!\!source_folder!"
    )
)

rem Проверка существования папки
if not exist "!source_folder!\" (
    echo.
    echo Ошибка: Папка "!source_folder!" не существует!
    echo.
    goto SELECT_FOLDER
)

rem Получаем абсолютный путь к выбранной папке
for %%I in ("!source_folder!") do set "source_folder_abs=%%~fI"

echo.
echo Папка для конвертации: !source_folder_abs!
echo.

rem Переходим в выбранную папку
pushd "!source_folder_abs!" 2>nul
if errorlevel 1 (
    echo.
    echo Ошибка: Не удается перейти в указанную папку!
    echo.
    popd
    goto SELECT_FOLDER
)

echo Начинаю обработку файлов...
echo.

rem Счетчик обработанных файлов
set file_count=0

rem Обрабатываем все поддерживаемые видеофайлы
for %%i in (*.mp4 *.mkv *.mov *.avi *.m4v *.ts *.webm *.flv) do (
    echo Обработка [!file_count!]: %%~nxi
    
    rem Генерируем уникальное имя для логов
    set "logname=%%~ni_!RANDOM!!RANDOM!"
    
    rem Первый проход
    ffmpeg -y -i "%%i" -c:v libx264 -b:v 15862k -maxrate 15862k -minrate 15862k -bufsize 15862k -preset slow -an -pass 1 -passlogfile "!logname!" -f mp4 NUL 2>nul
    
    rem Второй проход
    ffmpeg -y -i "%%i" -c:v libx264 -b:v 15862k -maxrate 15862k -minrate 15862k -bufsize 15862k -preset slow -an -pass 2 -passlogfile "!logname!" -movflags +faststart "%SCRIPT_DIR%\Converted\%%~ni.mp4" 2>nul
    
    rem Удаляем временные файлы
    if exist "!logname!-0.log" del "!logname!-0.log"
    if exist "!logname!-0.log.mbtree" del "!logname!-0.log.mbtree"
    
    set /a file_count+=1
    echo Готово: %%~ni.mp4
    echo.
)

rem Возвращаемся в исходную директорию
popd

echo ---------------------------------------
if !file_count! equ 0 (
    echo Файлы для обработки не найдены.
) else (
    echo Обработано файлов: !file_count!
    echo Результаты сохранены в: "%SCRIPT_DIR%\Converted"
)
echo ---------------------------------------
echo.
pause