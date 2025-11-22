# Key simulation helpers for BATS tests
# Provides utilities to simulate terminal input for interactive testing

# Simulate key presses by piping input to a command
# Usage: simulate_keys "down" "down" "enter" | ask_list "Prompt" items single
simulate_keys() {
    local keys=("$@")
    local output=""

    for key in "${keys[@]}"; do
        case "$key" in
            "up")
                output+=$'\e[A'
                ;;
            "down")
                output+=$'\e[B'
                ;;
            "left")
                output+=$'\e[D'
                ;;
            "right")
                output+=$'\e[C'
                ;;
            "enter")
                output+=$'\n'
                ;;
            "space")
                output+=" "
                ;;
            "esc")
                output+=$'\e'
                ;;
            "q")
                output+="q"
                ;;
            "j")
                output+="j"
                ;;
            "k")
                output+="k"
                ;;
            *)
                # For any other character, use it as-is
                output+="$key"
                ;;
        esac
    done

    echo -n "$output"
}

# Create a pseudo-TTY for testing interactive components
# Usage: with_tty command args...
with_tty() {
    # Use script command to create a pseudo-TTY
    # -q: quiet mode (no start/done messages)
    # /dev/null: discard script output
    # -c: command to run
    script -q /dev/null "$@"
}

# Simulate interactive session with input
# Usage: interactive_test input_string command args...
interactive_test() {
    local input="$1"
    shift

    # Create named pipe for input
    local tmpdir=$(mktemp -d)
    local input_pipe="$tmpdir/input"
    mkfifo "$input_pipe"

    # Write input to pipe in background
    (echo -n "$input" > "$input_pipe") &
    local writer_pid=$!

    # Run command with input from pipe
    local result
    result=$("$@" < "$input_pipe" 2>&1)
    local exit_code=$?

    # Cleanup
    wait "$writer_pid" 2>/dev/null || true
    rm -rf "$tmpdir"

    echo "$result"
    return $exit_code
}

# Check if running in TTY mode
is_tty() {
    [ -t 0 ] && return 0 || return 1
}

# Force TTY mode for testing
# Usage: force_tty_mode
force_tty_mode() {
    export OISEAU_IS_TTY=1
}

# Force non-TTY mode for testing
# Usage: force_non_tty_mode
force_non_tty_mode() {
    export OISEAU_IS_TTY=0
}
