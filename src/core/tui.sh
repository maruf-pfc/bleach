#!/usr/bin/env bash

# Constants (Exported for modules)
export SIDEBAR_WIDTH=25
export COLOR_PRIMARY="212"    # Pink/Neon
export COLOR_SECONDARY="99"   # Purple
export COLOR_ACCENT="51"      # Cyan
export COLOR_MUTED="240"      # Grey

# @description Initialize TUI settings
init_tui() {
    # Check for gum
    if ! command -v gum &>/dev/null; then
        echo "Error: 'gum' is required for the TUI."
        exit 1
    fi
}

# @description Run a command with verbose output (User Request: Visible Logs)
run_verbose() {
    local msg="$1"
    local cmd="$2"
    
    echo ""
    gum style --foreground "$COLOR_ACCENT" ":: $msg"
    echo "----------------------------------------"
    eval "$cmd" | tee -a "$CURRENT_LOG_FILE"
    echo "----------------------------------------"
}

# @description Run a command silently with a spinner
run_silent() {
    local msg="$1"
    local cmd="$2"
    
    gum spin --spinner dot --title "$msg" -- bash -c "$cmd >> $CURRENT_LOG_FILE 2>&1"
}

# @description Confirm an action
confirm_action() {
    local msg="$1"
    gum confirm "$msg"
}
