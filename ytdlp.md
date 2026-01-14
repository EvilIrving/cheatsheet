# yt-dlp 字幕下载指南

## 安装

```bash
# macOS
brew install yt-dlp

# pip
pip install yt-dlp
```

## 下载字幕

### 下载视频并嵌入字幕

```bash
yt-dlp --embed-subs "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 仅下载字幕文件

```bash
# 下载所有可用字幕
yt-dlp --write-subs "https://www.youtube.com/watch?v=VIDEO_ID"

# 下载指定语言字幕
yt-dlp --write-subs --sub-lang zh-Hans "https://www.youtube.com/watch?v=VIDEO_ID"

# 下载指定语言字幕（自动翻译）
yt-dlp --write-subs --sub-lang zh-Hans --translate-subs "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 下载自动生成字幕

```bash
yt-dlp --write-subs --sub-langs "live_chat" "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 下载字幕并指定格式

```bash
# SRT 格式
yt-dlp --write-subs --sub-format srt "https://www.youtube.com/watch?v=VIDEO_ID"

# VTT 格式
yt-dlp --write-subs --sub-format vtt "https://www.youtube.com/watch?v=VIDEO_ID"

# ASS 格式（高级字幕）
yt-dlp --write-subs --sub-format ass "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 列出所有可用字幕

```bash
yt-dlp --list-subs "https://www.youtube.com/watch?v=VIDEO_ID"
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `--embed-subs` | 将字幕嵌入视频文件 |
| `--write-subs` | 下载字幕文件 |
| `--sub-lang LANG` | 指定字幕语言 |
| `--sub-format FORMAT` | 指定字幕格式 |
| `--translate-subs LANG` | 翻译字幕到指定语言 |
| `--no-check-certificate` | 跳过证书检查 |
| `--cookies FROM_FILE` | 使用 cookies 文件认证 |

## 批量下载

### 从文件读取 URL

```bash
yt-dlp --write-subs --batch-file urls.txt
```

### 下载整个播放列表

```bash
yt-dlp --write-subs "https://www.youtube.com/playlist?list=PLAYLIST_ID"
```

## 字幕格式转换

```bash
# 使用 ffmpeg 转换格式
ffmpeg -i input.srt output.vtt

# 或使用 yt-dlp 内置转换
yt-dlp --convert-subs srt "https://www.youtube.com/watch?v=VIDEO_ID"
```

## 提取音频

### 下载音频（自动转 MP3）

```bash
yt-dlp -x --audio-format mp3 "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 指定音频质量

```bash
# 最佳音质
yt-dlp -x --audio-format flac "https://www.youtube.com/watch?v=VIDEO_ID"

# 128kbps MP3
yt-dlp -x --audio-format mp3 --audio-quality 128K "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 仅下载音频（不转换）

```bash
yt-dlp -f ba "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 下载并嵌入封面

```bash
yt-dlp --embed-thumbnail --audio-format mp3 -x "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 常用选项

| 选项 | 说明 |
|------|------|
| `-x` | 提取音频 |
| `--audio-format` | 音频格式 (mp3, flac, aac, opus, wav) |
| `--audio-quality` | 音频质量 (0-9 或 Kbps) |
| `--embed-thumbnail` | 嵌入封面图 |
| `--add-metadata` | 添加元数据 |
