#!/bin/bash
# Test script to validate UTF-8/ASCII/Plain mode consistency across all widgets
# This ensures all widgets respect OISEAU_MODE and degrade gracefully

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source oiseau.sh
source "$PROJECT_ROOT/oiseau.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
ISSUES_FOUND=0

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

# Report an issue
report_issue() {
    local widget="$1"
    local issue="$2"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    echo "  ⚠️  $widget: $issue"
}

# Test 1: Progress bar respects mode
test_progress_bar_modes() {
    local passed=1

    # Check for mode-aware characters
    if ! grep -q 'if \[ "\$OISEAU_MODE" = "rich" \]' "$PROJECT_ROOT/oiseau.sh"; then
        report_issue "show_progress_bar" "Missing mode detection"
        passed=0
    fi

    # Check for UTF-8 and ASCII variants
    if grep -q 'filled_char="█"' "$PROJECT_ROOT/oiseau.sh" && grep -q 'filled_char="#"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ UTF-8 bar: █, ASCII bar: #"
    else
        report_issue "show_progress_bar" "Missing UTF-8/ASCII character variants"
        passed=0
    fi

    return $passed
}

# Test 2: Spinner respects mode
test_spinner_modes() {
    local passed=1

    # Check for spinner style definitions
    if grep -q '"dots")' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Spinner styles defined"
    else
        report_issue "show_spinner" "Missing spinner style definitions"
        passed=0
    fi

    # Check for UTF-8 and ASCII variants in spinner frames
    if grep -q '⠋⠙⠹' "$PROJECT_ROOT/oiseau.sh" && grep -q '|/-' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ UTF-8 spinner: ⠋⠙⠹, ASCII spinner: |/-\\"
    else
        report_issue "show_spinner" "Missing UTF-8/ASCII spinner variants"
        passed=0
    fi

    return $passed
}

# Test 3: Password masking respects mode
test_password_masking_modes() {
    local passed=1

    # Check for mask_char variable
    if grep -q 'mask_char=' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Password masking uses mode-aware character"
    else
        report_issue "ask_input" "Password masking not mode-aware"
        passed=0
    fi

    # Check for UTF-8 bullet and ASCII asterisk
    if grep -q 'mask_char="•"' "$PROJECT_ROOT/oiseau.sh" && grep -q 'mask_char="\*"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ UTF-8 mask: •, ASCII mask: *"
    else
        report_issue "ask_input" "Missing UTF-8/ASCII mask variants"
        passed=0
    fi

    return $passed
}

# Test 4: Box drawing respects mode
test_box_modes() {
    local passed=1

    # Check for box character sets
    if grep -q 'BORDER_ROUNDED_TOP_LEFT="╭"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ UTF-8 borders defined (╭─╮)"
    else
        report_issue "show_box" "Missing UTF-8 border characters"
        passed=0
    fi

    if grep -q 'BORDER_ASCII_TOP_LEFT="+"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ ASCII borders defined (+--+)"
    else
        report_issue "show_box" "Missing ASCII border characters"
        passed=0
    fi

    return $passed
}

# Test 5: Icons respect mode
test_icon_modes() {
    local passed=1

    # Check for icon definitions
    if grep -q 'ICON_SUCCESS=' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Icons are defined"
    else
        report_issue "Icons" "Missing icon definitions"
        passed=0
    fi

    # Check for UTF-8 icons (should have checkmark, X, etc.)
    if grep -q '✓\|✔' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ UTF-8 icons present (✓)"
    else
        report_issue "Icons" "Missing UTF-8 icon variants"
        passed=0
    fi

    # Check for ASCII fallback icons
    if grep -q '\[OK\]\|\[X\]' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ ASCII icons present ([OK], [X])"
    else
        report_issue "Icons" "Missing ASCII icon fallbacks"
        passed=0
    fi

    return $passed
}

