#!/usr/bin/env bash
set -euo pipefail

# Karabiner-DriverKit-VirtualHIDDevice installer/uninstaller
# Based on: https://github.com/jtroo/kanata/discussions/1972
#
# Usage:
#   ./install-karabiner-driver.sh install
#   ./install-karabiner-driver.sh uninstall

REPO="pqrs-org/Karabiner-DriverKit-VirtualHIDDevice"
MANAGER="/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager"

case "${1:-}" in
install)
  API_URL="https://api.github.com/repos/${REPO}/releases/latest"

  echo "=== Karabiner-DriverKit-VirtualHIDDevice Installer ==="
  echo

  echo "[1/4] Fetching latest release info..."
  PKG_URL=$(curl --silent "$API_URL" |
    grep "browser_download_url" |
    grep "\.pkg" |
    cut -d '"' -f 4)

  if [ -z "$PKG_URL" ]; then
    echo "Error: Could not find .pkg download URL." >&2
    exit 1
  fi
  echo "  ✓ Found: $PKG_URL"

  echo
  echo "[2/4] Downloading..."
  curl -L "$PKG_URL" -o /tmp/Karabiner-DriverKit-VirtualHIDDevice.pkg
  echo "  ✓ Downloaded to /tmp/Karabiner-DriverKit-VirtualHIDDevice.pkg"

  echo
  echo "[3/4] Installing (requires sudo)..."
  sudo installer -pkg /tmp/Karabiner-DriverKit-VirtualHIDDevice.pkg -target /
  rm /tmp/Karabiner-DriverKit-VirtualHIDDevice.pkg
  echo "  ✓ Installed"

  echo
  echo "[4/4] Activating driver..."
  "$MANAGER" activate
  echo "  ✓ Activation requested"

  echo
  echo "=== Done ==="
  echo
  echo "Next steps:"
  echo "  1. Go to System Settings > Privacy & Security and approve the system extension"
  echo "  2. Run: ./scripts/setup-kanata-daemons.sh install"
  echo "  3. Run: ./scripts/setup-kanata-mac.sh"
  ;;

uninstall)
  echo "=== Karabiner-DriverKit-VirtualHIDDevice Uninstaller ==="
  echo

  UNINSTALL_DIR="/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall"

  echo "[1/3] Deactivating driver..."
  bash "${UNINSTALL_DIR}/deactivate_driver.sh"
  echo "  ✓ Deactivated"

  echo
  echo "[2/3] Removing files (requires sudo)..."
  sudo bash "${UNINSTALL_DIR}/remove_files.sh"
  echo "  ✓ Removed"

  echo
  echo "[3/3] Stopping daemon..."
  sudo killall Karabiner-VirtualHIDDevice-Daemon 2>/dev/null || true
  echo "  ✓ Stopped"

  echo
  echo "=== Done ==="
  ;;

*)
  echo "Usage: $0 [install|uninstall]"
  exit 1
  ;;
esac
