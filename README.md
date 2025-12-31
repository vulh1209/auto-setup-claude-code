# Auto Setup Claude Code CLI

One-click installer for Claude Code CLI and development tools across Windows, macOS, and Linux.

## Quick Install (One-liner)

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.ps1 | iex
```

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.sh | bash
```

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
