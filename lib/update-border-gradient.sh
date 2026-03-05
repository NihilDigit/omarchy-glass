#!/bin/bash
# Reads current theme colors and updates looknfeel.conf border gradient.
# Called by install.sh and theme-set hook.

COLORS_FILE="$HOME/.config/omarchy/current/theme/colors.toml"
LOOKNFEEL="$HOME/.config/hypr/looknfeel.conf"

if [ ! -f "$COLORS_FILE" ] || [ ! -f "$LOOKNFEEL" ]; then
    exit 0
fi

# Extract color4 (blue/teal) and color5 (purple/pink) — hex without #
c4=$(grep '^color4' "$COLORS_FILE" | cut -d'"' -f2 | tr -d '#')
c5=$(grep '^color5' "$COLORS_FILE" | cut -d'"' -f2 | tr -d '#')

if [ -z "$c4" ] || [ -z "$c5" ]; then
    exit 0
fi

# Update active border gradient in looknfeel.conf
sed -i "s/col.active_border = .*/col.active_border = rgba(${c4}ee) rgba(${c5}ee) 45deg/" "$LOOKNFEEL"
