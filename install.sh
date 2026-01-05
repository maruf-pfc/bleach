#!/bin/bash
set -e

# Bleach - One-Line Runner/Installer
# Can be run directly via: curl ... | bash

# Configuration
REPO_URL="https://github.com/maruf-pfc/bleach.git"
INSTALL_DIR="$HOME/.local/share/bleach"
BIN_DIR="$HOME/.local/bin"
BRANCH="main"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Bleach System Cleaner ===${NC}"

# 1. Prerequisite Check
if ! command -v git &> /dev/null || ! command -v python3 &> /dev/null; then
    echo "Error: 'git' and 'python3' are required."
    echo "Please install them via your package manager."
    exit 1
fi

# 2. Update/Clone
echo -e "${BLUE}[+] Fetching latest version...${NC}"
mkdir -p "$INSTALL_DIR"
if [ -d "$INSTALL_DIR/.git" ]; then
    cd "$INSTALL_DIR" && git pull -q
else
    git clone -q -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

# 3. Setup Python Environment (Quietly)
echo -e "${BLUE}[+] Preparing environment...${NC}"
cd "$INSTALL_DIR"
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install -q --upgrade pip
pip install -q .

# 4. Install Binary Wrapper
mkdir -p "$BIN_DIR"
LAUNCHER="$BIN_DIR/bleach"
cat <<EOF > "$LAUNCHER"
#!/bin/bash
exec "$INSTALL_DIR/venv/bin/bleach" "\$@"
EOF
chmod +x "$LAUNCHER"

# 5. Run Immediately
echo -e "${GREEN}[+] Launching Bleach...${NC}"
exec "$LAUNCHER"
