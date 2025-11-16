# Oiseau VHS Demo GIFs

Programmatically generated terminal GIFs using [VHS](https://github.com/charmbracelet/vhs).

## Test: Progress Bar Widget

Testing VHS generation for the `show_progress_bar` widget in all three terminal modes.

### Rich Mode (UTF-8 + 256 colors)

![Progress Bar - Rich Mode](progress_bar_rich.gif)

**Mode:** `OISEAU_MODE=rich`
**Features:** Full UTF-8 box drawing characters, 256-color ANSI palette

### Color Mode (ASCII + 256 colors)

![Progress Bar - Color Mode](progress_bar_color.gif)

**Mode:** `OISEAU_MODE=color`
**Features:** ASCII characters (`#`, `=`, `>`), 256-color ANSI palette

### Plain Mode (ASCII only)

![Progress Bar - Plain Mode](progress_bar_plain.gif)

**Mode:** `UI_DISABLE=1` (plain mode)
**Features:** ASCII characters only, no colors (pipes/redirects)

## Generating GIFs

Each GIF is generated from a `.tape` file:

```bash
# Generate rich mode GIF
vhs demos/progress_bar_rich.tape

# Generate color mode GIF
vhs demos/progress_bar_color.tape

# Generate plain mode GIF
vhs demos/progress_bar_plain.tape
```

## Next Steps

After testing proves successful:
- Create tape files for all 32 Oiseau widgets
- Generate 3 GIFs per widget (rich, color, plain modes)
- Integrate GIFs into main README.md
- Automate generation with `make demos` or similar
