# VHS Tape: Progress Bar Widget - Rich Mode (UTF-8 + 256 colors)
# Demonstrates show_progress_bar with full UTF-8 box drawing characters

Output demos/progress_bar_rich.gif

# Terminal settings
Set Width 800
Set Height 300
Set FontSize 14
Set Theme "Dracula"

# Ensure rich mode (UTF-8 + colors)
Type "export OISEAU_MODE=rich"
Enter
Sleep 500ms

# Source oiseau library
Type "source ./oiseau.sh"
Enter
Sleep 500ms

# Show the progress bar animation
Type "for i in {0..100}; do show_progress_bar $i 100 'Processing files'; sleep 0.05; done"
Enter

# Wait for completion
Sleep 6s

# Screenshot final state
Sleep 500ms
