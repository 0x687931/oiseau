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
- **📝 30+ Widgets** - Messages, boxes, progress bars, checklists, headers, and more

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
| `show_section_header "title" [step] [total] [subtitle]` | Boxed header with optional step counter |

### Boxes

| Function | Usage |
|----------|-------|
| `show_box <type> <title> <msg> [cmd...]` | Styled box with title, message, and optional commands |

Types: `error`, `warning`, `info`, `success`

### Progress & Lists

| Function | Description |
|----------|-------------|
| `show_progress_bar <current> <total> [label]` | Progress bar with percentage |
| `show_checklist <array_name>` | Checklist with status icons |
| `show_summary "title" "item1" "item2" ...` | Summary box with items |

### Interactive Prompts

| Function | Returns | Description |
|----------|---------|-------------|
| `prompt_confirm "msg" [default]` | 0=yes, 1=no | Yes/no confirmation |
| `ask_yes_no "msg"` | 0=yes, 1=no | Alias for prompt_confirm |
| `ask_input "msg" [default]` | string | Text input prompt |

### Formatting Helpers

| Function | Description |
|----------|-------------|
| `print_kv "key" "value" [width]` | Key-value pair |
| `print_command "cmd"` | Code-styled command |
| `print_item "text"` | Bulleted list item |
| `print_section "title"` | Section title |
| `print_step <num> "text"` | Numbered step |
| `print_next_steps "step1" "step2" ...` | Numbered next steps list |

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

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-widget`)
3. Make your changes
4. Test in all three modes (rich, color, plain)
5. Submit a pull request

### Development

```bash
# Run gallery to test changes
./gallery.sh

# Test in different modes
OISEAU_MODE=plain ./gallery.sh
NO_COLOR=1 ./gallery.sh
UI_DISABLE=1 ./gallery.sh

# Test in pipe
./gallery.sh | cat
```

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
