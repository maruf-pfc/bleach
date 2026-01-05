#!/usr/bin/env bash

LOG_DIR="${HOME}/.local/share/bleach/logs"
DATE_STR=$(date +%Y-%m-%d)
CURRENT_LOG_FILE="${LOG_DIR}/bleach_${DATE_STR}.log"

init_logger() {
    mkdir -p "$LOG_DIR"
    touch "$CURRENT_LOG_FILE"
}

log_info() {
    local msg="$1"
    echo "[INFO] $msg" | tee -a "$CURRENT_LOG_FILE"
}

log_error() {
    local msg="$1"
    echo "[ERROR] $msg" | tee -a "$CURRENT_LOG_FILE"
}

view_logs() {
    if [[ -f "$CURRENT_LOG_FILE" ]]; then
        gum pager < "$CURRENT_LOG_FILE"
    else
        gum style --foreground 196 "No logs found."
        sleep 2
    fi
}

# Storage Helpers
get_free_space() {
    # Returns available space in KB
    df -k / | awk 'NR==2 {print $4}'
}

human_readable_size() {
    local kb=$1
    if (( kb > 1048576 )); then
        echo "$(( kb / 1048576 )) GB"
    elif (( kb > 1024 )); then
        echo "$(( kb / 1024 )) MB"
    else
        echo "${kb} KB"
    fi
}
