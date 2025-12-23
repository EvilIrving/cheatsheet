# macOS System Setup Guide

> This guide documents the complete macOS configuration process for fresh installation or system reset
> Companion script: `init.sh` (Interactive one-click setup)

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [System Optimization](#2-system-optimization)
3. [Software Installation](#3-software-installation)
4. [Development Environment](#4-development-environment)
5. [Additional Settings](#5-additional-settings)

---

## 1. Prerequisites

### 1.1 Basic Setup (Manual)

- Power on and login → Connect to WiFi → Sign in to Apple account

### 1.2 Network Proxy (Important: Ensure downloads don't fail)

```sh
# Download proxy tool via mobile phone and transfer to Mac
# Install ClashVerge and add subscription link to enable proxy

# Test network connectivity
curl -I https://github.com
```

### 1.3 Install Homebrew

```sh
# macOS package manager - most software will be installed through it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Common Homebrew commands:
# - cask: GUI applications
# - formulae: CLI tools
# - Common: search | info | install | uninstall | list | cleanup | deps | update | upgrade | config
```

---

## 2. System Optimization

### 2.1 Mouse Settings

```sh
# Read current mouse speed
defaults read -g com.apple.mouse.scaling

# Set mouse movement speed (range 0-3, >3 is faster, requires restart)
defaults write -g com.apple.mouse.scaling 2.6

# Set mouse scroll speed (range 0-1.7)
defaults write -g com.apple.scrollwheel.scaling 1.2
```

### 2.2 Keyboard Settings

```sh
# Key repeat rate (range 120-2, smaller = faster)
defaults write -g KeyRepeat -int 1

# Delay before repeat (range 120-15, smaller = more responsive)
defaults write -g InitialKeyRepeat -int 10
```

### 2.3 Finder Settings

```sh
# Show hidden files (shortcut: Command + Shift + .)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Hide hidden files
defaults write com.apple.finder AppleShowAllFiles -bool false

# Disable .DS_Store file generation
defaults write com.apple.desktopservices DSDontWriteStores -bool true        # Local folders
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true  # Network folders
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true      # USB devices
```

### 2.4 Dock Settings

```sh
# Hide "Recent Applications" in Dock
defaults write com.apple.dock show-recents -bool false

# Restart Dock to apply changes
killall Dock
```

### 2.5 Menu Bar Spacing Settings

**Reference**: https://tinyapps.org/blog/reduce-menubar-spacing.html

**Minimal spacing** (most compact):
```sh
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 0 && \
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 0 && \
killall ControlCenter
```

**Custom spacing** (balanced):
```sh
# Adjust menu bar spacing constant (smaller value = more compact items)
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 10

# Adjust selection padding (smaller value = reduced selection area)
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 3

# Restart ControlCenter to apply changes
killall ControlCenter
```

**Restore default spacing**:
```sh
defaults -currentHost delete -globalDomain NSStatusItemSpacing && \
defaults -currentHost delete -globalDomain NSStatusItemSelectionPadding && \
killall ControlCenter
```

### 2.6 Other System Settings

```sh
# Disable Dictation
defaults write com.apple.assistant.support "Dictation Enabled" -bool false
```

---

## 3. Software Installation

### 3.1 Brew Formulae (Terminal Tools)

```sh
brew install fnm git pnpm mole tree
```

### 3.2 Brew Casks (GUI Applications)

```sh
brew install --cask \
  google-chrome \
  visual-studio-code \
  iterm2 \
  orbstack \
  maccy \
  keka \
  miaoyan
  squirrel-app
```

### 3.3 Manual Installation

- WeChat
- Qoder
- RunCat
- Lemon Cleaner
- ClashVerge (Proxy tool)

---

## 4. Development Environment

### 4.1 fnm (Node.js Version Manager)

```sh
# Check current shell type
echo $SHELL

# Add fnm environment to shell config file
# Create file if it doesn't exist: touch ~/.zshrc
echo 'eval "$(fnm env)"' >> ~/.zshrc

# Reload configuration
source ~/.zshrc

# Verify fnm environment
fnm env

# Install and use Node.js
fnm install 24
fnm use 24
```

### 4.2 Git Configuration

```sh
# Set user information
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 4.3 SSH Key Configuration (for GitHub, etc.)

```sh
# Generate SSH key (replace with your email)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Copy public key to clipboard (paste to GitHub Settings → SSH Keys)
pbcopy < ~/.ssh/id_rsa.pub

# Test GitHub SSH connection
ssh -T git@github.com
```

## 5. Additional Settings

### 5.1 Spotlight Index Management

```sh
# Disable Spotlight indexing (saves system resources)
sudo mdutil -a -i off

# Clear existing index data
sudo mdutil -a -E

# View indexing status
mdutil -s /
```
