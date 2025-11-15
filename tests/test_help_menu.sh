#!/bin/bash
# Test cases for show_help and show_help_paged functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/oiseau.sh"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to assert
assert_eq() {
    local name="$1"
    local expected="$2"
    local actual="$3"

    if [ "$expected" = "$actual" ]; then
        echo "✓ $name"
        ((TESTS_PASSED++))
    else
        echo "✗ $name"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Basic function exists
echo "Testing show_help function..."
if declare -f show_help >/dev/null; then
    echo "✓ show_help function exists"
    ((TESTS_PASSED++))
else
    echo "✗ show_help function not found"
    ((TESTS_FAILED++))
fi

# Test 2: show_help_paged exists
echo "Testing show_help_paged function..."
if declare -f show_help_paged >/dev/null; then
    echo "✓ show_help_paged function exists"
    ((TESTS_PASSED++))
else
    echo "✗ show_help_paged function not found"
    ((TESTS_FAILED++))
fi

# Test 3: show_help with no args returns error
echo ""
echo "Testing error handling..."
result=$(show_help 2>&1)
if [ $? -ne 0 ] && echo "$result" | grep -q "ERROR"; then
    echo "✓ show_help errors on missing arguments"
    ((TESTS_PASSED++))
else
    echo "✗ show_help should error on missing arguments"
    ((TESTS_FAILED++))
fi

# Test 4: show_help with empty array returns error
empty_array=()
result=$(show_help "Test" empty_array 2>&1)
if [ $? -ne 0 ] && echo "$result" | grep -q "ERROR"; then
    echo "✓ show_help errors on empty array"
    ((TESTS_PASSED++))
else
    echo "✗ show_help should error on empty array"
    ((TESTS_FAILED++))
fi

# Test 5: Basic array parsing works
echo ""
echo "Testing basic functionality..."
test_items=("key|description")
# This would need to be tested differently in integration tests
# since show_help outputs to stdout
if OISEAU_HELP_NO_KEYPRESS=1 show_help "Test" test_items 2>/dev/null | grep -q "key"; then
    echo "✓ show_help outputs key from array"
    ((TESTS_PASSED++))
else
    echo "✗ show_help should output key"
    ((TESTS_FAILED++))
fi

# Test 6: Section headers work
echo ""
echo "Testing section header detection..."
section_items=(
    "SECTION|"
    "key|description"
)
if OISEAU_HELP_NO_KEYPRESS=1 show_help "Test" section_items 2>/dev/null | grep -q "SECTION"; then
    echo "✓ show_help detects section headers"
    ((TESTS_PASSED++))
else
    echo "✗ show_help should detect sections"
    ((TESTS_FAILED++))
fi

# Test 7: Multiple items
echo ""
echo "Testing multiple items..."
multi_items=(
    "item1|description 1"
    "item2|description 2"
    "item3|description 3"
)
output=$(OISEAU_HELP_NO_KEYPRESS=1 show_help "Test" multi_items 2>/dev/null)
if echo "$output" | grep -q "item1" && echo "$output" | grep -q "item2" && echo "$output" | grep -q "item3"; then
    echo "✓ show_help displays multiple items"
    ((TESTS_PASSED++))
else
    echo "✗ show_help should display all items"
    ((TESTS_FAILED++))
fi

# Test 8: Sanitization works
echo ""
echo "Testing input sanitization..."
unsafe_items=("key\033[31mRED\033[0m|description")
output=$(OISEAU_HELP_NO_KEYPRESS=1 show_help "Test" unsafe_items 2>/dev/null)
# Output should not contain raw ANSI escape sequences after sanitization
if ! echo "$output" | grep -q $'\033\[31m'; then
    echo "✓ show_help sanitizes ANSI sequences"
    ((TESTS_PASSED++))
else
    echo "✗ show_help should sanitize input"
    ((TESTS_FAILED++))
fi

# Test 9: Custom key width
echo ""
echo "Testing custom key width..."
width_items=("VERY_LONG_KEY_NAME|description")
output=$(OISEAU_HELP_NO_KEYPRESS=1 show_help "Test" width_items 40 2>/dev/null)
if echo "$output" | grep -q "VERY_LONG_KEY_NAME"; then
    echo "✓ show_help accepts custom key width"
    ((TESTS_PASSED++))
else
    echo "✗ show_help should accept key width parameter"
    ((TESTS_FAILED++))
fi

# Test 10: show_help_paged exists and works
echo ""
echo "Testing show_help_paged..."
paged_items=(
    "key1|description"
    "key2|description"
    "key3|description"
)
output=$(OISEAU_HELP_NO_KEYPRESS=1 show_help_paged "Test" paged_items 2 20 2>/dev/null)
if [ $? -eq 0 ] && echo "$output" | grep -q "key1"; then
    echo "✓ show_help_paged works with pagination"
    ((TESTS_PASSED++))
else
    echo "✗ show_help_paged should work"
    ((TESTS_FAILED++))
fi

# Summary
echo ""
echo "==============================================="
echo "Test Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo "==============================================="

if [ $TESTS_FAILED -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
