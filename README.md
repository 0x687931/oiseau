# 🐦 Oiseau

**A modern, zero-dependency terminal UI library for Bash**

Oiseau (French for "bird") brings beautiful, modern UI components to your bash scripts with zero dependencies. Features 256-color ANSI palette, 30+ reusable widgets, smart terminal detection, and automatic degradation for maximum compatibility.

```bash
source oiseau/oiseau.sh

show_success "Operation completed!"
show_error "Something went wrong"
show_box warning "Uncommitted Changes" "You have 3 uncommitted files" \
    "git add ." \
    "git commit -m 'message'"
```

---

## ✨ Features

- **🎨 256-Color ANSI Palette** - Beautiful, modern color scheme
- **📦 Zero Dependencies** - Pure bash, no external tools required
- **🔄 Smart Degradation** - Automatically adapts to terminal capabilities (rich → color → plain)
- **🛡️ Security First** - Built-in input sanitization prevents code injection
- **⚡ Fast** - Caches terminal detection for minimal overhead
- **🌍 Universal** - Works in pipes, redirects, CI/CD, and all terminal emulators
- **📝 30+ Widgets** - Messages, boxes, progress bars, checklists, spinners, validated inputs, and more
- **🔐 Smart Input** - Password masking, email/number validation, auto-detection

---

## 📦 Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/oiseau.git

# Source in your script
source oiseau/oiseau.sh

# Start using widgets
show_success "Oiseau is ready!"
```

### Manual Install

Download `oiseau.sh` and source it in your scripts:

```bash
curl -o oiseau.sh https://raw.githubusercontent.com/yourusername/oiseau/main/oiseau.sh
source ./oiseau.sh
```

### Requirements

- Bash 4.0+ (most systems)
- That's it! No other dependencies.

---

## 🚀 Quick Examples

### Simple Messages

```bash
show_success "Build completed successfully"
show_error "Failed to connect to server"
show_warning "This will delete all files"
show_info "Processing 142 items..."
```

Output:
```
  ✓  Build completed successfully
  ✗  Failed to connect to server
  ⚠  This will delete all files
  ℹ  Processing 142 items...
```

### Styled Boxes

```bash
show_box error "Connection Failed" \
    "Unable to reach database at localhost:5432" \
    "systemctl start postgresql" \
    "pg_isready -h localhost"
```

Output:
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ✗  Connection Failed                                    ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                                          ┃
┃  Unable to reach database at localhost:5432             ┃
┃                                                          ┃
┃  To resolve:                                             ┃
┃    systemctl start postgresql                           ┃
┃    pg_isready -h localhost                              ┃
┃                                                          ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### Progress Bar

```bash
for i in {1..10}; do
    show_progress_bar "$i" 10 "Installation"
    sleep 0.5
done
```

Output:
```
Installation: ████████████░░░░░░░░ 60% (6/10)
```

### Checklists

```bash
tasks=(
    "done|Build Docker image|Completed in 45s"
    "active|Run tests|156 tests running..."
    "pending|Deploy to staging|Waiting"
)
show_checklist tasks
```

Output:
```
  ✓  Build Docker image     Completed in 45s
  ●  Run tests              156 tests running...
  ○  Deploy to staging      Waiting
