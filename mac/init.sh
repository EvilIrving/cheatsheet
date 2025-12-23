#!/bin/zsh
# macOS System Initialization Script
# Based on macos-setup-guide.md documentation
# Usage: chmod +x init.sh && ./init.sh

set -e

# ==================== Color Definitions ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==================== Utility Functions ====================
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
    echo -n "${CYAN}Press Enter to continue...${NC}"
    read -r
}

# ==================== Check Functions ====================
check_network() {
    print_info "Checking network connectivity..."
    if curl -s --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        print_success "Network connection is OK"
        return 0
    else
        print_warning "Cannot connect to GitHub. Please check your network or proxy settings."
        return 1
    fi
}

check_homebrew() {
    if command -v brew &> /dev/null; then
        print_success "Homebrew is already installed"
        return 0
    else
        print_warning "Homebrew is not installed"
        return 1
    fi
}

# ==================== Install Homebrew ====================
install_homebrew() {
    print_header "Installing Homebrew"
    
    if check_homebrew; then
        print_info "Skipping Homebrew installation"
        return 0
    fi
    
    if confirm "Install Homebrew?" "y"; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH (Apple Silicon Mac)
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installation completed"
    else
        print_info "Skipping Homebrew installation"
    fi
}

# ==================== System Settings ====================
configure_mouse() {
    print_header "Mouse Settings"
    
    print_info "Current mouse speed: $(defaults read -g com.apple.mouse.scaling 2>/dev/null || echo 'default')"
    print_info "Current scroll speed: $(defaults read -g com.apple.scrollwheel.scaling 2>/dev/null || echo 'default')"
    
    if confirm "Optimize mouse settings? (movement: 2.6, scroll: 1.2)" "y"; then
        defaults write -g com.apple.mouse.scaling 2.6
        defaults write -g com.apple.scrollwheel.scaling 1.2
        print_success "Mouse settings updated (restart required)"
    fi
}

configure_keyboard() {
    print_header "Keyboard Settings"
    
    print_info "Current key repeat rate: $(defaults read -g KeyRepeat 2>/dev/null || echo 'default')"
    print_info "Current initial repeat delay: $(defaults read -g InitialKeyRepeat 2>/dev/null || echo 'default')"
    
    if confirm "Optimize keyboard settings? (repeat rate: 1, delay: 10)" "y"; then
        defaults write -g KeyRepeat -int 1
        defaults write -g InitialKeyRepeat -int 10
        print_success "Keyboard settings updated (restart required)"
    fi
}

configure_finder() {
    print_header "Finder Settings"
    
    if confirm "Show hidden files?" "n"; then
        defaults write com.apple.finder AppleShowAllFiles -bool true
        print_success "Hidden files will be shown"
    fi
    
    if confirm "Disable .DS_Store file generation?" "y"; then
        defaults write com.apple.desktopservices DSDontWriteStores -bool true
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
        defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
        print_success ".DS_Store file generation disabled"
    fi
    
    killall Finder 2>/dev/null || true
    print_info "Finder restarted"
}

configure_dock() {
    print_header "Dock Settings"
    
    if confirm "Hide 'Recent Applications' in Dock?" "y"; then
        defaults write com.apple.dock show-recents -bool false
        killall Dock
        print_success "Recent applications hidden"
    fi
}

configure_menubar() {
    print_header "Menu Bar Spacing Settings"
    
    print_info "Current menu bar spacing settings:"
    print_info "  Spacing width: $(defaults -currentHost read -globalDomain NSStatusItemSpacing 2>/dev/null || echo 'default')"
    print_info "  Selection padding: $(defaults -currentHost read -globalDomain NSStatusItemSelectionPadding 2>/dev/null || echo 'default')"
    
    if confirm "Optimize menu bar spacing? (spacing: 10, padding: 3)" "y"; then
        defaults -currentHost write -globalDomain NSStatusItemSpacing -int 10
        defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 3
        killall ControlCenter
        print_success "Menu bar spacing updated (ControlCenter restarted)"
    fi
}

configure_other_system() {
    print_header "Other System Settings"
    
    if confirm "Disable Dictation?" "y"; then
        defaults write com.apple.assistant.support "Dictation Enabled" -bool false
        print_success "Dictation disabled"
    fi
}

