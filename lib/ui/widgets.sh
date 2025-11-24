#!/bin/bash
# Tild UI Widgets Library
# Pure functions for terminal UI components
# Version: 1.0.0

# ==============================================================================
# TERMINAL DETECTION & SETUP
# ==============================================================================

# Detect terminal capabilities (called once on source)
_tild_ui_setup() {
    # Detect color support
    if [ "${TERM:-}" = "dumb" ] || [ -z "${TERM:-}" ]; then
        export TILD_UI_COLORS=0
    elif [ -n "${NO_COLOR:-}" ]; then
        export TILD_UI_COLORS=0
    else
        export TILD_UI_COLORS=1
    fi

    # Detect Unicode support
    if locale 2>/dev/null | grep -qi "utf-8\|utf8"; then
        export TILD_UI_UNICODE=1
    else
        export TILD_UI_UNICODE=0
    fi

    # Get terminal width (default 80 if unable to detect)
    export TILD_UI_WIDTH=$(tput cols 2>/dev/null || echo 80)
}

# Initialize on source
_tild_ui_setup

# ==============================================================================
# COLOR DEFINITIONS (ANSI 256-Color Palette)
# ==============================================================================

if [ "$TILD_UI_COLORS" = "1" ]; then
    # Status Colors
    export COLOR_SUCCESS='\033[38;5;40m'   # Bright green
    export COLOR_ERROR='\033[38;5;196m'    # Bright red
    export COLOR_WARNING='\033[38;5;214m'  # Orange
    export COLOR_INFO='\033[38;5;39m'      # Bright blue
    export COLOR_ACCENT='\033[38;5;99m'    # Purple

    # UI Element Colors
    export COLOR_HEADER='\033[38;5;117m'   # Light blue
    export COLOR_BORDER='\033[38;5;240m'   # Gray
    export COLOR_MUTED='\033[38;5;246m'    # Light gray
    export COLOR_DIM='\033[38;5;238m'      # Dark gray

    # Priority Colors
    export COLOR_P0='\033[38;5;196m'       # Red - Critical
    export COLOR_P1='\033[38;5;214m'       # Orange - High
    export COLOR_P2='\033[38;5;227m'       # Yellow - Medium

    # Special Colors
    export COLOR_LINK='\033[38;5;75m'      # Sky blue
    export COLOR_CODE='\033[38;5;186m'     # Beige

    # Text Styles
    export BOLD='\033[1m'
    export DIM='\033[2m'
    export ITALIC='\033[3m'
    export UNDERLINE='\033[4m'
    export REVERSE='\033[7m'
    export RESET='\033[0m'
    export NC='\033[0m'
else
    # No color support - all empty
    export COLOR_SUCCESS=""
    export COLOR_ERROR=""
    export COLOR_WARNING=""
    export COLOR_INFO=""
    export COLOR_ACCENT=""
    export COLOR_HEADER=""
    export COLOR_BORDER=""
    export COLOR_MUTED=""
    export COLOR_DIM=""
    export COLOR_P0=""
    export COLOR_P1=""
    export COLOR_P2=""
    export COLOR_LINK=""
    export COLOR_CODE=""
    export BOLD=""
    export DIM=""
    export ITALIC=""
    export UNDERLINE=""
    export REVERSE=""
    export RESET=""
    export NC=""
fi

# ==============================================================================
# ICON DEFINITIONS
# ==============================================================================

if [ "$TILD_UI_UNICODE" = "1" ]; then
    # Status Indicators
    export ICON_SUCCESS="✓"
    export ICON_ERROR="✗"
    export ICON_WARNING="⚠"
    export ICON_INFO="ℹ"
    export ICON_PENDING="○"
    export ICON_ACTIVE="●"
    export ICON_PROGRESS="◐"
    export ICON_SKIP="⊘"

    # Progress Indicators
    export ICON_ARROW="›"
    export ICON_DOUBLE_ARROW="»"
    export ICON_ELLIPSIS="…"

    # Action Indicators
    export ICON_ENTER="⏎"
    export ICON_CTRL="⌃"

    # Box Drawing - Rounded
    export BOX_H="─"
    export BOX_V="│"
    export BOX_RTL="╭"
    export BOX_RTR="╮"
    export BOX_RBL="╰"
    export BOX_RBR="╯"
    export BOX_VR="├"
    export BOX_VL="┤"

    # Box Drawing - Double
    export BOX_DH="═"
    export BOX_DV="║"
    export BOX_DTL="╔"
    export BOX_DTR="╗"
    export BOX_DBL="╚"
    export BOX_DBR="╝"

    # Progress bar characters
    export CHAR_FILLED="█"
    export CHAR_EMPTY="░"
else
    # ASCII Fallback
    export ICON_SUCCESS="[✓]"
    export ICON_ERROR="[X]"
    export ICON_WARNING="[!]"
    export ICON_INFO="[i]"
    export ICON_PENDING="[ ]"
    export ICON_ACTIVE="[*]"
    export ICON_PROGRESS="[~]"
    export ICON_SKIP="[-]"
    export ICON_ARROW=">"
    export ICON_DOUBLE_ARROW=">>"
    export ICON_ELLIPSIS="..."
    export ICON_ENTER="[Enter]"
    export ICON_CTRL="[Ctrl]"
    export BOX_H="-"
    export BOX_V="|"
    export BOX_RTL="+"
    export BOX_RTR="+"
    export BOX_RBL="+"
    export BOX_RBR="+"
    export BOX_VR="+"
    export BOX_VL="+"
    export BOX_DH="="
    export BOX_DV="|"
    export BOX_DTL="+"
    export BOX_DTR="+"
    export BOX_DBL="+"
    export BOX_DBR="+"
    export CHAR_FILLED="#"
    export CHAR_EMPTY="-"
fi

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Escape control characters from user input
# Usage: _escape_input "user string"
_escape_input() {
    local input="$1"
    # Use printf instead of echo to avoid option/escape interpretation
    # Remove ANSI escape sequences and control characters
    printf '%s\n' "$input" | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\000-\037\177'
}

# Clamp width to terminal size
# Usage: _clamp_width <requested_width>
_clamp_width() {
    local requested=$1
    local term_width=${TILD_UI_WIDTH:-80}

    if [ "$requested" -gt "$term_width" ]; then
        echo "$term_width"
    else
        echo "$requested"
    fi
}

