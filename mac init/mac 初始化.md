软件 :
brew

AltTab.app              Keka.app                Scroll Reverser.app
Android Studio.app
                 lghub.app               Snipaste.app
Bartender 5.app         LocalSend.app
Clash Verge.app         Maccy.app               Telegram.app
CleanShot X.app         Magnet.app              Tencent Lemon.app
Downie 4.app            MarkText.app
Epson Software          NeatDownloadManager.app Utilities
               NeteaseMusic.app        Visual Studio Code.app
Fork.app                OmniDiskSweeper.app     WeChat.app
GMRightMouse.app                wechatwebdevtools.app
Google Chrome.app       Qoder.app               wpsoffice.app
IINA.app                Quark.app               Xcode.app
Input Source Pro.app    RunCat.app              Xmind.app
iTerm.app               Safari.app

orbstack

vscode 直接同步 
配置:
插件:



 
mac 系统

访达显示全部文件: 快捷键:  command + shift + . /  修改设置

https://share.google/aimode/qOvxhJqYLFpEaOMQm




先记录一下都哪些操作


开机登陆/连wifi/登陆账号/safari下载chrome

鼠标速度

Mac显示“隐藏文件”命令：
defaults write com.apple.finder AppleShowAllFiles -bool true
Mac隐藏“隐藏文件”命令：
defaults write com.apple.finder AppleShowAllFiles -bool false

下载 vivo 协作，用手机下载clashvergedev 传输到mac，安装然后复制订阅链接进去。开启机场，不然后续下载很多会失败。

先测试能不能连接
curl -I https://github.com

终端：/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
 

# cask 图形应用
# formulae 终端应用
# 常用命令 search info (un)install list cleanup deps update ugrade config
 

可下载的软件
fnm git pnpm iterm2  mole 

google-chrome python maccy keka visual-studio-code miaoyan orbstack biome tree  bun
 

自行下载的软件
微信
Qoder
RunCat 


# fnm 管理node版本
# 安装后需添加
 eval "$(fnm env)" 
 
 #valid env type 
 echo $SHELL

  touch ~/.zshrc / touch ~/.bash_profile (if not exist, touch create, use nano edit ) 

 # reload env 
 source ~/.zshrc  # 或 source ~/.bash_profile

# valid env 
fnm env  


install 24
use 24
 # git config
 
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"


ssh 🔗

# 生成SSH密钥
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 添加密钥到SSH代理
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# 复制公钥
pbcopy < ~/.ssh/id_rsa.pub

# 测试连接

ssh -T git@github.com



```sh
sudo mdutil -a -i off
sudo mdutil -a -E
mdutil -s /
```