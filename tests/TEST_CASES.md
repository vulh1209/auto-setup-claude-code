# Test Cases - Auto Setup Scripts

## Test Environment Requirements

### Windows
- Windows 10/11
- PowerShell 5.1+
- Internet connection
- Administrator privileges (for some installations)

### macOS
- macOS 10.15+ (Catalina or later)
- Terminal access
- Internet connection
- Sudo privileges

### Linux
- Ubuntu 20.04+, Debian 11+, Fedora 38+, or Arch Linux
- Bash shell
- Internet connection
- Sudo privileges

---

## Test Cases

### TC001: Script Launch and Menu Display

| ID | TC001 |
|---|---|
| **Description** | Verify script launches and displays menu correctly |
| **Preconditions** | Clean terminal, script file exists |
| **Steps** | 1. Run the script<br>2. Observe the output |
| **Expected Result** | - ASCII banner displays correctly<br>- Menu options 0-8 are visible<br>- Colors render properly<br>- No errors on startup |

**Platform-specific commands:**
- Windows: `.\setup.ps1` or double-click `setup.bat`
- macOS/Linux: `./setup.sh`

---

### TC002: Check Installed Versions (Option 7)

| ID | TC002 |
|---|---|
| **Description** | Verify version check displays correct information |
| **Preconditions** | Script running |
| **Steps** | 1. Select option 7<br>2. Observe output |
| **Expected Result** | - Shows installed status for Node.js, npm, Git, VS Code, Claude Code<br>- Green [OK] for installed items<br>- Red [ERROR] for missing items<br>- Version numbers displayed correctly |

---

### TC003: Install Node.js Only (Option 2)

| ID | TC003 |
|---|---|
| **Description** | Verify Node.js installation works correctly |
| **Preconditions** | Node.js NOT installed, internet connection |
| **Steps** | 1. Select option 2<br>2. Wait for installation<br>3. Verify with `node --version` |
| **Expected Result** | - Shows "Installing Node.js..."<br>- Installation completes without errors<br>- `node --version` returns valid version<br>- `npm --version` also works |

**Platform-specific behavior:**
- Windows: Uses winget or MSI installer
- macOS: Installs Homebrew first if needed, then Node.js
- Linux: Uses appropriate package manager (apt/dnf/pacman)

---

### TC004: Install Node.js When Already Installed

| ID | TC004 |
|---|---|
| **Description** | Verify script handles existing Node.js installation |
| **Preconditions** | Node.js already installed |
| **Steps** | 1. Select option 2<br>2. Observe output |
| **Expected Result** | - Shows "Node.js is already installed: vX.X.X"<br>- Does NOT reinstall<br>- No errors |

---

### TC005: Install Claude Code CLI (Option 3)

| ID | TC005 |
|---|---|
| **Description** | Verify Claude Code CLI installation |
| **Preconditions** | Node.js/npm installed, Claude Code NOT installed |
| **Steps** | 1. Select option 3<br>2. Wait for installation<br>3. Verify with `claude --version` |
| **Expected Result** | - Shows "Installing Claude Code CLI..."<br>- npm install completes<br>- `claude` command is available<br>- Shows success message |

---

### TC006: Install Claude Code Without Node.js

| ID | TC006 |
|---|---|
| **Description** | Verify error handling when Node.js is missing |
| **Preconditions** | Node.js NOT installed |
| **Steps** | 1. Select option 3 |
| **Expected Result** | - Shows error: "npm is not installed. Please install Node.js first (Option 2)."<br>- Does NOT crash<br>- Returns to menu |

---

### TC007: Install Git (Option 4)

| ID | TC007 |
|---|---|
| **Description** | Verify Git installation |
| **Preconditions** | Git NOT installed |
| **Steps** | 1. Select option 4<br>2. Wait for installation<br>3. Verify with `git --version` |
| **Expected Result** | - Installation completes<br>- `git --version` returns valid version |

---

### TC008: Install VS Code (Option 5)

| ID | TC008 |
|---|---|
| **Description** | Verify VS Code installation |
| **Preconditions** | VS Code NOT installed |
| **Steps** | 1. Select option 5<br>2. Wait for installation<br>3. Verify with `code --version` |
| **Expected Result** | - Installation completes<br>- `code --version` returns valid version (may require terminal restart) |

---

### TC009: Install All - Node.js + Claude Code (Option 1)

| ID | TC009 |
|---|---|
| **Description** | Verify combined installation |
| **Preconditions** | Clean system (Node.js and Claude Code not installed) |
| **Steps** | 1. Select option 1<br>2. Wait for both installations |
| **Expected Result** | - Node.js installs first<br>- Claude Code installs after<br>- Both commands work after completion |

---

### TC010: Full Setup (Option 6)

