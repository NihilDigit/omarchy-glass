#!/bin/bash
set -euo pipefail

# Omarchy Glass - Frosted glass visual enhancements for Omarchy
# https://github.com/nihildigit/omarchy-glass

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config/omarchy/glass-backup"
CONFIGS="$SCRIPT_DIR/configs"
HOOKS="$SCRIPT_DIR/hooks"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[glass]${NC} $1"; }
ok()    { echo -e "${GREEN}[glass]${NC} $1"; }
warn()  { echo -e "${YELLOW}[glass]${NC} $1"; }

# --- Pre-flight checks ---
if [ ! -f "$HOME/.config/hypr/hyprland.conf" ]; then
    echo "Error: Omarchy/Hyprland config not found. Is Omarchy installed?"
    exit 1
fi

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║       Omarchy Glass Installer    ║"
echo "  ╚══════════════════════════════════╝"
echo ""
echo "  This will apply frosted glass visual"
echo "  enhancements to your Omarchy setup."
echo ""

read -rp "  Continue? [Y/n] " confirm < /dev/tty
[[ "${confirm,,}" == "n" ]] && exit 0
echo ""

# --- Backup customized configs ---
# Only backs up files that differ from Omarchy defaults.
# Skips files the user hasn't touched. Won't overwrite existing backups on re-install.
info "Checking for customized configs..."

smart_backup() {
    local config="$1"  # path relative to ~/.config/
    local user="$HOME/.config/$config"
    local default="$HOME/.local/share/omarchy/config/$config"
    local backup="$BACKUP_DIR/$config"

    # Don't overwrite existing backup (preserves original on re-install)
    [ -f "$backup" ] && return 0

    if [ -f "$user" ] && [ -f "$default" ]; then
        if ! diff -q "$user" "$default" > /dev/null 2>&1; then
            mkdir -p "$(dirname "$backup")"
            cp "$user" "$backup"
            ok "Backed up customized $config"
        fi
    fi
}

smart_backup "hypr/looknfeel.conf"
smart_backup "hypr/hyprlock.conf"
smart_backup "waybar/config.jsonc"
smart_backup "waybar/style.css"
smart_backup "mako/config"
smart_backup "alacritty/alacritty.toml"
smart_backup "walker/config.toml"
smart_backup "fastfetch/config.jsonc"
smart_backup "swayosd/style.css"
smart_backup "btop/btop.conf"

# --- 1. Hyprland look & feel ---
info "Applying Hyprland visual enhancements..."
cp "$CONFIGS/hypr/looknfeel.conf" "$HOME/.config/hypr/looknfeel.conf"
"$SCRIPT_DIR/lib/update-border-gradient.sh"
ok "looknfeel.conf installed (border gradient matched to theme)"

# --- 2. Hyprlock ---
info "Applying lock screen enhancements..."
cp "$CONFIGS/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
ok "hyprlock.conf installed"

# --- 3. Waybar floating glass ---
info "Applying Waybar floating glass..."

# Patch waybar config.jsonc: add margin and height
WAYBAR_CONF="$HOME/.config/waybar/config.jsonc"
if [ -f "$WAYBAR_CONF" ]; then
    # Remove existing margin/height lines, then add ours after "spacing"
    tmp=$(mktemp)
    sed '/"margin-top"/d; /"margin-left"/d; /"margin-right"/d' "$WAYBAR_CONF" | \
    sed 's/"height": [0-9]*/"height": 32/' > "$tmp"

    # Add margins if not present
    if ! grep -q '"margin-top"' "$tmp"; then
        sed -i '/"height": 32/a\  "margin-top": 6,\n  "margin-left": 12,\n  "margin-right": 12,' "$tmp"
    fi
    # Replace active workspace icon with small dot
    sed -i 's/"active": "󱓻"/"active": "●"/' "$tmp"
    # Clock: add seconds, reorder to "weekday · HH:MM:SS"
    sed -i 's/"format": "{:L%A %H:%M}"/"format": "{:L%A · %H:%M:%S}",\n    "interval": 1/' "$tmp"
    mv "$tmp" "$WAYBAR_CONF"
fi

# Prepend glass style to waybar CSS
WAYBAR_CSS="$HOME/.config/waybar/style.css"
if [ -f "$WAYBAR_CSS" ]; then
    # Remove any existing glass blocks (in case of re-install)
    tmp=$(mktemp)
    awk '
        /^[[:space:]]*(window#waybar|tooltip|#workspaces button(\.active)?)[[:space:]]*\{/ { skip=1; next }
        skip && /^[[:space:]]*\}/ { skip=0; next }
        skip { next }
        /Omarchy Glass/ { next }
        { print }
    ' "$WAYBAR_CSS" > "$tmp"

    # Change * background-color to transparent
    sed -i 's/background-color: @background;/background-color: transparent;/' "$tmp"

    # Prepend glass block
    cat "$CONFIGS/waybar/style-prepend.css" "$tmp" > "$WAYBAR_CSS"
    rm "$tmp"
