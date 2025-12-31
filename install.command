#!/bin/bash
# ============================================================================
# Claude Code CLI - One-Click Installer for macOS
# Double-click this file to install Claude Code CLI
# ============================================================================

echo ""
echo "   ==================================================="
echo "      Claude Code CLI - One-Click Installer"
echo "   ==================================================="
echo ""

# Download and run the setup script from GitHub
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.sh | bash

echo ""
echo "Press any key to close..."
read -n 1
