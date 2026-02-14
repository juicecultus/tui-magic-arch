# TUI Magic — Arch Linux (MacBook 12" 2017)

Matrix-green TUI environment for the Apple MacBook 12" 2017 (MacBook10,1) running Arch Linux.

## Hardware

- **Machine**: Apple MacBook 12" 2017 (Intel Core i7-7Y75)
- **Display**: 2304x1440 Retina (acpi_video0 backlight)
- **WiFi**: Broadcom BCM4350 (brcmfmac)
- **Camera**: FaceTime HD (facetimehd kernel module)
- **Keyboard**: Apple SPI keyboard with fn keys
- **Ambient Light Sensor**: ACPI0008 (auto-brightness daemon)
- **Kernel**: Custom 6.19 with CONFIG_VIDEOBUF2_DMA_SG

## Features

- **Matrix green theme** across all TUI tools
- **tmux-based workflow** with Ctrl-a shortcuts
- **Hardware controls** in status bar: display brightness, volume, keyboard backlight
- **Battery status** with accurate charge % and time remaining
- **Auto-brightness** with 50% hysteresis on manual override
- **Matrix screensaver** (cmatrix): 2min idle on battery, 5min on AC
- **TLP power management** optimized for MacBook hardware
- **Fn key handler** via evtest systemd service

## Quick Start

```bash
git clone https://github.com/juicecultus/tui-magic-arch.git
cd tui-magic-arch
chmod +x install.sh
./install.sh
```

Log out and back in. tmux starts automatically.

## Tmux Shortcuts (Ctrl-a, then key)

| Key | Action        | Key | Action      |
|-----|---------------|-----|-------------|
| m   | matrix        | b   | btop        |
| n   | ranger        | t   | tig         |
| D   | dashboard     | g   | disk (gdu)  |
| v   | cava          | M   | cmus        |
| c   | calcurse      | R   | newsboat    |
| T   | clock         | B   | bonsai      |
| w   | wifi (nmtui)  | W   | web (w3m)   |
| H   | cheatsheet    | r   | reload conf |

## File Structure

```
.bashrc              Shell config, aliases, prompt
.bash_profile        Login shell → sources .bashrc
.tmux.conf           tmux config, theme, key bindings, screensaver
bin/
  motd               Login banner (system info, battery, CPU temp)
  screensaver        Standalone matrix screensaver (backup)
  view               Universal file viewer (images, PDF, video, etc)
tmux/
  hw.sh              Status bar: brightness, volume, kbd backlight
  net.sh             Status bar: WiFi SSID
  bat.sh             Status bar: battery %, status, time remaining
  cpu.sh             Status bar: CPU usage
  mem.sh             Status bar: RAM usage
  dashboard.sh       Split-pane dashboard layout
  cheatsheet.txt     Full shortcut reference
system/
  macbook-fnkeys.sh       Fn key handler (brightness, volume, kbd)
  macbook-fnkeys.service  systemd unit for fn key handler
  wifi-resume.sh          WiFi reconnect after suspend
install.sh           Full installer (packages + config deployment)
RESTORE.md           Disaster recovery from btrfs snapshots
```

## Power Management

TLP is configured with MacBook-specific optimizations:
- CPU turbo boost off on battery
- PCIe ASPM powersupersave on battery
- PCI runtime PM auto for all devices
- WiFi power save on battery
- Audio power save (1s idle on battery)

## Restore from Snapshot

See [RESTORE.md](RESTORE.md) for full disaster recovery instructions using btrfs snapshots backed up to the Raspberry Pi 5.

## Related

- [tui-magic](https://github.com/juicecultus/tui-magic) — Debian version for IBM ThinkPad X40
