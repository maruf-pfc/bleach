#!/usr/bin/env bash

# ==================================================
# Bleach
# Personal Auto Cleanup Tool for Developers
#
# Author : Md. Maruf Sarker | Niloy Bhowmick
# License: MIT
# OS     : Any Distro based on Debian (APT Package Manager)
#
# Purpose:
#   Keep a developer machine fast, clean, and predictable
#   by safely removing caches, logs, and unused resources.
#
# Safety:
#   - NEVER touches .git directories
#   - NEVER deletes project source code
#   - Conservative by default
# ==================================================

set -Eeuo pipefail

# ---------------- COLORS ----------------
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# ---------------- UI HELPERS ----------------
log()  { echo -e "${GREEN}[✓] $1${RESET}"; }
warn() { echo -e "${YELLOW}[!] $1${RESET}"; }
err()  { echo -e "${RED}[✗] $1${RESET}"; }
info() { echo -e "${BLUE}[→] $1${RESET}"; }

# ---------------- GLOBAL STATE ----------------
CURRENT_STEP=0
TOTAL_STEPS=0
SUCCESS=0
SKIPPED=0

# ---------------- STEP REGISTRATION ----------------
step() {
  TOTAL_STEPS=$((TOTAL_STEPS + 1))
}

progress() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  local percent=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
  local filled=$(( percent / 5 ))
  local empty=$(( 20 - filled ))

  printf "${BLUE}Progress:${RESET} ["
  printf "%0.s#" $(seq 1 $filled)
  printf "%0.s-" $(seq 1 $empty)
  printf "] %d%% (%d/%d)\n" "$percent" "$CURRENT_STEP" "$TOTAL_STEPS"
}

# ---------------- ERROR HANDLER ----------------
trap 'err "Non-critical error occurred. Continuing safely..."; SKIPPED=$((SKIPPED+1))' ERR

# ---------------- HELP & DOCS ----------------
show_help() {
cat <<'EOF'
bleach — Personal system cleanup tool for developers

USAGE:
  bleach.           Run full cleanup
  bleach --help     Show this help
  bleach --about    About this tool
  bleach --no-clear Do not clear terminal UI

WHAT IT DOES:
  - Cleans system & package manager caches
  - Removes unused Docker resources
  - Clears IDE, language, and user caches
  - Trims SSD for better performance

WHAT IT NEVER DOES:
  - Deletes .git directories
  - Removes source code
  - Touches databases or system binaries

RECOMMENDED:
  Run weekly or bi-weekly.

EOF
}

show_about() {
cat <<'EOF'
bleach
---------
A conservative, developer-focused system maintenance tool.

Philosophy:
  "Fast systems are maintained, not upgraded."

Built for:
  Developers, students, learners, and engineers
  who want a clean Linux environment without risk.

Author:
  Md. Maruf Sarker
EOF
}

case "${1:-}" in
  --help)  show_help; exit 0 ;;
  --about) show_about; exit 0 ;;
esac

NO_CLEAR=false
[[ "${1:-}" == "--no-clear" ]] && NO_CLEAR=true

# ---------------- HEADER ----------------
$NO_CLEAR || clear
echo "========================================"
echo "      BLEACH · SYSTEM MAINTENANCE"
echo "========================================"

# ---------------- SUDO (ASK ONCE) ----------------
if command -v sudo &>/dev/null; then
  sudo -v
fi

# ==================================================
# REGISTER STEPS (auto-count)
# ==================================================
step # APT
step # Logs
step # Docker
step # npm
step # pnpm
step # Python
step # Build artifacts
step # VS Code
step # JetBrains
step # Snap
step # Flatpak
step # Temp + SSD

# ==================================================
# EXECUTION
# ==================================================

# 1. APT CLEAN
warn "Cleaning APT cache & unused packages..."
sudo apt clean -y || true
sudo apt autoclean -y || true
sudo apt autoremove -y || true
log "APT cleanup done"; SUCCESS=$((SUCCESS+1)); progress

