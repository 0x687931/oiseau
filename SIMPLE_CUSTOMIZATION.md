# Simple Customization Design for Oiseau

## Design Philosophy: KISS

This customization system follows the **Keep It Simple, Stupid** principle:
- Zero configuration required for default behavior
- Environment variables only (no config files)
- Global settings only (no per-widget customization)
- Three simple options per setting

## Customization Options

### 1. Border Style (`OISEAU_BORDER_STYLE`)

**Purpose:** Allow users to choose their preferred box drawing style globally.

**Options:**
- `rounded` (default) - ╭─╮│╰─╯
- `double` - ┏━┓┃┗━┛
- `ascii` - +---+ |

**Usage:**
```bash
export OISEAU_BORDER_STYLE=double
source oiseau/oiseau.sh
```

**Behavior:**
- Applies to ALL box-drawing widgets (show_box, show_section_header, show_summary)
- Automatically falls back to ASCII if UTF-8 unavailable
- Invalid values default to "rounded"

### 2. Box Width (`OISEAU_BOX_WIDTH`)

**Purpose:** Allow users to adjust the default width of boxed widgets.

**Options:**
- Numeric value (e.g., 60, 80, 100)
- Default: 60
- Still clamped to terminal width minus 4

**Usage:**
```bash
export OISEAU_BOX_WIDTH=80
source oiseau/oiseau.sh
```

**Behavior:**
- Applies to show_box, show_section_header, show_summary
- Invalid values default to 60
- Always respects terminal width limits

### 3. Color Palette (`OISEAU_COLORS`)

**Purpose:** Allow users to disable or adjust color intensity.

**Options:**
- `auto` (default) - Full 256-color palette with auto-detection
- `basic` - 16-color fallback for better compatibility
- `none` - No colors (equivalent to NO_COLOR=1)

**Usage:**
```bash
export OISEAU_COLORS=basic
source oiseau/oiseau.sh
```

**Behavior:**
- `auto` - Current behavior (256 colors)
- `basic` - Use 16-color ANSI codes instead
- `none` - Disable all colors

## Implementation Strategy

### Initialization (oiseau.sh lines 23-72)

After terminal detection, read environment variables:

```bash
# Border style selection
OISEAU_BORDER_STYLE="${OISEAU_BORDER_STYLE:-rounded}"
case "$OISEAU_BORDER_STYLE" in
    double|rounded|ascii) ;; # valid
    *) OISEAU_BORDER_STYLE="rounded" ;; # default fallback
esac

# Box width override
OISEAU_BOX_WIDTH="${OISEAU_BOX_WIDTH:-60}"
if ! [[ "$OISEAU_BOX_WIDTH" =~ ^[0-9]+$ ]]; then
    OISEAU_BOX_WIDTH=60
fi

# Color palette selection
OISEAU_COLORS="${OISEAU_COLORS:-auto}"
case "$OISEAU_COLORS" in
    none) OISEAU_HAS_COLOR=0 ;;
    basic) OISEAU_COLOR_MODE="basic" ;;
    auto) OISEAU_COLOR_MODE="256" ;;
    *) OISEAU_COLOR_MODE="256" ;;
esac
```

### Border Character Selection (lines 122-144)

Consolidate all border character definitions:

```bash
# Select border style based on OISEAU_BORDER_STYLE and UTF-8 support
if [ "$OISEAU_HAS_UTF8" = "1" ] && [ "$OISEAU_BORDER_STYLE" != "ascii" ]; then
    if [ "$OISEAU_BORDER_STYLE" = "double" ]; then
        # Double borders
        export BOX_TL="┏" BOX_TR="┓" BOX_BL="┗" BOX_BR="┛"
        export BOX_H="━" BOX_V="┃" BOX_VR="┣" BOX_VL="┫"
    else
        # Rounded borders (default)
        export BOX_TL="╭" BOX_TR="╮" BOX_BL="╰" BOX_BR="╯"
        export BOX_H="─" BOX_V="│" BOX_VR="├" BOX_VL="┤"
    fi
else
    # ASCII fallback
    export BOX_TL="+" BOX_TR="+" BOX_BL="+" BOX_BR="+"
    export BOX_H="-" BOX_V="|" BOX_VR="+" BOX_VL="+"
fi
```

