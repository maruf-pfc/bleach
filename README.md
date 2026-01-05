# Bleach (Bash Edition)

> **Automated System Cleanup & Maintenance Tool for Linux**
> _Inspired by [ChrisTitusTech/linutil](https://github.com/ChrisTitusTech/linutil)_

Bleach is a powerful, interactive terminal utility designed to keep your Linux system clean, fast, and private. Rewritten entirely in **Bash** for maximum portability and control, it uses [gum](https://github.com/charmbracelet/gum) to provide a modern, easy-to-use interface.

![Demo](https://charm.sh/m/gum/demo.gif)
*(Example of the Gum interface used in Bleach)*

## ✨ Features

- **Interactive TUI**: Navigate easy menus to select exactly what you want to clean.
- **Deep Clean & Storage Recovery**:
  - **System**: APT (autoremove/clean), Docker (prune), Logs (vacuum), Temp files (`/tmp`), Trash.
  - **Dev**: Node (`npm`, `pnpm`, `yarn`), Python (deep `__pycache__` scan), Build Artifacts (`dist`, `build`).
  - **IDE**: Clear caches for VS Code and JetBrains IDEs.
  - **Privacy**: Clear user thumbnail caches.
- **System Maintenance**:
  - **SSD Trim**: Optimize SSD performance via `fstrim`.
  - **Storage Reporting**: Tracks and reports exactly how much disk space was reclaimed after every session.
- **Auto-Updates**:
  - **Self-Update**: Built-in weekly check for new versions.
  - **APT Hook**: Optional integration to check for Bleach updates whenever you run `sudo apt update`.
- **Logging**: Detailed logs of every action kept in `~/.local/share/bleach/logs`.

## 🚀 Installation

### One-Line Installer
This will install Bleach to `/opt/bleach`, create a symlink at `/usr/local/bin/bleach`, and install the `gum` dependency automatically.

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/bleach/main/install.sh | sudo bash
```

*(Note: If you are running from a local clone, just run `sudo ./install.sh`)*

### Prerequisites
Bleach uses **[gum](https://github.com/charmbracelet/gum)** for its UI. The installer handles this for you on Debian/Ubuntu systems.

## 🛠 Usage

Run the tool anytime from your terminal:

```bash
bleach
```

### Modes
- **System Cleanup**: Quick access to disk space recovery tools.
- **System Updates**: Centralized update management for APT, Flatpak, and Snap.
- **Maintenance**: Utilities for long-term health (SSD Trim, etc.).
- **View Logs**: Read what Bleach has done recently.

### Auto-Update
Bleach checks for updates weekly. You can also manually trigger a check:
```bash
bleach --check-update
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to add new modules or improve existing ones.

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.