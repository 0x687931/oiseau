# Mock terminal helpers for BATS tests
# Provides utilities to mock terminal capabilities and environment

# Mock terminal size
# Usage: mock_terminal_size rows cols
mock_terminal_size() {
    # Use global scope so tput function can access these
    declare -g MOCK_ROWS="${1:-24}"
    declare -g MOCK_COLS="${2:-80}"

    export LINES="$MOCK_ROWS"
    export COLUMNS="$MOCK_COLS"

    # Also mock tput if needed
    tput() {
        case "$1" in
            lines)
                echo "$MOCK_ROWS"
                ;;
            cols)
                echo "$MOCK_COLS"
                ;;
            *)
                # Fallback to real tput for other commands
                command tput "$@" 2>/dev/null || true
                ;;
        esac
    }
    export -f tput
}

# Reset terminal mocks
reset_terminal_mocks() {
    unset LINES COLUMNS
    unset -f tput 2>/dev/null || true
}

# Mock read command to simulate user input
# Usage: mock_read "input_string"
# This creates a read function that returns the mocked input
mock_read() {
    local input="$1"
    local position=0

    read() {
        local char
        if [ $position -lt ${#input} ]; then
            char="${input:$position:1}"
            position=$((position + 1))
            echo "$char"
            return 0
        else
            return 1
        fi
    }
    export -f read
}

# Reset read mock
reset_read_mock() {
    unset -f read 2>/dev/null || true
}

# Capture terminal output
# Usage: output=$(capture_output command args...)
capture_output() {
    "$@" 2>&1
}

# Strip ANSI codes from output
# Usage: stripped=$(strip_ansi "$colored_output")
strip_ansi() {
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Count lines in output
# Usage: line_count=$(count_lines "$output")
count_lines() {
    echo "$1" | wc -l | tr -d ' '
}

# Extract specific line from output
# Usage: line=$(get_line 3 "$output")
get_line() {
    local line_num="$1"
    local text="$2"
    echo "$text" | sed -n "${line_num}p"
}
