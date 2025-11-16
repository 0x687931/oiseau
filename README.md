# OISEAU - BASH TERMINAL UI LIBRARY v1.0.0

**PURPOSE**

32 widgets for building terminal UIs in Bash 3.2+. Pure bash, no external libraries or packages. Graceful degradation: UTF-8+256color → ASCII+256color → ASCII monochrome.

**INSTALLATION**

```bash
source ./oiseau.sh
```

**REQUIREMENTS**

Bash 3.2+ (macOS default, all modern Linux)

POSIX utilities (universally available):
- `tput` - terminal capability queries
- `tr` - character translation for box drawing
- `wc` - text width calculations
- `grep` - pattern matching
- `awk` - text processing
- `sed` - text manipulation
- `cat` - file concatenation
- `sleep` - spinner animations

Optional:
- `perl` - unicode width calculations (degrades gracefully if missing)

---

## WIDGET CATALOG

Jump to any widget:

**Status & Messages**
[`show_success`](#show_success) • [`show_error`](#show_error) • [`show_warning`](#show_warning) • [`show_info`](#show_info)

**Boxes & Containers**
[`show_box`](#show_box) • [`show_summary`](#show_summary) • [`show_header_box`](#show_header_box)

**Headers**
[`show_header`](#show_header) • [`show_subheader`](#show_subheader) • [`show_section_header`](#show_section_header)

**Progress & Status**
[`show_progress_bar`](#show_progress_bar) • [`show_checklist`](#show_checklist) • [`show_spinner`](#show_spinner) • [`start_spinner`](#start_spinner) • [`stop_spinner`](#stop_spinner)

**Interactive Input**
[`ask_input`](#ask_input) • [`ask_list`](#ask_list) • [`ask_yes_no`](#ask_yes_no) • [`prompt_confirm`](#prompt_confirm)

**Formatting Helpers**
[`print_kv`](#print_kv) • [`print_command`](#print_command) • [`print_item`](#print_item) • [`print_step`](#print_step) • [`print_next_steps`](#print_next_steps) • [`print_section`](#print_section)

**Advanced**
[`show_table`](#show_table) • [`show_pager`](#show_pager)

---

### show_success

Quick one-line success message with green checkmark.

**Syntax:**
```bash
show_success <message>
```

**Parameters:**
- `message` - Text to display

**Example:**
```bash
show_success "Build completed successfully"
```

**Output:**
```
  ✓  Build completed successfully
```

**Use cases:** Build success, task completion, operation confirmed

---

### show_error

Quick one-line error message with red X.

**Syntax:**
```bash
show_error <message>
```

**Parameters:**
- `message` - Text to display

**Example:**
```bash
show_error "Failed to connect to server"
```

**Output:**
```
  ✗  Failed to connect to server
```

**Use cases:** Connection failures, command errors, exceptions

---

### show_warning

Quick one-line warning message with orange warning icon.

**Syntax:**
```bash
show_warning <message>
```

**Parameters:**
- `message` - Text to display

**Example:**
```bash
show_warning "This will delete all files"
```

**Output:**
```
  ⚠  This will delete all files
```

**Use cases:** Destructive operations, deprecation notices, resource warnings

---

### show_info

Quick one-line informational message with blue info icon.

**Syntax:**
```bash
show_info <message>
```

**Parameters:**
- `message` - Text to display

**Example:**
```bash
show_info "Processing 142 items..."
```

**Output:**
```
  ℹ  Processing 142 items...
```

**Use cases:** Process status, info messages, debug output

---

### show_box

Display important information in bordered boxes with icons, titles, messages, and optional action commands.

**Syntax:**
```bash
show_box <type> <title> <message> [command1] [command2] ...
```

**Parameters:**
- `type` - Visual style: `error` (red ✗), `warning` (orange ⚠), `info` (blue ℹ), `success` (green ✓)
- `title` - Bold header text at the top
- `message` - Main content (automatically wrapped)
- `command...` - Optional commands shown under "To resolve:"

**Example:**
```bash
show_box error "Connection Failed" \
    "Unable to reach database at localhost:5432" \
    "systemctl start postgresql" \
    "pg_isready -h localhost"
```

**Output:**
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ✗  Connection Failed                                    ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                                          ┃
┃  Unable to reach database at localhost:5432              ┃
┃                                                          ┃
┃  To resolve:                                             ┃
┃    systemctl start postgresql                            ┃
┃    pg_isready -h localhost                               ┃
┃                                                          ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

**Use cases:**
- `error` - Service failures, connection errors, exceptions with remediation
- `warning` - Destructive operations, missing config, deprecations
- `info` - Multi-line status, help text, informational blocks
- `success` - Deployment complete, build success, operation confirmed

---

### show_progress_bar

Visual progress indicator showing task completion percentage.

**Syntax:**
```bash
show_progress_bar <current> <total> [label]
```

**Parameters:**
- `current` - Current progress value (e.g., 6)
- `total` - Total items to complete (e.g., 10)
- `label` - Optional text shown before the progress bar

**Example:**
```bash
for i in {1..10}; do
    show_progress_bar "$i" 10 "Installation"
    sleep 0.5
done
```

**Output:**
```
Installation: ████████████░░░░░░░░ 60% (6/10)
```

**Use cases:** Downloads, uploads, builds, compilations, batch processing

---

### show_checklist

Track multi-step workflows with visual status indicators.

**Syntax:**
```bash
show_checklist <array_name>
```

**Parameters:**
- `array_name` - Name of array containing tasks (not `$array_name`)

**Item format:** Each array item is a pipe-separated string:
```
"<status>|<task_name>|<details>"
```

**Status values:**
- `done` - Completed (✓ green checkmark)
- `active` - Currently running (● animated dot)
- `pending` - Not started (○ hollow circle)
- `skip` - Skipped/ignored (⊘ crossed circle)

**Example:**
```bash
tasks=(
    "done|Build Docker image|Completed in 45s"
    "active|Run tests|156 tests running..."
    "pending|Deploy to staging|Waiting"
)
show_checklist tasks
```

**Output:**
```
  ✓  Build Docker image  Completed in 45s
  ●  Run tests  156 tests running...
  ○  Deploy to staging  Waiting
```

**Use cases:** CI/CD pipelines, multi-stage builds, deployment workflows, install scripts

---

### show_section_header

Display titled sections with optional step counters.

**Syntax:**
```bash
show_section_header <title> [current_step] [total_steps] [subtitle]
```

**Parameters:**
- `title` - Main header text
- `current_step` - Optional: Current step number (e.g., 2)
- `total_steps` - Optional: Total number of steps (e.g., 4)
- `subtitle` - Optional: Additional context text

**Example:**
```bash
show_section_header "Deploy Application" 2 4 "Building Docker image"
```

**Output:**
```
╭──────────────────────────────────────────────────────────╮
│  Deploy Application                                      │
│  Step 2 of 4 › Building Docker image                     │
╰──────────────────────────────────────────────────────────╯
```

**Use cases:** Wizards, multi-step processes, guided setup, migration scripts

---

### show_header

Simple bold header for section titles.

**Syntax:**
```bash
show_header <title>
```

**Parameters:**
- `title` - Header text

**Example:**
```bash
show_header "Installation"
```

**Output:**
```
  Installation
```

**Use cases:** Section titles, script phase markers

---

### show_subheader

Muted subheader for subsections.

**Syntax:**
```bash
show_subheader <title>
```

**Parameters:**
- `title` - Subheader text

**Example:**
```bash
show_subheader "Configuring environment..."
```

**Output:**
```
  Configuring environment...
```

**Use cases:** Subsection headers, status text

---

### show_header_box

Decorative boxed header with optional subtitle.

**Syntax:**
```bash
show_header_box <title> [subtitle]
```

**Parameters:**
- `title` - Main header text
- `subtitle` - Optional secondary text

**Example:**
```bash
show_header_box "Deployment Pipeline"
```

**Output:**
```
╭──────────────────────────────────────────────────────────╮
│                                                          │
│   Deployment Pipeline                                    │
│                                                          │
╰──────────────────────────────────────────────────────────╯
```

**Use cases:** Script banners, tool headers, major sections

---

### show_summary

Summary box with multiple key-value items.

**Syntax:**
```bash
show_summary <title> <item1> <item2> ...
```

**Parameters:**
- `title` - Box title
- `item...` - List items to display

**Example:**
```bash
show_summary "Deployment Complete" \
    "Environment: Production" \
    "Build: #432" \
    "Status: All systems operational"
```

**Output:**
```
╭──────────────────────────────────────────────────────────╮
│  [OK]  Deployment Complete                               │
╰──────────────────────────────────────────────────────────╯
│  Environment: Production                                 │
│  Build: #432                                             │
│  Status: All systems operational                         │
╰──────────────────────────────────────────────────────────╯
```

**Use cases:** Final status, build metadata, deployment summary

---

### show_spinner

Animated loading spinner (runs until killed).

**Syntax:**
```bash
show_spinner <message>
```

**Parameters:**
- `message` - Text to show next to spinner

**Example:**
```bash
show_spinner "Loading..." &
SPINNER_PID=$!
sleep 5
kill $SPINNER_PID
```

**Use cases:** Network operations, unknown-duration tasks, blocking calls

---

### start_spinner

Start spinner in background (tracks PID automatically).

**Syntax:**
```bash
start_spinner <message>
```

**Parameters:**
- `message` - Text to show next to spinner

**Example:**
```bash
start_spinner "Processing files..."
# do work
stop_spinner
```

**Use cases:** Managed spinner with auto PID tracking (cleaner than manual show_spinner)

---

### stop_spinner

Stop background spinner started with `start_spinner`.

**Syntax:**
```bash
stop_spinner
```

**Example:**
```bash
start_spinner "Downloading..."
curl -O https://example.com/file.zip
stop_spinner
show_success "Download complete"
```

---

### ask_input

Enhanced text input with validation and password masking.

**Syntax:**
```bash
ask_input <prompt> [default] [mode]
```

**Parameters:**
- `prompt` - Question to ask
- `default` - Default value if user presses Enter
- `mode` - Validation mode: `text`, `password`, `email`, `number`

**Example:**
```bash
name=$(ask_input "Your name" "John")
email=$(ask_input "Email" "" "email")
password=$(ask_input "Password" "" "password")
```

**Use cases:** Config input, credential collection, validated user input

---

### ask_list

Interactive list selection with arrow key navigation.

**Syntax:**
```bash
ask_list <prompt> <array_name> [mode]
```

**Parameters:**
- `prompt` - Question to ask
- `array_name` - Name of array (not `$array`)
- `mode` - `single` (default) or `multi`

**Example:**
```bash
options=("Deploy" "Test" "Cancel")
choice=$(ask_list "Select action:" options)
```

**Use cases:** Interactive menus, option selection, arrow-key navigation

---

### ask_yes_no

Ask yes/no question (alias for `prompt_confirm`).

**Syntax:**
```bash
ask_yes_no <question>
```

**Parameters:**
- `question` - Question to ask

**Example:**
```bash
if ask_yes_no "Delete all files?"; then
    echo "Deleting..."
fi
```

**Use cases:** Confirmation prompts, boolean decisions, destructive operation guards

---

### prompt_confirm

Yes/no confirmation prompt.

**Syntax:**
```bash
prompt_confirm <question> [default]
```

**Parameters:**
- `question` - Question to ask
- `default` - Default answer: `y` or `n`

**Example:**
```bash
if prompt_confirm "Continue?" "y"; then
    proceed
fi
```

**Use cases:** Same as ask_yes_no, but with default value

---

### print_kv

Key-value pair with aligned columns.

**Syntax:**
```bash
print_kv <key> <value> [width]
```

**Parameters:**
- `key` - Left-side label
- `value` - Right-side value
- `width` - Optional column width

**Example:**
```bash
print_kv "Version" "2.0.1"
print_kv "Status" "Running"
```

**Output:**
```
  Version    2.0.1
  Status     Running
```

**Use cases:** Config display, system info, metadata output

---

### print_command

Code-styled command display (monospace box).

**Syntax:**
```bash
print_command <command>
```

**Parameters:**
- `command` - Command text to display

**Example:**
```bash
print_command "npm install oiseau"
```

**Use cases:** Command examples, copy-paste snippets, install instructions

---

### print_item

Bulleted list item.

**Syntax:**
```bash
print_item <text>
```

**Parameters:**
- `text` - Item text

**Example:**
```bash
print_item "First item"
print_item "Second item"
```

**Output:**
```
  • First item
  • Second item
```

**Use cases:** Bulleted lists, feature enumeration

---

### print_step

Numbered step with text.

**Syntax:**
```bash
print_step <number> <text>
```

**Parameters:**
- `number` - Step number
- `text` - Step description

**Example:**
```bash
print_step 1 "Clone repository"
print_step 2 "Install dependencies"
```

**Output:**
```
  1. Clone repository
  2. Install dependencies
```

**Use cases:** Numbered steps, installation procedures, tutorials

---

### print_next_steps

Numbered list of next steps.

**Syntax:**
```bash
print_next_steps <step1> <step2> ...
```

**Parameters:**
- `step...` - List of steps

**Example:**
```bash
print_next_steps \
    "Run tests: npm test" \
    "Deploy: npm run deploy"
```

**Output:**
```
Next steps:

  1. Run tests: npm test
  2. Deploy: npm run deploy
```

**Use cases:** Post-install actions, suggested next commands

---

### print_section

Section title with colored header.

**Syntax:**
```bash
print_section <title>
```

**Parameters:**
- `title` - Section title

**Example:**
```bash
print_section "Configuration"
```

**Use cases:** Section dividers, output organization

---

### show_table

Display data in a formatted table.

**Syntax:**
```bash
show_table <array_name>
```

**Parameters:**
- `array_name` - Name of array containing rows (pipe-separated values)

**Example:**
```bash
data=("Name|Age|City" "Alice|30|NYC" "Bob|25|LA")
show_table data
```

**Use cases:** Tabular data, CSV-like output, formatted reports

---

### show_pager

Display content in a pager (less/more).

**Syntax:**
```bash
show_pager <content>
```

**Parameters:**
- `content` - Text to display in pager

**Example:**
```bash
show_pager "$(cat longfile.txt)"
```

**Use cases:** Large text output, manpage-style help, log viewing

---

## TERMINAL MODES

Oiseau automatically detects terminal capabilities and adapts. Same code, three different outputs:

```bash
show_success "Build completed"
show_box info "Status" "Deployment in progress"
```

### Rich Mode (UTF-8 + Color)

**When:** Modern terminals (iTerm2, Alacritty, VS Code, Claude Code)

```
  ✓  Build completed
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ℹ  Status                                               ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                                          ┃
┃  Deployment in progress                                  ┃
┃                                                          ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

- Unicode box drawing (┏━┓ ╭─╮)
- Unicode icons (✓ ✗ ⚠ ℹ)
- Full 256-color palette
- **Force:** `export OISEAU_MODE=rich`

### Color Mode (ASCII + Color)

**When:** Older terminals with color but no UTF-8

```
  [OK]  Build completed
+==========================================================+
|  [i]  Status                                             |
+==========================================================+
|                                                          |
|  Deployment in progress                                  |
|                                                          |
+==========================================================+
```

- ASCII box drawing (+==+)
- ASCII icons ([OK] [X] [!] [i])
- Full 256-color palette
- **Force:** `export OISEAU_MODE=color`

### Plain Mode (ASCII + No Color)

**When:** Pipes, redirects, CI/CD, `NO_COLOR=1`

```
  [OK]  Build completed
+==========================================================+
|  [i]  Status                                             |
+==========================================================+
|                                                          |
|  Deployment in progress                                  |
|                                                          |
+==========================================================+
```

- ASCII box drawing (+==+)
- ASCII icons ([OK] [X] [!] [i])
- No colors (clean for logs)
- **Triggers:** `./script.sh | tee log.txt`, `NO_COLOR=1`, `UI_DISABLE=1`
- **Force:** `export OISEAU_MODE=plain`

**Note:** `OISEAU_MODE` must be set **before** sourcing `oiseau.sh`.

---

## CUSTOMIZATION

Three environment variables control Oiseau's appearance:

| Variable | Values | Default | Purpose |
|----------|--------|---------|---------|
| `OISEAU_MODE` | `rich`, `color`, `plain` | Auto | Force terminal mode |
| `OISEAU_BORDER_STYLE` | `rounded`, `double`, `ascii` | Auto | Force border style |
| `OISEAU_BOX_WIDTH` | Number (20-200) | `60` | Override box width |

Individual color overrides (ANSI 256-color codes):

| Variable | Default | Purpose |
|----------|---------|---------|
| `COLOR_ERROR` | `204` | Error message color |
| `COLOR_SUCCESS` | `114` | Success message color |
| `COLOR_WARNING` | `214` | Warning message color |
| `COLOR_INFO` | `75` | Info message color |
| `COLOR_HEADER` | `141` | Header text color |
| `COLOR_MUTED` | `240` | Muted text color |

**Example:**

```bash
export OISEAU_MODE=rich
export OISEAU_BORDER_STYLE=double
export OISEAU_BOX_WIDTH=80
export COLOR_ERROR=196
source ./oiseau.sh
```

---

## SECURITY

All widget functions use `_escape_input()` internally to:
- Remove ANSI escape sequences
- Strip control characters
- Prevent code injection attacks

User input is automatically sanitized:

```bash
user_input="$(cat untrusted_input.txt)"
show_success "$user_input"  # Safe
```

---

## TESTING

```bash
./run_tests.sh
```

Output:

```
+==========================================================+
|                                                          |
|   Oiseau Test Suite Runner                               |
|                                                          |
+==========================================================+


  [i]  Found 10 test suites

Running tests...

Testing: #################### 100% (10/10)
  [OK]  test_edge_cases
  [OK]  test_help_menu
  [OK]  test_help
  [OK]  test_input
  [OK]  test_list
  [OK]  test_mode_consistency
  [OK]  test_progress
  [OK]  test_resize
  [OK]  test_spinner
  [OK]  test_table



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
|                                                          |
|  All 10 test suites completed successfully.              |
|                                                          |
+==========================================================+

  [+]  Code quality validated
  [+]  All widgets tested
  [+]  Security checks passed
  [+]  Bash compatibility verified
```

Individual test suites:

```bash
./tests/test_progress.sh
./tests/test_input.sh
./tests/test_spinner.sh
```

---

## TROUBLESHOOTING

### Colors not showing

```bash
echo "TERM=$TERM"
tput colors  # Should show 256

# Force color mode (debugging only)
export OISEAU_HAS_COLOR=1
source oiseau.sh
```

### Unicode characters not rendering

```bash
locale | grep UTF-8

# Set UTF-8 locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
```

### Boxes wrapping incorrectly

```bash
tput cols  # Check terminal width
# Boxes auto-clamp to terminal width minus 4 columns
```

---

## GALLERY

Interactive demo of all widgets:

```bash
./gallery.sh

# Auto mode (no pauses)
OISEAU_GALLERY_AUTO=1 ./gallery.sh
```

---

## TUI MODE (NON-SCROLLING UIS)

Oiseau supports non-scrolling terminal UIs (like `htop`, `vim`):

```bash
./examples/tui_demo.sh      # Basic multi-view TUI
./examples/tui_mvc.sh       # MVC pattern TUI
```

See `examples/TUI_GUIDE.md` for full documentation.

---

## LICENSE

MIT License - see LICENSE file

---

## SUPPORT

- **Issues:** https://github.com/0x687931/oiseau/issues
- **Discussions:** https://github.com/0x687931/oiseau/discussions