| ID | TC010 |
|---|---|
| **Description** | Verify complete installation of all tools |
| **Preconditions** | Clean system |
| **Steps** | 1. Select option 6<br>2. Wait for all installations |
| **Expected Result** | - Installs in order: Node.js → Git → VS Code → Claude Code<br>- All tools verified working<br>- Shows "Full installation completed!" |

---

### TC011: Uninstall Claude Code (Option 8)

| ID | TC011 |
|---|---|
| **Description** | Verify Claude Code uninstallation |
| **Preconditions** | Claude Code installed |
| **Steps** | 1. Select option 8<br>2. Verify with `claude --version` |
| **Expected Result** | - Shows "Uninstalling Claude Code CLI..."<br>- Shows success message<br>- `claude` command no longer works |

---

### TC012: Exit Script (Option 0)

| ID | TC012 |
|---|---|
| **Description** | Verify clean exit |
| **Preconditions** | Script running |
| **Steps** | 1. Select option 0 |
| **Expected Result** | - Shows goodbye message<br>- Script terminates<br>- Returns to terminal prompt |

---

### TC013: Invalid Menu Option

| ID | TC013 |
|---|---|
| **Description** | Verify handling of invalid input |
| **Preconditions** | Script running at menu |
| **Steps** | 1. Enter invalid input (e.g., "abc", "99", special characters) |
| **Expected Result** | - Shows warning: "Invalid option. Please enter a number between 0-8."<br>- Does NOT crash<br>- Returns to menu |

---

### TC014: No Internet Connection

| ID | TC014 |
|---|---|
| **Description** | Verify handling when offline |
| **Preconditions** | Disconnect internet |
| **Steps** | 1. Try any install option (1-6) |
| **Expected Result** | - Shows error: "No internet connection detected."<br>- Does NOT attempt download<br>- Returns to menu gracefully |

---

### TC015: PATH Refresh After Installation

| ID | TC015 |
|---|---|
| **Description** | Verify commands are available immediately after install |
| **Preconditions** | Tool not installed |
| **Steps** | 1. Install any tool<br>2. Immediately check version |
| **Expected Result** | - Version check works in same session<br>- No need to restart terminal |

---

## Platform-Specific Test Cases

### TC-WIN-001: Windows - Winget Availability

| ID | TC-WIN-001 |
|---|---|
| **Description** | Verify winget detection on Windows |
| **Preconditions** | Windows 10/11 |
| **Steps** | 1. Run script<br>2. Install any package |
| **Expected Result** | - Uses winget if available<br>- Falls back to alternative if winget missing |

---

### TC-WIN-002: Windows - setup.bat Launcher

| ID | TC-WIN-002 |
|---|---|
| **Description** | Verify batch file launcher works |
| **Preconditions** | Both setup.bat and setup.ps1 exist |
| **Steps** | 1. Double-click setup.bat |
| **Expected Result** | - Opens PowerShell window<br>- Runs setup.ps1<br>- Menu displays correctly |

---

### TC-MAC-001: macOS - Homebrew Installation

| ID | TC-MAC-001 |
|---|---|
| **Description** | Verify Homebrew auto-installation |
| **Preconditions** | macOS without Homebrew |
| **Steps** | 1. Run script<br>2. Select any install option |
| **Expected Result** | - Detects Homebrew missing<br>- Installs Homebrew automatically<br>- Proceeds with package installation |

---

### TC-LIN-001: Linux - Distribution Detection

| ID | TC-LIN-001 |
|---|---|
| **Description** | Verify correct package manager is used |
| **Preconditions** | Any supported Linux distro |
| **Steps** | 1. Run script<br>2. Install any package |
| **Expected Result** | - Ubuntu/Debian: Uses apt<br>- Fedora: Uses dnf<br>- Arch: Uses pacman |

---

## Test Matrix

| Test Case | Windows | macOS | Ubuntu | Fedora | Arch |
|-----------|---------|-------|--------|--------|------|
| TC001 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC002 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC003 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC004 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC005 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC006 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC007 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC008 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC009 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC010 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC011 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC012 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC013 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC014 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC015 | ✓ | ✓ | ✓ | ✓ | ✓ |
| TC-WIN-001 | ✓ | - | - | - | - |
| TC-WIN-002 | ✓ | - | - | - | - |
| TC-MAC-001 | - | ✓ | - | - | - |
| TC-LIN-001 | - | - | ✓ | ✓ | ✓ |

---

## Test Execution Checklist

### Pre-Test Setup
- [ ] Fresh VM or clean environment
- [ ] Internet connection verified
- [ ] Admin/sudo access available
- [ ] Script files copied to test machine

### Post-Test Cleanup
- [ ] Uninstall Claude Code CLI
- [ ] Document any issues found
- [ ] Reset environment if needed
