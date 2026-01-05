#!/usr/bin/env bash

# STRICT PORT: VS Code
cleanup_vscode() {
    if [[ -d "${HOME}/.config/Code/Cache" ]] || [[ -d "${HOME}/.config/Code/CachedData" ]]; then
        if gum confirm "Clean VS Code Caches?"; then
             run_verbose "Cleaning VS Code..." "rm -rf ~/.config/Code/Cache ~/.config/Code/CachedData 2>/dev/null"
             log_info "VS Code cache cleaned"
        fi
    else
        log_info "VS Code cache not found"
    fi
}

# STRICT PORT: JetBrains
cleanup_jetbrains() {
    if [[ -d "${HOME}/.cache/JetBrains" ]]; then
        if gum confirm "Clean JetBrains Caches?"; then
            run_verbose "Cleaning JetBrains..." "rm -rf ~/.cache/JetBrains 2>/dev/null"
            log_info "JetBrains cache cleaned"
        fi
    else
        log_info "JetBrains cache not found"
    fi
}
