#!/usr/bin/env bash

maintenance_trim() {
    if gum confirm "Run fstrim on all mounted filesystems?"; then
        run_verbose "Trimming SSDs..." "sudo fstrim -av"
        log_info "SSD Trim completed"
    fi
}

maintenance_rotate_logs() {
    # Placeholder for log rotation force
    run_verbose "Forcing log rotation..." "sudo logrotate -f /etc/logrotate.conf"
    log_info "Log rotation forced"
}

run_maintenance_menu() {
     CHOICES=$(gum choose --no-limit --cursor="→ " --header="Maintenance Options" \
            "SSD Trim" \
            "Force Log Rotation" \
            "Back")

     [[ -z "$CHOICES" ]] && return

     while IFS= read -r item; do
        case "$item" in
            "SSD Trim")           maintenance_trim ;;
            "Force Log Rotation") maintenance_rotate_logs ;;
            "Back")               return ;;
        esac
    done <<< "$CHOICES"
}
