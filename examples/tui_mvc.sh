#!/bin/bash
# TUI MVC Demo - Model-View-Controller pattern for Terminal UI
# Demonstrates clean separation: Model (data) / View (rendering) / Controller (logic)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../oiseau.sh"

# ==============================================================================
# TERMINAL UTILITIES (Infrastructure)
# ==============================================================================

tui::clear() { echo -en "\033[2J\033[H"; }
tui::hide_cursor() { echo -en "\033[?25l"; }
tui::show_cursor() { echo -en "\033[?25h"; }
tui::move() { echo -en "\033[${1};${2}H"; }
tui::save_cursor() { echo -en "\033[s"; }
tui::restore_cursor() { echo -en "\033[u"; }

# ==============================================================================
# MODEL - Application State (Pure Data)
# ==============================================================================

declare -A MODEL=(
    [view]="home"
    [counter]=0
    [selected_item]=0
    [task_count]=5
    [status]="idle"
    [message]=""
)

# Task list data
TASKS=(
    "pending|Write documentation|Not started"
    "active|Implement feature X|In progress..."
    "done|Fix bug #123|Completed"
    "pending|Deploy to staging|Waiting"
    "skip|Run benchmarks|Skipped"
)

# Model methods - pure functions that update state
model::increment_counter() {
    MODEL[counter]=$((MODEL[counter] + 1))
}

model::set_view() {
    MODEL[view]="$1"
}

model::next_item() {
    local max=$((${#TASKS[@]} - 1))
    MODEL[selected_item]=$(( (MODEL[selected_item] + 1) % (max + 1) ))
}

model::prev_item() {
    local max=$((${#TASKS[@]} - 1))
    local current=${MODEL[selected_item]}
    MODEL[selected_item]=$(( (current - 1 + max + 1) % (max + 1) ))
}

model::toggle_task() {
    local idx=${MODEL[selected_item]}
    local task="${TASKS[$idx]}"
    local status="${task%%|*}"

    # Cycle through statuses
    case "$status" in
        pending) new_status="active" ;;
        active) new_status="done" ;;
        done) new_status="skip" ;;
        skip) new_status="pending" ;;
    esac

    # Update task
    local rest="${task#*|}"
    TASKS[$idx]="${new_status}|${rest}"
    MODEL[message]="Task #$((idx+1)) status changed to: $new_status"
}

# ==============================================================================
# VIEW - Rendering (No Logic, Just Display)
# ==============================================================================

view::header() {
    show_header_box "🐦 MVC TUI Demo" "Model-View-Controller Pattern"
    echo ""
}

view::navigation() {
    local current=${MODEL[view]}

    echo -en "  "
    [ "$current" = "home" ] && echo -en "${COLOR_SUCCESS}[Home]${RESET}" || echo -en "${COLOR_MUTED}Home${RESET}"
    echo -en "  "
    [ "$current" = "tasks" ] && echo -en "${COLOR_SUCCESS}[Tasks]${RESET}" || echo -en "${COLOR_MUTED}Tasks${RESET}"
    echo -en "  "
    [ "$current" = "about" ] && echo -en "${COLOR_SUCCESS}[About]${RESET}" || echo -en "${COLOR_MUTED}About${RESET}"
    echo ""
    echo ""
}

view::home() {
    print_section "🏠 Home View"

    show_summary "Application State" \
        "Current View: ${MODEL[view]}" \
        "Frame Count: ${MODEL[counter]}" \
        "Status: ${MODEL[status]}" \
        "Total Tasks: ${#TASKS[@]}"

    echo ""

    if [ -n "${MODEL[message]}" ]; then
        show_info "${MODEL[message]}"
        echo ""
    fi

    # Show a progress example
    local progress=$(( (MODEL[counter] * 5) % 100 ))
    show_progress_bar $progress 100 "Demo Progress"
}

view::tasks() {
    print_section "✓ Task Manager"

    echo -e "${COLOR_MUTED}Use ↑/↓ or Tab to select, SPACE to toggle status${RESET}"
    echo ""

    # Render task list with selection indicator
    local idx=0
    for task in "${TASKS[@]}"; do
        local indicator=" "
        if [ $idx -eq ${MODEL[selected_item]} ]; then
            indicator="${COLOR_SUCCESS}▶${RESET}"
        fi

        # Extract task components
        local status="${task%%|*}"
        local rest="${task#*|}"
        local title="${rest%%|*}"
        local detail="${rest#*|}"

        # Render based on status
        case "$status" in
            done)
                echo -e "  ${indicator} ${COLOR_SUCCESS}✓${RESET} ${COLOR_DIM}${title}${RESET} - ${detail}"
                ;;
            active)
                echo -e "  ${indicator} ${COLOR_WARNING}●${RESET} ${BOLD}${title}${RESET} - ${detail}"
                ;;
            pending)
                echo -e "  ${indicator} ${COLOR_MUTED}○${RESET} ${title} - ${detail}"
                ;;
            skip)
                echo -e "  ${indicator} ${COLOR_MUTED}−${RESET} ${COLOR_DIM}${title}${RESET} - ${detail}"
                ;;
        esac

        idx=$((idx + 1))
    done

    echo ""

    if [ -n "${MODEL[message]}" ]; then
        show_success "${MODEL[message]}"
    fi
}

