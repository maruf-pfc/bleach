#!/usr/bin/env bash

# Source sibling scripts
# shellcheck disable=SC1091
source "${MODULES_DIR}/cleanup/apt.sh"
# shellcheck disable=SC1091
source "${MODULES_DIR}/cleanup/docker.sh"
# shellcheck disable=SC1091
source "${MODULES_DIR}/cleanup/logs.sh"
# shellcheck disable=SC1091
source "${MODULES_DIR}/cleanup/ide.sh"
# shellcheck disable=SC1091
source "${MODULES_DIR}/cleanup/dev.sh"
# shellcheck disable=SC1091
source "${MODULES_DIR}/cleanup/system.sh"

run_cleanup_menu() {
    while true; do
        CHOICES=$(gum choose --no-limit --cursor="→ " --header="Cleanup Options (Space to select)" \
            "APT Clean" \
            "Docker Prune" \
            "System Logs Vacuum" \
            "IDE Cache (VSCode/JetBrains)" \
            "Dev Clean (Node/Python/Artifacts)" \
            "System Clean (Temp/SSD/Thumbnails/Trash)" \
            "Back")

        if [[ -z "$CHOICES" ]]; then
            return
        fi

        while IFS= read -r item; do
            case "$item" in
                "APT Clean")          cleanup_apt ;;
                "Docker Prune")       cleanup_docker ;;
                "System Logs Vacuum") cleanup_system_logs ;;
                "IDE Cache (VSCode/JetBrains)")
                    cleanup_vscode
                    cleanup_jetbrains
                    ;;
                "Dev Clean (Node/Python/Artifacts)")
                    cleanup_npm
                    cleanup_pnpm
                    cleanup_yarn
                    cleanup_python
                    cleanup_build_artifacts
                    ;;
                "System Clean (Temp/SSD/Thumbnails)")
                    cleanup_temp
                    cleanup_ssd
                    cleanup_thumbnails
                    cleanup_trash
                    ;;
                "Back")               return ;;
            esac
        done <<< "$CHOICES"
    done
}
