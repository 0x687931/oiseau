[3J[H[2J
+==========================================================+
|                                                          |
|   Oiseau                                                 |
|                                                          |
|   Beautiful terminal UI library for Bash                 |
|                                                          |
+==========================================================+


+==========================================================+
|  [i]  About                                              |
+==========================================================+
|                                                          |
|  Oiseau is a pure Bash terminal UI library that brings   |
|  modern,                                                 |
|                                                          |
|  To resolve:                                             |
|    beautiful interfaces to shell scripts with zero dependencies.|
|                                                          |
|    • Rich UTF-8 box drawing characters                   |
|    • Fallback to ASCII for compatibility                 |
|    • Interactive menus with arrow key navigation         |
|    • Progress bars, spinners, and animations             |
|    • Markdown-style text formatting                      |
|    • Color and plain text modes                          |
|                                                          |
+==========================================================+

+==========================================================+
|  [OK]  Installation                                      |
+==========================================================+
|                                                          |
|  # Clone the repository                                  |
|                                                          |
|  To resolve:                                             |
|    git clone https://github.com/0x687931/oiseau.git      |
|                                                          |
|    # Source in your script                               |
|    source ./oiseau.sh                                    |
|                                                          |
|    # Start using immediately - no dependencies!          |
|                                                          |
+==========================================================+

+==========================================================+
|  [i]  Quick Start                                        |
+==========================================================+
|                                                          |
|  #!/bin/bash                                             |
|                                                          |
|  To resolve:                                             |
|    source ./oiseau.sh                                    |
|                                                          |
|    # Show a success message                              |
|    show_box success "Build Complete" \                   |
|        "Application built successfully" \                |
|        "Ready to deploy"                                 |
|                                                          |
|    # Interactive menu                                    |
|    menu_items=("Deploy" "Test" "Cancel")                 |
|    selected=$(ask_list "Choose action:" menu_items)      |
|    show_success "You selected: $selected"                |
|                                                          |
+==========================================================+

+==========================================================+
|  [i]  Core Features                                      |
+==========================================================+
|                                                          |
|  MESSAGE BOXES                                           |
|                                                          |
|  To resolve:                                             |
|      show_box [type] "Title" "Line 1" "Line 2" ...       |
|      Types: success, error, warning, info                |
|                                                          |
|    INTERACTIVE MENUS                                     |
|      ask_list "Prompt" array_name                        |
|      ask_choice "Prompt" array_name                      |
|      Supports: arrow keys, multi-select, filtering       |
|                                                          |
|    PROGRESS & STATUS                                     |
|      show_progress 75 "Loading..."                       |
|      show_spinner "Processing..." &                      |
|      show_status success "Complete"                      |
|                                                          |
|    TEXT FORMATTING                                       |
|      format_markdown "**bold** _italic_ `code`"          |
|      Colors: $COLOR_SUCCESS, $COLOR_ERROR, $COLOR_WARNING|
|                                                          |
+==========================================================+

+==========================================================+
|  [i]  Display Modes                                      |
+==========================================================+
|                                                          |
|  RICH MODE (default)                                     |
|                                                          |
|  To resolve:                                             |
|      export OISEAU_MODE="rich"                           |
|      • UTF-8 box drawing: ┏━┓ ┃ ┗━┛                      |
|      • Full color support                                |
|      • Emoji and icons: ✓ ✗ ⚠ ℹ                          |
|                                                          |
|    ANSI/COLOR MODE                                       |
|      export OISEAU_MODE="ansi"                           |
|      • ASCII box drawing: +-+ | +-+                      |
|      • Full color support                                |
|      • ASCII icons: + x ! i                              |
|                                                          |
|    ASCII/PLAIN MODE                                      |
|      export OISEAU_MODE="ascii"                          |
|      • ASCII box drawing: +-+ | +-+                      |
|      • No colors (monochrome)                            |
|      • ASCII icons: + x ! i                              |
|                                                          |
+==========================================================+

+==========================================================+
|  [X]  Connection Failed                                  |
+==========================================================+
|                                                          |
|  Unable to reach database at localhost:5432              |
|                                                          |
|  To resolve:                                             |
|                                                          |
|    To resolve:                                           |
|      systemctl start postgresql                          |
|      pg_isready -h localhost                             |
|                                                          |
+==========================================================+

+==========================================================+
|  [!]  Disk Space Low                                     |
+==========================================================+
|                                                          |
|  Only 2.1 GB remaining on /dev/sda1                      |
|                                                          |
|  To resolve:                                             |
|                                                          |
|    Consider:                                             |
|      • Clear temporary files                             |
|      • Remove old logs                                   |
|      • Archive unused data                               |
|                                                          |
+==========================================================+

+==========================================================+
|  [i]  System Requirements                                |
+==========================================================+
|                                                          |
|  Minimum:                                                |
|                                                          |
|  To resolve:                                             |
|      • Bash 3.2+ (macOS compatible)                      |
|      • No external dependencies                          |
|                                                          |
|    Recommended:                                          |
|      • Bash 4.0+ for best performance                    |
|      • UTF-8 terminal for rich mode                      |
|                                                          |
+==========================================================+

+==========================================================+
|  [i]  Testing & Examples                                 |
+==========================================================+
|                                                          |
|  RUN TESTS                                               |
|                                                          |
|  To resolve:                                             |
|      ./run_tests.sh                    # All tests       |
|      ./run_tests.sh --rich             # Rich mode       |
|      ./run_tests.sh --ansi             # ANSI mode       |
|      ./run_tests.sh --ascii            # ASCII mode      |
|                                                          |
|    VIEW EXAMPLES                                         |
|      ./examples/help_menu_demo.sh      # Interactive menus|
|      ./examples/mode_demo.sh           # Display modes   |
|      ./examples/progress_demo.sh       # Progress bars   |
|                                                          |
+==========================================================+

+==========================================================+
|  [i]  API Reference                                      |
+==========================================================+
|                                                          |
|  BOXES & MESSAGES                                        |
|                                                          |
|  To resolve:                                             |
|      show_box [type] "title" "line1" "line2" ...         |
|      show_header_box "title" "subtitle" "info"           |
|      show_success|error|warning|info "message"           |
|                                                          |
|    INTERACTIVE                                           |
|      ask_list "prompt" array_name [--multi]              |
|      ask_choice "prompt" array_name                      |
|      ask_confirm "question" [default_y|default_n]        |
|                                                          |
|    PROGRESS & STATUS                                     |
|      show_progress percent "label"                       |
|      show_spinner "message" & spinner_pid=$!             |
|      kill $spinner_pid                                   |
|      show_status success|error|warning|info "text"       |
|                                                          |
|    FORMATTING                                            |
|      format_markdown "**bold** _italic_ `code`"          |
|      format_code "syntax highlighted code"               |
|                                                          |
|    LAYOUT                                                |
|      show_table header_array data_array                  |
|      show_columns col1 col2 col3                         |
|      show_divider [character] [color]                    |
|                                                          |
+==========================================================+

+==========================================================+
|  [i]  Contributing                                       |
+==========================================================+
|                                                          |
|  We welcome contributions!                               |
|                                                          |
|  To resolve:                                             |
|                                                          |
|    1. Fork the repository                                |
|    2. Create feature branch: git checkout -b feature/name|
|    3. Make changes and add tests                         |
|    4. Run test suite: ./run_tests.sh                     |
|    5. Submit pull request                                |
|                                                          |
|    Please ensure:                                        |
|      • All tests pass                                    |
|      • Code works in Bash 3.2+                           |
|      • Examples demonstrate new features                 |
|                                                          |
+==========================================================+

+==========================================================+
|  [i]  License & Links                                    |
+==========================================================+
|                                                          |
|  MIT License - free for commercial and personal use      |
|                                                          |
|  To resolve:                                             |
|                                                          |
|    Repository: https://github.com/0x687931/oiseau        |
|    Issues:     https://github.com/0x687931/oiseau/issues |
|    License:    https://github.com/0x687931/oiseau/blob/main/LICENSE|
|                                                          |
+==========================================================+

./generate_readme.sh: line 207: show_status: command not found
