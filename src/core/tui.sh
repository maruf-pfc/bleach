#!/usr/bin/env bash

# Colors
COLOR_PRIMARY="99"   # Purpleish
COLOR_SECONDARY="212" # Pinkish
COLOR_ACCENT="50"    # Cyan/Teal

draw_header() {
    clear
    gum style \
        --border normal \
        --margin "1" \
        --padding "1" \
        --border-foreground "$COLOR_PRIMARY" \
        --foreground "$COLOR_SECONDARY" \
        "BLEACH" \
        "System Maintenance & Cleanup"
}

# Helper to show a spinner while running a command
run_with_spinner() {
    local msg="$1"
    local command="$2"
    
    gum spin --spinner dot --title "$msg" -- bash -c "$command"
}

# Helper for confirmation
confirm_action() {
    local msg="$1"
    gum confirm "$msg"
}
