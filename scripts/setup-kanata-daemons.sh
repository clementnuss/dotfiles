#!/usr/bin/env bash
set -euo pipefail

# Kanata + Karabiner VirtualHIDDevice LaunchDaemons setup
# Based on: https://github.com/jtroo/kanata/discussions/1972
#
# Installs three system daemons (all run as root):
#   - Karabiner-VirtualHIDDevice-Daemon  (creates the virtual HID device)
#   - Karabiner-VirtualHIDDevice-Manager (activates the driver)
#   - kanata                             (needs root to access the rootonly socket)
#
# Requires sudo — but only once. After this everything auto-starts on boot.
#
# Usage:
#   sudo ./scripts/setup-kanata-daemons.sh install
#   sudo ./scripts/setup-kanata-daemons.sh uninstall

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/kanata/LaunchDaemons"
DEST_DIR="/Library/LaunchDaemons"
KANATA_LABEL="io.dreamsofcode.kanata"
KANATA_DEST="$DEST_DIR/$KANATA_LABEL.plist"

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo."
    echo "Usage: sudo $0 [install|uninstall]"
    exit 1
fi

# Resolve the real user's home directory (works whether called via sudo or not)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")

generate_kanata_plist() {
    cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$KANATA_LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/kanata</string>
        <string>-c</string>
        <string>$REAL_HOME/.config/kanata/kanata.kbd</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Library/Logs/Kanata/kanata.out.log</string>

    <key>StandardErrorPath</key>
    <string>/Library/Logs/Kanata/kanata.err.log</string>
</dict>
</plist>
EOF
}

shopt -s nullglob
PLISTS=("$SRC_DIR"/*.plist)

if [[ ${#PLISTS[@]} -eq 0 ]]; then
    echo "ERROR: No .plist files found in $SRC_DIR"
    exit 1
fi

case "${1:-}" in
install)
    echo "=== Installing Kanata + Karabiner VirtualHIDDevice Daemons ==="
    echo "  User home: $REAL_HOME"
    echo

    echo "  Creating log directory..."
    mkdir -p /Library/Logs/Kanata
    echo "  ✓ /Library/Logs/Kanata"
    echo

    # Install Karabiner plists from source files
    for SRC in "${PLISTS[@]}"; do
        FILENAME=$(basename "$SRC")
        LABEL="${FILENAME%.plist}"
        DEST="$DEST_DIR/$FILENAME"

        echo "  Installing $FILENAME..."
        # Bootout first in case it's already registered
        launchctl bootout system "$DEST" 2>/dev/null || true
        cp "$SRC" "$DEST" || { echo "ERROR: Failed to copy $FILENAME"; exit 1; }
        chown root:wheel "$DEST"
        launchctl enable "system/$LABEL"
        launchctl bootstrap system "$DEST"
        echo "  ✓ $LABEL"
    done

    # Generate and install kanata plist
    echo "  Installing $KANATA_LABEL.plist (config: $REAL_HOME/.config/kanata/kanata.kbd)..."
    launchctl bootout system "$KANATA_DEST" 2>/dev/null || true
    generate_kanata_plist > "$KANATA_DEST"
    chown root:wheel "$KANATA_DEST"
    launchctl enable "system/$KANATA_LABEL"
    launchctl bootstrap system "$KANATA_DEST"
    echo "  ✓ $KANATA_LABEL"

    echo
    echo "=== Done ==="
    echo
    echo "!! ADDITIONAL SETUP REQUIRED !!"
    echo
    echo "In System Settings, grant permissions to kanata:"
    echo "  1. Privacy & Security > Input Monitoring"
    echo "     Add: Shift+Cmd+G → type /opt/homebrew/bin/kanata → Open"
    echo "  2. Privacy & Security > Accessibility"
    echo "     Add: Shift+Cmd+G → type /opt/homebrew/bin/kanata → Open"
    echo "  3. Keyboard > Keyboard Shortcuts > Modifier Keys"
    echo "     Select 'Karabiner DriverKit VirtualHIDKeyboard' as the keyboard"
    echo
    echo "View logs: tail -f /Library/Logs/Kanata/kanata.err.log"
    ;;

uninstall)
    echo "=== Uninstalling Kanata + Karabiner VirtualHIDDevice Daemons ==="
    echo

    # Uninstall kanata daemon
    if [ -f "$KANATA_DEST" ]; then
        echo "  Removing $KANATA_LABEL.plist..."
        launchctl stop "$KANATA_LABEL" 2>/dev/null || true
        launchctl disable "system/$KANATA_LABEL" || echo "  WARN: disable failed"
        launchctl bootout system "$KANATA_DEST" || echo "  WARN: bootout failed"
        rm "$KANATA_DEST"
        echo "  ✓ $KANATA_LABEL removed"
    fi

    # Uninstall Karabiner plists
    for SRC in "${PLISTS[@]}"; do
        FILENAME=$(basename "$SRC")
        LABEL="${FILENAME%.plist}"
        DEST="$DEST_DIR/$FILENAME"

        [[ ! -f "$DEST" ]] && echo "  WARN: $DEST not found, skipping" && continue

        echo "  Removing $FILENAME..."
        launchctl stop "$LABEL" 2>/dev/null || true
        launchctl disable "system/$LABEL" || echo "  WARN: disable failed for $LABEL"
        launchctl bootout system "$DEST" || echo "  WARN: bootout failed for $LABEL"
        rm "$DEST"
        echo "  ✓ $LABEL removed"
    done

    echo
    echo "=== Done ==="
    ;;

*)
    echo "Usage: sudo $0 [install|uninstall]"
    exit 1
    ;;
esac
