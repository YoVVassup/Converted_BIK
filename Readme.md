# BIK Video Conversion Pipeline for Command & Conquer

[English](Readme.md) | [Russian](Readme_ru.md)

![License](https://img.shields.io/badge/license-GPLv3-blue)
![Platform](https://img.shields.io/badge/platform-Windows_10+-green)
![Status](https://img.shields.io/badge/status-stable-brightgreen)

[![RAD Tools](https://img.shields.io/badge/RAD_Game_Tools-Bink_1.0-orange)](https://www.radgametools.com/)
[![FFmpeg](https://img.shields.io/badge/FFmpeg-7.x-purple)](https://ffmpeg.org/)
[![Batch](https://img.shields.io/badge/Language-Windows_Batch-grey)](#)
[![Tests](https://img.shields.io/badge/Tests-118_passing-brightgreen)](TEST/)

Automated MP4 -> BIK conversion pipeline with WAV audio mixing and MIX archive packaging for the Command & Conquer franchise.

## Supported Games

| Game | Format |
|------|--------|
| **Red Alert 1** | HD + Standard |
| **Red Alert 2** | HD + Standard |
| **RA2: Yuri's Revenge** | HD + Standard |

## Source Files

Download source MP4 videos, BIK files, and WAV audio tracks. **Required** for `Cross_Converted_BIK.bat` to work.

| Game | Link | Contents |
|------|------|----------|
| Red Alert 1 | [Yandex.Disk](https://disk.yandex.com/d/byR2zVm0uniB0Q) | MP4 + WAV |
| Red Alert 2 | [Yandex.Disk](https://disk.yandex.com/d/Swf4monQvkhA8w) | MP4 + BIK + WAV |
| RA2: Yuri's Revenge | [Yandex.Disk](https://disk.yandex.com/d/8YOQIZcHQ74NMw) | MP4 + BIK + WAV |

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| `radvideo64.exe` | MP4 -> BIK encoding (Bink 1.0) |
| `BinkMix.exe` | WAV -> BIK audio mixing |
| `ccmix.exe` | MIX archive packing |
| `ffmpeg.exe` | H.265->H.264, MP3->WAV |
| `binkplay.exe` | BIK preview player |
| `CMDParse.exe` | Universal argument parser |

## Scripts

### Core Conversion

```batch
Cross_Converted_BIK.bat [flags]
```

Main production pipeline. Converts MP4 video files to BIK format at multiple resolutions (600p/720p/768p/900p/1080p), then mixes in WAV audio tracks. Supports RA1, RA2, and RA2YR games.

| Flag | Description |
|------|-------------|
| `-GAME:RA1` / `-GAME:RA2` / `-GAME:RA2YR` | Filter by game |
| `-GAME:RA2,RA2YR` | Multiple games (comma-separated) |
| `-GROUP:name` / `-G:name` | Filter by voice group |
| `-GROUP:Original,7wolf` | Multiple groups (comma-separated) |
| `-RES:600p` | Filter by resolution |
| `-RES:600p,720p` | Multiple resolutions (comma-separated) |
| `-RES:600p+` | Include noformat |
| `-INCREMENTAL` | Skip converted files |
| `-RETRY` | Retry failed files |
| `-DRY_RUN` | Preview mode |

**Examples:**
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

### MO Vision MIX Packaging

```batch
Pack_Mixes_MO_Vision.bat [-GROUP:name] [-GAME:name]
```

Packs converted BIK files into MIX archives for the MO Vision remake. Handles RA1, RA2, and RA2YR separately. For RA2YR, appends `_yr` suffix to filenames before packing (files already ending in `_yr` are not double-suffixed). Includes 2GB MIX file size validation.

**RA2 MIX splitting:** RA2 files are split by first character into two MIX archives:
- `expandmo11_*.mix` — Allied videos (filenames starting with `a`) + `westlogo.bik` (RA2 logo, always packed into first MIX) + `key.ini`
- `expandmo12_*.mix` — Soviet videos (filenames starting with `s`) + `key.ini`

| Flag | Description |
|------|-------------|
| `-GROUP:name` | Pack specific voice group |
| `-GROUP:Original,7wolf` | Multiple groups (comma-separated) |
| `-GAME:name` | Pack specific game |
| `-GAME:RA2,RA2YR` | Multiple games (comma-separated) |
| `-DRY_RUN` | Preview mode (no packing) |
| `-INCREMENTAL` | Skip already packed files |
| `-RETRY` | Retry previously failed files |

**Examples:**
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

### Original Games MIX Packaging

```batch
Pack_Mixes_Original.bat [-GROUP:name] [-RES:resolution]
```

Packs BIK files into MIX archives for the original RA2 and RA2YR games. Without parameters, processes **Original** group with **600p** resolution. RA2YR always uses **600pyr** regardless of `-RES:`.

| Flag | Description |
|------|-------------|
| `-GROUP:name` | Voice group |
| `-GROUP:Original,7wolf` | Multiple groups (comma-separated) |
| `-RES:resolution` | Target resolution |
| `-DRY_RUN` | Preview mode (no packing) |
| `-INCREMENTAL` | Skip already packed files |
| `-RETRY` | Retry previously failed files |

**Examples:**
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

### H.265 -> H.264 Converter

```batch
H265.bat [-SOURCE:path] [-OUTPUT:path] [-DRY_RUN]
```

Converts H.265 to H.264 without audio using 2-pass encoding. Interactive when run without flags. Non-interactive CLI mode:
- `-SOURCE:path` -- Input folder with H.265 videos
- `-OUTPUT:path` -- Output folder for H.264 files
- `-DRY_RUN` -- Preview mode (no conversion)

Supports MP4, MKV, MOV, AVI, M4V, TS, WEBM, FLV.

**CLI Examples:**
```batch
H265.bat -SOURCE:C:\Videos\H265 -OUTPUT:C:\Videos\H264
H265.bat -SOURCE:Clean_MP4 -OUTPUT:Converted
H265.bat -SOURCE:C:\Videos\H265 -OUTPUT:C:\Videos\H264 -DRY_RUN
```

### MP3 -> WAV Converter

```batch
MP3_to_WAV.bat [-OVERWRITE] [-DRY_RUN]
```

Converts MP3 audio files to WAV (16-bit PCM, 44100 Hz, stereo). Recursively scans `WAV_Sound/`. Skips existing WAVs by default. Always prompts for custom MP3 path (even with flags).

| Flag | Description |
|------|-------------|
| `-OVERWRITE` | Overwrite existing WAV files |
| `-DRY_RUN` | Preview mode |

**Examples:**
```batch
MP3_to_WAV.bat
MP3_to_WAV.bat -DRY_RUN
MP3_to_WAV.bat -OVERWRITE
```

### BIK Preview

```batch
Preview.bat [-GAME:name] [-GROUP:name] [-RES:name] [-FILE:path]
```

Interactive preview tool when run without flags. Non-interactive CLI mode:
- `-GAME:name` -- Game (RA1/RA2/RA2YR)
- `-GROUP:name` -- Voice group
- `-RES:name` -- Resolution
- `-FILE:path` -- BIK file to preview

Interactive step-by-step menu:
1. Select game (RA1/RA2/RA2YR)
2. Select MP4 file
3. Select resolution
4. Select voice group (or no audio)
5. Preview in `binkplay.exe`

### MIX Diff

```batch
MIX_Diff.bat [-PATH1:path] [-PATH2:path]
```

Comparison tool. Interactive menu when run without flags. Non-interactive CLI mode:
- `-PATH1:path` -- First directory or MIX file to compare
- `-PATH2:path` -- Second directory or MIX file to compare

Three modes:
1. Compare two BIK directories
2. Compare two MIX files
3. Compare MIX file with directory (interactive only)

Reports identical/added/removed/modified counts. Saves full report to temp file.

**CLI Examples:**
```batch
MIX_Diff.bat -PATH1:C:\dir1 -PATH2:C:\dir2
MIX_Diff.bat -PATH1:file1.mix -PATH2:file2.mix
```

### Resolution Converter

```batch
Resolution_Convert.bat [-INPUT:file] [-RES:WIDTHxHEIGHT] [-BITRATE:bps] [-DRY_RUN]
```

Interactive tool when run without flags. Non-interactive CLI mode:
- `-INPUT:file` -- Source BIK or MP4 file
- `-RES:WIDTHxHEIGHT` -- Target resolution (e.g., 1280x720)
- `-BITRATE:bps` -- Target bitrate in bps
- `-DRY_RUN` -- Preview mode (no conversion)

Three modes:
1. Convert single BIK to new resolution
2. Batch convert all BIK in folder
3. Convert MP4 to BIK with custom resolution

**CLI Example:**
```batch
Resolution_Convert.bat -INPUT:input.bik -RES:1280x720 -BITRATE:600000
Resolution_Convert.bat -INPUT:input.bik -RES:1920x1080 -BITRATE:1150000 -DRY_RUN
Resolution_Convert.bat -INPUT:video.mp4 -RES:1280x720 -BITRATE:600000
```

### MIX Validation

```batch
Validate_MIX.bat [-SCAN_DIR:path]
```

Validates MIX files. Interactive menu when run without flags. Non-interactive CLI mode:
- `-SCAN_DIR:path` -- Directory containing MIX files to validate

Interactive mode. Select source:
1. `Build\MOV` (MO Vision archives)
2. `Build\OriginalGames` (original game archives)
3. Custom path

Checks each MIX file: size > 0, minimum header size, ccmix --verify.

**CLI Examples:**
```batch
Validate_MIX.bat -SCAN_DIR:Build\MOV
Validate_MIX.bat -SCAN_DIR:Build\OriginalGames
```

### Workflow Examples

Real-world scenarios combining multiple flags and scripts:

**Full pipeline: convert all games, then pack**
```batch
REM Step 1: Convert all games at 600p
Cross_Converted_BIK.bat -RES:600p
REM Step 2: Pack for MO Vision
Pack_Mixes_MO_Vision.bat
REM Step 3: Pack for original games
Pack_Mixes_Original.bat -RES:600pyr
REM Step 4: Validate everything
Validate_MIX.bat -SCAN_DIR:Build
```

**Incremental rebuild: add new source files, convert only missing**
```batch
REM First run converts everything
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original
REM Later, after adding new MP4s, skip already converted
Cross_Converted_BIK.bat -GAME:RA2 -GROUP:Original -INCREMENTAL
```

**Debugging: preview what would be converted, then retry failures**
```batch
REM Check what files would be processed
Cross_Converted_BIK.bat -GAME:RA2,RA2YR -GROUP:Original,7wolf -DRY_RUN
REM Run actual conversion
Cross_Converted_BIK.bat -GAME:RA2,RA2YR -GROUP:Original,7wolf
REM If some files failed, retry only those
Cross_Converted_BIK.bat -GAME:RA2,RA2YR -GROUP:Original,7wolf -RETRY
```

**Selective packing: one group, one game, dry run first**
```batch
REM Preview what would be packed for 7wolf group in RA2
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:7wolf -DRY_RUN
REM Actually pack
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:7wolf
```

**Compare old build vs new build**
```batch
REM Compare two MIX archives
MIX_Diff.bat -PATH1:Build\MOV\Original\expandmo11_600p.mix -PATH2:Build\MOV\Original\expandmo11_720p.mix
REM Compare MIX contents against source directory
MIX_Diff.bat -PATH1:Build\MOV\Original\expandmo11_600p.mix -PATH2:Final_BIK_RA2\Original\600p
```

**Batch convert H.265 footage to H.264 for editing**
```batch
REM Convert all H.265 videos in a folder to H.264
H265.bat -SOURCE:D:\Footage\H265_raw -OUTPUT:D:\Footage\H264_editable
```

**Convert MP3 soundtrack to WAV for BIK mixing**
```batch
REM Preview what would be converted
MP3_to_WAV.bat -DRY_RUN
REM Convert, skipping existing WAVs
MP3_to_WAV.bat
REM Force reconvert all
MP3_to_WAV.bat -OVERWRITE
```

**Custom resolution for a specific BIK file**
```batch
REM Convert a single BIK to 1280x720 at 600 kbps
Resolution_Convert.bat -INPUT:Final_BIK_RA2\Original\600p\briefing.bik -RES:1280x720 -BITRATE:600000
REM Preview without converting
Resolution_Convert.bat -INPUT:Final_BIK_RA2\Original\600p\briefing.bik -RES:1920x1080 -BITRATE:1150000 -DRY_RUN
```

**Rebuild one resolution across all groups**
```batch
REM Convert only 720p for RA2, all groups
Cross_Converted_BIK.bat -GAME:RA2 -RES:720p
REM Pack only 720p for MO Vision
Pack_Mixes_MO_Vision.bat -GAME:RA2
```

**Validate specific MIX directory after build**
```batch
REM Check all MIX files in MO Vision build
Validate_MIX.bat -SCAN_DIR:Build\MOV
REM Check a specific group folder
Validate_MIX.bat -SCAN_DIR:Build\MOV\Original
```

### Test Suite

```batch
TEST\test_all.bat
```

Runs 118 automated tests across 9 modules:

| Module | Tests | Description |
|--------|-------|-------------|
| CMDParse | 36 | Argument parser: all modes, filters, defaults |
| config_loader | 5 | Config loading, path defaults, variable access |
| Filters | 8 | findstr logic, semicolons, substring rejection |
| Pack_Mixes_MO_Vision | 6 | FILTER_GAME/GROUP parsing, variable shadowing |
| Pack_Mixes_Original | 6 | AUDIO_GROUP parsing, defaults, splits |
| Cross_Converted_BIK | 9 | Game flags, RESOLUTION_FILTER findstr, defaults |
| Non-interactive CLI | 12 | CLI flags for MIX_Diff, Validate_MIX, H265, Resolution_Convert |
| Log Rotation | 18 | Auto-rotation when log > 1MB, size thresholds, rotation counter |
| PACK_MO_RETRY | 18 | MO Vision retry/dry_run/incremental output, CMDParse integration |

**Example:**
```batch
TEST\test_all.bat
```

## CMDParse -- Argument Parser

`CMDParse.exe` is a universal argument parser used by all batch scripts.

```batch
CMDParse.exe [flags]
```

| Mode | Description |
|------|-------------|
| `--mode:cross` | Cross_Converted_BIK (default) |
| `--mode:pack_mo` | Pack_Mixes_MO_Vision |
| `--mode:pack_original` | Pack_Mixes_Original |
| `--mode:mp3_to_wav` | MP3_to_WAV |
| `--mode:h265` | H265.bat |
| `--mode:preview` | Preview.bat |
| `--mode:validate` | Validate_MIX.bat |
| `--mode:resolution` | Resolution_Convert.bat |
| `--mode:mix_diff` | MIX_Diff.bat |

| Flag | Description |
|------|-------------|
| `-RA1`, `-RA2`, `-RA2YR` | Game flags |
| `-GAME:RA2,RA2YR` | Comma-separated game list |
| `-GROUP:Original,7wolf` | Comma-separated voice groups |
| `-RES:600p,720p+` | Comma-separated resolutions |
| `-DRY_RUN`, `-INCREMENTAL`, `-RETRY`, `-OVERWRITE` | Mode flags |
| `-SOURCE:path`, `-OUTPUT:path` | Path parameters |
| `--help` | Show help |

| Utility | Description |
|---------|-------------|
| `--list-groups` | List available voice groups |
| `--list-files` | List available MP4/BIK files |
| `--verify` | Verify all BIKs exist for resolutions |
| `--cleanup` | Remove empty BIK files |
| `--stats` | Show file statistics |

Defaults are loaded from `cmdparse.ini`.

For `--mode:pack_mo` and `--mode:pack_original`, `CMDParse.exe` outputs `DRY_RUN`, `INCREMENTAL`, and `RETRY` flags that control packing behavior (preview mode, skip existing, retry failed).

## Configuration

### config.ini

All scripts use `config_loader.bat` with `config.ini`:

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

CMDParse defaults (CLI arguments override these):

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

## Supported Resolutions

| Resolution | RA2/RA2YR | RA1 | Bitrate |
|------------|-----------|-----|---------|
| `600p` | 800x600 | 1024x600 | 400 kbps |
| `720p` | 960x720 | 1280x720 | 600 kbps |
| `768p` | 1024x768 | 1366x768 | 700 kbps |
| `900p` | 1200x900 | 1600x900 | 900 kbps |
| `1080p` | 1400x1080 | 1920x1080 | 1150 kbps |
| `600pyr` | 800x600 | -- | 1100 kbps RA2YR only |
| `noformat` | -- | 1024x564 | 400 kbps RA1 only |

## Supported Voice Groups

### Red Alert 1
`Original` `French` `German` `Ourmark` `Paradox` `R.G.MVO` `RusPerevod` `Ukrainian` `Vector` `VHS` `XXI Vek [GLS-21V]`

### Red Alert 2
`Original` `7wolf` `City [Dyadyushka Risyotch]` `Fargus` `French` `German` `Korean` `Russian project` `Thai` `Triada` `Turkish` `Ukrainian` `XXI Vek [8 Bit]`

### RA2: Yuri's Revenge
`Original` `7wolf` `City [Dyadyushka Risyotch]` `Fargus` `French` `German` `Korean` `Thai` `Triada` `Turkish` `Ukrainian`

## Important Notes

- **Platform**: Windows 10+ (cmd.exe only)
- **Encoding**: ~3-10 min per MP4 file
- **MIX limit**: Max 2GB per MIX file (x86)
- **Hidden windows**: radvideo64 and BinkMix run hidden via `run_hidden.vbs` (configurable with `hide_window=true/false` in config.ini)
- **Incremental**: `-INCREMENTAL` skips converted files
- **Retry**: Failed files -> `failed.txt`, use `-RETRY`
- **Dry run**: `-DRY_RUN` previews without converting
- **Logging**: Timestamps `[HH:MM:SS]` in log, ETA in console
- **Log Rotation**: Auto-rotates when log file exceeds 1MB (`conversion_log.txt` -> `conversion_log_YYYYMMDD_HHMMSS.log`)
- **CRLF**: All batch files use Windows CRLF line endings
- **Encoding**: `chcp 65001` for UTF-8 console output in main scripts

## Directory Structure

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
|   |-- CMDParse/         CMDParse.exe + sources
|   |-- CCMIX/            ccmix.exe
|   |-- Radtools_New/     radvideo64.exe, binkplay.exe
|   |-- Radtools_Old/     BinkMix.exe
|   |-- Original_MIX_Key/ MIX encryption keys
|   +-- ffmpeg.exe
|
|-- Clean_MP4/            Source MP4 videos
|-- WAV_Sound/            WAV audio tracks
|-- Clean_BIK/            Original BIK files
|
|-- Final_BIK_RA1/        RA1 output
|-- Final_BIK_RA2/        RA2 output
|-- Final_BIK_RA2YR/      RA2YR output
|
|-- Build/
|   |-- MOV/              MO Vision archives
|   +-- OriginalGames/    Original game archives
|
|-- Converted/            H265.bat output
|
+-- TEST/
    |-- test_all.bat      Test runner (118 tests)
    |-- test_cmdparse.bat
    |-- test_config_loader.bat
    |-- test_cross.bat
    |-- test_filters.bat
    |-- test_pack_mo.bat
    |-- test_pack_original.bat
    |-- test_cli.bat
    +-- test_log_rotation.bat
```

## Credits

- [RAD Game Tools](https://www.radgametools.com/) -- Bink encoder & mixer
- [FFmpeg](https://oss.netfarm.it/mplayer/) -- Video/audio processing
- [DarK600](https://forums.nexusmods.com/profile/41423505-dark600dionis/) -- AI-Upscaled cutscenes
- C&C modding community
