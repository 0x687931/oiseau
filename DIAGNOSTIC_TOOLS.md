# Diagnostic Tools for Vertical Alignment

This directory contains diagnostic tools for investigating vertical alignment issues. These are **manual inspection tools**, not automated tests.

## Automated Testing

For automated regression testing, use:

```bash
# Run all automated tests (including BATS vertical alignment tests)
./run_tests.sh

# Run only vertical alignment BATS tests
bats tests/bats/test_vertical_alignment.bats
```

## Manual Diagnostic Tools

### Quick Visual Check

**`visual_test.sh`** - Simple visual verification
```bash
./visual_test.sh
```

Displays multiple boxes with different content types. Visually inspect that all right edges (`┃`) align vertically.

### Detailed Analysis

**`test_vertical_detailed.sh`** - Comprehensive width measurements
```bash
./test_vertical_detailed.sh
```

Shows detailed character count vs display width for each line. Use this to understand the difference between:
- **Character count**: Number of Unicode code points
- **Display width**: Terminal columns occupied

**Example output:**
```
Line 5: char_count=58, display_width=60, visual=58
    ✓ ALIGNED
```

The char_count (58) being less than display_width (60) is **expected** for emoji content - emojis are 1 character but 2 columns wide.

### Width Calculation Debugging

**`trace_padding.sh`** - Trace padding calculation step-by-step
```bash
./trace_padding.sh
```

Shows the exact padding calculation for a test case with emojis, demonstrating:
1. Input display width
2. Padding calculation
3. Result display width
4. Full line assembly

**`debug_widths.sh`** - Character count vs display width comparison
```bash
./debug_widths.sh
```

Shows both character count and display width for each box line, clarifying why they differ for emoji/CJK content.

**`check_display_widths.sh`** - Display width verification
```bash
./check_display_widths.sh
```

Validates that all lines have the correct display width (60) regardless of character count.

### Width Method Comparison

**`test_width_methods.sh`** - Compare different width calculation methods
```bash
./test_width_methods.sh
```

Compares:
- Character count (`${#str}`)
- Multibyte count (`wc -m`)
- `wc -L` output
- `_display_width()` function

Note: `wc -L` returns character count, not display width, so it will differ from `_display_width()` for emoji/CJK.

### Non-Perl Fallback Testing

**`test_no_perl.sh`** - Test fallback width calculation
```bash
./test_no_perl.sh
```

Tests alignment when Perl is not available, using the heuristic fallback width calculator.

## Understanding the Output

### Key Concepts

**Character Count vs Display Width:**

```
"Hello"      → char_count=5,  display_width=5
"📁 file"    → char_count=6,  display_width=7  (emoji=2 cols)
"中文"       → char_count=2,  display_width=4  (each CJK=2 cols)
```

**Box Line Alignment:**

A properly aligned box line:
```
┃   📁 file                                                ┃
```

- **Display width**: 60 columns ✅ (correct alignment)
- **Character count**: 59 characters (expected - emoji takes 1 char, 2 cols)

### What to Look For

✅ **Healthy Output:**
- All right edges (`┃`) align vertically
- Display width = 60 for all lines
- Character count may vary (expected for emoji/CJK)

❌ **Problem Indicators:**
- Right edges misaligned (jaggy appearance)
- Display width ≠ 60
- Visual inspection shows gaps or overlaps

## When to Use What

| Goal | Tool |
|------|------|
| Automated regression testing | `./run_tests.sh` or `bats tests/bats/` |
| Quick visual check | `./visual_test.sh` |
| Understand width calculation | `./test_width_methods.sh` |
| Debug specific alignment issue | `./trace_padding.sh` |
| Verify display widths | `./check_display_widths.sh` |
| Test without Perl | `./test_no_perl.sh` |

## Important Notes

1. **These are diagnostic tools, not tests** - They display output for manual inspection but don't have pass/fail assertions

2. **Character count ≠ display width** - This is expected and correct for emoji/CJK content

3. **Use BATS for regression testing** - The automated test suite (`tests/bats/test_vertical_alignment.bats`) catches actual bugs

4. **Visual alignment is what matters** - If boxes look aligned to your eyes, the code is working correctly regardless of character count

## Contributing

When adding new diagnostic tools:
1. Mark them clearly as "MANUAL DIAGNOSTIC TOOL" in the header
2. Document what they show vs what they test
3. Reference the automated test suite for regression testing
4. Explain any expected differences (char count vs display width)