# Truncate string with ellipsis if too long
# Usage: _truncate "string" <max_width>
_truncate() {
    local str="$1"
    local max_width=$2
    local str_len=${#str}

    if [ "$str_len" -le "$max_width" ]; then
        echo "$str"
    else
        local truncated_len=$((max_width - 1))
        echo "${str:0:$truncated_len}${ICON_ELLIPSIS}"
    fi
}

# Repeat a character N times
# Usage: _repeat_char "char" <count>
_repeat_char() {
    local char="$1"
    local count=$2
    printf "%${count}s" | tr ' ' "$char"
}

# Calculate visible length (without ANSI codes)
# Usage: _visible_len "string with \033[0m codes"
_visible_len() {
    local str="$1"
    # Use printf instead of echo to avoid interpretation
    local stripped=$(printf '%s' "$str" | sed 's/\x1b\[[0-9;]*m//g')
    echo "${#stripped}"
}

# ==============================================================================
# MESSAGE FUNCTIONS
# ==============================================================================

# Show success message
# Usage: show_success "message"
# Side effects: Writes to stdout
show_success() {
    local message="$(_escape_input "$1")"
    echo -e "  ${COLOR_SUCCESS}${ICON_SUCCESS}${NC}  ${message}"
}

# Show error message
# Usage: show_error "message"
# Side effects: Writes to stdout
show_error() {
    local message="$(_escape_input "$1")"
    echo -e "  ${COLOR_ERROR}${ICON_ERROR}${NC}  ${message}"
}

# Show warning message
# Usage: show_warning "message"
# Side effects: Writes to stdout
show_warning() {
    local message="$(_escape_input "$1")"
    echo -e "  ${COLOR_WARNING}${ICON_WARNING}${NC}  ${message}"
}

# Show info message
# Usage: show_info "message"
# Side effects: Writes to stdout
show_info() {
    local message="$(_escape_input "$1")"
    echo -e "  ${COLOR_INFO}${ICON_INFO}${NC}  ${message}"
}

# ==============================================================================
# HEADER FUNCTIONS
# ==============================================================================

# Show section header with optional step counter
# Usage: show_section_header "title" [step_num] [total_steps] [subtitle]
# Side effects: Writes to stdout
show_section_header() {
    local title="$(_escape_input "$1")"
    local step_num="$2"
    local total_steps="$3"
    local subtitle="$(_escape_input "$4")"
    local width=$(_clamp_width 60)

    local title_len=${#title}
    local padding=$((width - title_len - 2))

    echo ""
    echo -e "${COLOR_BORDER}${BOX_RTL}$(_repeat_char "$BOX_H" $width)${BOX_RTR}${NC}"
    echo -e "${COLOR_BORDER}${BOX_V}${NC}  ${BOLD}${COLOR_HEADER}${title}${RESET}$(_repeat_char ' ' $padding)${COLOR_BORDER}${BOX_V}${NC}"

    if [ -n "$step_num" ] && [ -n "$total_steps" ]; then
        local step_text="Step ${step_num} of ${total_steps}"
        if [ -n "$subtitle" ]; then
            step_text="${step_text} ${ICON_ARROW} ${subtitle}"
        fi

        local step_len=$(_visible_len "$step_text")
        local step_padding=$((width - step_len - 2))

        echo -e "${COLOR_BORDER}${BOX_V}${NC}  ${DIM}${step_text}${RESET}$(_repeat_char ' ' $step_padding)${COLOR_BORDER}${BOX_V}${NC}"
    fi

    echo -e "${COLOR_BORDER}${BOX_RBL}$(_repeat_char "$BOX_H" $width)${BOX_RBR}${NC}"
    echo ""
}

# Show simple header (no box)
# Usage: show_header "title"
# Side effects: Writes to stdout
show_header() {
    local title="$(_escape_input "${1:-}")"
    local width=$(_clamp_width 60)

    echo ""
    echo -e "${BOLD}${COLOR_HEADER}${title}${RESET}"
    echo -e "${COLOR_BORDER}$(_repeat_char "$BOX_H" $width)${NC}"
    echo ""
}

# Show subheader (smaller, muted)
# Usage: show_subheader "title"
# Side effects: Writes to stdout
show_subheader() {
    local title="$(_escape_input "$1")"

    echo ""
    echo -e "${COLOR_MUTED}${title}${NC}"
    echo ""
}

# ==============================================================================
# BOX FUNCTIONS
# ==============================================================================

# Show info/error/warning/success box with message and optional commands
# Usage: show_box <type> <title> <message> [command1] [command2] ...
# Types: error, warning, info, success
# Side effects: Writes to stdout
show_box() {
    local type="$1"
    local title="$(_escape_input "$2")"
    local message="$(_escape_input "$3")"
    shift 3
    local width=$(_clamp_width 60)

    # Set color and icon based on type
    local color=$COLOR_INFO
    local icon=$ICON_INFO
    case "$type" in
        error)
            color=$COLOR_ERROR
            icon=$ICON_ERROR
            ;;
        warning)
            color=$COLOR_WARNING
            icon=$ICON_WARNING
            ;;
        success)
            color=$COLOR_SUCCESS
            icon=$ICON_SUCCESS
            ;;
    esac

    # Top border
    echo ""
    echo -e "${COLOR_BORDER}${BOX_DTL}$(_repeat_char "$BOX_DH" $width)${BOX_DTR}${NC}"

    # Title line
    local title_text="${icon}  ${title}"
    local title_len=$(_visible_len "$title_text")
    local title_padding=$((width - title_len - 2))
    echo -e "${COLOR_BORDER}${BOX_DV}${NC}  ${BOLD}${color}${title_text}${RESET}$(_repeat_char ' ' $title_padding)${COLOR_BORDER}${BOX_DV}${NC}"

    # Separator
    echo -e "${COLOR_BORDER}${BOX_VR}$(_repeat_char "$BOX_DH" $width)${BOX_VL}${NC}"

    # Empty line
    echo -e "${COLOR_BORDER}${BOX_DV}${NC}$(_repeat_char ' ' $((width + 2)))${COLOR_BORDER}${BOX_DV}${NC}"

    # Message (word wrap)
    local line_width=$((width - 4))
    echo "$message" | fold -s -w "$line_width" 2>/dev/null | while IFS= read -r line; do
        local line_len=${#line}
        local line_padding=$((width - line_len - 2))
        echo -e "${COLOR_BORDER}${BOX_DV}${NC}  ${line}$(_repeat_char ' ' $line_padding)${COLOR_BORDER}${BOX_DV}${NC}"
    done

    # Commands/steps (if provided)
    if [ $# -gt 0 ]; then
        echo -e "${COLOR_BORDER}${BOX_DV}${NC}$(_repeat_char ' ' $((width + 2)))${COLOR_BORDER}${BOX_DV}${NC}"
        for cmd in "$@"; do
            local cmd_clean="$(_escape_input "$cmd")"
            local cmd_len=${#cmd_clean}
            local cmd_padding=$((width - cmd_len - 4))
            echo -e "${COLOR_BORDER}${BOX_DV}${NC}    ${COLOR_CODE}${cmd_clean}${RESET}$(_repeat_char ' ' $cmd_padding)${COLOR_BORDER}${BOX_DV}${NC}"
        done
    fi

    # Empty line
    echo -e "${COLOR_BORDER}${BOX_DV}${NC}$(_repeat_char ' ' $((width + 2)))${COLOR_BORDER}${BOX_DV}${NC}"

    # Bottom border
    echo -e "${COLOR_BORDER}${BOX_DBL}$(_repeat_char "$BOX_DH" $width)${BOX_DBR}${NC}"
    echo ""
}

# ==============================================================================
# PROGRESS FUNCTIONS
# ==============================================================================

# Show progress bar
# Usage: show_progress_bar <current> <total> [label]
# Side effects: Writes to stdout
show_progress_bar() {
    local current=$1
    local total=$2
    local label="$(_escape_input "${3:-Progress}")"
    local bar_width=20

    # Validate inputs
    if [ "$total" -eq 0 ]; then
        total=1
    fi

    # Clamp percentage to 100
    local percentage=$((current * 100 / total))
    if [[ $percentage -gt 100 ]]; then
        percentage=100
    fi

    # Clamp filled to bar_width
    local filled=$((current * bar_width / total))
    if [[ $filled -gt $bar_width ]]; then
        filled=$bar_width
    fi
    local empty=$((bar_width - filled))

    # Build progress bar
    local bar=""
    local i
    for ((i=0; i<filled; i++)); do
        bar="${bar}${CHAR_FILLED}"
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar}${CHAR_EMPTY}"
    done

    echo -e "${COLOR_INFO}${label}:${NC} ${bar} ${BOLD}${percentage}%${RESET} ${DIM}(${current}/${total})${RESET}"
}

# Show checklist of steps
# Usage: show_checklist <items_array_name>
# Array format: "status|label|details"
# Status: done, active, pending, skip
# Side effects: Writes to stdout
show_checklist() {
    # Use indirect reference for bash 3.x compatibility
    local array_name="$1"
    eval "local items=(\"\${${array_name}[@]}\")"

    for item in "${items[@]}"; do
        IFS='|' read -r status label details <<< "$item"

        # Escape user input
        label="$(_escape_input "$label")"
        details="$(_escape_input "$details")"

        local icon color label_style details_style
        case "$status" in
            done)
                icon="${ICON_SUCCESS}"
                color="${COLOR_SUCCESS}"
                label_style="${DIM}${label}${RESET}"
                details_style="${details}"
                ;;
            active)
                icon="${ICON_ACTIVE}"
                color="${COLOR_ACCENT}"
                label_style="${BOLD}${label}${RESET}"
                details_style="${details}"
                ;;
            pending)
                icon="${ICON_PENDING}"
                color="${COLOR_MUTED}"
                label_style="${DIM}${label}${RESET}"
                details_style="${DIM}${details}${RESET}"
                ;;
            skip)
                icon="${ICON_SKIP}"
                color="${COLOR_MUTED}"
                label_style="${DIM}${label}${RESET}"
                details_style="${DIM}${details}${RESET}"
                ;;
            *)
                icon="${ICON_PENDING}"
                color="${COLOR_MUTED}"
                label_style="${label}"
                details_style="${details}"
                ;;
        esac

        printf "  ${color}${icon}${NC}  %-30s %s\n" "${label_style}" "${details_style}"
    done
    echo ""
}