fi
ok "Waybar glass applied"

# --- 4. Mako notifications ---
info "Applying notification enhancements..."
MAKO_CONF="$HOME/.config/mako/config"
if [ -f "$MAKO_CONF" ]; then
    # Add border-radius if not present
    if ! grep -q 'border-radius' "$MAKO_CONF"; then
        echo "border-radius=12" >> "$MAKO_CONF"
    fi

    # Make background semi-transparent (append BF alpha if not already)
    if grep -q '^background-color=#[0-9a-fA-F]\{6\}$' "$MAKO_CONF"; then
        sed -i 's/^background-color=#\([0-9a-fA-F]\{6\}\)$/background-color=#\1BF/' "$MAKO_CONF"
    fi
fi
ok "Mako notifications styled"

# --- 5. Alacritty terminal transparency ---
info "Applying terminal transparency..."
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
if [ -f "$ALACRITTY_CONF" ]; then
    if ! grep -q 'opacity' "$ALACRITTY_CONF"; then
        # Add opacity after decorations line
        sed -i '/^decorations/a opacity = 0.92' "$ALACRITTY_CONF"
    fi
fi
ok "Alacritty transparency applied"

# --- 6. Walker launcher ---
info "Applying launcher glass theme..."
mkdir -p "$HOME/.config/walker/themes"
cp -r "$CONFIGS/walker/themes/omarchy-glass" "$HOME/.config/walker/themes/"

WALKER_CONF="$HOME/.config/walker/config.toml"
if [ -f "$WALKER_CONF" ]; then
    sed -i 's/^theme = .*/theme = "omarchy-glass"/' "$WALKER_CONF"
    # Update additional_theme_location to user config
    sed -i 's|^additional_theme_location = .*|additional_theme_location = "~/.config/walker/themes/"|' "$WALKER_CONF"
fi
ok "Walker glass theme installed"

# --- 7. SwayOSD glass ---
info "Applying SwayOSD glass styling..."
SWAYOSD_CSS="$HOME/.config/swayosd/style.css"
if [ -f "$SWAYOSD_CSS" ]; then
    # Round the progressbar first (before the global replacement)
    sed -i '/progressbar {/{n;s/border-radius: 0;/border-radius: 6px;/}' "$SWAYOSD_CSS"
    # Then round window and remaining elements
    sed -i 's/border-radius: 0;/border-radius: 12px;/' "$SWAYOSD_CSS"
    sed -i 's/opacity: 0.97;/opacity: 0.85;/' "$SWAYOSD_CSS"
fi
ok "SwayOSD glass applied"

# --- 8. btop transparency ---
info "Applying btop transparency..."
BTOP_CONF="$HOME/.config/btop/btop.conf"
if [ -f "$BTOP_CONF" ]; then
    sed -i 's/^theme_background = True/theme_background = False/' "$BTOP_CONF"
fi
ok "btop transparency applied"

# --- 9. Fastfetch ---
info "Applying fastfetch config..."
mkdir -p "$HOME/.config/fastfetch"
cp "$CONFIGS/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
ok "Fastfetch config installed"

# --- 10. Hooks ---
info "Installing update-safe hooks..."
mkdir -p "$HOME/.config/omarchy/hooks"
escaped_script_dir=$(printf '%s\n' "$SCRIPT_DIR" | sed 's/[&|]/\\&/g')

for hook in post-update theme-set; do
    if [ -f "$HOOKS/$hook" ]; then
        hook_dst="$HOME/.config/omarchy/hooks/$hook"
        sed "s|@@GLASS_DIR@@|$escaped_script_dir|g" "$HOOKS/$hook" > "$hook_dst"
        chmod +x "$hook_dst"
    fi
done
ok "Hooks installed"

# --- Restart services ---
info "Restarting services..."
omarchy-restart-waybar 2>/dev/null || true
omarchy-restart-walker 2>/dev/null || true
makoctl reload 2>/dev/null || true
ok "Services restarted"

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║      Installation complete!      ║"
echo "  ╚══════════════════════════════════╝"
echo ""
if [ -n "$(find "$BACKUP_DIR" -type f 2>/dev/null)" ]; then
    echo "  Custom configs backed up to:"
    echo "    $BACKUP_DIR"
    echo ""
fi
echo "  To uninstall:"
echo "    ./uninstall.sh"
echo ""
