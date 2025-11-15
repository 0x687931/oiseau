# Oiseau Simple Customization Guide

## Philosophy: Convention Over Configuration

Oiseau is designed to **work beautifully with zero configuration**. The default settings are carefully chosen to look great in modern terminals while gracefully degrading to ASCII in limited environments.

**The best customization is no customization.**

That said, three simple environment variables let you adjust Oiseau to your needs without complexity.

---

## What You Get Out-of-the-Box

### Zero Configuration Required

```bash
#!/bin/bash
source oiseau.sh

show_box error "Build Failed" "Compilation errors detected"
show_header_box "My Application"
show_progress_bar 5 10 "Building"
```

**Result**: Beautiful, modern UI with:
- Automatic UTF-8 detection (rounded borders `╭─╮` or ASCII fallback `+--+`)
- 256-color palette (gracefully degrades to basic colors or monochrome)
- Smart icons (emoji `✓✗⚠ℹ` in UTF-8, text `[OK][X][!][i]` in ASCII)
- Responsive box widths (default 60 columns, clamped to terminal width)

---

## Three Border Styles (Auto-Detected)

Oiseau uses **two UTF-8 border styles** based on context:

### ROUNDED (Friendly, Modern)
```
╭──────────────────╮
│  Info Message    │
╰──────────────────╯
```
**Used by**: Headers, info boxes, success boxes, section headers

### DOUBLE/HEAVY (Emphasis, Important)
```
┏━━━━━━━━━━━━━━━━━━┓
┃  Error Message   ┃
┗━━━━━━━━━━━━━━━━━━┛
```
**Used by**: Error boxes, warning boxes, critical alerts

### ASCII (Universal Fallback)
```
+------------------+
|  Info Message    |
+------------------+
```
**Auto-enabled when**:
- Terminal doesn't support UTF-8
- `NO_COLOR=1` is set
- `UI_DISABLE=1` is set
- Output is piped or redirected

---

## Simple Customization (3 Environment Variables)

### 1. `OISEAU_BORDER_STYLE` - Change Border Style Globally

Force a specific border style for all widgets:

```bash
export OISEAU_BORDER_STYLE="rounded"  # All widgets use rounded borders
export OISEAU_BORDER_STYLE="double"   # All widgets use double borders
export OISEAU_BORDER_STYLE="ascii"    # Force ASCII mode
```

**Example**:
```bash
#!/bin/bash
export OISEAU_BORDER_STYLE="double"
source oiseau.sh

show_box success "Complete" "All tests passed"
# Uses ╔═╗ instead of ╭─╮
```

### 2. `OISEAU_BOX_WIDTH` - Change Box Width Globally

Override the default 60-column width:

```bash
export OISEAU_BOX_WIDTH="80"   # Wider boxes
export OISEAU_BOX_WIDTH="40"   # Narrower boxes
```

**Example**:
```bash
#!/bin/bash
export OISEAU_BOX_WIDTH="80"
source oiseau.sh

show_box info "Notice" "This box is now 80 columns wide"
```

**Note**: Boxes automatically clamp to terminal width - 4 to prevent overflow.

### 3. Individual Color Overrides

Override specific colors using ANSI 256-color codes:

```bash
export COLOR_ERROR="196"     # Bright red
export COLOR_SUCCESS="46"    # Bright green
export COLOR_WARNING="214"   # Orange
export COLOR_INFO="39"       # Cyan
export COLOR_HEADER="141"    # Purple
export COLOR_MUTED="240"     # Gray
```

**Example**:
```bash
#!/bin/bash
export COLOR_ERROR="196"  # Corporate brand red
source oiseau.sh

show_box error "Alert" "Using custom error color"
```

---

## Default Color Palette

Oiseau uses a carefully selected 256-color ANSI palette:

| Purpose | Color | ANSI Code |
|---------|-------|-----------|
| Success | Green | 114 |
| Error | Red | 204 |
| Warning | Orange | 214 |
| Info | Blue | 75 |
| Header | Purple | 141 |
| Muted | Gray | 240 |
| Dim | Dark Gray | 238 |
| Border | Gray | 240 |
| Code | Cyan | 81 |

---

## Icon Sets (Auto-Detected)

### UTF-8 Icons (Default in Rich/Color Mode)
- Success: `✓`
- Error: `✗`
- Warning: `⚠`
- Info: `ℹ`
- Active: `●`
- Pending: `○`
- Skip: `—`

### ASCII Icons (Fallback in Plain Mode)
- Success: `[OK]`
- Error: `[X]`
- Warning: `[!]`
- Info: `[i]`
- Active: `[*]`
- Pending: `[ ]`
- Skip: `[-]`

**No customization needed** - Oiseau automatically selects the right icon set based on terminal capabilities.