view::about() {
    print_section "ℹ️  About MVC Pattern"

    show_box info "What is MVC?" \
        "MVC separates application into three interconnected components:" \
        "" \
        "• Model: Manages data and business logic" \
        "• View: Handles display and presentation" \
        "• Controller: Processes input and updates model"

    echo ""

    show_summary "Benefits" \
        "✓ Clean separation of concerns" \
        "✓ Easy to test each component" \
        "✓ Reusable view and model code" \
        "✓ Multiple views can share same model"

    echo ""

    show_success "This TUI uses pure bash with Oiseau for rendering!"
}

view::footer() {
    echo ""
    echo -e "${COLOR_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    case ${MODEL[view]} in
        tasks)
            echo -ne "${COLOR_MUTED}↑↓/Tab=Select  Space=Toggle  1-3=Views  R=Refresh  Q=Quit  |  Frame #${MODEL[counter]}${RESET}"
            ;;
        *)
            echo -ne "${COLOR_MUTED}Tab=Next View  1=Home  2=Tasks  3=About  R=Refresh  Q=Quit  |  Frame #${MODEL[counter]}${RESET}"
            ;;
    esac
}

# Main render - composes all view components
view::render() {
    tui::clear

    view::header
    view::navigation

    case ${MODEL[view]} in
        home)
            view::home
            ;;
        tasks)
            view::tasks
            ;;
        about)
            view::about
            ;;
    esac

    view::footer
}

# ==============================================================================
# CONTROLLER - Input Handling & Business Logic
# ==============================================================================

controller::handle_key() {
    local key="$1"

    # Clear message on new input
    MODEL[message]=""

    case "$key" in
        # View switching (numbers)
        1)
            model::set_view "home"
            ;;
        2)
            model::set_view "tasks"
            ;;
        3)
            model::set_view "about"
            ;;

        # Tab - cycle through views
        $'\t')
            case ${MODEL[view]} in
                home) model::set_view "tasks" ;;
                tasks) model::set_view "about" ;;
                about) model::set_view "home" ;;
            esac
            ;;

        # Arrow keys
        A|$'\x1b[A')  # Up arrow
            if [ "${MODEL[view]}" = "tasks" ]; then
                model::prev_item
            fi
            ;;
        B|$'\x1b[B')  # Down arrow
            if [ "${MODEL[view]}" = "tasks" ]; then
                model::next_item
            fi
            ;;

        # Task toggle (space bar)
        ' ')
            if [ "${MODEL[view]}" = "tasks" ]; then
                model::toggle_task
            fi
            ;;

        # Refresh (force re-render)
        r|R)
            MODEL[message]="Display refreshed"
            ;;

        # Escape (could be used to go back/cancel)
        $'\x1b')
            model::set_view "home"
            MODEL[message]="Returned to home"
            ;;

        # Quit
        q|Q)
            return 1
            ;;
    esac

    return 0
}

