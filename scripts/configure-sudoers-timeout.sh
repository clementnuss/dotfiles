#!/usr/bin/env bash
set -euo pipefail

# Configure sudo timeout and shared authentication

SCRIPT_NAME="$(basename "$0")"
SUDOERS_DIR="/etc/sudoers.d"
SUDOERS_FILE="$SUDOERS_DIR/99-timeout-config"
TEMP_FILE=$(mktemp)

# Cleanup function
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

echo "=== Configure sudo Timeout ==="
echo
echo "⚠️  IMPORTANT SAFETY NOTE:"
echo "  Before running this script, open a separate root shell as a backup:"
echo "  In another terminal, run: sudo -i"
echo "  Keep that terminal open until you've verified sudo still works!"
echo
read -p "Do you have a root shell open as backup? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "  Aborted. Please open a root shell first."
    exit 0
fi

echo

# Check if we have sudo access
if ! sudo -v &> /dev/null; then
    echo "  ✗ Error: Unable to obtain sudo privileges."
    exit 1
fi

# Check if sudoers.d directory exists
echo "[1/4] Checking sudoers.d directory..."
if [ ! -d "$SUDOERS_DIR" ]; then
    echo "  ✗ Error: $SUDOERS_DIR does not exist."
    echo "    Your sudo configuration may not support drop-in files."
    exit 1
fi
echo "  ℹ Directory exists"

# Create the sudoers configuration in temp file
echo
echo "[2/4] Creating sudo timeout configuration..."
cat > "$TEMP_FILE" << 'EOF'
# Sudo timeout and authentication sharing configuration
# Created by chezmoi setup script

# Set sudo timeout to 60 minutes (1 hour)
Defaults timestamp_timeout=60

# Share sudo authentication across all terminals
# (disable per-tty tickets)
Defaults !tty_tickets
EOF
echo "  ✓ Created temporary configuration file"

# Validate the sudoers file syntax BEFORE installing
echo
echo "[3/4] Validating sudoers configuration..."
if ! visudo -c -f "$TEMP_FILE" &> /dev/null; then
    echo "  ✗ Error: Invalid sudoers syntax detected!"
    echo "    Not installing the configuration."
    exit 1
fi
echo "  ✓ Syntax validation passed"

# Install the configuration
echo
echo "[4/4] Installing configuration..."
sudo cp "$TEMP_FILE" "$SUDOERS_FILE"
sudo chmod 0440 "$SUDOERS_FILE"
echo "  ✓ Installed to $SUDOERS_FILE"

# Final validation of installed file
if ! sudo visudo -c &> /dev/null; then
    echo
    echo "  ✗ CRITICAL: Validation failed after installation!"
    echo "    Removing configuration file..."
    sudo rm -f "$SUDOERS_FILE"
    echo "    If sudo is broken, use your root shell to fix it."
    exit 1
fi

echo
echo "=== Complete ==="
echo
echo "Sudo timeout configured:"
echo "  - Timeout: 1 hour (60 minutes)"
echo "  - Authentication shared across all terminals"
echo
echo "Testing sudo now..."
if sudo -v &> /dev/null; then
    echo "  ✓ Sudo is working correctly!"
    echo
    echo "You can now close your backup root shell."
    echo "The changes take effect immediately for new sudo sessions."
else
    echo "  ✗ Sudo test failed! Use your root shell to run:"
    echo "    rm -f $SUDOERS_FILE"
fi
echo
