#!/bin/bash
set -euo pipefail

# Omarchy Glass - Remote one-liner uninstaller
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/nihildigit/omarchy-glass/main/remote-uninstall.sh)

INSTALL_DIR="$HOME/.local/share/omarchy-glass"
UNINSTALLER="$INSTALL_DIR/uninstall.sh"

if [ ! -x "$UNINSTALLER" ]; then
    echo "[glass] Omarchy Glass not found at $INSTALL_DIR"
    echo "[glass] Nothing to uninstall."
    echo "[glass] If you installed from a manual clone, run ./uninstall.sh in that clone."
    exit 0
fi

exec "$UNINSTALLER"
