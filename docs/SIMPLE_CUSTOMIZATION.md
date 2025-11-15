# Oiseau Customization Guide

**Philosophy: Works beautifully with ZERO configuration. Simple global overrides via environment variables.**

Oiseau is designed to work perfectly out of the box. This document describes the minimal customization options available for those who need them.

---

## Core Principle

- **Default behavior is optimal** - No configuration needed for 99% of use cases
- **Global overrides only** - No per-widget parameters or complex theming
- **Environment variables** - Simple, standard Unix way to customize

---

## Border Styles

Oiseau supports **3 border styles** that automatically switch based on terminal capabilities:

### 1. Rounded (Default in UTF-8 terminals)
```
╭────────────────────╮
│  Modern & Friendly │
╰────────────────────╯
```
Used for: Section headers, summaries, friendly boxes

### 2. Square/Double (Default for important boxes in UTF-8)
```
┏━━━━━━━━━━━━━━━━━━━┓
┃  Important & Bold  ┃
┗━━━━━━━━━━━━━━━━━━━┛
```
Used for: Error boxes, warning boxes, data that needs attention

### 3. ASCII (Automatic fallback)
```
+--------------------+
|  Universal & Safe  |
+--------------------+
```
Used for: Non-UTF-8 terminals, plain mode, pipes, CI/CD

**Note:** Border style selection is automatic based on terminal detection. No configuration needed.

---

## Color Palette

Oiseau uses a single, carefully-designed 256-color ANSI palette:

### Status Colors
- **Success:** `\033[38;5;40m` - Bright green
- **Error:** `\033[38;5;196m` - Bright red
- **Warning:** `\033[38;5;214m` - Orange
- **Info:** `\033[38;5;39m` - Bright blue

### UI Colors
- **Accent:** `\033[38;5;99m` - Purple
- **Header:** `\033[38;5;117m` - Light blue
- **Border:** `\033[38;5;240m` - Gray
- **Muted:** `\033[38;5;246m` - Light gray
- **Dim:** `\033[38;5;238m` - Dark gray

### Special Colors
- **Code:** `\033[38;5;186m` - Beige (for commands)
- **Link:** `\033[38;5;75m` - Sky blue

**Note:** These colors are optimized for both dark and light terminal themes.

---

## Icon Sets

Oiseau automatically selects the appropriate icon set:

### UTF-8 Icons (Default)
```
✓  Success    ✗  Error      ⚠  Warning    ℹ  Info
●  Active     ○  Pending    ✓  Done       ⊘  Skip
```

### ASCII Icons (Automatic fallback)
```
[OK]  Success    [X]  Error     [!]  Warning    [i]  Info
[*]   Active     [ ]  Pending   [+]  Done       [-]  Skip
```

**Note:** Icon set is automatically selected based on UTF-8 terminal detection. No configuration needed.

---

## Environment Variable Overrides

### Disable All UI Features
```bash
# Method 1: Oiseau-specific
export UI_DISABLE=1
source oiseau/oiseau.sh

# Method 2: Standard NO_COLOR convention
export NO_COLOR=1
source oiseau/oiseau.sh
```


### Override Individual Colors
```bash
# Colors must be overridden AFTER sourcing (not before)
# The library initializes all colors during sourcing
source oiseau/oiseau.sh

# Now override specific colors
export COLOR_ERROR='\033[38;5;201m'    # Bright magenta
export COLOR_SUCCESS='\033[38;5;46m'   # Brighter green
export COLOR_WARNING='\033[38;5;208m'  # Different orange
export COLOR_INFO='\033[38;5;45m'      # Lighter blue
```

### Force Border Style
```bash
# Override must happen AFTER sourcing (not before)
# The library auto-detects UTF-8 support during initialization
source oiseau/oiseau.sh

# Force ASCII borders even in UTF-8 terminals
export OISEAU_HAS_UTF8=0

# Or force UTF-8 borders (only if your terminal truly supports it)
export OISEAU_HAS_UTF8=1
```

### Force Display Mode
```bash
# Override must happen AFTER sourcing (not before)
# The library auto-detects the best mode during initialization
source oiseau/oiseau.sh

# Force plain mode (no colors, ASCII only)
export OISEAU_MODE=plain

# Or force color mode (colors but ASCII borders)
export OISEAU_MODE=color

# Or force rich mode (colors + UTF-8 borders)
export OISEAU_MODE=rich
```

---

## Examples

### Example 1: Zero Configuration (Recommended)
```bash
#!/bin/bash
source oiseau/oiseau.sh

show_success "Everything works perfectly with zero config!"
show_box error "Build Failed" "npm run build returned exit code 1"
```

**Result:** Beautiful, modern UI that automatically adapts to your terminal.

---

### Example 2: Corporate Environment (ASCII Only)
```bash
#!/bin/bash
source oiseau/oiseau.sh

# Force ASCII for maximum compatibility (override after sourcing)
export OISEAU_HAS_UTF8=0

show_success "Deployment started"
show_box info "Status" "All systems operational"
```

**Result:** Plain ASCII borders and icons, full color support maintained.

---

### Example 3: Custom Brand Colors
```bash
#!/bin/bash
source oiseau/oiseau.sh

# Override colors to match company branding (after sourcing)
export COLOR_SUCCESS='\033[38;5;46m'   # Brighter green
export COLOR_ERROR='\033[38;5;160m'    # Darker red
export COLOR_INFO='\033[38;5;33m'      # Deeper blue

show_success "Build completed"
show_error "Tests failed"
show_info "Deploying to staging"
```

**Result:** Same beautiful UI, different color scheme.

---

## What You CANNOT Customize

The following are intentionally not customizable to maintain simplicity:

- **Per-widget styling** - All widgets of the same type look identical
- **Theme files** - No JSON/YAML theme configuration
- **Custom icons** - Only UTF-8 or ASCII icon sets
- **Border characters** - Cannot mix border styles
- **Widget layouts** - Padding, spacing, structure is fixed

**Why?** This is a simple bash UI library for scripts, not a GUI framework. Consistency and simplicity are more valuable than infinite flexibility.

---

## Recommended Practices

### DO:
- Use zero configuration for 99% of scripts
- Override colors sparingly for branding needs
- Use `UI_DISABLE=1` for machine-readable output
- Respect terminal auto-detection

### DON'T:
- Override multiple environment variables unless necessary
- Force UTF-8 mode on non-UTF-8 terminals
- Try to customize per-widget (not supported)
- Fight the defaults - they're designed to work everywhere

---

## Testing Your Customization

```bash
# Test in all three modes
OISEAU_MODE=rich ./your-script.sh
OISEAU_MODE=color ./your-script.sh
OISEAU_MODE=plain ./your-script.sh

# Test in pipe (should auto-detect plain mode)
./your-script.sh | cat

# Test with NO_COLOR
NO_COLOR=1 ./your-script.sh

# Run the gallery to see all widgets
./gallery.sh
```

---

## Summary

Oiseau is designed around **convention over configuration**:

1. **It just works** - Beautiful UI with zero setup
2. **Smart defaults** - Auto-detects terminal capabilities
3. **Simple overrides** - Environment variables for rare customization needs
4. **No complexity** - No themes, no per-widget params, no config files

**The best customization is no customization.**