configure_spotlight() {
    print_header "Spotlight Index Management"
    
    print_info "Current Spotlight status:"
    mdutil -s / 2>/dev/null || echo "Unable to get status"
    
    if confirm "Disable Spotlight indexing? (saves system resources)" "n"; then
        print_warning "This operation requires administrator privileges"
        sudo mdutil -a -i off
        print_success "Spotlight indexing disabled"
        
        if confirm "Clear existing index data?" "n"; then
            sudo mdutil -a -E
            print_success "Index data cleared"
        fi
    fi
}

# ==================== Software Installation ====================
install_formulae() {
    print_header "Installing Brew Formulae (Terminal Tools)"
    
    local formulae=("fnm" "git" "pnpm" "tw93/tap/mole" "tree")
    
    print_info "The following terminal tools will be installed:"
    for pkg in "${formulae[@]}"; do
        echo "  - $pkg"
    done
    
    if confirm "Continue installation?" "y"; then
        for pkg in "${formulae[@]}"; do
            if brew list "$pkg" &>/dev/null; then
                print_info "$pkg already installed, skipping"
            else
                print_info "Installing $pkg..."
                brew install "$pkg" && print_success "$pkg installed successfully" || print_error "$pkg installation failed"
            fi
        done
    fi
}

install_casks() {
    print_header "Installing Brew Casks (GUI Applications)"
    
    local casks=("google-chrome" "visual-studio-code" "iterm2" "orbstack" "maccy" "keka" "squirrel-app")
    
    print_info "The following GUI applications will be installed:"
    for app in "${casks[@]}"; do
        echo "  - $app"
    done
    
    if confirm "Continue installation?" "y"; then
        for app in "${casks[@]}"; do
            if brew list --cask "$app" &>/dev/null; then
                print_info "$app already installed, skipping"
            else
                print_info "Installing $app..."
                brew install --cask "$app" && print_success "$app installed successfully" || print_error "$app installation failed"
            fi
        done
    fi
}

show_manual_apps() {
    print_header "Applications Requiring Manual Installation"
    
    print_info "The following applications need to be downloaded and installed manually:"
    echo "  - WeChat"
    echo "  - Qoder"
    echo "  - RunCat"
    echo "  - Lemon Cleaner"
    echo "  - ClashVerge (Proxy tool)"
    
    press_enter
}

# ==================== Development Environment ====================
configure_fnm() {
    print_header "Configuring fnm (Node.js Version Manager)"
    
    if ! command -v fnm &> /dev/null; then
        print_warning "fnm is not installed. Please install fnm first."
        return 1
    fi
    
    # Check if already configured
    if grep -q 'fnm env' ~/.zshrc 2>/dev/null; then
        print_info "fnm environment already configured"
    else
        if confirm "Add fnm environment to ~/.zshrc?" "y"; then
            echo 'eval "$(fnm env)"' >> ~/.zshrc
            print_success "fnm environment added to ~/.zshrc"
        fi
    fi
    
    # Install Node.js
    if confirm "Install Node.js 24?" "y"; then
        print_info "Installing Node.js 24..."
        fnm install 24
        fnm use 24
        print_success "Node.js $(node -v) installed and activated"
    fi
}

configure_git() {
    print_header "Git Configuration"
    
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$current_name" ]]; then
        print_info "Current Git username: $current_name"
    fi
    if [[ -n "$current_email" ]]; then
        print_info "Current Git email: $current_email"
    fi
    
    if confirm "Configure Git user information?" "y"; then
        echo -n "${CYAN}Enter username: ${NC}"
        read -r git_name
        echo -n "${CYAN}Enter email: ${NC}"
        read -r git_email
        
        if [[ -n "$git_name" ]]; then
            git config --global user.name "$git_name"
            print_success "Git username set: $git_name"
        fi
        if [[ -n "$git_email" ]]; then
            git config --global user.email "$git_email"
            print_success "Git email set: $git_email"
        fi
    fi
}

