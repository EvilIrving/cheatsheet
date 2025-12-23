# somebash

> Personal collection of useful scripts - Bash / Python / JavaScript

## Project Structure

```
somebash/
├── mac/                # macOS system initialization setup
├── media/              # Audio & video processing tools
├── scraper/            # Data scraping scripts
└── file-utils/         # File processing utilities
```

---

## mac/ - macOS System Initialization

Complete configuration solution for macOS fresh installation or system reset.

| File | Description |
|------|------|
| `init.sh` | Interactive one-click initialization script |
| `macos-setup-guide.md` | Detailed setup guide documentation |
| `Brewfile` | Homebrew package manifest |
| `brew-formulae.txt` | List of brew formulae |
| `brew-taps.txt` | List of brew taps |
| `vscode-extensions.txt` | List of VSCode extensions |

**Usage:**

```bash
cd mac
chmod +x init.sh
./init.sh
```

---

## media/ - Audio & Video Processing Tools

| File | Description |
|------|------|
| `batch-fix-metadata.sh` | Batch fix video metadata (FFmpeg) |
| `merge-video-guide.md` | Video merge & compression command guide |
| `xiaoyuzhou-downloader.js` | Xiaoyuzhou podcast audio downloader (Tampermonkey) |

**Video metadata fix:**

```bash
cd media
chmod +x batch-fix-metadata.sh
./batch-fix-metadata.sh
```

**Xiaoyuzhou downloader:** Install `xiaoyuzhou-downloader.js` script in Tampermonkey.

---

## scraper/ - Data Scraping Scripts

| File | Description |
|------|------|
| `zhipin-job-scraper.py` | Boss Zhipin job posting scraper |
| `json-writer.py` | JSON file writing utility |

**Usage:**

```bash
cd scraper
python zhipin-job-scraper.py
```

---

## file-utils/ - File Processing Utilities

| File | Description |
|------|------|
| `batch-rename-ext.sh` | Batch rename file extensions |

**Usage:**

```bash
cd file-utils
chmod +x batch-rename-ext.sh

# Rename all files in current directory to .png
./batch-rename-ext.sh png

# Rename to .jpg
./batch-rename-ext.sh jpg
```

---

## Dependencies

- **Shell scripts**: Bash / Zsh
- **Python scripts**: Python 3.x, requests
- **Video processing**: FFmpeg
- **Browser scripts**: Tampermonkey

## License

MIT
