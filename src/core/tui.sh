#!/usr/bin/env bash

# Colors
COLOR_PRIMARY="99"   # Purpleish
COLOR_SECONDARY="212" # Pinkish
COLOR_ACCENT="50"    # Cyan/Teal
COLOR_MUTED="240"    # Grey

# Layout Constants
SIDEBAR_WIDTH=25

# @description Draw the Tabbed Header
# @arg $1 active_tab Name of the active tab (cleanup|updates|maintenance|info)
draw_header() {
    local active_tab=$1
    local tab_cleanup="Cleanup"
    local tab_updates="Updates menu"
    local tab_maint="Maintenance"
    local tab_info="Stats"
    
    # Highlight active
    case $active_tab in
        "cleanup") tab_cleanup=$(gum style --foreground "$COLOR_SECONDARY" --bold " [ Cleanup ] ") ;;
        "updates") tab_updates=$(gum style --foreground "$COLOR_SECONDARY" --bold " [ Updates ] ") ;;
        "maintenance") tab_maint=$(gum style --foreground "$COLOR_SECONDARY" --bold " [ Maintenance ] ") ;;
        "info") tab_info=$(gum style --foreground "$COLOR_SECONDARY" --bold " [ Stats ] ") ;;
    esac

    # Responsive width check
    local clean_label="System Cleanup"
    if [[ $(tput cols) -lt 80 ]]; then
        clean_label="Clean"
    fi

    local header_text
    header_text=$(gum join --horizontal "  $tab_cleanup" "  $tab_updates" "  $tab_maint" "  $tab_info")
    
    gum style \
        --border double \
        --margin "0" \
        --padding "0 1" \
        --border-foreground "$COLOR_PRIMARY" \
        --width "$(tput cols)" \
        "$header_text"
}

# @description Run a command with visible output (Verbose)
# @arg $1 message
# @arg $2 command
run_verbose() {
    local msg="$1"
    local cmd="$2"
    
    echo ""
    gum style --foreground "$COLOR_ACCENT" ":: $msg"
    echo "----------------------------------------"
    # Execute and Pipe to log (tee) but also show on screen
    # We use 'eval' to handle complex command strings with pipes/redirections passed as string
    eval "$cmd" | tee -a "$CURRENT_LOG_FILE"
    echo "----------------------------------------"
}

# @description Run a command silently with spinner
# @arg $1 message
# @arg $2 command
run_silent() {
    local msg="$1"
    local cmd="$2"
    gum spin --spinner dot --title "$msg" -- bash -c "$cmd >> $CURRENT_LOG_FILE 2>&1"
}

confirm_action() {
    local msg="$1"
    gum confirm "$msg"
}
