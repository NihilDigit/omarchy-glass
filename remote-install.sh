#!/bin/bash
set -euo pipefail

# Omarchy Glass - Remote one-liner installer
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/nihildigit/omarchy-glass/main/remote-install.sh)

REPO="https://github.com/nihildigit/omarchy-glass.git"
INSTALL_DIR="$HOME/.local/share/omarchy-glass"

if [ -d "$INSTALL_DIR" ]; then
    echo "[glass] Updating existing installation..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    echo "[glass] Downloading Omarchy Glass..."
    git clone --depth 1 "$REPO" "$INSTALL_DIR"
fi

exec "$INSTALL_DIR/install.sh"
