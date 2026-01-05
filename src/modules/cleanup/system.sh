#!/usr/bin/env bash

# STRICT PORT: Temp
cleanup_temp() {
    if gum confirm "Clean temporary files (/tmp/*)?"; then
        run_verbose "Cleaning /tmp..." "sudo rm -rf /tmp/* 2>/dev/null"
        log_info "Temporary files cleaned"
    fi
}

# STRICT PORT: SSD Trim
cleanup_ssd() {
    if gum confirm "Run SSD Trim (fstrim)?"; then
        run_verbose "Trimming SSDs..." "sudo fstrim -av"
        log_info "SSD Trim completed"
    fi
}

# NEW: Thumbnails
cleanup_thumbnails() {
    if gum confirm "Clean user thumbnails cache?"; then
        run_verbose "Cleaning thumbnails..." "rm -rf ~/.cache/thumbnails/* 2>/dev/null"
        log_info "Thumbnails cleaned"
    fi
}

# NEW: Trash
cleanup_trash() {
    if gum confirm "Empty User Trash?"; then
        run_verbose "Emptying Trash..." "rm -rf ~/.local/share/Trash/* 2>/dev/null"
        log_info "Trash emptied"
    fi
}