```

### Section Headers

```bash
show_section_header "Deploy Application" 2 4 "Building Docker image"
```

Output:
```
╭────────────────────────────────────────────────────────────╮
│  Deploy Application                                        │
│  Step 2 of 4 › Building Docker image                       │
╰────────────────────────────────────────────────────────────╯
```

---

## 📚 Widget Reference

Oiseau includes **25+ widgets** organized into the following categories:

### Status Messages

| Function | Description |
|----------|-------------|
| `show_success "msg"` | Green checkmark message |
| `show_error "msg"` | Red X message |
| `show_warning "msg"` | Orange warning message |
| `show_info "msg"` | Blue info message |

### Headers

| Function | Description |
|----------|-------------|
| `show_header "title"` | Simple bold header |
| `show_subheader "title"` | Muted subheader |
| `show_header_box "title" [subtitle]` | Decorative boxed header with optional subtitle |
| `show_section_header "title" [step] [total] [subtitle]` | Boxed header with optional step counter |

### Boxes & Containers

| Function | Usage |
|----------|-------|
| `show_box <type> <title> <msg> [cmd...]` | Styled box with title, message, and optional commands |
| `show_summary "title" "item1" "item2" ...` | Summary box with multiple items |

**Box Types:** `error`, `warning`, `info`, `success`

### Progress Indicators

| Function | Description |
|----------|-------------|
| `show_progress_bar <current> <total> [label]` | Animated progress bar with percentage |
| `show_checklist <array_name>` | Checklist with status icons (done/active/pending/skip) |

**Progress Bar Features:**
- **Auto-animation:** Updates in place when in TTY
- **Smart fallback:** Prints new lines in pipes/redirects
- **Validation:** Prevents division by zero, validates numeric input
- **Customizable:** Width and animation can be overridden

**Environment Variables:**
- `OISEAU_PROGRESS_ANIMATE` - Force animation on/off (default: auto-detect)
- `OISEAU_PROGRESS_WIDTH` - Bar width in characters (default: 20)

**Example:**
```bash
for i in {1..100}; do
  show_progress_bar $i 100 "Downloading"
  sleep 0.05
done
```

**Checklist Statuses:**
```bash
tasks=(
    "done|Task completed|Additional info"
    "active|Task in progress|Working..."
    "pending|Task waiting|Not started"
    "skip|Task skipped|Not needed"
)
show_checklist tasks
```

### Spinner (Loading Indicators)

| Function | Description |
|----------|-------------|
| `show_spinner "message"` | Animated loading spinner (runs until killed) |
| `start_spinner "message"` | Start spinner in background, tracks PID |
| `stop_spinner` | Stop background spinner started with start_spinner |

**Styles:** dots (default), line, circle, pulse, arc

**Environment Variables:**
- `OISEAU_SPINNER_STYLE` - Spinner animation style
- `OISEAU_SPINNER_FPS` - Frames per second (default: 10)

**Example:**
```bash
start_spinner "Processing files..."
# ... do work ...
stop_spinner
show_success "Done!"
```

### Interactive Prompts

| Function | Returns | Description |
|----------|---------|-------------|
| `prompt_confirm "msg" [default]` | 0=yes, 1=no | Yes/no confirmation |
| `ask_yes_no "msg"` | 0=yes, 1=no | Alias for prompt_confirm |
| `ask_input "msg" [default] [mode]` | string | Enhanced text input with validation |
| `ask_list "prompt" array_name [mode]` | string(s) | Interactive list selection with arrow keys |

#### Enhanced Text Input

The `ask_input` function provides secure text input with validation, password masking, and auto-detection:

**Modes:**
- `text` (default) - Normal text input
- `password` - Masked input (• in UTF-8, * in ASCII/Plain), backspace support
- `email` - Validates email format, loops until valid
- `number` - Validates numeric input only

**Auto-detection:**
Automatically switches to password mode when prompt contains: `password`, `passwd`, `pass`, `secret`, `token`, `key`, or `api`

**Examples:**

```bash
# Basic text input with default
name=$(ask_input "Your name" "John")

# Password - auto-detected from prompt
password=$(ask_input "Enter password")          # Shows • (UTF-8) or * (ASCII)
api_key=$(ask_input "API key")                  # Auto-detected as password

# Explicit password mode
password=$(ask_input "PIN" "" "password")

# Email validation (loops until valid)
email=$(ask_input "Email address" "" "email")

