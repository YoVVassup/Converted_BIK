# Конвейер конвертации BIK-видео для Command & Conquer

[English](Readme.md) | [Russian](Readme_ru.md)

![License](https://img.shields.io/badge/license-GPLv3-blue)
![Platform](https://img.shields.io/badge/platform-Windows_10+-green)
![Status](https://img.shields.io/badge/status-stable-brightgreen)

[![RAD Tools](https://img.shields.io/badge/RAD_Game_Tools-Bink_1.0-orange)](https://www.radgametools.com/)
[![FFmpeg](https://img.shields.io/badge/FFmpeg-7.x-purple)](https://ffmpeg.org/)
[![Batch](https://img.shields.io/badge/Language-Windows_Batch-grey)](#)
[![Tests](https://img.shields.io/badge/Tests-30_%D1%81%D1%83%D1%82%D0%B5%D0%B1%D0%BE%D0%B2-brightgreen)](TEST/)

Автоматический пайплайн конвертации MP4 -> BIK с микшированием WAV и упаковкой в MIX-архивы для серии Command & Conquer.

## Поддерживаемые игры

| Игра | Формат |
|------|--------|
| **Red Alert 1** | HD + стандартный |
| **Red Alert 2** | HD + стандартный |
| **RA2: Yuri's Revenge** | HD + стандартный |

## Исходные файлы

Скачайте исходные MP4 видео, BIK файлы и WAV звуковые дорожки. **Обязательны** для работы `Cross_Converted_BIK.bat`.

| Игра | Ссылка | Содержимое |
|------|--------|------------|
| Red Alert 1 | [Яндекс.Диск](https://disk.yandex.com/d/byR2zVm0uniB0Q) | MP4 + WAV |
| Red Alert 2 | [Яндекс.Диск](https://disk.yandex.com/d/Swf4monQvkhA8w) | MP4 + BIK + WAV |
| RA2: Yuri's Revenge | [Яндекс.Диск](https://disk.yandex.com/d/8YOQIZcHQ74NMw) | MP4 + BIK + WAV |

## Инструменты

| Инструмент | Назначение |
|------------|-----------|
| `radvideo64.exe` | Кодирование MP4 -> BIK (Bink 1.0) |
| `BinkMix.exe` | Микширование WAV -> BIK |
| `ccmix.exe` | Упаковка MIX-архивов |
| `ffmpeg.exe` | H.265->H.264, MP3->WAV |
| `binkplay.exe` | Плеер предпросмотра BIK |
| `CMDParse.exe` | Универсальный парсер аргументов |

## Скрипты

### Основная конвертация

```batch
Cross_Converted_BIK.bat [флаги]
```

Основной пайплайн. Конвертирует MP4 видео в BIK на нескольких разрешениях (600p/720p/768p/900p/1080p), затем микширует WAV звуковые дорожки. Поддерживает RA1, RA2 и RA2YR.

| Флаг | Описание |
|------|----------|
| `-GAME:RA1` / `-GAME:RA2` / `-GAME:RA2YR` | Фильтр по игре |
| `-GAME:RA2,RA2YR` | Несколько игр (через запятую) |
| `-GROUP:имя` / `-G:имя` | Фильтр по группе озвучки |
| `-GROUP:Original,7wolf` | Несколько групп (через запятую) |
| `-RES:600p` | Фильтр по разрешению |
| `-RES:600p,720p` | Несколько разрешений (через запятую) |
| `-RES:600p+` | Включить noformat |
| `-INCREMENTAL` | Пропустить конвертированные |
| `-RETRY` | Повтор ошибочных файлов |
| `-DRY_RUN` | Режим проверки |

**Примеры:**
```batch
Cross_Converted_BIK.bat -GAME:RA2
Cross_Converted_BIK.bat -GAME:RA2,RA2YR
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original,7wolf
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -RES:600p,720p
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -RES:600p+
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:"City [Dyadyushka Risyotch]"
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -RES:600p -INCREMENTAL
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -RES:600p -DRY_RUN
Cross_Converted_BIK.bat
```

### Упаковка MIX для MO Vision

```batch
Pack_Mixes_MO_Vision.bat [-GROUP:имя] [-GAME:игра]
```

Упаковывает сконвертированные BIK файлы в MIX-архивы для ремейка MO Vision. Обрабатывает RA1, RA2 и RA2YR отдельно. Для RA2YR добавляет суффикс `_yr` к именам файлов перед упаковкой (файлы уже заканчивающиеся на `_yr` не дублируются). Включает валидацию лимита размера MIX-файла (2 ГБ).

**Разбиение MIX для RA2:** Файлы RA2 разбиваются по первому символу на два MIX-архива:
- `expandmo11_*.mix` — Союзные видео (имена начинающиеся на `a`) + `westlogo.bik` (логотип RA2, всегда в первом MIX) + `key.ini`
- `expandmo12_*.mix` — Советские видео (имена начинающиеся на `s`) + `key.ini`

| Флаг | Описание |
|------|----------|
| `-GROUP:имя` | Упаковать конкретную группу |
| `-GROUP:Original,7wolf` | Несколько групп (через запятую) |
| `-GAME:игра` | Упаковать конкретную игру |
| `-GAME:RA2,RA2YR` | Несколько игр (через запятую) |
| `-DRY_RUN` | Режим проверки (без упаковки) |
| `-INCREMENTAL` | Пропустить уже упакованные файлы |
| `-RETRY` | Повторить ранее ошибочные файлы |

**Примеры:**
```batch
Pack_Mixes_MO_Vision.bat
Pack_Mixes_MO_Vision.bat -GROUP:Original
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:7wolf
Pack_Mixes_MO_Vision.bat -GAME:RA2YR
Pack_Mixes_MO_Vision.bat -GAME:RA2,RA2YR -GROUP:Original,7wolf
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:Original -DRY_RUN
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:Original -INCREMENTAL
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:Original -RETRY
```

### Упаковка MIX для оригинальных игр

```batch
Pack_Mixes_Original.bat [-GROUP:имя] [-RES:разрешение]
```

Упаковывает BIK файлы в MIX-архивы для оригинальных RA2 и RA2YR. Без параметров -- обрабатывает группу **Original** с разрешением **600p**. RA2YR всегда использует **600pyr** независимо от `-RES:`.

| Флаг | Описание |
|------|----------|
| `-GROUP:имя` | Группа озвучки |
| `-GROUP:Original,7wolf` | Несколько групп (через запятую) |
| `-RES:разрешение` | Целевое разрешение |
| `-DRY_RUN` | Режим проверки (без упаковки) |
| `-INCREMENTAL` | Пропустить уже упакованные файлы |
| `-RETRY` | Повторить ранее ошибочные файлы |

**Примеры:**
```batch
Pack_Mixes_Original.bat
Pack_Mixes_Original.bat -GROUP:Original -RES:1080p
Pack_Mixes_Original.bat -GROUP:"Russian project" -RES:720p
Pack_Mixes_Original.bat -GROUP:7wolf -RES:600pyr
Pack_Mixes_Original.bat -GROUP:Original,7wolf -RES:600p
Pack_Mixes_Original.bat -GROUP:Original -RES:600p -DRY_RUN
Pack_Mixes_Original.bat -GROUP:Original -RES:600p -INCREMENTAL
Pack_Mixes_Original.bat -GROUP:Original -RES:600p -RETRY
```

### Конвертер H.265 -> H.264

```batch
H265.bat [-SOURCE:путь] [-OUTPUT:путь] [-DRY_RUN]
```

Конвертирует H.265 в H.264 без звука с 2-проходным кодированием. Интерактивный при запуске без флагов. Неинтерактивный CLI:
- `-SOURCE:путь` -- Папка с H.265 видео
- `-OUTPUT:путь` -- Папка для H.264 файлов
- `-DRY_RUN` -- Режим проверки (без конвертации)

Поддерживает MP4, MKV, MOV, AVI, M4V, TS, WEBM, FLV.

**Примеры CLI:**
```batch
H265.bat -SOURCE:C:\Videos\H265 -OUTPUT:C:\Videos\H264
H265.bat -SOURCE:Clean_MP4 -OUTPUT:Converted
H265.bat -SOURCE:C:\Videos\H265 -OUTPUT:C:\Videos\H264 -DRY_RUN
```

### Конвертер MP3 -> WAV

```batch
MP3_to_WAV.bat [-OVERWRITE] [-DRY_RUN]
```

Конвертирует MP3 аудио файлы в WAV (16-bit PCM, 44100 Гц, стерео). Рекурсивно сканирует `WAV_Sound/`. Пропускает существующие WAV по умолчанию. Всегда запрашивает путь к MP3 (даже с флагами).

| Флаг | Описание |
|------|----------|
| `-OVERWRITE` | Перезаписать существующие WAV |
| `-DRY_RUN` | Режим проверки |

**Примеры:**
```batch
MP3_to_WAV.bat
MP3_to_WAV.bat -DRY_RUN
MP3_to_WAV.bat -OVERWRITE
```

### Превью BIK

```batch
Preview.bat [-GAME:игра] [-GROUP:группа] [-RES:разрешение] [-FILE:путь]
```

Интерактивный инструмент при запуске без флагов. Неинтерактивный CLI:
- `-GAME:игра` -- Игра (RA1/RA2/RA2YR)
- `-GROUP:группа` -- Группа озвучки
- `-RES:разрешение` -- Разрешение
- `-FILE:путь` -- BIK файл для просмотра

Интерактивное пошаговое меню:
1. Выбор игры (RA1/RA2/RA2YR)
2. Выбор MP4 файла
3. Выбор разрешения
4. Выбор группы озвучки (или без звука)
5. Просмотр в `binkplay.exe`

### MIX-Diff

```batch
MIX_Diff.bat [-PATH1:путь] [-PATH2:путь]
```

Инструмент сравнения. Интерактивное меню при запуске без флагов. Неинтерактивный CLI:
- `-PATH1:путь` -- Первая директория или MIX-файл для сравнения
- `-PATH2:путь` -- Вторая директория или MIX-файл для сравнения

Три режима:
1. Сравнение двух директорий с BIK
2. Сравнение двух MIX-файлов
3. Сравнение MIX-файла с директорией (только интерактивно)

Выводит количество идентичных/добавленных/удалённых/изменённых файлов. Сохраняет полный отчёт во временный файл.

**Примеры CLI:**
```batch
MIX_Diff.bat -PATH1:C:\dir1 -PATH2:C:\dir2
MIX_Diff.bat -PATH1:file1.mix -PATH2:file2.mix
```

### Конвертер разрешений

```batch
Resolution_Convert.bat [-INPUT:файл] [-RES:ШИРИНАxВЫСОТА] [-BITRATE:биты/с] [-DRY_RUN]
```

Интерактивный инструмент при запуске без флагов. Неинтерактивный CLI:
- `-INPUT:файл` -- Исходный BIK или MP4 файл
- `-RES:ШИРИНАxВЫСОТА` -- Целевое разрешение (например, 1280x720)
- `-BITRATE:биты/с` -- Целевой битрейт в битах/с
- `-DRY_RUN` -- Режим проверки (без конвертации)

Три режима:
1. Конвертация одного BIK в новое разрешение
2. Пакетная конвертация всех BIK в папке
3. Конвертация MP4 в BIK с нестандартным разрешением

**Пример CLI:**
```batch
Resolution_Convert.bat -INPUT:input.bik -RES:1280x720 -BITRATE:600000
Resolution_Convert.bat -INPUT:input.bik -RES:1920x1080 -BITRATE:1150000 -DRY_RUN
Resolution_Convert.bat -INPUT:video.mp4 -RES:1280x720 -BITRATE:600000
```

### Валидация MIX

```batch
Validate_MIX.bat [-SCAN_DIR:путь]
```

Валидирует MIX-файлы. Интерактивное меню при запуске без флагов. Неинтерактивный CLI:
- `-SCAN_DIR:путь` -- Директория с MIX-файлами для валидации

Интерактивный режим. Выбор источника:
1. `Build\MOV` (архивы MO Vision)
2. `Build\OriginalGames` (архивы оригинальных игр)
3. Произвольный путь

Проверяет каждый MIX-файл: размер > 0, минимальный размер заголовка, ccmix --verify.

**Примеры CLI:**
```batch
Validate_MIX.bat -SCAN_DIR:Build\MOV
Validate_MIX.bat -SCAN_DIR:Build\OriginalGames
```

### Рабочие сценарии

Реальные примеры комбинирования флагов и скриптов:

**Полный пайплайн: конвертация всех игр, затем упаковка**
```batch
REM Шаг 1: Конвертация всех игр в 600p
Cross_Converted_BIK.bat -RES:600p
REM Шаг 2: Упаковка для MO Vision
Pack_Mixes_MO_Vision.bat
REM Шаг 3: Упаковка для оригинальных игр
Pack_Mixes_Original.bat -RES:600pyr
REM Шаг 4: Валидация всего
Validate_MIX.bat -SCAN_DIR:Build
```

**Инкрементальная пересборка: добавили новые файлы, конвертируем только недостающие**
```batch
REM Первый запуск конвертирует всё
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original
REM Позже, после добавления новых MP4, пропускаем уже конвертированные
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -INCREMENTAL
```

**Отладка: предпросмотр перед конвертацией, повтор ошибочных**
```batch
REM Проверка какие файлы будут обработаны
Cross_Converted_BIK.bat -GAME:RA2,RA2YR -GROUP:Original,7wolf -DRY_RUN
REM Запуск реальной конвертации
Cross_Converted_BIK.bat -GAME:RA2,RA2YR -GROUP:Original,7wolf
REM Если часть файлов упала, повторяем только их
Cross_Converted_BIK.bat -GAME:RA2,RA2YR -GROUP:Original,7wolf -RETRY
```

**Выборочная упаковка: одна группа, одна игра, сначала просмотр**
```batch
REM Предпросмотр упаковки для группы 7wolf в RA2
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:7wolf -DRY_RUN
REM Реальная упаковка
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:7wolf
```

**Сравнение старой и новой сборки**
```batch
REM Сравнение двух MIX-архивов
MIX_Diff.bat -PATH1:Build\MOV\Original\expandmo11_600p.mix -PATH2:Build\MOV\Original\expandmo11_720p.mix
REM Сравнение содержимого MIX с исходной директорией
MIX_Diff.bat -PATH1:Build\MOV\Original\expandmo11_600p.mix -PATH2:Final_BIK_RA2\Original\600p
```

**Пакетная конвертация H.265 footage в H.264 для монтажа**
```batch
REM Конвертация всех H.265 видео в папке в H.264
H265.bat -SOURCE:D:\Footage\H265_raw -OUTPUT:D:\Footage\H264_editable
```

**Конвертация MP3 саундтрека в WAV для микширования BIK**
```batch
REM Предпросмотр конвертации
MP3_to_WAV.bat -DRY_RUN
REM Конвертация, пропуская существующие WAV
MP3_to_WAV.bat
REM Принудительная переконвертация всех
MP3_to_WAV.bat -OVERWRITE
```

**Нестандартное разрешение для конкретного BIK файла**
```batch
REM Конвертация одного BIK в 1280x720 при 600 kbps
Resolution_Convert.bat -INPUT:Final_BIK_RA2\Original\600p\briefing.bik -RES:1280x720 -BITRATE:600000
REM Предпросмотр без конвертации
Resolution_Convert.bat -INPUT:Final_BIK_RA2\Original\600p\briefing.bik -RES:1920x1080 -BITRATE:1150000 -DRY_RUN
```

**Пересборка одного разрешения для всех групп**
```batch
REM Конвертация только 720p для RA2, все группы
Cross_Converted_BIK.bat -GAME:RA2 -RES:720p
REM Упаковка только 720p для MO Vision
Pack_Mixes_MO_Vision.bat -GAME:RA2
```

**Валидация конкретной директории после сборки**
```batch
REM Проверка всех MIX-файлов в сборке MO Vision
Validate_MIX.bat -SCAN_DIR:Build\MOV
REM Проверка конкретной папки группы
Validate_MIX.bat -SCAN_DIR:Build\MOV\Original
```

### Тестовый набор

```batch
TEST\test_all.bat
```

Запускает 30 автоматизированных тестовых наборов:

| Набор | Скрипт | Описание |
|-------|--------|----------|
| 1 | test_cmdparse.bat | Парсер аргументов: все режимы, фильтры, дефолты |
| 2 | test_config_loader.bat | Загрузка конфига, дефолты путей, доступность переменных |
| 3 | test_filters.bat | Логика findstr, точки с запятой, отклонение подстрок |
| 4 | test_pack_mo.bat | Парсинг FILTER_GAME/GROUP, защита от затенения переменных |
| 5 | test_pack_original.bat | Парсинг AUDIO_GROUP, дефолты, разбиение |
| 6 | test_cross.bat | Флаги игр, RESOLUTION_FILTER findstr, дефолты |
| 7 | test_cli.bat | CLI флаги для MIX_Diff, Validate_MIX, H265, Resolution_Convert |
| 8 | test_log_rotation.bat | Автоматическая ротация при лог > 1MB, пороги размера |
| 9 | test_resolution_convert.bat | Логика конвертации разрешений |
| 10 | test_mp3_to_wav.bat | Конвертация MP3 в WAV |
| 11 | test_preview.bat | Рабочий процесс предпросмотра |
| 12 | test_cli_improved.bat | Улучшенная обработка CLI флагов |
| 13 | test_dry_run_incremental.bat | Режимы DRY_RUN, INCREMENTAL, RETRY |
| 14 | test_validate_mix.bat | Валидация MIX |
| 15 | test_h265.bat | Конвертация H265 |
| 16 | test_mp3_to_wav_full.bat | MP3 в WAV полное покрытие |
| 17 | test_resolution_convert_full.bat | Конвертация разрешений полное покрытие |
| 18 | test_cross_full.bat | Кросс-конвертация полное покрытие |
| 19 | test_preview_full.bat | Предпросмотр полное покрытие |
| 20 | test_pack_mo_full.bat | Упаковка MO Vision полное покрытие |
| 21 | test_pack_original_full.bat | Упаковка оригинальных игр полное покрытие |
| 22 | test_mix_diff_full.bat | MIX diff полное покрытие |
| 23 | test_config_loader_full.bat | Загрузка конфига полное покрытие |
| 24 | test_config_loader_edge.bat | Граничные случаи загрузки конфига |
| 25 | test_cross_errors.bat | Кросс-конвертация пути ошибок + статистика |
| 26 | test_mp3_edge.bat | Граничные случаи MP3 в WAV |
| 27 | test_h265_edge.bat | Граничные случаи H265 |
| 28 | test_preview_edge.bat | Валидация предпросмотра |
| 29 | test_validate_mix_edge.bat + test_mix_diff_edge.bat + test_pack_edge.bat | Граничные случаи валидации, diff, упаковки |
| 30 | test_resolution_convert_edge.bat | Пути ошибок конвертации разрешений |

**Пример:**
```batch
TEST\test_all.bat
```

## CMDParse -- Парсер аргументов

`CMDParse.exe` -- универсальный парсер аргументов, используемый всеми батниками.

```batch
CMDParse.exe [флаги]
```

| Режим | Описание |
|-------|----------|
| `--mode:cross` | Cross_Converted_BIK (по умолчанию) |
| `--mode:pack_mo` | Pack_Mixes_MO_Vision |
| `--mode:pack_original` | Pack_Mixes_Original |
| `--mode:mp3_to_wav` | MP3_to_WAV |
| `--mode:h265` | H265.bat |
| `--mode:preview` | Preview.bat |
| `--mode:validate` | Validate_MIX.bat |
| `--mode:resolution` | Resolution_Convert.bat |
| `--mode:mix_diff` | MIX_Diff.bat |

| Флаг | Описание |
|------|----------|
| `-RA1`, `-RA2`, `-RA2YR` | Флаги игр |
| `-GAME:RA2,RA2YR` | Список игр через запятую |
| `-GROUP:Original,7wolf` | Список групп через запятую |
| `-RES:600p,720p+` | Список разрешений через запятую |
| `-DRY_RUN`, `-INCREMENTAL`, `-RETRY`, `-OVERWRITE` | Флаги режимов |
| `-SOURCE:путь`, `-OUTPUT:путь` | Параметры путей |
| `--help` | Показать справку |

| Утилита | Описание |
|---------|----------|
| `--list-groups` | Вывести доступные группы озвучки |
| `--list-files` | Вывести доступные MP4/BIK файлы |
| `--verify` | Проверить что все BIK созданы для всех разрешений |
| `--cleanup` | Удалить пустые BIK файлы |
| `--stats` | Показать статистику по файлам |

Дефолты загружаются из `cmdparse.ini`.

Для режимов `--mode:pack_mo` и `--mode:pack_original` `CMDParse.exe` выводит флаги `DRY_RUN`, `INCREMENTAL` и `RETRY`, которые управляют поведением упаковки (режим проверки, пропуск существующих, повтор ошибочных).

## Конфигурация

### config.ini

Все скрипты используют `config_loader.bat` с `config.ini`:

```ini
[paths]
radtools_new=third-party\Radtools_New\radvideo64.exe
radtools_old=third-party\Radtools_Old\BinkMix.exe
ccmix=third-party\CCMIX\ccmix.exe
ffmpeg=third-party\ffmpeg.exe
binkplay=third-party\Radtools_New\binkplay.exe

[folders]
mp4_source=Clean_MP4
sound_source=WAV_Sound
clean_bik=Clean_BIK
final_ra1=Final_BIK_RA1
final_ra2=Final_BIK_RA2
final_ra2yr=Final_BIK_RA2YR
build_root=Build

[config]
log_file=conversion_log.txt
failed_file=failed.txt
hide_window=true

[nolang]
files_hd=ALLIESMAP_01 ALLIESMAP_02 ...
files_noformat=AFTRMATH AIRFIELD ...
```

### cmdparse.ini

Дефолты CMDParse (CLI аргументы перезаписывают):

```ini
[defaults]
mode=cross
games=RA1,RA2,RA2YR
groups=
resolutions=
dry_run=false
incremental=false
retry=false
overwrite=false
```

## Поддерживаемые разрешения

| Разрешение | RA2/RA2YR | RA1 | Битрейт |
|------------|-----------|-----|---------|
| `600p` | 800x600 | 1024x600 | 400 kbps |
| `720p` | 960x720 | 1280x720 | 600 kbps |
| `768p` | 1024x768 | 1366x768 | 700 kbps |
| `900p` | 1200x900 | 1600x900 | 900 kbps |
| `1080p` | 1400x1080 | 1920x1080 | 1150 kbps |
| `600pyr` | 800x600 | -- | 1100 kbps только RA2YR |
| `noformat` | -- | 1024x564 | 400 kbps только RA1 |

## Поддерживаемые группы озвучки

### Red Alert 1
`Original` `French` `German` `Ourmark` `Paradox` `R.G.MVO` `RusPerevod` `Ukrainian` `Vector` `VHS` `XXI Vek [GLS-21V]`

### Red Alert 2
`Original` `7wolf` `City [Dyadyushka Risyotch]` `Fargus` `French` `German` `Korean` `Russian project` `Thai` `Triada` `Turkish` `Ukrainian` `XXI Vek [8 Bit]`

### RA2: Yuri's Revenge
`Original` `7wolf` `City [Dyadyushka Risyotch]` `Fargus` `French` `German` `Korean` `Thai` `Triada` `Turkish` `Ukrainian`

## Важные замечания

- **Платформа**: Windows 10+ (только cmd.exe)
- **Конвертация**: ~3-10 мин на MP4 файл
- **Лимит MIX**: Макс 2 ГБ на MIX-файл (x86)
- **Скрытые окна**: radvideo64 и BinkMix работают в фоне через `run_hidden.vbs` (настраивается через `hide_window=true/false` в config.ini)
- **Инкрементальный**: `-INCREMENTAL` пропускает конвертированные
- **Повтор**: Ошибочные файлы -> `failed.txt`, `-RETRY`
- **Проверка**: `-DRY_RUN` без реальной конвертации
- **Логирование**: Таймстампы `[HH:MM:SS]` в логе, ETA в консоли
- **Ротация логов**: Автоматическая ротация при превышении 1MB (`conversion_log.txt` -> `conversion_log_ГГГГММДД_ЧЧММСС.log`)
- **CRLF**: Все батники используют Windows CRLF окончания строк
- **Кодировка**: `chcp 65001` для UTF-8 вывода консоли в основных скриптах

## Структура каталогов

```
.
|-- Cross_Converted_BIK.bat
|-- Pack_Mixes_MO_Vision.bat
|-- Pack_Mixes_Original.bat
|-- H265.bat
|-- MP3_to_WAV.bat
|-- Preview.bat
|-- MIX_Diff.bat
|-- Resolution_Convert.bat
|-- Validate_MIX.bat
|-- config.ini
|-- config_loader.bat
|-- cmdparse.ini
|-- Readme.md
|-- Readme_ru.md
|-- LICENSE
|
|-- third-party/
|   |-- CMDParse/         CMDParse.exe + исходники
|   |-- CCMIX/            ccmix.exe
|   |-- Radtools_New/     radvideo64.exe, binkplay.exe
|   |-- Radtools_Old/     BinkMix.exe
|   |-- Original_MIX_Key/ Ключи шифрования MIX
|   +-- ffmpeg.exe
|
|-- Clean_MP4/            Исходные MP4 видео
|-- WAV_Sound/            WAV звуковые дорожки
|-- Clean_BIK/            Оригинальные BIK файлы
|
|-- Final_BIK_RA1/        Результаты RA1
|-- Final_BIK_RA2/        Результаты RA2
|-- Final_BIK_RA2YR/      Результаты RA2YR
|
|-- Build/
|   |-- MOV/              Архивы MO Vision
|   +-- OriginalGames/    Архивы оригинальных игр
|
|-- Converted/            Результаты H265.bat
|
+-- TEST/
    |-- test_all.bat              Тест-раннер (30 наборов)
    |-- test_cmdparse.bat
    |-- test_config_loader.bat
    |-- test_config_loader_full.bat
    |-- test_config_loader_edge.bat
    |-- test_cross.bat
    |-- test_cross_full.bat
    |-- test_cross_errors.bat
    |-- test_filters.bat
    |-- test_pack_mo.bat
    |-- test_pack_mo_full.bat
    |-- test_pack_original.bat
    |-- test_pack_original_full.bat
    |-- test_pack_edge.bat
    |-- test_cli.bat
    |-- test_cli_improved.bat
    |-- test_log_rotation.bat
    |-- test_dry_run_incremental.bat
    |-- test_h265.bat
    |-- test_h265_edge.bat
    |-- test_mp3_to_wav.bat
    |-- test_mp3_to_wav_full.bat
    |-- test_mp3_edge.bat
    |-- test_resolution_convert.bat
    |-- test_resolution_convert_full.bat
    |-- test_resolution_convert_edge.bat
    |-- test_preview.bat
    |-- test_preview_full.bat
    |-- test_preview_edge.bat
    |-- test_validate_mix.bat
    |-- test_validate_mix_edge.bat
    |-- test_mix_diff_full.bat
    |-- test_mix_diff_edge.bat
    |-- create_mix.bat
    |-- create_mix.ps1
    +-- vmix_rel_test/
```

## Благодарности

- [RAD Game Tools](https://www.radgametools.com/) -- кодек и микшер Bink
- [FFmpeg](https://oss.netfarm.it/mplayer/) -- обработка видео/аудио
- [DarK600](https://forums.nexusmods.com/profile/41423505-dark600dionis/) -- AI-апскейл катсцен
- Сообщество моддеров C&C
