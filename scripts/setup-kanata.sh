#!/usr/bin/env bash
set -euo pipefail

# Kanata Linux Setup Script
# Based on: https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md

SCRIPT_NAME="$(basename "$0")"
USER_NAME="${SUDO_USER:-$USER}"

echo "=== Kanata Linux Setup Script ==="
echo

# Check if running with sudo for system configuration
if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run with sudo to configure system settings."
    echo "Usage: sudo ./$SCRIPT_NAME"
    exit 1
fi

echo "[1/5] Creating uinput group..."
if getent group uinput > /dev/null 2>&1; then
    echo "  ℹ uinput group already exists"
else
    groupadd --system uinput
    echo "  ✓ Created uinput group"
fi

echo
echo "[2/5] Adding user '$USER_NAME' to input and uinput groups..."
usermod -aG input "$USER_NAME"
usermod -aG uinput "$USER_NAME"
echo "  ✓ User added to groups (will take effect after logout/login)"

echo
echo "[3/5] Configuring udev rules..."
UDEV_RULES_FILE="/etc/udev/rules.d/99-input.rules"
UDEV_RULE='KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"'

if [ -f "$UDEV_RULES_FILE" ]; then
    if grep -q "uinput" "$UDEV_RULES_FILE"; then
        echo "  ℹ udev rules already configured in $UDEV_RULES_FILE"
    else
        echo "$UDEV_RULE" >> "$UDEV_RULES_FILE"
        echo "  ✓ Added udev rule to existing file"
    fi
else
    echo "$UDEV_RULE" > "$UDEV_RULES_FILE"
    echo "  ✓ Created $UDEV_RULES_FILE"
fi

echo "  Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger
echo "  ✓ udev rules reloaded"

echo
echo "[4/5] Loading uinput kernel module..."
if lsmod | grep -q uinput; then
    echo "  ℹ uinput module already loaded"
else
    modprobe uinput
    echo "  ✓ Loaded uinput module"
fi

# Ensure uinput loads on boot
MODULES_LOAD_FILE="/etc/modules-load.d/uinput.conf"
if [ -f "$MODULES_LOAD_FILE" ]; then
    echo "  ℹ uinput module load configuration already exists"
else
    echo "uinput" > "$MODULES_LOAD_FILE"
    echo "  ✓ Configured uinput to load on boot"
fi

echo
echo "[5/5] Setting up systemd user service..."
USER_HOME=$(eval echo "~$USER_NAME")
SERVICE_DIR="$USER_HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/kanata.service"

# Create directory as the user
sudo -u "$USER_NAME" mkdir -p "$SERVICE_DIR"

# Check if kanata is installed
if ! command -v kanata &> /dev/null; then
    echo "  ⚠ Warning: kanata binary not found in PATH"
    echo "    Please install kanata before enabling the service"
    KANATA_PATH="/usr/local/bin/kanata"
else
    KANATA_PATH=$(command -v kanata)
    echo "  ℹ Found kanata at: $KANATA_PATH"
fi

# Check if kanata config exists
KANATA_CONFIG="$USER_HOME/.config/kanata/main.kbd"
if [ ! -f "$KANATA_CONFIG" ]; then
    echo "  ⚠ Warning: kanata config not found at $KANATA_CONFIG"
    echo "    Please create a configuration file before starting the service"
fi

# Create systemd service file
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Type=simple
ExecStart=$KANATA_PATH --cfg $KANATA_CONFIG
Restart=on-failure

[Install]
WantedBy=default.target
EOF

chown "$USER_NAME:$USER_NAME" "$SERVICE_FILE"
echo "  ✓ Created systemd service file at $SERVICE_FILE"

echo
echo "=== Setup Complete ==="
echo
echo "Next steps:"
echo "  1. Log out and log back in for group changes to take effect"
echo "  2. Verify /dev/uinput permissions: ls -l /dev/uinput"
echo "  3. Ensure kanata is installed and in your PATH"
echo "  4. Create your kanata configuration at: $KANATA_CONFIG"
echo "  5. Enable the service: systemctl --user enable kanata.service"
echo "  6. Start the service: systemctl --user start kanata.service"
echo "  7. Check service status: systemctl --user status kanata.service"
echo
