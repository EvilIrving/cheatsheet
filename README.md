# somebash

> 个人常用脚本工具集 - Bash / Python / JavaScript

## 项目结构

```
somebash/
├── mac/                # macOS 系统初始化配置
├── media/              # 音视频处理工具
├── scraper/            # 数据爬取脚本
└── file-utils/         # 文件处理工具
```

---

## mac/ - macOS 系统初始化

macOS 新机/重装后的完整配置方案。

| 文件 | 说明 |
|------|------|
| `init.sh` | 交互式一键初始化脚本 |
| `macos-setup-guide.md` | 详细配置指南文档 |
| `Brewfile` | Homebrew 软件清单 |
| `brew-formulae.txt` | brew formulae 列表 |
| `brew-taps.txt` | brew taps 列表 |
| `vscode-extensions.txt` | VSCode 扩展列表 |

**使用方法:**

```bash
cd mac
chmod +x init.sh
./init.sh
```

---

## media/ - 音视频处理工具

| 文件 | 说明 |
|------|------|
| `batch-fix-metadata.sh` | 批量修复视频元数据 (FFmpeg) |
| `merge-video-guide.md` | 视频合并压缩命令指南 |
| `xiaoyuzhou-downloader.js` | 小宇宙播客音频下载 (Tampermonkey) |

**视频元数据修复:**

```bash
cd media
chmod +x batch-fix-metadata.sh
./batch-fix-metadata.sh
```

**小宇宙下载器:** 在 Tampermonkey 中安装 `xiaoyuzhou-downloader.js` 脚本。

---

## scraper/ - 数据爬取脚本

| 文件 | 说明 |
|------|------|
| `zhipin-job-scraper.py` | Boss直聘招聘信息爬虫 |
| `json-writer.py` | JSON 文件写入工具 |

**使用方法:**

```bash
cd scraper
python zhipin-job-scraper.py
```

---

## file-utils/ - 文件处理工具

| 文件 | 说明 |
|------|------|
| `batch-rename-ext.sh` | 批量重命名文件扩展名 |

**使用方法:**

```bash
cd file-utils
chmod +x batch-rename-ext.sh

# 将当前目录所有文件扩展名改为 .png
./batch-rename-ext.sh png

# 改为 .jpg
./batch-rename-ext.sh jpg
```

---

## 依赖要求

- **Shell 脚本**: Bash / Zsh
- **Python 脚本**: Python 3.x, requests
- **视频处理**: FFmpeg
- **浏览器脚本**: Tampermonkey

## License

MIT