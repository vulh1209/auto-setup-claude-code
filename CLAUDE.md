# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Desktop installer app for Claude Code CLI and development tools. Built with Tauri 2.0 (Rust backend) + React + TypeScript.

**Output formats:**
- Windows: `.exe` (NSIS installer)
- macOS: `.dmg` / `.app`
- Linux: `.AppImage` / `.deb`

## Tech Stack

- **Frontend**: React 18 + TypeScript + Tailwind CSS
- **Backend**: Rust + Tauri 2.0
- **Build**: Vite + Tauri CLI
- **CI/CD**: GitHub Actions (auto-build on tag push)

## Project Structure

```
auto-setup-claude-code/
├── src/                          # Frontend (React)
│   ├── App.tsx                   # Main component
│   ├── components/
│   │   ├── ToolSelector.tsx      # Checkboxes for tool selection
│   │   ├── ProgressBar.tsx       # Installation progress
│   │   └── StatusLog.tsx         # Log output display
│   ├── hooks/
│   │   └── useInstaller.ts       # Installation logic hook
│   └── styles/
│       └── globals.css           # Tailwind styles
├── src-tauri/                    # Backend (Rust)
│   ├── Cargo.toml                # Rust dependencies
│   ├── tauri.conf.json           # Tauri configuration
│   ├── capabilities/             # Permission configs
│   ├── icons/                    # App icons (all sizes)
│   └── src/
│       ├── main.rs               # Entry point
│       ├── lib.rs                # Tauri setup
│       └── commands/
│           ├── mod.rs            # Module exports
│           ├── detect.rs         # OS & tool detection
│           └── install.rs        # Installation commands
├── scripts/legacy/               # Original CLI scripts (preserved)
│   ├── setup.ps1                 # Windows PowerShell
│   ├── setup.sh                  # macOS/Linux Bash
│   └── *.bat                     # Windows batch launchers
├── .github/workflows/
│   └── release.yml               # Auto-build on tag push
├── package.json                  # Frontend dependencies
├── vite.config.ts                # Vite bundler config
└── tailwind.config.js            # Tailwind config
```

## Development

### Prerequisites

```bash
# Rust (1.70+)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# macOS: Xcode CLI tools
xcode-select --install

# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev
```

### Commands

```bash
# Install dependencies
npm install

# Development mode (hot reload)
npm run tauri dev

# Production build
npm run tauri build
```

### Build Output

Production builds are in `src-tauri/target/release/bundle/`:
- `macos/Claude Code Installer.app`
- `dmg/Claude Code Installer_*.dmg`
- `nsis/*.exe` (Windows)
- `appimage/*.AppImage` (Linux)
- `deb/*.deb` (Linux)

## Architecture

### Frontend (React)

| Component | Purpose |
|-----------|---------|
| `App.tsx` | Main app, state management, layout |
| `ToolSelector.tsx` | Checkboxes with installed status |
| `ProgressBar.tsx` | Installation progress indicator |
| `StatusLog.tsx` | Real-time log output |
| `useInstaller.ts` | Hook for calling Tauri commands |

### Backend (Rust)

| Module | Purpose |
|--------|---------|
| `detect.rs` | OS detection, package manager detection, tool version checks |
| `install.rs` | Installation commands for each tool (Node.js, Git, VS Code, Bun, Claude Code) |

### Tauri Commands (IPC)

```typescript
// Frontend calls
invoke("get_system_info")      // Get OS, arch, installed tools
invoke("install_nodejs")       // Install Node.js
invoke("install_claude_code")  // Install Claude Code CLI
invoke("install_git")          // Install Git
invoke("install_vscode")       // Install VS Code
invoke("install_bun")          // Install Bun
```

## Releasing

1. Update version in `package.json` and `src-tauri/tauri.conf.json`
2. Commit changes
3. Create and push tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
4. GitHub Actions will build for all platforms and create a draft release

## Supported Platforms

| Platform | Package Manager | Notes |
|----------|-----------------|-------|
| Windows 10/11 | winget | Falls back to direct download |
| macOS 10.15+ | Homebrew | Auto-installs Homebrew if needed |
| Ubuntu/Debian | apt | Uses NodeSource for Node.js |
| Fedora/RHEL | dnf | |
| Arch Linux | pacman | Uses AUR for VS Code |

## Legacy CLI Scripts

Original CLI scripts are preserved in `scripts/legacy/` for:
- Users who prefer command-line installation
- CI/CD automation
- Reference when maintaining Tauri commands

### Quick CLI Install

**Windows:**
```powershell
irm https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/scripts/legacy/setup.ps1 | iex
```

**macOS/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/scripts/legacy/setup.sh | bash
```
