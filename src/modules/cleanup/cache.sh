#!/usr/bin/env bash

cleanup_cache() {
    # Python Caches
    if gum confirm "Remove common Python caches (.cache/pip, __pycache__)?"; then
        run_verbose "Cleaning Python caches..." "rm -rf ~/.cache/pip ~/.cache/pypoetry ~/.cache/virtualenv"
        # Find and delete __pycache__ in common dev directories
        # We run this in background or with a spinner, might take a while
        log_info "Python basic cache cleaned"
    fi
    
    # Node/NPM
    if command -v npm &>/dev/null; then
        if gum confirm "Clean npm cache?"; then
             run_verbose "Cleaning npm cache..." "npm cache clean --force"
             log_info "npm cache cleaned"
        fi
    fi
}
