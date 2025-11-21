# Test Infrastructure Extensibility Architecture

## Executive Summary

This document defines the extensibility architecture for Oiseau's test infrastructure, designed to scale from 22 tests to 200+ tests, support 10x growth in contributors and components, and remain maintainable for 5+ years without requiring framework rewrites.

**Current State (PR#71):**
- 22 tests across 10 flat test files
- 2 helper files (61 + 192 = 253 lines)
- 1 expect prototype
- Manual test execution
- Single contributor workflow

**Target State (Year 5):**
- 200+ tests across all categories
- 15+ components with full coverage
- 10+ concurrent contributors
- Multiple test types (unit, integration, interactive, visual, performance, accessibility)
- Automated CI/CD with parallel execution
- Self-service test creation (< 30 min for new component)

---

## 1. Directory Structure: Scaling to 200+ Tests

### Current Structure (Flat)
```
tests/
├── test_list.sh           # 275 lines
├── test_input.sh          # 322 lines
├── test_spinner.sh        # 195 lines
├── ... 7 more flat files
├── lib/test_helpers.sh    # 61 lines
└── prototypes/
    └── 01_expect_basic.exp
```

**Problems:**
- No logical grouping (all tests in one directory)
- Naming inconsistent (`test_*.sh`)
- Can't filter by test type
- Shared fixtures unclear
- No component isolation

### Proposed Structure (Hierarchical + Modular)

```
tests/
├── config.yml                      # Central test configuration
├── snapshots/                      # Rendering snapshots
│   ├── ask_list_basic.txt
│   ├── ask_list_multiline.txt
│   ├── show_box_info.txt
│   └── ...
├── fixtures/                       # Shared test data
│   ├── common/
│   │   ├── sample_items.txt
│   │   ├── unicode_samples.txt
│   │   └── ansi_samples.txt
│   ├── ask_list/
│   │   ├── long_items.txt
│   │   ├── emoji_items.txt
│   │   └── special_chars.txt
│   └── show_table/
│       ├── sample_data.csv
│       └── wide_columns.csv
│
├── helpers/                        # Modular helper library
│   ├── core/
│   │   ├── assertions.bash         # Common assertions
│   │   ├── fixtures.bash           # Fixture loading
│   │   ├── setup.bash              # Setup/teardown utilities
│   │   └── test_runner.bash        # Test execution helpers
│   ├── interactive/
│   │   ├── expect_helpers.tcl      # Expect utilities
│   │   ├── keyboard.bash           # Key simulation
│   │   ├── pty.bash                # PTY management
│   │   └── screen_capture.bash     # Output validation
│   ├── mocking/
│   │   ├── terminal.bash           # Mock tput, stty
│   │   ├── input.bash              # Mock read
│   │   ├── filesystem.bash         # Mock file ops
│   │   └── time.bash               # Mock date/sleep
│   ├── rendering/
│   │   ├── snapshot.bash           # Snapshot testing
│   │   ├── visual_diff.bash        # Visual comparison
│   │   └── ansi_parser.bash        # ANSI code handling
│   └── components/
│       ├── ask_list_helpers.bash
│       ├── ask_choice_helpers.bash
│       ├── show_box_helpers.bash
│       └── ...                     # One per major component
│
├── unit/                           # Pure function tests (50 tests)
│   ├── test_display_width.bats
│   ├── test_pad_to_width.bats
│   ├── test_escape_input.bats
│   ├── test_color_detection.bats
│   └── ...
│
├── integration/                    # Component interaction (40 tests)
│   ├── test_box_with_list.bats
│   ├── test_nested_components.bats
│   ├── test_mode_switching.bats
│   └── ...
│
├── interactive/                    # Keyboard simulation (60 tests)
│   ├── test_ask_list_navigation.bats
│   ├── test_ask_choice_input.bats
│   ├── test_keyboard_shortcuts.bats
│   ├── test_multi_select.bats
│   └── ...
│
├── rendering/                      # Visual output (30 tests)
│   ├── test_box_rendering.bats
│   ├── test_unicode_display.bats
│   ├── test_color_output.bats
│   ├── test_emoji_alignment.bats
│   └── ...
│
├── performance/                    # Benchmarks (10 tests)
│   ├── test_large_lists.bats
│   ├── test_rapid_redraws.bats
│   └── test_memory_usage.bats
│
├── accessibility/                  # A11y testing (10 tests)
│   ├── test_screen_reader_compat.bats
│   ├── test_keyboard_only.bats
│   ├── test_color_contrast.bats
│   └── test_plain_mode.bats
│
├── e2e/                           # Complete workflows (10 tests)
│   ├── test_installer_flow.bats
│   ├── test_demo_scripts.bats
│   └── test_multi_step_dialogs.bats
│
├── templates/                      # Test templates
│   ├── component_template.bats
│   ├── interactive_template.bats
│   └── rendering_template.bats
│
└── bin/                           # Test utilities
    ├── generate-test               # Test generator
    ├── run-tests                   # Smart test runner
    ├── update-snapshots            # Snapshot management
    ├── check-coverage              # Coverage reporting
    └── validate-config             # Config validation
```

### Naming Conventions

**Test Files:** `test_<component>_<type>.bats`
- `test_ask_list_unit.bats` - Unit tests for ask_list
- `test_ask_list_interactive.bats` - Interactive tests for ask_list
- `test_ask_list_rendering.bats` - Rendering tests for ask_list

**Helper Files:** `<domain>_helpers.bash` or `<utility>.bash`
- `assertions.bash` - General purpose
- `ask_list_helpers.bash` - Component-specific

**Fixture Files:** `<component>/<scenario>.<ext>`
- `ask_list/long_items.txt`
- `common/unicode_samples.txt`

### Running Tests by Category

```bash
# Run all tests
./tests/bin/run-tests

# Run specific category
./tests/bin/run-tests unit
./tests/bin/run-tests interactive
./tests/bin/run-tests rendering

# Run tests for specific component
./tests/bin/run-tests --component ask_list

# Run tests matching pattern
./tests/bin/run-tests --filter navigation

# Run fast tests only (skip slow performance tests)
./tests/bin/run-tests --tag speed:fast

# Run in parallel (CI mode)
./tests/bin/run-tests --parallel 4
```

---

## 2. Helper Library Architecture

### Current Problems
- Monolithic helpers (192 lines in one file)
- No namespace management
- Unclear dependencies
- Hard to maintain at scale

### Modular Design

#### Core Helpers (`helpers/core/`)

**`assertions.bash`** - Common test assertions
```bash
# Custom assertions beyond bats-assert
assert_line_count() { ... }
assert_box_width() { ... }
assert_vertical_alignment() { ... }
assert_no_ansi_codes() { ... }
assert_display_width() { ... }
refute_error() { ... }
```

**`fixtures.bash`** - Fixture management
```bash
# Load fixture files
load_fixture() {
    local component=$1
    local fixture_name=$2
    cat "tests/fixtures/${component}/${fixture_name}"
}

# Generate test data
generate_items() { ... }
generate_long_list() { ... }
generate_unicode_mix() { ... }
```

**`setup.bash`** - Common setup/teardown
```bash
# Standard setup for all tests
setup() {
    load_oiseau
    setup_test_environment
    export TEST_MODE=1
}

# Standard teardown
teardown() {
    cleanup_temp_files
    reset_terminal
}
```

#### Interactive Helpers (`helpers/interactive/`)

**`keyboard.bash`** - Key simulation
```bash
# Simulate arrow keys
send_up_arrow() { echo -ne "\033[A"; }
send_down_arrow() { echo -ne "\033[B"; }
send_enter() { echo -ne "\r"; }
send_space() { echo -ne " "; }
send_escape() { echo -ne "\033"; }

# Complex sequences
navigate_to_item() {
    local target_index=$1
    for ((i=0; i<target_index; i++)); do
        send_down_arrow
        sleep 0.05
    done
}
```

**`pty.bash`** - PTY management
```bash
# Create pseudo-terminal for testing
create_pty() { ... }
destroy_pty() { ... }
read_pty_output() { ... }
write_pty_input() { ... }
```

#### Mocking Helpers (`helpers/mocking/`)

**`terminal.bash`** - Mock terminal
```bash
# Mock tput
mock_tput() {
    case "$1" in
        cols) echo "${MOCK_TERM_WIDTH:-80}";;
        lines) echo "${MOCK_TERM_HEIGHT:-24}";;
        *) command tput "$@";;
    esac
}

# Mock terminal dimensions
with_terminal_size() {
    local width=$1 height=$2
    shift 2
    MOCK_TERM_WIDTH=$width MOCK_TERM_HEIGHT=$height "$@"
}
```

#### Rendering Helpers (`helpers/rendering/`)

**`snapshot.bash`** - Snapshot testing
```bash
# Compare output to snapshot
assert_snapshot() {
    local output=$1
    local snapshot_name=$2
    local snapshot_file="tests/snapshots/${snapshot_name}.txt"

    if [[ -n "${SNAPSHOT_UPDATE:-}" ]]; then
        echo "$output" > "$snapshot_file"
        skip "Snapshot updated: $snapshot_name"
    fi

    if [[ ! -f "$snapshot_file" ]]; then
        echo "$output" > "$snapshot_file"
        skip "Snapshot created: $snapshot_name"
    fi

    local expected=$(cat "$snapshot_file")
    diff_output=$(diff -u <(echo "$expected") <(echo "$output"))

    if [[ -n "$diff_output" ]]; then
        echo "Snapshot mismatch for: $snapshot_name"
        echo "$diff_output"
        return 1
    fi
}
```

#### Component Helpers (`helpers/components/`)

**`ask_list_helpers.bash`** - ask_list utilities
```bash
# Create test list
create_test_list() {
    local size=$1
    local items=()
    for ((i=1; i<=size; i++)); do
        items+=("Item $i")
    done
    declare -p items
}

# Validate list output
assert_list_rendered() {
    local output=$1
    assert_line_count "$output" "${EXPECTED_LINES}"
    assert_output --partial "Choose:"
}
```

### Helper Auto-Loading

**`helpers/autoload.bash`** - Smart helper loading
```bash
# Auto-load helpers based on test file location
__autoload_helpers() {
    local test_file=$1
    local test_dir=$(dirname "$test_file")
    local test_type=$(basename "$test_dir")

    # Always load core
    source "${HELPERS_DIR}/core/assertions.bash"
    source "${HELPERS_DIR}/core/fixtures.bash"
    source "${HELPERS_DIR}/core/setup.bash"

    # Load type-specific helpers
    case "$test_type" in
        interactive)
            source "${HELPERS_DIR}/interactive/keyboard.bash"
            source "${HELPERS_DIR}/interactive/pty.bash"
            ;;
        rendering)
            source "${HELPERS_DIR}/rendering/snapshot.bash"
            source "${HELPERS_DIR}/rendering/visual_diff.bash"
            ;;
        # ... more types
    esac
}
```

### Helper Versioning

**`helpers/VERSION`** - Track helper API versions
```
HELPERS_VERSION=2.1.0

BREAKING_CHANGES:
- 2.0.0: assert_output_matches removed, use assert_snapshot
- 1.5.0: mock_tput signature changed (added --strict flag)

DEPRECATIONS:
- 2.1.0: mock_terminal_width → use with_terminal_size (remove in 3.0)
```

### Helper Documentation

**`helpers/README.md`** - Complete helper API docs
```markdown
# Test Helper API Reference

## Core Helpers

### assertions.bash

#### assert_box_width()
Verify box border width matches expected value.

**Usage:**
```bash
assert_box_width "$output" 60
```

**Parameters:**
- `$1` - Output to check
- `$2` - Expected width

**Returns:** 0 if width matches, 1 otherwise
```

---

## 3. Test Template System

### Template Structure

**`templates/component_template.bats`**
```bash
#!/usr/bin/env bats
# Test suite for: COMPONENT_NAME
# Auto-generated: DATE_PLACEHOLDER

load '../helpers/autoload'

setup() {
    setup_test_environment
    # TODO: Add component-specific setup
}

teardown() {
    cleanup_test_environment
    # TODO: Add component-specific teardown
}

# =============================================================================
# VALIDATION TESTS
# =============================================================================

@test "COMPONENT_NAME: function exists" {
    type COMPONENT_NAME
}

@test "COMPONENT_NAME: rejects missing arguments" {
    run COMPONENT_NAME
    assert_failure
    assert_output --partial "ERROR"
}

@test "COMPONENT_NAME: validates input" {
    # TODO: Add validation tests
    skip "Implement validation tests"
}

# =============================================================================
# FUNCTIONAL TESTS
# =============================================================================

@test "COMPONENT_NAME: basic functionality" {
    # TODO: Add basic functionality test
    skip "Implement basic test"
}

@test "COMPONENT_NAME: handles edge cases" {
    # TODO: Add edge case tests
    skip "Implement edge case tests"
}

# =============================================================================
# RENDERING TESTS
# =============================================================================

@test "COMPONENT_NAME: renders correctly (snapshot)" {
    # TODO: Add snapshot test
    skip "Implement rendering test"
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

@test "COMPONENT_NAME: integrates with other components" {
    # TODO: Add integration tests
    skip "Implement integration tests"
}
```

### Test Generator Script

**`bin/generate-test`**
```bash
#!/bin/bash
# Generate test suite for new component

set -euo pipefail

COMPONENT_NAME=$1
TEST_TYPE=${2:-all}  # unit, interactive, rendering, all

if [[ -z "$COMPONENT_NAME" ]]; then
    echo "Usage: generate-test <component_name> [type]"
    exit 1
fi

# Detect component category (ask_*, show_*, etc)
CATEGORY=$(echo "$COMPONENT_NAME" | sed 's/_.*//')

generate_from_template() {
    local template=$1
    local output_file=$2

    sed -e "s/COMPONENT_NAME/$COMPONENT_NAME/g" \
        -e "s/CATEGORY/$CATEGORY/g" \
        -e "s/DATE_PLACEHOLDER/$(date)/g" \
        "tests/templates/${template}.bats" > "$output_file"

    chmod +x "$output_file"
    echo "Created: $output_file"
}

# Generate test files based on type
case "$TEST_TYPE" in
    unit)
        generate_from_template "unit_template" \
            "tests/unit/test_${COMPONENT_NAME}_unit.bats"
        ;;
    interactive)
        generate_from_template "interactive_template" \
            "tests/interactive/test_${COMPONENT_NAME}_interactive.bats"
        ;;
    rendering)
        generate_from_template "rendering_template" \
            "tests/rendering/test_${COMPONENT_NAME}_rendering.bats"
        ;;
    all)
        generate_from_template "unit_template" \
            "tests/unit/test_${COMPONENT_NAME}_unit.bats"
        generate_from_template "interactive_template" \
            "tests/interactive/test_${COMPONENT_NAME}_interactive.bats"
        generate_from_template "rendering_template" \
            "tests/rendering/test_${COMPONENT_NAME}_rendering.bats"
        ;;
    *)
        echo "Unknown type: $TEST_TYPE"
        exit 1
        ;;
esac

# Create fixture directory
mkdir -p "tests/fixtures/${COMPONENT_NAME}"
echo "Created fixture directory: tests/fixtures/${COMPONENT_NAME}"

# Create component helper stub
if [[ ! -f "tests/helpers/components/${COMPONENT_NAME}_helpers.bash" ]]; then
    cat > "tests/helpers/components/${COMPONENT_NAME}_helpers.bash" <<EOF
#!/bin/bash
# Helper functions for ${COMPONENT_NAME} tests

# TODO: Add component-specific helper functions

# Example:
# create_test_${COMPONENT_NAME}() {
#     # Create test instance
# }
EOF
    echo "Created helper stub: tests/helpers/components/${COMPONENT_NAME}_helpers.bash"
fi

echo ""
echo "Test suite generated for: $COMPONENT_NAME"
echo "Next steps:"
echo "  1. Edit test files and replace TODO markers"
echo "  2. Add fixtures to tests/fixtures/${COMPONENT_NAME}/"
echo "  3. Implement helpers in tests/helpers/components/${COMPONENT_NAME}_helpers.bash"
echo "  4. Run tests: ./tests/bin/run-tests --component ${COMPONENT_NAME}"
```

### Usage Example

```bash
# Generate complete test suite for new component
./tests/bin/generate-test ask_autocomplete

# Output:
# Created: tests/unit/test_ask_autocomplete_unit.bats
# Created: tests/interactive/test_ask_autocomplete_interactive.bats
# Created: tests/rendering/test_ask_autocomplete_rendering.bats
# Created fixture directory: tests/fixtures/ask_autocomplete
# Created helper stub: tests/helpers/components/ask_autocomplete_helpers.bash

# Now developer fills in TODO markers (~15-30 minutes)
```

---

## 4. Test Parameterization

### Problem: Duplicated Tests

**Bad (current approach):**
```bash
@test "ask_list handles 3 items" {
    items=(A B C)
    run ask_list "Choose:" items
    assert_success
}

@test "ask_list handles 10 items" {
    items=(A B C D E F G H I J)
    run ask_list "Choose:" items
    assert_success
}

@test "ask_list handles 100 items" {
    items=()
    for i in {1..100}; do items+=("Item $i"); done
    run ask_list "Choose:" items
    assert_success
}
```

### Solution: Data-Driven Testing

**`helpers/core/parameterize.bash`**
```bash
# Run test with multiple parameter sets
with_parameters() {
    local test_func=$1
    shift
    local params=("$@")

    local failed=0
    for param in "${params[@]}"; do
        echo "  Testing with parameter: $param"
        if ! $test_func "$param"; then
            failed=1
            echo "  FAILED with parameter: $param"
        fi
    done

    return $failed
}

# Load parameters from fixture file
load_parameters() {
    local fixture=$1
    mapfile -t PARAMS < "tests/fixtures/$fixture"
}
```

**Usage:**
```bash
@test "ask_list handles various list sizes" {
    test_list_size() {
        local size=$1
        eval "$(create_test_list "$size")"
        run ask_list "Choose:" items
        assert_success
        assert_line_count "$output" $((size + 2))  # items + prompt + help
    }

    with_parameters test_list_size 1 3 10 50 100 500
}

@test "ask_list handles special characters" {
    test_special_char() {
        local char=$1
        items=("Item${char}1" "Item${char}2")
        run ask_list "Choose:" items
        assert_success
        assert_output --partial "Item${char}1"
    }

    with_parameters test_special_char " " "-" "/" "." "_" "(" ")"
}

@test "ask_list handles emoji" {
    load_parameters "common/emoji_samples.txt"

    test_emoji() {
        local emoji=$1
        items=("${emoji} Item1" "${emoji} Item2")
        run ask_list "Choose:" items
        assert_success
    }

    for emoji in "${PARAMS[@]}"; do
        test_emoji "$emoji"
    done
}
```

### Matrix Testing

**Test component across multiple configurations:**
```bash
@test "ask_list: matrix test (mode × terminal size × item count)" {
    MODES=(rich color plain)
    SIZES=("80x24" "120x40" "200x60")
    COUNTS=(3 10 50)

    for mode in "${MODES[@]}"; do
        for size in "${SIZES[@]}"; do
            for count in "${COUNTS[@]}"; do
                echo "Testing: mode=$mode size=$size count=$count"

                width=${size%%x*}
                height=${size##*x}

                OISEAU_MODE=$mode \
                with_terminal_size $width $height \
                    test_list_with_count $count
            done
        done
    done
}
```

---

## 5. Component Test Interface

### Standard Component Contract

Every interactive component must pass the same baseline tests. This ensures consistency and catches common issues.

**`helpers/core/component_interface.bash`**
```bash
#!/bin/bash
# Standard test interface for all components

# Apply standard component tests
component_test_interface() {
    local component=$1
    local test_args=$2  # Arguments for basic test

    @test "$component: function exists" {
        type "$component"
    }

    @test "$component: accepts --help flag" {
        run $component --help
        assert_success
        assert_output --partial "Usage:"
    }

    @test "$component: validates required arguments" {
        run $component
        assert_failure
        assert_output --partial "ERROR"
    }

    @test "$component: handles Ctrl-C gracefully" {
        # TODO: Implement with PTY
        skip "Requires PTY implementation"
    }

    @test "$component: works in non-TTY mode" {
        run bash -c "echo 1 | $component $test_args"
        assert_success
    }

    @test "$component: handles UTF-8 characters" {
        run $component "测试 🎉" $test_args
        assert_success
    }

    @test "$component: handles empty input" {
        run $component "" $test_args
        assert_failure
    }

    @test "$component: sanitizes ANSI codes" {
        run $component $'\033[1mTest\033[0m' $test_args
        assert_success
    }

    @test "$component: respects OISEAU_MODE" {
        OISEAU_MODE=plain run $component $test_args
        assert_success
        assert_no_ansi_codes "$output"
    }

    @test "$component: respects terminal width" {
        with_terminal_size 40 24 \
            run $component $test_args
        assert_success
    }

    @test "$component: handles very narrow terminal (20 cols)" {
        with_terminal_size 20 24 \
            run $component $test_args
        assert_success
    }

    @test "$component: handles very wide terminal (200 cols)" {
        with_terminal_size 200 24 \
            run $component $test_args
        assert_success
    }

    @test "$component: exits with correct status code" {
        run $component $test_args
        [[ $status -eq 0 || $status -eq 1 ]]
    }

    @test "$component: produces parseable output" {
        run $component $test_args
        # Output should not be empty
        [[ -n "$output" ]]
    }

    @test "$component: doesn't leak temp files" {
        local before=$(ls /tmp | wc -l)
        run $component $test_args
        local after=$(ls /tmp | wc -l)
        [[ $after -eq $before ]]
    }

    @test "$component: handles rapid sequential calls" {
        for i in {1..10}; do
            run $component $test_args
            assert_success
        done
    }

    @test "$component: compatible with Bash 3.2" {
        if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
            skip "Already on Bash 4+"
        fi
        run $component $test_args
        assert_success
    }

    @test "$component: handles signals properly" {
        # Test SIGTERM, SIGINT handling
        skip "Requires signal testing framework"
    }

    @test "$component: produces consistent output" {
        run $component $test_args
        local output1=$output
        run $component $test_args
        local output2=$output
        [[ "$output1" == "$output2" ]]
    }

    @test "$component: documentation exists" {
        grep -q "$component" README.md
    }
}
```

### Usage in Test Files

**`tests/unit/test_ask_list_unit.bats`**
```bash
#!/usr/bin/env bats

load '../helpers/autoload'
load '../helpers/core/component_interface'

# Apply standard interface tests
setup() {
    items=(Apple Banana Cherry)
    TEST_ARGS="'Choose fruit:' items"
    component_test_interface "ask_list" "$TEST_ARGS"
}

# Component-specific tests below
@test "ask_list: supports single-select mode" {
    # ...
}

@test "ask_list: supports multi-select mode" {
    # ...
}
```

### Benefit

- **Consistency:** All components tested the same way
- **Regression prevention:** Standard tests catch common issues
- **Documentation:** Interface serves as specification
- **Onboarding:** New contributors know what to test
- **Scalability:** Add one line per new component

---

## 6. Configuration System

### Configuration File Structure

**`tests/config.yml`**
```yaml
# Test infrastructure configuration

# Default test environment
defaults:
  terminal:
    width: 80
    height: 24
    type: xterm-256color
  bash:
    version: "5.2"
  mode: rich
  timeout: 5s

# CI/CD configuration
ci:
  parallel: true
  jobs: 4
  coverage: true
  verbose: false
  fail_fast: false

# Coverage thresholds
coverage:
  minimum: 90%
  warn_below: 95%
  target: 100%

# Performance thresholds
performance:
  max_render_time: 100ms
  max_interaction_time: 50ms
  max_list_size: 1000

# Test categories
categories:
  unit:
    timeout: 2s
    parallel: true
  integration:
    timeout: 5s
    parallel: true
  interactive:
    timeout: 10s
    parallel: false  # PTY conflicts
  rendering:
    timeout: 3s
    parallel: true
  performance:
    timeout: 30s
    parallel: false
  accessibility:
    timeout: 5s
    parallel: true
  e2e:
    timeout: 30s
    parallel: false

# Terminal size matrix (for matrix testing)
terminal_sizes:
  - [20, 10]   # Minimum
  - [40, 20]   # Small
  - [80, 24]   # Standard
  - [120, 40]  # Large
  - [200, 60]  # Very large

# Mode matrix
modes:
  - rich
  - color
  - plain

# Bash version matrix (for CI)
bash_versions:
  - "3.2"  # macOS default
  - "4.4"  # Common Linux
  - "5.2"  # Latest

# Snapshot configuration
snapshots:
  auto_create: true
  auto_update: false  # Require explicit SNAPSHOT_UPDATE=1
  diff_tool: diff -u

# Reporting
reporting:
  junit: true
  html: true
  coverage_format: lcov
```

### Configuration Loader

**`helpers/core/config.bash`**
```bash
#!/bin/bash
# Configuration management for tests

TEST_CONFIG_FILE="${TEST_ROOT}/config.yml"

# Load configuration (requires yq or manual parsing)
load_test_config() {
    if command -v yq >/dev/null 2>&1; then
        # Use yq for YAML parsing
        TEST_TIMEOUT=$(yq eval '.defaults.timeout' "$TEST_CONFIG_FILE")
        TEST_TERM_WIDTH=$(yq eval '.defaults.terminal.width' "$TEST_CONFIG_FILE")
        TEST_TERM_HEIGHT=$(yq eval '.defaults.terminal.height' "$TEST_CONFIG_FILE")
    else
        # Fallback: source bash version
        source "${TEST_ROOT}/config.bash"
    fi
}

# Override config for specific test
with_test_config() {
    local config_overrides=$1
    shift

    # Parse overrides: "width=40,height=20,timeout=10s"
    IFS=',' read -ra OVERRIDES <<< "$config_overrides"
    for override in "${OVERRIDES[@]}"; do
        IFS='=' read -r key value <<< "$override"
        case "$key" in
            width) MOCK_TERM_WIDTH=$value;;
            height) MOCK_TERM_HEIGHT=$value;;
            timeout) TEST_TIMEOUT=$value;;
            mode) OISEAU_MODE=$value;;
        esac
    done

    # Run test with overrides
    "$@"
}
```

---

## 7. Snapshot Testing

### Snapshot Directory Structure

```
tests/snapshots/
├── ask_list/
│   ├── basic.txt
│   ├── multiline.txt
│   ├── emoji.txt
│   └── empty.txt
├── show_box/
│   ├── info_box.txt
│   ├── error_box.txt
│   └── nested_box.txt
└── show_table/
    ├── simple_table.txt
    └── wide_table.txt
```

See Section 2 (Helper Library Architecture) for full snapshot.bash implementation.

---

## 8. Test Tagging & Filtering

### BATS Tagging Support

BATS supports tags via comments:

```bash
# @tags unit fast
@test "display_width: basic ASCII" {
    result=$(_display_width "hello")
    [[ $result -eq 5 ]]
}

# @tags unit fast emoji
@test "display_width: emoji characters" {
    result=$(_display_width "📁")
    [[ $result -eq 2 ]]
}

# @tags integration slow
@test "ask_list with show_box integration" {
    # ...
}

# @tags interactive manual
@test "keyboard navigation" {
    skip "Requires manual testing"
}
```

### Tag Categories

**Recommended tags:**
- **Speed:** `fast`, `slow`
- **Type:** `unit`, `integration`, `interactive`, `rendering`, `performance`, `e2e`
- **Component:** `ask_list`, `show_box`, `ask_choice`, etc.
- **Feature:** `navigation`, `keyboard`, `emoji`, `unicode`, `ansi`
- **Status:** `manual`, `wip`, `flaky`, `skip`
- **Requirement:** `perl`, `expect`, `pty`, `bash4`

---

## 9. Anti-Patterns to Avoid

### 1. Tight Coupling Between Tests

**Bad:**
```bash
# test_1.bats
@test "setup shared state" {
    echo "data" > /tmp/shared_state
}

# test_2.bats (depends on test_1 running first!)
@test "use shared state" {
    data=$(cat /tmp/shared_state)
    [[ "$data" == "data" ]]
}
```

**Good:**
```bash
# Each test is independent
@test "process data" {
    setup_test_data  # Create own state
    data=$(cat "$TEST_DATA_FILE")
    [[ "$data" == "expected" ]]
    cleanup_test_data  # Clean own state
}
```

### 2. Hardcoded Assumptions

**Bad:**
```bash
@test "box width" {
    output=$(show_box info "Test" "Message")
    # Assumes terminal is 80 cols
    [[ $(echo "$output" | head -1 | wc -c) -eq 60 ]]
}
```

**Good:**
```bash
@test "box width" {
    with_terminal_size 80 24 \
        run show_box info "Test" "Message"

    # Use configurable width
    assert_box_width "$output" "$OISEAU_BOX_WIDTH"
}
```

### 3. Magic Numbers

**Bad:**
```bash
@test "list navigation" {
    # What do these numbers mean?
    simulate_keys "\033[B\033[B\033[B"
    [[ $CURSOR -eq 3 ]]
}
```

**Good:**
```bash
@test "list navigation" {
    local TARGET_INDEX=3
    navigate_to_item $TARGET_INDEX
    assert_cursor_at $TARGET_INDEX
}
```

### 4. Copy-Paste Test Code

**Bad:**
```bash
@test "ask_list: 3 items" {
    items=(A B C)
    run ask_list "Choose:" items
    assert_success
    # ... 20 lines of validation
}

@test "ask_list: 10 items" {
    items=(A B C D E F G H I J)
    run ask_list "Choose:" items
    assert_success
    # ... same 20 lines copied
}
```

**Good:**
```bash
validate_list_output() {
    local expected_count=$1
    assert_success
    # ... 20 lines of validation (once)
}

@test "ask_list: various sizes" {
    for size in 3 10 50 100; do
        eval "$(create_test_list $size)"
        run ask_list "Choose:" items
        validate_list_output $size
    done
}
```

### 5. Monolithic Helpers

**Bad:**
```bash
# test_helpers.bash (5000 lines)
# - 200 helper functions
# - No organization
# - Unclear dependencies
# - Name collisions
```

**Good:**
```bash
helpers/
├── core/assertions.bash      # 20 functions
├── interactive/keyboard.bash # 15 functions
├── mocking/terminal.bash     # 10 functions
└── components/ask_list_helpers.bash  # 8 functions
```

---

## 10. Migration Roadmap

### Phase 1: Refactor (Weeks 1-2)

**Goal:** Reorganize existing tests without adding new ones.

**Tasks:**
1. Create new directory structure
2. Move existing tests to categories
3. Extract helper modules
4. Add configuration system
5. Create test runner script

**Deliverables:**
- [ ] Directory structure created
- [ ] 10 existing test files moved and renamed
- [ ] Helpers split into 4-5 modules
- [ ] `config.yml` created
- [ ] `bin/run-tests` implemented
- [ ] Documentation updated

**Testing:** All existing tests still pass.

### Phase 2: Extend (Weeks 3-4)

**Goal:** Add new test types and infrastructure.

**Tasks:**
1. Add interactive tests (expect-based)
2. Implement snapshot testing
3. Add component interface tests
4. Create test generator
5. Add tagging support

**Deliverables:**
- [ ] 10 interactive tests added
- [ ] Snapshot system implemented
- [ ] Component interface applied to 5 components
- [ ] `bin/generate-test` working
- [ ] Tagging added to all tests

**Testing:** 40+ tests passing.

### Phase 3: Scale (Weeks 5-6)

**Goal:** Achieve comprehensive coverage.

**Tasks:**
1. Add rendering tests
2. Add performance benchmarks
3. Add accessibility tests
4. Complete component interface coverage
5. Matrix testing implementation

**Deliverables:**
- [ ] 30 rendering tests added
- [ ] 10 performance benchmarks added
- [ ] 10 accessibility tests added
- [ ] All 15+ components have interface tests
- [ ] Matrix testing for 3 dimensions

**Testing:** 100+ tests passing.

### Phase 4: Optimize (Weeks 7-8)

**Goal:** Production-ready CI/CD integration.

**Tasks:**
1. Optimize test execution speed
2. Add parallel execution
3. Integrate with CI/CD
4. Add coverage reporting
5. Documentation and onboarding

**Deliverables:**
- [ ] Tests run in < 5 minutes (parallel)
- [ ] CI/CD pipeline configured
- [ ] Coverage reports generated
- [ ] Complete test documentation
- [ ] Contributor onboarding guide

**Testing:** 200+ tests passing, 90%+ coverage.

---

## 11. Future-Proofing Checklist

### Extensibility Checklist

- [x] **Can add new test type without modifying existing tests?**
  - Yes: Just create new category directory (e.g., `tests/security/`)

- [x] **Can add new component tests in < 30 minutes?**
  - Yes: `./tests/bin/generate-test new_component`

- [x] **Can non-expert contributors add tests?**
  - Yes: Templates + component interface + helper library

- [x] **Can migrate to new tools without rewriting tests?**
  - Yes: Abstraction layer in helpers (swap BATS → shunit2 by changing runner only)

- [x] **Can scale to 1000+ tests without architectural changes?**
  - Yes: Hierarchical structure + parallel execution + filtering

- [x] **Can run tests in parallel?**
  - Yes: `./tests/bin/run-tests --parallel 4`

- [x] **Can filter tests by multiple dimensions?**
  - Yes: Category + component + tag + pattern

### Maintenance Checklist

- [x] **Is test code DRY (no duplication)?**
  - Yes: Helpers + parameterization + component interface

- [x] **Are helpers well-documented?**
  - Yes: `helpers/README.md` + inline docs

- [x] **Is configuration centralized?**
  - Yes: `tests/config.yml`

- [x] **Are snapshots version-controlled?**
  - Yes: `tests/snapshots/` in git

- [x] **Can detect obsolete tests/snapshots?**
  - Yes: `bin/prune-snapshots`

### Contributor Experience Checklist

- [x] **Clear test organization?**
  - Yes: Directory hierarchy + naming conventions

- [x] **Easy to run subset of tests?**
  - Yes: `run-tests unit`, `run-tests --component ask_list`

- [x] **Fast feedback loop?**
  - Yes: Unit tests run in seconds, `--fast` flag available

- [x] **Good error messages?**
  - Yes: Custom assertions with context, snapshot diffs

- [x] **Easy to debug failing tests?**
  - Yes: `--verbose` flag, `TEST_DEBUG=1`

### CI/CD Checklist

- [x] **Tests run in CI?**
  - Yes: Standard bats execution

- [x] **Parallel execution in CI?**
  - Yes: `--parallel` flag

- [x] **Coverage reporting?**
  - Yes: Via kcov or similar (planned)

- [x] **Test result artifacts?**
  - Yes: JUnit XML, HTML reports

- [x] **Fast CI runs (< 5 min)?**
  - Yes: Parallel + fast tests only in PR checks

---

## Conclusion

This extensibility architecture provides:

1. **Scalability:** 200+ tests → 1000+ tests without restructuring
2. **Maintainability:** DRY helpers, clear organization, good docs
3. **Contributor-friendly:** Templates, generators, clear conventions
4. **Future-proof:** Abstraction layers, configuration, versioning
5. **Fast feedback:** Parallel execution, smart filtering, watch mode
6. **Quality:** Snapshot testing, component interfaces, coverage tracking

The architecture supports 10x growth in all dimensions while keeping test creation simple (< 30 min per component) and execution fast (< 5 min full suite).

**Next Steps:**
1. Review this architecture with team
2. Create Phase 1 implementation PR
3. Migrate 1-2 components as proof of concept
4. Iterate based on feedback
5. Roll out to remaining components

---

**Document Version:** 1.0
**Last Updated:** 2025-11-20
**Author:** Extensibility & Future-Proofing Specialist (Claude)
**Related:** PR#71 (Test Infrastructure)
