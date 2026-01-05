#!/usr/bin/env bash

# Bleach Installer
# Installs/Updates Bleach to /opt/bleach and sets up update hooks

set -e

REPO_URL="https://github.com/yourusername/bleach.git" # Replace with actual URL logic in real usage, utilizing local path for now if needed or placeholder
INSTALL_DIR="/opt/bleach"
BIN_LINK="/usr/local/bin/bleach"

# Ensure root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)." 
   exit 1
fi

echo "Installing Bleach..."

# 1. Install Dependencies (gum)
if ! command -v gum &>/dev/null; then
    echo "Installing dependency: gum..."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list
    apt update && apt install gum -y
fi

# 2. Clean Install / Update
if [[ -d "$INSTALL_DIR" ]]; then
    echo "Removing old version at $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    # Or git pull? Cleaner to re-clone to ensure pristine state
fi

echo "Cloning repository..."
# In a real one-line installer, this would clone. 
# For this dev environment, we assume the current directory IS the source.
# So we copy instead of clone if we are running from source.
if [[ -d "src" && -f "bleach" ]]; then
    echo "Installing from local source..."
    mkdir -p "$INSTALL_DIR"
    cp -r ./* "$INSTALL_DIR/"
else
    # Fallback to clone
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# 3. Permissions & Symlink
chmod +x "$INSTALL_DIR/bleach"
chmod +x "$INSTALL_DIR/src/core/"*.sh
chmod +x "$INSTALL_DIR/src/modules/"*/*.sh # Recursive?

echo "Creating symlink at $BIN_LINK..."
ln -sf "$INSTALL_DIR/bleach" "$BIN_LINK"

# 4. APT Hook Setup
if [[ -d "/etc/apt/apt.conf.d" ]]; then
    # Default to YES for auto-update if silent, or valid functionality
    echo "Setting up APT auto-update hook..."
    cat > /etc/apt/apt.conf.d/99bleach <<EOF
APT::Update::Pre-Invoke {"$BIN_LINK --check-update || true";};
EOF
    echo "APT hook installed at /etc/apt/apt.conf.d/99bleach"
fi

echo "========================================"
echo "Bleach installed successfully!"
echo "Run 'bleach' to start."
echo "========================================"