# Number validation (loops until valid)
age=$(ask_input "Your age" "" "number")
```

**Security features:**
- All input sanitized with `_escape_input()`
- Prompts sanitized before display
- No ANSI injection or command substitution possible
- Password mode never echoes sensitive data

#### Interactive List Selection

The `ask_list` function provides interactive list selection with arrow key navigation:

**Modes:**
- `single` (default) - Select one item with Enter
- `multi` - Toggle multiple items with Space, confirm with Enter

**Navigation:**
- Arrow keys (↑↓) or vim keys (j/k) to navigate
- Enter to select (single mode) or confirm (multi mode)
- Space to toggle selection (multi mode only)
- q or Esc to cancel

**Auto-detection:**
Automatically falls back to numbered list in non-TTY environments (pipes, redirects)

**Mode-aware:**
- UTF-8 mode: › cursor, ✓ checkbox
- ASCII mode: > cursor, X checkbox

**Examples:**

```bash
# Single-select
options=("Deploy to staging" "Deploy to production" "Rollback")
choice=$(ask_list "Select action:" options)
echo "You selected: $choice"

# Multi-select
files=("app.log" "error.log" "access.log" "debug.log")
selected=$(ask_list "Select files to delete:" files "multi")

# Process multi-select results (newline-separated)
echo "$selected" | while IFS= read -r file; do
    echo "Deleting: $file"
done
```

**Features:**
- Bash 3.x compatible (works on macOS default bash)
- Input sanitization built-in
- Real-time screen updates with smooth navigation
- Graceful non-TTY fallback

### Formatting Helpers

| Function | Description |
|----------|-------------|
| `print_kv "key" "value" [width]` | Key-value pair with aligned columns |
| `print_command "cmd"` | Code-styled command display |
| `print_command_inline "text"` | Inline code-styled text |
| `print_item "text"` | Bulleted list item |
| `print_section "title"` | Section title (colored header) |
| `print_step <num> "text"` | Numbered step with text |
| `print_next_steps "step1" "step2" ...` | Numbered next steps list |

### Backward Compatibility Aliases

The following `print_*` aliases are provided for backward compatibility:

| Alias | Maps To |
|-------|---------|
| `print_info()` | `show_info()` |
| `print_success()` | `show_success()` |
| `print_error()` | `show_error()` |
| `print_warning()` | `show_warning()` |
| `print_header()` | `show_header()` |
| `print_box()` | `show_summary()` |

---

## 🎨 Customization

Oiseau is designed to **work beautifully with zero configuration**. The defaults are carefully chosen for modern terminals while gracefully degrading to ASCII in limited environments.

### Environment Variables

Three simple environment variables let you customize Oiseau globally:

#### 1. `OISEAU_BORDER_STYLE` - Change Border Style

Force a specific border style for all widgets:

```bash
export OISEAU_BORDER_STYLE="rounded"  # Friendly, modern (╭─╮)
export OISEAU_BORDER_STYLE="double"   # Emphasis, important (┏━┓)
export OISEAU_BORDER_STYLE="ascii"    # Universal fallback (+--+)
```

**Border Styles:**

- **Rounded** (`╭─╮`): Used by headers, info boxes, section headers
- **Double** (`┏━┓`): Used by error boxes, warning boxes, critical alerts
- **ASCII** (`+--+`): Auto-enabled for pipes, redirects, or `NO_COLOR=1`

#### 2. `OISEAU_BOX_WIDTH` - Change Box Width

Override the default 60-column width:

```bash
export OISEAU_BOX_WIDTH="80"   # Wider boxes
export OISEAU_BOX_WIDTH="40"   # Narrower boxes
```

Boxes automatically clamp to terminal width - 4 to prevent overflow.

#### 3. Individual Color Overrides

Override specific colors using ANSI 256-color codes:

```bash
export COLOR_ERROR="196"     # Bright red (default: 204)
export COLOR_SUCCESS="46"    # Bright green (default: 114)
export COLOR_WARNING="214"   # Orange (default: 214)
export COLOR_INFO="39"       # Cyan (default: 75)
export COLOR_HEADER="141"    # Purple (default: 141)
export COLOR_MUTED="240"     # Gray (default: 240)
```

### Examples

#### Zero Configuration (Recommended)

```bash
#!/bin/bash
source oiseau.sh

