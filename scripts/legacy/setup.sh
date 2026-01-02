#!/bin/bash
# ============================================================================
# Auto Setup Script for Claude Code CLI - macOS/Linux
# ============================================================================
# This script automatically installs Node.js, Claude Code CLI, Git, VS Code, and Bun
# Run: chmod +x setup.sh && ./setup.sh
# ============================================================================

# Don't use set -e as it causes premature exit

# ============================================================================
# COLORS
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# ============================================================================
# PRINT FUNCTIONS
# ============================================================================
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# ============================================================================
# BANNER
# ============================================================================
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"

   _____ _                 _        _____          _
  / ____| |               | |      / ____|        | |
 | |    | | __ _ _   _  __| | ___ | |     ___   __| | ___
 | |    | |/ _` | | | |/ _` |/ _ \| |    / _ \ / _` |/ _ \
 | |____| | (_| | |_| | (_| |  __/| |___| (_) | (_| |  __/
  \_____|_|\__,_|\__,_|\__,_|\___| \_____\___/ \__,_|\___|

         Auto Setup Script for Claude Code CLI
         macOS/Linux Edition v1.0

EOF
    echo -e "${NC}"
}

# ============================================================================
# MENU
# ============================================================================
show_menu() {
    echo -e "${GRAY}============================================${NC}"
    echo -e "${WHITE}  SELECT AN OPTION:${NC}"
    echo -e "${GRAY}============================================${NC}"
    echo ""
    echo -e "  ${WHITE}[1] Install All (Node.js + Claude Code)${NC}"
    echo -e "  ${WHITE}[2] Install Node.js only${NC}"
    echo -e "  ${WHITE}[3] Install Claude Code CLI only${NC}"
    echo -e "  ${WHITE}[4] Install Git${NC}"
    echo -e "  ${WHITE}[5] Install VS Code${NC}"
    echo -e "  ${WHITE}[6] Install Bun (fast JS runtime)${NC}"
    echo -e "  ${YELLOW}[7] Install Everything (Full Setup)${NC}"
    echo -e "  ${WHITE}[8] Check installed versions${NC}"
    echo -e "  ${WHITE}[9] Uninstall Claude Code CLI${NC}"
    echo ""
    echo -e "  ${GRAY}[0] Exit${NC}"
    echo ""
    echo -e "${GRAY}============================================${NC}"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/fedora-release ]]; then
        echo "fedora"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

command_exists() {
    command -v "$1" &> /dev/null
}

check_internet() {
    if ping -c 1 google.com &> /dev/null; then
        return 0
    else
        return 1
    fi
}

reload_shell() {
    # Don't source shell configs as they may produce output
    # Just add common paths directly
    export PATH="/usr/local/bin:$HOME/.npm-global/bin:$PATH"

    # Add Homebrew paths for macOS
    if [[ -d /opt/homebrew/bin ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    elif [[ -d /usr/local/bin ]]; then
        export PATH="/usr/local/bin:$PATH"
    fi

    # Add Node.js global bin
    if [[ -d /usr/local/lib/node_modules/.bin ]]; then
        export PATH="/usr/local/lib/node_modules/.bin:$PATH"
    fi
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================
install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        print_success "Homebrew installed successfully!"
    else
        print_success "Homebrew is already installed"
    fi
}

install_nodejs() {
    print_info "Checking Node.js installation..."

    if command_exists node; then
        local version=$(node --version)
        print_success "Node.js is already installed: $version"
        return 0
    fi

    print_info "Installing Node.js..."
    local os=$(detect_os)

    case $os in
        macos)
            install_homebrew
            print_info "Installing Node.js via Homebrew..."
            brew install node
            ;;
        debian)
            print_info "Installing Node.js via NodeSource..."
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        fedora|rhel)
            print_info "Installing Node.js via dnf..."
            sudo dnf install -y nodejs npm
            ;;
        arch)
            print_info "Installing Node.js via pacman..."
            sudo pacman -Sy --noconfirm nodejs npm
            ;;
        *)
            print_error "Unsupported OS. Please install Node.js manually from https://nodejs.org"
            return 1
            ;;
    esac

    reload_shell

    if command_exists node; then
        local version=$(node --version)
        print_success "Node.js installed successfully: $version"
        return 0
    else
        print_error "Node.js installation failed"
        return 1
    fi
}

install_git() {
    print_info "Checking Git installation..."

    if command_exists git; then
        local version=$(git --version)
        print_success "Git is already installed: $version"
        return 0
    fi

    print_info "Installing Git..."
    local os=$(detect_os)

    case $os in
        macos)
            install_homebrew
            brew install git
            ;;
        debian)
            sudo apt-get update
            sudo apt-get install -y git
            ;;
        fedora|rhel)
            sudo dnf install -y git
            ;;
        arch)
            sudo pacman -Sy --noconfirm git
            ;;
        *)
            print_error "Unsupported OS. Please install Git manually."
            return 1
            ;;
    esac

    if command_exists git; then
        local version=$(git --version)
        print_success "Git installed successfully: $version"
        return 0
    else
        print_error "Git installation failed"
        return 1
    fi
}

install_vscode() {
    print_info "Checking VS Code installation..."

    if command_exists code; then
        print_success "VS Code is already installed"
        return 0
    fi

    print_info "Installing VS Code..."
    local os=$(detect_os)

    case $os in
        macos)
            install_homebrew
            brew install --cask visual-studio-code
            ;;
        debian)
            print_info "Downloading VS Code .deb package..."
            wget -qO /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
            sudo dpkg -i /tmp/vscode.deb || sudo apt-get install -f -y
            rm -f /tmp/vscode.deb
            ;;
        fedora|rhel)
            print_info "Downloading VS Code .rpm package..."
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            sudo dnf install -y code
            ;;
        arch)
            print_info "Installing VS Code from AUR..."
            if command_exists yay; then
                yay -S --noconfirm visual-studio-code-bin
            elif command_exists paru; then
                paru -S --noconfirm visual-studio-code-bin
            else
                print_warning "No AUR helper found. Installing code from official repos..."
                sudo pacman -Sy --noconfirm code
            fi
            ;;
        *)
            print_error "Unsupported OS. Please install VS Code manually from https://code.visualstudio.com"
            return 1
            ;;
    esac

    if command_exists code; then
        print_success "VS Code installed successfully"
        return 0
    else
        print_warning "VS Code installed but 'code' command may not be available yet."
        print_info "Try reopening your terminal."
        return 0
    fi
}

install_claude_code() {
    print_info "Checking Claude Code CLI installation..."

    if command_exists claude; then
        local version=$(claude --version 2>/dev/null || echo "installed")
        print_success "Claude Code CLI is already installed: $version"
        return 0
    fi

    if ! command_exists npm; then
        print_error "npm is not installed. Please install Node.js first (Option 2)."
        return 1
    fi

    print_info "Installing Claude Code CLI..."

    # Try to install globally, use sudo if needed
    if npm install -g @anthropic-ai/claude-code 2>/dev/null; then
        print_success "Claude Code CLI installed successfully!"
    else
        print_warning "Global install failed, trying with sudo..."
        sudo npm install -g @anthropic-ai/claude-code
    fi

    reload_shell

    if command_exists claude; then
        print_success "Claude Code CLI installed successfully!"
        print_info "Run 'claude' to start using Claude Code."
        return 0
    else
        print_warning "Installation completed. Try reopening your terminal."
        print_info "Or run: npm list -g @anthropic-ai/claude-code"
        return 0
    fi
}

install_bun() {
    print_info "Checking Bun installation..."

    if command_exists bun; then
        local version=$(bun --version)
        print_success "Bun is already installed: v$version"
        return 0
    fi

    print_info "Installing Bun..."

    # Use official Bun installer (works on macOS and Linux)
    if curl -fsSL https://bun.sh/install | bash; then
        # Add Bun to PATH for current session
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"

        if command_exists bun; then
            local version=$(bun --version)
            print_success "Bun installed successfully: v$version"
            print_info "Run 'source ~/.bashrc' or restart terminal to use bun"
            return 0
        else
            print_warning "Bun installed. Please restart your terminal to use 'bun' command."
            return 0
        fi
    else
        print_error "Failed to install Bun"
        print_info "Try manually: curl -fsSL https://bun.sh/install | bash"
        return 1
    fi
}

uninstall_claude_code() {
    print_info "Uninstalling Claude Code CLI..."

    if ! command_exists npm; then
        print_error "npm is not installed."
        return 1
    fi

    if npm uninstall -g @anthropic-ai/claude-code 2>/dev/null; then
        print_success "Claude Code CLI uninstalled successfully!"
    else
        sudo npm uninstall -g @anthropic-ai/claude-code
        print_success "Claude Code CLI uninstalled successfully!"
    fi

    return 0
}

# ============================================================================
# VERSION CHECK
# ============================================================================
show_versions() {
    echo ""
    echo -e "${GRAY}============================================${NC}"
    echo -e "${WHITE}  INSTALLED VERSIONS:${NC}"
    echo -e "${GRAY}============================================${NC}"
    echo ""

    # Node.js
    if command_exists node; then
        local node_version=$(node --version)
        print_success "Node.js: $node_version"
    else
        print_error "Node.js: Not installed"
    fi

    # npm
    if command_exists npm; then
        local npm_version=$(npm --version)
        print_success "npm: v$npm_version"
    else
        print_error "npm: Not installed"
    fi

    # Git
    if command_exists git; then
        local git_version=$(git --version)
        print_success "Git: $git_version"
    else
        print_error "Git: Not installed"
    fi

    # VS Code
    if command_exists code; then
        local code_version=$(code --version 2>/dev/null | head -1 || echo "installed")
        print_success "VS Code: v$code_version"
    else
        print_error "VS Code: Not installed"
    fi

    # Bun
    if command_exists bun; then
        local bun_version=$(bun --version)
        print_success "Bun: v$bun_version"
    else
        print_error "Bun: Not installed"
    fi

    # Claude Code
    if command_exists claude; then
        local claude_version=$(claude --version 2>/dev/null || echo "installed")
        print_success "Claude Code: $claude_version"
    else
        print_error "Claude Code: Not installed"
    fi

    echo ""
}

# ============================================================================
# MAIN MENU LOOP
# ============================================================================
main_menu() {
    while true; do
        show_banner
        show_menu

        echo -n "Enter your choice [0-9]: "
        read -r choice
        echo ""

        case $choice in
            1)
                print_info "Starting installation of Node.js + Claude Code..."
                if ! check_internet; then
                    print_error "No internet connection detected. Please check your connection."
                else
                    install_nodejs
                    sleep 2
                    reload_shell
                    install_claude_code
                fi
                ;;
            2)
                if ! check_internet; then
                    print_error "No internet connection detected."
                else
                    install_nodejs
                fi
                ;;
            3)
                if ! check_internet; then
                    print_error "No internet connection detected."
                else
                    install_claude_code
                fi
                ;;
            4)
                if ! check_internet; then
                    print_error "No internet connection detected."
                else
                    install_git
                fi
                ;;
            5)
                if ! check_internet; then
                    print_error "No internet connection detected."
                else
                    install_vscode
                fi
                ;;
            6)
                if ! check_internet; then
                    print_error "No internet connection detected."
                else
                    install_bun
                fi
                ;;
            7)
                print_info "Starting FULL installation..."
                if ! check_internet; then
                    print_error "No internet connection detected."
                else
                    install_nodejs
                    sleep 2
                    reload_shell
                    install_git
                    sleep 2
                    install_vscode
                    sleep 2
                    install_bun
                    sleep 2
                    install_claude_code
                    echo ""
                    print_success "Full installation completed!"
                fi
                ;;
            8)
                show_versions
                ;;
            9)
                uninstall_claude_code
                ;;
            0)
                echo ""
                print_info "Goodbye! Happy coding with Claude Code!"
                echo ""
                exit 0
                ;;
            *)
                print_warning "Invalid option. Please enter a number between 0-9."
                ;;
        esac

        echo ""
        echo -n "Press Enter to continue..."
        read -r
    done
}

# ============================================================================
# COMMAND LINE ARGUMENTS PARSER
# ============================================================================
show_usage() {
    echo ""
    echo "Usage: ./setup.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all         Install everything (Node.js, Claude Code, Git, VS Code, Bun)"
    echo "  --node        Install Node.js only"
    echo "  --claude      Install Claude Code CLI only"
    echo "  --git         Install Git"
    echo "  --vscode      Install VS Code"
    echo "  --bun         Install Bun"
    echo "  --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  curl -fsSL URL/setup.sh | bash                    # Node.js + Claude Code (default)"
    echo "  curl -fsSL URL/setup.sh | bash -s -- --all        # Install everything"
    echo "  curl -fsSL URL/setup.sh | bash -s -- --git --bun  # Install Git and Bun"
    echo ""
}

run_non_interactive() {
    local install_node=false
    local install_claude=false
    local install_git=false
    local install_vscode=false
    local install_bun=false
    local has_args=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        has_args=true
        case $1 in
            --all)
                install_node=true
                install_claude=true
                install_git=true
                install_vscode=true
                install_bun=true
                shift
                ;;
            --node)
                install_node=true
                shift
                ;;
            --claude)
                install_claude=true
                shift
                ;;
            --git)
                install_git=true
                shift
                ;;
            --vscode)
                install_vscode=true
                shift
                ;;
            --bun)
                install_bun=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_warning "Unknown option: $1"
                shift
                ;;
        esac
    done

    # Default: install Node.js + Claude Code if no args
    if [[ "$has_args" == "false" ]]; then
        install_node=true
        install_claude=true
    fi

    show_banner
    print_info "Running in non-interactive mode..."
    echo ""

    if ! check_internet; then
        print_error "No internet connection detected."
        exit 1
    fi

    # Install selected components
    if [[ "$install_node" == "true" ]]; then
        install_nodejs
        sleep 1
        reload_shell
    fi

    if [[ "$install_git" == "true" ]]; then
        install_git
        sleep 1
    fi

    if [[ "$install_vscode" == "true" ]]; then
        install_vscode
        sleep 1
    fi

    if [[ "$install_bun" == "true" ]]; then
        install_bun
        sleep 1
    fi

    if [[ "$install_claude" == "true" ]]; then
        install_claude_code
    fi

    echo ""
    print_success "Installation completed!"
    print_info "For interactive menu, download and run: ./setup.sh"
}

# ============================================================================
# ENTRY POINT
# ============================================================================

# Check if running interactively or via pipe
if [ -t 0 ]; then
    # Interactive mode - check for --help first
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_usage
        exit 0
    fi
    # Show menu
    main_menu
else
    # Piped mode (curl | bash) - run with arguments
    run_non_interactive "$@"
fi
