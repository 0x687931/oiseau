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
            colors=$(tput colors 2>/dev/null || echo 0)
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
        locale_check="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
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
OISEAU_WIDTH=$(tput cols 2>/dev/null || echo 80)
export OISEAU_WIDTH

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
    local clean
    clean=$(echo -e "$str" | sed $'s/\033[^m]*m//g')
    echo "${#clean}"
}

# Calculate display width (accounts for wide characters like emojis)
# Emojis and some Unicode characters take 2 columns, this estimates the width
_display_width() {
    local str="$1"
    # Remove ANSI codes first
    local clean
    clean=$(echo -e "$str" | sed $'s/\033[^m]*m//g')

    # Try perl for accurate display width calculation if the module is available
    if command -v perl >/dev/null 2>&1; then
        local perl_result
        if perl_result=$(echo "$clean" | perl -C -ne 'use Text::VisualWidth::PP qw(width); print width($_)' 2>/dev/null) && [ -n "$perl_result" ]; then
            echo "$perl_result"
            return
        fi
    fi

    # Fallback: Perl-based wcwidth estimation without external modules
    # This handles CJK, emojis, and other wide characters more accurately
    if command -v perl >/dev/null 2>&1; then
        local perl_width
        if perl_width=$(echo -n "$clean" | perl -C -ne '
            use utf8;
            binmode(STDIN, ":utf8");
            binmode(STDOUT, ":utf8");
            chomp;
            my $width = 0;
            for my $char (split //, $_) {
                my $code = ord($char);
                # Special case: Common icon characters that modern terminals render as width 1
                # These are technically in wide ranges but render narrow in most terminals
                if (
                    $code == 0x2713 ||  # ✓ Check mark
                    $code == 0x2717 ||  # ✗ Ballot X
                    $code == 0x26A0 ||  # ⚠ Warning sign
                    $code == 0x2139 ||  # ℹ Information source
                    $code == 0x25CB ||  # ○ White circle
                    $code == 0x25CF ||  # ● Black circle
                    $code == 0x2298     # ⊘ Circled division slash
                ) {
                    $width += 1;
                }
                # East Asian Width ranges (CJK, full-width, etc.)
                # Based on Unicode East Asian Width property
                # Note: Ambiguous-width characters (hiragana, katakana) are treated as wide
                # for better compatibility with CJK-aware terminal emulators
                elsif (
                    # Hiragana
                    ($code >= 0x3040 && $code <= 0x309F) ||
                    # Katakana
                    ($code >= 0x30A0 && $code <= 0x30FF) ||
                    # CJK Extension A
                    ($code >= 0x3400 && $code <= 0x4DBF) ||
                    # CJK Unified Ideographs
                    ($code >= 0x4E00 && $code <= 0x9FFF) ||
                    # Hangul Syllables
                    ($code >= 0xAC00 && $code <= 0xD7AF) ||
                    # CJK Compatibility Ideographs
                    ($code >= 0xF900 && $code <= 0xFAFF) ||
                    # Full-width Latin
                    ($code >= 0xFF00 && $code <= 0xFF60) ||
                    # Full-width Hangul
                    ($code >= 0xFFA0 && $code <= 0xFFDC) ||
                    # Emoji ranges (most common)
                    ($code >= 0x1F300 && $code <= 0x1F9FF) ||
                    # Supplementary Ideographic Plane
                    ($code >= 0x20000 && $code <= 0x2FFFF) ||
                    # Misc symbols and pictographs
                    ($code >= 0x2600 && $code <= 0x26FF) ||
                    # Dingbats
                    ($code >= 0x2700 && $code <= 0x27BF)
                ) {
                    $width += 2;
                } else {
                    $width += 1;
                }
            }
            print $width;
        ' 2>/dev/null) && [ -n "$perl_width" ]; then
            echo "$perl_width"
            return
        fi
    fi

    # Last resort: basic heuristic for systems without perl
    # This is less accurate but better than nothing
    local char_count
    char_count=$(echo -n "$clean" | wc -m | tr -d ' ')

    # Count characters that are likely wide (multibyte UTF-8 sequences of 3+ bytes)
    # CJK and emoji are typically 3-4 byte sequences
    # Use LC_ALL=C to get actual byte count instead of character count
    local byte_count
    byte_count=$(LC_ALL=C printf %s "$clean" | wc -c | tr -d ' ')
    local estimated_wide=$(( (byte_count - char_count) / 2 ))

    # Adjust for common icon characters that are narrow in modern terminals
    # These have 3-byte UTF-8 encoding but render as width 1
    local icon_count=0
    for icon in "✓" "✗" "⚠" "ℹ" "○" "●" "⊘"; do
        local count
        count=$(echo -n "$clean" | grep -o "$icon" 2>/dev/null | wc -l | tr -d ' ')
        icon_count=$((icon_count + count))
    done
    estimated_wide=$((estimated_wide - icon_count))

    # Ensure we don't over-estimate or under-estimate
    if [ "$estimated_wide" -lt 0 ]; then
        estimated_wide=0
    fi

    echo $((char_count + estimated_wide))
}

# Pad a string to a specific display width
# Usage: _pad_to_width "text" 60
_pad_to_width() {
    local text="$1"
    local target_width="$2"
    local current_width
    current_width=$(_display_width "$text")
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
    local visible_len
    visible_len=$(_visible_len "$str")

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
    local msg
    msg="$(_escape_input "$1")"
    echo -e "  ${COLOR_SUCCESS}${ICON_SUCCESS}${RESET}  $msg"
}

# Show error message with red X
show_error() {
    local msg
    msg="$(_escape_input "$1")"
    echo -e "  ${COLOR_ERROR}${ICON_ERROR}${RESET}  $msg"
}

# Show warning message with orange warning icon
show_warning() {
    local msg
    msg="$(_escape_input "$1")"
    echo -e "  ${COLOR_WARNING}${ICON_WARNING}${RESET}  $msg"
}

# Show info message with blue info icon
show_info() {
    local msg
    msg="$(_escape_input "$1")"
    echo -e "  ${COLOR_INFO}${ICON_INFO}${RESET}  $msg"
}

# ==============================================================================
# HEADER FUNCTIONS
# ==============================================================================

# Show section header with optional step counter
# Usage: show_section_header "Title" [step_num] [total_steps] [subtitle]
show_section_header() {
    local title
    title="$(_escape_input "$1")"
    local step_num="${2:-}"
    local total_steps="${3:-}"
    local subtitle="${4:-}"

    local width
    width=$(_clamp_width 60)
    local inner_width=$((width - 2))

    echo ""
    echo -e "${COLOR_BORDER}${BOX_RTL}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_RTR}${RESET}"

    # Title line
    local title_display_width
    title_display_width=$(_display_width "$title")
    local title_padding=$((inner_width - title_display_width - 2))
    echo -e "${COLOR_BORDER}${BOX_V}${RESET}  ${COLOR_HEADER}${BOLD}${title}${RESET}$(_repeat_char " " "$title_padding")${COLOR_BORDER}${BOX_V}${RESET}"

    # Step counter and subtitle if provided
    if [ -n "$step_num" ] && [ -n "$total_steps" ]; then
        local step_text="Step ${step_num} of ${total_steps}"
        if [ -n "$subtitle" ]; then
            step_text="${step_text} › ${subtitle}"
        fi
        local step_display_width
        step_display_width=$(_display_width "$step_text")
        local step_padding=$((inner_width - step_display_width - 2))
        echo -e "${COLOR_BORDER}${BOX_V}${RESET}  ${COLOR_MUTED}${step_text}${RESET}$(_repeat_char " " "$step_padding")${COLOR_BORDER}${BOX_V}${RESET}"
    fi

    echo -e "${COLOR_BORDER}${BOX_RBL}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_RBR}${RESET}"
    echo ""
}

# Simple header
show_header() {
    local title
    title="$(_escape_input "$1")"
    echo -e "\n${COLOR_HEADER}${BOLD}${title}${RESET}\n"
}

# Muted subheader
show_subheader() {
    local title
    title="$(_escape_input "$1")"
    echo -e "${COLOR_MUTED}${title}${RESET}"
}

# Header box - decorative box with title and optional subtitle
# Usage: show_header_box "title" ["subtitle"]
show_header_box() {
    local title
    title="$(_escape_input "$1")"
    local subtitle
    subtitle="$(_escape_input "$2")"

    local width
    width=$(_clamp_width 60)
    local inner_width=$((width - 2))

    echo ""
    echo -e "${COLOR_HEADER}${BOLD}"

    # Top border
    echo -e "  ${BOX_DTL}$(_repeat_char "${BOX_DH}" "$inner_width")${BOX_DTR}"

    # Empty line
    echo -e "  ${BOX_DV}$(_pad_to_width "" "$inner_width")${BOX_DV}"

    # Title (word-wrapped if needed)
    echo "$title" | fold -s -w $((inner_width - 6)) | while IFS= read -r line; do
        echo -e "  ${BOX_DV}$(_pad_to_width "   $line" "$inner_width")${BOX_DV}"
    done

    # Empty line
    echo -e "  ${BOX_DV}$(_pad_to_width "" "$inner_width")${BOX_DV}"

    # Subtitle (word-wrapped if needed)
    if [ -n "$subtitle" ]; then
        echo "$subtitle" | fold -s -w $((inner_width - 6)) | while IFS= read -r line; do
            echo -e "  ${BOX_DV}$(_pad_to_width "   $line" "$inner_width")${BOX_DV}"
        done
        echo -e "  ${BOX_DV}$(_pad_to_width "" "$inner_width")${BOX_DV}"
    fi

    # Bottom border
    echo -e "  ${BOX_DBL}$(_repeat_char "${BOX_DH}" "$inner_width")${BOX_DBR}"

    echo -e "${RESET}"
}

# ==============================================================================
# BOX COMPONENTS
# ==============================================================================

# Show a styled box with title, message, and optional commands
# Usage: show_box <type> <title> <message> [command1] [command2] ...
# Types: error, warning, info, success
show_box() {
    local type="$1"; shift
    local title
    title="$(_escape_input "$1")"; shift
    local content
    content="$(_escape_input "$1")"; shift
    local commands=("$@")

    # Determine colors and icon based on type
    local color icon
    case "$type" in
        error)   color="$COLOR_ERROR"; icon="$ICON_ERROR" ;;
        warning) color="$COLOR_WARNING"; icon="$ICON_WARNING" ;;
        success) color="$COLOR_SUCCESS"; icon="$ICON_SUCCESS" ;;
        *)       color="$COLOR_INFO"; icon="$ICON_INFO" ;;
    esac

    local width
    width=$(_clamp_width 60)
    local inner_width=$((width - 2))

    # Top border
    echo -e "${color}${BOX_DTL}$(_repeat_char "${BOX_DH}" "$inner_width")${BOX_DTR}${RESET}"

    # Title line (with proper right border)
    local title_content="  ${icon}  ${title}"
    echo -e "${color}${BOX_DV}${RESET}$(_pad_to_width "$title_content" "$inner_width")${color}${BOX_DV}${RESET}"

    # Separator
    echo -e "${color}${BOX_DVR}$(_repeat_char "${BOX_DH}" "$inner_width")${BOX_DVL}${RESET}"

    # Empty line
    echo -e "${color}${BOX_DV}${RESET}$(_pad_to_width "" "$inner_width")${color}${BOX_DV}${RESET}"

    # Message (word-wrapped if needed)
    echo "$content" | fold -s -w $((inner_width - 4)) | while IFS= read -r line; do
        echo -e "${color}${BOX_DV}${RESET}$(_pad_to_width "  $line" "$inner_width")${color}${BOX_DV}${RESET}"
    done

    # Commands section if provided
    if [ "${#commands[@]}" -gt 0 ]; then
        echo -e "${color}${BOX_DV}${RESET}$(_pad_to_width "" "$inner_width")${color}${BOX_DV}${RESET}"
        echo -e "${color}${BOX_DV}${RESET}$(_pad_to_width "  To resolve:" "$inner_width")${color}${BOX_DV}${RESET}"
        for cmd in "${commands[@]}"; do
            echo -e "${color}${BOX_DV}${RESET}$(_pad_to_width "    ${cmd}" "$inner_width")${color}${BOX_DV}${RESET}"
        done
    fi

    # Bottom empty line and border
    echo -e "${color}${BOX_DV}${RESET}$(_pad_to_width "" "$inner_width")${color}${BOX_DV}${RESET}"
    echo -e "${color}${BOX_DBL}$(_repeat_char "${BOX_DH}" "$inner_width")${BOX_DBR}${RESET}"
}

