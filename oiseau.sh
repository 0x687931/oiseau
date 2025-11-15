#!/bin/bash
# Oiseau - A Modern Terminal UI Library for Bash
# Version: 1.0.0
# License: MIT
#
# Pure bash UI library with zero dependencies, featuring:
# - 256-color ANSI palette with smart degradation
# - 30+ reusable widgets (boxes, progress bars, checklists, etc.)
# - Automatic capability detection (color, UTF-8, terminal dimensions)
# - Input sanitization and security
# - Works in pipes, redirects, and all terminal environments
#
# Usage:
#   source oiseau/oiseau.sh
#   show_success "Operation completed!"
#   show_box error "Failed" "Something went wrong" "command to fix"

# ==============================================================================
# TERMINAL DETECTION & INITIALIZATION
# ==============================================================================

# Safety toggle - disable all UI features if UI_DISABLE=1
if [ "${UI_DISABLE:-0}" = "1" ] || [ -n "${NO_COLOR+x}" ]; then
    export OISEAU_MODE="plain"
    export OISEAU_HAS_COLOR=0
    export OISEAU_HAS_UTF8=0
else
    # Detect if we're in a TTY
    if [[ -t 1 ]]; then
        export OISEAU_IS_TTY=1
    else
        export OISEAU_IS_TTY=0
        export OISEAU_MODE="plain"
    fi

    # Detect color support
    if [ "$OISEAU_IS_TTY" = "1" ] && [ "$TERM" != "dumb" ] && [ -n "$TERM" ]; then
        if command -v tput >/dev/null 2>&1; then
            local colors=$(tput colors 2>/dev/null || echo 0)
            if [ "$colors" -ge 256 ]; then
                export OISEAU_HAS_COLOR=1
            else
                export OISEAU_HAS_COLOR=0
            fi
        else
            export OISEAU_HAS_COLOR=1
        fi
    else
        export OISEAU_HAS_COLOR=0
    fi

    # Detect UTF-8 support
    if [ "$OISEAU_IS_TTY" = "1" ]; then
        local locale_check="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
        if [[ "$locale_check" =~ [Uu][Tt][Ff]-?8 ]]; then
            export OISEAU_HAS_UTF8=1
        else
            export OISEAU_HAS_UTF8=0
        fi
    else
        export OISEAU_HAS_UTF8=0
    fi

    # Determine UI mode
    if [ "$OISEAU_HAS_COLOR" = "1" ] && [ "$OISEAU_HAS_UTF8" = "1" ]; then
        export OISEAU_MODE="rich"
    elif [ "$OISEAU_HAS_COLOR" = "1" ]; then
        export OISEAU_MODE="color"
    else
        export OISEAU_MODE="plain"
    fi
fi

# Get terminal width (cached)
export OISEAU_WIDTH=$(tput cols 2>/dev/null || echo 80)

# ==============================================================================
# COLOR DEFINITIONS (ANSI 256-Color Palette)
# ==============================================================================

if [ "$OISEAU_HAS_COLOR" = "1" ]; then
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
    export RESET='\033[0m'
else
    # No color support - all empty
    export COLOR_SUCCESS="" COLOR_ERROR="" COLOR_WARNING="" COLOR_INFO=""
    export COLOR_ACCENT="" COLOR_HEADER="" COLOR_BORDER="" COLOR_MUTED=""
    export COLOR_DIM="" COLOR_P0="" COLOR_P1="" COLOR_P2=""
    export COLOR_LINK="" COLOR_CODE=""
    export BOLD="" DIM="" ITALIC="" RESET=""
fi

# ==============================================================================
# ICON & BOX DRAWING DEFINITIONS
# ==============================================================================

if [ "$OISEAU_HAS_UTF8" = "1" ]; then
    # Status Icons
    export ICON_SUCCESS="✓" ICON_ERROR="✗" ICON_WARNING="⚠" ICON_INFO="ℹ"
    export ICON_PENDING="○" ICON_ACTIVE="●" ICON_DONE="✓" ICON_SKIP="⊘"

    # Box Drawing - Rounded
    export BOX_RTL="╭" BOX_RTR="╮" BOX_RBL="╰" BOX_RBR="╯"
    export BOX_H="─" BOX_V="│" BOX_VR="├" BOX_VL="┤"

    # Box Drawing - Double
    export BOX_DTL="┏" BOX_DTR="┓" BOX_DBL="┗" BOX_DBR="┛"
    export BOX_DH="━" BOX_DV="┃" BOX_DVR="┣" BOX_DVL="┫"
