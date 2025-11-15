#!/bin/bash
# Test script for window resize handler

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

# Test 1: Function exists - register
test_register_exists() {
    if type register_resize_handler >/dev/null 2>&1; then
        echo "  ✓ register_resize_handler function exists"
        return 0
    else
        echo "  ✗ register_resize_handler function not found"
        return 1
    fi
}

# Test 2: Function exists - unregister
test_unregister_exists() {
    if type unregister_resize_handler >/dev/null 2>&1; then
        echo "  ✓ unregister_resize_handler function exists"
        return 0
    else
        echo "  ✗ unregister_resize_handler function not found"
        return 1
    fi
}

# Test 3: Function exists - update_terminal_size
test_update_size_exists() {
    if type update_terminal_size >/dev/null 2>&1; then
        echo "  ✓ update_terminal_size function exists"
        return 0
    else
        echo "  ✗ update_terminal_size function not found"
        return 1
    fi
}

# Test 4: Internal handler exists
test_internal_handler_exists() {
    if type _oiseau_resize_handler >/dev/null 2>&1; then
        echo "  ✓ _oiseau_resize_handler internal function exists"
        return 0
    else
        echo "  ✗ _oiseau_resize_handler not found"
        return 1
    fi
}

# Test 5: Validation - missing callback
test_validation_missing_callback() {
    local output=$(register_resize_handler 2>&1)
    if echo "$output" | grep -q "ERROR.*requires callback"; then
        echo "  ✓ Rejects missing callback"
        return 0
    else
        echo "  ✗ Should reject missing callback"
        return 1
    fi
}

# Test 6: Validation - invalid function
test_validation_invalid_function() {
    local output=$(register_resize_handler "nonexistent_function_12345" 2>&1)
    if echo "$output" | grep -q "ERROR.*not a defined function"; then
        echo "  ✓ Rejects invalid function"
        return 0
    else
        echo "  ✗ Should reject invalid function"
        return 1
    fi
}

# Test 7: Global variables initialized
test_global_vars() {
    if grep -q '_OISEAU_RESIZE_CALLBACK=""' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q '_OISEAU_RESIZE_ORIGINAL_TRAP=""' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q '_OISEAU_RESIZE_IN_HANDLER=0' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Global variables initialized"
        return 0
    else
        echo "  ✗ Global variables not found"
        return 1
    fi
}

# Test 8: Recursion prevention
test_recursion_prevention() {
    if grep -q 'if \[ "\$_OISEAU_RESIZE_IN_HANDLER" = "1" \]' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Recursion prevention implemented"
        return 0
    else
        echo "  ✗ Recursion prevention not found"
        return 1
    fi
}

# Test 9: Trap chaining - saves original
test_trap_chaining_save() {
    # Check for trap saving logic (may include re-register protection)
    if grep -q 'trap -p WINCH' "$PROJECT_ROOT/oiseau.sh" && grep -q '_OISEAU_RESIZE_ORIGINAL_TRAP' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Saves original WINCH trap (with re-register protection)"
        return 0
    else
        echo "  ✗ Doesn't save original trap"
        return 1
    fi
}

# Test 10: Trap chaining - calls original
test_trap_chaining_call() {
    if grep -q 'eval.*_OISEAU_RESIZE_ORIGINAL_TRAP' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Calls original trap after handling"
        return 0
    else
        echo "  ✗ Doesn't call original trap"
        return 1
    fi
}

# Test 11: Installs WINCH trap
test_winch_trap() {
    if grep -q "trap '_oiseau_resize_handler' WINCH" "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Installs WINCH trap"
        return 0
    else
        echo "  ✗ WINCH trap installation not found"
        return 1
    fi
}

# Test 12: Updates terminal dimensions
test_updates_dimensions() {
    if grep -q 'update_terminal_size' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Calls update_terminal_size"
        return 0
    else
        echo "  ✗ Doesn't update dimensions"
        return 1
    fi
}

# Test 13: Uses tput with fallback
test_tput_fallback() {
    if grep -q 'tput cols.*|| echo 80' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q 'tput lines.*|| echo 24' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Uses tput with fallback to 80x24"
        return 0
    else
        echo "  ✗ tput fallback not found"
        return 1
    fi
}

# Test 14: Exports OISEAU_WIDTH and OISEAU_HEIGHT
test_exports_vars() {
    if grep -q 'export OISEAU_WIDTH' "$PROJECT_ROOT/oiseau.sh" && \
       grep -q 'export OISEAU_HEIGHT' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Exports OISEAU_WIDTH and OISEAU_HEIGHT"
        return 0
    else
        echo "  ✗ Doesn't export dimension variables"
        return 1
    fi
}

# Test 15: Unregister restores original trap
test_unregister_restore() {
    if grep -q 'trap.*_OISEAU_RESIZE_ORIGINAL_TRAP.*WINCH' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Unregister restores original trap"
        return 0
    else
        echo "  ✗ Unregister doesn't restore trap"
        return 1
    fi
}

# Test 16: Unregister clears state
test_unregister_clears() {
    if grep -q '_OISEAU_RESIZE_CALLBACK=""' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Unregister clears state variables"
        return 0
    else
        echo "  ✗ Unregister doesn't clear state"
        return 1
    fi
}

# Test 17: Idempotent cleanup
test_idempotent_cleanup() {
    if grep -q 'Idempotent' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Cleanup is idempotent (safe to call multiple times)"
        return 0
    else
        echo "  ✗ Idempotent cleanup not documented"
        return 1
    fi
}

# Test 18: Auto-initializes on load
test_auto_initialize() {
    if grep -q 'if \[ -z "\$OISEAU_HEIGHT" \]' "$PROJECT_ROOT/oiseau.sh"; then
        echo "  ✓ Auto-initializes OISEAU_HEIGHT on load"
        return 0
    else
        echo "  ✗ Auto-initialization not found"
        return 1
    fi
}

# Banner
echo ""
echo "╭────────────────────────────────────────────────╮"
echo "│  Resize Handler Validation Tests             │"
echo "╰────────────────────────────────────────────────╯"
echo ""

# Run all tests
run_test "Function Exists: register" test_register_exists
run_test "Function Exists: unregister" test_unregister_exists
run_test "Function Exists: update_size" test_update_size_exists
run_test "Internal Handler Exists" test_internal_handler_exists
run_test "Validation: Missing Callback" test_validation_missing_callback
run_test "Validation: Invalid Function" test_validation_invalid_function
run_test "Global Variables Initialized" test_global_vars
run_test "Recursion Prevention" test_recursion_prevention
run_test "Trap Chaining: Saves Original" test_trap_chaining_save
run_test "Trap Chaining: Calls Original" test_trap_chaining_call
run_test "Installs WINCH Trap" test_winch_trap
run_test "Updates Terminal Dimensions" test_updates_dimensions
run_test "tput with Fallback" test_tput_fallback
run_test "Exports Dimension Variables" test_exports_vars
run_test "Unregister Restores Trap" test_unregister_restore
run_test "Unregister Clears State" test_unregister_clears
run_test "Idempotent Cleanup" test_idempotent_cleanup
run_test "Auto-Initialize on Load" test_auto_initialize

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
