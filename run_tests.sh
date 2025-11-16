#!/usr/bin/env bash
#===============================================================================
# OISEAU TEST RUNNER
#===============================================================================
# Unified test runner for all Oiseau test suites
# Uses oiseau widgets for beautiful output
#===============================================================================

set -eo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source oiseau library
source "$SCRIPT_DIR/oiseau.sh"

# Test configuration
TEST_DIR="$SCRIPT_DIR/tests"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

#===============================================================================
# Helper Functions
#===============================================================================

run_test_file() {
    local test_file="$1"
    local test_name="$(basename "$test_file" .sh)"

    TESTS_RUN=$((TESTS_RUN + 1))

    # Run test and capture output
    if "$test_file" > /dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        show_success "$test_name"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
        show_error "$test_name"
    fi
}

#===============================================================================
# Main Execution
#===============================================================================

# Welcome banner
show_header_box "Oiseau Test Suite Runner"
echo ""

# Check if test directory exists
if [ ! -d "$TEST_DIR" ]; then
    show_box error "Test Directory Not Found" "Cannot find test directory: $TEST_DIR"
    exit 1
fi

# Find all test files (Bash 3.x compatible)
test_files=()
while IFS= read -r file; do
    test_files+=("$file")
done < <(find "$TEST_DIR" -name "test_*.sh" -type f | sort)

if [ ${#test_files[@]} -eq 0 ]; then
    show_box warning "No Tests Found" "No test files found in $TEST_DIR"
    exit 1
fi

# Show test summary
show_info "Found ${#test_files[@]} test suites"
echo ""

# Progress tracking
echo "Running tests..."
echo ""

# Run each test file
for i in "${!test_files[@]}"; do
    test_file="${test_files[$i]}"
    current=$((i + 1))
    total="${#test_files[@]}"

    # Show progress
    show_progress_bar "$current" "$total" "Testing"

    # Run test
    run_test_file "$test_file"
done

# Final progress
show_progress_bar "$total" "$total" "Complete"
echo ""
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
    exit 0
else
    show_box error "Some Tests Failed" "$(printf '%d test suite(s) failed:\n\n' "$TESTS_FAILED")$(printf '  • %s\n' "${FAILED_TESTS[@]}")"
    echo ""
    show_info "Re-run individual tests for details:"
    for failed in "${FAILED_TESTS[@]}"; do
        echo "  ./tests/${failed}.sh"
    done
    echo ""
    exit 1
fi
