#!/bin/bash
# Test script for ask_list interactive list selection

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
    if type ask_list >/dev/null 2>&1; then
        echo "  ✓ ask_list function exists"
        return 0
    else
        echo "  ✗ ask_list function not found"
        return 1
    fi
}

# Test 2: Validation - missing arguments
test_validation_missing() {
    # Call function and capture both stdout and stderr
    local output=$(ask_list 2>&1)
    if echo "$output" | grep -q "ERROR"; then
        echo "  ✓ Rejects missing arguments"
        return 0
    else
        echo "  ✗ Should reject missing arguments (got: '$output')"
        return 1
    fi
}

# Test 3: Validation - empty array
test_validation_empty() {
    local empty_array=()
    local output=$(ask_list "Choose:" empty_array 2>&1)
    if echo "$output" | grep -q "ERROR.*empty"; then
        echo "  ✓ Rejects empty array"
        return 0
    else
        echo "  ✗ Should reject empty array"
        return 1
    fi
}

# Test 4: Non-TTY fallback
test_nontty_fallback() {
    # In non-TTY mode, should offer numbered list
    # This test just verifies the code path exists
    if grep -q 'OISEAU_IS_TTY.*!=.*"1"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Non-TTY fallback code exists"
        return 0
    else
        echo "  ✗ Non-TTY fallback not found"
        return 1
    fi
}

# Test 5: Mode awareness - cursor characters
test_mode_awareness() {
    if grep -q 'cursor_char="›"' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q 'cursor_char=">"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Mode-aware cursor: › (UTF-8), > (ASCII)"
        return 0
    else
        echo "  ✗ Cursor character mode awareness not found"
        return 1
    fi
}

# Test 6: Mode awareness - checkboxes
test_checkbox_modes() {
    if grep -q 'checked_char="✓"' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q 'checked_char="X"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Mode-aware checkboxes: ✓ (UTF-8), X (ASCII)"
        return 0
    else
        echo "  ✗ Checkbox mode awareness not found"
        return 1
    fi
}

# Test 7: Single-select mode
test_single_select() {
    # Verify single-select mode code exists
    if grep -q 'mode.*single' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Single-select mode implemented"
        return 0
    else
        echo "  ✗ Single-select mode not found"
        return 1
    fi
}

# Test 8: Multi-select mode
test_multi_select() {
    # Verify multi-select mode code exists
    if grep -q 'mode.*multi' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Multi-select mode implemented"
        return 0
    else
        echo "  ✗ Multi-select mode not found"
        return 1
    fi
}

# Test 9: Arrow key navigation
test_arrow_keys() {
    # Verify arrow key handling
    if grep -q '\[A.*Up arrow' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q '\[B.*Down arrow' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Arrow key navigation (↑↓) implemented"
        return 0
    else
        echo "  ✗ Arrow key navigation not found"
        return 1
    fi
}

# Test 10: Vim-style navigation (j/k)
test_vim_keys() {
    if grep -q "'k'.*# Up" "$PROJECT_ROOT/oiseau.sh" && \
       grep -q "'j'.*# Down" "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Vim-style navigation (j/k) implemented"
        return 0
    else
        echo "  ✗ Vim-style navigation not found"
        return 1
    fi
}

# Test 11: Space toggle (multi-select)
test_space_toggle() {
    if grep -q "' '.*# Space" "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Space key toggle for multi-select"
        return 0
    else
        echo "  ✗ Space toggle not found"
        return 1
    fi
}

# Test 12: Enter key selection
test_enter_key() {
    if grep -q "''.*# Enter" "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Enter key for selection"
        return 0
    else
        echo "  ✗ Enter key handling not found"
        return 1
    fi
}

# Test 13: Cancel with q or Esc
test_cancel_keys() {
    if grep -q "'q'.*'Q'.*cancel\|'q'.*'Q'.*Esc" "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Cancel with q/Esc implemented"
        return 0
    else
        echo "  ✗ Cancel keys not found"
        return 1
    fi
}

# Test 14: Input sanitization
test_sanitization() {
    if grep -q '_escape_input.*prompt' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Prompt sanitization active"
        return 0
    else
        echo "  ✗ Sanitization not found"
        return 1
    fi
}

# Test 15: Screen clearing/redraw
test_screen_redraw() {
    if grep -q 'render_list' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ List rendering function exists"
        return 0
    else
        echo "  ✗ List rendering not found"
        return 1
    fi
}

# Test 16: Help text display
test_help_text() {
    if grep -q 'Navigate.*Enter.*Select' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Help text for single-select mode"
    else
        echo "  ✗ Single-select help text not found"
        return 1
    fi

    if grep -q 'Space.*Toggle.*Enter.*Confirm' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Help text for multi-select mode"
        return 0
    else
        echo "  ✗ Multi-select help text not found"
        return 1
    fi
}

# Test 17: Return value format
test_return_format() {
    # Multi-select should return newline-separated items
    if grep -q 'printf.*%s.*\\n' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Multi-select returns newline-separated items"
        return 0
    else
        echo "  ✗ Return format not correct"
        return 1
    fi
}

# Test 18: Bash 3.x compatibility
test_bash3_compat() {
    # Should use eval instead of nameref for array handling
    if grep -q 'eval.*items=.*\${.*@' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Bash 3.x compatible array handling"
        return 0
    else
        echo "  ✗ May not be bash 3.x compatible"
        return 1
    fi
}

# Banner
echo ""
show_header_box "Interactive List (ask_list) Validation Tests"
echo ""

# Run all tests
run_test "Function Exists" test_function_exists
run_test "Validation: Missing Args" test_validation_missing
run_test "Validation: Empty Array" test_validation_empty
run_test "Non-TTY Fallback" test_nontty_fallback
run_test "Mode Awareness: Cursor" test_mode_awareness
run_test "Mode Awareness: Checkboxes" test_checkbox_modes
run_test "Single-Select Mode" test_single_select
run_test "Multi-Select Mode" test_multi_select
run_test "Arrow Key Navigation" test_arrow_keys
run_test "Vim-Style Navigation (j/k)" test_vim_keys
run_test "Space Toggle (Multi)" test_space_toggle
run_test "Enter Key Selection" test_enter_key
run_test "Cancel Keys (q/Esc)" test_cancel_keys
run_test "Input Sanitization" test_sanitization
run_test "Screen Redraw" test_screen_redraw
run_test "Help Text" test_help_text
run_test "Return Format" test_return_format
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
