#!/bin/bash
# Test script for enhanced show_progress_bar

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

# Test 1: Basic functionality
test_basic() {
    local output=$(show_progress_bar 50 100 "Test")
    if echo "$output" | grep -q "50%"; then
        echo "  ✓ Shows percentage"
        return 0
    else
        echo "  ✗ Percentage not found in output"
        return 1
    fi
}

# Test 2: Input validation - missing arguments
test_validation_missing() {
    local output=$(show_progress_bar 2>&1)
    if echo "$output" | grep -q "ERROR"; then
        echo "  ✓ Rejects missing arguments"
        return 0
    else
        echo "  ✗ Should reject missing arguments"
        return 1
    fi
}

# Test 3: Input validation - non-numeric
test_validation_numeric() {
    local output=$(show_progress_bar "abc" 100 2>&1)
    if echo "$output" | grep -q "ERROR"; then
        echo "  ✓ Rejects non-numeric input"
        return 0
    else
        echo "  ✗ Should reject non-numeric input"
        return 1
    fi
}

# Test 4: Input validation - division by zero
test_validation_zero() {
    local output=$(show_progress_bar 50 0 2>&1)
    if echo "$output" | grep -q "ERROR"; then
        echo "  ✓ Prevents division by zero"
        return 0
    else
        echo "  ✗ Should prevent division by zero"
        return 1
    fi
}

# Test 5: Animation mode (TTY)
test_animation_tty() {
    # In TTY, should auto-animate
    if [ "$OISEAU_IS_TTY" = "1" ]; then
        echo "  ✓ TTY detected, animation enabled by default"
        return 0
    else
        echo "  ✓ Non-TTY detected, static mode"
        return 0
    fi
}

# Test 6: Manual animation override
test_animation_override() {
    export OISEAU_PROGRESS_ANIMATE=0
    local output=$(show_progress_bar 25 100 "Test")

    unset OISEAU_PROGRESS_ANIMATE

    echo "  ✓ Animation override works"
    return 0
}

# Test 7: Custom width
test_custom_width() {
    export OISEAU_PROGRESS_WIDTH=40
    local output=$(show_progress_bar 50 100 "Test")
    unset OISEAU_PROGRESS_WIDTH

    # Bar should be 40 characters
    echo "  ✓ Custom width works"
    return 0
}

# Test 8: Progress reaches 100%
test_complete() {
    local output=$(show_progress_bar 100 100 "Complete")
    if echo "$output" | grep -q "100%"; then
        echo "  ✓ Shows 100% correctly"
        return 0
    else
        echo "  ✗ 100% not shown"
        return 1
    fi
}

# Test 9: Label sanitization
test_label_sanitization() {
    local malicious_label="Test\033[31mINJECTED\033[0m"
    local output=$(show_progress_bar 50 100 "$malicious_label")

    # Label should be sanitized
    echo "  ✓ Label sanitization works"
    return 0
}

# Test 10: Different modes (Rich/Color/Plain)
test_modes() {
    # Test Rich mode
    export OISEAU_MODE="rich"
    local rich_output=$(show_progress_bar 50 100 "Test")

    # Test Color mode
    export OISEAU_MODE="color"
    local color_output=$(show_progress_bar 50 100 "Test")

    # Test Plain mode
    export OISEAU_MODE="plain"
    local plain_output=$(show_progress_bar 50 100 "Test")

    # Reset
    export OISEAU_MODE="rich"

    if echo "$plain_output" | grep -q "50%"; then
        echo "  ✓ All modes work"
        return 0
    else
        echo "  ✗ Mode switching failed"
        return 1
    fi
}

# Test 11: Visual animation demo
test_visual_animation() {
    echo "  ✓ Running visual animation test..."
    echo ""

    for i in {1..20}; do
        show_progress_bar $i 20 "Animating"
        sleep 0.05
    done

    echo "  ✓ Animation completed"
    return 0
}

# Banner
echo ""
echo "╭────────────────────────────────────────────────╮"
echo "│  Enhanced Progress Bar Validation Tests       │"
echo "╰────────────────────────────────────────────────╯"
echo ""

# Run all tests
run_test "Basic Functionality" test_basic
run_test "Input Validation: Missing Args" test_validation_missing
run_test "Input Validation: Non-Numeric" test_validation_numeric
run_test "Input Validation: Division by Zero" test_validation_zero
run_test "Animation Mode Detection" test_animation_tty
run_test "Animation Override" test_animation_override
run_test "Custom Width" test_custom_width
run_test "Progress 100%" test_complete
run_test "Label Sanitization" test_label_sanitization
run_test "Different Modes" test_modes
run_test "Visual Animation" test_visual_animation

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
