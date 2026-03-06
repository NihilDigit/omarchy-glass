#!/bin/bash
set -euo pipefail

# Omarchy Glass - Uninstaller
# Restores from backup if user had customizations, otherwise refreshes to Omarchy defaults.

BACKUP_DIR="$HOME/.config/omarchy/glass-backup"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[glass]${NC} $1"; }
ok()    { echo -e "${GREEN}[glass]${NC} $1"; }
warn()  { echo -e "${YELLOW}[glass]${NC} $1"; }

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
refresh_to_default() {
    local config="$1"
    local target="$HOME/.config/$config"
    local default="$HOME/.local/share/omarchy/config/$config"

    if command -v omarchy-refresh-config > /dev/null 2>&1; then
        if omarchy-refresh-config "$config" > /dev/null 2>&1; then
            return 0
        fi
    fi

    if [ -f "$default" ]; then
        mkdir -p "$(dirname "$target")"
        cp "$default" "$target"
        return 0
    fi

    return 1
}

restore_or_refresh() {
    local config="$1"   # path relative to ~/.config/
    local label="$2"
    local backup="$BACKUP_DIR/$config"

    if [ -f "$backup" ]; then
        mkdir -p "$(dirname "$HOME/.config/$config")"
        cp "$backup" "$HOME/.config/$config"
        ok "Restored $label (from backup)"
    else
        if refresh_to_default "$config"; then
            ok "Restored $label"
        else
            warn "Skipped $label (no backup and no Omarchy default found)"
        fi
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
restore_or_refresh "swayosd/style.css" "SwayOSD"
restore_or_refresh "btop/btop.conf" "btop"

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
