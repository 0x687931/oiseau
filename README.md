# Oiseau

**Terminal UI library for Bash**
32 widgets • Pure bash • Zero dependencies

```bash
source ./oiseau.sh
```

**Requirements:** Bash 3.2+, standard POSIX utilities (`tput`, `tr`, `wc`, `grep`, `awk`, `sed`, `cat`, `sleep`), optional `perl`

**Shell:** Widgets still target Bash 3.2+, but all helper tooling now uses POSIX `sh` or
`#!/usr/bin/env bash` shebangs so macOS (default zsh) and Linux users can invoke demos,
tests, and git helpers without switching shells.

### Using Oiseau from zsh

`oiseau.sh` now detects when it is sourced from zsh and automatically flips the
compatibility switches (`emulate -L sh`, `setopt KSH_ARRAYS`, `setopt
SH_WORD_SPLIT`, and a `declare` shim) required for its associative arrays and
widgets to work.  This keeps the public API identical regardless of whether you
develop from `bash` or macOS' default `zsh`.

> **No Bash installed?** That's OK.  Source `oiseau.sh` straight from `zsh` and
> the compatibility layer will load without spawning Bash.  All demos/tests keep
> their `#!/usr/bin/env bash` shebangs, but simply sourcing the library (the
> common macOS workflow) no longer depends on `/bin/bash` being present.

**Graceful degradation:** UTF-8+256color → ASCII+256color → ASCII monochrome

---

## Terminal Modes

Automatic detection. Override with `export OISEAU_MODE=rich|color|plain` before sourcing.

| Mode | Boxes | Icons | Colors | When |
|------|-------|-------|--------|------|
| **rich** | Unicode (┏━┓) | Unicode (✓ ✗ ⚠ ℹ) | 256-color | Modern terminals (iTerm2, VS Code, Alacritty) |
| **color** | ASCII (+==+) | ASCII ([OK] [X] [!] [i]) | 256-color | Older terminals with color |
| **plain** | ASCII (+==+) | ASCII ([OK] [X] [!] [i]) | None | Pipes, CI/CD, `NO_COLOR=1` |

**Example output (same code, three modes):**

```bash
show_success "Build completed"
show_box info "Status" "Deployment in progress"
```

**Rich:**
```
  ✓  Build completed
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ℹ  Status                                               ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃  Deployment in progress                                  ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

**Color/Plain:**
```
  [OK]  Build completed
+==========================================================+
|  [i]  Status                                             |
+==========================================================+
|  Deployment in progress                                  |
+==========================================================+
```

---

## Accessibility

Color palettes for visual accessibility. Set `export OISEAU_PALETTE=colorblind|highcontrast` before sourcing.

| Palette | Purpose | Colors | Backgrounds |
|---------|---------|--------|-------------|
| **default** | Standard | Mid-range green/red/orange/blue | Light & dark |
| **colorblind** | Deuteranopia/protanopia safe | Blue/orange/yellow (no red/green) | Light & dark |
| **highcontrast** | Maximum visibility | Bold bright colors | Light & dark |

**All palettes optimized for dark terminal backgrounds** (recommended). Work on light backgrounds but with reduced contrast.

Colors follow Apple HIG principles. WCAG contrast ratios on dark backgrounds: DEFAULT (4.5-11:1), COLORBLIND (5.5-15:1), HIGHCONTRAST (5-20:1).

```bash
export OISEAU_PALETTE=colorblind
source ./oiseau.sh
```

---

## Customization

| Variable | Values | Default | Purpose |
|----------|--------|---------|---------|
| `OISEAU_MODE` | `rich`, `color`, `plain` | Auto | Force mode |
| `OISEAU_PALETTE` | `default`, `colorblind`, `highcontrast` | `default` | Color palette |
| `OISEAU_BORDER_STYLE` | `rounded`, `double`, `ascii` | Auto | Force border style |
| `OISEAU_BOX_WIDTH` | 20-200 | 60 | Box width |
| `COLOR_ERROR` | ANSI 256 | 196 | Error color |
| `COLOR_SUCCESS` | ANSI 256 | 40 | Success color |
| `COLOR_WARNING` | ANSI 256 | 214 | Warning color |
| `COLOR_INFO` | ANSI 256 | 39 | Info color |
| `COLOR_HEADER` | ANSI 256 | 117 | Header color |
| `COLOR_MUTED` | ANSI 256 | 246 | Muted color |

---

## Widget Catalog

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

```bash
show_success <message>

# Example
show_success "Build completed successfully"
```
```
  ✓  Build completed successfully
