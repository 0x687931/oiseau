#!/bin/bash
# TUI Demo - Non-scrolling Terminal UI with Oiseau
# Demonstrates a refreshing TUI that updates in place (like htop, vim, etc.)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../oiseau.sh"

# ==============================================================================
# TUI STATE MANAGEMENT
# ==============================================================================

# Global state
CURRENT_VIEW="dashboard"
COUNTER=0
TASK_STATUS="pending"
CPU_USAGE=0
MEMORY_USAGE=0

# ==============================================================================
# TERMINAL CONTROL FUNCTIONS
# ==============================================================================

# Save cursor position
save_cursor() {
    echo -en "\033[s"
}

# Restore cursor position
restore_cursor() {
    echo -en "\033[u"
}

# Move cursor to position (row, col)
move_cursor() {
    local row=$1
    local col=$2
    echo -en "\033[${row};${col}H"
}

# Clear screen and move to top
clear_screen() {
    echo -en "\033[2J\033[H"
}

# Hide cursor
hide_cursor() {
    echo -en "\033[?25l"
}

# Show cursor
show_cursor() {
    echo -en "\033[?25h"
}

# Clear from cursor to end of screen
clear_to_bottom() {
    echo -en "\033[J"
}

# ==============================================================================
# TUI RENDERING FUNCTIONS
# ==============================================================================

# Render the header (always visible)
render_header() {
    move_cursor 1 1
    show_header_box "🐦 Oiseau TUI Demo" "Non-scrolling Terminal UI - Press Q to quit"
    echo ""
}

# Render the navigation menu
render_menu() {
    echo -e "${COLOR_MUTED}Views: ${RESET}${COLOR_INFO}[D]${RESET}ashboard  ${COLOR_INFO}[M]${RESET}onitor  ${COLOR_INFO}[T]${RESET}asks  ${COLOR_INFO}[Q]${RESET}uit"
    echo ""
}

# Render dashboard view
render_dashboard() {
    print_section "📊 Dashboard View"

    show_summary "System Status" \
        "Uptime: $(printf '%02d:%02d:%02d' $((COUNTER/3600)) $(((COUNTER%3600)/60)) $((COUNTER%60)))" \
        "Tasks: 12 running, 3 pending" \
        "Status: ${COLOR_SUCCESS}Healthy${RESET}"

    echo ""

    local progress_items=(
        "done|Initialize system|Completed"
        "done|Load configuration|Config loaded"
        "active|Process queue|${COUNTER} items processed"
        "pending|Generate report|Waiting"
    )
    show_checklist progress_items

    echo ""
    show_info "Counter: $COUNTER (auto-incrementing)"
}

# Render monitor view
render_monitor() {
    print_section "📈 Resource Monitor"

    # Simulate CPU usage (oscillating)
    CPU_USAGE=$(( (COUNTER * 7 + 30) % 100 ))
    MEMORY_USAGE=$(( (COUNTER * 3 + 40) % 80 + 20 ))

    echo -e "${COLOR_MUTED}CPU Usage:${RESET}"
    show_progress_bar $CPU_USAGE 100 "CPU"

    echo ""
    echo -e "${COLOR_MUTED}Memory Usage:${RESET}"
    show_progress_bar $MEMORY_USAGE 100 "Memory"

    echo ""

    local metrics=(
        "CPU Cores: 8"
        "Memory Total: 16 GB"
        "Disk Usage: 245 GB / 500 GB"
        "Network: ${COLOR_SUCCESS}Connected${RESET}"
    )

    show_summary "System Metrics" "${metrics[@]}"
}

# Render tasks view
render_tasks() {
    print_section "✓ Task Manager"

    # Cycle through task statuses
    case $((COUNTER % 4)) in
        0) TASK_STATUS="pending" ;;
        1) TASK_STATUS="active" ;;
        2) TASK_STATUS="done" ;;
        3) TASK_STATUS="skip" ;;
    esac

    local tasks=(
        "done|Backup database|Completed at 14:30"
        "done|Deploy application|Build #${COUNTER}"
        "${TASK_STATUS}|Run integration tests|Status changes every tick"
        "pending|Send notifications|Scheduled for 18:00"
        "pending|Archive logs|Waiting"
    )

    show_checklist tasks

    echo ""

    if [ "$TASK_STATUS" = "active" ]; then
        show_box info "Task Running" "Integration tests are currently executing..."
    elif [ "$TASK_STATUS" = "done" ]; then
        show_box success "Task Complete" "Integration tests passed successfully!"
    fi
}

