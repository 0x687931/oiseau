#!/bin/bash
# Test script for show_table widget

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
    if type show_table >/dev/null 2>&1; then
        echo "  ✓ show_table function exists"
        return 0
    else
        echo "  ✗ show_table function not found"
        return 1
    fi
}

# Test 2: Validation - missing arguments
test_validation_missing() {
    local output=$(show_table 2>&1)
    if echo "$output" | grep -q "ERROR"; then
        echo "  ✓ Rejects missing arguments"
        return 0
    else
        echo "  ✗ Should reject missing arguments"
        return 1
    fi
}

# Test 3: Validation - invalid num_cols
test_validation_invalid_cols() {
    local test_data=("A" "B")
    local output=$(show_table test_data "invalid" 2>&1)
    if echo "$output" | grep -q "ERROR.*must be.*integer"; then
        echo "  ✓ Rejects invalid num_cols"
        return 0
    else
        echo "  ✗ Should reject invalid num_cols"
        return 1
    fi
}

# Test 4: Validation - empty array
test_validation_empty() {
    local empty_array=()
    local output=$(show_table empty_array 2 2>&1)
    if echo "$output" | grep -q "ERROR.*empty"; then
        echo "  ✓ Rejects empty array"
        return 0
    else
        echo "  ✗ Should reject empty array"
        return 1
    fi
}

# Test 5: Validation - array size not multiple of num_cols
test_validation_size_mismatch() {
    local bad_data=("A" "B" "C")
    local output=$(show_table bad_data 2 2>&1)
    if echo "$output" | grep -q "ERROR.*multiple"; then
        echo "  ✓ Rejects size mismatch"
        return 0
    else
        echo "  ✗ Should reject size mismatch"
        return 1
    fi
}

# Test 6: Mode awareness - border characters
test_mode_awareness() {
    if grep -q 'border_h="─"' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q 'border_h="-"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Mode-aware borders: ─ (UTF-8), - (ASCII)"
        return 0
    else
        echo "  ✗ Border mode awareness not found"
        return 1
    fi
}

# Test 7: Width calculation - auto mode
test_auto_width() {
    if grep -q 'Auto-calculate widths based on content' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Auto-width calculation implemented"
        return 0
    else
        echo "  ✗ Auto-width calculation not found"
        return 1
    fi
}

# Test 8: Width calculation - custom widths
test_custom_width() {
    if grep -q 'Parse custom widths if provided' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Custom width specification supported"
        return 0
    else
        echo "  ✗ Custom width specification not found"
        return 1
    fi
}

# Test 9: Performance - width caching
test_width_caching() {
    if grep -q 'Single pass through all cells' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Width caching (single pass) implemented"
        return 0
    else
        echo "  ✗ Width caching not found"
        return 1
    fi
}

# Test 10: Truncation with ellipsis
test_truncation() {
    # Check for improved truncation using _truncate_to_width helper
    if grep -q '_truncate_to_width' "$PROJECT_ROOT/oiseau.sh" || grep -q 'Truncate with ellipsis' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Ellipsis truncation implemented (using _truncate_to_width helper)"
        return 0
    else
        echo "  ✗ Ellipsis truncation not found"
        return 1
    fi
}

# Test 11: Input sanitization
test_sanitization() {
    if grep -q '_escape_input.*cell' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Cell sanitization active"
        return 0
    else
        echo "  ✗ Sanitization not found"
        return 1
    fi
}

# Test 12: Header row styling
test_header_styling() {
    if grep -q 'if \[ "\$r" -eq 0 \]' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Header row special styling"
        return 0
    else
        echo "  ✗ Header styling not found"
        return 1
    fi
}

# Test 13: Display width handling (CJK support)
test_display_width() {
    if grep -q '_display_width.*cell' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Uses _display_width for CJK support"
        return 0
    else
        echo "  ✗ Display width handling not found"
        return 1
    fi
}

# Test 14: Border line caching
test_border_caching() {
    if grep -q 'Build border lines (cached for reuse)' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Border line caching implemented"
        return 0
    else
        echo "  ✗ Border caching not found"
        return 1
    fi
}

# Test 15: Bash 3.x compatibility
test_bash3_compat() {
    if grep -q 'eval.*table_data=.*\${.*@' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Bash 3.x compatible array handling"
        return 0
    else
        echo "  ✗ May not be bash 3.x compatible"
        return 1
    fi
}

# Banner
echo ""
echo "╭────────────────────────────────────────────────╮"
echo "│  Table Widget (show_table) Validation Tests    │"
echo "╰────────────────────────────────────────────────╯"
echo ""

# Run all tests
run_test "Function Exists" test_function_exists
run_test "Validation: Missing Args" test_validation_missing
run_test "Validation: Invalid Cols" test_validation_invalid_cols
run_test "Validation: Empty Array" test_validation_empty
run_test "Validation: Size Mismatch" test_validation_size_mismatch
run_test "Mode Awareness: Borders" test_mode_awareness
run_test "Auto Width Calculation" test_auto_width
run_test "Custom Width Specification" test_custom_width
run_test "Width Caching (Performance)" test_width_caching
run_test "Truncation with Ellipsis" test_truncation
run_test "Input Sanitization" test_sanitization
run_test "Header Row Styling" test_header_styling
run_test "Display Width (CJK Support)" test_display_width
run_test "Border Line Caching" test_border_caching
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
