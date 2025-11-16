# VHS Tape: Progress Bar Widget - All Three Modes
# Demonstrates show_progress_bar in rich, color, and plain modes

Output demos/progress_bar.gif

# Terminal settings
Set Width 800
Set Height 400
Set FontSize 14
Set Theme "Dracula"

# ==============================================================================
# RICH MODE (UTF-8 + 256 colors)
# ==============================================================================

Type "# Rich mode: UTF-8 + colors"
Enter
Sleep 500ms

Type "export OISEAU_MODE=rich"
Enter
Sleep 200ms

Type "export OISEAU_PROGRESS_ANIMATE=1"
Enter
Sleep 200ms

Type "source ./oiseau.sh"
Enter
Sleep 800ms

Type "for i in {0..100}; do"
Enter
Sleep 300ms

Type "  show_progress_bar $i 100 'Processing files'"
Enter
Sleep 300ms

Type "  sleep 0.05"
Enter
Sleep 300ms

Type "done"
Enter

# Wait for completion
Sleep 6s

# Pause before mode switch
Sleep 2s

# Clear for next demo (hidden)
Hide
Type "clear"
Enter
Show
Sleep 1s

# ==============================================================================
# COLOR MODE (ASCII + 256 colors)
# ==============================================================================

Type "# Color mode: ASCII + colors"
Enter
Sleep 500ms

Type "export OISEAU_MODE=color"
Enter
Sleep 200ms

Type "source ./oiseau.sh"
Enter
Sleep 800ms

Type "for i in {0..100}; do"
Enter
Sleep 300ms

Type "  show_progress_bar $i 100 'Building project'"
Enter
Sleep 300ms

Type "  sleep 0.05"
Enter
Sleep 300ms

Type "done"
Enter

# Wait for completion
Sleep 6s

# Pause before mode switch
Sleep 2s

# Clear for next demo (hidden)
Hide
Type "clear"
Enter
Show
Sleep 1s

# ==============================================================================
# PLAIN MODE (ASCII only, no colors)
# ==============================================================================

Type "# Plain mode: ASCII only"
Enter
Sleep 500ms

Type "export UI_DISABLE=1"
Enter
Sleep 200ms

Type "source ./oiseau.sh"
Enter
Sleep 800ms

Type "for i in {0..100}; do"
Enter
Sleep 300ms

Type "  show_progress_bar $i 100 'Downloading data'"
Enter
Sleep 300ms

Type "  sleep 0.05"
Enter
Sleep 300ms

Type "done"
Enter

# Wait for completion
Sleep 6s

# Final pause to view result
Sleep 3s
