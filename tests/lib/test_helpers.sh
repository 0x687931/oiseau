#!/bin/bash
# Shared test helper library for Oiseau test suite
# Eliminates duplication across test files

# Determine project root relative to tests/lib/
TEST_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(cd "$TEST_LIB_DIR/../.." && pwd)"

# Source oiseau.sh
source "$PROJECT_ROOT/oiseau.sh"

# Test counters (global state shared across test file)
TESTS_RUN=0
TESTS_PASSED=0

# Run a single test function and track results
# Usage: run_test "Test Name" test_function_name
run_test() {
    local test_name="$1"
    local test_func="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo "━━━ Test: $test_name ━━━"

    if $test_func; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "  ✓ PASS: $test_name"
    else
        echo "  ✗ FAIL: $test_name"
    fi
}

# Print test suite header banner
# Usage: print_test_banner "Test Suite Name"
print_test_banner() {
    local suite_name="$1"
    echo ""
    show_header_box "$suite_name"
    echo ""
}

# Print test summary and exit with appropriate code
# Usage: print_test_summary
print_test_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Tests run: $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $((TESTS_RUN - TESTS_PASSED))"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
        show_success "All tests passed!"
        exit 0
    else
        show_error "Some tests failed"
        exit 1
    fi
}
