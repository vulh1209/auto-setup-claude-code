# Auto Setup Claude Code CLI

One-click installer for Claude Code CLI and development tools across Windows, macOS, and Linux.

## Quick Install (One-liner)

### Default (Node.js + Claude Code)

**Windows (PowerShell)**
```powershell
irm https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.ps1 | iex
```

**macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.sh | bash
```

### Install Everything (Full Setup)

**Windows (PowerShell)**
```powershell
iex "& { $(irm https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.ps1) } -All"
```

**macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.sh | bash -s -- --all
```

### Verify & Fix Issues (Windows only)

**Windows (PowerShell)** - Check system and auto-fix common issues:
```powershell
iex "& { $(irm https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.ps1) } -Verify"
```

This will:
- Check PowerShell Execution Policy and fix if needed
- Verify Node.js, npm, and Claude Code installation
- Auto-fix PATH issues
- Offer to install missing components

### Custom Installation

**macOS / Linux** - Select specific tools:
```bash
# Install Git and Bun only
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.sh | bash -s -- --git --bun

# Install Node.js, Claude Code, and VS Code
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.sh | bash -s -- --node --claude --vscode
```

**Available Options:**
| Option | Description |
|--------|-------------|
| `--all` / `-All` | Install everything |
| `--node` / `-Node` | Install Node.js |
| `--claude` / `-Claude` | Install Claude Code CLI |
| `--git` / `-Git` | Install Git |
| `--vscode` / `-VSCode` | Install VS Code |
| `--bun` / `-Bun` | Install Bun |
| `-Verify` | Verify system and fix common issues (Windows only) |

## What Gets Installed

| Tool | Description |
|------|-------------|
| **Node.js** | JavaScript runtime (latest stable) |
| **npm** | Node package manager |
| **Claude Code CLI** | Anthropic's official CLI for Claude |
| **Git** | Version control system |
| **VS Code** | Code editor |
| **Bun** | Fast JavaScript runtime & toolkit |

## Menu Options

```
[1] Install All (Node.js + Claude Code)
[2] Install Node.js only
[3] Install Claude Code CLI only
[4] Install Git
[5] Install VS Code
[6] Install Bun (fast JS runtime)
[7] Install Everything (Full Setup)
[8] Check installed versions
[9] Uninstall Claude Code CLI
[V] Verify & Fix Common Issues
[0] Exit
```

## Manual Installation

### Windows
```powershell
# Option 1: Run directly
.\setup.ps1

# Option 2: Double-click
setup.bat
```

### macOS / Linux
```bash
chmod +x setup.sh
./setup.sh
```

## Supported Platforms

| Platform | Package Manager |
|----------|-----------------|
| Windows 10/11 | winget |
| macOS | Homebrew |
| Ubuntu/Debian | apt |
| Fedora/RHEL | dnf |
| Arch Linux | pacman |

## Requirements

- **Windows**: PowerShell 5.1+
- **macOS**: macOS 10.15+ (Catalina or later)
- **Linux**: Bash shell
- **All**: Internet connection

## License

MIT License
