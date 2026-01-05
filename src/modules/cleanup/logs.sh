#!/usr/bin/env bash

cleanup_system_logs() {
    if gum confirm "Vacuum system journals (limit size to 100M)?"; then
        run_with_spinner "Cleaning journals..." "sudo journalctl --vacuum-size=100M"
        log_info "System logs cleaned"
    else
        log_info "System logs cleanup skipped"
    fi
}
