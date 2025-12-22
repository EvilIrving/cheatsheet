#!/bin/zsh
# macOS 系统初始化脚本
# 基于 mac 初始化.md 文档实现
# 用法: chmod +x init.sh && ./init.sh

set -e

# ==================== 颜色定义 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==================== 工具函数 ====================
print_header() {
    echo ""
    echo "${PURPLE}============================================${NC}"
    echo "${PURPLE}  $1${NC}"
    echo "${PURPLE}============================================${NC}"
    echo ""
}

print_info() {
    echo "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo "${RED}[✗]${NC} $1"
}

confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    echo -n "${CYAN}$prompt${NC}"
    read -r response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

press_enter() {
    echo ""
    echo -n "${CYAN}按 Enter 键继续...${NC}"
    read -r
}

# ==================== 检查函数 ====================
check_network() {
    print_info "检查网络连接..."
    if curl -s --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        print_success "网络连接正常"
        return 0
    else
        print_warning "无法连接到 GitHub，请检查网络或代理设置"
        return 1
    fi
}

check_homebrew() {
    if command -v brew &> /dev/null; then
        print_success "Homebrew 已安装"
        return 0
    else
        print_warning "Homebrew 未安装"
        return 1
    fi
}

# ==================== 安装 Homebrew ====================
install_homebrew() {
    print_header "安装 Homebrew"
    
    if check_homebrew; then
        print_info "跳过 Homebrew 安装"
        return 0
    fi
    
    if confirm "是否安装 Homebrew?" "y"; then
        print_info "正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # 添加 Homebrew 到 PATH (Apple Silicon Mac)
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        print_success "Homebrew 安装完成"
    else
        print_info "跳过 Homebrew 安装"
    fi
}

# ==================== 系统设置 ====================
configure_mouse() {
    print_header "鼠标设置"
    
    print_info "当前鼠标速度: $(defaults read -g com.apple.mouse.scaling 2>/dev/null || echo '默认')"
    print_info "当前滚动速度: $(defaults read -g com.apple.scrollwheel.scaling 2>/dev/null || echo '默认')"
    
    if confirm "是否优化鼠标设置? (移动速度: 2.6, 滚动速度: 1.2)" "y"; then
        defaults write -g com.apple.mouse.scaling 2.6
        defaults write -g com.apple.scrollwheel.scaling 1.2
        print_success "鼠标设置已更新 (需重启生效)"
    fi
}

configure_keyboard() {
    print_header "键盘设置"
    
    print_info "当前按键重复频率: $(defaults read -g KeyRepeat 2>/dev/null || echo '默认')"
    print_info "当前重复前延迟: $(defaults read -g InitialKeyRepeat 2>/dev/null || echo '默认')"
    
    if confirm "是否优化键盘设置? (重复频率: 1, 延迟: 10)" "y"; then
        defaults write -g KeyRepeat -int 1
        defaults write -g InitialKeyRepeat -int 10
        print_success "键盘设置已更新 (需重启生效)"
    fi
}

configure_finder() {
    print_header "Finder 访达设置"
    
    if confirm "是否显示隐藏文件?" "n"; then
        defaults write com.apple.finder AppleShowAllFiles -bool true
        print_success "已设置显示隐藏文件"
    fi
    
    if confirm "是否禁用 .DS_Store 文件生成?" "y"; then
        defaults write com.apple.desktopservices DSDontWriteStores -bool true
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
        defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
        print_success "已禁用 .DS_Store 文件生成"
    fi
    
    killall Finder 2>/dev/null || true
    print_info "Finder 已重启"
}

configure_dock() {
    print_header "Dock 设置"
    
    if confirm "是否隐藏 Dock 中的'最近使用的应用'?" "y"; then
        defaults write com.apple.dock show-recents -bool false
        killall Dock
        print_success "已隐藏最近使用的应用"
    fi
}

configure_other_system() {
    print_header "其他系统设置"
    
    if confirm "是否关闭听写功能?" "y"; then
        defaults write com.apple.assistant.support "Dictation Enabled" -bool false
        print_success "已关闭听写功能"
    fi
}

