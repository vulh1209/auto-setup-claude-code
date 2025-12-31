#!/bin/bash
# ============================================================================
# Claude Code CLI - Full Installation for macOS
# Double-click this file to install everything
# ============================================================================

echo ""
echo "   ==================================================="
echo "      Claude Code CLI - Full Installation"
echo "   ==================================================="
echo ""

# Download and run the setup script with --all flag
curl -fsSL https://raw.githubusercontent.com/vulh1209/auto-setup-claude-code/main/setup.sh | bash -s -- --all

echo ""
echo "Press any key to close..."
read -n 1