show_header_box "Deployment Pipeline"
show_progress_bar 8 10 "Deploying"
show_box success "Complete" "Deployed to production"
```

Works perfectly with automatic detection.

#### Custom Border Style

```bash
#!/bin/bash
export OISEAU_BORDER_STYLE="double"
source oiseau.sh

show_box success "Complete" "All tests passed"
# Uses ┏━┓ instead of ╭─╮
```

#### Custom Brand Colors

```bash
#!/bin/bash
export COLOR_ERROR="196"    # Corporate brand red
export COLOR_SUCCESS="46"   # Corporate brand green
export OISEAU_BOX_WIDTH="80"
source oiseau.sh

show_box error "Critical Alert" "System requires immediate attention"
show_box success "All Clear" "Systems operational"
```

### Environment Variable Reference

| Variable | Values | Default | Purpose |
|----------|--------|---------|---------|
| `OISEAU_BORDER_STYLE` | `rounded`, `double`, `ascii` | Auto | Force border style |
| `OISEAU_BOX_WIDTH` | Number (20-200) | `60` | Override box width |
| `COLOR_ERROR` | ANSI 256 code | `204` | Error message color |
| `COLOR_SUCCESS` | ANSI 256 code | `114` | Success message color |
| `COLOR_WARNING` | ANSI 256 code | `214` | Warning message color |
| `COLOR_INFO` | ANSI 256 code | `75` | Info message color |
| `COLOR_HEADER` | ANSI 256 code | `141` | Header text color |
| `COLOR_MUTED` | ANSI 256 code | `240` | Muted text color |

---

## 🎨 Terminal Modes

Oiseau automatically detects your terminal capabilities and adapts:

### Rich Mode (Default)
- **Requires:** Color support + UTF-8
- **Features:** Full 256-color palette, Unicode box drawing, Unicode icons
- **Example:** Modern terminals (iTerm2, Alacritty, VS Code terminal, Claude Code)

### Color Mode
- **Requires:** Color support only
- **Features:** 256-color palette, ASCII fallback characters
- **Example:** Older terminals without UTF-8

### Plain Mode
- **Triggers:** Pipes, redirects, `NO_COLOR=1`, `UI_DISABLE=1`, or no TTY
- **Features:** No colors, ASCII-only
- **Example:** `script.sh | tee log.txt` or CI/CD environments

### Force Plain Mode

```bash
# Disable all UI enhancements
export UI_DISABLE=1
source oiseau/oiseau.sh

# Or respect NO_COLOR standard
export NO_COLOR=1
source oiseau/oiseau.sh
```

---

## 🔒 Security

Oiseau includes built-in input sanitization:

```bash
# User input is automatically escaped
user_input="$(cat untrusted_input.txt)"
show_success "$user_input"  # Safe - ANSI codes and control chars removed
```

All widget functions use `_escape_input()` internally to:
- Remove ANSI escape sequences
- Strip control characters
- Prevent code injection attacks

---

## 🖼️ Gallery

Run the interactive gallery to see all widgets in action:

```bash
cd oiseau
./gallery.sh
```

Or run in auto mode (no pauses):

```bash
OISEAU_GALLERY_AUTO=1 ./gallery.sh
```

---

## 🎮 Building TUIs (Non-Scrolling UIs)

Oiseau can build **non-scrolling Terminal User Interfaces** that refresh in place - like `htop`, `vim`, or monitoring dashboards.

### Quick Start

Run the TUI examples:

```bash
# Basic multi-view TUI
./examples/tui_demo.sh

