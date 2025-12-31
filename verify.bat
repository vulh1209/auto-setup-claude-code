@echo off
:: ============================================================================
:: Claude Code CLI - Verify & Fix
:: Double-click this file to verify and fix common issues
:: ============================================================================

title Claude Code CLI - Verify & Fix

echo.
echo   ===================================================
echo      Claude Code CLI - Verify ^& Fix
echo   ===================================================
echo.

:: Download and run the setup script with -Verify flag
powershell -ExecutionPolicy Bypass -Command "iex \"& { $(irm https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.ps1) } -Verify\""

pause
