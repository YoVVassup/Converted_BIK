# 🎮 Конвейер конвертации BIK-видео для Command & Conquer

[🇬🇧 English](Readme.md) | [🇷🇺 Русский](Readme_ru.md)

![License](https://img.shields.io/badge/license-GPLv3-blue)
![Platform](https://img.shields.io/badge/platform-Windows_10+-green)
![Status](https://img.shields.io/badge/status-stable-brightgreen)

[![RAD Tools](https://img.shields.io/badge/RAD_Game_Tools-Bink_1.0-orange)](https://www.radgametools.com/)
[![FFmpeg](https://img.shields.io/badge/FFmpeg-7.x-purple)](https://ffmpeg.org/)
[![Batch](https://img.shields.io/badge/Language-Windows_Batch-grey)](#)

Автоматический пайплайн конвертации MP4 → BIK с микшированием WAV и упаковкой в MIX-архивы для серии Command & Conquer.

## 🎯 Поддерживаемые игры

| Игра | Формат |
|------|--------|
| **Red Alert 1** 🔴 | HD + стандартный |
| **Red Alert 2** 🟡 | HD + стандартный |
| **RA2: Yuri's Revenge** 🟣 | HD + стандартный |

## 📥 Исходные файлы

Скачайте исходные MP4 видео, BIK файлы и WAV звуковые дорожки. **Обязательны** для работы `Cross_Converted_BIK.bat`.

| Игра | Ссылка | Содержимое |
|------|--------|------------|
| 🔴 Red Alert 1 | [Яндекс.Диск](https://disk.yandex.com/d/byR2zVm0uniB0Q) | MP4 + WAV |
| 🟡 Red Alert 2 | [Яндекс.Диск](https://disk.yandex.com/d/Swf4monQvkhA8w) | MP4 + BIK + WAV |
| 🟣 RA2: Yuri's Revenge | [Яндекс.Диск](https://disk.yandex.com/d/8YOQIZcHQ74NMw) | MP4 + BIK + WAV |

## 🛠️ Инструменты

| Инструмент | Назначение |
|------------|-----------|
| 🎬 `radvideo64.exe` | Кодирование MP4 → BIK (Bink 1.0) |
| 🎵 `BinkMix.exe` | Микширование WAV → BIK |
| 📦 `ccmix.exe` | Упаковка MIX-архивов |
| 🎞️ `ffmpeg.exe` | H.265→H.264, MP3→WAV |
| 🎮 `binkplay.exe` | Плеер предпросмотра BIK |
| 🔧 `CMDParse.exe` | Универсальный парсер аргументов |

## 📜 Скрипты

### 🔄 Основная конвертация

```batch
Cross_Converted_BIK.bat [флаги]
```

| Флаг | Описание |
|------|----------|
| 🎯 `-GAME:RA1` / `-GAME:RA2` / `-GAME:RA2YR` | Фильтр по игре (несколько флагов для нескольких игр) |
| 👥 `-GROUP:имя` / `-G:имя` | Фильтр по группе озвучки (несколько флагов для нескольких групп) |
| 📐 `-RES:600p` | Фильтр по разрешению (несколько флагов для нескольких разрешений) |
| 📐+ `-RES:600p+` | Включить noformat |
| ⏭️ `-INCREMENTAL` | Пропустить конвертированные |
| 🔄 `-RETRY` | Повтор ошибочных файлов |
| 👁️ `-DRY_RUN` | Режим проверки |

**Примеры:**
```batch
Cross_Converted_BIK.bat -GAME:RA2
Cross_Converted_BIK.bat -GAME:RA2 -GAME:RA2YR
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -GROUP:7wolf
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -RES:600p -RES:720p
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -RES:600p+
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:"City [Dyadyushka Risyotch]"
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -RES:600p -INCREMENTAL
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -RES:600p -DRY_RUN
Cross_Converted_BIK.bat
```

### 📦 Упаковка MIX для MO Vision

```batch
Pack_Mixes_MO_Vision.bat [-GROUP:имя] [-GAME:игра]
```

| Флаг | Описание |
|------|----------|
| 👥 `-GROUP:имя` | Упаковать конкретную группу |
| 🎯 `-GAME:игра` | Упаковать конкретную игру |

**Примеры:**
```batch
Pack_Mixes_MO_Vision.bat
Pack_Mixes_MO_Vision.bat -GROUP:Original
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:7wolf
Pack_Mixes_MO_Vision.bat -GAME:RA2YR
```

### 📦 Упаковка MIX для оригинальных игр

```batch
Pack_Mixes_Original.bat [-GROUP:имя] [-RES:разрешение]
```

Без параметров — обрабатывает **Original** с **600p**.

**Примеры:**
```batch
Pack_Mixes_Original.bat
Pack_Mixes_Original.bat -GROUP:Original -RES:1080p
Pack_Mixes_Original.bat -GROUP:"Russian project" -RES:720p
Pack_Mixes_Original.bat -GROUP:7wolf -RES:600pyr
```

### 🎞️ Конвертер H.265 → H.264

```batch
H265.bat
```

Интерактивный инструмент. Запрашивает путь к папке с видео. Конвертирует H.265 в H.264 без аудио. Поддерживает MP4, MKV, MOV, AVI, M4V, TS, WEBM, FLV.

### 🎵 Конвертер MP3 → WAV

```batch
MP3_to_WAV.bat [-OVERWRITE] [-DRY_RUN]
```

| Флаг | Описание |
|------|----------|
| 🔄 `-OVERWRITE` | Перезаписать существующие WAV |
| 👁️ `-DRY_RUN` | Режим проверки |

**Примеры:**
```batch
MP3_to_WAV.bat
MP3_to_WAV.bat -DRY_RUN
MP3_to_WAV.bat -OVERWRITE
```

### 👁️ Превью BIK

```batch
Preview.bat
```

Интерактивный инструмент. Пошаговое меню:
1. Выбор игры (RA1/RA2/RA2YR)
2. Выбор MP4 файла
3. Выбор разрешения
4. Выбор группы озвучки (или без звука)
5. Просмотр в `binkplay.exe`

### 🔍 MIX-Diff

```batch
MIX_Diff.bat
```

Интерактивный инструмент сравнения. Три режима:
1. Сравнение двух директорий с BIK
2. Сравнение двух MIX-файлов
3. Сравнение MIX-файла с директорией

### 📐 Конвертер разрешений

```batch
Resolution_Convert.bat
```

Интерактивный инструмент. Три режима:
1. Конвертация одного BIK в новое разрешение
2. Пакетная конвертация всех BIK в папке
3. Конвертация MP4 в BIK с нестандартным разрешением

### ✅ Тест пайплайна

```batch
test.bat
```

6 проверок:
1. Инструменты (radvideo64, BinkMix, ccmix)
2. Папки (Clean_MP4, WAV_Sound)
3. Конвертация MP4 → BIK
4. BinkMix.exe
5. Валидация nolang конфига
6. DRY_RUN режим

### 🔒 Валидация MIX

```batch
Validate_MIX.bat
```

Интерактивная валидация. Выбор источника:
1. `Build\MOV` (архивы MO Vision)
2. `Build\OriginalGames` (архивы оригинальных игр)
3. Произвольный путь

Проверяет каждый MIX-файл: размер > 0, минимальный размер заголовка, ccmix --verify.

## 🔧 CMDParse — Парсер аргументов

`CMDParse.exe` — универсальный парсер аргументов, используемый всеми батниками.

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
| 🎯 `-RA1`, `-RA2`, `-RA2YR` | Флаги игр |
| 🔗 `-GAME:RA2,RA2YR` | Список игр через запятую |
| 👥 `-GROUP:Original,7wolf` | Список групп через запятую |
| 📐 `-RES:600p,720p+` | Список разрешений через запятую |
| 🔄 `-DRY_RUN`, `-INCREMENTAL`, `-RETRY`, `-OVERWRITE` | Флаги режимов |
| 📂 `-SOURCE:путь`, `-OUTPUT:путь` | Параметры путей |
| ❓ `--help` | Показать справку |

| Утилита | Описание |
|---------|----------|
| `--list-groups` | Вывести доступные группы озвучки |
| `--list-files` | Вывести доступные MP4/BIK файлы |
| `--verify` | Проверить что все BIK созданы для всех разрешений |
| `--cleanup` | Удалить пустые BIK файлы |
| `--stats` | Показать статистику по файлам |

Дефолты загружаются из `cmdparse.ini`.

## ⚙️ Конфигурация

### 📄 config.ini

Все скрипты используют `config_loader.bat` с `config.ini`:

```ini
[paths]
radtools_new=third-party\Radtools_New\radvideo64.exe
radtools_old=third-party\Radtools_Old\BinkMix.exe
ccmix=third-party\CCMIX\ccmix.exe
ffmpeg=third-party\ffmpeg.exe

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

[nolang]
files_hd=ALLIESMAP_01 ALLIESMAP_02 ...
files_noformat=AFTRMATH AIRFIELD ...
```

### 📄 cmdparse.ini

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

## 📐 Поддерживаемые разрешения

| Разрешение | RA2/RA2YR | RA1 | Битрейт |
|------------|-----------|-----|---------|
| `600p` | 800x600 | 1024x600 | 400 kbps |
| `720p` | 960x720 | 1280x720 | 600 kbps |
| `768p` | 1024x768 | 1366x768 | 700 kbps |
| `900p` | 1200x900 | 1600x900 | 900 kbps |
| `1080p` | 1400x1080 | 1920x1080 | 1150 kbps |
| `600pyr` | 800x600 | — | 1100 kbps только RA2YR |
| `noformat` | — | 1024x564 | 400 kbps только RA1 |

## 👥 Поддерживаемые группы озвучки

### 🔴 Red Alert 1
`Original` · `R.G.MVO` · `VHS`

### 🟡 Red Alert 2
`Original` · `7wolf` · `City [Dyadyushka Risyotch]` · `Fargus` · `Russian project` · `Triada` · `XXI Vek [8 Bit]`
`French` · `German` · `Korean` · `Ukrainian` · `Thai` · `Turkish`

### 🟣 RA2: Yuri's Revenge
`Original` · `7wolf` · `City [Dyadyushka Risyotch]` · `Fargus` · `Triada`
`French` · `German` · `Korean` · `Ukrainian` · `Thai` · `Turkish`

## ⚠️ Важные замечания

- **🖥️ Платформа**: Windows 10+ (только cmd.exe)
- **⏱️ Конвертация**: ~3-10 мин на MP4 файл
- **💾 Лимит MIX**: Макс 2ГБ на MIX-файл (x86)
- **👻 Скрытые окна**: radvideo64 и BinkMix работают в фоне (без всплывающих окон)
- **🔄 Инкрементальный**: `-INCREMENTAL` пропускает конвертированные
- **🔁 Повтор**: Ошибочные файлы → `failed.txt`, `-RETRY`
- **👁️ Проверка**: `-DRY_RUN` без реальной конвертации
- **📝 Логирование**: Таймстампы `[HH:MM:SS]` в логе, ETA в консоли

## 📁 Структура каталогов

```
.
├── Cross_Converted_BIK.bat
├── Pack_Mixes_MO_Vision.bat
├── Pack_Mixes_Original.bat
├── H265.bat
├── MP3_to_WAV.bat
├── Preview.bat
├── MIX_Diff.bat
├── Resolution_Convert.bat
├── test.bat
├── Validate_MIX.bat
├── config.ini
├── config_loader.bat
├── cmdparse.ini
├── Readme.md
│
├── third-party/
│   ├── CMDParse/       CMDParse.exe + исходники
│   ├── CCMIX/          ccmix.exe
│   ├── Radtools_New/   radvideo64.exe, binkplay.exe
│   ├── Radtools_Old/   BinkMix.exe
│   ├── Original_MIX_Key/  Ключи шифрования MIX
│   └── ffmpeg.exe
│
├── Clean_MP4/          Исходные MP4 видео
├── WAV_Sound/          WAV звуковые дорожки
├── Clean_BIK/          Оригинальные BIK файлы
│
├── Final_BIK_RA1/      Результаты RA1
├── Final_BIK_RA2/      Результаты RA2
├── Final_BIK_RA2YR/    Результаты RA2YR
│
├── Build/
│   ├── MOV/            Архивы MO Vision
│   └── OriginalGames/  Архивы оригинальных игр
│
└── Converted/          Результаты H265.bat
```

## 🙏 Благодарности

- [RAD Game Tools](https://www.radgametools.com/) — кодек и микшер Bink
- [FFmpeg](https://oss.netfarm.it/mplayer/) — обработка видео/аудио
- [DarK600](https://forums.nexusmods.com/profile/41423505-dark600dionis/) — AI-апскейл катсцен
- Сообщество моддеров C&C
