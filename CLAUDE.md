# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Auto-setup scripts for installing Claude Code CLI and its prerequisites across different platforms. The scripts provide an interactive menu-driven installer for Node.js, Claude Code CLI, Git, VS Code, and Bun.

## Scripts

- **setup.ps1** - Windows PowerShell installer (requires PowerShell 5.1+)
- **setup.sh** - macOS/Linux Bash installer
- **setup.bat** - Windows batch launcher (double-click to run setup.ps1)

## Running the Scripts

### Windows
```powershell
.\setup.ps1
# Or double-click setup.bat
```

### macOS/Linux
```bash
chmod +x setup.sh
./setup.sh
```

## Architecture

Both scripts follow the same structure:
1. **Color/Print Functions** - Consistent output formatting with color-coded status messages
2. **Utility Functions** - OS detection, command existence checks, internet connectivity, PATH refresh
3. **Installation Functions** - Each tool (Node.js, Git, VS Code, Bun, Claude Code) has a dedicated install function
4. **Menu System** - Interactive menu loop for user selection

### Key Behaviors
- Scripts check for existing installations before attempting to install
- Windows uses winget as primary installer with MSI fallback for Node.js
- macOS/Linux uses Homebrew on macOS, apt/dnf/pacman on respective Linux distros
- Claude Code is installed globally via `npm install -g @anthropic-ai/claude-code`
- PATH is refreshed after each installation to make commands immediately available

## Menu Options (same for both scripts)
1. Install All (Node.js + Claude Code)
2. Install Node.js only
3. Install Claude Code CLI only
4. Install Git
5. Install VS Code
6. Install Bun (fast JS runtime)
7. Install Everything (Full Setup)
8. Check installed versions
9. Uninstall Claude Code CLI
0. Exit

## Supported Platforms

### Windows
- Windows 10/11 with PowerShell 5.1+
- Uses `winget` as primary package manager
- Falls back to direct MSI download for Node.js if winget unavailable

### macOS
- Requires/installs Homebrew automatically
- Uses `brew install` for all packages

### Linux
- **Debian/Ubuntu**: Uses apt + NodeSource repository
- **Fedora/RHEL**: Uses dnf
- **Arch Linux**: Uses pacman (+ AUR for VS Code)

## Testing

### Unit Tests
Run automated tests to verify script integrity and environment:

**Windows:**
```powershell
.\tests\test_setup.ps1
```

**macOS/Linux:**
```bash
chmod +x tests/test_setup.sh
./tests/test_setup.sh
```

Tests include:
- Script file existence and syntax validation
- Required functions verification
- OS/package manager detection
- Tool installation status (Node.js, npm, Git, VS Code, Bun, Claude Code)
- Internet connectivity check

### Manual Test Cases
Located in `tests/TEST_CASES.md`:
- 15 common test cases for all platforms
- Platform-specific test cases (Windows, macOS, Linux)
- Test matrix for cross-platform verification
