# Oiseau VHS Demo GIFs

Programmatically generated terminal GIFs using [VHS](https://github.com/charmbracelet/vhs).

## Test: Progress Bar Widget

Single GIF demonstrating `show_progress_bar` widget in all three terminal modes sequentially.

![Progress Bar - All Modes](progress_bar.gif)

**Demonstrates:**
1. **Rich mode** (UTF-8 + 256 colors) - Full box drawing characters
2. **Color mode** (ASCII + 256 colors) - ASCII progress bars with colors
3. **Plain mode** (ASCII only) - No colors, plain text

**Features shown:**
- Multi-line formatted shell commands
- Progress bar animation in place (not scrolling)
- Mode transitions with `clear` between demos
- Proper spacing and readability

## Technical Notes

**Key environment variables:**
- `OISEAU_MODE=rich|color` - Force specific rendering mode
- `OISEAU_PROGRESS_ANIMATE=1` - Force animation (required for VHS)
- `UI_DISABLE=1` - Force plain mode

**VHS is not detected as TTY by default**, so `OISEAU_PROGRESS_ANIMATE=1` is required to enable in-place progress bar updates instead of line-by-line output.

## Generating the GIF

```bash
vhs demos/progress_bar.tape
```

## Approach: One Tape File Per Widget

**Strategy:** Each widget gets ONE tape file that demonstrates all three modes sequentially.

**Benefits:**
- Easier maintenance (1 file vs 3 files per widget)
- Single GIF shows complete widget capabilities
- Consistent format across all widgets
- Smaller total file size

**Next:** Create tape files for remaining 31 widgets using this pattern.
