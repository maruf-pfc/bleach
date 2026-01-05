#!/usr/bin/env bash

# Self Update Logic
# Assumes Bleach is installed via Git in BLEACH_ROOT

# @description Check if a newer version exists on remote
# @noargs
# @exitcode 0 If update is available
# @exitcode 1 If no update or not a git repo
check_for_updates() {
    local install_dir="$BLEACH_ROOT"
    
    if [[ ! -d "$install_dir/.git" ]]; then
        # Not a git repo, maybe manual install?
        return 1
    fi
    
    # Check if remote has updates
    cd "$install_dir" || return
    git fetch origin master &>/dev/null || git fetch origin main &>/dev/null
    
    local LOCAL
    local REMOTE
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse "@{u}")

    if [[ "$LOCAL" != "$REMOTE" ]]; then
        return 0 # Update available
    else
        return 1 # No update
    fi
}

# @description Perform the self-update (git pull)
# @noargs
perform_self_update() {
    local install_dir="$BLEACH_ROOT"
    cd "$install_dir" || return
    
    log_info "Updating Bleach..."
    
    # Check if we have write access
    if [[ -w "$install_dir" ]]; then
        if git pull; then
            log_info "Bleach updated successfully."
        else
            log_error "Failed to update Bleach."
        fi
    else
        # Try with sudo
        log_info "Requesting sudo permissions for update..."
        if sudo git pull; then
             log_info "Bleach updated successfully (with sudo)."
        else
             log_error "Failed to update Bleach."
        fi
    fi
}
