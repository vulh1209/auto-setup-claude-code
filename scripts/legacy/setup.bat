@echo off
:: ============================================================================
:: Auto Setup Script Launcher for Claude Code CLI
:: Double-click this file to run the setup script
:: ============================================================================

title Claude Code CLI - Auto Setup

:: Run PowerShell script with execution policy bypass
powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

pause
