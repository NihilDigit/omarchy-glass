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

read -rp "  Continue? [Y/n] " confirm
[[ "${confirm,,}" == "n" ]] && exit 0
echo ""

# --- Backup existing configs ---
info "Backing up existing configs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup() {
    local src="$1"
    local name="$2"
    if [ -e "$src" ]; then
        cp -r "$src" "$BACKUP_DIR/$name"
    fi
}

backup "$HOME/.config/hypr/looknfeel.conf" "looknfeel.conf"
backup "$HOME/.config/hypr/hyprlock.conf" "hyprlock.conf"
backup "$HOME/.config/waybar/config.jsonc" "waybar-config.jsonc"
backup "$HOME/.config/waybar/style.css" "waybar-style.css"
backup "$HOME/.config/mako/config" "mako-config"
backup "$HOME/.config/alacritty/alacritty.toml" "alacritty.toml"
backup "$HOME/.config/walker/config.toml" "walker-config.toml"
if [ -d "$HOME/.config/walker/themes" ]; then
    backup "$HOME/.config/walker/themes" "walker-themes"
fi
ok "Backup complete"

# --- 1. Hyprland look & feel ---
info "Applying Hyprland visual enhancements..."
cp "$CONFIGS/hypr/looknfeel.conf" "$HOME/.config/hypr/looknfeel.conf"
ok "looknfeel.conf installed"

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
    mv "$tmp" "$WAYBAR_CONF"
fi

# Prepend glass style to waybar CSS
WAYBAR_CSS="$HOME/.config/waybar/style.css"
if [ -f "$WAYBAR_CSS" ]; then
    # Remove any existing window#waybar block (in case of re-install)
    tmp=$(mktemp)
    awk '
        /^window#waybar \{/ { skip=1; next }
        skip && /^\}/ { skip=0; next }
        skip { next }
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

# --- 7. Hooks ---
info "Installing update-safe hooks..."
mkdir -p "$HOME/.config/omarchy/hooks"

for hook in post-update theme-set; do
    if [ -f "$HOOKS/$hook" ]; then
        cp "$HOOKS/$hook" "$HOME/.config/omarchy/hooks/$hook"
        chmod +x "$HOME/.config/omarchy/hooks/$hook"
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
echo "  Backups saved to:"
echo "    $BACKUP_DIR"
echo ""
echo "  To uninstall:"
echo "    ./uninstall.sh"
echo ""
