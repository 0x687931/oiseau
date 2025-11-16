#!/usr/bin/env bash
#===============================================================================
# OISEAU TEST RUNNER
#===============================================================================
# Unified test runner for all Oiseau test suites
# Uses oiseau widgets for beautiful output
#
# Usage:
#   ./run_tests.sh              # Run in default mode (auto-detect)
#   ./run_tests.sh --rich       # Force UTF-8 mode
#   ./run_tests.sh --color      # Force ASCII mode
#   ./run_tests.sh --plain      # Force plain mode
#   ./run_tests.sh --all        # Run in all three modes
#===============================================================================

set -eo pipefail

# Parse command line arguments
TEST_MODE="${1:-auto}"
RUN_ALL_MODES=0

case "$TEST_MODE" in
    --rich|--utf8)
        export OISEAU_MODE="rich"
        ;;
    --color|--ascii|--ansi)
        export OISEAU_MODE="color"
        ;;
    --plain)
        export OISEAU_MODE="plain"
        ;;
    --all)
        RUN_ALL_MODES=1
        ;;
    --help|-h)
        echo "Usage: $0 [MODE]"
        echo ""
        echo "Modes:"
        echo "  --rich, --utf8    Force UTF-8 mode (full Unicode)"
        echo "  --color, --ascii  Force ASCII mode (no Unicode)"
        echo "  --plain           Force plain mode (no colors)"
        echo "  --all             Run tests in all three modes"
        echo "  (default)         Auto-detect mode"
        exit 0
        ;;
    auto|"")
        # Auto-detect (default behavior)
        ;;
    *)
        echo "Error: Unknown mode '$TEST_MODE'"
        echo "Run '$0 --help' for usage information"
        exit 1
        ;;
esac

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to run tests in a specific mode
run_tests_in_mode() {
    local mode="$1"

    # Set mode if specified
    if [ "$mode" != "auto" ]; then
        export OISEAU_MODE="$mode"
    fi

    # Source oiseau library (fresh for each mode)
    source "$SCRIPT_DIR/oiseau.sh"

# Test configuration
TEST_DIR="$SCRIPT_DIR/tests"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

#===============================================================================
# Main Execution
#===============================================================================

# Welcome banner
show_header_box "Oiseau Test Suite Runner"
echo ""

# Check if test directory exists
if [ ! -d "$TEST_DIR" ]; then
    show_box error "Test Directory Not Found" "Cannot find test directory: $TEST_DIR"
    return 1
fi

# Find all test files (Bash 3.x compatible)
test_files=()
while IFS= read -r file; do
    test_files+=("$file")
done < <(find "$TEST_DIR" -name "test_*.sh" -type f | sort)

if [ ${#test_files[@]} -eq 0 ]; then
    show_box warning "No Tests Found" "No test files found in $TEST_DIR"
    return 1
fi

# Show test summary
show_info "Found ${#test_files[@]} test suites"
echo ""

# Progress tracking
echo "Running tests..."
echo ""

# Run each test file with animated progress
for i in "${!test_files[@]}"; do
    test_file="${test_files[$i]}"
    test_name="$(basename "$test_file" .sh)"
    current=$((i + 1))
    total="${#test_files[@]}"

    # Run test and capture result
    TESTS_RUN=$((TESTS_RUN + 1))

    # Build progress bar manually for inline display
    percent=$((current * 100 / total))
    bar_width=20
    filled=$((current * bar_width / total))
    empty=$((bar_width - filled))

    # Choose characters based on mode
    if [ "$OISEAU_MODE" = "rich" ]; then
        filled_char="█"
        empty_char="░"
    else
        filled_char="#"
        empty_char="-"
    fi

    # Build bar string
    bar="${COLOR_SUCCESS}$(_repeat_char "$filled_char" "$filled")${COLOR_DIM}$(_repeat_char "$empty_char" "$empty")${RESET}"
    progress_display="Testing: ${bar} ${percent}% (${current}/${total})"

    # Run test and show result on same line (update in place)
    if "$test_file" > /dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -en "\r${progress_display}  ${COLOR_SUCCESS}${ICON_SUCCESS}${RESET}  ${test_name}\033[K"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
        echo -en "\r${progress_display}  ${COLOR_ERROR}${ICON_ERROR}${RESET}  ${test_name}\033[K"
    fi
    sleep 0.1  # Brief pause to see each test update
done

# Print final newline after progress updates
echo ""
echo ""  # Extra blank line
echo ""

# Summary section
show_header_box "Test Results Summary"
echo ""

# Show summary using key-value pairs
print_kv "Total Test Suites" "$TESTS_RUN" 20
print_kv "Passed" "$TESTS_PASSED" 20
print_kv "Failed" "$TESTS_FAILED" 20

echo ""

# Show result
if [ "$TESTS_FAILED" -eq 0 ]; then
    show_box success "All Tests Passed!" "All $TESTS_PASSED test suites completed successfully."
    echo ""

    # Checklist of what was validated
    checklist_items=(
        "done|Code quality validated"
        "done|All widgets tested"
        "done|Security checks passed"
        "done|Bash compatibility verified"
    )
    show_checklist checklist_items
    echo ""
    return 0
else
    show_box error "Some Tests Failed" "$(printf '%d test suite(s) failed:\n\n' "$TESTS_FAILED")$(printf '  • %s\n' "${FAILED_TESTS[@]}")"
    echo ""
    show_info "Re-run individual tests for details:"
    for failed in "${FAILED_TESTS[@]}"; do
        echo "  ./tests/${failed}.sh"
    done
    echo ""
    return 1
fi
}

#===============================================================================
# Main Entry Point
#===============================================================================

# Run tests based on mode selection
if [ "$RUN_ALL_MODES" -eq 1 ]; then
    # Run in all three modes
    OVERALL_EXIT=0

    for mode in rich color plain; do
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        case "$mode" in
            rich)  echo "Running tests in RICH mode (UTF-8 + Color)" ;;
            color) echo "Running tests in COLOR mode (ASCII + Color)" ;;
            plain) echo "Running tests in PLAIN mode (ASCII only)" ;;
        esac
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        if ! run_tests_in_mode "$mode"; then
            OVERALL_EXIT=1
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ "$OVERALL_EXIT" -eq 0 ]; then
        echo "✓ All tests passed in all three modes!"
    else
        echo "✗ Some tests failed in one or more modes"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    exit "$OVERALL_EXIT"
else
    # Run in single mode
    run_tests_in_mode "$TEST_MODE"
    exit $?
fi
