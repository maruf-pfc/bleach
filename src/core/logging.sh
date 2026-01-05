#!/usr/bin/env bash

LOG_DIR="${HOME}/.local/share/bleach/logs"
DATE_STR=$(date +%Y-%m-%d)
CURRENT_LOG_FILE="${LOG_DIR}/bleach_${DATE_STR}.log"

# @description Initialize the logging directory and file
# @noargs
init_logger() {
    mkdir -p "$LOG_DIR"
    touch "$CURRENT_LOG_FILE"
}

# @description Log an informational message
# @arg $1 msg Message to log
log_info() {
    local msg="$1"
    echo "[INFO] $msg" | tee -a "$CURRENT_LOG_FILE"
}

# @description Log an error message
# @arg $1 msg Message to log
log_error() {
    local msg="$1"
    echo "[ERROR] $msg" | tee -a "$CURRENT_LOG_FILE"
}

# @description View the current log file using gum pager
# @noargs
view_logs() {
    if [[ -f "$CURRENT_LOG_FILE" ]]; then
        gum pager < "$CURRENT_LOG_FILE"
    else
        gum style --foreground 196 "No logs found."
        sleep 2
    fi
}

# @description Get free space on root filesystem in KB
# @noargs
get_free_space() {
    # Returns available space in KB
    df -k / | awk 'NR==2 {print $4}'
}

# @description Convert KB to human readable string (GB/MB/KB)
# @arg $1 kb Size in Kilobytes
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