# ==============================================================================
# PROGRESS & CHECKLIST
# ==============================================================================

#===============================================================================
# FUNCTION: show_progress_bar
# DESCRIPTION: Display a progress bar with optional animation
# PARAMETERS:
#   $1 - current (number, required): Current progress value
#   $2 - total (number, required): Total/maximum value
#   $3 - label (string, optional): Label text (default: "Progress")
# ENVIRONMENT VARIABLES:
#   OISEAU_PROGRESS_ANIMATE - Enable in-place animation (1=yes, 0=no, default: auto)
#   OISEAU_PROGRESS_WIDTH   - Bar width in characters (default: 20)
# RETURNS: 0 on success, 1 on error
# MODES:
#   Rich:  UTF-8 filled/empty blocks (█░)
#   Color: ASCII filled/empty (#-)
#   Plain: Percentage only
# BEHAVIOR:
#   - Auto-detects animation: if called rapidly in TTY, updates in place
#   - Prints newline when progress reaches 100%
#   - Non-TTY or Plain mode: always prints new line
# EXAMPLE:
#   for i in {1..100}; do
#     show_progress_bar $i 100 "Downloading"
#     sleep 0.05
#   done
#===============================================================================
show_progress_bar() {
    local current="$1"
    local total="$2"
    local label="${3:-Progress}"

    # Validate inputs
    if [ -z "$current" ] || [ -z "$total" ]; then
        echo "ERROR: show_progress_bar requires current and total arguments" >&2
        return 1
    fi

    # Ensure numeric values
    if ! [[ "$current" =~ ^[0-9]+$ ]] || ! [[ "$total" =~ ^[0-9]+$ ]]; then
        echo "ERROR: show_progress_bar requires numeric arguments" >&2
        return 1
    fi

    # Prevent division by zero
    if [ "$total" -eq 0 ]; then
        echo "ERROR: show_progress_bar total cannot be zero" >&2
        return 1
    fi

    # Sanitize label
    local safe_label
    safe_label="$(_escape_input "$label")"

    # Calculate progress
    local percent=$((current * 100 / total))
    local bar_width="${OISEAU_PROGRESS_WIDTH:-20}"
    local filled=$((current * bar_width / total))
    local empty=$((bar_width - filled))

    # Determine if we should animate (update in place)
    local should_animate=0

    # Check explicit override
    if [ -n "${OISEAU_PROGRESS_ANIMATE+x}" ]; then
        if [ "$OISEAU_PROGRESS_ANIMATE" = "1" ]; then
            should_animate=1
        fi
    else
        # Auto-detect: animate if stdout is a TTY and not plain mode
        # Check at call time (not source time) to handle redirected output
        if [ -t 1 ] && [ "$OISEAU_MODE" != "plain" ]; then
            should_animate=1
        fi
    fi

    # Build progress bar based on mode
    local bar_display
    if [ "$OISEAU_MODE" = "plain" ]; then
        # Plain mode: just percentage
        bar_display="${percent}%"
    else
        # Build visual bar
        local filled_char empty_char
        if [ "$OISEAU_MODE" = "rich" ]; then
            filled_char="█"
            empty_char="░"
        else
            filled_char="#"
            empty_char="-"
        fi

        local bar
        bar="${COLOR_SUCCESS}$(_repeat_char "$filled_char" "$filled")${COLOR_DIM}$(_repeat_char "$empty_char" "$empty")${RESET}"
        bar_display="${bar} ${percent}%"
    fi

    # Add count if space allows
    local full_display="${safe_label}: ${bar_display} (${current}/${total})"

    # Output
    if [ "$should_animate" = "1" ]; then
        # In-place update (carriage return, clear to end of line)
        echo -en "\r${full_display}\033[K"

        # Print newline when complete
        if [ "$current" -ge "$total" ]; then
            echo ""
        fi
    else
        # Static mode: print new line each time
        echo -e "${full_display}"
    fi
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

    local width
    width=$(_clamp_width 60)
    local inner_width=$((width - 2))

    echo -e "${COLOR_BORDER}${BOX_RTL}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_RTR}${RESET}"

    local title_content="  ${ICON_SUCCESS}  ${title}"
    local title_display_width
    title_display_width=$(_display_width "$title_content")
    local title_padding=$((inner_width - title_display_width))
    echo -e "${COLOR_BORDER}${BOX_V}${RESET}  ${COLOR_SUCCESS}${ICON_SUCCESS}${RESET}  ${BOLD}${title}${RESET}$(_repeat_char " " "$title_padding")${COLOR_BORDER}${BOX_V}${RESET}"

    echo -e "${COLOR_BORDER}${BOX_VR}$(_repeat_char "${BOX_H}" "$inner_width")${BOX_VL}${RESET}"

    for item in "${items[@]}"; do
        local item_display_width
        item_display_width=$(_display_width "$item")
        local item_padding=$((inner_width - item_display_width - 2))
        echo -e "${COLOR_BORDER}${BOX_V}${RESET}  $item$(_repeat_char " " "$item_padding")${COLOR_BORDER}${BOX_V}${RESET}"
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

#===============================================================================
# FUNCTION: ask_input
# DESCRIPTION: Prompt for text input with optional password masking and validation
# PARAMETERS:
#   $1 - prompt (string, required): Prompt message
#   $2 - default (string, optional): Default value if user presses Enter
#   $3 - mode (string, optional): Input mode (text|password|email|number)
# RETURNS: User input (sanitized)
# MODES:
#   text     - Normal text input (default)
#   password - Hidden input, shows bullets (••••)
#   email    - Validates email format
#   number   - Validates numeric input
# BEHAVIOR:
#   - Auto-detects password fields by prompt text (password, pass, secret, token, key)
#   - Validates input based on mode
#   - Loops until valid input received (for email/number modes)
#   - Sanitizes all input for security
# EXAMPLE:
#   name=$(ask_input "Your name")
#   pass=$(ask_input "Password" "" "password")
#   email=$(ask_input "Email" "" "email")
#   age=$(ask_input "Age" "" "number")
#===============================================================================
ask_input() {
    local prompt="$1"
    local default="${2:-}"
    local mode="${3:-text}"

    # Auto-detect password mode from prompt text (whole word matching)
    if [ "$mode" = "text" ]; then
        local prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')
        if [[ "$prompt_lower" =~ (^|[^a-z])(password|passwd|pass|secret|token|key|api)([^a-z]|$) ]]; then
            mode="password"
        fi
    fi

    # Sanitize prompt
    local safe_prompt="$(_escape_input "$prompt")"

    local response=""
    local valid=0

    while [ $valid -eq 0 ]; do
        # Display prompt (to stderr so it doesn't interfere with return value)
        if [ -n "$default" ] && [ "$mode" != "password" ]; then
            local safe_default="$(_escape_input "$default")"
            echo -ne "${COLOR_INFO}${ICON_INFO}${RESET}  ${safe_prompt} [${safe_default}]: " >&2
        else
            echo -ne "${COLOR_INFO}${ICON_INFO}${RESET}  ${safe_prompt}: " >&2
        fi

        # Read input based on mode
        if [ "$mode" = "password" ]; then
            # Password mode: hide input, show mask character
            # Respect terminal mode for visual consistency
            local mask_char="*"
            if [ "$OISEAU_MODE" = "rich" ]; then
                mask_char="•"  # UTF-8 bullet
            elif [ "$OISEAU_MODE" = "color" ]; then
                mask_char="*"  # ASCII asterisk
            else
                mask_char="*"  # Plain mode asterisk
            fi

            response=""
            while IFS= read -r -s -n1 char; do
                # Handle Enter key
                if [ -z "$char" ]; then
                    break
                fi

                # Handle backspace
                if [ "$char" = $'\177' ] || [ "$char" = $'\b' ]; then
                    if [ -n "$response" ]; then
                        response="${response%?}"
                        echo -ne "\b \b" >&2
                    fi
                else
                    response+="$char"
                    echo -n "$mask_char" >&2
                fi
            done
            echo "" >&2  # Newline after password input
        else
            # Normal text input
            if ! read -r response; then
                # EOF encountered, break out of loop
                if [ -n "$default" ]; then
                    response="$default"
                    valid=1
                else
                    echo "" >&2
                    echo "ERROR: EOF encountered, no valid input" >&2
                    return 1
                fi
            fi
        fi

        # Use default if empty (only if read succeeded)
        if [ -z "$response" ] && [ -n "$default" ]; then
            response="$default"
        fi

        # Validate based on mode
        case "$mode" in
            email)
                if [[ "$response" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    valid=1
                else
                    show_error "Invalid email format. Please try again." >&2
                fi
                ;;
            number)
                if [[ "$response" =~ ^[0-9]+$ ]]; then
                    valid=1
                else
                    show_error "Please enter a valid number." >&2
                fi
                ;;
            *)
                # text or password - always valid
                valid=1
                ;;
        esac
    done

    # Sanitize and return
    local safe_response="$(_escape_input "$response")"
    echo "$safe_response"
}