```

Build success, task completion, operation confirmed.

---

### show_error

Quick one-line error message with red X.

```bash
show_error <message>

# Example
show_error "Failed to connect to server"
```
```
  ✗  Failed to connect to server
```

Connection failures, command errors, exceptions.

---

### show_warning

Quick one-line warning message with orange warning icon.

```bash
show_warning <message>

# Example
show_warning "This will delete all files"
```
```
  ⚠  This will delete all files
```

Destructive operations, deprecation notices, resource warnings.

---

### show_info

Quick one-line informational message with blue info icon.

```bash
show_info <message>

# Example
show_info "Processing 142 items..."
```
```
  ℹ  Processing 142 items...
```

Process status, info messages, debug output.

---

### show_box

Display important information in bordered boxes with icons, titles, messages, and optional action commands.

```bash
show_box <type> <title> <message> [command1] [command2] ...

# Example
show_box error "Connection Failed" \
    "Unable to reach database at localhost:5432" \
    "systemctl start postgresql" \
    "pg_isready -h localhost"
```
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

Service failures with remediation (`error`), destructive operations (`warning`), multi-line status (`info`), deployment complete (`success`).

---

### show_progress_bar

Visual progress indicator showing task completion percentage.

```bash
show_progress_bar <current> <total> [label]

# Example
for i in {1..10}; do
    show_progress_bar "$i" 10 "Installation"
    sleep 0.5
done
```
```
Installation: ████████████░░░░░░░░ 60% (6/10)
```

Downloads, uploads, builds, compilations, batch processing.

---

### show_checklist

Track multi-step workflows with visual status indicators.

```bash
show_checklist <array_name>

# Example
tasks=(
    "done|Build Docker image|Completed in 45s"
    "active|Run tests|156 tests running..."
    "pending|Deploy to staging|Waiting"
)
show_checklist tasks
```
```
  ✓  Build Docker image  Completed in 45s
  ●  Run tests  156 tests running...
  ○  Deploy to staging  Waiting
```

CI/CD pipelines, multi-stage builds, deployment workflows, install scripts. Status values: `done`, `active`, `pending`, `skip`.

---

### show_section_header

Display titled sections with optional step counters.

```bash
show_section_header <title> [current_step] [total_steps] [subtitle]

# Example
show_section_header "Deploy Application" 2 4 "Building Docker image"
```
```
╭──────────────────────────────────────────────────────────╮
│  Deploy Application                                      │
│  Step 2 of 4 › Building Docker image                     │
╰──────────────────────────────────────────────────────────╯
```

Wizards, multi-step processes, guided setup, migration scripts.

---

### show_header

Simple bold header for section titles.

```bash
show_header <title>

# Example
show_header "Installation"
```
```
  Installation
```

Section titles, script phase markers.

---

### show_subheader

Muted subheader for subsections.

```bash
show_subheader <title>

# Example
show_subheader "Configuring environment..."
```
```
  Configuring environment...
```

Subsection headers, status text.

---

### show_header_box

Decorative boxed header with optional subtitle.

```bash
show_header_box <title> [subtitle]

# Example
show_header_box "Deployment Pipeline"
```
```
╭──────────────────────────────────────────────────────────╮
│                                                          │
│   Deployment Pipeline                                    │
│                                                          │
╰──────────────────────────────────────────────────────────╯
```

Script banners, tool headers, major sections.

---

### show_summary

Summary box with multiple key-value items.

```bash
show_summary <title> <item1> <item2> ...

# Example
show_summary "Deployment Complete" \
    "Environment: Production" \
    "Build: #432" \
    "Status: All systems operational"
```
```
╭──────────────────────────────────────────────────────────╮
│  [OK]  Deployment Complete                               │
╰──────────────────────────────────────────────────────────╯
│  Environment: Production                                 │
│  Build: #432                                             │
│  Status: All systems operational                         │
╰──────────────────────────────────────────────────────────╯
```

Final status, build metadata, deployment summary.

---

### show_spinner

Animated loading spinner (runs until killed).

```bash
show_spinner <message>

# Example
show_spinner "Loading..." &
SPINNER_PID=$!
sleep 5
kill $SPINNER_PID
```

Network operations, unknown-duration tasks, blocking calls.

---

### start_spinner

Start spinner in background (tracks PID automatically).

```bash
start_spinner <message>

# Example
start_spinner "Processing files..."
# do work
stop_spinner
```

Managed spinner with auto PID tracking (cleaner than manual show_spinner).

---

### stop_spinner

Stop background spinner started with `start_spinner`.

```bash
stop_spinner

