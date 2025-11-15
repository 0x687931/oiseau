#!/bin/bash
# Phase 7 Demo: Help Menu Widget
# Shows usage of show_help() and show_help_paged() functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/oiseau.sh"

clear

# Demo 1: Simple help menu
show_header_box "Phase 7: Help Menu Widget" "Two new display functions for formatted help"

echo ""
echo -e "${COLOR_MUTED}Demo 1: Basic Help Menu with show_help()${RESET}"
echo ""

# Define help items
app_help=(
    "NAVIGATION|"
    "q|Quit the application"
    "h|Show this help menu"
    "j|Scroll down"
    "k|Scroll up"
    ""
    "EDITING|"
    "e|Edit selected item"
    "d|Delete selected item"
    "a|Add new item"
    ""
    "DISPLAY|"
    "s|Sort by name"
    "f|Filter results"
    "c|Toggle color mode"
)

show_help "Application Commands" app_help 15

echo ""
echo -e "${COLOR_MUTED}Press Enter to continue to Demo 2...${RESET}"
read -r

clear

# Demo 2: Help menu with different key width
show_header_box "Phase 7 Demo: Part 2" "Customizing key column width"

echo ""
echo -e "${COLOR_MUTED}Demo 2: Help Menu with Custom Key Width${RESET}"
echo ""

keyboard_help=(
    "SHORTCUTS|"
    "Ctrl+S|Save file"
    "Ctrl+Z|Undo"
    "Ctrl+Y|Redo"
    "Ctrl+A|Select all"
    ""
    "NAVIGATION|"
    "Ctrl+Home|Go to beginning"
    "Ctrl+End|Go to end"
    "Page Up|Scroll up one page"
    "Page Down|Scroll down one page"
)

show_help "Keyboard Shortcuts" keyboard_help 25

echo ""
echo -e "${COLOR_MUTED}Press Enter to continue to Demo 3...${RESET}"
read -r

clear

# Demo 3: Paged help menu
show_header_box "Phase 7 Demo: Part 3" "Using show_help_paged() for longer content"

echo ""
echo -e "${COLOR_MUTED}Demo 3: Paged Help Menu${RESET}"
echo -e "${COLOR_MUTED}(Large help menu with pauses)${RESET}"
echo ""

large_help=(
    "BASIC COMMANDS|"
    "status|Show current status"
    "init|Initialize new project"
    "build|Build the project"
    "test|Run tests"
    "clean|Clean build artifacts"
    ""
    "GIT OPERATIONS|"
    "git add|Stage files"
    "git commit|Create commit"
    "git push|Push to remote"
    "git pull|Pull from remote"
    "git branch|List branches"
    ""
    "FILE MANAGEMENT|"
    "cp|Copy files"
    "rm|Remove files"
    "mv|Move files"
    "mkdir|Create directory"
    "ls|List contents"
)

OISEAU_HELP_NO_KEYPRESS=0 show_help_paged "Extended Commands" large_help 8 20

echo ""
show_header_box "Demo Complete" "The show_help() functions are now part of Oiseau"

echo ""
echo -e "${COLOR_SUCCESS}${BOLD}Summary:${RESET}"
echo ""
echo -e "  ${COLOR_SUCCESS}✓${RESET} show_help() - Display help menu with optional sections"
echo -e "  ${COLOR_SUCCESS}✓${RESET} show_help_paged() - Display help in pages with pauses"
echo -e "  ${COLOR_SUCCESS}✓${RESET} Both reuse show_header_box() and print_kv()"
echo -e "  ${COLOR_SUCCESS}✓${RESET} Full support for Rich, Color, and Plain modes"
echo -e "  ${COLOR_SUCCESS}✓${RESET} Input sanitization via _escape_input()"
echo ""

echo -e "${COLOR_MUTED}Key features:${RESET}"
echo -e "  • Section headers with pipe-separated format"
echo -e "  • Automatic TTY detection for keypress prompt"
echo -e "  • Customizable key column width"
echo -e "  • Optional OISEAU_HELP_NO_KEYPRESS for scripting"
echo -e "  • Graceful degradation across terminal modes"
echo ""
