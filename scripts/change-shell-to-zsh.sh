#!/usr/bin/env bash
set -euo pipefail

# Change Default Shell to zsh

SCRIPT_NAME="$(basename "$0")"

echo "=== Change Default Shell to zsh ==="
echo

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "  ✗ Error: zsh is not installed."
    echo "    Please install zsh first (e.g., sudo pacman -S zsh)"
    exit 1
fi

# Get the path to zsh
ZSH_PATH=$(command -v zsh)
echo "[1/3] Found zsh at: $ZSH_PATH"

# Check if zsh is in /etc/shells
echo
echo "[2/3] Checking /etc/shells..."
if ! grep -q "^${ZSH_PATH}$" /etc/shells; then
    echo "  ⚠ zsh is not in /etc/shells. Adding it now..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    echo "  ✓ Added $ZSH_PATH to /etc/shells"
else
    echo "  ℹ zsh is already in /etc/shells"
fi

# Check current shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
echo
echo "[3/3] Checking current shell..."
echo "  Current shell: $CURRENT_SHELL"

# Change shell if not already zsh
if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "  Changing default shell to zsh..."
    chsh -s "$ZSH_PATH"
    echo "  ✓ Default shell changed to zsh"
    echo
    echo "=== Complete ==="
    echo
    echo "Please log out and log back in for the change to take effect."
else
    echo "  ℹ Default shell is already zsh"
    echo
    echo "=== Already Using zsh ==="
    echo
    echo "No changes needed."
fi
echo