# Example
start_spinner "Downloading..."
curl -O https://example.com/file.zip
stop_spinner
show_success "Download complete"
```

---

### ask_input

Enhanced text input with validation and password masking.

```bash
ask_input <prompt> [default] [mode]

# Example
name=$(ask_input "Your name" "John")
email=$(ask_input "Email" "" "email")
password=$(ask_input "Password" "" "password")
```

Config input, credential collection, validated user input. Modes: `text`, `password`, `email`, `number`.

---

### ask_list

Interactive list selection with arrow key navigation.

```bash
ask_list <prompt> <array_name> [mode]

# Example
options=("Deploy" "Test" "Cancel")
choice=$(ask_list "Select action:" options)
```

Interactive menus, option selection, arrow-key navigation. Modes: `single`, `multi`.

---

### ask_yes_no

Ask yes/no question (alias for `prompt_confirm`).

```bash
ask_yes_no <question>

# Example
if ask_yes_no "Delete all files?"; then
    echo "Deleting..."
fi
```

Confirmation prompts, boolean decisions, destructive operation guards.

---

### prompt_confirm

Yes/no confirmation prompt.

```bash
prompt_confirm <question> [default]

# Example
if prompt_confirm "Continue?" "y"; then
    proceed
fi
```

Same as ask_yes_no, but with default value.

---

### print_kv

Key-value pair with aligned columns.

```bash
print_kv <key> <value> [width]

# Example
print_kv "Version" "2.0.1"
print_kv "Status" "Running"
```
```
  Version    2.0.1
  Status     Running
```

Config display, system info, metadata output.

---

### print_command

Code-styled command display (monospace box).

```bash
print_command <command>

# Example
print_command "npm install oiseau"
```

Command examples, copy-paste snippets, install instructions.

---

### print_item

Bulleted list item.

```bash
print_item <text>

# Example
print_item "First item"
print_item "Second item"
```
```
  • First item
  • Second item
```

Bulleted lists, feature enumeration.

---

### print_step

Numbered step with text.

```bash
print_step <number> <text>

# Example
print_step 1 "Clone repository"
print_step 2 "Install dependencies"
```
```
  1. Clone repository
  2. Install dependencies
```

Numbered steps, installation procedures, tutorials.

---

### print_next_steps

Numbered list of next steps.

```bash
print_next_steps <step1> <step2> ...

# Example
print_next_steps \
    "Run tests: npm test" \
    "Deploy: npm run deploy"
```
```
Next steps:

  1. Run tests: npm test
  2. Deploy: npm run deploy
```

Post-install actions, suggested next commands.

---

### print_section

Section title with colored header.

```bash
print_section <title>

# Example
print_section "Configuration"
```

Section dividers, output organization.

---

### show_table

Display data in a formatted table.

```bash
show_table <array_name>

# Example
data=("Name|Age|City" "Alice|30|NYC" "Bob|25|LA")
show_table data
```

Tabular data, CSV-like output, formatted reports. Array items are pipe-separated values.

---

### show_pager

Display content in a pager (less/more).

```bash
show_pager <content>

# Example
show_pager "$(cat longfile.txt)"
```

Large text output, manpage-style help, log viewing.

---

## Security

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

## Testing

```bash
# POSIX runner; works from zsh, bash, dash, etc.
./run_tests.sh --plain

# Iterate across rich/color/plain sequentially
./run_tests.sh --all
```

Sample:

```
== Running tests with OISEAU_MODE=plain ==
(1/10) test_edge_cases.sh ... ok
(2/10) test_help_menu.sh ... ok
...
(10/10) test_table.sh ... ok

Summary (plain mode): 10/10 passed
```

Individual test suites:

```bash
./tests/test_progress.sh
./tests/test_input.sh
./tests/test_spinner.sh
```

---

## Troubleshooting

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

## Gallery

Interactive demo of all widgets:

```bash
./gallery.sh

# Auto mode (no pauses)
OISEAU_GALLERY_AUTO=1 ./gallery.sh
```

---

## TUI Mode

Oiseau supports non-scrolling terminal UIs (like `htop`, `vim`):

```bash
./examples/tui_demo.sh      # Basic multi-view TUI
./examples/tui_mvc.sh       # MVC pattern TUI
```

See `examples/TUI_GUIDE.md` for full documentation.

---

## License

MIT License - see LICENSE file

---

## Support

- **Issues:** https://github.com/0x687931/oiseau/issues
- **Discussions:** https://github.com/0x687931/oiseau/discussions
