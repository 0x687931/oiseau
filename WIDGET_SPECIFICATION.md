# Oiseau Widget Specification

## Overview
Oiseau is a modern, zero-dependency terminal UI library for Bash that provides 30+ reusable widgets with automatic terminal capability detection and graceful degradation.

## Core Requirements

### Zero Dependencies
- Pure bash implementation (Bash 4.0+)
- No external tools required
- Graceful degradation when optional tools unavailable

### Terminal Mode Support
1. **Rich Mode** - Full 256-color + UTF-8 Unicode
2. **Color Mode** - 256-color + ASCII fallbacks
3. **Plain Mode** - No color, ASCII only (pipes, CI/CD, NO_COLOR=1)

### Widget Categories

#### 1. Status Messages
- `show_success()` - Green checkmark with message
- `show_error()` - Red X with message
- `show_warning()` - Orange warning with message
- `show_info()` - Blue info with message

#### 2. Headers
- `show_header()` - Simple bold header
- `show_subheader()` - Muted subheader
- `show_section_header()` - Boxed header with optional step counter

#### 3. Boxes
- `show_box()` - Styled box with type, title, message, and optional commands
- Types: error, warning, info, success
- Auto-wrapping for long messages
- Command suggestions section

#### 4. Progress & Lists
- `show_progress_bar()` - Progress bar with percentage
- `show_checklist()` - Status-based checklist (done, active, pending, skip)
- `show_summary()` - Summary box with multiple items

#### 5. Interactive Prompts
- `prompt_confirm()` - Yes/no confirmation
- `ask_yes_no()` - Alias for prompt_confirm
- `ask_input()` - Text input with optional default

#### 6. Formatting Helpers
- `print_kv()` - Key-value pairs
- `print_command()` - Code-styled commands
- `print_item()` - Bulleted list items
- `print_section()` - Section titles
- `print_step()` - Numbered steps
- `print_next_steps()` - Next steps list

## Design Principles

### 1. KISS (Keep It Simple, Stupid)
- Simple function calls
- Minimal configuration
- Sensible defaults
- Zero config to get started

### 2. Security
- Input sanitization via `_escape_input()`
- ANSI code removal
- Control character stripping
- Prevents code injection

### 3. Compatibility
- Works in all terminal environments
- Automatic degradation
- Respects NO_COLOR standard
- UI_DISABLE toggle for complete disablement

### 4. Performance
- Terminal detection cached
- Minimal overhead
- No repeated capability checks

## Border/Box Drawing Styles

### Current Implementation
Two box styles available based on terminal UTF-8 support:

1. **Rounded Borders** (UTF-8)
   - Used in: section headers, summary boxes
   - Characters: ╭─╮│╰─╯

2. **Double Borders** (UTF-8)
   - Used in: show_box widgets
   - Characters: ┏━┓┃┗━┛

3. **ASCII Fallback** (No UTF-8)
   - Used in: all modes when UTF-8 unavailable
   - Characters: +---+ |

### Border Style Selection
- Automatically determined by UTF-8 detection
- No user configuration currently available
- Hardcoded per widget type

## Color System

### Current Implementation
- 256-color ANSI palette
- Predefined color constants
- Auto-disabled when color unsupported
- Color variables exported globally

### Color Categories
1. **Status Colors** - Success, error, warning, info, accent
2. **UI Element Colors** - Header, border, muted, dim
3. **Priority Colors** - P0 (critical), P1 (high), P2 (medium)
4. **Special Colors** - Link, code

## Width Management

### Current Implementation
- Auto-detection via `tput cols`
- Default: 60 columns for boxes
- Clamped to terminal width minus 4
- No user override available

## Critical Gaps Identified

### 1. No Customization System
- Border styles are hardcoded per widget
- Colors cannot be overridden
- Box width is fixed at 60
- No environment variable overrides

### 2. Inconsistent Box Usage
- Section headers use rounded borders
- Error/warning boxes use double borders
- No unified border selection mechanism

### 3. Limited Flexibility
- Cannot change border style globally
- Cannot adjust box width globally
- Cannot customize colors beyond editing source

## Requirements for Customization

Based on KISS principle, any customization system should:

1. **Work with zero config** - Current behavior is default
2. **Simple override mechanism** - Environment variables only
3. **Global scope** - One setting affects all widgets
4. **No complexity** - No themes, no config files, no APIs
5. **Three border styles** - rounded, double, ascii (user choice)
6. **Width override** - Single global box width setting
7. **Color override** - Optional color palette selection

## Non-Requirements

To maintain simplicity:

- No per-widget customization
- No theme system
- No config files
- No plugin architecture
- No runtime configuration APIs
- No complex color schemes