# 2. SYSTEM LOGS
warn "Cleaning system logs..."
sudo journalctl --vacuum-size=100M || true
log "System logs cleaned"; SUCCESS=$((SUCCESS+1)); progress

# 3. DOCKER
if command -v docker &>/dev/null; then
  warn "Cleaning Docker unused resources..."
  docker system prune -f || true
  log "Docker cleaned"; SUCCESS=$((SUCCESS+1))
else
  info "Docker not installed, skipping"; SKIPPED=$((SKIPPED+1))
fi
progress

# 4. npm
if command -v npm &>/dev/null; then
  warn "Cleaning npm cache..."
  npm cache clean --force || true
  log "npm cache cleaned"; SUCCESS=$((SUCCESS+1))
else
  info "npm not installed, skipping"; SKIPPED=$((SKIPPED+1))
fi
progress

# 5. pnpm
if command -v pnpm &>/dev/null; then
  warn "Pruning pnpm store..."
  pnpm store prune || true
  log "pnpm store cleaned"; SUCCESS=$((SUCCESS+1))
else
  info "pnpm not installed, skipping"; SKIPPED=$((SKIPPED+1))
fi
progress

# 6. PYTHON CACHE (SAFE)
warn "Removing Python cache files..."
rm -rf ~/.cache/pip ~/.cache/pypoetry ~/.cache/virtualenv || true

PROJECT_DIRS=("$HOME/projects" "$HOME/code" "$HOME/dev")
for dir in "${PROJECT_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  find "$dir" \
    -path "*/.git" -prune -o \
    -type d -name "__pycache__" \
    -exec rm -rf {} + 2>/dev/null || true
done

log "Python cache cleaned safely"; SUCCESS=$((SUCCESS+1)); progress

# 7. BUILD ARTIFACTS
warn "Removing common build artifacts..."
rm -rf ~/node_modules ~/dist ~/build 2>/dev/null || true
log "Build artifacts cleaned"; SUCCESS=$((SUCCESS+1)); progress

# 8. VS CODE
warn "Cleaning VS Code cache..."
rm -rf ~/.config/Code/Cache ~/.config/Code/CachedData 2>/dev/null || true
log "VS Code cache cleaned"; SUCCESS=$((SUCCESS+1)); progress

# 9. JETBRAINS
warn "Cleaning JetBrains cache..."
rm -rf ~/.cache/JetBrains 2>/dev/null || true
log "JetBrains cache cleaned"; SUCCESS=$((SUCCESS+1)); progress

# 10. SNAP
if command -v snap &>/dev/null; then
  warn "Cleaning Snap cache..."
  sudo rm -rf /var/lib/snapd/cache/* || true
  log "Snap cache cleaned"; SUCCESS=$((SUCCESS+1))
else
  info "Snap not installed, skipping"; SKIPPED=$((SKIPPED+1))
fi
progress

# 11. FLATPAK
if command -v flatpak &>/dev/null; then
  warn "Removing unused Flatpak packages..."
  flatpak uninstall --unused -y || true
  log "Flatpak cleaned"; SUCCESS=$((SUCCESS+1))
else
  info "Flatpak not installed, skipping"; SKIPPED=$((SKIPPED+1))
fi
progress

# 12. TEMP + SSD
warn "Cleaning temporary files..."
sudo rm -rf /tmp/* || true

warn "Running SSD trim..."
sudo fstrim -av || true

log "Temp cleaned & SSD trimmed"; SUCCESS=$((SUCCESS+1)); progress

# ==================================================
# SUMMARY
# ==================================================
echo
echo "========================================"
echo -e "${GREEN}CLEANUP COMPLETED${RESET}"
echo "----------------------------------------"
echo " Successful steps : $SUCCESS"
echo " Skipped / failed : $SKIPPED"
echo " Total steps      : $TOTAL_STEPS"
echo "========================================"
