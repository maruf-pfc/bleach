#!/usr/bin/env bash

# STRICT PORT: npm
cleanup_npm() {
    if command -v npm &>/dev/null; then
        if gum confirm "Clean npm cache?"; then
            run_verbose "Cleaning npm cache..." "npm cache clean --force"
            log_info "npm cache cleaned"
        fi
    fi
}

# STRICT PORT: pnpm
cleanup_pnpm() {
    if command -v pnpm &>/dev/null; then
        if gum confirm "Prune pnpm store?"; then
            run_verbose "Pruning pnpm store..." "pnpm store prune"
            log_info "pnpm store cleaned"
        fi
    fi
}

# STRICT PORT: Python
cleanup_python() {
    # Basic caches
    if gum confirm "Clean Python caches (pip, poetry, virtualenv)?"; then
        run_verbose "Cleaning general Python caches..." "rm -rf ~/.cache/pip ~/.cache/pypoetry ~/.cache/virtualenv"
        log_info "General Python caches cleaned"
    fi

    # Deep Scan (__pycache__)
    # Original script scanned: $HOME/projects $HOME/code $HOME/dev
    # We will replicate this
    local scan_dirs=()
    [[ -d "$HOME/projects" ]] && scan_dirs+=("$HOME/projects")
    [[ -d "$HOME/code" ]] && scan_dirs+=("$HOME/code")
    [[ -d "$HOME/dev" ]] && scan_dirs+=("$HOME/dev")

    if [[ ${#scan_dirs[@]} -gt 0 ]]; then
        if gum confirm "Deep Clean __pycache__ in ${scan_dirs[*]}?"; then
             # Construct find command safely
             # find "$dir" -path "*/.git" -prune -o -type d -name "__pycache__" -exec rm -rf {} +
             for dir in "${scan_dirs[@]}"; do
                 run_verbose "Cleaning __pycache__ in $dir..." \
                    "find '$dir' -path '*/.git' -prune -o -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null"
             done
             log_info "Deep Python cleanup completed"
        fi
    else
        if gum confirm "No standard dev dirs found. Scan entire \$HOME for __pycache__? (Slow)"; then
             run_verbose "Scanning \$HOME..." \
                "find '$HOME' -path '*/.git' -prune -o -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null"
             log_info "Home directory Python cleanup completed"
        fi
    fi
}

# STRICT PORT: Build Artifacts
cleanup_build_artifacts() {
    # Original: rm -rf ~/node_modules ~/dist ~/build
    if gum confirm "Remove common build artifacts (~/node_modules, ~/dist, ~/build)?"; then
        run_verbose "Removing build artifacts..." "rm -rf ~/node_modules ~/dist ~/build 2>/dev/null"
        log_info "Build artifacts removed"
    fi
}

cleanup_yarn() {
    if command -v yarn &>/dev/null; then
        if gum confirm "Clean Yarn cache?"; then
             run_verbose "Cleaning Yarn cache..." "yarn cache clean"
             log_info "Yarn cache cleaned"
        fi
    fi
}
