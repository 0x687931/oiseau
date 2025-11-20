# BATS Interactive Component Tests

This directory contains BATS (Bash Automated Testing System) tests for oiseau's interactive UI components.

## Overview

These tests address [Issue #69](https://github.com/0x687931/oiseau/issues/69) by providing comprehensive test coverage for interactive components like `ask_list()`, `ask_choice()`, and related functionality.

## Test Structure

```
tests/bats/
├── README.md                    # This file
├── test_interactive.bats        # Main test suite for interactive components
└── helpers/
    ├── key_simulator.bash       # Key press simulation utilities
    └── mock_terminal.bash       # Terminal mocking utilities
```

## Running Tests

### Run all BATS tests

```bash
bats tests/bats/test_interactive.bats
```

### Run specific test

```bash
bats tests/bats/test_interactive.bats --filter "ask_list function exists"
```

### Run with verbose output

```bash
bats tests/bats/test_interactive.bats --verbose
```

## Test Coverage

### Current Coverage (22 tests)

#### Function Existence & Validation
- ✅ `ask_list` function exists
- ✅ `ask_list` rejects missing arguments
- ✅ `ask_list` rejects empty array
- ✅ `ask_list` rejects invalid mode
- ✅ `ask_choice` function exists
- ✅ `ask_choice` rejects missing arguments

#### Non-TTY Fallback
- ✅ `ask_list` works in non-TTY mode (single selection)
- ✅ `ask_choice` works in non-TTY mode

#### Edge Cases
- ✅ Single item lists
- ✅ Items with special characters
- ✅ Items with emojis (📁 🌿 🎉)
- ✅ Very long item names
- ✅ Empty prompts

#### Multi-Select Mode
- ✅ Multi-select mode support

#### Rendering & Display
- ✅ ANSI codes respect OISEAU_MODE=plain
- ✅ Rich mode configuration
- ✅ Emoji width calculation (`_display_width`)
- ✅ Text padding (`_pad_to_width`)

#### Integration
- ✅ Integration with `show_box`
- ✅ Multiple sequential calls

### Future Test Additions

The following areas still need interactive key press testing (requires pseudo-TTY):

- [ ] Arrow key navigation (↑↓)
- [ ] Vim-style navigation (j/k)
- [ ] Space key for multi-select toggle
- [ ] Enter key for selection
- [ ] Esc/q for cancellation
- [ ] Cursor wrapping at list boundaries
- [ ] Screen re-rendering on terminal resize

## Helper Libraries

### key_simulator.bash

Provides utilities for simulating terminal input:

- `simulate_keys()` - Generate key sequences (arrow keys, enter, etc.)
- `interactive_test()` - Run commands with simulated input
- `force_tty_mode()` / `force_non_tty_mode()` - Control TTY detection

### mock_terminal.bash

Provides utilities for mocking terminal environment:

- `mock_terminal_size()` - Set terminal dimensions
- `strip_ansi()` - Remove ANSI escape codes
- `capture_output()` - Capture command output
- `get_line()` / `count_lines()` - Parse output

## Writing New Tests

### Basic Test Structure

```bash
@test "descriptive test name" {
    force_non_tty_mode  # Or force_tty_mode

    run bash -c 'source "$1/oiseau.sh" && \
                 export OISEAU_IS_TTY=0 && \
                 items=("A" "B" "C") && \
                 echo "1" | ask_list "Choose:" items "single"' _ "$PROJECT_ROOT"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "expected pattern" ]]
}
```

### Testing Interactive Components

For true interactive testing (arrow keys, etc.), you'll need a pseudo-TTY:

```bash
@test "arrow key navigation works" {
    # Use expect or similar tool for pseudo-TTY
    # This is a future enhancement
    skip "Requires pseudo-TTY implementation"
}
```

## Dependencies

- **BATS** (Bash Automated Testing System)
  - Install: `brew install bats-core` (macOS)
  - Or: `npm install -g bats` (cross-platform)

## Related Documentation

- [Issue #69 - Add comprehensive UI/UX tests](https://github.com/0x687931/oiseau/issues/69)
- [BATS Documentation](https://bats-core.readthedocs.io/)
- [oiseau.sh Main Library](../../oiseau.sh)

## Contributing

When adding new interactive components:

1. Add corresponding BATS tests
2. Test both TTY and non-TTY modes
3. Test edge cases (empty input, long strings, emoji, etc.)
4. Document any helper functions in this README

## Notes

- These tests focus on **non-interactive** testing (validation, fallback modes, edge cases)
- **Interactive key press testing** (arrow keys, etc.) requires pseudo-TTY setup
- Current tests achieve good coverage of function logic and validation
- Future work: Add expect-based interactive tests for key press scenarios
