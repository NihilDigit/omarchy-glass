# Omarchy Glass

Frosted glass visual enhancements for [Omarchy](https://omarchy.org/) — a modern Arch Linux distribution with Hyprland.

Theme-agnostic: works with **any** Omarchy theme out of the box.

<!-- TODO: replace with actual screenshot -->
<!-- ![preview](screenshots/preview.png) -->

## What it does

| Component | Enhancement |
|-----------|-------------|
| **Windows** | 12px rounded corners, soft shadows, smooth slide animations |
| **Waybar** | Floating pill with frosted glass background |
| **Walker** | Frosted glass launcher with rounded corners |
| **Notifications** | Semi-transparent background with rounded corners |
| **Lock screen** | Rounded input field with fade animations |
| **Terminal** | Subtle transparency with background blur |
| **Borders** | Animated gradient border (works with gradient-capable themes) |
| **Workspaces** | Smooth slide transition between workspaces |

## Install

One-liner:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nihildigit/omarchy-glass/main/remote-install.sh)
```

Or manually:

```bash
git clone https://github.com/nihildigit/omarchy-glass.git
cd omarchy-glass
./install.sh
```

The installer will:
1. Back up your existing configs to `~/.config/omarchy/glass-backup/`
2. Apply visual enhancements (patching, not replacing, where possible)
3. Install hooks to survive `omarchy-update` and theme changes
4. Restart affected services

## Uninstall

```bash
~/.local/share/omarchy-glass/uninstall.sh
```

Or if you cloned manually:

```bash
cd omarchy-glass
./uninstall.sh
```

Restores all original configs from the backup created during install.

## Update-safe

Omarchy Glass installs two hooks:

- **`post-update`** — Automatically restores visual tweaks if `omarchy-update` overwrites them
- **`theme-set`** — Re-applies notification transparency after switching themes

## What gets modified

```
~/.config/
├── hypr/
│   ├── looknfeel.conf        # Rounding, shadows, blur, animations, layerrules
│   └── hyprlock.conf         # Rounded input, fade animations
├── waybar/
│   ├── config.jsonc          # Floating margins + height (patched, not replaced)
│   └── style.css             # Glass background prepended (your custom styles preserved)
├── mako/
│   └── config                # border-radius + background alpha (patched)
├── alacritty/
│   └── alacritty.toml        # opacity added (patched)
├── walker/
│   ├── config.toml           # Theme switched to omarchy-glass
│   └── themes/omarchy-glass/ # Glass theme files
└── omarchy/
    └── hooks/
        ├── post-update       # Survives omarchy-update
        └── theme-set         # Survives theme changes
```

## Requirements

- [Omarchy](https://omarchy.org/) 3.x+
- Hyprland 0.44+

## License

MIT