configure_spotlight() {
    print_header "Spotlight 索引管理"
    
    print_info "当前 Spotlight 状态:"
    mdutil -s / 2>/dev/null || echo "无法获取状态"
    
    if confirm "是否关闭 Spotlight 索引? (可节省系统资源)" "n"; then
        print_warning "此操作需要管理员权限"
        sudo mdutil -a -i off
        print_success "已关闭 Spotlight 索引"
        
        if confirm "是否清除现有索引数据?" "n"; then
            sudo mdutil -a -E
            print_success "已清除索引数据"
        fi
    fi
}

# ==================== 软件安装 ====================
install_formulae() {
    print_header "安装 Brew Formulae (终端工具)"
    
    local formulae=("fnm" "git" "pnpm" "tw93/tap/mole" "tree")
    
    print_info "将安装以下终端工具:"
    for pkg in "${formulae[@]}"; do
        echo "  - $pkg"
    done
    
    if confirm "是否继续安装?" "y"; then
        for pkg in "${formulae[@]}"; do
            if brew list "$pkg" &>/dev/null; then
                print_info "$pkg 已安装，跳过"
            else
                print_info "正在安装 $pkg..."
                brew install "$pkg" && print_success "$pkg 安装成功" || print_error "$pkg 安装失败"
            fi
        done
    fi
}

install_casks() {
    print_header "安装 Brew Casks (图形应用)"
    
    local casks=("google-chrome" "visual-studio-code" "iterm2" "orbstack" "maccy" "keka")
    
    print_info "将安装以下图形应用:"
    for app in "${casks[@]}"; do
        echo "  - $app"
    done
    
    if confirm "是否继续安装?" "y"; then
        for app in "${casks[@]}"; do
            if brew list --cask "$app" &>/dev/null; then
                print_info "$app 已安装，跳过"
            else
                print_info "正在安装 $app..."
                brew install --cask "$app" && print_success "$app 安装成功" || print_error "$app 安装失败"
            fi
        done
    fi
}

show_manual_apps() {
    print_header "需要手动下载的应用"
    
    print_info "以下应用需要手动下载安装:"
    echo "  - 微信"
    echo "  - Qoder"
    echo "  - RunCat"
    echo "  - Lemon Cleaner"
    echo "  - ClashVerge (代理工具)"
    
    press_enter
}

# ==================== 开发环境配置 ====================
configure_fnm() {
    print_header "配置 fnm (Node.js 版本管理)"
    
    if ! command -v fnm &> /dev/null; then
        print_warning "fnm 未安装，请先安装 fnm"
        return 1
    fi
    
    # 检查是否已配置
    if grep -q 'fnm env' ~/.zshrc 2>/dev/null; then
        print_info "fnm 环境已配置"
    else
        if confirm "是否将 fnm 环境添加到 ~/.zshrc?" "y"; then
            echo 'eval "$(fnm env)"' >> ~/.zshrc
            print_success "fnm 环境已添加到 ~/.zshrc"
        fi
    fi
    
    # 安装 Node.js
    if confirm "是否安装 Node.js 24?" "y"; then
        print_info "正在安装 Node.js 24..."
        fnm install 24
        fnm use 24
        print_success "Node.js $(node -v) 已安装并激活"
    fi
}

configure_git() {
    print_header "Git 配置"
    
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$current_name" ]]; then
        print_info "当前 Git 用户名: $current_name"
    fi
    if [[ -n "$current_email" ]]; then
        print_info "当前 Git 邮箱: $current_email"
    fi
    
    if confirm "是否配置 Git 用户信息?" "y"; then
        echo -n "${CYAN}请输入用户名: ${NC}"
        read -r git_name
        echo -n "${CYAN}请输入邮箱: ${NC}"
        read -r git_email
        
        if [[ -n "$git_name" ]]; then
            git config --global user.name "$git_name"
            print_success "Git 用户名已设置: $git_name"
        fi
        if [[ -n "$git_email" ]]; then
            git config --global user.email "$git_email"
            print_success "Git 邮箱已设置: $git_email"
        fi
    fi
}

