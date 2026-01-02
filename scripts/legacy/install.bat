@echo off
:: ============================================================================
:: Claude Code CLI - One-Click Installer
:: Double-click this file to install Claude Code CLI
:: ============================================================================

title Claude Code CLI - Installer

echo.
echo   ===================================================
echo      Claude Code CLI - One-Click Installer
echo   ===================================================
echo.

:: Download and run the setup script from GitHub
powershell -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.ps1'))"

pause
