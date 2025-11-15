# Oiseau Validation Report

**Date:** 2025-11-15
**Version:** 1.0.0
**Reviewer:** Architecture Validation Agent

---

## Executive Summary

Oiseau is a well-designed bash UI library that successfully implements its core mission: zero-dependency terminal widgets with smart degradation. However, it currently lacks a customization mechanism, creating an inconsistency between its "modern" positioning and user flexibility expectations.

**Critical Finding:** The library needs a **simple, environment-variable-based customization system** that maintains the KISS principle while providing basic user control over border styles, box widths, and color modes.

---

## Widget Implementation Validation

### ✅ Strengths

#### 1. Terminal Detection (Lines 23-72)
- **Good:** Detection of TTY, color support, and UTF-8 logic is sound
- **Excellent:** Proper fallback chain (rich → color → plain)
- **Excellent:** Respects NO_COLOR and UI_DISABLE standards
- **Excellent:** Cached terminal width detection
- **Issue:** Uses `local` at top level (lines 39, 54) which causes errors in strict bash environments. Should use regular variables instead.

#### 2. Security (Line 151-155)
- **Excellent:** Input sanitization via `_escape_input()`
- **Excellent:** ANSI code stripping prevents injection
- **Excellent:** Control character removal
- **Good:** Applied consistently across all widgets

#### 3. Widget Implementation Quality
- **Excellent:** All 30+ widgets implemented correctly
- **Excellent:** Consistent API design
- **Excellent:** Word wrapping in boxes (line 353)
- **Excellent:** Auto-clamping to terminal width
- **Good:** Backward compatibility aliases (lines 554-562)

#### 4. Code Quality
- **Excellent:** Clear function organization
- **Excellent:** Comprehensive comments
- **Good:** Bash 4.0+ compatibility
- **Good:** Utility functions well-abstracted

### ⚠️ Critical Issues

#### 1. Inconsistent Border Usage
**Location:** Lines 128-144, 285, 341, 436

**Problem:**
- `show_section_header()` uses rounded borders (BOX_RTL, BOX_RBL)
- `show_box()` uses double borders (BOX_DTL, BOX_DBL)
- `show_summary()` uses rounded borders (BOX_RTL, BOX_RBL)

**Impact:**
- Visual inconsistency across widgets
- No clear design rationale
- User cannot control preference

**Root Cause:**
- Hardcoded border characters per widget
- Two separate border variable sets defined but no selection mechanism
- No global border style variable

**Example:**
```bash
# Current behavior - mixed styles
show_section_header "Step 1"  # Rounded: ╭───╮
show_box error "Failed" "msg" # Double: ┏━━━┓
show_summary "Done" "item"    # Rounded: ╭───╮
```

#### 2. No Customization Mechanism
**Location:** Entire codebase

**Problem:**
- Border style cannot be changed without editing source
- Box width is hardcoded at 60 (lines 281, 337, 433)
- Color palette is all-or-nothing (256 colors or none)

**Impact:**
- Users with strong aesthetic preferences must fork
- No way to adapt to different terminal environments
- Limits adoption in environments with specific requirements

**Missing:**
- Environment variable overrides
- Global border style selection
- Adjustable box width
- Color mode options (256 vs 16-color)

#### 3. Duplicate Border Definitions
**Location:** Lines 127-143

**Problem:**
```bash
# Two sets of rounded border variables
BOX_RTL / BOX_RTR / BOX_RBL / BOX_RBR  # One set
BOX_DTL / BOX_DTR / BOX_DBL / BOX_DBR  # Another set
```

**Impact:**
- Confusing naming (R = rounded, D = double, but not documented)
- No mechanism to choose between them
- Code duplication

---

## Customization Validation

### Current State: ❌ No Customization Support

| Question | Answer | Evidence |
|----------|--------|----------|
| Can users change border style globally? | **NO** | Hardcoded per widget, no env var |
| Can users change colors globally? | **PARTIAL** | Only via NO_COLOR=1 (disable only) |
| Can users change box width globally? | **NO** | Hardcoded at 60, no override |
| Does it work with zero config? | **YES** | Defaults work out of box |
| Is it simple? | **YES** | Simple to use, but inflexible |

### Proposed State: ✅ Simple Customization via Environment Variables

| Question | Answer | Mechanism |
|----------|--------|-----------|
| Can users change border style globally? | **YES** | `OISEAU_BORDER_STYLE=double` |
| Can users change colors globally? | **YES** | `OISEAU_COLORS=basic` |
| Can users change box width globally? | **YES** | `OISEAU_BOX_WIDTH=80` |
| Does it work with zero config? | **YES** | All defaults maintained |
| Is it simple? | **YES** | 3 optional env vars, no config files |

---

## Design Principle Validation

### KISS Principle: ✅ PASSES (with proposed changes)

**Current Implementation:**
- ✅ Zero dependencies
- ✅ Simple function calls
- ✅ No config files
- ✅ Sensible defaults
- ❌ No flexibility (too rigid)

**Proposed Customization:**
- ✅ Maintains zero dependencies
- ✅ Maintains simple function calls
- ✅ Still no config files
- ✅ Preserves all defaults
- ✅ Adds minimal, optional flexibility

**Complexity Assessment:**
- Environment variables: **Simple** (standard unix pattern)
- Number of settings: **3** (minimal)
- Breaking changes: **Zero**
- Learning curve: **None** (optional, documented)

### Security Validation: ✅ PASSES (with caveats)

- Input sanitization: **Implemented correctly**
- ANSI injection prevention: **Working**
- Control character stripping: **Working**
- Eval usage: **Limited to one function** (`show_checklist` line 402 uses eval for bash 3.x/4.x array compatibility). Usage is controlled (nameref-style array dereferencing) but should be documented as a security consideration.

