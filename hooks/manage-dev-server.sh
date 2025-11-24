#!/bin/bash
# Claude Code hook to automatically manage local development server
# Auto-starts server before tests (primarily for Claude's testing)
# Allows manual stop/start via bash commands

set -euo pipefail

read_input_with_timeout() {
    local timeout_secs="${1:-2}"

    if command -v timeout >/dev/null 2>&1; then
        timeout "$timeout_secs" cat 2>/dev/null || true
        return 0
    fi

    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$timeout_secs" cat 2>/dev/null || true
        return 0
    fi

    if command -v perl >/dev/null 2>&1; then
        perl -MIO::Select -e '
            use strict;
            use warnings;
            my $timeout = shift || 2;
            my $selector = IO::Select->new(\*STDIN);
            if ($selector->can_read($timeout)) {
                local $/;
                my $data = <STDIN>;
                print $data if defined $data;
            }
        ' "$timeout_secs" 2>/dev/null || true
        return 0
    fi

    return 0
}

# Check if we're running interactively (no stdin) to prevent hanging
if [ -t 0 ]; then
    # stdin is a terminal - running outside of Claude Code hook context
    echo '{"decision": "approve", "reason": "Running outside hook context"}'
    exit 0
fi

# Read hook input from stdin with portable timeout
INPUT="$(read_input_with_timeout 2)"
if [ -z "$INPUT" ]; then
    INPUT='{}'
fi

# Handle empty or invalid input
if [ -z "$INPUT" ] || [ "$INPUT" = "{}" ]; then
    echo '{"decision": "approve", "reason": "No valid input received"}'
    exit 0
fi

# Parse JSON input
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Only process Bash commands
if [ "$TOOL_NAME" != "Bash" ]; then
    echo '{"decision": "approve"}'
    exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Change to working directory
cd "$CWD"

# Check if this repo has our dev server scripts
if [ ! -f "bin/start_dev" ] || [ ! -f "bin/stop_dev" ]; then
    # Not a repo with dev server scripts, skip
    echo '{"decision": "approve"}'
    exit 0
fi

# Server management configuration
PID_FILE="tmp/pids/dev_server.pid"

# Function to check if server is running
is_server_running() {
    if [ ! -f "$PID_FILE" ]; then
        return 1
    fi

    PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
    if [ -z "$PID" ]; then
        return 1
    fi

    # Check if process is actually running
    if ps -p "$PID" > /dev/null 2>&1; then
        return 0
    else
        # Stale PID file
        rm -f "$PID_FILE"
        return 1
    fi
}

# Detect manual stop requests
if echo "$COMMAND" | grep -qE "bin/stop_dev|stop_dev"; then
    # User explicitly stopping server, allow it
    echo '{"decision": "approve", "systemMessage": "🛑 Stopping development server..."}'
    exit 0
fi

# Detect manual start requests
if echo "$COMMAND" | grep -qE "bin/start_dev|start_dev"; then
    # User explicitly starting server, allow it
    echo '{"decision": "approve", "systemMessage": "🚀 Starting development server..."}'
    exit 0
fi

# Detect test commands that need the server running
if echo "$COMMAND" | grep -qE "(rspec|rails.*test|bundle.*exec.*(rspec|test))"; then
    if is_server_running; then
        # Server already running, proceed
        echo '{"decision": "approve", "systemMessage": "✅ Dev server running (PID: '"$(cat $PID_FILE)"')"}'
        exit 0
    else
        # Server not running, need to start it
        cat <<EOF
{
  "decision": "block",
  "reason": "Development server is not running. Tests require the server for system specs and integration testing.\n\nYou MUST start the server first:\n\n  bin/start_dev\n\nThis will:\n- Start Rails server on port 3001/3443 (HTTPS)\n- Start Tailwind CSS watcher\n- Start log monitor\n- Run startup diagnostics\n\nOnce started, re-run your test command.\n\nTo stop the server later: bin/stop_dev",
  "systemMessage": "⚠️  Server not running - must start before tests"
}
EOF
        exit 2
    fi
fi

# For all other commands, just approve
echo '{"decision": "approve"}'
exit 0
