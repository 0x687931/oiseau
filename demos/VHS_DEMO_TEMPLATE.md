# VHS Demo Template for Oiseau Widgets

This template documents the standard framework for creating VHS demos that show widgets in all 3 modes (Rich, Color, Plain).

## Framework Pattern

### Part 1: Visible Code (What User Sees)
Show simple, clean code that a normal user would write, assuming TTY auto-detection works:

```tape
# Show the demo description
Type "# Demo: [Widget Name] in all 3 modes"
Enter
Sleep 500ms

# Source the library
Type "source ./oiseau.sh"
Enter
Sleep 500ms

# Show the simple usage code (NO environment variables, NO mode overrides)
Type "[user's simple code line 1]"
Enter
Sleep 300ms

Type "[user's simple code line 2]"
Enter
Sleep 300ms

# ... more lines as needed

Type "done"  # or final line
Enter
Sleep 1s
```

### Part 2: Hidden Execution (What Actually Runs)
Execute the actual demo code with mode overrides and line positioning:

```tape
# Reserve lines for the three widgets and execute actual demo code (hidden)
Hide
Type "echo ''"
Enter
Type "echo ''"
Enter
Type "echo ''"
Enter
Type "echo ''"
Enter

# Execute with explicit mode controls for demo
Type "[actual demo code with OISEAU_MODE=rich ... line 1]"
Enter
Type "[actual demo code with OISEAU_MODE=color ... line 2]"
Enter
Type "[actual demo code with UI_DISABLE=1 ... line 3]"
Enter

Type "done"  # or final line
Enter
Show

# Wait for animation/demonstration to complete
Sleep [appropriate duration]
Sleep 3s
```

## Key Principles

1. **Visible = Simple**: Show what a normal user would type (clean, no hacks)
2. **Hidden = Demo Magic**: Use environment variables and line positioning to demonstrate all 3 modes
3. **Line-by-line typing**: Type entire lines, not character-by-character (use default Type speed)
4. **Reserve space first**: Always reserve empty lines before running multi-line widgets
5. **Consistent timing**: 500ms after major sections, 300ms between code lines, 1s before execution

## Example: Progress Bar

**Visible code (simple):**
```bash
for i in {0..100}; do
  show_progress_bar $i 100 'Processing'
  sleep 0.05
done
```

**Hidden execution (demo):**
```bash
# Reserve 4 lines
echo ''
echo ''
echo ''
echo ''

# Execute with mode overrides
for i in {0..100}; do
  OISEAU_MODE=rich OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Rich mode' 1
  OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Color mode' 2
  UI_DISABLE=1 OISEAU_PROGRESS_ANIMATE=1 show_progress_bar $i 100 'Plain mode' 3
  sleep 0.05
done
```

## VHS Settings (Standard)

```tape
Output demos/[widget_name].gif
Set Width 800
Set Height 400
Set FontSize 14
Set Theme "Dracula"
```

## Notes

- Always escape `$` as `\$` in VHS Type commands
- Use `Hide/Show` to execute code without displaying it
- Keep GIF file size under 500KB for web performance
- Test with the corresponding `test_[widget_name].sh` script before generating GIF
