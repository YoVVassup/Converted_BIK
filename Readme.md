# 🎮 BIK Video Conversion Pipeline for Command & Conquer

[🇬🇧 English](Readme.md) | [🇷🇺 Русский](Readme_ru.md)

![License](https://img.shields.io/badge/license-GPLv3-blue)
![Platform](https://img.shields.io/badge/platform-Windows_10+-green)
![Status](https://img.shields.io/badge/status-stable-brightgreen)

[![RAD Tools](https://img.shields.io/badge/RAD_Game_Tools-Bink_1.0-orange)](https://www.radgametools.com/)
[![FFmpeg](https://img.shields.io/badge/FFmpeg-7.x-purple)](https://ffmpeg.org/)
[![Batch](https://img.shields.io/badge/Language-Windows_Batch-grey)](#)

Automated MP4 → BIK conversion pipeline with WAV audio mixing and MIX archive packaging for the Command & Conquer franchise.

## 🎯 Supported Games

| Game | Format |
|------|--------|
| **Red Alert 1** 🔴 | HD + Standard |
| **Red Alert 2** 🟡 | HD + Standard |
| **RA2: Yuri's Revenge** 🟣 | HD + Standard |

## 📥 Source Files

Download source MP4 videos, BIK files, and WAV audio tracks. **Required** for `Cross_Converted_BIK.bat` to work.

| Game | Link | Contents |
|------|------|----------|
| 🔴 Red Alert 1 | [Yandex.Disk](https://disk.yandex.com/d/byR2zVm0uniB0Q) | MP4 + WAV |
| 🟡 Red Alert 2 | [Yandex.Disk](https://disk.yandex.com/d/Swf4monQvkhA8w) | MP4 + BIK + WAV |
| 🟣 RA2: Yuri's Revenge | [Yandex.Disk](https://disk.yandex.com/d/8YOQIZcHQ74NMw) | MP4 + BIK + WAV |

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| 🎬 `radvideo64.exe` | MP4 → BIK encoding (Bink 1.0) |
| 🎵 `BinkMix.exe` | WAV → BIK audio mixing |
| 📦 `ccmix.exe` | MIX archive packing |
| 🎞️ `ffmpeg.exe` | H.265→H.264, MP3→WAV |
| 🎮 `binkplay.exe` | BIK preview player |
| 🔧 `CMDParse.exe` | Universal argument parser |

## 📜 Scripts

### 🔄 Core Conversion

```batch
Cross_Converted_BIK.bat [flags]
```

| Flag | Description |
|------|-------------|
| 🎯 `-GAME:RA1` / `-GAME:RA2` / `-GAME:RA2YR` | Filter by game (use multiple for several) |
| 👥 `-GROUP:name` / `-G:name` | Filter by voice group (use multiple for several) |
| 📐 `-RES:600p` | Filter by resolution (use multiple for several) |
| 📐+ `-RES:600p+` | Include noformat |
| ⏭️ `-INCREMENTAL` | Skip converted files |
| 🔄 `-RETRY` | Retry failed files |
| 👁️ `-DRY_RUN` | Preview mode |

**Examples:**
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

### 📦 MO Vision MIX Packaging

```batch
Pack_Mixes_MO_Vision.bat [-GROUP:name] [-GAME:name]
```

| Flag | Description |
|------|-------------|
| 👥 `-GROUP:name` | Pack specific voice group |
| 🎯 `-GAME:name` | Pack specific game |

**Examples:**
```batch
Pack_Mixes_MO_Vision.bat
Pack_Mixes_MO_Vision.bat -GROUP:Original
Pack_Mixes_MO_Vision.bat -GAME:RA2 -GROUP:7wolf
Pack_Mixes_MO_Vision.bat -GAME:RA2YR
```

### 📦 Original Games MIX Packaging

```batch
Pack_Mixes_Original.bat [-GROUP:name] [-RES:resolution]
```

Without parameters — processes **Original** group with **600p** resolution.

**Examples:**
```batch
Pack_Mixes_Original.bat
Pack_Mixes_Original.bat -GROUP:Original -RES:1080p
Pack_Mixes_Original.bat -GROUP:"Russian project" -RES:720p
Pack_Mixes_Original.bat -GROUP:7wolf -RES:600pyr
```

### 🎞️ H.265 → H.264 Converter

```batch
H265.bat
```

Interactive tool. Prompts for folder path with videos. Converts H.265 to H.264 without audio. Supports MP4, MKV, MOV, AVI, M4V, TS, WEBM, FLV.

### 🎵 MP3 → WAV Converter

```batch
MP3_to_WAV.bat [-OVERWRITE] [-DRY_RUN]
```

| Flag | Description |
|------|-------------|
| 🔄 `-OVERWRITE` | Overwrite existing WAV files |
| 👁️ `-DRY_RUN` | Preview mode |

**Examples:**
```batch
MP3_to_WAV.bat
MP3_to_WAV.bat -DRY_RUN
MP3_to_WAV.bat -OVERWRITE
```

### 👁️ BIK Preview

```batch
Preview.bat
```

Interactive preview tool. Step-by-step menu:
1. Select game (RA1/RA2/RA2YR)
2. Select MP4 file
3. Select resolution
4. Select voice group (or no audio)
5. Preview in `binkplay.exe`

### 🔍 MIX Diff

```batch
MIX_Diff.bat
```

Interactive comparison tool. Three modes:
1. Compare two BIK directories
2. Compare two MIX files
3. Compare MIX file with directory

### 📐 Resolution Converter

```batch
Resolution_Convert.bat
```

Interactive tool. Three modes:
1. Convert single BIK to new resolution
2. Batch convert all BIK in folder
3. Convert MP4 to BIK with custom resolution

### ✅ Pipeline Test

```batch
test.bat
```

Runs 6 checks:
1. Tools (radvideo64, BinkMix, ccmix)
2. Folders (Clean_MP4, WAV_Sound)
3. MP4 → BIK conversion
4. BinkMix.exe existence
5. Nolang config validation
6. DRY_RUN mode

### 🔒 MIX Validation

```batch
Validate_MIX.bat
```

Interactive validation. Select source:
1. `Build\MOV` (MO Vision archives)
2. `Build\OriginalGames` (original game archives)
3. Custom path

Checks each MIX file: size > 0, minimum header size, ccmix --verify.

## 🔧 CMDParse — Argument Parser

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
| 🎯 `-RA1`, `-RA2`, `-RA2YR` | Game flags |
| 🔗 `-GAME:RA2,RA2YR` | Comma-separated game list |
| 👥 `-GROUP:Original,7wolf` | Comma-separated voice groups |
| 📐 `-RES:600p,720p+` | Comma-separated resolutions |
| 🔄 `-DRY_RUN`, `-INCREMENTAL`, `-RETRY`, `-OVERWRITE` | Mode flags |
| 📂 `-SOURCE:path`, `-OUTPUT:path` | Path parameters |
| ❓ `--help` | Show help |

| Utility | Description |
|---------|-------------|
| `--list-groups` | List available voice groups |
| `--list-files` | List available MP4/BIK files |
| `--verify` | Verify all BIKs exist for resolutions |
| `--cleanup` | Remove empty BIK files |
| `--stats` | Show file statistics |

Defaults are loaded from `cmdparse.ini`.

## ⚙️ Configuration

### 📄 config.ini

All scripts use `config_loader.bat` with `config.ini`:

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

## 📐 Supported Resolutions

| Resolution | RA2/RA2YR | RA1 | Bitrate |
|------------|-----------|-----|---------|
| `600p` | 800x600 | 1024x600 | 400 kbps |
| `720p` | 960x720 | 1280x720 | 600 kbps |
| `768p` | 1024x768 | 1366x768 | 700 kbps |
| `900p` | 1200x900 | 1600x900 | 900 kbps |
| `1080p` | 1400x1080 | 1920x1080 | 1150 kbps |
| `600pyr` | 800x600 | — | 1100 kbps RA2YR only |
| `noformat` | — | 1024x564 | 400 kbps RA1 only |

## 👥 Supported Voice Groups

### 🔴 Red Alert 1
`Original` · `R.G.MVO` · `VHS`

### 🟡 Red Alert 2
`Original` · `7wolf` · `City [Dyadyushka Risyotch]` · `Fargus` · `Russian project` · `Triada` · `XXI Vek [8 Bit]`
`French` · `German` · `Korean` · `Ukrainian` · `Thai` · `Turkish`

### 🟣 RA2: Yuri's Revenge
`Original` · `7wolf` · `City [Dyadyushka Risyotch]` · `Fargus` · `Triada`
`French` · `German` · `Korean` · `Ukrainian` · `Thai` · `Turkish`

## ⚠️ Important Notes

- **🖥️ Platform**: Windows 10+ (cmd.exe only)
- **⏱️ Encoding**: ~3-10 min per MP4 file
- **💾 MIX limit**: Max 2GB per MIX file (x86)
- **👻 Hidden windows**: radvideo64 and BinkMix run hidden (no popup windows)
- **🔄 Incremental**: `-INCREMENTAL` skips converted files
- **🔁 Retry**: Failed files → `failed.txt`, use `-RETRY`
- **👁️ Dry run**: `-DRY_RUN` previews without converting
- **📝 Logging**: Timestamps `[HH:MM:SS]` in log, ETA in console

## 📁 Directory Structure

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
│   ├── CMDParse/       CMDParse.exe + sources
│   ├── CCMIX/          ccmix.exe
│   ├── Radtools_New/   radvideo64.exe, binkplay.exe
│   ├── Radtools_Old/   BinkMix.exe
│   ├── Original_MIX_Key/  MIX encryption keys
│   └── ffmpeg.exe
│
├── Clean_MP4/          Source MP4 videos
├── WAV_Sound/          WAV audio tracks
├── Clean_BIK/          Original BIK files
│
├── Final_BIK_RA1/      RA1 output
├── Final_BIK_RA2/      RA2 output
├── Final_BIK_RA2YR/    RA2YR output
│
├── Build/
│   ├── MOV/            MO Vision archives
│   └── OriginalGames/  Original game archives
│
└── Converted/          H265.bat output
```

## 🙏 Credits

- [RAD Game Tools](https://www.radgametools.com/) — Bink encoder & mixer
- [FFmpeg](https://oss.netfarm.it/mplayer/) — Video/audio processing
- [DarK600](https://forums.nexusmods.com/profile/41423505-dark600dionis/) — AI-Upscaled cutscenes
- C&C modding community
