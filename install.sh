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

echo "Installing Bleach v1.0.1..."

# 1. Check for Go
export PATH=$PATH:/usr/local/go/bin

NEED_GO=true

if command -v go &>/dev/null; then
    GO_VERSION=$(go version | awk '{print $3}' | tr -d "go")
    # Simple check for 1.23
    if [[ "$(printf '%s\n' "1.23" "$GO_VERSION" | sort -V | head -n1)" == "1.23" ]]; then
        echo "Found Go $GO_VERSION (>= 1.23). Skipping installation."
        NEED_GO=false
    else
        echo "Found Go $GO_VERSION, but need >= 1.23."
    fi
fi

if [ "$NEED_GO" = true ]; then
    echo "Installing Go 1.23.2..."
    
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)  GO_ARCH="amd64" ;;
        aarch64) GO_ARCH="arm64" ;;
        arm64)   GO_ARCH="arm64" ;;
        *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    echo "Detected architecture: linux-$GO_ARCH"
    
    curl -L "https://go.dev/dl/go1.23.2.linux-$GO_ARCH.tar.gz" -o /tmp/go.tar.gz
    rm -rf /usr/local/go
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
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
export GOCACHE="/tmp/go-build-cache"
go mod tidy
go build -o bleach ./cmd/bleach

# 5. Permissions & Symlink
chmod +x "$INSTALL_DIR/bleach"

echo "Creating symlink at $BIN_LINK..."
ln -sf "$INSTALL_DIR/bleach" "$BIN_LINK"

echo "========================================"
echo "Bleach v1.0.1 installed successfully!"
echo "Run 'bleach' to start."
echo "========================================"