# ==============================================================================
# SUMMARY FUNCTIONS
# ==============================================================================

# Show summary box (typically for success/completion)
# Usage: show_summary "title" "item1" "item2" ...
# Side effects: Writes to stdout
show_summary() {
    local title="$(_escape_input "$1")"
    shift
    local width=$(_clamp_width 60)

    echo ""
    echo -e "${COLOR_SUCCESS}${BOX_RTL}$(_repeat_char "$BOX_H" $width)${BOX_RTR}${NC}"

    local title_text="${ICON_SUCCESS}  ${title}"
    local title_len=$(_visible_len "$title_text")
    local title_padding=$((width - title_len - 2))
    echo -e "${COLOR_SUCCESS}${BOX_V}${NC}  ${BOLD}${COLOR_SUCCESS}${title_text}${RESET}$(_repeat_char ' ' $title_padding)${COLOR_SUCCESS}${BOX_V}${NC}"

    echo -e "${COLOR_SUCCESS}${BOX_VR}$(_repeat_char "$BOX_H" $width)${BOX_VL}${NC}"

    for item in "$@"; do
        local item_clean="$(_escape_input "$item")"
        local item_len=${#item_clean}
        local item_padding=$((width - item_len - 2))
        echo -e "${COLOR_SUCCESS}${BOX_V}${NC}  ${item_clean}$(_repeat_char ' ' $item_padding)${COLOR_SUCCESS}${BOX_V}${NC}"
    done

    echo -e "${COLOR_SUCCESS}${BOX_RBL}$(_repeat_char "$BOX_H" $width)${BOX_RBR}${NC}"
    echo ""
}

# ==============================================================================
# INTERACTIVE FUNCTIONS
# ==============================================================================

# Prompt for yes/no confirmation
# Usage: if prompt_confirm "Proceed?"; then ... fi
# Returns: 0 for yes, 1 for no
# Side effects: Writes to stdout, reads from stdin
prompt_confirm() {
    local message="$(_escape_input "$1")"
    echo ""
    echo -e "  ${COLOR_ACCENT}${ICON_ARROW}${NC} ${message} ${DIM}(y/n)${RESET}"
    read -p "  " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Prompt for multi-choice selection
# Usage: choice=$(prompt_choice "Select option:" "Option 1" "Option 2" "Option 3")
# Returns: Selected choice number (1-N) via stdout
# Side effects: Writes to stdout, reads from stdin
prompt_choice() {
    local message="$(_escape_input "$1")"
    shift
    local choices=("$@")

    echo ""
    echo -e "${COLOR_ACCENT}${message}${NC}"
    echo ""

    local i=1
    for choice in "${choices[@]}"; do
        local choice_clean="$(_escape_input "$choice")"
        echo -e "  ${COLOR_INFO}${i})${NC} ${choice_clean}"
        ((i++))
    done

    echo ""
    read -p "  ${ICON_ARROW} Enter choice: " -r
    echo "$REPLY"
}

# Show action prompt hint
# Usage: prompt_action "Press Enter to continue"
# Side effects: Writes to stdout
prompt_action() {
    local message="$(_escape_input "$1")"
    echo ""
    echo -e "  ${COLOR_MUTED}${ICON_ENTER}  ${message}${RESET}"
    echo ""
}

# ==============================================================================
# KEY-VALUE DISPLAY FUNCTIONS
# ==============================================================================

# Print key-value pair with formatted alignment
# Usage: print_kv "Key" "Value"
# Side effects: Writes to stdout
print_kv() {
    local key="$(_escape_input "$1")"
    local value="$(_escape_input "$2")"
    local key_width=20

    printf "  ${COLOR_MUTED}%-${key_width}s${NC} %s\n" "$key:" "$value"
}

# ==============================================================================
# USER INPUT FUNCTIONS
# ==============================================================================

# Ask yes/no question and return result
# Usage: if ask_yes_no "Continue?"; then ... fi
# Returns: 0 for yes, 1 for no
# Side effects: Writes to stdout, reads from stdin
ask_yes_no() {
    local message="$(_escape_input "$1")"
    echo ""
    echo -e "  ${COLOR_ACCENT}${ICON_ARROW}${NC} ${message} ${DIM}(y/n)${RESET}"
    read -p "  " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Ask for text input
# Usage: result=$(ask_input "Enter value")
# Returns: User input via stdout
# Side effects: Writes prompt to stderr, reads from stdin, returns value to stdout
ask_input() {
    local message="$(_escape_input "$1")"
    echo "" >&2
    echo -e "  ${COLOR_ACCENT}${ICON_ARROW}${NC} ${message}" >&2
    read -p "  " -r
    echo "$REPLY"
}

# ==============================================================================
# FORMATTING FUNCTIONS
# ==============================================================================

# Print a command in code style
# Usage: print_command "git status"
# Side effects: Writes to stdout
print_command() {
    local command="$(_escape_input "$1")"
    echo -e "    ${COLOR_CODE}${command}${NC}"
}

# Print a command inline (for use within other messages)
# Usage: echo "Run $(print_command_inline "git status") to check"
# Returns: Formatted command string via stdout
# Side effects: None (output captured by caller)
print_command_inline() {
    local command="$(_escape_input "$1")"
    echo -e "${COLOR_CODE}${command}${NC}"
}

# Print a list item
# Usage: print_item "Item text"
# Side effects: Writes to stdout
print_item() {
    local item="$(_escape_input "$1")"
    echo -e "  ${COLOR_MUTED}${ICON_ARROW}${NC} ${item}"
}

# Print a section header (simple, no box)
# Usage: print_section "Section Title"
# Side effects: Writes to stdout
print_section() {
    local title="$(_escape_input "$1")"
    echo ""
    echo -e "${BOLD}${COLOR_HEADER}${title}${NC}"
    echo ""
}

# Print a numbered step
# Usage: print_step 1 "First step"
# Side effects: Writes to stdout
print_step() {
    local number="$1"
    local description="$(_escape_input "$2")"
    echo -e "  ${COLOR_INFO}${number}.${NC} ${description}"
}

# Print next steps list
# Usage: print_next_steps "Step 1" "Step 2" "Step 3"
# Side effects: Writes to stdout
print_next_steps() {
    echo ""
    echo -e "${BOLD}${COLOR_HEADER}Next Steps:${NC}"
    echo ""
    local i=1
    for step in "$@"; do
        # Step may contain inline formatting from print_command_inline
        echo -e "  ${COLOR_INFO}${i}.${NC} ${step}"
        ((i++))
    done
    echo ""
}

# Print a simple box with title and optional items
# Usage: print_box "Title" ["item1" "item2" ...]
# Side effects: Writes to stdout
print_box() {
    local title="$(_escape_input "$1")"
    shift
    local width=$(_clamp_width 60)

    # Top border
    echo ""
    echo -e "${COLOR_BORDER}${BOX_RTL}$(_repeat_char "$BOX_H" $width)${BOX_RTR}${NC}"

    # Title
    local title_len=${#title}
    local title_padding=$((width - title_len - 2))
    echo -e "${COLOR_BORDER}${BOX_V}${NC}  ${BOLD}${COLOR_SUCCESS}${title}${RESET}$(_repeat_char ' ' $title_padding)${COLOR_BORDER}${BOX_V}${NC}"

    # Items (if provided)
    if [ $# -gt 0 ]; then
        echo -e "${COLOR_BORDER}${BOX_VR}$(_repeat_char "$BOX_H" $width)${BOX_VL}${NC}"
        for item in "$@"; do
            local item_clean="$(_escape_input "$item")"
            local item_len=${#item_clean}
            local item_padding=$((width - item_len - 2))
            echo -e "${COLOR_BORDER}${BOX_V}${NC}  ${item_clean}$(_repeat_char ' ' $item_padding)${COLOR_BORDER}${BOX_V}${NC}"
        done
    fi

    # Bottom border
    echo -e "${COLOR_BORDER}${BOX_RBL}$(_repeat_char "$BOX_H" $width)${BOX_RBR}${NC}"
    echo ""
}

# ==============================================================================
# BACKWARDS COMPATIBILITY (Deprecated - Legacy Support)
# ==============================================================================

# Legacy function names from install.sh and existing scripts
print_info() { show_info "$@"; }
print_success() { show_success "$@"; }
print_error() { show_error "$@"; }
print_warning() { show_warning "$@"; }
print_header() { show_header "$@"; }

# ==============================================================================
# INITIALIZATION COMPLETE
# ==============================================================================

# Export all functions for subshells if needed
export -f show_success show_error show_warning show_info
export -f show_section_header show_header show_subheader
export -f show_box show_progress_bar show_checklist show_summary
export -f prompt_confirm prompt_choice prompt_action
export -f print_info print_success print_error print_warning print_header
export -f print_kv ask_yes_no ask_input
export -f print_command print_command_inline print_item print_section print_step print_next_steps print_box

# UI library loaded
return 0 2>/dev/null || true
