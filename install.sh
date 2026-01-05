#!/bin/bash
set -e

# Configuration
REPO_URL="https://github.com/maruf-pfc/bleach.git"
INSTALL_DIR="$HOME/.local/share/bleach"
BIN_DIR="$HOME/.local/bin"
BRANCH="main"  # Update to 'dev' if needed during testing, defaulting to main for release

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Bleach Installer ===${NC}"

# 1. Check Dependencies
echo -e "${BLUE}[1/5] Checking usage requirements...${NC}"
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is not installed."
    exit 1
fi
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed."
    exit 1
fi

# 2. Setup Directory
echo -e "${BLUE}[2/5] Fetching repository...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation in $INSTALL_DIR..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "Cloning into $INSTALL_DIR..."
    git clone -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# 3. Create/Update Virtual Environment
echo -e "${BLUE}[3/5] Setting up Python environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate

# 4. Install Dependencies
echo -e "${BLUE}[4/5] Installing dependencies...${NC}"
pip install -q --upgrade pip
pip install -q .

# 5. Setup Binary
echo -e "${BLUE}[5/5] Configuring executable...${NC}"
mkdir -p "$BIN_DIR"

# Create a launcher script
LAUNCHER="$BIN_DIR/bleach"
cat <<EOF > "$LAUNCHER"
#!/bin/bash
exec "$INSTALL_DIR/venv/bin/bleach" "\$@"
EOF
chmod +x "$LAUNCHER"

echo -e "${GREEN}Instance installed successfully!${NC}"
echo ""

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${YELLOW}Warning: $BIN_DIR is not in your PATH.${NC}"
    echo "Add line below to your .bashrc or .zshrc:"
    echo "  export PATH=\"\$PATH:$BIN_DIR\""
    echo ""
    echo "Then restart your terminal."
    echo "For now, you can run it via: $LAUNCHER"
else
    echo -e "You can run bleach by typing: ${GREEN}bleach${NC}"
fi

# Optional: Run immediately
echo ""
echo -e "${BLUE}Starting Bleach...${NC}"
"$LAUNCHER"