controller::update() {
    # Auto-increment counter each frame
    model::increment_counter

    # Update status based on counter
    local mod=$((MODEL[counter] % 3))
    case $mod in
        0) MODEL[status]="idle" ;;
        1) MODEL[status]="processing" ;;
        2) MODEL[status]="active" ;;
    esac
}

# ==============================================================================
# MAIN LOOP - Ties Everything Together
# ==============================================================================

app::read_key() {
    local key=""

    # Try to read a full escape sequence (for arrow keys)
    # Use 1s timeout - screen only redraws on input or state change
    IFS= read -rsn1 -t 1 key 2>/dev/null

    if [ "$key" = $'\x1b' ]; then
        # Read next char to see if it's an arrow key
        local next
        IFS= read -rsn2 -t 0.1 next 2>/dev/null
        if [ -n "$next" ]; then
            key="${key}${next}"
        fi
    fi

    echo "$key"
}

app::run() {
    tui::hide_cursor

    trap app::cleanup EXIT INT TERM

    local running=true
    local last_view="${MODEL[view]}"
    local need_full_redraw=false

    # Initial render
    view::render
    last_view="${MODEL[view]}"

    while $running; do
        # Handle input
        local key=$(app::read_key)

        # Update model (business logic)
        controller::update

        # Process key input
        if [ -n "$key" ]; then
            if ! controller::handle_key "$key"; then
                running=false
                continue
            else
                need_full_redraw=true
            fi
        fi

        # Full redraw only when view changes or on user input
        if [ "$need_full_redraw" = true ] || [ "${MODEL[view]}" != "$last_view" ]; then
            view::render
            need_full_redraw=false
            last_view="${MODEL[view]}"
        else
            # Selective update: just update the footer status line
            # Move to beginning of current line and overwrite
            case ${MODEL[view]} in
                tasks)
                    echo -ne "\r\033[K${COLOR_MUTED}↑↓/Tab=Select  Space=Toggle  1-3=Views  R=Refresh  Q=Quit  |  Frame #${MODEL[counter]}${RESET}"
                    ;;
                *)
                    echo -ne "\r\033[K${COLOR_MUTED}Tab=Next View  1=Home  2=Tasks  3=About  R=Refresh  Q=Quit  |  Frame #${MODEL[counter]}${RESET}"
                    ;;
            esac
        fi
    done
}

app::cleanup() {
    tui::show_cursor
    tui::clear
    tui::move 1 1
    echo -e "${COLOR_SUCCESS}MVC TUI exited cleanly. Thank you! 👋${RESET}"
    echo ""
    exit 0
}

# ==============================================================================
# ENTRY POINT
# ==============================================================================

main() {
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        echo "Error: This TUI requires an interactive terminal"
        exit 1
    fi

    # Welcome screen
    tui::clear
    show_header_box "🐦 MVC TUI Demo" "Clean Architecture"
    echo ""
    show_box info "Welcome!" \
        "This demo shows how to build a TUI using the MVC pattern." \
        "" \
        "The code is organized into:" \
        "  • Model:      Application state and data" \
        "  • View:       Rendering functions (no logic)" \
        "  • Controller: Input handling and business logic"
    echo ""
    show_summary "Key Bindings" \
        "Tab          - Cycle through views" \
        "1, 2, 3      - Jump to specific view" \
        "↑ / ↓        - Navigate items (Tasks view)" \
        "Space        - Toggle item (Tasks view)" \
        "R            - Force refresh" \
        "Esc          - Return to home" \
        "Q            - Quit"
    echo ""
    echo -e "${COLOR_MUTED}Press any key to continue...${RESET}"
    read -rsn1

    app::run
}

main
