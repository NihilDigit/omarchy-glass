#!/bin/bash
set -euo pipefail

# Omarchy Glass - Remote one-liner uninstaller
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/nihildigit/omarchy-glass/main/remote-uninstall.sh)

INSTALL_DIR="$HOME/.local/share/omarchy-glass"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "[glass] Omarchy Glass not found at $INSTALL_DIR"
    echo "[glass] Downloading for uninstall..."
    git clone --depth 1 "https://github.com/nihildigit/omarchy-glass.git" "$INSTALL_DIR"
fi

exec "$INSTALL_DIR/uninstall.sh"
