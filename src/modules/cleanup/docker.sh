#!/usr/bin/env bash

cleanup_docker() {
    if ! command -v docker &>/dev/null; then
        return
    fi

    if gum confirm "Prune unused Docker resources (images, containers, networks)?"; then
        run_with_spinner "Pruning Docker..." "docker system prune -f"
        log_info "Docker cleanup completed"
    else
        log_info "Docker cleanup skipped"
    fi
}