configure_ssh() {
    print_header "SSH Key Configuration"
    
    if [[ -f ~/.ssh/id_rsa.pub ]]; then
        print_info "SSH key already exists"
        if confirm "View public key?" "y"; then
            echo ""
            cat ~/.ssh/id_rsa.pub
            echo ""
        fi
    else
        if confirm "Generate new SSH key?" "y"; then
            echo -n "${CYAN}Enter email: ${NC}"
            read -r ssh_email
            
            if [[ -n "$ssh_email" ]]; then
                ssh-keygen -t rsa -b 4096 -C "$ssh_email"
                
                # Start SSH agent and add key
                eval "$(ssh-agent -s)"
                ssh-add ~/.ssh/id_rsa
                
                print_success "SSH key generated"
                
                if confirm "Copy public key to clipboard?" "y"; then
                    pbcopy < ~/.ssh/id_rsa.pub
                    print_success "Public key copied to clipboard. Paste it at GitHub Settings → SSH Keys"
                fi
            fi
        fi
    fi
    
    if confirm "Test GitHub SSH connection?" "n"; then
        print_info "Testing GitHub SSH connection..."
        ssh -T git@github.com 2>&1 || true
    fi
}

# ==================== Main Menu ====================
show_menu() {
    clear
    echo ""
    echo "${PURPLE}╔════════════════════════════════════════════════════╗${NC}"
    echo "${PURPLE}║       macOS System Initialization v1.0             ║${NC}"
    echo "${PURPLE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "${CYAN}Please select an option:${NC}"
    echo ""
    echo "  ${GREEN}[0]${NC} 🚀 Configure Everything"
    echo ""
    echo "  ${YELLOW}── Prerequisites ──${NC}"
    echo "  ${GREEN}[1]${NC} Check Network Connection"
    echo "  ${GREEN}[2]${NC} Install Homebrew"
    echo ""
    echo "  ${YELLOW}── System Settings ──${NC}"
    echo "  ${GREEN}[3]${NC} Mouse Settings"
    echo "  ${GREEN}[4]${NC} Keyboard Settings"
    echo "  ${GREEN}[5]${NC} Finder Settings"
    echo "  ${GREEN}[6]${NC} Dock Settings"
    echo "  ${GREEN}[7]${NC} Menu Bar Spacing Settings"
    echo "  ${GREEN}[8]${NC} Other System Settings"
    echo "  ${GREEN}[9]${NC} Spotlight Index Management"
    echo ""
    echo "  ${YELLOW}── Software Installation ──${NC}"
    echo "  ${GREEN}[10]${NC} Install Brew Formulae (Terminal Tools)"
    echo "  ${GREEN}[11]${NC} Install Brew Casks (GUI Applications)"
    echo "  ${GREEN}[12]${NC} View Manual Installation List"
    echo ""
    echo "  ${YELLOW}── Development Environment ──${NC}"
    echo "  ${GREEN}[13]${NC} Configure fnm (Node.js)"
    echo "  ${GREEN}[14]${NC} Configure Git"
    echo "  ${GREEN}[15]${NC} Configure SSH Keys"
    echo ""
    echo "  ${GREEN}[q]${NC} Exit"
    echo ""
    echo -n "${CYAN}Enter your choice: ${NC}"
}

run_all() {
    print_header "Starting Full Configuration"
    
    if ! confirm "Are you sure you want to configure everything?" "n"; then
        return
    fi
    
    check_network
    install_homebrew
    
    # Check if Homebrew installation was successful
    if ! check_homebrew; then
        print_error "Homebrew not installed, cannot continue"
        return 1
    fi
    
    # System settings
    configure_mouse
    configure_keyboard
    configure_finder
    configure_dock
    configure_menubar
    configure_other_system
    
    # Software installation
    install_formulae
    install_casks
    show_manual_apps
    
    # Development environment
    configure_fnm
    configure_git
    configure_ssh
    
    print_header "Configuration Completed!"
    print_warning "Some settings require system restart to take effect"
}

# ==================== Main Program ====================
main() {
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script only supports macOS"
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
            7) configure_menubar; press_enter ;;
            8) configure_other_system; press_enter ;;
            9) configure_spotlight; press_enter ;;
            10) install_formulae; press_enter ;;
            11) install_casks; press_enter ;;
            12) show_manual_apps ;;
            13) configure_fnm; press_enter ;;
            14) configure_git; press_enter ;;
            15) configure_ssh; press_enter ;;
            q|Q) 
                print_info "Goodbye! 👋"
                exit 0 
                ;;
            *)
                print_error "Invalid option, please try again"
                sleep 1
                ;;
        esac
    done
}

# Run main program
main
