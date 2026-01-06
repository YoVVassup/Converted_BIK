# Скрипт конвертации BIK-видео для игр Command & Conquer

Этот пакетный файл предназначен для автоматической конвертации видеофайлов из формата MP4 в формат BIK с добавлением звуковых дорожек из WAV-файлов для различных версий игры Command & Conquer.

## Поддерживаемые игры

- **Red Alert 1 (RA1)** - видео с поддержкой HD и стандартного формата
- **Red Alert 2 (RA2)** - видео с поддержкой HD и стандартного формата  
- **Red Alert 2 Yuri's Revenge (RA2YR)** - видео с поддержкой HD и стандартного формата

## Основные скрипты

### 1. Основная конвертация BIK

```bash
Cross_Converted_BIK.bat [-RA1] [-RA2] [-RA2YR]
```

Если параметры не указаны, обрабатываются все игры.   
Примеры:

- ```Cross_Converted_BIK.bat -RA1``` - обработать только Red Alert 1
- ```Cross_Converted_BIK.bat -RA2 -RA2YR``` - обработать Red Alert 2 и Yuri's Revenge

### 2. Упаковка в MIX-файлы для модов (MO/Vision)

```bash
Pack_Mixes_MO_Vision.bat
```

Этот скрипт упаковывает сконвертированные BIK-файлы в MIX-архивы для использования в модификациях на движке RA2/RA2YR (в данном случае MO Vision). 

**Особенности:**

- Для RA1: Original группа разделяется между expandmo11-14, остальные группы используют expandmo13-14
- Для RA2: Все группы упаковываются в expandmo11-12
- Для RA2YR: Все файлы получают суффикс `_yr` и упаковываются в expandmo13-14
- Создает структуру в папке `Build\MOV`

### 3. Упаковка в MIX-файлы для оригинальных игр

```bash
Pack_Mixes_Original.bat <озвучка> <разрешение>
```

Этот скрипт создает MIX-файлы для оригинальных игр RA2 и Yuri's Revenge.

**Особенности:**

- Для RA2 создает `movies01.mix` (файлы на "a" + westlogo.bik) и `movies02.mix` (файлы на "s")
- Для RA2YR создает `movmd03.mix` (все файлы)
- Автоматически добавляет key.ini файлы из папки `Original_MIX_Key`
- Создает структуру в папке `Build\OriginalGames`
- Если имя озвучки содержит пробелы, то его следует заключить в кавычки.

**Примеры использования:**

```bash
Pack_Mixes_Original.bat Original 1080p
Pack_Mixes_Original.bat "Russian project" 720p
```

### 4. Конвертер видео H.265 → H.264

```bash
H265.bat
```

Вспомогательный инструмент для конвертации видео из формата H.265 в H.264 без аудио.

**Особенности:**

- Поддерживает различные видеоформаты: MP4, MKV, MOV, AVI, M4V, TS, WEBM, FLV
- Использует двухпроходное кодирование для высокого качества
- Сохраняет результаты в папку `Converted`
- Поддерживает как абсолютные, так и относительные пути

## Подготовка материалов

Для проверки работы использовал следующие материалы:

### Red Alert 1
- [WAV_Sound_RA1](https://disk.yandex.ru/d/fypGSbfMwDs8uQ)
- [Clean_MP4_RA1](https://disk.yandex.ru/d/jTlcTHwJjgLhWg)

### Red Alert 2 / Yuri's Revenge
- [WAV_Sound_RA2_RA2YR](https://disk.yandex.ru/d/v5S_kkOyPR6YMA) + [WAV_Sound_RA2_RA2YR_Plus](https://disk.yandex.ru/d/YhJb8tHVh_IBbQ)
- [Clean_MP4_RA2_RA2YR](https://disk.yandex.ru/d/2c-p-ID_-__Jog)
- [Clean_BIK_RA2_RA2YR](https://disk.yandex.ru/d/xmjS5EqcHf8PRQ)

## Поддерживаемые озвучки

### Red Alert 1
- Original (English)
- R.G.MVO
- VHS

### Red Alert 2
- Original (English)
- 7wolf
- City [Dyadyushka Risyotch]
- Fargus
- Russian project
- Triada
- XXI Vek [8 Bit]

### Red Alert 2 Yuri's Revenge
- Original (English)
- 7wolf
- City [Dyadyushka Risyotch]
- Fargus
- Triada

**Дополнительные озвучки** (при скачивании WAV_Sound_RA2_RA2YR_Plus):
- RA2: French, German, Korean, Ukrainian
- RA2YR: French, German, Korean, Ukrainian

## Важные замечания

### Производительность
⚠️ **Внимание!** Кодирование происходит за счет CPU и очень сильно его нагружает. На весь процесс из 3 игр уходит около 2 дней (при AMD Ryzen 9 8945HS).

### Форматы видео
- Катсцены RA1 будут преобразованы в формат Bink v1 для использования в модах на движке RA2/RA2YR
- Все видео конвертируются в нескольких разрешениях для поддержки разных конфигураций

## Структура каталогов

Для корректной работы скриптов необходимо иметь следующую структуру каталогов:

```
.
├── Cross_Converted_BIK.bat 		# Основной скрипт конвертации
├── Pack_Mixes_MO_Vision.bat 		# Упаковка для модов
├── Pack_Mixes_Original.bat 		# Упаковка для оригинальных игр
├── H265.bat 						# Конвертер H.265 → H.264
├── Readme.md 						# Эта документация
│
├── Radtools_New/ 					# Новые RAD инструменты
│ 	└── radvideo64.exe
├── Radtools_Old/ 					# Старые RAD инструменты
│ 	└── BinkMix.exe
├── CCMIX/ 							# Инструмент упаковки MIX
│ 	└── ccmix.exe
│
├── Clean_MP4/ 						# Исходные видеофайлы
│ 	├── RA1/
│ 	│ 	├── HD/
│ 	│ 	│ 	├── noWAV/ 				# Видео без звука
│ 	│ 	│ 	└── WAV/ 				# Видео со звуком
│ 	│ 	└── noHD/ 					# Стандартное качество
│ 	├── RA2/
│ 	└── RA2YR/
│
├── WAV_Sound/ 						# Звуковые дорожки
│ 	├── RA1/
│ 	│ 	└── <GroupName>/ 			# Группы озвучек
│ 	├── RA2/
│ 	│ 	└── <GroupName>/
│ 	└── RA2YR/
│ 		└── <GroupName>/
│
├── Clean_BIK/ 						# Оригинальные BIK-файлы
│ 	├── RA2/
│ 	└── RA2YR/
│
├── Final_BIK_RA1/ 					# Результаты конвертации
├── Final_BIK_RA2/
├── Final_BIK_RA2YR/
│
├── Build/ 							# Результаты упаковки
│ 	├── MOV/ 						# Для мода MO Vision
│ 	│ 	├── RA1_Remake/
│ 	│ 	└── RA2_and_RA2YR_Remake/
│ 	└── OriginalGames/ 				# Для оригинальных игр
│ 		├── RA2_Original/
│ 		└── YR_Original/
│
├── Original_MIX_Key/ 				# Key.ini файлы для оригинальных игр
│ 	├── movies01/
│ 	├── movies02/
│ 	└── movmd03/
│
└── Converted/ 						# Результаты H265.bat
```


## Поддерживаемые разрешения

Для каждой игры создаются видео в следующих разрешениях:

- **600p** (800×600 для RA2/RA2YR, 1024×600 для RA1)
- **720p** (960×720 для RA2/RA2YR, 1280×720 для RA1)
- **768p** (1024×768 для RA2/RA2YR, 1366×768 для RA1)
- **900p** (1200×900 для RA2/RA2YR, 1600×900 для RA1)
- **1080p** (1400×1080 для RA2/RA2YR, 1920×1080 для RA1)
- **noformat** (140×110 для RA2/RA2YR, 1024×564 для RA1)

## Принцип работы

### 1. Конвертация (Cross_Converted_BIK.bat)
1. Проверка зависимостей: Проверяет наличие инструментов и исходных каталогов
2. Создание структуры папок: Автоматически создает папки для результатов
3. Обработка видео: Конвертирует MP4 в BIK с разными разрешениями и битрейтами
4. Добавление звука: Смешивает видео с соответствующими WAV-дорожками
5. Логирование: Весь процесс записывается в файл `conversion_log.txt`

### 2. Упаковка для модов (Pack_Mixes_MO_Vision.bat)
1. Обработка RA1: Разделение файлов Original группы и упаковка в разные MIX
2. Обработка RA2: Упаковка всех файлов в expandmo11-12
3. Обработка RA2YR: Добавление суффикса `_yr` и упаковка в expandmo13-14
4. Создание структуры для модификаций

### 3. Упаковка для оригинальных игр (Pack_Mixes_Original.bat)
1. Создание movies01.mix: Файлы на "a" + westlogo.bik + key.ini
2. Создание movies02.mix: Файлы на "s" + key.ini
3. Создание movmd03.mix: Все файлы RA2YR + key.ini
4. Организация по озвучкам и разрешениям

### 4. Конвертация H.265 (H265.bat)
1. Запрос пути к исходным видео
2. Двухпроходное кодирование в H.264
3. Сохранение результатов без аудио
4. Автоматическая очистка временных файлов

## Особенности обработки для разных игр

### Red Alert 1 (RA1)
- HD/noWAV - видео высокого качества без звука
- HD/WAV - видео высокого качества со звуком
- noHD - видео стандартного качества со звуком
- Разделение файлов в папки nolang для совместимости

### Red Alert 2 и Yuri's Revenge
- Обработка MP4-файлов с созданием HD-версий
- Обработка оригинальных BIK-файлов (если доступны)
- Поддержка различных языковых групп
- Автоматическое переименование файлов RA2YR

## Благодарности

* создателям [RADTOOLS](https://www.radgametools.com/)
* создателям [ffmpeg](https://rwijnsma.home.xs4all.nl/files/ffmpeg/) (универсальной модификации под любые windows)
* [DarK600](https://forums.nexusmods.com/profile/41423505-dark600dionis/) (за предоставленные Fullscreen cutscenes - AI-Upscaled - boosted to 30 FPS от RA2YR и RA2)
* Сообществу моддеров Command & Conquer за тестирование и обратную связь
