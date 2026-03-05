# Omarchy Glass

Frosted glass visual enhancements for [Omarchy](https://omarchy.org/) — a modern Arch Linux distribution with Hyprland.

Theme-agnostic: works with **any** Omarchy theme out of the box.

https://github.com/user-attachments/assets/c4a1c9ce-bcb9-441c-b05f-24bdb3daca88

## What it does

| Component | Enhancement |
|-----------|-------------|
| **Windows** | 12px rounded corners, soft shadows, smooth slide animations |
| **Waybar** | Floating pill with frosted glass background |
| **Walker** | Frosted glass launcher with rounded corners |
| **Notifications** | Semi-transparent background with rounded corners |
| **Lock screen** | Rounded input field with fade animations |
| **Terminal** | Subtle transparency with background blur |
| **Fastfetch** | Arch logo, streamlined layout with dynamic hardware detection, Omarchy version info |
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
1. Compare your configs against Omarchy defaults — only backs up files you've customized
2. Apply visual enhancements (replaces looknfeel/hyprlock/fastfetch; patches waybar/mako/alacritty/walker in-place)
3. Install hooks to survive `omarchy-update` and theme changes
4. Restart affected services

## Uninstall

One-liner:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nihildigit/omarchy-glass/main/remote-uninstall.sh)
```

Or locally:

```bash
~/.local/share/omarchy-glass/uninstall.sh
```

Customized configs are restored from backup; unmodified configs are refreshed to Omarchy defaults via `omarchy-refresh-config`.

## Update-safe

Omarchy Glass installs two hooks:

- **`post-update`** — Restores visual tweaks if `omarchy-update` overwrites them
- **`theme-set`** — Updates border gradient to match new theme colors, re-applies notification transparency

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
├── fastfetch/
│   └── config.jsonc          # Streamlined system info layout
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
- Hyprland 0.53+ (uses `match:namespace` layerrule syntax)

## License

MIT
