#!/usr/bin/env bash
set -euo pipefail

# Disable Fallback DNS in systemd-resolved

SCRIPT_NAME="$(basename "$0")"
CONFIG_DIR="/etc/systemd/resolved.conf.d"
CONFIG_FILE="$CONFIG_DIR/fallback_dns.conf"

echo "=== Disable Fallback DNS ==="
echo

# Check if systemd-resolved is available
if ! systemctl is-enabled systemd-resolved.service &> /dev/null; then
    echo "  ✗ Error: systemd-resolved is not enabled."
    echo "    This script is only needed if you're using systemd-resolved."
    exit 1
fi

# Create config directory if it doesn't exist
echo "[1/3] Checking configuration directory..."
if [ ! -d "$CONFIG_DIR" ]; then
    echo "  Creating $CONFIG_DIR..."
    sudo mkdir -p "$CONFIG_DIR"
    echo "  ✓ Created $CONFIG_DIR"
else
    echo "  ℹ Directory already exists"
fi

# Create or update the configuration file
echo
echo "[2/3] Creating fallback DNS configuration..."
sudo tee "$CONFIG_FILE" > /dev/null << 'EOF'
[Resolve]
FallbackDNS=
EOF
echo "  ✓ Created $CONFIG_FILE"

# Restart systemd-resolved to apply changes
echo
echo "[3/3] Restarting systemd-resolved..."
sudo systemctl restart systemd-resolved.service
echo "  ✓ Service restarted"

echo
echo "=== Complete ==="
echo
echo "Fallback DNS has been disabled."
echo "You can verify with: resolvectl status"
echo