else
    # ASCII Fallbacks
    export ICON_SUCCESS="[OK]" ICON_ERROR="[X]" ICON_WARNING="[!]" ICON_INFO="[i]"
    export ICON_PENDING="[ ]" ICON_ACTIVE="[*]" ICON_DONE="[+]" ICON_SKIP="[-]"

    export BOX_RTL="+" BOX_RTR="+" BOX_RBL="+" BOX_RBR="+"
    export BOX_H="-" BOX_V="|" BOX_VR="+" BOX_VL="+"

    export BOX_DTL="+" BOX_DTR="+" BOX_DBL="+" BOX_DBR="+"
    export BOX_DH="=" BOX_DV="|" BOX_DVR="+" BOX_DVL="+"
fi

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Escape user input to prevent code injection
_escape_input() {
    local input="$1"
    # Remove ANSI escape sequences and control characters
    echo "$input" | sed $'s/\033[^m]*m//g' | tr -d '\000-\037' | tr -d '\177'
}

# Calculate visible length (ignoring ANSI codes)
_visible_len() {
    local str="$1"
    # Remove ANSI codes before calculating length
    local clean=$(echo -e "$str" | sed $'s/\033[^m]*m//g')
    echo "${#clean}"
}

# Calculate display width (accounts for wide characters like emojis)
# Emojis and some Unicode characters take 2 columns, this estimates the width
_display_width() {
    local str="$1"
    # Remove ANSI codes first
    local clean=$(echo -e "$str" | sed $'s/\033[^m]*m//g')

    # Try perl for accurate display width calculation if the module is available
    if command -v perl >/dev/null 2>&1; then
        local perl_result
        perl_result=$(echo "$clean" | perl -C -ne 'use Text::VisualWidth::PP qw(width); print width($_)' 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$perl_result" ]; then
            echo "$perl_result"
            return
        fi
    fi

    # Fallback: simple estimation using heuristics
    # Count characters and add extra width for emojis (which take 2 columns)
    local char_count=$(echo -n "$clean" | wc -m | tr -d ' ')

    # Count common emojis and special characters that take 2 columns
    local emoji_count=$(echo "$clean" | grep -o '[🐦🎯✓✗⚠ℹ⏳◆⬤○◇▶●◉⚡🔄❌✔⚙🎨📦🚀💡🔍📝💬💭]' 2>/dev/null | wc -l | tr -d ' ')

    # Display width = character count + emoji count (since emojis take 2 columns but count as 1 char)
    echo $((char_count + emoji_count))
}

# Pad a string to a specific display width
# Usage: _pad_to_width "text" 60
_pad_to_width() {
    local text="$1"
    local target_width="$2"
    local current_width=$(_display_width "$text")
    local padding=$((target_width - current_width))

    if [ "$padding" -gt 0 ]; then
        echo -n "$text"
        printf "%${padding}s" ""
    else
        echo -n "$text"
    fi
}

# Repeat a character N times
_repeat_char() {
    local char="$1"
    local count="$2"
    printf "%${count}s" | tr ' ' "$char"
}

# Truncate string to max width with ellipsis
_truncate() {
    local str="$1"
    local max_width="$2"
    local visible_len=$(_visible_len "$str")

    if [ "$visible_len" -le "$max_width" ]; then
        echo "$str"
    else
        local truncated="${str:0:$((max_width - 3))}"
        echo "${truncated}..."
    fi
}

# Clamp width to terminal size
_clamp_width() {
    local requested="$1"
    local max=$((OISEAU_WIDTH - 4))
    if [ "$requested" -gt "$max" ]; then
        echo "$max"
    else
        echo "$requested"
    fi
}

# ==============================================================================
# SIMPLE MESSAGE FUNCTIONS
# ==============================================================================

# Show success message with green checkmark
show_success() {
    local msg="$(_escape_input "$1")"
    echo -e "  ${COLOR_SUCCESS}${ICON_SUCCESS}${RESET}  $msg"
}

# Show error message with red X
show_error() {
    local msg="$(_escape_input "$1")"
    echo -e "  ${COLOR_ERROR}${ICON_ERROR}${RESET}  $msg"
}

# Show warning message with orange warning icon
show_warning() {
    local msg="$(_escape_input "$1")"
    echo -e "  ${COLOR_WARNING}${ICON_WARNING}${RESET}  $msg"
}

# Show info message with blue info icon
show_info() {
    local msg="$(_escape_input "$1")"
    echo -e "  ${COLOR_INFO}${ICON_INFO}${RESET}  $msg"
}

# ==============================================================================
# HEADER FUNCTIONS
# ==============================================================================

# Show section header with optional step counter
# Usage: show_section_header "Title" [step_num] [total_steps] [subtitle]
show_section_header() {
    local title="$(_escape_input "$1")"
    local step_num="${2:-}"
    local total_steps="${3:-}"
    local subtitle="${4:-}"

    local width=$(_clamp_width 60)
    local inner_width=$((width - 2))

    echo ""
    echo -e "${COLOR_BORDER}${BOX_RTL}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_RTR}${RESET}"

    # Title line
    echo -e "${COLOR_BORDER}${BOX_V}${RESET}  ${COLOR_HEADER}${BOLD}${title}${RESET}"

    # Step counter and subtitle if provided
    if [ -n "$step_num" ] && [ -n "$total_steps" ]; then
        local step_text="Step ${step_num} of ${total_steps}"
        if [ -n "$subtitle" ]; then
            step_text="${step_text} › ${subtitle}"
        fi
        echo -e "${COLOR_BORDER}${BOX_V}${RESET}  ${COLOR_MUTED}${step_text}${RESET}"
    fi

    echo -e "${COLOR_BORDER}${BOX_RBL}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_RBR}${RESET}"
    echo ""
}

# Simple header
show_header() {
    local title="$(_escape_input "$1")"
    echo -e "\n${COLOR_HEADER}${BOLD}${title}${RESET}\n"
}

# Muted subheader
show_subheader() {
    local title="$(_escape_input "$1")"
    echo -e "${COLOR_MUTED}${title}${RESET}"
}

# ==============================================================================
# BOX COMPONENTS
# ==============================================================================

# Show a styled box with title, message, and optional commands
# Usage: show_box <type> <title> <message> [command1] [command2] ...
# Types: error, warning, info, success
show_box() {
    local type="$1"; shift
    local title="$(_escape_input "$1")"; shift
    local message="$(_escape_input "$1")"; shift
    local commands=("$@")

    # Determine colors and icon based on type
    local color icon
    case "$type" in
        error)   color="$COLOR_ERROR"; icon="$ICON_ERROR" ;;
        warning) color="$COLOR_WARNING"; icon="$ICON_WARNING" ;;
        success) color="$COLOR_SUCCESS"; icon="$ICON_SUCCESS" ;;
        *)       color="$COLOR_INFO"; icon="$ICON_INFO" ;;
    esac

    local width=$(_clamp_width 60)
    local inner_width=$((width - 2))

    # Top border
    echo -e "${color}${BOX_DTL}$(_repeat_char "${BOX_DH}" "$inner_width")${BOX_DTR}${RESET}"

    # Title line
    echo -e "${color}${BOX_DV}${RESET}  ${color}${icon}  ${BOLD}${title}${RESET}"

    # Separator
    echo -e "${color}${BOX_DVR}$(_repeat_char "${BOX_DH}" "$inner_width")${BOX_DVL}${RESET}"

    # Empty line
    echo -e "${color}${BOX_DV}${RESET}"

    # Message (word-wrapped if needed)
    echo "$message" | fold -s -w $((inner_width - 4)) | while IFS= read -r line; do
        echo -e "${color}${BOX_DV}${RESET}  $line"
    done

    # Commands section if provided
    if [ "${#commands[@]}" -gt 0 ]; then
        echo -e "${color}${BOX_DV}${RESET}"
        if [ "${#commands[@]}" -eq 1 ]; then
            echo -e "${color}${BOX_DV}${RESET}  ${COLOR_MUTED}To resolve:${RESET}"
        else
            echo -e "${color}${BOX_DV}${RESET}  ${COLOR_MUTED}To resolve:${RESET}"
        fi
        for cmd in "${commands[@]}"; do
            echo -e "${color}${BOX_DV}${RESET}    ${COLOR_CODE}${cmd}${RESET}"
        done
    fi

    # Bottom empty line and border
    echo -e "${color}${BOX_DV}${RESET}"
    echo -e "${color}${BOX_DBL}$(_repeat_char "${BOX_DH}" "$inner_width")${BOX_DBR}${RESET}"
}

