# ============================================================================
# Auto Setup Script for Claude Code CLI - Windows PowerShell
# ============================================================================
# This script automatically installs Node.js, Claude Code CLI, Git, VS Code, and Bun
# Run: .\setup.ps1 or double-click setup.bat
# ============================================================================

# Requires PowerShell 5.1 or higher
#Requires -Version 5.1

# ============================================================================
# CONFIGURATION
# ============================================================================
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ============================================================================
# COLOR FUNCTIONS
# ============================================================================
function Write-Color {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

function Write-Success { param([string]$Text) Write-Color "[OK] $Text" "Green" }
function Write-Error { param([string]$Text) Write-Color "[ERROR] $Text" "Red" }
function Write-Warning { param([string]$Text) Write-Color "[WARN] $Text" "Yellow" }
function Write-Info { param([string]$Text) Write-Color "[INFO] $Text" "Cyan" }

# ============================================================================
# BANNER
# ============================================================================
function Show-Banner {
    Clear-Host
    Write-Color @"

   _____ _                 _        _____          _
  / ____| |               | |      / ____|        | |
 | |    | | __ _ _   _  __| | ___ | |     ___   __| | ___
 | |    | |/ _`` | | | |/ _`` |/ _ \| |    / _ \ / _`` |/ _ \
 | |____| | (_| | |_| | (_| |  __/| |___| (_) | (_| |  __/
  \_____|_|\__,_|\__,_|\__,_|\___| \_____\___/ \__,_|\___|

         Auto Setup Script for Claude Code CLI
         Windows Edition v1.0

"@ "Cyan"
}

# ============================================================================
# MENU
# ============================================================================
function Show-Menu {
    Write-Color "============================================" "DarkGray"
    Write-Color "  SELECT AN OPTION:" "White"
    Write-Color "============================================" "DarkGray"
    Write-Color ""
    Write-Color "  [1] Install All (Node.js + Claude Code)" "White"
    Write-Color "  [2] Install Node.js only" "White"
    Write-Color "  [3] Install Claude Code CLI only" "White"
    Write-Color "  [4] Install Git" "White"
    Write-Color "  [5] Install VS Code" "White"
    Write-Color "  [6] Install Bun (fast JS runtime)" "White"
    Write-Color "  [7] Install Everything (Full Setup)" "Yellow"
    Write-Color "  [8] Check installed versions" "White"
    Write-Color "  [9] Uninstall Claude Code CLI" "White"
    Write-Color "  [V] Verify & Fix Common Issues" "Magenta"
    Write-Color ""
    Write-Color "  [0] Exit" "DarkGray"
    Write-Color ""
    Write-Color "============================================" "DarkGray"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
function Set-ExecutionPolicyIfNeeded {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "Undefined") {
        Write-Info "Setting PowerShell Execution Policy to RemoteSigned..."
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Success "Execution Policy set to RemoteSigned for current user."
        }
        catch {
            Write-Warning "Could not set Execution Policy automatically."
            Write-Info "Please run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
        }
    }
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CommandExists {
    param([string]$Command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
}

function Test-InternetConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5
        return $true
    }
    catch {
        return $false
    }
}

function Refresh-EnvironmentPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Request-AdminRestart {
    if (-not (Test-Administrator)) {
        Write-Warning "This operation requires Administrator privileges."
        Write-Info "Restarting script as Administrator..."
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================
function Install-NodeJS {
    Write-Info "Checking Node.js installation..."

    if (Test-CommandExists "node") {
        $version = node --version
        Write-Success "Node.js is already installed: $version"
        return $true
    }

    Write-Info "Installing Node.js..."

    # Check if winget is available
    if (Test-CommandExists "winget") {
        Write-Info "Using winget to install Node.js..."
        try {
            winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements
            Refresh-EnvironmentPath

            if (Test-CommandExists "node") {
                $version = node --version
                Write-Success "Node.js installed successfully: $version"
                return $true
            }
        }
        catch {
            Write-Warning "winget installation failed, trying alternative method..."
        }
    }

    # Fallback: Download and install manually
    Write-Info "Downloading Node.js installer..."
    $nodeUrl = "https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi"
    $installerPath = "$env:TEMP\node-installer.msi"

    try {
        Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath -UseBasicParsing
        Write-Info "Running Node.js installer..."
        Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /qn" -Wait -NoNewWindow
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        Refresh-EnvironmentPath

        if (Test-CommandExists "node") {
            $version = node --version
            Write-Success "Node.js installed successfully: $version"
            return $true
        }
        else {
            Write-Error "Node.js installation failed. Please install manually from https://nodejs.org"
            return $false
        }
    }
    catch {
        Write-Error "Failed to download/install Node.js: $_"
        return $false
    }
}

function Install-Git {
    Write-Info "Checking Git installation..."

    if (Test-CommandExists "git") {
        $version = git --version
        Write-Success "Git is already installed: $version"
        return $true
    }

    Write-Info "Installing Git..."

    if (Test-CommandExists "winget") {
        Write-Info "Using winget to install Git..."
        try {
            winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
            Refresh-EnvironmentPath

            if (Test-CommandExists "git") {
                $version = git --version
                Write-Success "Git installed successfully: $version"
                return $true
            }
        }
        catch {
            Write-Warning "winget installation failed..."
        }
    }

    Write-Error "Could not install Git automatically. Please install from https://git-scm.com"
    return $false
}

function Install-VSCode {
    Write-Info "Checking VS Code installation..."

    if (Test-CommandExists "code") {
        Write-Success "VS Code is already installed"
        return $true
    }

    Write-Info "Installing VS Code..."

    if (Test-CommandExists "winget") {
        Write-Info "Using winget to install VS Code..."
        try {
            winget install Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements
            Refresh-EnvironmentPath

            if (Test-CommandExists "code") {
                Write-Success "VS Code installed successfully"
                return $true
            }
        }
        catch {
            Write-Warning "winget installation failed..."
        }
    }

    Write-Error "Could not install VS Code automatically. Please install from https://code.visualstudio.com"
    return $false
}

function Install-ClaudeCode {
    Write-Info "Checking Claude Code CLI installation..."

    if (Test-CommandExists "claude") {
        $version = claude --version 2>$null
        Write-Success "Claude Code CLI is already installed: $version"
        return $true
    }

    # Check if Node.js/npm is installed
    if (-not (Test-CommandExists "npm")) {
        Write-Error "npm is not installed. Please install Node.js first (Option 2)."
        return $false
    }

    Write-Info "Installing Claude Code CLI..."

    # Fix Execution Policy to allow npm scripts to run
    Set-ExecutionPolicyIfNeeded

    try {
        npm install -g @anthropic-ai/claude-code
        Refresh-EnvironmentPath

        if (Test-CommandExists "claude") {
            Write-Success "Claude Code CLI installed successfully!"
            Write-Info "Run 'claude' to start using Claude Code."
            return $true
        }
        else {
            Write-Warning "Installation completed but 'claude' command not found in PATH."
            Write-Info "Attempting to fix PATH automatically..."

            # Auto-fix PATH for Claude Code
            $npmPrefix = npm config get prefix 2>$null
            if ($npmPrefix) {
                $possibleClaudePaths = @(
                    "$npmPrefix",
                    "$npmPrefix\node_modules\.bin",
                    "$env:APPDATA\npm",
                    "$env:APPDATA\npm\node_modules\.bin"
                )

                foreach ($claudePath in $possibleClaudePaths) {
                    $claudeExe = Join-Path $claudePath "claude.cmd"
                    $claudePs1 = Join-Path $claudePath "claude.ps1"
                    if ((Test-Path $claudeExe) -or (Test-Path $claudePs1)) {
                        Write-Info "Found Claude at: $claudePath"
                        if (-not ($env:Path -like "*$claudePath*")) {
                            $env:Path = "$claudePath;$env:Path"
                            [System.Environment]::SetEnvironmentVariable("Path", "$claudePath;" + [System.Environment]::GetEnvironmentVariable("Path", "User"), "User")
                            Write-Success "PATH updated successfully!"
                        }
                        break
                    }
                }

                # Refresh and verify
                Refresh-EnvironmentPath
                if (Test-CommandExists "claude") {
                    Write-Success "Claude Code CLI installed and PATH configured!"
                    Write-Info "Run 'claude' to start using Claude Code."
                    return $true
                }
            }

            Write-Warning "PATH may need manual update. Please restart your terminal."
            Write-Info "Or run: iex `"& { `$(irm https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.ps1) } -Verify`""
            return $true
        }
    }
    catch {
        Write-Error "Failed to install Claude Code CLI: $_"
        return $false
    }
}

function Install-Bun {
    Write-Info "Checking Bun installation..."

    if (Test-CommandExists "bun") {
        $version = bun --version
        Write-Success "Bun is already installed: v$version"
        return $true
    }

    Write-Info "Installing Bun..."

    # Check if winget is available
    if (Test-CommandExists "winget") {
        Write-Info "Using winget to install Bun..."
        try {
            winget install Oven-sh.Bun --silent --accept-package-agreements --accept-source-agreements
            Refresh-EnvironmentPath

            if (Test-CommandExists "bun") {
                $version = bun --version
                Write-Success "Bun installed successfully: v$version"
                return $true
            }
        }
        catch {
            Write-Warning "winget installation failed, trying PowerShell method..."
        }
    }

    # Fallback: Use official PowerShell installer
    Write-Info "Using official Bun installer..."
    try {
        Invoke-RestMethod bun.sh/install.ps1 | Invoke-Expression
        Refresh-EnvironmentPath

        if (Test-CommandExists "bun") {
            $version = bun --version
            Write-Success "Bun installed successfully: v$version"
            return $true
        }
        else {
            Write-Warning "Bun installed. Please restart your terminal to use 'bun' command."
            return $true
        }
    }
    catch {
        Write-Error "Failed to install Bun: $_"
        Write-Info "Try manually: irm bun.sh/install.ps1 | iex"
        return $false
    }
}

function Uninstall-ClaudeCode {
    Write-Info "Uninstalling Claude Code CLI..."

    if (-not (Test-CommandExists "npm")) {
        Write-Error "npm is not installed."
        return $false
    }

    # Fix Execution Policy to allow npm scripts to run
    Set-ExecutionPolicyIfNeeded

    try {
        npm uninstall -g @anthropic-ai/claude-code
        Write-Success "Claude Code CLI uninstalled successfully!"
        return $true
    }
    catch {
        Write-Error "Failed to uninstall Claude Code CLI: $_"
        return $false
    }
}

# ============================================================================
# VERIFY AND FIX COMMON ISSUES
# ============================================================================
function Invoke-VerifyAndFix {
    Write-Color ""
    Write-Color "============================================" "DarkGray"
    Write-Color "  VERIFY & FIX COMMON ISSUES" "Magenta"
    Write-Color "============================================" "DarkGray"
    Write-Color ""

    $issuesFound = 0
    $issuesFixed = 0

    # 1. Check Execution Policy
    Write-Info "Checking PowerShell Execution Policy..."
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    $machinePolicy = Get-ExecutionPolicy -Scope LocalMachine
    Write-Color "  Current User Policy: $currentPolicy" "White"
    Write-Color "  Local Machine Policy: $machinePolicy" "White"

    if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "Undefined") {
        $issuesFound++
        Write-Warning "Execution Policy is blocking scripts!"
        Write-Info "Fixing: Setting Execution Policy to RemoteSigned..."
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Success "Execution Policy fixed!"
            $issuesFixed++
        }
        catch {
            Write-Error "Could not fix automatically. Run as Administrator or execute:"
            Write-Color "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" "Yellow"
        }
    }
    else {
        Write-Success "Execution Policy is OK ($currentPolicy)"
    }

    Write-Color ""

    # 2. Check PATH for Node.js
    Write-Info "Checking Node.js in PATH..."
    if (Test-CommandExists "node") {
        $nodePath = (Get-Command node).Source
        Write-Success "Node.js found: $nodePath"
    }
    else {
        $issuesFound++
        Write-Warning "Node.js not found in PATH"
        # Check if Node.js is installed but not in PATH
        $possiblePaths = @(
            "$env:ProgramFiles\nodejs",
            "${env:ProgramFiles(x86)}\nodejs",
            "$env:LOCALAPPDATA\Programs\nodejs"
        )
        foreach ($path in $possiblePaths) {
            if (Test-Path "$path\node.exe") {
                Write-Info "Found Node.js at: $path"
                Write-Info "Adding to PATH..."
                $env:Path = "$path;$env:Path"
                [System.Environment]::SetEnvironmentVariable("Path", "$path;" + [System.Environment]::GetEnvironmentVariable("Path", "User"), "User")
                Write-Success "Node.js added to PATH!"
                $issuesFixed++
                break
            }
        }
    }

    Write-Color ""

    # 3. Check PATH for npm
    Write-Info "Checking npm in PATH..."
    if (Test-CommandExists "npm") {
        $npmPath = (Get-Command npm).Source
        Write-Success "npm found: $npmPath"
    }
    else {
        $issuesFound++
        Write-Warning "npm not found in PATH"
        Write-Info "npm should be installed with Node.js. Try reinstalling Node.js (Option 2)"
    }

    Write-Color ""

    # 4. Check npm global prefix
    Write-Info "Checking npm global configuration..."
    if (Test-CommandExists "npm") {
        try {
            $npmPrefix = npm config get prefix 2>$null
            Write-Color "  npm global prefix: $npmPrefix" "White"

            # Check if npm global bin is in PATH
            $npmBin = "$npmPrefix"
            if (-not ($env:Path -like "*$npmBin*")) {
                $issuesFound++
                Write-Warning "npm global bin directory not in PATH"
                Write-Info "Adding npm global bin to PATH..."
                $env:Path = "$npmBin;$env:Path"
                [System.Environment]::SetEnvironmentVariable("Path", "$npmBin;" + [System.Environment]::GetEnvironmentVariable("Path", "User"), "User")
                Write-Success "npm global bin added to PATH!"
                $issuesFixed++
            }
            else {
                Write-Success "npm global bin is in PATH"
            }
        }
        catch {
            Write-Warning "Could not check npm configuration"
        }
    }

    Write-Color ""

    # 5. Check Claude Code installation
    Write-Info "Checking Claude Code CLI..."
    if (Test-CommandExists "claude") {
        $claudeVersion = claude --version 2>$null
        Write-Success "Claude Code CLI is working: $claudeVersion"
    }
    else {
        if (Test-CommandExists "npm") {
            # Check if claude is installed but not in PATH
            try {
                $globalPackages = npm list -g @anthropic-ai/claude-code 2>$null
                if ($globalPackages -like "*claude-code*") {
                    $issuesFound++
                    Write-Warning "Claude Code is installed but not in PATH"

                    # Auto-fix: Find and add claude to PATH
                    Write-Info "Attempting to fix PATH for Claude Code..."
                    $npmPrefix = npm config get prefix 2>$null
                    if ($npmPrefix) {
                        # Check common locations for claude executable
                        $possibleClaudePaths = @(
                            "$npmPrefix",
                            "$npmPrefix\node_modules\.bin",
                            "$env:APPDATA\npm",
                            "$env:APPDATA\npm\node_modules\.bin",
                            "$env:LOCALAPPDATA\npm",
                            "$env:LOCALAPPDATA\npm\node_modules\.bin"
                        )

                        $claudeFound = $false
                        foreach ($claudePath in $possibleClaudePaths) {
                            $claudeExe = Join-Path $claudePath "claude.cmd"
                            $claudePs1 = Join-Path $claudePath "claude.ps1"
                            if ((Test-Path $claudeExe) -or (Test-Path $claudePs1)) {
                                Write-Info "Found Claude at: $claudePath"
                                if (-not ($env:Path -like "*$claudePath*")) {
                                    Write-Info "Adding to PATH..."
                                    $env:Path = "$claudePath;$env:Path"
                                    [System.Environment]::SetEnvironmentVariable("Path", "$claudePath;" + [System.Environment]::GetEnvironmentVariable("Path", "User"), "User")
                                    Write-Success "Claude Code PATH fixed!"
                                    $issuesFixed++
                                }
                                $claudeFound = $true
                                break
                            }
                        }

                        if (-not $claudeFound) {
                            # Fallback: add npm prefix to PATH
                            if (-not ($env:Path -like "*$npmPrefix*")) {
                                Write-Info "Adding npm prefix to PATH: $npmPrefix"
                                $env:Path = "$npmPrefix;$env:Path"
                                [System.Environment]::SetEnvironmentVariable("Path", "$npmPrefix;" + [System.Environment]::GetEnvironmentVariable("Path", "User"), "User")
                                Write-Success "npm prefix added to PATH!"
                                $issuesFixed++
                            }
                        }

                        # Verify fix worked
                        Refresh-EnvironmentPath
                        if (Test-CommandExists "claude") {
                            Write-Success "Claude Code CLI is now accessible!"
                        }
                        else {
                            Write-Warning "PATH updated but claude still not found. Please restart your terminal."
                        }
                    }
                }
                else {
                    Write-Info "Claude Code CLI is not installed. Use Option 3 to install."
                }
            }
            catch {
                Write-Info "Claude Code CLI is not installed. Use Option 3 to install."
            }
        }
        else {
            Write-Info "Install Node.js first (Option 2), then install Claude Code (Option 3)"
        }
    }

    Write-Color ""

    # 6. Test npm script execution
    Write-Info "Testing npm script execution..."
    if (Test-CommandExists "npm") {
        try {
            $npmVersion = & npm --version 2>&1
            if ($npmVersion -match "^\d+\.\d+\.\d+$") {
                Write-Success "npm scripts can execute properly (npm v$npmVersion)"
            }
            else {
                $issuesFound++
                Write-Warning "npm script execution may have issues"
                Write-Color "  Output: $npmVersion" "Yellow"
            }
        }
        catch {
            $issuesFound++
            Write-Error "npm script execution failed: $_"
            Write-Info "This is likely an Execution Policy issue. Fixing..."
            Set-ExecutionPolicyIfNeeded
        }
    }

    Write-Color ""

    # Summary
    Write-Color "============================================" "DarkGray"
    Write-Color "  SUMMARY" "White"
    Write-Color "============================================" "DarkGray"
    if ($issuesFound -eq 0) {
        Write-Success "No issues found! Your system is ready."
    }
    else {
        Write-Color "  Issues found: $issuesFound" "Yellow"
        Write-Color "  Issues fixed: $issuesFixed" "Green"
        if ($issuesFound -gt $issuesFixed) {
            Write-Warning "Some issues require manual intervention. See details above."
        }
        else {
            Write-Success "All issues have been fixed!"
        }
    }

    Write-Color ""
    Write-Info "If you still have issues, try:"
    Write-Color "  1. Restart PowerShell/Terminal" "White"
    Write-Color "  2. Run this script as Administrator" "White"
    Write-Color "  3. Reinstall Node.js (Option 2)" "White"
    Write-Color ""
}

# ============================================================================
# VERSION CHECK
# ============================================================================
function Show-Versions {
    Write-Color ""
    Write-Color "============================================" "DarkGray"
    Write-Color "  INSTALLED VERSIONS:" "White"
    Write-Color "============================================" "DarkGray"
    Write-Color ""

    # Node.js
    if (Test-CommandExists "node") {
        $nodeVersion = node --version
        Write-Success "Node.js: $nodeVersion"
    }
    else {
        Write-Error "Node.js: Not installed"
    }

    # npm
    if (Test-CommandExists "npm") {
        $npmVersion = npm --version
        Write-Success "npm: v$npmVersion"
    }
    else {
        Write-Error "npm: Not installed"
    }

    # Git
    if (Test-CommandExists "git") {
        $gitVersion = git --version
        Write-Success "Git: $gitVersion"
    }
    else {
        Write-Error "Git: Not installed"
    }

    # VS Code
    if (Test-CommandExists "code") {
        $codeVersion = code --version 2>$null | Select-Object -First 1
        Write-Success "VS Code: v$codeVersion"
    }
    else {
        Write-Error "VS Code: Not installed"
    }

    # Bun
    if (Test-CommandExists "bun") {
        $bunVersion = bun --version
        Write-Success "Bun: v$bunVersion"
    }
    else {
        Write-Error "Bun: Not installed"
    }

    # Claude Code
    if (Test-CommandExists "claude") {
        $claudeVersion = claude --version 2>$null
        Write-Success "Claude Code: $claudeVersion"
    }
    else {
        Write-Error "Claude Code: Not installed"
    }

    Write-Color ""
}

# ============================================================================
# MAIN MENU LOOP
# ============================================================================
function Start-MainMenu {
    do {
        Show-Banner
        Show-Menu

        $choice = Read-Host "Enter your choice [0-9, V]"
        Write-Color ""

        switch ($choice) {
            "1" {
                # Install All (Node.js + Claude Code)
                Write-Info "Starting installation of Node.js + Claude Code..."
                if (-not (Test-InternetConnection)) {
                    Write-Error "No internet connection detected. Please check your connection."
                    break
                }
                Install-NodeJS
                Start-Sleep -Seconds 2
                Refresh-EnvironmentPath
                Install-ClaudeCode
            }
            "2" {
                # Install Node.js only
                if (-not (Test-InternetConnection)) {
                    Write-Error "No internet connection detected."
                    break
                }
                Install-NodeJS
            }
            "3" {
                # Install Claude Code only
                if (-not (Test-InternetConnection)) {
                    Write-Error "No internet connection detected."
                    break
                }
                Install-ClaudeCode
            }
            "4" {
                # Install Git
                if (-not (Test-InternetConnection)) {
                    Write-Error "No internet connection detected."
                    break
                }
                Install-Git
            }
            "5" {
                # Install VS Code
                if (-not (Test-InternetConnection)) {
                    Write-Error "No internet connection detected."
                    break
                }
                Install-VSCode
            }
            "6" {
                # Install Bun
                if (-not (Test-InternetConnection)) {
                    Write-Error "No internet connection detected."
                    break
                }
                Install-Bun
            }
            "7" {
                # Install Everything
                Write-Info "Starting FULL installation..."
                if (-not (Test-InternetConnection)) {
                    Write-Error "No internet connection detected."
                    break
                }
                Install-NodeJS
                Start-Sleep -Seconds 2
                Refresh-EnvironmentPath
                Install-Git
                Start-Sleep -Seconds 2
                Refresh-EnvironmentPath
                Install-VSCode
                Start-Sleep -Seconds 2
                Refresh-EnvironmentPath
                Install-Bun
                Start-Sleep -Seconds 2
                Refresh-EnvironmentPath
                Install-ClaudeCode
                Write-Color ""
                Write-Success "Full installation completed!"
            }
            "8" {
                # Show versions
                Show-Versions
            }
            "9" {
                # Uninstall Claude Code
                Uninstall-ClaudeCode
            }
            "V" {
                # Verify and Fix Common Issues
                Invoke-VerifyAndFix
            }
            "v" {
                # Verify and Fix Common Issues (lowercase)
                Invoke-VerifyAndFix
            }
            "0" {
                Write-Color ""
                Write-Info "Goodbye! Happy coding with Claude Code!"
                Write-Color ""
                return
            }
            default {
                Write-Warning "Invalid option. Please enter a number between 0-9 or V."
            }
        }

        Write-Color ""
        Read-Host "Press Enter to continue..."

    } while ($true)
}

# ============================================================================
# COMMAND LINE ARGUMENTS HANDLER
# ============================================================================
function Show-Usage {
    Write-Color ""
    Write-Color "Usage: .\setup.ps1 [OPTIONS]" "White"
    Write-Color ""
    Write-Color "Options:" "Cyan"
    Write-Color "  -All         Install everything (Node.js, Claude Code, Git, VS Code, Bun)" "White"
    Write-Color "  -Node        Install Node.js only" "White"
    Write-Color "  -Claude      Install Claude Code CLI only" "White"
    Write-Color "  -Git         Install Git" "White"
    Write-Color "  -VSCode      Install VS Code" "White"
    Write-Color "  -Bun         Install Bun" "White"
    Write-Color "  -Verify      Verify and fix common issues" "White"
    Write-Color "  -Help        Show this help message" "White"
    Write-Color ""
    Write-Color "Examples:" "Cyan"
    Write-Color "  irm URL | iex                                    # Interactive menu" "White"
    Write-Color "  .\setup.ps1 -All                                 # Install everything" "White"
    Write-Color "  .\setup.ps1 -Node -Claude                        # Install Node.js and Claude Code" "White"
    Write-Color "  .\setup.ps1 -Git -Bun                            # Install Git and Bun" "White"
    Write-Color "  .\setup.ps1 -Verify                              # Check and fix common issues" "White"
    Write-Color ""
}

function Invoke-NonInteractive {
    param(
        [switch]$InstallAll,
        [switch]$InstallNode,
        [switch]$InstallClaude,
        [switch]$InstallGit,
        [switch]$InstallVSCode,
        [switch]$InstallBun
    )

    Show-Banner
    Write-Info "Running in non-interactive mode..."
    Write-Color ""

    if (-not (Test-InternetConnection)) {
        Write-Error "No internet connection detected."
        exit 1
    }

    # Install selected components
    if ($InstallAll -or $InstallNode) {
        Install-NodeJS
        Start-Sleep -Seconds 1
        Refresh-EnvironmentPath
    }

    if ($InstallAll -or $InstallGit) {
        Install-Git
        Start-Sleep -Seconds 1
        Refresh-EnvironmentPath
    }

    if ($InstallAll -or $InstallVSCode) {
        Install-VSCode
        Start-Sleep -Seconds 1
        Refresh-EnvironmentPath
    }

    if ($InstallAll -or $InstallBun) {
        Install-Bun
        Start-Sleep -Seconds 1
        Refresh-EnvironmentPath
    }

    if ($InstallAll -or $InstallClaude) {
        Install-ClaudeCode
    }

    Write-Color ""
    Write-Success "Installation completed!"
    Write-Info "For interactive menu, run: .\setup.ps1"
}

# ============================================================================
# ENTRY POINT
# ============================================================================

# Parse command line arguments
$hasArgs = $false
$doAll = $false
$doNode = $false
$doClaude = $false
$doGit = $false
$doVSCode = $false
$doBun = $false
$doVerify = $false
$showHelp = $false

foreach ($arg in $args) {
    $hasArgs = $true
    switch -Wildcard ($arg.ToLower()) {
        "-all" { $doAll = $true }
        "--all" { $doAll = $true }
        "-node" { $doNode = $true }
        "--node" { $doNode = $true }
        "-claude" { $doClaude = $true }
        "--claude" { $doClaude = $true }
        "-git" { $doGit = $true }
        "--git" { $doGit = $true }
        "-vscode" { $doVSCode = $true }
        "--vscode" { $doVSCode = $true }
        "-bun" { $doBun = $true }
        "--bun" { $doBun = $true }
        "-verify" { $doVerify = $true }
        "--verify" { $doVerify = $true }
        "-fix" { $doVerify = $true }
        "--fix" { $doVerify = $true }
        "-help" { $showHelp = $true }
        "--help" { $showHelp = $true }
        "-h" { $showHelp = $true }
        default { Write-Warning "Unknown option: $arg" }
    }
}

if ($showHelp) {
    Show-Usage
    exit 0
}

if ($doVerify) {
    # Run verify and fix only
    Show-Banner
    Invoke-VerifyAndFix
    exit 0
}

if ($hasArgs) {
    # Non-interactive mode with arguments
    Invoke-NonInteractive -InstallAll:$doAll -InstallNode:$doNode -InstallClaude:$doClaude -InstallGit:$doGit -InstallVSCode:$doVSCode -InstallBun:$doBun
}
else {
    # Interactive mode - show menu
    Start-MainMenu
}