#===============================================================================
# FUNCTION: ask_list
# DESCRIPTION: Interactive list selection with arrow key navigation
# PARAMETERS:
#   $1 - prompt (string, required): Prompt message
#   $2 - array_name (string, required): Name of array variable containing options
#   $3 - mode (string, optional): Selection mode (single|multi, default: single)
# RETURNS: Selected item(s), newline-separated for multi-select
# MODES:
#   single - Select one item with Enter (default)
#   multi  - Toggle items with Space, confirm with Enter
# BEHAVIOR:
#   - Auto-detects TTY: interactive in TTY, falls back to numbered list in non-TTY
#   - Arrow keys (↑↓) or j/k to navigate
#   - Enter to select (single mode) or confirm (multi mode)
#   - Space to toggle (multi mode only)
#   - q or Esc to cancel
#   - Respects UTF-8/ASCII/Plain modes for visual indicators
# EXAMPLE:
#   options=("Option 1" "Option 2" "Option 3")
#   selected=$(ask_list "Choose:" options)
#   files=("file1.txt" "file2.txt" "file3.txt")
#   selected=$(ask_list "Select files:" files "multi")
#===============================================================================
ask_list() {
    local prompt="$1"
    local array_name="$2"
    local mode="${3:-single}"

    # Validate inputs first (before eval)
    if [ -z "$prompt" ] || [ -z "$array_name" ]; then
        echo "ERROR: ask_list requires prompt and array_name arguments" >&2
        return 1
    fi

    # Sanitize prompt
    local safe_prompt="$(_escape_input "$prompt")"

    # Load array items using eval for bash 3.x compatibility
    eval "local items=(\"\${${array_name}[@]}\")"

    if [ ${#items[@]} -eq 0 ]; then
        echo "ERROR: ask_list requires non-empty array" >&2
        return 1
    fi

    # Non-TTY fallback: simple numbered list
    if [ "$OISEAU_IS_TTY" != "1" ]; then
        echo "$safe_prompt" >&2
        local i=1
        for item in "${items[@]}"; do
            echo "  $i) $item" >&2
            i=$((i + 1))
        done
        echo -n "Enter number: " >&2
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#items[@]} ]; then
            echo "${items[$((choice - 1))]}"
            return 0
        else
            echo "ERROR: Invalid selection" >&2
            return 1
        fi
    fi

    # Interactive mode (TTY)
    local selected_index=0
    local -a selected_items=()  # For multi-select

    # Initialize selected_items array (all false for multi-select)
    if [ "$mode" = "multi" ]; then
        for ((i=0; i<${#items[@]}; i++)); do
            selected_items[$i]=0
        done
    fi

    # Mode-aware visual indicators
    local cursor_char=">"
    local checked_char="✓"
    local unchecked_char=" "
    local checkbox_left="["
    local checkbox_right="]"

    if [ "$OISEAU_MODE" = "rich" ]; then
        cursor_char="›"
        checked_char="✓"
        unchecked_char=" "
    elif [ "$OISEAU_MODE" = "color" ] || [ "$OISEAU_MODE" = "plain" ]; then
        cursor_char=">"
        checked_char="X"
        unchecked_char=" "
    fi

    # Helper function to render the list
    render_list() {
        # Clear screen area (move cursor up and clear lines)
        if [ "$1" != "first" ]; then
            # Move cursor up by number of items + header + footer
            local lines_to_clear=$((${#items[@]} + 3))
            for ((i=0; i<lines_to_clear; i++)); do
                echo -ne "\033[1A\033[2K" >&2  # Move up and clear line
            done
        fi

        # Print prompt
        echo -e "${COLOR_INFO}${safe_prompt}${RESET}" >&2

        # Print items
        for ((i=0; i<${#items[@]}; i++)); do
            local item="${items[$i]}"
            local prefix="  "

            if [ "$i" -eq "$selected_index" ]; then
                prefix="${COLOR_INFO}${cursor_char}${RESET} "
            fi

            if [ "$mode" = "multi" ]; then
                local checkbox
                if [ "${selected_items[$i]}" -eq 1 ]; then
                    checkbox="${COLOR_SUCCESS}${checkbox_left}${checked_char}${checkbox_right}${RESET}"
                else
                    checkbox="${COLOR_MUTED}${checkbox_left}${unchecked_char}${checkbox_right}${RESET}"
                fi
                echo -e "${prefix}${checkbox} ${item}" >&2
            else
                echo -e "${prefix}${item}" >&2
            fi
        done

        # Print help text
        if [ "$mode" = "multi" ]; then
            echo -e "${COLOR_DIM}[↑↓:Navigate | Space:Toggle | Enter:Confirm | q:Cancel]${RESET}" >&2
        else
            echo -e "${COLOR_DIM}[↑↓:Navigate | Enter:Select | q:Cancel]${RESET}" >&2
        fi
    }

    # Initial render
    render_list "first"

    # Read arrow keys and handle selection
    while true; do
        # Read single character
        IFS= read -r -s -n1 key

        # Handle escape sequences (arrow keys)
        if [ "$key" = $'\x1b' ]; then
            read -r -s -n2 -t 0.1 key  # Read the rest of the escape sequence (100ms timeout)
        fi

        case "$key" in
            '[A'|'k')  # Up arrow or k
                selected_index=$(( (selected_index - 1 + ${#items[@]}) % ${#items[@]} ))
                render_list
                ;;
            '[B'|'j')  # Down arrow or j
                selected_index=$(( (selected_index + 1) % ${#items[@]} ))
                render_list
                ;;
            ' ')  # Space (toggle in multi mode)
                if [ "$mode" = "multi" ]; then
                    if [ "${selected_items[$selected_index]}" -eq 1 ]; then
                        selected_items[$selected_index]=0
                    else
                        selected_items[$selected_index]=1
                    fi
                    render_list
                fi
                ;;
            '')  # Enter
                if [ "$mode" = "multi" ]; then
                    # Return all selected items
                    local results=()
                    for ((i=0; i<${#items[@]}; i++)); do
                        if [ "${selected_items[$i]}" -eq 1 ]; then
                            results+=("${items[$i]}")
                        fi
                    done

                    if [ ${#results[@]} -eq 0 ]; then
                        echo "" >&2
                        echo "ERROR: No items selected" >&2
                        return 1
                    fi

                    # Clear the list display
                    echo "" >&2

                    # Return selected items (one per line)
                    printf '%s\n' "${results[@]}"
                    return 0
                else
                    # Return single selected item
                    echo "" >&2
                    echo "${items[$selected_index]}"
                    return 0
                fi
                ;;
            'q'|'Q'|$'\x1b')  # q or Esc to cancel
                echo "" >&2
                echo "ERROR: Selection cancelled" >&2
                return 1
                ;;
        esac
    done
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
# SPINNER WIDGET
# ==============================================================================

#===============================================================================
# FUNCTION: show_spinner
# DESCRIPTION: Display an animated loading spinner
# PARAMETERS:
#   $1 - message (string, required): Message to display next to spinner
# ENVIRONMENT VARIABLES:
#   OISEAU_SPINNER_STYLE - Spinner animation style (dots|line|circle|pulse|arc)
#   OISEAU_SPINNER_FPS   - Animation frame rate (default: 10)
# RETURNS: Runs until killed (Ctrl+C or kill PID)
# MODES:
#   Rich:  Animated UTF-8 spinner (⠋⠙⠹⠸...)
#   Color: Animated ASCII spinner (|/-\)
#   Plain: Static message only
# EXAMPLE:
#   show_spinner "Loading data..." &
#   SPINNER_PID=$!
#   # ... do work ...
#   kill $SPINNER_PID
#   wait $SPINNER_PID 2>/dev/null
#===============================================================================
show_spinner() {
    local message="${1:-Loading...}"

    # Sanitize input
    local safe_message
    safe_message="$(_escape_input "$message")"

    # Non-TTY: just print message once and return
    if [ "$OISEAU_IS_TTY" != "1" ]; then
        echo "$safe_message"
        return 0
    fi

    # Plain mode: static message
    if [ "$OISEAU_MODE" = "plain" ]; then
        echo "$safe_message"
        return 0
    fi

    # Validate and get spinner style
    local style="${OISEAU_SPINNER_STYLE:-dots}"
    case "$style" in
        dots|line|circle|pulse|arc) ;;
        *)
            style="dots"
            ;;
    esac

    # Get frames based on mode and style
    local frames
    if [ "$OISEAU_MODE" = "rich" ]; then
        case "$style" in
            dots)   frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏") ;;
            line)   frames=("⎯" "⎼" "⎽" "⎼") ;;
            circle) frames=("◐" "◓" "◑" "◒") ;;
            pulse)  frames=("●" "○" "●" "○") ;;
            arc)    frames=("◜" "◝" "◞" "◟") ;;
        esac
    else
        # Color mode (ASCII)
        case "$style" in
            dots)   frames=("|" "/" "-" "\\") ;;
            line)   frames=("-" "=" "≡" "=") ;;
            circle) frames=("|" "/" "-" "\\") ;;
            pulse)  frames=("*" "o" "*" "o") ;;
            arc)    frames=("." "o" "O" "o") ;;
        esac
    fi

    # Animation settings with validation
    local fps="${OISEAU_SPINNER_FPS:-10}"

    # Validate FPS is a positive number
    if ! [[ "$fps" =~ ^[0-9]+$ ]] || [ "$fps" -le 0 ]; then
        fps=10  # Fallback to default
    fi

    local delay
    delay=$(awk "BEGIN {print 1/$fps}")
    local frame_idx=0
    local num_frames=${#frames[@]}

    # Hide cursor
    echo -en "\033[?25l"

    # Cleanup on exit - clear line and show cursor, then exit
    # shellcheck disable=SC2329  # Function is invoked via trap
    cleanup_spinner() {
        echo -en "\r\033[K\033[?25h"
        trap - EXIT INT TERM  # Remove trap to prevent recursion
        exit 0
    }
    trap cleanup_spinner EXIT INT TERM

    # Animation loop
    while true; do
        local frame="${frames[$frame_idx]}"
        echo -en "\r${COLOR_INFO}${frame}${RESET}  ${safe_message}\033[K"

        frame_idx=$(( (frame_idx + 1) % num_frames ))
        sleep "$delay" || exit 0  # Exit if sleep is interrupted
    done
}

#===============================================================================
# FUNCTION: start_spinner
# DESCRIPTION: Start spinner in background and track PID
# PARAMETERS:
#   $1 - message (string, optional): Message to display (default: "Loading...")
# ENVIRONMENT VARIABLES:
#   Sets OISEAU_SPINNER_PID - PID of background spinner process
# RETURNS: 0 on success
# EXAMPLE:
#   start_spinner "Processing files..."
#   # ... do work ...
#   stop_spinner
#===============================================================================
start_spinner() {
    local message="${1:-Loading...}"

    # Start spinner in background
    show_spinner "$message" &
    export OISEAU_SPINNER_PID=$!

    # Give it a moment to start
    sleep 0.1
}

#===============================================================================
# FUNCTION: stop_spinner
# DESCRIPTION: Stop background spinner started with start_spinner
# PARAMETERS: None
# ENVIRONMENT VARIABLES:
#   Reads OISEAU_SPINNER_PID - PID of spinner to stop
#   Unsets OISEAU_SPINNER_PID after stopping
# RETURNS: 0 on success
# EXAMPLE:
#   start_spinner "Loading..."
#   sleep 2
#   stop_spinner
#   show_success "Done!"
#===============================================================================
stop_spinner() {
    if [ -n "$OISEAU_SPINNER_PID" ]; then
        # Kill spinner process
        kill "$OISEAU_SPINNER_PID" 2>/dev/null

        # Wait for it to finish
        wait "$OISEAU_SPINNER_PID" 2>/dev/null

        # Clear line and show cursor
        echo -en "\r\033[K\033[?25h"

        # Unset PID
        unset OISEAU_SPINNER_PID
    fi
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
