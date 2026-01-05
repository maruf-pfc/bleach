# Contributing to Bleach

Thank you for your interest in contributing to Bleach! We have moved to a modular Bash architecture to make system maintenance accessible and transparent.

## Project Structure

- **`bleach`**: The main entry point script.
- **`install.sh`**: The one-line installer and updater.
- **`src/core/`**: Core libraries (`tui.sh`, `logging.sh`, `state.sh`, `self_update.sh`).
- **`src/modules/`**: Standalone scripts for specific tasks.
    - `cleanup/`: Cleaning caches, logs, IDEs, trash, etc.
    - `updates/`: System updates (APT, Snap, Flatpak).
    - `maintenance/`: System optimization.

## How to Add a New Module

1. **Create a Script**: Add a new `.sh` file in the appropriate `src/modules/<category>/` directory.
2. **Define a Function**: The script should export a function (e.g., `cleanup_myapp()`).
3. **User Interaction**:
    - Use `gum confirm` for yes/no prompts.
    - Use `run_with_spinner` for long-running commands.
    - Use `log_info` / `log_error` for feedback.
4. **Register**: Add your function to the `run_<category>_menu` function in `src/modules/<category>/main.sh`.

## Style Guide

- **Shebang**: Always use `#!/usr/bin/env bash`.
- **Safety**: Use `set -Eeuo pipefail` where possible, or handle errors explicitly.
- **Indentation**: 4 spaces.
- **Comments**: Comment complexity; keep it simple.

## Pull Requests

1. Fork the repo.
2. Create a new branch (`git checkout -b feature/my-new-feature`).
3. Commit your changes.
4. Push to the branch.
5. Open a Pull Request.
