#!/bin/bash
# UI Theme - Color definitions for consistent terminal output
# Source this file to access theme colors and reset functionality

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================

# Standard colors
export UI_RED='\033[0;31m'
export UI_GREEN='\033[0;32m'
export UI_YELLOW='\033[1;33m'
export UI_BLUE='\033[0;34m'
export UI_MAGENTA='\033[0;35m'
export UI_CYAN='\033[0;36m'
export UI_WHITE='\033[1;37m'

# Text formatting
export UI_BOLD='\033[1m'
export UI_DIM='\033[2m'
export UI_UNDERLINE='\033[4m'

# Reset
export UI_RESET='\033[0m'
export NC='\033[0m'  # Backward compatibility

# ============================================================================
# SEMANTIC COLORS (Use these for consistency)
# ============================================================================

export UI_COLOR_ERROR="$UI_RED"
export UI_COLOR_SUCCESS="$UI_GREEN"
export UI_COLOR_WARNING="$UI_YELLOW"
export UI_COLOR_INFO="$UI_BLUE"
export UI_COLOR_HEADER="$UI_CYAN"
export UI_COLOR_SECTION="$UI_MAGENTA"

# ============================================================================
# ICON DEFINITIONS
# ============================================================================

export UI_ICON_ERROR='✗'
export UI_ICON_SUCCESS='✓'
export UI_ICON_WARNING='⚠'
export UI_ICON_INFO='ℹ'
export UI_ICON_SECTION='▸'

# Branch type icons
export UI_ICON_MAIN='●'
export UI_ICON_FEATURE='◆'
export UI_ICON_FIX='▲'
export UI_ICON_REFACTOR='○'

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Reset all formatting
ui_reset() {
    echo -e "${UI_RESET}"
}

# Get color by semantic name
ui_color() {
    local name="$1"
    case "$name" in
        error) echo "$UI_COLOR_ERROR" ;;
        success) echo "$UI_COLOR_SUCCESS" ;;
        warning) echo "$UI_COLOR_WARNING" ;;
        info) echo "$UI_COLOR_INFO" ;;
        header) echo "$UI_COLOR_HEADER" ;;
        section) echo "$UI_COLOR_SECTION" ;;
        *) echo "$UI_RESET" ;;
    esac
}

# Get icon by name
ui_icon() {
    local name="$1"
    case "$name" in
        error) echo "$UI_ICON_ERROR" ;;
        success) echo "$UI_ICON_SUCCESS" ;;
        warning) echo "$UI_ICON_WARNING" ;;
        info) echo "$UI_ICON_INFO" ;;
        section) echo "$UI_ICON_SECTION" ;;
        main) echo "$UI_ICON_MAIN" ;;
        feature) echo "$UI_ICON_FEATURE" ;;
        fix) echo "$UI_ICON_FIX" ;;
        refactor) echo "$UI_ICON_REFACTOR" ;;
        *) echo "" ;;
    esac
}
