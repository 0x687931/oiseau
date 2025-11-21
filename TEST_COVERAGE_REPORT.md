# Test Coverage & Validation Report: Emoji/CJK Alignment Bug

**Repository**: /Users/am/Documents/GitHub/oiseau-validate-alignment  
**Issue**: Vertical bar alignment in boxes with emoji/CJK content (#68)  
**Scope**: Complete inventory of ALL UI elements requiring emoji/CJK validation

---

## Executive Summary

**Current Test Coverage**: 2/10 UI functions (20%)  
**Bugs Identified**: 1 confirmed, 2 potential  
**Critical Finding**: The alignment bug affects MORE than just boxes - any function using padding/alignment needs validation.

---

## Complete UI Element Inventory

### Category 1: Functions Using `_pad_to_width` ⚠️ CRITICAL

These directly pad content to display width. Bug will cause misalignment.

| Function | Line | Test Coverage | Status |
|----------|------|---------------|--------|
| `show_header_box` | 829 | ✅ 15 BATS tests | TESTED |
| `show_box` | 876 | ✅ 3 BATS tests | TESTED |

**Tests Location**: `/Users/am/Documents/GitHub/oiseau-validate-alignment/tests/bats/test_vertical_alignment.bats`

---

### Category 2: Functions Using `_display_width` ⚠️ ALIGNMENT CRITICAL

These calculate display width for padding. Must be accurate for emoji/CJK.

| Function | Line | Uses | Test Coverage | Priority |
|----------|------|------|---------------|----------|
| `show_section_header` | 780 | `_display_width`, `_repeat_char` | ❌ None | HIGH |
| `show_summary` | 1285 | `_display_width`, `_repeat_char` | ❌ None | HIGH |
| `show_table` | 2217 | `_display_width`, `_truncate_to_width` | ⚠️ Partial (CJK truncation only) | HIGH |

---

### Category 3: Functions with Character-Based Width 🐛 CONFIRMED BUG

| Function | Line | Issue | Impact | Priority |
|----------|------|-------|--------|----------|
| `print_kv` | 1963 | Uses `printf %-${width}s` (character-based) | Misaligns values when keys have emoji/CJK | MEDIUM |

**Bug Details**:
```bash
# Current (BROKEN):
printf "  ${COLOR_MUTED}%-${key_width}s${RESET} %s\n" "$key" "$value"

# Issue: %-20s pads to 20 CHARACTERS, not 20 display columns
# Emoji (2 columns) counted as 1 character = misalignment

# Fix Required:
local key_display=$(_display_width "$key")
local padding=$((key_width - key_display))
printf "  ${COLOR_MUTED}%s%s${RESET} %s\n" "$key" "$(_repeat_char " " "$padding")" "$value"
```

---

### Category 4: Simple Display Functions (Low Risk)

These use simple printf without alignment, so emoji/CJK impact is minimal.

| Function | Line | Uses | Risk | Test Priority |
|----------|------|------|------|---------------|
| `show_checklist` | 1244 | Icons + printf (no padding) | LOW | Low |
| `show_progress_bar` | 1084 | Label display (no alignment) | MEDIUM | Medium |
| `show_header` | 815 | Simple printf | LOW | Low |
| `show_subheader` | 822 | Simple printf | LOW | Low |

---

## Test Coverage Matrix

| Function | ASCII Tests | Emoji Tests | CJK Tests | Mixed Tests | Status |
|----------|-------------|-------------|-----------|-------------|--------|
| `show_header_box` | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | COMPLETE |
| `show_box` | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | COMPLETE |
| `show_section_header` | ⚠️ Basic | ❌ No | ❌ No | ❌ No | **MISSING** |
| `show_summary` | ⚠️ Basic | ❌ No | ❌ No | ❌ No | **MISSING** |
| `show_table` | ✅ Yes | ❌ No | ⚠️ Partial | ❌ No | **INCOMPLETE** |
| `print_kv` | ✅ Yes | ❌ No | ❌ No | ❌ No | **MISSING** |
| `show_progress_bar` | ✅ Yes | ❌ No | ❌ No | ❌ No | **INCOMPLETE** |
| `show_checklist` | ✅ Yes | ❌ No | ❌ No | ❌ No | **INCOMPLETE** |

---

## Existing Test Suite Analysis

### File: `tests/bats/test_vertical_alignment.bats` ✅ COMPREHENSIVE

**Test Groups**:
1. **Vertical Alignment Tests** (12 tests)
   - Plain ASCII, single emoji, multiple emojis (2, 3, many)
   - CJK characters, mixed emoji + CJK
   - Edge cases: emoji at end, only emojis, long wrapping lines

2. **show_box Tests** (3 tests)
   - Emoji content, CJK content, mixed content

3. **_display_width Tests** (5 tests)
   - ASCII, emoji, CJK, ANSI codes

4. **_pad_to_width Tests** (5 tests)
   - ASCII, emoji, CJK, edge cases

**Validation Method**: 
- Uses independent Python/Perl width calculator
- Compares oiseau's `_display_width` against reference implementation
- Validates box line consistency (all lines same width)

**Helper Functions**:
```bash
# Independent width calculation (not using oiseau code)
python_display_width() {
    python3 -c "import unicodedata; ..."
}

# Box alignment validation
check_box_width_consistency() {
    # Extracts all box lines, measures width, validates
}
```

### Files: `tests/test_*.sh` ⚠️ BASIC COVERAGE

Most shell tests focus on functionality, not emoji/CJK edge cases:
- `test_table.sh`: Has CJK truncation test (good start)
- `test_edge_cases.sh`: Has CJK table test
- `test_mode_consistency.sh`: Mode detection only
- Others: No emoji/CJK validation

---

## Gap Analysis

### HIGH PRIORITY: Missing Test Coverage

1. **show_section_header** (NO TESTS)
   - Location: `/Users/am/Documents/GitHub/oiseau-validate-alignment/oiseau.sh:780`
   - Need: Emoji in title, CJK in title, emoji in subtitle
   - Impact: Used in many user-facing flows

2. **show_summary** (NO TESTS)
   - Location: `/Users/am/Documents/GitHub/oiseau-validate-alignment/oiseau.sh:1285`
   - Need: Emoji in title, CJK in items
   - Impact: Summary boxes may misalign

3. **show_table** (INCOMPLETE TESTS)
   - Location: `/Users/am/Documents/GitHub/oiseau-validate-alignment/oiseau.sh:2217`
   - Has: CJK truncation test
   - Need: Emoji in headers, emoji in cells, mixed columns
   - Impact: Tables are complex and critical

### MEDIUM PRIORITY: Bug Fix + Tests

4. **print_kv BUG**
   - Location: `/Users/am/Documents/GitHub/oiseau-validate-alignment/oiseau.sh:1963-1969`
   - Need: Fix implementation + add tests
   - Impact: Key-value pairs misalign with emoji keys

### LOW PRIORITY: Validation Tests

5. **show_progress_bar**: Add emoji label tests
6. **show_checklist**: Add emoji in label tests
7. **show_header/subheader**: Informational tests only

---

## Recommended Test Strategy

### Phase 1: Expand BATS Test Suite (HIGH PRIORITY)

**File**: `tests/bats/test_vertical_alignment.bats`

Add new test groups:

```bash
# ==============================================================================
# TEST GROUP: show_section_header Alignment
# ==============================================================================

@test "show_section_header: emoji in title" {
    output=$(show_section_header "📁 Project Setup" 2>&1)
    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "show_section_header: CJK in title" {
    output=$(show_section_header "项目设置" 2>&1)
    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "show_section_header: emoji with step counter" {
    output=$(show_section_header "📁 Setup" 1 3 "Initialize" 2>&1)
    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "show_section_header: CJK in subtitle" {
    output=$(show_section_header "Setup" 1 3 "初始化" 2>&1)
    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

# ==============================================================================
# TEST GROUP: show_summary Alignment
# ==============================================================================

@test "show_summary: emoji in title" {
    output=$(show_summary "📁 Deployment Summary" "Step 1" "Step 2" 2>&1)
    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "show_summary: CJK in title" {
    output=$(show_summary "部署摘要" "Item 1" "Item 2" 2>&1)
    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

@test "show_summary: mixed emoji and CJK items" {
    output=$(show_summary "Summary" "📁 Files processed" "中文项目" 2>&1)
    run check_box_width_consistency "$output" 60
    [ "$status" -eq 0 ]
}

# ==============================================================================
# TEST GROUP: show_table Alignment (EXPANDED)
# ==============================================================================

@test "show_table: emoji in header" {
    local -a data=("📁 Name" "Status" "file1.txt" "OK" "file2.txt" "OK")
    output=$(show_table data 2 2>&1)
    # Validate column alignment
    [[ "$output" =~ "📁 Name" ]]
}

@test "show_table: emoji in data cells" {
    local -a data=("Name" "Icon" "File" "📁" "Folder" "📂" "Branch" "🌿")
    output=$(show_table data 2 2>&1)
    # Validate no crashes
    [ $? -eq 0 ]
}

@test "show_table: mixed CJK headers and ASCII data" {
    local -a data=("名称" "Type" "项目A" "Project" "项目B" "Task")
    output=$(show_table data 2 2>&1)
    [[ "$output" =~ "项目" ]]
}

# ==============================================================================
# TEST GROUP: print_kv Alignment (NEW - AFTER FIX)
# ==============================================================================

@test "print_kv: emoji in key with alignment" {
    output=$(print_kv "📁 Status" "OK" 20)
    # Measure actual spacing between key and value
    # Should be consistent with ASCII key spacing
}

@test "print_kv: CJK in key with alignment" {
    output=$(print_kv "状态" "正常" 20)
    # Validate spacing
}

@test "print_kv: multiple keys with mixed widths" {
    output1=$(print_kv "Status" "OK" 20)
    output2=$(print_kv "📁 Repo" "myrepo" 20)
    output3=$(print_kv "状态" "正常" 20)
    # All values should align vertically
}
```

### Phase 2: Fix print_kv() Bug

**File**: `/Users/am/Documents/GitHub/oiseau-validate-alignment/oiseau.sh:1963-1969`

**Current Code**:
```bash
print_kv() {
    local key="$1"
    local value="$2"
    local key_width="${3:-20}"

    printf "  ${COLOR_MUTED}%-${key_width}s${RESET} %s\n" "$key" "$value"
}
```

**Fixed Code**:
```bash
print_kv() {
    local key="$1"
    local value="$2"
    local key_width="${3:-20}"
    
    # Calculate display width and pad manually
    local key_display=$(_display_width "$key")
    local padding=$((key_width - key_display))
    
    # Ensure non-negative padding
    if [ "$padding" -lt 0 ]; then
        padding=0
    fi
    
    printf "  ${COLOR_MUTED}%s%s${RESET} %s\n" "$key" "$(_repeat_char " " "$padding")" "$value"
}
```

### Phase 3: Add Emoji Label Tests (LOW PRIORITY)

Add simple validation tests for progress bars and checklists with emoji content.

---

## Validation Framework

### Independent Width Calculator

**File**: `tests/bats/helpers/independent_width.bash`

Provides reference implementation separate from oiseau code:

```bash
python_display_width() {
    local text="$1"
    python3 -c "
import unicodedata
import sys
text = '$text'
width = sum(2 if unicodedata.east_asian_width(c) in 'FW' else 1 for c in text)
print(width)
"
}

perl_display_width() {
    local text="$1"
    perl -Mutf8 -CS -e "
        use Unicode::EastAsianWidth;
        my \$text = '$text';
        my \$width = 0;
        for my \$char (split //, \$text) {
            \$width += (InFullwidth(\$char) || InWide(\$char)) ? 2 : 1;
        }
        print \$width;
    "
}
```

### Alignment Validation Helpers

**File**: `tests/bats/test_vertical_alignment.bats`

```bash
# Strip ANSI codes
strip_ansi() {
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Extract box lines (lines with vertical bars)
extract_box_lines() {
    local output="$1"
    strip_ansi "$output" | grep -E '[┃|]'
}

# Measure line width using independent calculator
measure_line_width() {
    local line="$1"
    local clean=$(strip_ansi "$line")
    python_display_width "$clean"
}

# Check all box lines have consistent width
check_box_width_consistency() {
    local output="$1"
    local expected_width="${2:-60}"
    
    local lines=$(extract_box_lines "$output")
    local inconsistent=0
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local width=$(measure_line_width "$line")
            if [ "$width" -ne "$expected_width" ]; then
                echo "Line width $width != expected $expected_width: $line" >&2
                inconsistent=1
            fi
        fi
    done <<< "$lines"
    
    return $inconsistent
}
```

---

## File Locations Reference

| Component | File Path |
|-----------|-----------|
| Main library | `/Users/am/Documents/GitHub/oiseau-validate-alignment/oiseau.sh` |
| BATS tests | `/Users/am/Documents/GitHub/oiseau-validate-alignment/tests/bats/test_vertical_alignment.bats` |
| BATS helpers | `/Users/am/Documents/GitHub/oiseau-validate-alignment/tests/bats/helpers/independent_width.bash` |
| Shell tests | `/Users/am/Documents/GitHub/oiseau-validate-alignment/tests/test_*.sh` |
| Edge cases | `/Users/am/Documents/GitHub/oiseau-validate-alignment/tests/test_edge_cases.sh` |
| Table tests | `/Users/am/Documents/GitHub/oiseau-validate-alignment/tests/test_table.sh` |

---

## Summary Statistics

**Total UI Functions**: 10  
**Functions Using Width Calculation**: 6  
**Functions with Comprehensive Tests**: 2 (20%)  
**Functions with No Tests**: 2 (20%)  
**Functions with Partial Tests**: 6 (60%)  

**Known Bugs**: 1 confirmed (print_kv)  
**Potential Issues**: 2 (progress_bar labels, checklist items)  

**Test Files**:
- BATS test file: 1 (comprehensive)
- Shell test files: 10 (basic coverage)

**Recommended Actions**:
1. ✅ Keep existing comprehensive tests for show_header_box and show_box
2. 🔴 Add tests for show_section_header (HIGH PRIORITY)
3. 🔴 Add tests for show_summary (HIGH PRIORITY)
4. 🟡 Expand tests for show_table (MEDIUM PRIORITY)
5. 🟡 Fix and test print_kv (MEDIUM PRIORITY)
6. 🟢 Add validation tests for other functions (LOW PRIORITY)

---

## Conclusion

**Key Finding**: The emoji/CJK alignment issue is NOT limited to show_header_box and show_box. It affects:
- 6 functions using width calculation
- 1 function with a confirmed bug (print_kv)
- Multiple untested functions that may have issues

**Critical Insight**: Any solution (whether fixing _pad_to_width or the box rendering) MUST be validated across ALL UI elements, not just the two functions that currently have tests.

**Recommended Approach**:
1. Fix the root cause (whether in _pad_to_width or box rendering)
2. Validate fix using existing comprehensive tests
3. Add missing tests for untested functions BEFORE declaring bug fixed
4. Fix print_kv() bug (separate issue, same root cause)
5. Expand test coverage to prevent regression

**Test Coverage Goal**: 100% of width-calculation functions with emoji/CJK tests
