# i3 Configuration and Scripts

This repository contains my personal i3 window manager configuration and utility scripts for Parrot OS.

## Contents

- `config`: Main i3 configuration file.
- `i3status.conf`: Configuration for the i3status bar.
- `scripts/`: Custom shell scripts for system management:
  - `battery_check.sh`: Battery monitoring with JARVIS voice notifications.
  - `copy_date.sh`: Utility to copy the current date to clipboard.
  - `copy_time.sh`: Utility to copy the current time to clipboard.
  - `volume.sh`: Volume control script.

## Setup

To use this configuration, clone this repository into `~/.config/i3`:

```bash
git clone <remote-url> ~/.config/i3
```

Ensure the scripts in `scripts/` are executable:

```bash
chmod +x ~/.config/i3/scripts/*.sh
```