# ==============================================================================
# PROGRESS & CHECKLIST
# ==============================================================================

# Show a progress bar
# Usage: show_progress_bar <current> <total> [label]
show_progress_bar() {
    local current="$1"
    local total="$2"
    local label="${3:-Progress}"

    local percent=$((current * 100 / total))
    local bar_width=20
    local filled=$((current * bar_width / total))
    local empty=$((bar_width - filled))

    local bar="${COLOR_SUCCESS}$(_repeat_char '█' "$filled")${COLOR_DIM}$(_repeat_char '░' "$empty")${RESET}"

    echo -e "${label}: ${bar} ${percent}% (${current}/${total})"
}

# Show a checklist with status indicators
# Usage: show_checklist <items_array_name>
# Array format: "status|label|details" where status is: done, active, pending, skip
show_checklist() {
    local array_name="$1"
    # Use eval for bash 3.x/4.x compatibility (nameref requires bash 4.3+)
    eval "local items=(\"\${${array_name}[@]}\")"

    for item in "${items[@]}"; do
        IFS='|' read -r status label details <<< "$item"

        local icon color
        case "$status" in
            done)    icon="$ICON_DONE"; color="$COLOR_SUCCESS" ;;
            active)  icon="$ICON_ACTIVE"; color="$COLOR_INFO" ;;
            skip)    icon="$ICON_SKIP"; color="$COLOR_DIM" ;;
            *)       icon="$ICON_PENDING"; color="$COLOR_MUTED" ;;
        esac

        if [ -n "$details" ]; then
            echo -e "  ${color}${icon}${RESET}  ${BOLD}${label}${RESET}  ${COLOR_MUTED}${details}${RESET}"
        else
            echo -e "  ${color}${icon}${RESET}  ${label}"
        fi
    done
}

