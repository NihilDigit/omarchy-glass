#!/bin/bash
set -euo pipefail

# Omarchy Glass - Uninstaller
# Restores original configs from backup

BACKUP_DIR="$HOME/.config/omarchy/glass-backup"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${BLUE}[glass]${NC} $1"; }
ok()    { echo -e "${GREEN}[glass]${NC} $1"; }
err()   { echo -e "${RED}[glass]${NC} $1"; }

if [ ! -d "$BACKUP_DIR" ]; then
    err "Backup directory not found at $BACKUP_DIR"
    err "Cannot uninstall without backups."
    exit 1
fi

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║      Omarchy Glass Uninstaller   ║"
echo "  ╚══════════════════════════════════╝"
echo ""
echo "  This will restore your original configs"
echo "  from the backup created during install."
echo ""

read -rp "  Continue? [Y/n] " confirm
[[ "${confirm,,}" == "n" ]] && exit 0
echo ""

restore() {
    local backup="$1"
    local target="$2"
    local label="$3"

    if [ -e "$BACKUP_DIR/$backup" ]; then
        cp -r "$BACKUP_DIR/$backup" "$target"
        ok "Restored $label"
    fi
}

restore "looknfeel.conf" "$HOME/.config/hypr/looknfeel.conf" "Hyprland look&feel"
restore "hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf" "Hyprlock"
restore "waybar-config.jsonc" "$HOME/.config/waybar/config.jsonc" "Waybar config"
restore "waybar-style.css" "$HOME/.config/waybar/style.css" "Waybar style"
restore "mako-config" "$HOME/.config/mako/config" "Mako notifications"
restore "alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" "Alacritty"
restore "walker-config.toml" "$HOME/.config/walker/config.toml" "Walker config"
restore "fastfetch-config.jsonc" "$HOME/.config/fastfetch/config.jsonc" "Fastfetch"

if [ -d "$BACKUP_DIR/walker-themes" ]; then
    rm -rf "$HOME/.config/walker/themes"
    restore "walker-themes" "$HOME/.config/walker/themes" "Walker themes"
fi

# Remove hooks
info "Removing hooks..."
rm -f "$HOME/.config/omarchy/hooks/post-update"
rm -f "$HOME/.config/omarchy/hooks/theme-set"
ok "Hooks removed"

# Remove glass walker theme
rm -rf "$HOME/.config/walker/themes/omarchy-glass"

# Restart services
info "Restarting services..."
omarchy-restart-waybar 2>/dev/null || true
omarchy-restart-walker 2>/dev/null || true
makoctl reload 2>/dev/null || true
hyprctl reload 2>/dev/null || true
ok "Services restarted"

echo ""
ok "Uninstall complete. Original configs restored."
echo ""
echo "  You can safely remove the backup at:"
echo "    $BACKUP_DIR"
echo ""
