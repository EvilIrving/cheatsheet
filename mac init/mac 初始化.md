# macOS 系统初始化指南

> 本文档记录 macOS 新机/重装后的完整配置流程
> 配套脚本: `install.sh` (交互式一键配置)

---

## 目录

1. [前置准备](#1-前置准备)
2. [系统设置优化](#2-系统设置优化)
3. [软件安装](#3-软件安装)
4. [开发环境配置](#4-开发环境配置)
5. [其他设置](#5-其他设置)

---

## 1. 前置准备

### 1.1 基础操作（手动）

- 开机登录 → 连接 WiFi → 登录 Apple 账号

### 1.2 网络代理（重要：确保后续下载不失败）

```sh
# 下载 vivo 协作，用手机下载 ClashVerge 传输到 Mac
# 安装后复制订阅链接，开启代理

# 测试网络连通性
curl -I https://github.com
```

### 1.3 安装 Homebrew

```sh
# macOS 包管理器，后续大部分软件通过它安装
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Homebrew 常用命令说明:
# - cask: 图形应用 (GUI apps)
# - formulae: 终端应用 (CLI tools)
# - 常用: search | info | install | uninstall | list | cleanup | deps | update | upgrade | config
```

---

## 2. 系统设置优化

### 2.1 鼠标设置

```sh
# 读取当前鼠标速度
defaults read -g com.apple.mouse.scaling

# 设置鼠标移动速度 (范围 0-3，超过3更快，需重启生效)
defaults write -g com.apple.mouse.scaling 2.6

# 设置鼠标滚动速度 (范围 0-1.7)
defaults write -g com.apple.scrollwheel.scaling 1.2
```

### 2.2 键盘设置

```sh
# 按键重复频率 (范围 120-2，越小越快)
defaults write -g KeyRepeat -int 1

# 重复前延迟 (范围 120-15，越小响应越快)
defaults write -g InitialKeyRepeat -int 10
```

### 2.3 Finder 访达设置

```sh
# 显示隐藏文件 (快捷键: Command + Shift + .)
defaults write com.apple.finder AppleShowAllFiles -bool true

# 隐藏隐藏文件
defaults write com.apple.finder AppleShowAllFiles -bool false

# 禁用 .DS_Store 文件生成
defaults write com.apple.desktopservices DSDontWriteStores -bool true        # 本地文件夹
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true  # 网络文件夹
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true      # USB存储设备
```

### 2.4 Dock 设置

```sh
# 隐藏 Dock 中的"最近使用的应用"
defaults write com.apple.dock show-recents -bool false

# 重启 Dock 使设置生效
killall Dock
```

### 2.5 其他系统设置

```sh
# 关闭听写功能
defaults write com.apple.assistant.support "Dictation Enabled" -bool false
```

---

## 3. 软件安装

### 3.1 Brew Formulae (终端工具)

```sh
brew install fnm git pnpm mole tree
```

### 3.2 Brew Casks (图形应用)

```sh
brew install --cask \
  google-chrome \
  visual-studio-code \
  iterm2 \
  orbstack \
  maccy \
  keka \
  miaoyan
```

### 3.3 手动下载安装

- 微信
- Qoder
- RunCat
- Lemon Cleaner
- ClashVerge (代理工具)

---

## 4. 开发环境配置

### 4.1 fnm (Node.js 版本管理)

```sh
# 检查当前 Shell 类型
echo $SHELL

# 添加 fnm 环境到 shell 配置文件
# 如果文件不存在先创建: touch ~/.zshrc
echo 'eval "$(fnm env)"' >> ~/.zshrc

# 重新加载配置
source ~/.zshrc

# 验证 fnm 环境
fnm env

# 安装并使用 Node.js
fnm install 24
fnm use 24
```

### 4.2 Git 配置

```sh
# 设置用户信息
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

### 4.3 SSH 密钥配置 (用于 GitHub 等)

```sh
# 生成 SSH 密钥 (替换为你的邮箱)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 启动 SSH 代理并添加密钥
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# 复制公钥到剪贴板 (粘贴到 GitHub Settings → SSH Keys)
pbcopy < ~/.ssh/id_rsa.pub

# 测试 GitHub SSH 连接
ssh -T git@github.com
```

## 5. 其他设置

### 5.1 Spotlight 索引管理

```sh
# 关闭 Spotlight 索引 (节省资源)
sudo mdutil -a -i off

# 清除索引数据
sudo mdutil -a -E

# 查看索引状态
mdutil -s /
```