# MVC pattern TUI with navigation
./examples/tui_mvc.sh
```

### Scrolling vs Non-Scrolling

**Scrolling (like `gallery.sh`):**
- Output accumulates and scrolls down
- Good for logs, reports, installation output
- Simple sequential display

**Non-Scrolling TUI:**
- Takes over full screen, updates in place
- Highly interactive with keyboard controls
- Good for dashboards, monitors, editors

### Basic TUI Pattern

```bash
#!/bin/bash
source oiseau.sh

# Terminal control
clear_screen() { echo -en "\033[2J\033[H"; }
hide_cursor() { echo -en "\033[?25l"; }
show_cursor() { echo -en "\033[?25h"; }

# Read single keypress
read_key() {
    local key=""
    IFS= read -rsn1 -t 1 key 2>/dev/null
    echo "$key"
}

# Render UI
render() {
    clear_screen
    show_header "My Dashboard"
    show_summary "Status" "Counter: $COUNTER"
}

# Main loop
main() {
    hide_cursor
    trap 'show_cursor; clear_screen' EXIT

    COUNTER=0
    while true; do
        render
        key=$(read_key)

        case "$key" in
            q|Q) break ;;
            ' ') COUNTER=$((COUNTER + 1)) ;;
        esac
    done
}

main
```

### Standard Key Bindings

| Key | Purpose | Example Use |
|-----|---------|-------------|
| **Q** | Quit | Exit application |
| **R** | Refresh | Force screen refresh |
| **Tab** | Next | Cycle through views/items |
| **Esc** | Back/Cancel | Return to previous view |
| **↑↓** | Navigate | Move through lists |
| **←→** | Horizontal | Switch tabs, adjust values |
| **Space** | Toggle | Toggle checkboxes, select items |
| **Enter** | Confirm | Submit, open item |
| **1-9** | Jump | Quick navigation |

### Reading Special Keys

Arrow keys and special keys send multi-byte escape sequences:

```bash
read_key() {
    local key=""
    IFS= read -rsn1 -t 1 key 2>/dev/null

    # Check for escape sequence (arrow keys, etc.)
    if [ "$key" = $'\x1b' ]; then
        local next
        IFS= read -rsn2 -t 0.1 next 2>/dev/null
        if [ -n "$next" ]; then
            key="${key}${next}"
        fi
    fi

    echo "$key"
}

# Handle keys
case "$key" in
    $'\x1b[A')  # Up arrow
        move_up
        ;;
    $'\x1b[B')  # Down arrow
        move_down
        ;;
    $'\t')      # Tab
        next_view
        ;;
    ' ')        # Space
        toggle_item
        ;;
    q|Q)        # Quit
        return 1
        ;;
esac
```

### MVC Architecture

For complex TUIs, use Model-View-Controller pattern:

```bash
# MODEL - Application state
declare -A MODEL=(
    [view]="home"
    [counter]=0
    [selected]=0
)

model::increment() {
    MODEL[counter]=$((MODEL[counter] + 1))
}

# VIEW - Rendering (no logic)
view::render() {
    clear_screen
    show_header "Counter: ${MODEL[counter]}"
    show_summary "State" "View: ${MODEL[view]}"
}

# CONTROLLER - Input handling
controller::handle_key() {
    case "$1" in
        q|Q) return 1 ;;
        ' ') model::increment ;;
    esac
    return 0
}

# MAIN LOOP
while true; do
    view::render
    key=$(read_key)
    controller::handle_key "$key" || break
