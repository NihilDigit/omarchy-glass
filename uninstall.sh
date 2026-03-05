#!/bin/bash
set -euo pipefail

# Omarchy Glass - Uninstaller
# Restores from backup if user had customizations, otherwise refreshes to Omarchy defaults.

BACKUP_DIR="$HOME/.config/omarchy/glass-backup"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[glass]${NC} $1"; }
ok()    { echo -e "${GREEN}[glass]${NC} $1"; }

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║      Omarchy Glass Uninstaller   ║"
echo "  ╚══════════════════════════════════╝"
echo ""
echo "  Customized configs → restored from backup"
echo "  Unmodified configs → refreshed to Omarchy defaults"
echo ""

read -rp "  Continue? [Y/n] " confirm < /dev/tty
[[ "${confirm,,}" == "n" ]] && exit 0
echo ""

# Restore from backup if available, otherwise refresh to Omarchy default
restore_or_refresh() {
    local config="$1"   # path relative to ~/.config/
    local label="$2"
    local backup="$BACKUP_DIR/$config"

    if [ -f "$backup" ]; then
        mkdir -p "$(dirname "$HOME/.config/$config")"
        cp "$backup" "$HOME/.config/$config"
        ok "Restored $label (from backup)"
    else
        omarchy-refresh-config "$config" > /dev/null 2>&1
        ok "Restored $label"
    fi
}

info "Restoring configs..."
restore_or_refresh "hypr/looknfeel.conf" "Hyprland look&feel"
restore_or_refresh "hypr/hyprlock.conf" "Hyprlock"
restore_or_refresh "waybar/config.jsonc" "Waybar config"
restore_or_refresh "waybar/style.css" "Waybar style"
restore_or_refresh "mako/config" "Mako notifications"
restore_or_refresh "alacritty/alacritty.toml" "Alacritty"
restore_or_refresh "walker/config.toml" "Walker config"
restore_or_refresh "fastfetch/config.jsonc" "Fastfetch"

# Remove glass walker theme
rm -rf "$HOME/.config/walker/themes/omarchy-glass"

# Remove hooks
info "Removing hooks..."
rm -f "$HOME/.config/omarchy/hooks/post-update"
rm -f "$HOME/.config/omarchy/hooks/theme-set"
ok "Hooks removed"

# Restart services
info "Restarting services..."
omarchy-restart-waybar 2>/dev/null || true
omarchy-restart-walker 2>/dev/null || true
makoctl reload 2>/dev/null || true
hyprctl reload 2>/dev/null || true
ok "Services restarted"

# Clean up backup directory
if [ -d "$BACKUP_DIR" ]; then
    rm -rf "$BACKUP_DIR"
    ok "Backup directory cleaned up"
fi

echo ""
ok "Uninstall complete."
echo ""
