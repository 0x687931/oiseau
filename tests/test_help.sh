#!/bin/bash
# Test script for show_help widget

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source oiseau.sh
source "$PROJECT_ROOT/oiseau.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Helper function to run tests
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

# Test 1: Function exists
test_function_exists() {
    if type show_help >/dev/null 2>&1; then
        echo "  ✓ show_help function exists"
        return 0
    else
        echo "  ✗ show_help function not found"
        return 1
    fi
}

# Test 2: show_help_paged exists
test_paged_exists() {
    if type show_help_paged >/dev/null 2>&1; then
        echo "  ✓ show_help_paged function exists"
        return 0
    else
        echo "  ✗ show_help_paged function not found"
        return 1
    fi
}

# Test 3: Validation - missing arguments
test_validation_missing() {
    local output=$(show_help 2>&1)
    if echo "$output" | grep -q "ERROR"; then
        echo "  ✓ Rejects missing arguments"
        return 0
    else
        echo "  ✗ Should reject missing arguments"
        return 1
    fi
}

# Test 4: Validation - empty array
test_validation_empty() {
    local empty_array=()
    local output=$(show_help "Test" empty_array 2>&1)
    if echo "$output" | grep -q "ERROR.*empty"; then
        echo "  ✓ Rejects empty array"
        return 0
    else
        echo "  ✗ Should reject empty array"
        return 1
    fi
}

# Test 5: Validation - invalid key_width
test_validation_key_width() {
    local test_items=("key|desc")
    local output=$(show_help "Test" test_items 2 2>&1)
    if echo "$output" | grep -q "ERROR.*key_width"; then
        echo "  ✓ Rejects invalid key_width"
        return 0
    else
        echo "  ✗ Should reject invalid key_width"
        return 1
    fi
}

# Test 6: Widget reuse - show_header_box
test_uses_header_box() {
    if grep -q 'show_header_box.*safe_title' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Uses show_header_box for title"
        return 0
    else
        echo "  ✗ Doesn't use show_header_box"
        return 1
    fi
}

# Test 7: Widget reuse - print_kv
test_uses_print_kv() {
    if grep -q 'print_kv.*safe_key.*safe_description' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Uses print_kv for key-value pairs"
        return 0
    else
        echo "  ✗ Doesn't use print_kv"
        return 1
    fi
}

# Test 8: Section header support
test_section_headers() {
    if grep -q 'if \[ -z "\$description" \]' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Section header support (empty description)"
        return 0
    else
        echo "  ✗ Section header handling not found"
        return 1
    fi
}

# Test 9: Pipe delimiter parsing
test_pipe_delimiter() {
    # Check for pipe delimiter parsing (may use local IFS for safety)
    if grep -q "IFS='|'" "$PROJECT_ROOT/oiseau.sh" && grep -q "read -r key description" "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Pipe delimiter parsing (with local IFS for safety)"
        return 0
    else
        echo "  ✗ Pipe delimiter parsing not found"
        return 1
    fi
}

# Test 10: Input sanitization
test_sanitization() {
    if grep -q '_escape_input.*title' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Title and content sanitization active"
        return 0
    else
        echo "  ✗ Sanitization not found"
        return 1
    fi
}

# Test 11: TTY detection for "press any key"
test_tty_detection() {
    if grep -q 'if \[ "\$OISEAU_IS_TTY" = "1" \]' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ TTY detection for interactive prompt"
        return 0
    else
        echo "  ✗ TTY detection not found"
        return 1
    fi
}

# Test 12: Press any key prompt
test_press_any_key() {
    if grep -q 'Press any key to continue' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Press any key prompt implemented"
        return 0
    else
        echo "  ✗ Press any key prompt not found"
        return 1
    fi
}

# Test 13: Paged version uses show_pager
test_paged_uses_pager() {
    if grep -q 'show_pager.*help_content.*title' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ show_help_paged uses show_pager"
        return 0
    else
        echo "  ✗ show_help_paged doesn't use show_pager"
        return 1
    fi
}

# Test 14: Bash 3.x compatibility
test_bash3_compat() {
    if grep -q 'eval.*help_items=.*\${.*@' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Bash 3.x compatible array handling"
        return 0
    else
        echo "  ✗ May not be bash 3.x compatible"
        return 1
    fi
}

# Banner
echo ""
show_header_box "Help Menu (show_help) Validation Tests"
echo ""

# Run all tests
run_test "Function Exists" test_function_exists
run_test "Paged Version Exists" test_paged_exists
run_test "Validation: Missing Args" test_validation_missing
run_test "Validation: Empty Array" test_validation_empty
run_test "Validation: Invalid Key Width" test_validation_key_width
run_test "Widget Reuse: show_header_box" test_uses_header_box
run_test "Widget Reuse: print_kv" test_uses_print_kv
run_test "Section Header Support" test_section_headers
run_test "Pipe Delimiter Parsing" test_pipe_delimiter
run_test "Input Sanitization" test_sanitization
run_test "TTY Detection" test_tty_detection
run_test "Press Any Key Prompt" test_press_any_key
run_test "Paged Version Uses show_pager" test_paged_uses_pager
run_test "Bash 3.x Compatibility" test_bash3_compat

# Summary
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
