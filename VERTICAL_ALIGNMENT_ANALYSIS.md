# Vertical Alignment Analysis

## Issue Background

Issue #68 reports that vertical bars (`┃`) in boxes are misaligned when content contains emojis or CJK characters. This has been a recurring problem.

## Investigation Findings

### Root Cause Misunderstanding

The issue report suggested that `_pad_to_width()` was using character count instead of display width. However, investigation shows:

**✅ The code IS working correctly**

The confusion arose from using **character count** vs **display width** as the measurement criteria.

### Key Concepts

#### Display Width vs Character Count

- **Character Count**: Number of Unicode code points in a string
- **Display Width**: Number of terminal columns occupied when rendered

Examples:
```
"Hello"      → char_count=5, display_width=5
"📁 file"    → char_count=6, display_width=7  (emoji=2 cols, space=1, file=4)
"中文"       → char_count=2, display_width=4  (each CJK char=2 cols)
```

#### Box Rendering

When rendering a box like:
```
┃   📁 file                                                ┃
```

- Total **display width** should be 60 columns
- But **character count** will be 59 (because 📁 is 1 char but displays as 2 cols)
- This is **CORRECT BEHAVIOR**

### Current Implementation Status

#### ✅ _display_width() Function

Located at `oiseau.sh:394-528`, correctly calculates display width using:

1. **Perl-based wcwidth** (if Perl available)
   - Tries Text::VisualWidth::PP first (most accurate)
   - Falls back to custom Perl wcwidth implementation
   - Handles emoji ranges: U+1F300-1F9FF, U+2600-26FF
   - Handles CJK ranges: U+3040-D7AF, U+F900-FFDC
   - Special cases for width-1 symbols: ✓ ✗ ⚠ ℹ

2. **Fallback heuristic** (no Perl)
   - Estimates wide characters from UTF-8 byte sequences
   - Accounts for narrow symbols

#### ✅ _pad_to_width() Function

Located at `oiseau.sh:533-545`, correctly pads to **display width**:

```bash
_pad_to_width() {
    local text="$1"
    local target_width="$2"
    local current_width=$(_display_width "$text")  # ← Uses display width!
    local padding=$((target_width - current_width))

    if [ "$padding" -gt 0 ]; then
        echo -n "${text}$(_repeat_char ' ' "$padding")"
    else
        echo -n "$text"
    fi
}
```

**Example:**
- Input: `"   📁 file"` (9 chars, 10 cols display)
- Target: 58 cols
- Padding: 58 - 10 = 48 spaces
- Result: 57 chars, 58 cols display ✓

#### ✅ show_header_box() and show_box()

Both functions correctly use `_pad_to_width()` which accounts for display width.

## Test Results

Created comprehensive test suite: `tests/bats/test_vertical_alignment.bats`

### Test Coverage: 24 Tests, All Passing ✅

1. **Vertical Alignment Tests** (11 tests)
   - Plain ASCII text
   - Single emoji
   - Two emojis (issue #68 example: 📁 🌿)
   - Three emojis
   - CJK characters
   - Mixed emoji and CJK
   - Emoji at end of line
   - Only emojis
   - show_box variants

2. **_display_width Tests** (5 tests)
   - ASCII returns correct width
   - Emoji counted as width 2
   - CJK counted as width 2
   - ANSI escape codes stripped

3. **_pad_to_width Tests** (5 tests)
   - ASCII text padded correctly
   - Emoji text padded correctly
   - CJK text padded correctly
   - No padding when at target
   - Handles text wider than target

4. **Edge Cases** (3 tests)
   - Empty subtitle
   - Very long emoji line with wrapping
   - Special symbols (✓ ✗ ⚠ ℹ) as width 1

### Visual Verification

All manual visual tests show perfect alignment:

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃   No emojis - just plain text here                       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃   📁 One emoji at start                                  ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃   📁 🌿 Two emojis together                              ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

All right edges align perfectly.

## Conclusion

### Status: ✅ Working Correctly

The vertical alignment is **already implemented correctly**. The `_display_width()` function properly accounts for:
- Emojis (2 cols)
- CJK characters (2 cols)
- Special symbols (1 col)
- ANSI escape codes (0 cols)

### Why Past Issues Occurred

If there were historical alignment issues, they were likely:

1. **Before Perl implementation** - The current Perl-based width calculation was added later
2. **Terminal-specific rendering** - Some terminals may render emojis differently
3. **Missing Perl** - Systems without Perl fall back to heuristics (less accurate)

### Recommendations

1. **Keep comprehensive tests** - The 24 BATS tests will catch any regression
2. **Document the difference** - Make it clear that character count ≠ display width
3. **Close issue #68** - The reported problem is resolved

## Test Files Created

1. `test_vertical_detailed.sh` - Detailed analysis with measurements
2. `visual_test.sh` - Simple visual verification
3. `test_width_methods.sh` - Comparison of width calculation methods
4. `test_no_perl.sh` - Test fallback mode
5. `check_display_widths.sh` - Display width verification
6. `tests/bats/test_vertical_alignment.bats` - Comprehensive BATS test suite (24 tests)

## Running Tests

```bash
# Visual test
./visual_test.sh

# BATS comprehensive tests
bats tests/bats/test_vertical_alignment.bats

# All tests should pass
```
