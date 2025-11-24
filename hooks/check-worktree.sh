#!/bin/bash
# Claude Code hook to enforce worktree workflow and Ruby best practices
# - Blocks file edits when on main branch and provides guidance
# - Enforces rbenv usage for Ruby/Rails commands
# - Allows editing worktree automation scripts and hooks for emergency fixes
#
# FIXED: Now detects worktrees by file path, not shell CWD
# This works with Claude Code's persistent shell architecture

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

# Read hook input from stdin with a portable timeout implementation
INPUT="$(read_input_with_timeout 2)"
if [ -z "$INPUT" ]; then
    INPUT='{}'
fi

# Handle empty or invalid input
if [ -z "$INPUT" ] || [ "$INPUT" = "{}" ]; then
    echo '{"decision": "approve", "reason": "No valid input received"}'
    exit 0
fi

# Parse JSON input to get tool name and current working directory
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Determine the actual git repository directory to check
# This handles both CWD-based operations and worktree operations
determine_git_dir() {
    local target_dir="$CWD"

    case "$TOOL_NAME" in
        Write|Edit)
            # For file operations, check the file's directory, not CWD
            FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
            if [ -n "$FILE_PATH" ]; then
                target_dir=$(dirname "$FILE_PATH")
            fi
            ;;
        Bash)
            # For git commands, check for -C flag or cd command
            COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
            if [[ "$COMMAND" =~ git\ -C\ ([^\ ]+) ]]; then
                target_dir="${BASH_REMATCH[1]}"
            elif [[ "$COMMAND" =~ cd\ ([^[:space:]\&\;]+) ]]; then
                # Extract directory from cd command (handles cd /path && other-command)
                target_dir="${BASH_REMATCH[1]}"
                # Strip quotes to prevent bypass (security fix for P1 issue)
                target_dir="${target_dir%\"}"
                target_dir="${target_dir#\"}"
                target_dir="${target_dir%\'}"
                target_dir="${target_dir#\'}"
            fi
            ;;
    esac

    echo "$target_dir"
}

GIT_DIR=$(determine_git_dir)

# Check if this is a git repository
if ! git -C "$GIT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    # Not a git repo, allow all operations
    echo '{"decision": "approve"}'
    exit 0
fi

CURRENT_BRANCH=$(git -C "$GIT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# Check if we're on main branch
if [ "$CURRENT_BRANCH" = "main" ]; then
    # Block Write, Edit, and certain Bash operations on main
    case "$TOOL_NAME" in
        Write|Edit)
            # Get the file path being edited
            FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

            # Whitelist: Allow editing these files even on main branch
            # - Worktree automation scripts (for emergency fixes)
            # - Claude hooks (for hook configuration)
            # - Claude settings (for hook configuration)
            # - Documentation for worktree scripts
            if [[ "$FILE_PATH" =~ bin/worktree- ]] || \
               [[ "$FILE_PATH" =~ \.claude/hooks/ ]] || \
               [[ "$FILE_PATH" =~ \.claude/settings ]] || \
               [[ "$FILE_PATH" =~ bin/WORKTREE_SCRIPTS\.md ]]; then
                echo '{"decision": "approve", "systemMessage": "✓ Editing whitelisted file: '"$(basename "$FILE_PATH")"'"}'
                exit 0
            fi

            # Get repository name and construct dynamic paths
            REPO_NAME=$(basename "$CWD")

            # Return blocking error with feedback to Claude
            cat <<EOF
{
  "decision": "block",
  "reason": "Cannot edit files on main branch. Please use the worktree workflow:\n\n1. Create a worktree:\n   git worktree add ../${REPO_NAME}-feature-name -b feature/feature-name\n\n2. Edit files in the worktree using absolute paths:\n   /path/to/${REPO_NAME}-feature-name/file.rb\n\n3. Commit using git -C:\n   git -C ../${REPO_NAME}-feature-name add -A\n   git -C ../${REPO_NAME}-feature-name commit -m 'message'\n\n4. Push and create PR:\n   git -C ../${REPO_NAME}-feature-name push -u origin feature/feature-name\n   gh pr create --head feature/feature-name\n\n5. After PR is merged, clean up:\n   git worktree remove ../${REPO_NAME}-feature-name\n   git branch -d feature/feature-name\n\nNote: Worktree scripts (bin/worktree-*) and hooks can be edited on main for emergency fixes.",
  "systemMessage": "⚠️  WORKTREE POLICY: Direct edits to main branch are blocked"
}
EOF
            exit 2
            ;;
        Bash)
            # Check if it's a git commit or push command (without -C flag)
            COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

            # Allow git -C commands (they operate on worktrees)
            if [[ "$COMMAND" =~ git\ -C ]]; then
                echo '{"decision": "approve", "systemMessage": "✓ Using git -C to operate on worktree"}'
                exit 0
            fi

            # Block regular git commit/push on main
            if echo "$COMMAND" | grep -qE "git\s+(commit|push)"; then
                cat <<EOF
{
  "decision": "block",
  "reason": "Cannot commit or push on main branch. Use:\n\ngit -C /path/to/worktree add -A\ngit -C /path/to/worktree commit -m 'message'\ngit -C /path/to/worktree push",
  "systemMessage": "⚠️  WORKTREE POLICY: Git commits/pushes to main are blocked"
}
EOF
                exit 2
            fi
            ;;
    esac
fi

# Enforce rbenv usage for Ruby/Rails commands (applies to all branches)
# Prevents agents from wasting tokens on commands that fail due to wrong Ruby version
if [ "$TOOL_NAME" = "Bash" ]; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

    # Check for Ruby/Rails commands
    if echo "$COMMAND" | grep -qE "^\s*(bundle|ruby|gem|rake|rails|rspec)\s+"; then
        CMD_WORD=$(echo "$COMMAND" | grep -oE "^\s*(bundle|ruby|gem|rake|rails|rspec)" | xargs)

        # Quick check: already using explicit version manager?
        if echo "$COMMAND" | grep -qE "(\.rbenv/shims/|rbenv exec|asdf exec|rvm )"; then
            echo '{"decision": "approve"}'
            exit 0
        fi

        # Check if command resolves to rbenv shim (works with any rbenv setup)
        CMD_PATH=$(command -v "$CMD_WORD" 2>/dev/null || echo "")

        if [[ "$CMD_PATH" =~ /shims/ ]]; then
            # rbenv-managed via PATH, allow silently
            echo '{"decision": "approve"}'
            exit 0
        else
            # Not rbenv-managed, block with minimal message
            echo "{\"decision\": \"block\", \"reason\": \"Use ~/.rbenv/shims/$CMD_WORD (not ${CMD_PATH:-system ruby})\", \"systemMessage\": \"⚠️  Use ~/.rbenv/shims/$CMD_WORD\"}"
            exit 2
        fi
    fi
fi

# Allow the operation
echo '{"decision": "approve"}'
exit 0
