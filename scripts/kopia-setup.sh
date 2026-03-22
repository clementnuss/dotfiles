#!/usr/bin/env bash
set -euo pipefail

# Kopia Repository Setup
# One-time setup for a kopia repository on a Synology NAS via WebDAV.
# After running this, snapshots can be created with:
#   kopia snapshot create ~/.local/share/atuin

KOPIA_WEBDAV_URL="${KOPIA_SYNOLOGY_URL:-}"
KOPIA_USER="${KOPIA_SYNOLOGY_USER:-}"
KOPIA_PASS="${KOPIA_SYNOLOGY_PASS:-}"

echo "=== Kopia Repository Setup ==="
echo

# Check prerequisites
if ! command -v kopia &> /dev/null; then
    echo "Error: kopia is not installed. Install it first:"
    echo "  https://kopia.io/docs/installation/"
    exit 1
fi

# Check if already connected
if kopia repository status &> /dev/null; then
    echo "Already connected to a kopia repository."
    kopia repository status
    echo
    echo "To disconnect first: kopia repository disconnect"
    exit 0
fi

# Prompt for missing connection details
if [ -z "$KOPIA_WEBDAV_URL" ]; then
    read -rp "WebDAV URL (e.g. http://nas:5005/kopia): " KOPIA_WEBDAV_URL
fi

if [[ ! "$KOPIA_WEBDAV_URL" =~ ^https?:// ]]; then
    echo "Error: URL must start with http:// or https://"
    exit 1
fi

if [ -z "$KOPIA_USER" ]; then
    read -rp "WebDAV username: " KOPIA_USER
fi
if [ -z "$KOPIA_PASS" ]; then
    read -rsp "WebDAV password: " KOPIA_PASS
    echo
fi

WEBDAV_ARGS=(
    "--url=$KOPIA_WEBDAV_URL"
    "--webdav-username=$KOPIA_USER"
    "--webdav-password=$KOPIA_PASS"
)

echo
echo "[1/2] Connecting to repository..."
# Try connecting to an existing repo first, create if it doesn't exist
if kopia repository connect webdav "${WEBDAV_ARGS[@]}" 2>/dev/null; then
    echo "  Connected to existing repository"
else
    echo "  Repository not found — creating new repository..."
    kopia repository create webdav "${WEBDAV_ARGS[@]}"
    echo "  Created and connected to new repository"
fi

echo
echo "[2/2] Setting default retention policy..."
kopia policy set --global \
    --keep-daily=30 \
    --keep-monthly=12 \
    --keep-annual=3
echo "  Retention: 30 daily, 12 monthly, 3 annual"

echo
echo "=== Setup Complete ==="
echo
echo "Create snapshots with:"
echo "  kopia snapshot create ~/.local/share/atuin"
echo
echo "Useful commands:"
echo "  kopia repository status  — check connection"
echo "  kopia snapshot list      — list snapshots"
echo "  kopia policy show        — show retention policy"
