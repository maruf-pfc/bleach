# Bleach (Go Version)

A lightning-fast, terminal-based system cleaner and dashboard for Linux, rewritten in **Go** using the **Bubble Tea** framework.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Go](https://img.shields.io/badge/go-1.23+-00ADD8.svg?logo=go&logoColor=white)

## Features

-   **Unified Dashboard**: Real-time "Command Center" view with live CPU, RAM, and Disk usage bars.
-   **System Operations**:
    -   **Cleanup**: One-click `apt clean`, `autoremove`, and log rotation.
    -   **Updates**: streamlining `apt update && upgrade`.
    -   **Maintenance**: Automated system maintenance tasks.
-   **Responsive TUI**: Adapts layout automatically (Side-by-side or Stacked) based on terminal window size.
-   **Safe & Transparent**: Executes standard Linux commands (`sudo apt ...`) and streams output directly to you.

## 🚀 Installation

### From Source (Recommended)

Requires [Go 1.23+](https://go.dev/dl/) installed.

1.  Clone the repository:
    ```bash
    git clone https://github.com/maruf-pfc/bleach.git
    cd bleach
    ```
2.  Build the binary:
    ```bash
    go build ./cmd/bleach
    ```
3.  Run:
    ```bash
    ./bleach
    ```

### Optional: Install Globally
```bash
sudo mv bleach /usr/local/bin/
```

## 🎮 Usage

Launch Bleach from your terminal:
```bash
./bleach
```

### Interface
-   **Dashboard (Top)**: Shows your System Info (Hostname, Kernel) and Live Resource Usage.
-   **Menu (Bottom Left)**: Navigate using partially `Up` / `Down` arrows.
-   **Output (Bottom Right)**: Displays real-time logs of actions performed.

### Controls
| Key | Action |
| :--- | :--- |
| `↑` / `↓` / `k` / `j` | Navigate Menu |
| `Enter` | Select Action |
| `q` / `Ctrl+C` | Quit |

## 🛠 Tech Stack
-   **Language**: Go (Golang)
-   **Framework**: [Bubble Tea](https://github.com/charmbracelet/bubbletea) (The Elm Architecture for TUI)
-   **Styling**: [Lip Gloss](https://github.com/charmbracelet/lipgloss)
-   **System Stats**: [gopsutil](https://github.com/shirou/gopsutil)

## License
MIT License. Use at your own risk.