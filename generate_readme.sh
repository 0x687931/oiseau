#!/bin/bash
# Generate README using Oiseau's own UI components
# This demonstrates Oiseau's capabilities while documenting them

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/oiseau.sh"

# Force ASCII mode for GitHub web compatibility
export OISEAU_MODE="ascii"

# Header
show_header_box "Oiseau" "Beautiful terminal UI library for Bash" "github.com/0x687931/oiseau"

echo ""

# Introduction
cat << 'EOF'
Oiseau is a pure Bash terminal UI library that brings modern, beautiful
interfaces to shell scripts with zero dependencies.

Features:
  • Rich UTF-8 box drawing characters
  • Fallback to ASCII for compatibility
  • Interactive menus with arrow key navigation
  • Progress bars, spinners, and animations
  • Markdown-style text formatting
  • Color and plain text modes
EOF

echo ""
echo ""

# Installation
show_box success "Quick Start" "Clone and source in your script - no dependencies required!" \
    "git clone https://github.com/0x687931/oiseau.git" \
    "source ./oiseau.sh"

echo ""

# Usage Example
cat << 'EOF'
Example Usage:

  #!/bin/bash
  source ./oiseau.sh

  # Show a success message
  show_box success "Build Complete" "Application built successfully"

  # Interactive menu
  menu_items=("Deploy" "Test" "Cancel")
  selected=$(ask_list "Choose action:" menu_items)
  show_success "You selected: $selected"
EOF

echo ""
echo ""

# Display Modes
cat << 'EOF'
Display Modes:

  RICH MODE (default)
    export OISEAU_MODE="rich"
    • UTF-8 box drawing: ┏━┓ ┃ ┗━┛
    • Full color support
    • Emoji and icons: ✓ ✗ ⚠ ℹ

  ANSI/COLOR MODE
    export OISEAU_MODE="ansi"
    • ASCII box drawing: +-+ | +-+
    • Full color support
    • ASCII icons: + x ! i

  ASCII/PLAIN MODE
    export OISEAU_MODE="ascii"
    • ASCII box drawing: +-+ | +-+
    • No colors (monochrome)
    • ASCII icons: + x ! i
EOF

echo ""
echo ""

# Example boxes
show_box error "Connection Failed" "Unable to reach database at localhost:5432" \
    "systemctl start postgresql" \
    "pg_isready -h localhost"

echo ""

show_box warning "Disk Space Low" "Only 2.1 GB remaining on /dev/sda1" \
    "sudo apt-get clean" \
    "sudo journalctl --vacuum-time=7d" \
    "ncdu /"

echo ""

show_box info "System Requirements" "Minimum: Bash 3.2+ (macOS compatible). Recommended: Bash 4.0+ for best performance and UTF-8 terminal for rich mode."

echo ""

# Core Functions
cat << 'EOF'
Core Functions:

  MESSAGE BOXES
    show_box [type] "title" "message" ["command1" "command2" ...]
    Types: success, error, warning, info (or empty for info)

  SIMPLE MESSAGES
    show_success "message"
    show_error "message"
    show_warning "message"
    show_info "message"

  INTERACTIVE MENUS
    ask_list "prompt" array_name [--multi]
    ask_choice "prompt" array_name
    ask_confirm "question?" [default_y|default_n]

  PROGRESS & STATUS
    show_progress_bar current total "label"
    show_spinner "message" &  # Run in background
    show_status success|error|warning|info "text"

  HEADERS & LAYOUT
    show_header_box "title" "subtitle" "info"
    show_section_header "title" [step] [total] [subtitle]
    show_divider [character] [color]
EOF

echo ""
echo ""

# Testing
cat << 'EOF'
Testing & Examples:

  Run test suite:
    ./run_tests.sh                # All tests (auto mode)
    ./run_tests.sh --rich         # Rich mode
    ./run_tests.sh --ansi         # ANSI mode
    ./run_tests.sh --ascii        # ASCII mode

  View examples:
    ./examples/help_menu_demo.sh  # Interactive menus
    ./examples/mode_demo.sh       # Display modes
    ./examples/progress_demo.sh   # Progress bars
EOF

echo ""
echo ""

# Contributing
cat << 'EOF'
Contributing:

  1. Fork the repository
  2. Create feature branch: git checkout -b feature/name
  3. Make changes and add tests
  4. Run test suite: ./run_tests.sh
  5. Submit pull request

  Please ensure:
    • All tests pass
    • Code works in Bash 3.2+
    • Examples demonstrate new features
EOF

echo ""
echo ""

# Footer
cat << 'EOF'
License & Links:

  MIT License - free for commercial and personal use

  Repository: https://github.com/0x687931/oiseau
  Issues:     https://github.com/0x687931/oiseau/issues
  License:    https://github.com/0x687931/oiseau/blob/main/LICENSE
EOF

echo ""
show_success "Generated with Oiseau!"
echo ""
