#!/usr/bin/env sh
#===============================================================================
# OISEAU TEST RUNNER (POSIX EDITION)
#===============================================================================
# This script orchestrates the Bash-based test suites using only POSIX sh so it
# can be invoked from zsh, dash, busybox sh, etc. Each individual test keeps its
# native interpreter (Bash) via its own shebang.
#
# Usage:
#   ./run_tests.sh              # Auto-detect (no forced mode)
#   ./run_tests.sh --rich       # Force UTF-8 mode
#   ./run_tests.sh --color      # Force ASCII+color mode
#   ./run_tests.sh --plain      # Force ASCII mode
#   ./run_tests.sh --all        # Run all forced modes sequentially
#===============================================================================

set -eu

# shellcheck disable=SC3040
if (set -o pipefail >/dev/null 2>&1); then
    # shellcheck disable=SC3040
    set -o pipefail
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TEST_DIR="$SCRIPT_DIR/tests"

print_usage() {
    cat <<'USAGE'
Usage: ./run_tests.sh [MODE]

Modes:
  --rich, --utf8    Force UTF-8 mode (Unicode + Color)
  --color, --ansi   Force color mode (ASCII + Color)
  --plain, --ascii  Force plain mode (ASCII, no color)
  --all             Run tests in all forced modes (rich/color/plain)
  auto              Auto-detect mode (default)
USAGE
}

RAW_ARG=${1:-auto}
RUN_ALL=0
case "$RAW_ARG" in
    --rich|--utf8)
        TEST_MODE="rich"
        ;;
    --color|--ansi)
        TEST_MODE="color"
        ;;
    --plain|--ascii)
        TEST_MODE="plain"
        ;;
    --all)
        RUN_ALL=1
        TEST_MODE="auto"
        ;;
    --help|-h)
        print_usage
        exit 0
        ;;
    auto|"")
        TEST_MODE="auto"
        ;;
    *)
        printf 'Unknown mode: %s\n\n' "$RAW_ARG" >&2
        print_usage >&2
        exit 1
        ;;
esac

# Build deterministic list of tests once
if [ ! -d "$TEST_DIR" ]; then
    printf 'Test directory not found: %s\n' "$TEST_DIR" >&2
    exit 1
fi

TEST_LIST=$(mktemp "${TMPDIR:-/tmp}/oiseau_tests.XXXXXX")
trap 'rm -f "$TEST_LIST"' EXIT INT TERM
find "$TEST_DIR" -type f -name 'test_*.sh' ! -path '*/lib/*' | sort >"$TEST_LIST"
TOTAL_TESTS=$(wc -l <"$TEST_LIST" | awk '{print $1}')

if [ "$TOTAL_TESTS" -eq 0 ]; then
    printf 'No test suites found under %s\n' "$TEST_DIR" >&2
    exit 1
fi

run_tests_for_mode() {
    mode=$1
    tests_run=0
    tests_passed=0
    failed_tests=""

    if [ "$mode" = "auto" ]; then
        printf '\n== Running tests (auto-detect mode) ==\n'
    else
        printf '\n== Running tests with OISEAU_MODE=%s ==\n' "$mode"
    fi

    while IFS= read -r test_file || [ -n "$test_file" ]; do
        [ -n "$test_file" ] || continue
        tests_run=$((tests_run + 1))
        printf '(%d/%d) %s ... ' "$tests_run" "$TOTAL_TESTS" "$(basename "$test_file")"
        log_file=$(mktemp "${TMPDIR:-/tmp}/oiseau_test_log.XXXXXX")
        if [ "$mode" = "auto" ]; then
            if "$test_file" >"$log_file" 2>&1; then
                printf 'ok\n'
                tests_passed=$((tests_passed + 1))
            else
                printf 'FAIL\n'
                failed_tests="$failed_tests\n$(basename "$test_file")"
                cat "$log_file"
            fi
        else
            if OISEAU_MODE="$mode" "$test_file" >"$log_file" 2>&1; then
                printf 'ok\n'
                tests_passed=$((tests_passed + 1))
            else
                printf 'FAIL\n'
                failed_tests="$failed_tests\n$(basename "$test_file")"
                cat "$log_file"
            fi
        fi
        rm -f "$log_file"
    done <"$TEST_LIST"

    printf '\nSummary (%s mode): %d/%d passed\n' "$mode" "$tests_passed" "$tests_run"
    if [ -n "$failed_tests" ]; then
        printf 'Failed tests:%s\n' "$failed_tests"
        return 1
    fi
    return 0
}

STATUS=0
if [ "$RUN_ALL" -eq 1 ]; then
    for forced_mode in rich color plain; do
        if ! run_tests_for_mode "$forced_mode"; then
            STATUS=1
        fi
    done
else
    if ! run_tests_for_mode "$TEST_MODE"; then
        STATUS=1
    fi
fi

exit "$STATUS"
