# Omarchy Glass — Project Guide

Frosted glass visual enhancements for [Omarchy](https://omarchy.org/) (Arch Linux + Hyprland).
Theme-agnostic: automatically adapts border gradient to any Omarchy theme.

## Architecture

```
omarchy-glass/
├── install.sh              # Main installer — backs up, patches, copies, hooks
├── uninstall.sh            # Restores from backup or Omarchy defaults
├── remote-install.sh       # One-liner wrapper (curl | bash)
├── remote-uninstall.sh     # One-liner wrapper for uninstall
├── configs/
│   ├── hypr/
│   │   ├── looknfeel.conf  # Core: animations, blur, shadows, layerrules
│   │   └── hyprlock.conf   # Lock screen: input field, fade animations
│   ├── waybar/
│   │   └── style-prepend.css  # Prepended to user's waybar style.css
│   ├── walker/themes/omarchy-glass/
│   │   ├── style.css       # GTK4 CSS glass theme
│   │   └── layout.xml      # GTK4 layout
│   └── fastfetch/
│       └── config.jsonc    # System info layout
├── hooks/
│   ├── post-update         # Restores glass after omarchy-update
│   └── theme-set           # Syncs border gradient + mako on theme change
└── lib/
    └── update-border-gradient.sh  # Extracts theme colors → border gradient
```

## Config Strategy: Replace vs Patch

| Strategy | Files | How |
|----------|-------|-----|
| **Replace** (full copy) | `looknfeel.conf`, `hyprlock.conf`, `fastfetch/config.jsonc` | `cp` source → target |
| **Prepend** | `waybar/style.css` | Cat glass CSS + existing CSS |
| **Patch** (in-place sed) | `mako/config`, `alacritty.toml`, `swayosd/style.css`, `btop.conf`, `waybar/config.jsonc` | `sed -i` / `grep` + append |
| **Theme install** | `walker/themes/omarchy-glass/` | `cp -r` theme directory |

This matters for hooks and uninstall — "replaced" files are restored from backup/defaults;
"patched" files need targeted sed/grep fixups in hooks.

## install.sh Re-install Safety

The awk block at line ~112 strips existing glass CSS blocks from waybar before re-prepending.
**If you add a new CSS selector to `style-prepend.css`, also add it to the awk pattern** in install.sh
so re-install doesn't produce duplicates.

## Hooks

Hooks use `@@GLASS_DIR@@` placeholder, replaced with actual path by install.sh at install time.

- **post-update**: Triggered by `omarchy-update`. Does full-file restore for `looknfeel.conf`,
  then runs targeted sed patches for mako/waybar/alacritty/swayosd/btop.
- **theme-set**: Triggered by theme change. Only patches `col.active_border` in `looknfeel.conf`
  (via `lib/update-border-gradient.sh`) and re-applies mako transparency.
  Does NOT restore full files — theme changes don't overwrite `looknfeel.conf`.

## Uninstall

Full-file strategy: restores every config from `~/.config/omarchy/glass-backup/`,
falls back to `omarchy-refresh-config`, then to Omarchy defaults at `~/.local/share/omarchy/config/`.
Removes walker theme dir and hooks. No per-line reversal needed.

## Key Design Values

- **All visual values are hard-coded** (no config file for glass itself). Consistent look, simple code.
- **12px rounding** everywhere (windows, mako, swayosd, hyprlock). Waybar is 17px (pill shape).
- **0.75 alpha** for glass backgrounds (waybar, walker). Mako uses BF suffix (≈0.75).
- **Backup is smart**: only saves files that differ from Omarchy defaults, never overwrites existing backups.

## Animation System

All Hyprland animations live in `looknfeel.conf`:

- Window enter/exit: slide with easeOutQuint
- Layer enter: slide with easeOutQuint (notifications slide in, OSD pops)
- Layer exit: fade with easeOutQuint
- Workspace switch: slide with custom fluent bezier
- Border gradient: infinite linear loop

Per-layer overrides via `layerrule = animation <style>, match:namespace <name>`:
- mako → `slide` (notifications slide from edge)
- swayosd → `popin` (volume/brightness bubble pop)

CSS transitions (GTK):
- Waybar workspace buttons: 300ms ease (background, border, text-shadow)
- Walker items: 200ms ease (background on hover/select)

## Conventions

- Shell scripts: `set -euo pipefail`, colored output via `info()`/`ok()`/`warn()`
- sed patterns must handle re-runs gracefully (check before patching, don't double-apply)
- Hyprland uses `match:namespace` syntax (requires Hyprland 0.53+)
- Walker uses GTK4 CSS (supports `transition` but beware `all: unset` resets)
- Waybar uses GTK3 CSS
