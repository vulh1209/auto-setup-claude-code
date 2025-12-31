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
    Write-Color ""
    Write-Color "  [0] Exit" "DarkGray"
    Write-Color ""
    Write-Color "============================================" "DarkGray"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
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
    try {
        npm install -g @anthropic-ai/claude-code
        Refresh-EnvironmentPath

        if (Test-CommandExists "claude") {
            Write-Success "Claude Code CLI installed successfully!"
            Write-Info "Run 'claude' to start using Claude Code."
            return $true
        }
        else {
            Write-Warning "Installation completed but 'claude' command not found."
            Write-Info "Try reopening your terminal or run: npm list -g @anthropic-ai/claude-code"
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

        $choice = Read-Host "Enter your choice [0-9]"
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
            "0" {
                Write-Color ""
                Write-Info "Goodbye! Happy coding with Claude Code!"
                Write-Color ""
                return
            }
            default {
                Write-Warning "Invalid option. Please enter a number between 0-9."
            }
        }

        Write-Color ""
        Read-Host "Press Enter to continue..."

    } while ($true)
}

# ============================================================================
# ENTRY POINT
# ============================================================================
Start-MainMenu