done
```

### Terminal Control Reference

Essential ANSI escape codes for TUIs:

| Code | Function |
|------|----------|
| `\033[2J` | Clear entire screen |
| `\033[H` | Move cursor to home (1,1) |
| `\033[{row};{col}H` | Move cursor to position |
| `\033[?25l` | Hide cursor |
| `\033[?25h` | Show cursor |
| `\033[K` | Clear line from cursor |
| `\033[J` | Clear screen from cursor |

### Best Practices

1. **Always cleanup** - Restore cursor and terminal state on exit:
   ```bash
   cleanup() {
       show_cursor
       clear_screen
   }
   trap cleanup EXIT INT TERM
   ```

2. **Check for TTY** - TUIs require interactive terminal:
   ```bash
   if [ ! -t 0 ] || [ ! -t 1 ]; then
       echo "Error: Requires interactive terminal"
       exit 1
   fi
   ```

3. **Use timeouts** - Allow auto-refresh with non-blocking reads:
   ```bash
   # -t 1 = 1 second timeout allows refresh every second
   IFS= read -rsn1 -t 1 key 2>/dev/null
   ```

4. **Handle resize** - Detect terminal window resize:
   ```bash
   trap 'COLUMNS=$(tput cols); LINES=$(tput lines)' WINCH
   ```

### Complete Examples

See `examples/` directory:

- **`tui_demo.sh`** - Basic multi-view TUI with auto-refresh
- **`tui_mvc.sh`** - MVC pattern with interactive task list
- **`help_menu_demo.sh`** - Interactive menus with arrow key navigation (ask_list, ask_choice)
- **`TUI_GUIDE.md`** - Comprehensive TUI development guide

---

## 📖 Real-World Example

```bash
#!/bin/bash
source oiseau/oiseau.sh

# Multi-step deployment script
show_section_header "Application Deployment" 1 3 "Preparing environment"

# Checklist of tasks
tasks=(
    "done|Pull latest code|git pull origin main"
    "done|Install dependencies|npm ci completed"
    "active|Build application|Webpack bundling..."
    "pending|Run tests|Waiting"
    "pending|Deploy to production|Waiting"
)
show_checklist tasks

echo ""

# Progress indicator
show_info "Building production bundle..."
for i in {1..10}; do
    show_progress_bar "$i" 10 "Build"
    sleep 0.3
done

echo ""

# Error handling
if ! npm run build 2>/dev/null; then
    show_box error "Build Failed" \
        "Webpack encountered errors during compilation" \
        "npm run build -- --verbose" \
        "Check webpack.config.js for issues"
    exit 1
fi

echo ""

# Success summary
show_summary "Deployment Complete" \
    "Environment: Production" \
    "Build: #432" \
    "Duration: 3m 45s" \
    "Status: All health checks passed"

echo ""
show_success "Application successfully deployed!"

# Next steps
print_next_steps \
    "Monitor logs: kubectl logs -f deployment/app" \
    "Run smoke tests: npm run test:smoke" \
    "Update documentation: docs/releases/v2.0.md"
```

---

## 🤖 Multi-Agent Decision Framework

Oiseau includes a reusable **Multi-Agent Decision Framework (MADF)** for solving complex development problems using specialized AI agents working in parallel.

### What is MADF?

The framework coordinates multiple specialized agents (Performance, Maintainability, Robustness, Usability, Security, Compatibility) to:
- Analyze problems from different perspectives
- Generate diverse solution approaches
- Compare tradeoffs between approaches
- Synthesize the best combined solution

### Quick Start

Invoke the framework with a slash command:

```bash
/madf Implement a tree view widget with expand/collapse
```

Or reference the skill explicitly:

```
Please use the multi-agent-framework skill to help me decide whether to split oiseau.sh into multiple files.
```

### When to Use MADF

Use this framework for:
- New widget implementation (Tier 3)
- Architecture decisions (Tier 4)
- Performance optimizations (Tier 2-3)
- Complex bug fixes (Tier 2-3)
- API design questions (Tier 2-3)

Don't use for trivial changes (typos, comments, simple fixes).

### Example Output

The framework provides structured analysis:

1. **Problem Classification** - Complexity tier (1-4) and reasoning
2. **Agent Solutions** - Each agent's approach with pros/cons/code
3. **Comparison Matrix** - Side-by-side tradeoff analysis
4. **Synthesis** - Combined best approach from all perspectives
5. **Implementation Plan** - Concrete next steps
6. **Risks & Mitigations** - What could go wrong and how to prevent it

### Documentation

- **Framework Guide**: `docs/multi-agent-framework.md`
- **Quick Reference**: `docs/examples/madf-sessions/quick-reference.md`
- **Example Sessions**: `docs/examples/madf-sessions/`

### Configuration Files

- **Agent Skill**: `.claude/skills/multi-agent-framework.md`
- **Slash Command**: `.claude/commands/madf.md`

---

## 🧪 Testing

Oiseau includes a comprehensive test suite with 128 tests across 10 test suites.

### Run All Tests

```bash
./run_tests.sh
```

This unified test runner uses oiseau widgets to display beautiful test results with progress bars, checklists, and summary boxes.

**Output:**
```
  +==========================================================+
  |                                                          |
  |   Oiseau Test Suite Runner                               |
  |                                                          |
  +==========================================================+

  [i]  Found 10 test suites

Running tests...

Testing: 100% (10/10)
  [OK]  test_edge_cases
  [OK]  test_help_menu
  ...

  +==========================================================+
  |                                                          |
  |   Test Results Summary                                   |
  |                                                          |
  +==========================================================+

  Total Test Suites    10
  Passed               10
  Failed               0

+==========================================================+
|  [OK]  All Tests Passed!                                 |
+==========================================================+

  [+]  Code quality validated
  [+]  All widgets tested
  [+]  Security checks passed
  [+]  Bash compatibility verified
```

### Run Individual Test Suite

```bash
./tests/test_progress.sh    # Test progress bar widget
./tests/test_input.sh       # Test input validation
./tests/test_spinner.sh     # Test spinner widget
# ... etc
```

### Test Suites

- `test_edge_cases.sh` - Edge cases and code review issues
- `test_help.sh` - Help menu system validation
- `test_help_menu.sh` - Help menu backward compatibility
- `test_input.sh` - Enhanced input validation
- `test_list.sh` - Interactive list selection
- `test_mode_consistency.sh` - UTF-8/ASCII/Plain mode consistency
- `test_progress.sh` - Progress bar validation
- `test_resize.sh` - Window resize handler
- `test_spinner.sh` - Spinner widget
- `test_table.sh` - Table widget

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-widget`)
3. Make your changes
4. **Run the test suite** (`./run_tests.sh`)
5. Test in all three modes (rich, color, plain)
6. Submit a pull request

### Development

```bash
# Run test suite
./run_tests.sh

# Run gallery to test changes
./gallery.sh

# Test in different modes
OISEAU_MODE=plain ./gallery.sh
NO_COLOR=1 ./gallery.sh
UI_DISABLE=1 ./gallery.sh

# Test in pipe
./gallery.sh | cat
```

### Using MADF for Development

When contributing complex features, consider using the Multi-Agent Decision Framework:

```bash
/madf Implement [your feature name]
```

This will provide multiple perspectives on implementation approach, helping ensure your contribution considers performance, maintainability, robustness, usability, security, and compatibility.

---

## 📄 License

MIT License - see LICENSE for details

---

## 🙏 Acknowledgments

- Inspired by [Charm](https://charm.sh/) (Bubbletea, Gum, Lip Gloss)
- Inspired by [Ink](https://github.com/vadimdemedes/ink) for React-like terminal UIs
- Built for the bash scripting community

---

## 🐛 Troubleshooting

### Colors not showing

```bash
# Check terminal detection
echo "TERM=$TERM"
tput colors  # Should show 256

# Force color mode (debugging only)
export OISEAU_HAS_COLOR=1
source oiseau/oiseau.sh
```

### Unicode characters not rendering

```bash
# Check locale
locale | grep UTF-8

# Set UTF-8 locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
```

### Boxes wrapping incorrectly

```bash
# Check terminal width
tput cols

# Boxes auto-clamp to terminal width minus 4 columns
```

---

## 📞 Support

- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions

---

**Made with 🐦 for the bash community**
