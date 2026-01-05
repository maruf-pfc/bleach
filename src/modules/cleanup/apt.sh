#!/usr/bin/env bash

cleanup_apt() {
    if ! command -v apt &>/dev/null; then
        gum style --foreground 196 "APT not found on this system."
        return
    fi
    
    if gum confirm "Clean APT cache and remove unused packages?"; then
        run_verbose "Cleaning APT..." "sudo apt clean -y && sudo apt autoclean -y && sudo apt autoremove -y"
        log_info "APT cleanup completed"
    else
        log_info "APT cleanup skipped"
    fi
}
