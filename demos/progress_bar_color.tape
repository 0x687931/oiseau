# VHS Tape: Progress Bar Widget - Color Mode (ASCII + 256 colors)
# Demonstrates show_progress_bar with ASCII characters but full colors

Output demos/progress_bar_color.gif

# Terminal settings
Set Width 800
Set Height 300
Set FontSize 14
Set Theme "Dracula"

# Force color mode (ASCII + colors, no UTF-8) and animation
Type "export OISEAU_MODE=color OISEAU_PROGRESS_ANIMATE=1"
Enter
Sleep 500ms

# Source oiseau library
Type "source ./oiseau.sh"
Enter
Sleep 500ms

# Show the progress bar animation
Type "for i in {0..100}; do show_progress_bar $i 100 'Building project'; sleep 0.05; done"
Enter

# Wait for completion
Sleep 6s

# Screenshot final state
Sleep 500ms
