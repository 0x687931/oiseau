# Action Plan: Emoji/CJK Alignment Resolution

## TL;DR

**Status**: NOT A BUG — Current implementation is correct.

**Root Cause**: Validation scripts measure by byte count instead of display width.

**Fix**: Update validation methodology, not the code.

---

## Current Situation

### What's Happening
- Lines with emoji/CJK are 2-4 bytes longer than plain text lines
- Visual alignment is PERFECT (all borders align on screen)
- Byte-count-based validation scripts report "misalignment"
- PR#85 proposes fixing this by padding to byte count instead of display width

### Why This Happened
1. Unicode characters have different byte sizes (emoji = 4 bytes, CJK = 3 bytes, ASCII = 1 byte)
2. Terminals render by display width (columns), not byte count
3. `_pad_to_width()` correctly pads to display width
4. Result: Perfect visual alignment, but unequal byte counts

### The Real Problem
**The validation methodology is wrong, not the code.**

---

## Recommended Actions

### Priority 1: Do NOT Merge PR#85

**Reason**: PR#85 breaks the semantic contract of `_pad_to_width()`.

**Impact if merged**:
- ✗ Visual alignment breaks (borders misalign on screen)
- ✗ Function name becomes misleading (`_pad_to_width` but pads to bytes)
- ✗ All UI elements render incorrectly with emoji/CJK

**Action**: Close PR#85 with explanation from this analysis.

### Priority 2: Fix Validation Scripts

**Current (WRONG)**:
```bash
# Measures byte count (varies for emoji/CJK)
byte_count=$(LC_ALL=C printf '%s' "$line" | wc -c | tr -d ' ')
```

**Correct**:
```bash
# Measures display width (consistent across all content)
display_width=$(_display_width "$line")
```

**Files to update**:
- `/Users/am/Documents/GitHub/oiseau-validate-alignment/validate_alignment_simple.sh`
- `/Users/am/Documents/GitHub/oiseau-validate-alignment/check_actual_alignment.sh`
- Any other validation scripts that measure line length

**Example fix**:
```bash
# BEFORE (validates byte count)
test_case() {
    local content="$1"
    output=$(bash -c "source ./oiseau.sh; show_header_box 'Test' '$content'")

    echo "$output" | while IFS= read -r line; do
        clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
        byte_count=${#clean}  # WRONG: Byte count
        echo "  Bytes: $byte_count"
    done
}

# AFTER (validates display width)
test_case() {
    local content="$1"
    output=$(bash -c "source ./oiseau.sh; show_header_box 'Test' '$content'")

    echo "$output" | while IFS= read -r line; do
        clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
        display_width=$(_display_width "$clean")  # CORRECT: Display width
        echo "  Display: $display_width columns"
    done
}
```

### Priority 3: Update Documentation

**Add to `oiseau.sh` function documentation**:

```bash
# Pad a string to a specific display width
# Usage: _pad_to_width "text" 60
#
# IMPORTANT: This function pads to DISPLAY WIDTH (terminal columns), not byte count.
# For Unicode text (emoji, CJK), the resulting byte count will vary:
#   - Plain ASCII: display width = byte count
#   - Emoji (📁):  display width < byte count (emoji = 4 bytes, 2 columns)
#   - CJK (中):    display width < byte count (CJK = 3 bytes, 2 columns)
#
# This is EXPECTED and CORRECT behavior. Terminals render by display width,
# not byte count. Equal byte counts would produce MISALIGNED visual output.
#
# Example:
#   _pad_to_width "Plain text" 20    → 20 columns, 20 bytes
#   _pad_to_width "📁 emoji" 20     → 20 columns, 22 bytes (2 extra for emoji)
#
# Both results are 20 columns wide on screen (aligned), but different byte lengths.
_pad_to_width() {
    # ... existing implementation ...
}
```

**Create a UNICODE_HANDLING.md guide**:
```markdown
# Unicode Handling in Oiseau

## Display Width vs Byte Count

Oiseau uses display width (terminal columns) for all alignment calculations.
This is correct for terminal rendering, but produces different byte counts
for Unicode text.

## Why Byte Counts Vary

- ASCII character "a": 1 byte, 1 column
- Emoji "📁": 4 bytes, 2 columns
- CJK "中": 3 bytes, 2 columns

When padding to 20 columns:
- "hello" + 15 spaces = 20 bytes, 20 columns
- "📁 hi" + 16 spaces = 22 bytes, 20 columns (visually aligned!)

## Validation

Always validate by display width, not byte count:

✓ CORRECT: `_display_width "$line"` should equal 60 columns
✗ WRONG:   `wc -c "$line"` should equal 60 bytes
```

### Priority 4: Add Display-Width Validation

**Create a new validation script** (`validate_display_width.sh`):

