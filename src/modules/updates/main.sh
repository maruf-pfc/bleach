#!/usr/bin/env bash

update_flatpak() {
    if command -v flatpak &>/dev/null; then
        run_verbose "Updating Flatpaks..." "flatpak update -y"
        # Also remove unused
        if gum confirm "Remove unused Flatpaks?"; then
             run_verbose "Removing unused Flatpaks..." "flatpak uninstall --unused -y"
        fi
        log_info "Flatpak updated and cleaned"
    fi
}

update_snap() {
    if command -v snap &>/dev/null; then
        run_verbose "Refreshing Snaps..." "sudo snap refresh"
        log_info "Snaps refreshed"
    fi
}

system_update() {
    if command -v apt &>/dev/null; then
        # Run directly without spinner to allow password prompts and apt interactivity
        echo "Updating System (APT)..."
        sudo apt update
        sudo apt upgrade -y
        log_info "System updated"
        
        # Pause to let user read output
        gum style --foreground 212 "Press Enter to continue..."
        read -r
    fi
}

run_updates_menu() {
     CHOICES=$(gum choose --no-limit --cursor="→ " --header="Update Options" \
            "System Update (APT)" \
            "Flatpak Update & Clean" \
            "Snap Refresh" \
            "Back")
            
     [[ -z "$CHOICES" ]] && return

     while IFS= read -r item; do
        case "$item" in
            "System Update (APT)")   system_update ;;
            "Flatpak Update & Clean") update_flatpak ;;
            "Snap Refresh")          update_snap ;;
            "Back")                  return ;;
        esac
    done <<< "$CHOICES"
}