# ==============================================================================
# SUMMARY BOX
# ==============================================================================

# Show a summary box with multiple items
# Usage: show_summary "title" "item1" "item2" "item3"
show_summary() {
    local title="$1"; shift
    local items=("$@")

    local width=$(_clamp_width 60)
    local inner_width=$((width - 2))

    echo -e "${COLOR_BORDER}${BOX_RTL}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_RTR}${RESET}"
    echo -e "${COLOR_BORDER}${BOX_V}${RESET}  ${COLOR_SUCCESS}${ICON_SUCCESS}  ${BOLD}${title}${RESET}"
    echo -e "${COLOR_BORDER}${BOX_VR}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_VL}${RESET}"

    for item in "${items[@]}"; do
        echo -e "${COLOR_BORDER}${BOX_V}${RESET}  $item"
    done

    echo -e "${COLOR_BORDER}${BOX_RBL}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_RBR}${RESET}"
}

# ==============================================================================
# INTERACTIVE PROMPTS
# ==============================================================================

# Confirm prompt (yes/no)
# Returns: 0 for yes, 1 for no
prompt_confirm() {
    local msg="$1"
    local default="${2:-n}"

    local prompt_text
    if [ "$default" = "y" ]; then
        prompt_text="${msg} [Y/n]: "
    else
        prompt_text="${msg} [y/N]: "
    fi

    echo -ne "${COLOR_INFO}${ICON_INFO}${RESET}  ${prompt_text}"
    read -r response

    response="${response:-$default}"
    [[ "$response" =~ ^[Yy] ]]
}

# Ask yes/no question
ask_yes_no() {
    prompt_confirm "$@"
}

# Ask for text input
ask_input() {
    local msg="$1"
    local default="${2:-}"

    if [ -n "$default" ]; then
        echo -ne "${COLOR_INFO}${ICON_INFO}${RESET}  ${msg} [${default}]: "
    else
        echo -ne "${COLOR_INFO}${ICON_INFO}${RESET}  ${msg}: "
    fi

    read -r response
    echo "${response:-$default}"
}

# ==============================================================================
# FORMATTING FUNCTIONS
# ==============================================================================

# Print key-value pair
print_kv() {
    local key="$1"
    local value="$2"
    local key_width="${3:-20}"

    printf "  ${COLOR_MUTED}%-${key_width}s${RESET} %s\n" "$key" "$value"
}

# Print command in code style
print_command() {
    local cmd="$1"
    echo -e "  ${COLOR_CODE}${cmd}${RESET}"
}

# Print inline command
print_command_inline() {
    local cmd="$1"
    echo -e "${COLOR_CODE}${cmd}${RESET}"
}

# Print bulleted item
print_item() {
    local item="$1"
    echo -e "  • $item"
}

# Print section title
print_section() {
    local title="$1"
    echo -e "\n${COLOR_HEADER}${title}${RESET}"
}

# Print numbered step
print_step() {
    local num="$1"
    local text="$2"
    echo -e "  ${COLOR_INFO}${num}.${RESET} ${text}"
}

# Print "next steps" list
print_next_steps() {
    echo -e "\n${COLOR_HEADER}${BOLD}Next steps:${RESET}\n"
    local i=1
    for step in "$@"; do
        print_step "$i" "$step"
        ((i++))
    done
    echo ""
}

# Simple box (legacy compatibility)
print_box() {
    local title="$1"; shift
    local items=("$@")
    show_summary "$title" "${items[@]}"
}

# ==============================================================================
# BACKWARD COMPATIBILITY ALIASES
# ==============================================================================

print_info() { show_info "$@"; }
print_success() { show_success "$@"; }
print_error() { show_error "$@"; }
print_warning() { show_warning "$@"; }
print_header() { show_header "$@"; }

# ==============================================================================
# INITIALIZATION COMPLETE
# ==============================================================================

export OISEAU_LOADED=1