configure_ssh() {
    print_header "SSH 密钥配置"
    
    if [[ -f ~/.ssh/id_rsa.pub ]]; then
        print_info "SSH 密钥已存在"
        if confirm "是否查看公钥?" "y"; then
            echo ""
            cat ~/.ssh/id_rsa.pub
            echo ""
        fi
    else
        if confirm "是否生成新的 SSH 密钥?" "y"; then
            echo -n "${CYAN}请输入邮箱: ${NC}"
            read -r ssh_email
            
            if [[ -n "$ssh_email" ]]; then
                ssh-keygen -t rsa -b 4096 -C "$ssh_email"
                
                # 启动 SSH 代理并添加密钥
                eval "$(ssh-agent -s)"
                ssh-add ~/.ssh/id_rsa
                
                print_success "SSH 密钥已生成"
                
                if confirm "是否复制公钥到剪贴板?" "y"; then
                    pbcopy < ~/.ssh/id_rsa.pub
                    print_success "公钥已复制到剪贴板，请粘贴到 GitHub Settings → SSH Keys"
                fi
            fi
        fi
    fi
    
    if confirm "是否测试 GitHub SSH 连接?" "n"; then
        print_info "测试 GitHub SSH 连接..."
        ssh -T git@github.com 2>&1 || true
    fi
}

# ==================== 主菜单 ====================
show_menu() {
    clear
    echo ""
    echo "${PURPLE}╔════════════════════════════════════════════════════╗${NC}"
    echo "${PURPLE}║       macOS 系统初始化脚本 v1.0                    ║${NC}"
    echo "${PURPLE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "${CYAN}请选择要执行的操作:${NC}"
    echo ""
    echo "  ${GREEN}[0]${NC} 🚀 一键全部配置"
    echo ""
    echo "  ${YELLOW}── 前置准备 ──${NC}"
    echo "  ${GREEN}[1]${NC} 检查网络连接"
    echo "  ${GREEN}[2]${NC} 安装 Homebrew"
    echo ""
    echo "  ${YELLOW}── 系统设置 ──${NC}"
    echo "  ${GREEN}[3]${NC} 鼠标设置"
    echo "  ${GREEN}[4]${NC} 键盘设置"
    echo "  ${GREEN}[5]${NC} Finder 访达设置"
    echo "  ${GREEN}[6]${NC} Dock 设置"
    echo "  ${GREEN}[7]${NC} 其他系统设置"
    echo "  ${GREEN}[8]${NC} Spotlight 索引管理"
    echo ""
    echo "  ${YELLOW}── 软件安装 ──${NC}"
    echo "  ${GREEN}[9]${NC} 安装 Brew Formulae (终端工具)"
    echo "  ${GREEN}[10]${NC} 安装 Brew Casks (图形应用)"
    echo "  ${GREEN}[11]${NC} 查看手动安装应用列表"
    echo ""
    echo "  ${YELLOW}── 开发环境 ──${NC}"
    echo "  ${GREEN}[12]${NC} 配置 fnm (Node.js)"
    echo "  ${GREEN}[13]${NC} 配置 Git"
    echo "  ${GREEN}[14]${NC} 配置 SSH 密钥"
    echo ""
    echo "  ${GREEN}[q]${NC} 退出"
    echo ""
    echo -n "${CYAN}请输入选项: ${NC}"
}

run_all() {
    print_header "开始一键全部配置"
    
    if ! confirm "确定要执行全部配置吗?" "n"; then
        return
    fi
    
    check_network
    install_homebrew
    
    # 检查 Homebrew 是否安装成功
    if ! check_homebrew; then
        print_error "Homebrew 未安装，无法继续"
        return 1
    fi
    
    # 系统设置
    configure_mouse
    configure_keyboard
    configure_finder
    configure_dock
    configure_other_system
    
    # 软件安装
    install_formulae
    install_casks
    show_manual_apps
    
    # 开发环境
    configure_fnm
    configure_git
    configure_ssh
    
    print_header "配置完成!"
    print_warning "部分设置需要重启系统才能生效"
}

# ==================== 主程序 ====================
main() {
    # 检查是否在 macOS 上运行
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "此脚本仅支持 macOS 系统"
        exit 1
    fi
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            0) run_all ;;
            1) check_network; press_enter ;;
            2) install_homebrew; press_enter ;;
            3) configure_mouse; press_enter ;;
            4) configure_keyboard; press_enter ;;
            5) configure_finder; press_enter ;;
            6) configure_dock; press_enter ;;
            7) configure_other_system; press_enter ;;
            8) configure_spotlight; press_enter ;;
            9) install_formulae; press_enter ;;
            10) install_casks; press_enter ;;
            11) show_manual_apps ;;
            12) configure_fnm; press_enter ;;
            13) configure_git; press_enter ;;
            14) configure_ssh; press_enter ;;
            q|Q) 
                print_info "再见! 👋"
                exit 0 
                ;;
            *)
                print_error "无效选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# 运行主程序
main