---

## Terminal Mode Detection

Oiseau automatically detects terminal capabilities and adapts:

### Rich Mode (Default)
- **Detected when**: Terminal supports UTF-8 + 256 colors
- **Features**: Full UTF-8 borders, 256-color palette, emoji icons
- **Terminals**: iTerm2, Alacritty, VS Code, modern terminals

### Color Mode
- **Detected when**: Terminal supports colors but limited UTF-8
- **Features**: UTF-8 borders, 256-color palette, ASCII icons
- **Terminals**: Older terminals with color support

### Plain Mode
- **Detected when**: `NO_COLOR=1`, `UI_DISABLE=1`, piped output, or no TTY
- **Features**: ASCII borders, no colors, text-only icons
- **Use cases**: CI/CD logs, piped output, email, legacy terminals

**Force plain mode**:
```bash
export NO_COLOR=1
# OR
export UI_DISABLE=1
```

---

## Real-World Examples

### Example 1: Zero Configuration (Recommended)

```bash
#!/bin/bash
source oiseau.sh

show_header_box "Deployment Pipeline"
show_progress_bar 8 10 "Deploying"
show_box success "Complete" "Deployed to production"
```

**Result**: Works perfectly with automatic detection.

---

### Example 2: Corporate Environment (ASCII-Only)

```bash
#!/bin/bash
export OISEAU_BORDER_STYLE="ascii"
export NO_COLOR=1
source oiseau.sh

show_header_box "Build Report"
show_summary "Results" \
    "Tests: 142 passed" \
    "Coverage: 87%" \
    "Build time: 3m 45s"
```

**Result**: Pure ASCII, no colors, works everywhere (CI/CD, email, logs).

---

### Example 3: Custom Brand Colors

```bash
#!/bin/bash
export COLOR_ERROR="196"    # Bright red (corporate brand)
export COLOR_SUCCESS="46"   # Bright green (corporate brand)
export OISEAU_BOX_WIDTH="80"
source oiseau.sh

show_box error "Critical Alert" "System requires immediate attention"
show_box success "All Clear" "Systems operational"
```

**Result**: Branded colors with wider boxes.

---

## What You CANNOT Customize (And Why)

To maintain simplicity and consistency, these are intentionally fixed:

❌ **Per-widget customization** - Would require function parameter parsing (too complex for bash)
❌ **Theme files** - Would require file parsers (adds dependencies)
❌ **Custom border characters** - Would break terminal compatibility
❌ **Per-widget colors** - Would make scripts inconsistent and hard to maintain
❌ **Font styles** - Terminal-dependent, unreliable

**Principle**: Global conventions are better than per-widget chaos.

---

## Best Practices

### ✅ DO:
- Use default settings (zero config)
- Override globally when needed (environment variables)
- Test with `NO_COLOR=1` to ensure ASCII compatibility
- Use semantic colors (error=red, success=green)

### ❌ DON'T:
- Don't try to customize individual widgets
- Don't use custom ANSI codes directly in messages
- Don't assume UTF-8 support
- Don't hardcode box widths in messages

---

## Testing Your Customizations

Test in all three modes:

```bash
# Test rich mode (default)
./your_script.sh

# Test plain mode
NO_COLOR=1 ./your_script.sh

# Test piped output
./your_script.sh | cat

# Test specific border style
OISEAU_BORDER_STYLE=ascii ./your_script.sh

# Test custom width
OISEAU_BOX_WIDTH=80 ./your_script.sh
```

---

## Environment Variable Reference

| Variable | Values | Default | Purpose |
|----------|--------|---------|---------|
| `OISEAU_BORDER_STYLE` | `rounded`, `double`, `ascii` | Auto-detect | Force border style |
| `OISEAU_BOX_WIDTH` | Number (20-200) | `60` | Override box width |
| `COLOR_ERROR` | ANSI 256 code | `204` | Error message color |
| `COLOR_SUCCESS` | ANSI 256 code | `114` | Success message color |
| `COLOR_WARNING` | ANSI 256 code | `214` | Warning message color |
| `COLOR_INFO` | ANSI 256 code | `75` | Info message color |
| `COLOR_HEADER` | ANSI 256 code | `141` | Header text color |
| `COLOR_MUTED` | ANSI 256 code | `240` | Muted text color |
| `NO_COLOR` | `1` | (unset) | Disable all colors |
| `UI_DISABLE` | `1` | (unset) | Disable all UI enhancements |

---

## Summary

Oiseau's customization philosophy:

1. **Works beautifully with zero configuration** (default for 90% of users)
2. **Three simple environment variables** for global overrides (8% of users)
3. **No complexity** - no config files, no themes, no per-widget params (KISS)

**Remember**: The best customization is using the defaults. Override only when necessary.
