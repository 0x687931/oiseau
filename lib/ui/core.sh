#!/bin/bash
# lib/ui/core.sh - Terminal UI Core Module
#
# Provides terminal capability detection and state management for the Tild UI system.
# This module detects terminal features once and provides flags for feature gating.
#
# Usage:
#   source lib/ui/core.sh
#   ui_init
#   if [ "$UI_HAS_COLOR" = "true" ]; then
#     # Use colors
#   fi

# ============================================================================
# SAFETY TOGGLE
# ============================================================================

# Allow disabling UI enhancements entirely via environment variable
if [ "${UI_DISABLE:-0}" = "1" ]; then
    # Set all capabilities to false/plain mode
    UI_HAS_COLOR="false"
    UI_HAS_UTF8="false"
    UI_MODE="plain"
    UI_INITIALIZED="true"
    # Set dimension defaults
    UI_TERM_COLS=80
    UI_TERM_ROWS=24

    # Define no-op versions of all public API functions to prevent "command not found" errors
    # These maintain the API contract but disable all UI features
    ui_init() { return 0; }
    ui_is_tty() { return 1; }
    ui_get_mode() { echo "plain"; }
    ui_has_color() { return 1; }
    ui_has_utf8() { return 1; }
    ui_has_rich() { return 1; }
    ui_get_cols() { echo "80"; }
    ui_get_rows() { echo "24"; }
    ui_update_dimensions() { return 0; }
    ui_diagnostic() {
        echo "=== Tild UI System Diagnostics ==="
        echo ""
        echo "UI System Status: DISABLED (UI_DISABLE=1)"
        echo ""
        echo "All UI functions are no-ops in this mode."
    }

    # Export the no-op functions
    export -f ui_init
    export -f ui_is_tty
    export -f ui_get_mode
    export -f ui_has_color
    export -f ui_has_utf8
    export -f ui_has_rich
    export -f ui_get_cols
    export -f ui_get_rows
    export -f ui_update_dimensions
    export -f ui_diagnostic

    return 0
fi

# ============================================================================
# STATE FLAGS (Set during initialization, should not be modified after)
# ============================================================================

# Terminal capability flags (set by ui_init)
UI_HAS_COLOR=""
UI_HAS_UTF8=""
UI_MODE=""

# Cached terminal dimensions
UI_TERM_COLS=""
UI_TERM_ROWS=""

# Initialization flag
UI_INITIALIZED="false"

# ============================================================================
# TERMINAL CAPABILITY DETECTION
# ============================================================================

# Detect if stdout is connected to a TTY
# Returns: 0 if TTY, 1 if not (pipe/redirect)
_ui_is_tty() {
    [[ -t 1 ]]
}

# Detect color support using TERM environment variable and tput
# Returns: 0 if color supported, 1 if not
_ui_detect_color() {
    # No TTY = no color
    if ! _ui_is_tty; then
        return 1
    fi

    # Check for dumb terminal
    if [ "$TERM" = "dumb" ] || [ -z "$TERM" ]; then
        return 1
    fi

    # Check for explicit no-color environment variables
    # NO_COLOR spec: presence of the variable (even if empty) means no color
    if [[ -n "${NO_COLOR+x}" ]] || [[ -n "${NOCOLOR+x}" ]]; then
        return 1
    fi

    # Try to use tput to check color support
    if command -v tput >/dev/null 2>&1; then
        local colors
        colors=$(tput colors 2>/dev/null)
        if [ -n "$colors" ] && [ "$colors" -ge 8 ]; then
            return 0
        fi
    fi

    # Fallback: Check TERM for common color-supporting terminals
    case "$TERM" in
        *color*|xterm*|screen*|tmux*|rxvt*|linux|vt100|vt220)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Detect UTF-8 support using locale
# Returns: 0 if UTF-8 supported, 1 if not
_ui_detect_utf8() {
    # No TTY = ASCII only
    if ! _ui_is_tty; then
        return 1
    fi

    # Check locale variables in precedence order: LC_ALL > LC_CTYPE > LANG
    local effective_locale="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"

    [[ "$effective_locale" == *.[Uu][Tt][Ff]-8 ]] || [[ "$effective_locale" == *.[Uu][Tt][Ff]8 ]]
}

# Determine overall UI mode based on capabilities
# Returns: "rich" (color + UTF-8), "color" (color only), or "plain" (ASCII only)
_ui_determine_mode() {
    local has_color="$1"
    local has_utf8="$2"

    if [ "$has_color" = "true" ] && [ "$has_utf8" = "true" ]; then
        echo "rich"
    elif [ "$has_color" = "true" ]; then
        echo "color"
    else
        echo "plain"
    fi
}

# ============================================================================
# TERMINAL DIMENSIONS CACHING
# ============================================================================

# Get terminal width (cached for performance)
# Returns: Terminal width in columns, or 80 if detection fails
ui_get_cols() {
    # Return cached value if available
    if [ -n "$UI_TERM_COLS" ]; then
        echo "$UI_TERM_COLS"
        return 0
    fi

    # Try tput first
    if command -v tput >/dev/null 2>&1; then
        local cols
        cols=$(tput cols 2>/dev/null)
        if [ -n "$cols" ] && [ "$cols" -gt 0 ]; then
            echo "$cols"
            return 0
        fi
    fi

    # Try stty as fallback
    if command -v stty >/dev/null 2>&1 && _ui_is_tty; then
        local size
        size=$(stty size 2>/dev/null | cut -d' ' -f2)
        if [ -n "$size" ] && [ "$size" -gt 0 ]; then
            echo "$size"
            return 0
        fi
    fi

    # Default to 80 columns
    echo "80"
}