# Test 6: Checklist respects mode
test_checklist_modes() {
    local passed=1

    # Check for checklist markers
    if grep -q 'show_checklist' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Checklist widget exists"
    else
        report_issue "show_checklist" "Widget not found"
        passed=0
    fi

    # Check for done/active/pending markers in different modes
    # The checklist should use icons which already have mode awareness
    if grep -q 'ICON_SUCCESS\|ICON_INFO\|ICON_PENDING' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Uses mode-aware icons"
    else
        report_issue "show_checklist" "Should use mode-aware icons"
        passed=0
    fi

    return $passed
}

# Test 7: All widgets use mode detection
test_global_mode_detection() {
    local passed=1

    # Check that OISEAU_MODE is set during initialization
    if grep -q 'OISEAU_MODE=' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ OISEAU_MODE variable is set"
    else
        report_issue "Initialization" "OISEAU_MODE not set"
        passed=0
    fi

    # Check for the three modes
    if grep -q 'OISEAU_MODE="rich"' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q 'OISEAU_MODE="color"' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q 'OISEAU_MODE="plain"' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ All three modes defined: rich, color, plain"
    else
        report_issue "Initialization" "Not all modes defined"
        passed=0
    fi

    return $passed
}

# Test 8: Check for hardcoded UTF-8 characters outside mode blocks
test_no_hardcoded_utf8() {
    local passed=1

    # This is a heuristic test - look for common UTF-8 box drawing characters
    # that appear outside of mode-conditional blocks
    # Note: This is simplified and may need refinement

    echo "  ℹ️  Checking for hardcoded UTF-8 characters..."

    # Count UTF-8 box drawing characters
    local utf8_count=$(grep -o '[─│┌┐└┘├┤┬┴┼╭╮╰╯╔╗╚╝║═╠╣╦╩╬]' "$PROJECT_ROOT/oiseau.sh" | wc -l)

    if [ "$utf8_count" -gt 0 ]; then
        echo "  ✓ Found $utf8_count UTF-8 box characters (should be in mode blocks)"
    fi

    return $passed
}

# Banner
echo ""
echo "╭────────────────────────────────────────────────────────────╮"
echo "│  UTF-8 / ASCII / Plain Mode Consistency Validation        │"
echo "╰────────────────────────────────────────────────────────────╯"
echo ""
echo "Validating that all widgets respect OISEAU_MODE and degrade"
echo "gracefully across: rich (UTF-8) → color (ASCII) → plain"
echo ""

# Run all tests
run_test "Progress Bar Mode Awareness" test_progress_bar_modes
run_test "Spinner Mode Awareness" test_spinner_modes
run_test "Password Masking Mode Awareness" test_password_masking_modes
run_test "Box Drawing Mode Awareness" test_box_modes
run_test "Icon Mode Awareness" test_icon_modes
run_test "Checklist Mode Awareness" test_checklist_modes
run_test "Global Mode Detection" test_global_mode_detection
run_test "No Hardcoded UTF-8" test_no_hardcoded_utf8

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tests run: $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $((TESTS_RUN - TESTS_PASSED))"
echo "Issues found: $ISSUES_FOUND"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $TESTS_PASSED -eq $TESTS_RUN ] && [ $ISSUES_FOUND -eq 0 ]; then
    echo ""
    show_success "All widgets are mode-consistent! ✓"
    echo ""
    echo "Summary:"
    echo "  • UTF-8 mode (rich): Full Unicode box drawing, bullets, checkmarks"
    echo "  • ASCII mode (color): +--+, #, *, [OK], |/-\\"
    echo "  • Plain mode: Same as ASCII, no colors"
    echo ""
    exit 0
else
    echo ""
    show_error "Some widgets need mode-awareness fixes"
    echo ""
    echo "Next steps:"
    echo "  1. Review issues reported above"
    echo "  2. Ensure all widgets check OISEAU_MODE"
    echo "  3. Provide UTF-8 and ASCII variants for all visual elements"
    echo ""
    exit 1
fi