```bash
#!/usr/bin/env bash
# Validates that all box lines have the same DISPLAY WIDTH

cd "$(dirname "$0")"
source ./oiseau.sh

test_case() {
    local content="$1"
    echo "Testing: $content"

    output=$(show_header_box 'Test' "$content" 2>/dev/null)

    # Collect display widths of all content lines
    widths=()
    while IFS= read -r line; do
        # Strip ANSI codes
        clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

        # Skip empty lines and border-only lines
        if [[ "$clean" =~ ^\|.*\|$ ]]; then
            # This is a content line, measure it
            # Remove the borders (first and last char)
            content_only="${clean:1:-1}"
            width=$(_display_width "$content_only")
            widths+=("$width")
        fi
    done <<< "$output"

    # Check if all widths are equal
    first_width="${widths[0]}"
    all_equal=true
    for w in "${widths[@]}"; do
        if [ "$w" != "$first_width" ]; then
            all_equal=false
            break
        fi
    done

    if $all_equal; then
        echo "  ✓ All lines are $first_width columns wide"
    else
        echo "  ✗ Inconsistent widths: ${widths[*]}"
    fi
    echo ""
}

echo "=== DISPLAY WIDTH VALIDATION ==="
echo ""

test_case "Plain text"
test_case "📁 One emoji"
test_case "📁 🌿 Two emojis"
test_case "中文 CJK"

echo "=== If all lines show ✓, alignment is correct ==="
```

---

## Alternative: If Byte Equality Is Required

If there's a genuine requirement for equal byte counts (e.g., for a wire protocol), implement this:

### Option A: Separate Function (RECOMMENDED)

```bash
# Add a new function for byte-based padding
_pad_to_bytes() {
    local text="$1"
    local target_bytes="$2"
    local current_bytes=$(LC_ALL=C printf '%s' "$text" | wc -c | tr -d ' ')
    local padding=$((target_bytes - current_bytes))

    if [ "$padding" -gt 0 ]; then
        echo -n "${text}$(_repeat_char ' ' "$padding")"
    else
        echo -n "$text"
    fi
}
```

Then use:
- `_pad_to_width()` for terminal rendering (all existing code)
- `_pad_to_bytes()` for byte-based formats (new use cases)

### Option B: Mode Parameter

```bash
_pad_to_width() {
    local text="$1"
    local target="$2"
    local mode="${3:-display}"  # "display" (default) or "bytes"

    if [ "$mode" = "bytes" ]; then
        local current=$(LC_ALL=C printf '%s' "$text" | wc -c | tr -d ' ')
    else
        local current=$(_display_width "$text")
    fi

    local padding=$((target - current))

    if [ "$padding" -gt 0 ]; then
        echo -n "${text}$(_repeat_char ' ' "$padding")"
    else
        echo -n "$text"
    fi
}
```

Usage:
- `_pad_to_width "text" 60` — pads to 60 display columns (default)
- `_pad_to_width "text" 60 "bytes"` — pads to 60 bytes

**Recommendation**: Only implement this if there's a clear requirement. Otherwise, accept the byte count variation.

---

## Timeline

### Week 1: Analysis & Communication
- [x] Complete root cause analysis (this document)
- [ ] Share analysis with team
- [ ] Close PR#85 with explanation
- [ ] Get stakeholder buy-in on approach

### Week 2: Fix Validation
- [ ] Update validation scripts to use display width
- [ ] Create new `validate_display_width.sh` script
- [ ] Run validation on all UI components
- [ ] Document results

### Week 3: Documentation
- [ ] Add inline documentation to `_pad_to_width()`
- [ ] Create `UNICODE_HANDLING.md` guide
- [ ] Update existing docs to clarify display width vs bytes
- [ ] Add examples to README

### Week 4: Testing
- [ ] Test all UI components with emoji/CJK
- [ ] Verify visual alignment is perfect
- [ ] Run updated validation suite
- [ ] Document any edge cases

---

## Success Metrics

### How We Know It's Fixed

1. **Visual Validation** ✓
   - All box borders align perfectly on screen
   - Progress bars render correctly
   - Tables display properly

2. **Display Width Validation** ✓
   - All content lines are same display width
   - Measured by `_display_width()`, not byte count

3. **Documentation** ✓
   - Clear explanation of display width vs bytes
   - Examples of expected byte count variation
   - Validation guidelines for contributors

4. **Team Understanding** ✓
   - No more "byte count bug" reports
   - Validation scripts use display width
   - Future PRs maintain the contract

---

## Key Principles

1. **Semantic Contracts Matter**: `_pad_to_width()` means display width, not bytes
2. **Measure What Matters**: Terminals render by display width, so validate by display width
3. **Accept Unicode Reality**: Byte count variation is normal and expected
4. **Single Source of Truth**: Fix width handling once in `_pad_to_width()`, not per widget
5. **Visual Correctness First**: If it looks right on screen, it IS right

---

## Questions & Answers

### Q: Why do byte counts vary?
**A**: Unicode characters have different byte sizes. Emoji = 4 bytes, CJK = 3 bytes, ASCII = 1 byte. This is a fundamental property of UTF-8 encoding.

### Q: Is this a bug?
**A**: No. The current implementation is correct for terminal rendering. The "bug" was in the validation methodology.

### Q: Why not just fix PR#85?
**A**: PR#85 breaks the semantic contract of `_pad_to_width()`. It would make visual alignment WORSE, not better.

### Q: What if I need equal byte counts?
**A**: Create a separate `_pad_to_bytes()` function for that specific use case. Don't change `_pad_to_width()`.

### Q: How do I validate alignment?
**A**: Use `_display_width()` to measure line width in columns, not `wc -c` to count bytes.

### Q: Will this affect performance?
**A**: No change to existing code. Display width calculation is already cached and optimized.

---

## Contact

For questions or clarifications about this analysis:
- Review the detailed technical analysis in `ARCHITECTURAL_ANALYSIS.md`
- Check the visual explanation in `VISUAL_EXPLANATION.md`
- Run the validation tests in `validate_display_width.sh`

**Bottom Line**: The current implementation is architecturally correct. Fix the validation, not the code.
