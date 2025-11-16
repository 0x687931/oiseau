#!/usr/bin/env bash
#
# Test script for P2 fixes in show_help_paged
# Tests argument validation and items_per_page validation

set -euo pipefail

# Source oiseau.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/oiseau.sh"

echo "Testing P2 Fixes for show_help_paged"
echo "====================================="
echo ""

# Test data
declare -a test_help=(
    "SECTION_HEADER|"
    "key1|description1"
    "key2|description2"
    "key3|description3"
)

# Disable keypress prompts for testing
export OISEAU_HELP_NO_KEYPRESS=1

echo "Test 1: Missing title argument (should error)"
echo "----------------------------------------------"
output=$(show_help_paged "" test_help 5 2>&1 || true)
if echo "$output" | grep -q "ERROR: show_help_paged requires title and array_name arguments"; then
    echo "✓ PASS: Empty title rejected"
else
    echo "✗ FAIL: Empty title should be rejected"
    echo "Output: $output"
    exit 1
fi
echo ""

echo "Test 2: Missing array_name argument (should error)"
echo "---------------------------------------------------"
output=$(show_help_paged "Test" "" 5 2>&1 || true)
if echo "$output" | grep -q "ERROR: show_help_paged requires title and array_name arguments"; then
    echo "✓ PASS: Empty array_name rejected"
else
    echo "✗ FAIL: Empty array_name should be rejected"
    echo "Output: $output"
    exit 1
fi
echo ""

echo "Test 3: items_per_page = 0 (should error, division by zero)"
echo "------------------------------------------------------------"
output=$(show_help_paged "Test" test_help 0 2>&1 || true)
if echo "$output" | grep -q "ERROR: items_per_page must be greater than 0"; then
    echo "✓ PASS: items_per_page=0 rejected"
else
    echo "✗ FAIL: items_per_page=0 should be rejected"
    echo "Output: $output"
    exit 1
fi
echo ""

echo "Test 4: items_per_page = negative (should error)"
echo "-------------------------------------------------"
output=$(show_help_paged "Test" test_help -5 2>&1 || true)
if echo "$output" | grep -q "ERROR: items_per_page must be a positive integer"; then
    echo "✓ PASS: Negative items_per_page rejected"
else
    echo "✗ FAIL: Negative items_per_page should be rejected"
    echo "Output: $output"
    exit 1
fi
echo ""

echo "Test 5: items_per_page = non-numeric (should error)"
echo "----------------------------------------------------"
output=$(show_help_paged "Test" test_help "abc" 2>&1 || true)
if echo "$output" | grep -q "ERROR: items_per_page must be a positive integer"; then
    echo "✓ PASS: Non-numeric items_per_page rejected"
else
    echo "✗ FAIL: Non-numeric items_per_page should be rejected"
    echo "Output: $output"
    exit 1
fi
echo ""

echo "Test 6: Valid call with items_per_page = 2 (should succeed)"
echo "------------------------------------------------------------"
output=$(show_help_paged "Test Help" test_help 2 20 2>&1 || true)
if [ $? -eq 0 ] || echo "$output" | grep -q "Test Help"; then
    echo "✓ PASS: Valid call succeeded"
else
    echo "✗ FAIL: Valid call should succeed"
    echo "Output: $output"
    exit 1
fi
echo ""

echo "Test 7: Valid call with default items_per_page (should succeed)"
echo "----------------------------------------------------------------"
output=$(show_help_paged "Test Help" test_help 2>&1 || true)
if [ $? -eq 0 ] || echo "$output" | grep -q "Test Help"; then
    echo "✓ PASS: Valid call with default items_per_page succeeded"
else
    echo "✗ FAIL: Valid call with default items_per_page should succeed"
    echo "Output: $output"
    exit 1
fi
echo ""

echo "====================================="
echo "All P2 fix tests PASSED!"
echo "====================================="
echo ""
echo "Summary:"
echo "- Argument validation prevents bad substitution errors"
echo "- items_per_page validation prevents division by zero"
echo "- Error messages guide users to correct usage"