# Render just the footer (for selective updates)
render_footer() {
    echo -e "${COLOR_MUTED}Auto-refresh: ${COLOR_SUCCESS}ON${RESET}  |  Update interval: 1s  |  Frame: #${COUNTER}${RESET}"
}

# Main render function - redraws entire screen
render_screen() {
    clear_screen

    render_header
    render_menu

    case $CURRENT_VIEW in
        dashboard)
            render_dashboard
            ;;
        monitor)
            render_monitor
            ;;
        tasks)
            render_tasks
            ;;
    esac

    # Footer with instructions
    echo ""
    echo -e "${COLOR_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # Save cursor position before footer for selective updates
    save_cursor
    render_footer
}

# ==============================================================================
# INPUT HANDLING
# ==============================================================================

# Read a single character without waiting (non-blocking with timeout)
read_key() {
    local key=""
    # Read with 1 second timeout (balances responsiveness with refresh rate)
    IFS= read -rsn1 -t 1 key 2>/dev/null
    echo "$key"
}

# Process key press
process_input() {
    local key=$1

    case "$key" in
        d|D)
            CURRENT_VIEW="dashboard"
            ;;
        m|M)
            CURRENT_VIEW="monitor"
            ;;
        t|T)
            CURRENT_VIEW="tasks"
            ;;
        q|Q)
            return 1  # Signal to quit
            ;;
    esac

    return 0  # Continue running
}

# ==============================================================================
# MAIN TUI LOOP
# ==============================================================================

run_tui() {
    # Setup terminal
    hide_cursor

    # Trap to cleanup on exit
    trap cleanup EXIT INT TERM

    local running=true
    local last_view="$CURRENT_VIEW"
    local need_full_redraw=true

    # Initial render
    render_screen
    last_view="$CURRENT_VIEW"

    while $running; do
        # Read input (non-blocking with 1s timeout)
        local key=$(read_key)

        # Increment counter (simulates state changes)
        COUNTER=$((COUNTER + 1))

        # Process input if key was pressed
        if [ -n "$key" ]; then
            if ! process_input "$key"; then
                running=false
                continue
            else
                need_full_redraw=true
            fi
        fi

        # Determine if we need full redraw
        if [ "$need_full_redraw" = true ] || [ "$CURRENT_VIEW" != "$last_view" ]; then
            render_screen
            need_full_redraw=false
            last_view="$CURRENT_VIEW"
        else
            # Selective update: just update the footer counter
            restore_cursor
            echo -en "\033[K"  # Clear from cursor to end of line
            render_footer
        fi
    done
}

# Cleanup function
cleanup() {
    show_cursor
    clear_screen
    move_cursor 1 1
    echo -e "${COLOR_SUCCESS}TUI Demo exited cleanly. Goodbye! 👋${RESET}"
    echo ""
    exit 0
}

# ==============================================================================
# ENTRY POINT
# ==============================================================================

main() {
    # Check if terminal is interactive
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        echo "Error: This TUI requires an interactive terminal"
        exit 1
    fi

    # Show initial info
    clear_screen
    show_header_box "🐦 Oiseau TUI Demo" "Starting..."
    echo ""
    show_info "This is a non-scrolling TUI that refreshes in place"
    echo ""
    print_kv "Features" "Real-time updates, keyboard navigation, multiple views"
    print_kv "Controls" "D=Dashboard, M=Monitor, T=Tasks, Q=Quit"
    echo ""
    echo -e "${COLOR_MUTED}Press any key to start...${RESET}"
    read -rsn1

    # Run the TUI
    run_tui
}

# Run main
main
