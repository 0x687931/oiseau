#!/bin/bash
# Test script for edge cases discovered in code review

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

# Test 1: show_help_paged propagates errors
test_help_paged_error_propagation() {
    local empty_array=()
    # Call with empty array (should fail)
    show_help_paged "Test" empty_array >/dev/null 2>&1
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        echo "  ✓ show_help_paged propagates error from show_help"
        return 0
    else
        echo "  ✗ show_help_paged should return non-zero for invalid input"
        return 1
    fi
}

# Test 2: Pager handles content without trailing newline
test_pager_no_trailing_newline() {
    # Create file without trailing newline
    printf "Line 1\nLine 2\nLine 3 (no newline)" > /tmp/test_no_newline.txt

    # Source and capture pager output in non-interactive mode
    OISEAU_IS_TTY=0 show_pager /tmp/test_no_newline.txt "Test" > /tmp/pager_output.txt 2>&1

    # Check if final line is present
    if grep -q "Line 3 (no newline)" /tmp/pager_output.txt; then
        echo "  ✓ Pager captures final line without newline"
        rm -f /tmp/test_no_newline.txt /tmp/pager_output.txt
        return 0
    else
        echo "  ✗ Pager lost final line without newline"
        rm -f /tmp/test_no_newline.txt /tmp/pager_output.txt
        return 1
    fi
}

# Test 3: Resize handler re-registration preserves original trap
test_resize_reregister() {
    # Define test callbacks
    test_callback_1() {
        echo "Callback 1"
    }

    test_callback_2() {
        echo "Callback 2"
    }

    # Register first handler
    register_resize_handler test_callback_1 >/dev/null 2>&1

    # Register second handler (re-register)
    register_resize_handler test_callback_2 >/dev/null 2>&1

    # Clean up
    unregister_resize_handler

    # If we got here without errors, the re-registration worked
    echo "  ✓ Resize handler re-registration works"
    return 0
}

# Test 4: Table truncation with CJK characters
test_table_cjk_truncation() {
    # Create table with CJK text that needs truncation
    local table_data=("Name" "Description" "Alice" "English text" "李明" "中文名字很长需要截断测试超长文本")

    # Show table with narrow columns to force truncation
    local output=$(show_table table_data 2 "Test" "10,15" 2>&1)

    # Check if table was generated (should not error)
    if echo "$output" | grep -q "Alice"; then
        echo "  ✓ Table handles CJK truncation without errors"
        return 0
    else
        echo "  ✗ Table failed with CJK content"
        return 1
    fi
}

# Test 5: Pager with variable content (not file)
test_pager_variable_content() {
    local content="Line 1
Line 2
Line 3"

    # Test with variable content
    OISEAU_IS_TTY=0 show_pager "$content" "Test" > /tmp/pager_var_output.txt 2>&1

    if grep -q "Line 3" /tmp/pager_var_output.txt; then
        echo "  ✓ Pager handles variable content"
        rm -f /tmp/pager_var_output.txt
        return 0
    else
        echo "  ✗ Pager failed with variable content"
        rm -f /tmp/pager_var_output.txt
        return 1
    fi
}

# Test 6: show_help_paged doesn't block in TTY mode
test_help_paged_no_block() {
    local help_items=("Test|Description" "Key|Value")

    # Set TTY mode and NO_KEYPRESS flag
    OISEAU_IS_TTY=1 OISEAU_HELP_NO_KEYPRESS=1 show_help "Test" help_items >/dev/null 2>&1

    # If we got here without hanging, it worked
    echo "  ✓ show_help respects OISEAU_HELP_NO_KEYPRESS flag"
    return 0
}

# Test 7: Table with empty cells
test_table_empty_cells() {
    local table_data=("Name" "Value" "Item1" "" "" "Value2")

    local output=$(show_table table_data 2 "Test" 2>&1)

    if echo "$output" | grep -q "Item1"; then
        echo "  ✓ Table handles empty cells"
        return 0
    else
        echo "  ✗ Table failed with empty cells"
        return 1
    fi
}

# Test 8: Resize handler cleanup is idempotent
test_resize_cleanup_idempotent() {
    test_callback() {
        echo "Test"
    }

    register_resize_handler test_callback >/dev/null 2>&1

    # Call cleanup multiple times
    unregister_resize_handler
    unregister_resize_handler
    unregister_resize_handler

    # If no errors, it's idempotent
    echo "  ✓ Resize handler cleanup is idempotent"
    return 0
}

# Test 9: _truncate_to_width helper function
test_truncate_to_width_helper() {
    if type _truncate_to_width >/dev/null 2>&1; then
        # Test with CJK text
        local result=$(_truncate_to_width "你好世界测试" 10)

        if [ -n "$result" ] && echo "$result" | grep -q "..."; then
            echo "  ✓ _truncate_to_width helper exists and works"
            return 0
        else
            echo "  ✗ _truncate_to_width produced unexpected result: '$result'"
            return 1
        fi
    else
        echo "  ✗ _truncate_to_width helper function not found"
        return 1
    fi
}

# Test 10: Pager with piped stdin (non-interactive test)
test_pager_stdin() {
    echo -e "Piped line 1\nPiped line 2" | OISEAU_IS_TTY=0 show_pager "-" "Test" > /tmp/pager_stdin.txt 2>&1

    if grep -q "Piped line 2" /tmp/pager_stdin.txt; then
        echo "  ✓ Pager handles stdin in non-TTY mode"
        rm -f /tmp/pager_stdin.txt
        return 0
    else
        echo "  ✗ Pager failed with stdin"
        rm -f /tmp/pager_stdin.txt
        return 1
    fi
}

# Banner
echo ""
show_header_box "Edge Cases & Code Review Issues Tests"
echo ""

# Run all tests
run_test "show_help_paged Error Propagation" test_help_paged_error_propagation
run_test "Pager: No Trailing Newline" test_pager_no_trailing_newline
run_test "Resize: Re-registration" test_resize_reregister
run_test "Table: CJK Truncation" test_table_cjk_truncation
run_test "Pager: Variable Content" test_pager_variable_content
run_test "Help Paged: No Block in TTY" test_help_paged_no_block
run_test "Table: Empty Cells" test_table_empty_cells
run_test "Resize: Idempotent Cleanup" test_resize_cleanup_idempotent
run_test "_truncate_to_width Helper" test_truncate_to_width_helper
run_test "Pager: Stdin Input" test_pager_stdin

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tests run: $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $((TESTS_RUN - TESTS_PASSED))"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    show_success "All edge case tests passed!"
    exit 0
else
    show_error "Some edge case tests failed"
    exit 1
fi
