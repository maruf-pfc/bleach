# Bleach

**A safe, cross-platform terminal-based system cleaner.**

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-blue.svg)

**Bleach** is a modern system maintenance tool designed for developers. It helps you keep your Linux environment fast and clean by removing unused caches, logs, and temporary files safely.

Unlike aggressive cleaning tools, Bleach respects your development environment—it never touches `.git` folders, source code, or active databases.

## ✨ Features

- **🖥️ Modern TUI**: built with [Textual](https://textual.textualize.io/) for a beautiful, interactive terminal experience.
- **🛡️ Safe by Default**: Explicitly ignores `.git` directories and critical system files.
- **🐧 Cross-Distro**: Smartly detects your package manager (APT, DNF, Pacman, etc.).
- **🧹 Deep Cleaning**:
  - **System**: Journal logs, temporary files, thumbnails.
  - **Dev Tools**: Docker (unused images/containers), NPM cache, Pip cache.
  - **Package Managers**: Clean APT/DNF/Pacman caches and autoremove unused packages.

## 📦 Installation

### Option 1: Debian/Ubuntu (.deb)

Download the latest release from the [Releases Page](https://github.com/maruf-pfc/bleach/releases).

```bash
sudo dpkg -i bleach_*.deb
sudo apt-get install -f  # Fix dependencies if needed
```

### Option 2: Python (Universal)

Install directly from the repository using `pip` (requires Python 3.8+):

```bash
pip install git+https://github.com/maruf-pfc/bleach.git
```

### Option 3: Build from Source

If you want to build the `.deb` package yourself:

```bash
git clone https://github.com/maruf-pfc/bleach.git
cd bleach
./build_deb.sh
sudo dpkg -i build/bleach_0.1.0_all.deb
```

## 🚀 Usage

Simply run `bleach` in your terminal:

```bash
bleach
```

- Navigate using **Arrow Keys** or **Mouse**.
- Toggle items with **Space** or **Click**.
- Run cleanup by clicking **"Run Cleanup"**.

### CLI Options

```bash
bleach --version   # Show version
bleach --help      # Show help message
```

## 🛠️ Development

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

1. **Clone the repo**
   ```bash
   git clone https://github.com/maruf-pfc/bleach.git
   cd bleach
   ```

2. **Install dev dependencies**
   ```bash
   pip install -e ".[dev]"
   ```

3. **Run Linting & Tests**
   ```bash
   ruff check .
   mypy .
   pytest
   ```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/maruf-pfc">Md. Maruf Sarker</a>
</p>