# Get terminal height (cached for performance)
# Returns: Terminal height in rows, or 24 if detection fails
ui_get_rows() {
    # Return cached value if available
    if [ -n "$UI_TERM_ROWS" ]; then
        echo "$UI_TERM_ROWS"
        return 0
    fi

    # Try tput first
    if command -v tput >/dev/null 2>&1; then
        local rows
        rows=$(tput lines 2>/dev/null)
        if [ -n "$rows" ] && [ "$rows" -gt 0 ]; then
            echo "$rows"
            return 0
        fi
    fi

    # Try stty as fallback
    if command -v stty >/dev/null 2>&1 && _ui_is_tty; then
        local size
        size=$(stty size 2>/dev/null | cut -d' ' -f1)
        if [ -n "$size" ] && [ "$size" -gt 0 ]; then
            echo "$size"
            return 0
        fi
    fi

    # Default to 24 rows
    echo "24"
}

# Update cached terminal dimensions
# Call this if terminal size may have changed (e.g., after SIGWINCH)
ui_update_dimensions() {
    # Clear cache to force re-fetching dimensions
    UI_TERM_COLS=""
    UI_TERM_ROWS=""
    # Re-fetch dimensions
    UI_TERM_COLS=$(ui_get_cols)
    UI_TERM_ROWS=$(ui_get_rows)
}

# ============================================================================
# INITIALIZATION
# ============================================================================

# Initialize UI system - detect all capabilities once
# This should be called once at the start of any script using the UI system
#
# Sets global flags:
#   UI_HAS_COLOR  - "true" if terminal supports colors
#   UI_HAS_UTF8   - "true" if terminal supports UTF-8
#   UI_MODE       - "rich", "color", or "plain"
#   UI_TERM_COLS  - Terminal width in columns
#   UI_TERM_ROWS  - Terminal height in rows
#
# Usage:
#   ui_init
ui_init() {
    # Only initialize once
    if [ "$UI_INITIALIZED" = "true" ]; then
        return 0
    fi

    # Detect capabilities
    if _ui_detect_color; then
        UI_HAS_COLOR="true"
    else
        UI_HAS_COLOR="false"
    fi

    if _ui_detect_utf8; then
        UI_HAS_UTF8="true"
    else
        UI_HAS_UTF8="false"
    fi

    # Determine UI mode
    UI_MODE=$(_ui_determine_mode "$UI_HAS_COLOR" "$UI_HAS_UTF8")

    # Cache terminal dimensions
    ui_update_dimensions

    # Mark as initialized
    UI_INITIALIZED="true"

    # Export flags as read-only (defensive coding)
    # Note: These can't be truly read-only because they need to be set first
    # but we document them as read-only to indicate they shouldn't be modified
    export UI_HAS_COLOR
    export UI_HAS_UTF8
    export UI_MODE
    export UI_TERM_COLS
    export UI_TERM_ROWS
    export UI_INITIALIZED
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if current output context is a TTY
# Returns: 0 if TTY, 1 if not
ui_is_tty() {
    _ui_is_tty
}

# Get current UI mode
# Returns: "rich", "color", or "plain"
ui_get_mode() {
    if [ "$UI_INITIALIZED" != "true" ]; then
        echo "plain"
        return 1
    fi
    echo "$UI_MODE"
}

# Check if colors are available
# Returns: 0 if colors available, 1 if not
ui_has_color() {
    [ "$UI_HAS_COLOR" = "true" ]
}

# Check if UTF-8 is available
# Returns: 0 if UTF-8 available, 1 if not
ui_has_utf8() {
    [ "$UI_HAS_UTF8" = "true" ]
}

# Check if rich mode is available (color + UTF-8)
# Returns: 0 if rich mode available, 1 if not
ui_has_rich() {
    [ "$UI_MODE" = "rich" ]
}

# ============================================================================
# DIAGNOSTIC FUNCTIONS (for debugging)
# ============================================================================

# Print UI system diagnostic information
# Useful for debugging terminal capability issues
ui_diagnostic() {
    echo "=== Tild UI System Diagnostics ==="
    echo ""
    echo "Initialization Status: $UI_INITIALIZED"
    echo ""
    echo "Terminal Detection:"
    local is_tty="no"
    _ui_is_tty && is_tty="yes"
    echo "  TTY:        $is_tty"
    echo "  TERM:       ${TERM:-<not set>}"
    echo ""
    echo "Capabilities:"
    echo "  Color:      $UI_HAS_COLOR"
    echo "  UTF-8:      $UI_HAS_UTF8"
    echo "  Mode:       $UI_MODE"
    echo ""
    echo "Dimensions:"
    echo "  Columns:    $UI_TERM_COLS"
    echo "  Rows:       $UI_TERM_ROWS"
    echo ""
    echo "Environment:"
    echo "  UI_DISABLE: ${UI_DISABLE:-<not set>}"
    echo "  NO_COLOR:   ${NO_COLOR:-<not set>}"
    echo "  LANG:       ${LANG:-<not set>}"
    echo "  LC_ALL:     ${LC_ALL:-<not set>}"
    echo ""
}

# ============================================================================
# EXPORTS
# ============================================================================

# Export public functions (not the internal _ui_* functions)
export -f ui_init
export -f ui_is_tty
export -f ui_get_mode
export -f ui_has_color
export -f ui_has_utf8
export -f ui_has_rich
export -f ui_get_cols
export -f ui_get_rows
export -f ui_update_dimensions
export -f ui_diagnostic
