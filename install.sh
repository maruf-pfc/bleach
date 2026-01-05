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
export PATH=$PATH:/usr/local/go/bin

if ! command -v go &>/dev/null; then
    echo "Go not found. Installing Go 1.23.2..."
    
    # Detect Architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)  GO_ARCH="amd64" ;;
        aarch64) GO_ARCH="arm64" ;;
        arm64)   GO_ARCH="arm64" ;;
        *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    echo "Detected architecture: linux-$GO_ARCH"
    
    # Download Go
    curl -L "https://go.dev/dl/go1.23.2.linux-$GO_ARCH.tar.gz" -o /tmp/go.tar.gz
    
    # Remove old installation if exists
    rm -rf /usr/local/go
    
    # Extract
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    
    # Update PATH for this session
    export PATH=$PATH:/usr/local/go/bin
    
    echo "Go installed successfully."
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
