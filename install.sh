#!/usr/bin/env bash

# Bleach Installer (Go Version)
# Installs/Updates Bleach to /opt/bleach by building from source

set -e

REPO_URL="https://github.com/maruf-pfc/bleach.git"
INSTALL_DIR="/opt/bleach"
BIN_LINK="/usr/local/bin/bleach"

# Ensure root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)." 
   exit 1
fi

echo "Installing Bleach v1.0.0..."

# 1. Check for Go
# Add standard Go path just in case sudo reset it
export PATH=$PATH:/usr/local/go/bin

if ! command -v go &>/dev/null; then
    echo "Error: 'go' command not found."
    echo "Tips:"
    echo "  1. If Go is installed in your home directory, run this script with: sudo -E ./install.sh"
    echo "  2. Or install Go globally: https://go.dev/doc/install"
    exit 1
fi

# 2. Clean Install / Update
if [[ -d "$INSTALL_DIR" ]]; then
    echo "Removing old version at $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
fi

# 3. Clone/Copy Source
echo "Setting up source..."
if [[ -d "cmd" && -f "go.mod" ]]; then
    # Installing from current directory
    echo "Installing from local source..."
    mkdir -p "$INSTALL_DIR"
    cp -r ./* "$INSTALL_DIR/"
else
    # Cloning from remote
    echo "Cloning repository..."
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

# 4. Build Binary
echo "Building Bleach binary..."
cd "$INSTALL_DIR"
# Ensure dependencies
export GOCACHE="/tmp/go-build-cache" # Use temp cache for root build
go mod tidy
go build -o bleach ./cmd/bleach

# 5. Permissions & Symlink
chmod +x "$INSTALL_DIR/bleach"

echo "Creating symlink at $BIN_LINK..."
ln -sf "$INSTALL_DIR/bleach" "$BIN_LINK"

echo "========================================"
echo "Bleach v1.0.0 installed successfully!"
echo "Run 'bleach' to start."
echo "========================================"