### Widget Updates

**Remove hardcoded border characters:**
- Line 285: show_section_header - change BOX_RTL → BOX_TL
- Line 341: show_box - change BOX_DTL → BOX_TL
- Line 436: show_summary - change BOX_RTL → BOX_TL

**Use OISEAU_BOX_WIDTH:**
- Line 281: `local width=$(_clamp_width "$OISEAU_BOX_WIDTH")`
- Line 337: `local width=$(_clamp_width "$OISEAU_BOX_WIDTH")`
- Line 433: `local width=$(_clamp_width "$OISEAU_BOX_WIDTH")`

## What This Design Does NOT Include

Following the KISS principle, explicitly excluded:

- ❌ Theme files or config files
- ❌ Per-widget border style overrides
- ❌ Per-widget width overrides
- ❌ Custom color palettes (beyond basic/256)
- ❌ Runtime configuration APIs
- ❌ Border thickness options
- ❌ Custom border characters
- ❌ Color scheme switching
- ❌ Plugin system

## Validation Checklist

- ✅ Can users change border style globally? **YES** - OISEAU_BORDER_STYLE
- ✅ Can users change colors globally? **YES** - OISEAU_COLORS
- ✅ Can users change box width globally? **YES** - OISEAU_BOX_WIDTH
- ✅ Does it work with zero config? **YES** - All defaults maintained
- ✅ Is it simple? **YES** - 3 environment variables, no config files
- ✅ No breaking changes? **YES** - Defaults preserve current behavior
- ✅ Maintains KISS principle? **YES** - Minimal, focused, simple

## Migration Path

**Current users:**
- No changes required
- Default behavior identical to current version
- Opt-in customization only

**New users:**
- Can use defaults (zero config)
- Can customize with simple env vars
- No learning curve increase

## Example Usage

```bash
# Example 1: Default (no customization)
source oiseau/oiseau.sh
show_box error "Failed" "Something went wrong"
# Uses: rounded borders, 60 width, 256 colors

# Example 2: ASCII borders for compatibility
export OISEAU_BORDER_STYLE=ascii
source oiseau/oiseau.sh
show_box error "Failed" "Something went wrong"
# Uses: ASCII borders, 60 width, 256 colors

# Example 3: Wider boxes with double borders
export OISEAU_BORDER_STYLE=double
export OISEAU_BOX_WIDTH=80
source oiseau/oiseau.sh
show_box error "Failed" "Something went wrong"
# Uses: double borders, 80 width, 256 colors

# Example 4: Basic colors for older terminals
export OISEAU_COLORS=basic
source oiseau/oiseau.sh
show_box error "Failed" "Something went wrong"
# Uses: rounded borders, 60 width, 16 colors

# Example 5: Complete customization
export OISEAU_BORDER_STYLE=double
export OISEAU_BOX_WIDTH=100
export OISEAU_COLORS=basic
source oiseau/oiseau.sh
show_box error "Failed" "Something went wrong"
# Uses: double borders, 100 width, 16 colors
```

## Documentation Updates Required

Add to README.md under "Terminal Modes" section:

```markdown
### Customization

Oiseau supports simple customization via environment variables:

**Border Style:**
```bash
export OISEAU_BORDER_STYLE=double  # rounded (default), double, ascii
```

**Box Width:**
```bash
export OISEAU_BOX_WIDTH=80  # Default: 60
```

**Color Palette:**
```bash
export OISEAU_COLORS=basic  # auto (default), basic, none
```

All settings are optional and have sensible defaults.
```

## Summary

This design provides **just enough** customization without sacrificing simplicity:
- 3 settings, all optional
- Environment variables only
- No config files
- No APIs
- Zero breaking changes
- Maintains zero-config philosophy
