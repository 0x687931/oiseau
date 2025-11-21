# The Real Problem: Display Width vs Byte Count

## What We Discovered

Lines with emoji/CJK are **2-4 bytes longer** than plain text lines when they should be equal.

## Current "Fix" (LOCAL - WRONG)

Changed `_pad_to_width()` to pad based on byte count instead of display width.

**Problem**: This breaks the function's purpose - it's supposed to pad to DISPLAY width, not byte count.

## Codex Review Insight

> The final rendered line is shorter by `byte_count - current_width` columns, making right borders drift left even though byte counts match.

**Translation**: We made byte counts equal but VISUAL alignment is now broken the other way.

## The Real Question

Why do we want equal byte counts?

**Answer**: Because the box border character (┃) is added AFTER padding, so all lines need same byte count to have borders align.

## The Actual Problem (GLOBAL)

The issue isn't in `_pad_to_width()` - it's in how we USE it!

### Current Pattern (BROKEN)
```bash
# In show_box or similar:
padded=$(_pad_to_width "$content" 56)  # Pad to 56 DISPLAY columns
echo "┃ $padded ┃"                      # Add borders

# Result for emoji:
# - "📁 text" = 3 bytes, 4 display columns
# - Padded to 56 display columns = adds 52 spaces
# - Total: 3 + 52 = 55 bytes
# - With borders: "┃ " + 55 + " ┃" = different length than plain text line
```

### The Real Fix (GLOBAL)

The box TOTAL WIDTH should be consistent, not just the padding.

**Option 1**: Pad to BYTE count target
```bash
# If we want final line to be 60 bytes:
# Content: 3 bytes
# Borders: "┃ " (4 bytes) + " ┃" (4 bytes) = 8 bytes
# Available for content: 60 - 8 = 52 bytes
# Padding needed: 52 - 3 = 49 bytes
```

**Option 2**: Account for byte/display difference in border calculation
```bash
# Pad to display width (correct for terminal rendering)
padded=$(_pad_to_width "$content" 56)

# Calculate actual bytes in padded content
content_bytes=$(printf '%s' "$padded" | wc -c)

# Adjust spacing around borders to compensate
# (This is complex and error-prone)
```

**Option 3**: Use fixed-byte-width box borders
```bash
# Always use same border pattern regardless of content
# The border defines the byte width
# Content padding adjusts to fit inside
```

## Where to Fix This

Let me search for all places that use `_pad_to_width`:

1. `show_box()` - box rendering
2. `show_header_box()` - header boxes
3. `show_error()` / `show_success()` / etc - message boxes
4. Table rendering
5. Progress bars
6. Checklists
7. Any other formatting

## The Real Root Cause

We're mixing two different concepts:
1. **Visual alignment** (display width in terminal)
2. **Byte alignment** (consistent line lengths in bytes)

These are DIFFERENT when emoji/CJK are present.

## The Right Fix

**Fix at the box rendering level, not the padding level.**

`_pad_to_width()` should continue to pad to DISPLAY width (that's correct for terminal rendering).

But box functions should:
1. Calculate total box width IN BYTES
2. Account for content byte vs display width difference
3. Ensure all lines have same BYTE count

## Proposed Solution

```bash
# New function: _render_box_line()
_render_box_line() {
    local content="$1"
    local target_display_width="$2"
    local target_byte_width="$3"  # NEW: target in bytes

    # Pad to display width (correct for visual rendering)
    local padded=$(_pad_to_width "$content" "$target_display_width")

    # Calculate how many bytes we have
    local current_bytes=$(printf '%s' "$padded" | wc -c | tr -d ' ')

    # Add additional spaces to reach byte target
    local byte_padding=$((target_byte_width - current_bytes))

    if [ "$byte_padding" -gt 0 ]; then
        padded="${padded}$(_repeat_char ' ' "$byte_padding")"
    fi

    echo "┃ $padded ┃"
}
```

This way:
- Content is visually aligned (display width padding works)
- Lines are byte-aligned (additional padding for byte consistency)
- Both goals achieved

## Next Step

**REVERT the _pad_to_width change** and fix at the box rendering level instead.
