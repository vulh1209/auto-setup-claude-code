# Claude Code Installer

Desktop installer for Claude Code CLI and development tools. Download, double-click, install.

![Claude Code Installer](https://img.shields.io/badge/version-1.0.0-blue) ![Platforms](https://img.shields.io/badge/platforms-Windows%20|%20macOS%20|%20Linux-green)

## Download

### Latest Release

| Platform | Download | Architecture |
|----------|----------|--------------|
| **Windows** | [Claude Code Installer.exe](https://github.com/vulh1209/auto-setup-claude-code/releases/latest/download/Claude.Code.Installer_1.0.0_x64-setup.exe) | x64 |
| **macOS (Apple Silicon)** | [Claude Code Installer.dmg](https://github.com/vulh1209/auto-setup-claude-code/releases/latest/download/Claude.Code.Installer_1.0.0_aarch64.dmg) | ARM64 |
| **macOS (Intel)** | [Claude Code Installer.dmg](https://github.com/vulh1209/auto-setup-claude-code/releases/latest/download/Claude.Code.Installer_1.0.0_x64.dmg) | x64 |
| **Linux** | [Claude Code Installer.AppImage](https://github.com/vulh1209/auto-setup-claude-code/releases/latest/download/claude-code-installer_1.0.0_amd64.AppImage) | x64 |
| **Linux (Debian)** | [claude-code-installer.deb](https://github.com/vulh1209/auto-setup-claude-code/releases/latest/download/claude-code-installer_1.0.0_amd64.deb) | x64 |

> **Note**: Download links will be available after the first release. To create a release, push a tag: `git tag v1.0.0 && git push origin v1.0.0`

## Features

- **Simple GUI** - Just check the tools you want and click Install
- **Cross-platform** - Works on Windows, macOS, and Linux
- **Lightweight** - Only ~2MB download (thanks to Tauri)
- **Auto-detect** - Shows which tools are already installed

## What You Can Install

| Tool | Description |
|------|-------------|
| **Node.js** | JavaScript runtime (required for Claude Code) |
| **Claude Code CLI** | Anthropic's official AI coding assistant |
| **Git** | Version control system |
| **VS Code** | Code editor |
| **Bun** | Fast JavaScript runtime & toolkit |

## Screenshots

```
┌─────────────────────────────────────────────────┐
│  Claude Code Installer                          │
│  macOS • arm64 • brew                           │
├─────────────────────────────────────────────────┤
│                                                 │
│   Select tools to install:                      │
│                                                 │
│   [x] Node.js        (Required for Claude Code) │
│   [x] Claude Code CLI (AI coding assistant)     │
│   [ ] Git            (Version control)          │
│   [ ] VS Code        (Code editor)              │
│   [ ] Bun            (Fast JS runtime)          │
│                                                 │
│              [ Install Selected (2) ]           │
│                                                 │
└─────────────────────────────────────────────────┘
```

## CLI Scripts (Legacy)

If you prefer command-line installation, the original scripts are still available in `scripts/legacy/`:

### Quick Install (One-liner)

**Windows (PowerShell)**
```powershell
irm https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/scripts/legacy/setup.ps1 | iex
```

**macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/scripts/legacy/setup.sh | bash
```

## Building from Source

### Prerequisites

1. **Rust** (1.70+)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Node.js** (18+)

3. **Platform-specific dependencies**:
   - **macOS**: `xcode-select --install`
   - **Ubuntu/Debian**: `sudo apt install libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev`
   - **Fedora**: `sudo dnf install webkit2gtk4.1-devel libappindicator-gtk3-devel librsvg2-devel`

### Build

```bash
# Install dependencies
npm install

# Development mode
npm run tauri dev

# Production build
npm run tauri build
```

Output files will be in `src-tauri/target/release/bundle/`.

## Supported Platforms

| Platform | Package Manager |
|----------|-----------------|
| Windows 10/11 | winget |
| macOS 10.15+ | Homebrew |
| Ubuntu/Debian | apt |
| Fedora/RHEL | dnf |
| Arch Linux | pacman |

## Tech Stack

- **Frontend**: React + TypeScript + Tailwind CSS
- **Backend**: Rust + Tauri 2.0
- **Build**: Vite + Tauri CLI

## License

MIT License
