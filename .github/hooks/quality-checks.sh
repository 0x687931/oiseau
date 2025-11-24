#!/bin/bash
# Git pre-push hook to catch code quality issues before pushing
# Prevents common problems from reaching the remote repository
#
# This hook can be bypassed with: git push --no-verify
#
# Checks performed:
# 1. ShellCheck on modified .sh files
# 2. IFS corruption detection (IFS='...' read without local IFS)
# 3. Multibyte truncation patterns (byte-position substring operations)
# 4. Unsafe parameter expansions in shell scripts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1" >&2; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

# Track if we found any issues
FOUND_CRITICAL=0
FOUND_WARNINGS=0

# Get list of files being pushed (compare against remote)
# $1 = local ref, $2 = local sha, $3 = remote ref, $4 = remote sha
# shellcheck disable=SC2034  # local_ref and remote_ref used by git pre-push protocol
while read -r local_ref local_sha remote_ref remote_sha; do
    # Skip if deleting branch
    if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
        continue
    fi

    # If remote_sha is all zeros, we're pushing a new branch - compare against merge base
    if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
        # New branch - check against main/master
        if git rev-parse --verify main >/dev/null 2>&1; then
            range="main..$local_sha"
        elif git rev-parse --verify master >/dev/null 2>&1; then
            range="master..$local_sha"
        else
            # No main/master branch - check ALL commits in the push (not just tip)
            # Find the root of the branch or use first commit if needed
            # This ensures we don't bypass checks for earlier commits in feature branches
            # shellcheck disable=SC2046  # Word splitting intentional for multiple remote refs
            MERGE_BASE=$(git merge-base --all "$local_sha" $(git for-each-ref --format='%(objectname)' refs/remotes/) 2>/dev/null | head -1)
            if [ -n "$MERGE_BASE" ]; then
                range="$MERGE_BASE..$local_sha"
            else
                # Last resort: check from root of repository
                FIRST_COMMIT=$(git rev-list --max-parents=0 "$local_sha" 2>/dev/null || echo "")
                if [ -n "$FIRST_COMMIT" ]; then
                    range="$FIRST_COMMIT..$local_sha"
                else
                    # Absolute fallback: just this commit
                    range="$local_sha^..$local_sha"
                fi
            fi
        fi
    else
        range="$remote_sha..$local_sha"
    fi

    # Get changed files in this range
    CHANGED_FILES=$(git diff --name-only --diff-filter=ACMR "$range" || true)

    if [ -z "$CHANGED_FILES" ]; then
        print_info "No files changed in this ref"
        continue
    fi

    print_info "Pre-push quality checks running..."
    echo ""

    # Filter for shell scripts (both .sh files and extensionless scripts with #!/bin/bash or #!/bin/sh shebang)
    SHELL_SCRIPTS=""
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Check if file has .sh extension OR starts with shell shebang
            if [[ "$file" =~ \.sh$ ]] || head -n 1 "$file" 2>/dev/null | grep -q '^#!/bin/\(bash\|sh\)'; then
                SHELL_SCRIPTS="${SHELL_SCRIPTS}${file}"$'\n'
            fi
        fi
    done <<< "$CHANGED_FILES"
    # Remove trailing newline
    SHELL_SCRIPTS="${SHELL_SCRIPTS%$'\n'}"

    if [ -n "$SHELL_SCRIPTS" ]; then
        print_info "Checking shell scripts with ShellCheck..."

        # Check if shellcheck is available
        if ! command -v shellcheck >/dev/null 2>&1; then
            print_warning "ShellCheck not installed - skipping shellcheck validation"
            print_warning "Install with: brew install shellcheck (macOS) or apt-get install shellcheck (Linux)"
            echo ""
        else
            # Run shellcheck on each file
            while IFS= read -r file; do  # safe-truncate: IFS scoped to read only, no leakage
                if [ -f "$file" ]; then
                    echo "  Checking: $file"
                    if ! shellcheck -x -e SC1090,SC1091 "$file" 2>&1; then
                        print_error "ShellCheck found issues in: $file"
                        FOUND_CRITICAL=1
                    fi
                fi
            done <<< "$SHELL_SCRIPTS"

            if [ $FOUND_CRITICAL -eq 0 ]; then
                print_success "All shell scripts passed ShellCheck"
            fi
            echo ""
        fi

        # Check for IFS corruption patterns
        print_info "Checking for IFS corruption patterns..."
        IFS_ISSUES=$(echo "$SHELL_SCRIPTS" | while IFS= read -r file; do
            if [ -f "$file" ]; then
                # Look for IFS='...' read without 'local IFS' in the same function
                # This is a simplified check - catches most common cases
                if grep -n "IFS=" "$file" | grep -v "local IFS" | grep "read" >/dev/null 2>&1; then
                    echo "$file:$(grep -n "IFS=" "$file" | grep -v "local IFS" | grep "read" | cut -d: -f1 | head -1):Potential IFS corruption - use 'local IFS' before 'IFS='"
                fi
            fi
        done)

        if [ -n "$IFS_ISSUES" ]; then
            print_warning "Potential IFS corruption detected:"
            echo "$IFS_ISSUES" | while IFS= read -r issue; do
                echo "  $issue"
            done
            echo ""
            print_warning "These may cause issues. Consider using 'local IFS' to scope changes."
            FOUND_WARNINGS=1
            echo ""
        else
            print_success "No IFS corruption patterns detected"
            echo ""
        fi

        # Check for multibyte truncation issues
        print_info "Checking for multibyte truncation patterns..."
        TRUNCATION_ISSUES=$(echo "$SHELL_SCRIPTS" | while IFS= read -r file; do
            if [ -f "$file" ]; then
                # Look for parameter expansion with fixed byte positions on potentially multibyte strings
                # Pattern: ${var:position:length} in contexts that might process user input or file content
                # shellcheck disable=SC2016  # Single quotes intentional - matching literal \${ pattern
                if grep -n '\${[^}]*:[0-9]' "$file" | grep -v "# safe-truncate" >/dev/null 2>&1; then
                    echo "$file:$(grep -n '\${[^}]*:[0-9]' "$file" | grep -v "# safe-truncate" | cut -d: -f1 | head -1):Potential multibyte truncation - byte-position operations on potentially multibyte strings"
                fi
            fi
        done)

        if [ -n "$TRUNCATION_ISSUES" ]; then
            print_warning "Potential multibyte truncation detected:"
            echo "$TRUNCATION_ISSUES" | while IFS= read -r issue; do
                echo "  $issue"
            done
            echo ""
            print_warning "Add '# safe-truncate' comment if you've verified this is safe for multibyte input."
            FOUND_WARNINGS=1
            echo ""
        else
            print_success "No multibyte truncation patterns detected"
            echo ""
        fi

        # Check for unquoted variable expansions in dangerous contexts
        print_info "Checking for unsafe parameter expansions..."
        UNSAFE_EXPANSIONS=$(echo "$SHELL_SCRIPTS" | while IFS= read -r file; do
            if [ -f "$file" ]; then
                # Look for common unsafe patterns (this is a basic check)
                # Pattern: rm/mv/cp followed by unquoted variable
                if grep -nE '(rm|mv|cp)[[:space:]]+[^"'\'']*\$[A-Za-z_]' "$file" | grep -v "# safe-expansion" >/dev/null 2>&1; then
                    echo "$file:$(grep -nE '(rm|mv|cp)[[:space:]]+[^"'\'']*\$[A-Za-z_]' "$file" | grep -v "# safe-expansion" | cut -d: -f1 | head -1):Unquoted variable in file operation - may cause issues with spaces/special chars"
                fi
            fi
        done)

        if [ -n "$UNSAFE_EXPANSIONS" ]; then
            print_warning "Unsafe parameter expansions detected:"
            echo "$UNSAFE_EXPANSIONS" | while IFS= read -r issue; do
                echo "  $issue"
            done
            echo ""
            print_warning "Add '# safe-expansion' comment if you've verified this is safe."
            FOUND_WARNINGS=1
            echo ""
        else
            print_success "No unsafe parameter expansions detected"
            echo ""
        fi
    fi

    # Note: Don't exit here - we need to process all refs from stdin
    # Continue to next ref in the loop
done

# Summary after processing ALL refs
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FOUND_CRITICAL -eq 1 ]; then
    echo ""
    print_error "Pre-push checks FAILED - critical issues found"
    echo ""
    echo "Fix the issues above or bypass with: git push --no-verify"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
elif [ $FOUND_WARNINGS -eq 1 ]; then
    echo ""
    print_warning "Pre-push checks completed with warnings"
    echo ""
    echo "Review warnings above. Push will continue in 3 seconds..."
    echo "Press Ctrl+C to cancel and fix warnings."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    sleep 3
    exit 0
else
    echo ""
    print_success "All pre-push checks passed!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi
