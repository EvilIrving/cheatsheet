# Whisper 本地部署指南

## 安装 Conda（Miniforge）

```bash
# 1. 安装 miniforge
brew install miniforge

# 2. 初始化
conda init zsh
source ~/.zshrc

# 3. 验证
conda --version
```

## 安装 Whisper

```bash
# 1. 创建 conda 环境
conda create -n whisper python=3.10 -y
conda activate whisper

# 2. 安装 whisper
pip install openai-whisper

# 3. FFmpeg（系统已装则不需要）
brew install ffmpeg
```

## 使用

```bash
# 基础用法
whisper audio.mp3 --model small --language Chinese

# 指定模型（推荐）
whisper audio.mp3 --model small    # 快，够用
whisper audio.mp3 --model medium   # 推荐，平衡
whisper audio.mp3 --model large    # 最准，慢

# M 系列芯片加速
whisper audio.mp3 --model small --device mps

# 输出格式
whisper audio.mp3 --model small --output_format srt   # 字幕
whisper audio.mp3 --model small --output_format txt   # 纯文本
whisper audio.mp3 --model small --output_format json  # JSON
```

## 模型对比

| 模型 | 10分钟音频耗时 | 显存占用 | 推荐场景 |
|------|---------------|----------|----------|
| tiny | ~10 秒 | ~1GB | 快速预览 |
| base | ~20 秒 | ~1GB | 简单转写 |
| small | ~50 秒 | ~2GB | **日常推荐** |
| medium | ~2 分钟 | ~5GB | 高精度需求 |
| large | ~5 分钟 | ~10GB | 最高精度 |

## 常用命令

```bash
# 音频转中文文字
whisper audio.mp3 --model small --language Chinese

# 生成字幕文件
whisper audio.mp3 --model small --output_format srt

# 音频转英文
whisper audio.mp3 --model small --language English

# 指定输出目录
whisper audio.mp3 --model small --output_dir ./output
```

## 卸载

```bash
conda deactivate
conda remove -n whisper --all -y
```
