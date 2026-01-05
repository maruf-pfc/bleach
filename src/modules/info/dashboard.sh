#!/usr/bin/env bash

# @description Get the Left Panel (Logo + Info)
get_left_panel() {
    local hostname
    hostname=$(hostname)
    local kernel
    kernel=$(uname -r)
    local uptime_info
    uptime_info=$(uptime -p | sed 's/up //')
    local shell_info="$SHELL"
    local resolution="Unknown"
    # Basic resolution check (if xdpyinfo exists, rarely on servers but good for desktop)
    if command -v xdpyinfo &>/dev/null; then
        resolution=$(xdpyinfo | awk '/dimensions:/ {print $2}')
    fi

    # ASCII Logo
    local color_pri="$COLOR_PRIMARY"
    local color_sec="$COLOR_SECONDARY"
    local logo
    logo=$(gum style --foreground "$color_pri" --bold \
" ____  _each
| __ )| | ___  __ _  ___| |__
|  _ \| |/ _ \/ _\` |/ __| '_ \\
| |_) | |  __/ (_| | (__| | | |
|____/|_|\___|\__,_|\___|_| |_|")

    # Info Text
    # We use basic string formatting to avoid complex join issues
    local info_text
    info_text=$(printf "Host:   %s\nKernel: %s\nUptime: %s\nShell:  %s" "$hostname" "$kernel" "$uptime_info" "$shell_info")
    
    local styled_logo
    # Better ASCII Art (Compact)
    #  ____  _     _____    _    ____ _   _ 
    # | __ )| |   | ____|  / \  / ___| | | |
    # |  _ \| |   |  _|   / _ \| |   | |_| |
    # | |_) | |___| |___ / ___ \ |___|  _  |
    # |____/|_____|_____/_/   \_\____|_| |_|
    # Escape backslashes carefully
    local logo_text=" ____  _     _____    _    ____ _   _ 
| __ )| |   | ____|  / \  / ___| | | |
|  _ \| |   |  _|   / _ \| |   | |_| |
| |_) | |___| |___ / ___ \ |___|  _  |
|____/|_____|_____/_/   \_\____|_| |_|"
    
    styled_logo=$(gum style --foreground "$color_pri" "$logo_text")
    
    local styled_text
    styled_text=$(gum style --foreground "$COLOR_ACCENT" "$info_text")

    # Combine Logo Left, Info Right
    # Use top alignment for text against logo to look neat? Or center. Center is fine.
    gum join --horizontal --align center "$styled_logo" "   " "$styled_text"
}

# @description Get the Right Panel (Live Stats Bars)
# @description Get the Right Panel (Live Stats Bars)
# @arg $1 width (optional, default 40)
get_right_panel() {
    local width="${1:-40}"
    # Ensure minimum width
    if (( width < 25 )); then width=25; fi
    
    # Calculate available space for bar
    # Margin safety: 20 chars (Label 6 + Value 6 + Brackets 2 + Padding 6)
    local bar_width=$(( width - 20 ))
    if (( bar_width < 2 )); then bar_width=2; fi

    # 1. CPU
    local cpu_load
    cpu_load=$(mkdir -p /tmp/bleach_stats; top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if [[ -z "$cpu_load" ]]; then cpu_load=0; fi
    
    local bars=$(awk -v pd="$cpu_load" -v bw="$bar_width" 'BEGIN { printf "%.0f", (pd / 100) * bw }')
    # Clamping bars
    if (( bars > bar_width )); then bars=$bar_width; fi
    
    local spaces=$(( bar_width - bars ))
    local bar_str=""
    for ((i=0; i<bars; i++)); do bar_str+="|"; done
    for ((i=0; i<spaces; i++)); do bar_str+=" "; done
    local cpu_line
    # Use -s to prevent wrapping? No, printf is fine if width is correct.
    cpu_line=$(printf "CPU:  [%s] %s%%" "$bar_str" "$cpu_load")
    
    # 2. RAM
    local ram_used
    local ram_total
    local ram_percent
    read -r ram_total ram_used <<< "$(free -m | awk '/^Mem:/ {print $2, $3}')"
    if [[ -z "$ram_total" || "$ram_total" -eq 0 ]]; then 
        ram_percent=0
        ram_used=0
        ram_total=0
        ram_percent=0
    else 
        ram_percent=$(awk "BEGIN {print int($ram_used * 100 / $ram_total)}")
    fi
    
    local rbars=$(awk -v pd="$ram_percent" -v bw="$bar_width" 'BEGIN { printf "%.0f", (pd / 100) * bw }')
    if (( rbars > bar_width )); then rbars=$bar_width; fi
    
    local rspaces=$(( bar_width - rbars ))
    local rbar_str=""
    for ((i=0; i<rbars; i++)); do rbar_str+="|"; done
    for ((i=0; i<rspaces; i++)); do rbar_str+=" "; done
    local ram_line
    ram_line=$(printf "RAM:  [%s] %s%%" "$rbar_str" "$ram_percent")

    # 3. Disk
    local disk_used
    local disk_total
    local disk_percent
    read -r disk_total disk_used disk_percent_str <<< "$(df -h / | awk 'NR==2 {print $2, $3, $5}')"
    if [[ -z "$disk_percent_str" ]]; then disk_percent_str="0%"; fi
    local disk_percent_val="${disk_percent_str//%/}"
    
    local dbars=$(awk -v pd="$disk_percent_val" -v bw="$bar_width" 'BEGIN { printf "%.0f", (pd / 100) * bw }')
    if (( dbars > bar_width )); then dbars=$bar_width; fi
    
    local dspaces=$(( bar_width - dbars ))
    local dbar_str=""
    for ((i=0; i<dbars; i++)); do dbar_str+="|"; done
    for ((i=0; i<dspaces; i++)); do dbar_str+=" "; done
    local disk_line
    disk_line=$(printf "Disk: [%s] %s%%" "$dbar_str" "$disk_percent_val")

    # Output
    # We add empty lines for spacing
    gum style --foreground "$COLOR_ACCENT" --width "$width" "$cpu_line" "" "$ram_line" "" "$disk_line"
}

get_separator() {
    # 8 lines of pipe
    gum style --foreground "$COLOR_MUTED" " │ " " │ " " │ " " │ " " │ " " │ " " │ " " │ " " │ "
}

# @description Draw the Full Dashboard Layout
draw_dashboard() {
    local cols
    cols=$(tput cols)
    
    # Grid Logic (Flex-like)
    # Total available width for content = cols - 2 (Outer Border)
    local available_width=$(( cols - 2 ))
    
    local content
    
    if (( cols >= 90 )); then
        # Horizontal Split (50% / 50%)
        # Left Width (Inner)
        # Right Width (Inner)
        # Layout: [ P L_INNER P | P R_INNER P ]
        # Widths: 
        # Left Box Width = available_width / 2
        # Right Box Width = available_width - Left Box Width
        
        local left_box_width=$(( available_width / 2 ))
        local right_box_width=$(( available_width - left_box_width ))
        
        # Inner content widths (subtract padding/borders)
        # Left Box has padding 1 (L+R=2) and 3 char separator? No separator is separate block.
        # Wait, if we use join, separator is between boxes.
        # So we deduct separator width (3 chars: " | ") from available space first.
        
        local effective_width=$(( available_width - 3 ))
        left_box_width=$(( effective_width / 2 ))
        right_box_width=$(( effective_width - left_box_width ))
        
        # Inner widths for content generation (padding=2 chars horizontal)
        local left_inner=$(( left_box_width - 2 ))
        local right_inner=$(( right_box_width - 2 ))
        
        local left_panel
        left_panel=$(get_left_panel)
        
        local right_panel
        right_panel=$(get_right_panel "$right_inner")
        
        local left_box
        left_box=$(gum style --width "$left_box_width" --padding "1 1" "$left_panel")
        
        local right_box
        right_box=$(gum style --width "$right_box_width" --padding "1 1" "$right_panel")
        
        local separator
        separator=$(get_separator)
        
        content=$(gum join --horizontal "$left_box" "$separator" "$right_box")
    else
        # Vertical Stack
        local box_width=$(( available_width ))
        local panel_inner_width=$(( box_width - 4 ))
        
        local left_panel
        left_panel=$(get_left_panel)
        
        local right_panel
        right_panel=$(get_right_panel "$panel_inner_width")
        
        local top_box
        top_box=$(gum style --width "$box_width" --align center --border bottom --border-foreground "$COLOR_MUTED" --padding "1" "$left_panel")
        
        local bottom_box
        bottom_box=$(gum style --width "$box_width" --align center --padding "1" "$right_panel")
        
        content=$(gum join --vertical "$top_box" "$bottom_box")
    fi
    
    gum style --border double --border-foreground "$COLOR_PRIMARY" --width "$cols" "$content"
}