### Compatibility Validation: ✅ PASSES

- Bash 4.0+ requirement: **Met**
- Graceful degradation: **Working**
- Pipe detection: **Working**
- NO_COLOR standard: **Respected**

---

## Comparison: Complex vs Simple Customization

### ❌ What We're NOT Recommending (Too Complex)

```bash
# Theme files
~/.oiseau/themes/my-theme.toml

# Per-widget customization
show_box error "msg" --border=double --width=80 --color=red

# Plugin system
oiseau_load_plugin "custom-borders"

# Configuration API
oiseau_config_set "box.border" "double"
```

**Why Not:**
- Violates KISS principle
- Adds dependencies (TOML parser)
- Increases code complexity
- Creates maintenance burden
- Steep learning curve

### ✅ What We ARE Recommending (Simple)

```bash
# Three optional environment variables
export OISEAU_BORDER_STYLE=double  # rounded, double, ascii
export OISEAU_BOX_WIDTH=80         # numeric
export OISEAU_COLORS=basic         # auto, basic, none

source oiseau/oiseau.sh
```

**Why This Works:**
- Zero breaking changes
- Standard unix pattern
- No new dependencies
- Minimal code changes (~50 lines)
- Zero learning curve
- Maintains simplicity

---

## Implementation Impact Assessment

### Code Changes Required

**Minimal:** ~50-75 lines of code changes

1. **Initialization section** (after line 72):
   - Add 15 lines: Read and validate env vars

2. **Border definition section** (lines 122-144):
   - Refactor 20 lines: Consolidate border selection

3. **Widget functions** (3 locations):
   - Update 3 lines: Use OISEAU_BOX_WIDTH
   - Update 12 lines: Use consolidated border vars

4. **Color section** (lines 81-116):
   - Add 10 lines: Support basic color mode

### Breaking Changes

**NONE** - All changes are backward compatible:
- Default behavior unchanged
- New env vars are optional
- Existing scripts continue to work
- No API changes

### Testing Required

- ✅ Zero config (default behavior)
- ✅ OISEAU_BORDER_STYLE=rounded
- ✅ OISEAU_BORDER_STYLE=double
- ✅ OISEAU_BORDER_STYLE=ascii
- ✅ OISEAU_BOX_WIDTH=80
- ✅ OISEAU_COLORS=basic
- ✅ Invalid values (should default)
- ✅ All three modes (rich, color, plain)

---

## Recommendations

### 🔴 CRITICAL: Implement Simple Customization System

**Priority:** HIGH
**Effort:** LOW (50-75 lines)
**Impact:** HIGH (user satisfaction)

**Action Items:**
1. Implement 3-border-style system (rounded, double, ascii)
2. Add OISEAU_BOX_WIDTH environment variable override
3. Add OISEAU_COLORS environment variable (auto, basic, none)
4. Consolidate duplicate border variable definitions
5. Update all widgets to use unified border variables
6. Update README with customization examples

**Rationale:**
- Addresses #1 user request (flexibility)
- Maintains KISS principle
- Zero breaking changes
- Minimal code impact
- Standard unix pattern

### 🟡 MEDIUM: Standardize Border Usage

**Priority:** MEDIUM
**Effort:** LOW (included in above)
**Impact:** MEDIUM (visual consistency)

**Action Items:**
1. Document border style choices
2. Make default consistent across all widgets
3. Let users override via OISEAU_BORDER_STYLE

**Rationale:**
- Currently inconsistent (rounded vs double)
- User confusion about default style
- Fixed by customization system

### 🟢 LOW: Enhance Documentation

**Priority:** LOW
**Effort:** LOW
**Impact:** MEDIUM

**Action Items:**
1. Add "Customization" section to README
2. Document all environment variables
3. Add examples of common customizations
4. Update gallery.sh to demo custom styles

---

## Validation Summary

### Overall Assessment: ✅ STRONG (with recommendations)

**Core Functionality:** 9/10
- Excellent widget implementation
- Robust terminal detection
- Strong security practices
- Good code quality

**Flexibility:** 5/10 (Current) → 9/10 (With Changes)
- Currently too rigid
- Simple env var system solves this
- Maintains simplicity

**KISS Compliance:** 8/10 (Current) → 10/10 (With Changes)
- Currently very simple but inflexible
- Proposed changes add flexibility without complexity

### Final Recommendation

**Implement the simple 3-environment-variable customization system:**

1. **OISEAU_BORDER_STYLE** - Choose border style (rounded/double/ascii)
2. **OISEAU_BOX_WIDTH** - Override default box width
3. **OISEAU_COLORS** - Choose color mode (auto/basic/none)

This provides **just enough** customization without violating KISS principles, requires minimal code changes, introduces zero breaking changes, and significantly improves user satisfaction.

**Status:** Ready for implementation
**Risk:** LOW
**Effort:** LOW
**Value:** HIGH

---

## Appendix: Alternative Approaches Considered and Rejected

### Config Files (REJECTED - Too Complex)
- Would require TOML/YAML/INI parser
- Adds dependencies
- Violates zero-dependency requirement

### Command-Line Arguments (REJECTED - Wrong Pattern)
- Bash library, not CLI tool
- Would require changes to every function call
- Breaks existing code

### Per-Widget Customization (REJECTED - Too Complex)
- Exponential complexity increase
- Violates KISS principle
- Adds cognitive load

### Theme System (REJECTED - Too Complex)
- Requires theme file format
- Requires theme loading logic
- Far exceeds user needs
- Maintenance burden

### CSS-Like Styling (REJECTED - Absurd for Bash)
- Completely inappropriate for bash
- Massive complexity
- No real-world use case

---

**Conclusion:** The simple environment variable approach is the **only** solution that maintains KISS principles while addressing the customization gap.
