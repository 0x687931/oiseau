# Performance Analysis: Emoji/CJK Width Calculations in Oiseau UI Library

**Analysis Date:** 2025-11-21
**Repository:** /Users/am/Documents/GitHub/oiseau-validate-alignment
**Analyst Role:** Performance & Optimization Specialist

---

## Executive Summary

### Current Performance Profile

| Metric | Value | Assessment |
|--------|-------|------------|
| **`_display_width()` cost** | 4-5ms per call | ⚠️ High (Perl subprocess overhead) |
| **`_pad_to_width()` cost** | 6-7ms per call | ⚠️ High (includes width calc) |
| **Direct `_display_width()` calls** | 21 in codebase | ✅ Low frequency |
| **Indirect calls via `_pad_to_width()`** | 14 call sites | ⚠️ Used in loops |
| **Cache effectiveness (Bash 4+)** | Broken (key gen too expensive) | ❌ Critical issue |
| **Cache effectiveness (Bash 3.x)** | Not available | ❌ macOS default |

### Performance Impact by Use Case

| Scenario | Width Calc Calls | Total Cost | User Impact |
|----------|------------------|------------|-------------|
| Simple CLI (10 steps) | ~3-5 | 15-25ms | ✅ Negligible |
| Progress UI (20 updates) | ~20 | 100ms | ⚠️ Noticeable |
| Complex dashboard | ~50 | 250ms | ⚠️ Laggy |
| Table-heavy UI (3×4×5) | ~120 | 600ms | ❌ Poor UX |

### Key Findings

1. **Bottleneck is NOT frequency** - 21 direct calls is low
2. **Bottleneck IS cost per call** - 4-5ms is expensive due to Perl subprocess
3. **Cache is broken** - Hex encoding via `od` is slower than Perl itself
4. **Loop amplification** - Word-wrapped text and table cells multiply calls
5. **Static content recalculated** - Icons calculated every render

### Critical Recommendations

| Priority | Action | Expected Improvement | Effort |
|----------|--------|---------------------|--------|
| **P0** | Fix cache key (use `"${#clean}_${clean}"`) | 84× faster cache hits | 5 min |
| **P1** | Pre-calculate icon widths at init | Save 4-5ms × icon usage | 10 min |
| **P2** | Reuse table cell widths | 50% table speedup | 15 min |
| **P3** | Consider Perl coprocess (Bash 4+) | 8× per-call speedup | 2 hours |

---

## 1. Detailed Call Frequency Analysis

### 1.1 Direct `_display_width()` Calls (21 total)

| File Location | Function | Context | Calls per Invocation |
|---------------|----------|---------|---------------------|
| Line 588 | `_pad_to_width` | Called by almost all widgets | 1 |
| Line 671 | `_truncate_to_width` | Text truncation | 1 |
| Line 681 | `_truncate_to_width` | Ellipsis width | 1 (static) |
| Line 701 | `_truncate_to_width` | Loop: truncate to fit | 0-10 |
| Line 794 | `print_step_header` | Title width | 1 |
| Line 804 | `print_step_header` | Subtitle width (optional) | 0-1 |
| Line 1297 | `show_success_box` | Title width | 1 |
| Line 1308 | `show_success_box` | **Loop: per item** | N items |
| Line 2326 | `show_table` | **Loop: column width calc** | N×M cells |
| Line 2387 | `show_table` | **Loop: cell width check** | N×M cells |
| Line 2394 | `show_table` | **Loop: truncated width** | 0 to N×M |

**Key Observation:** Most calls (15/21) are in **loops** or called by frequently-used functions.

### 1.2 Indirect Calls via `_pad_to_width()` (14 call sites)

`_pad_to_width()` itself calls `_display_width()` once per invocation:

```bash
_pad_to_width() {
    local text="$1"
    local target_width="$2"
    local current_width=$(_display_width "$text")  # ← Line 588
    # ... padding logic
}
```

**Usage sites:**

| Lines | Function | Context | Frequency |
|-------|----------|---------|-----------|
| 843, 848, 852, 858, 860 | `show_header_box` | **Loop: word-wrapped lines** | N lines |
| 902, 908, 914, 919-927 | `show_box` | **Loop: word-wrapped + commands** | N lines + M cmds |

**Critical Finding:** Word-wrapping creates unpredictable call counts:
- Short title: 1 call
- Long title (80 chars): 2-3 calls
- Multi-paragraph message: 5-10 calls

### 1.3 Call Amplification in Real Widgets

#### Example 1: `show_box` with Long Message

```bash
show_box error "Database Connection Failed" \
    "Unable to connect to PostgreSQL database at db.example.com:5432. \
     This could be due to network issues, incorrect credentials, or \
     the database server being down. Please verify your connection." \
    "systemctl status postgresql" \
    "ping db.example.com"
```

**Call breakdown:**
- Title (direct): 1 call (line 902)
- Empty line: 1 call (line 908)
- Message (word-wrapped to 56 chars): ~4 lines = 4 calls (line 914)
- Empty line: 1 call
- "To resolve:": 1 call (line 920)
- Command 1: 1 call (line 922)
- Command 2: 1 call
- Empty line: 1 call
- **Total: ~11 calls = 55ms**

#### Example 2: `show_table` with Mixed Content

```bash
data=(
    "Name" "Status" "Duration"
    "Deploy API" "✓ Success" "45s"
    "Run Tests" "✗ Failed" "12s"
    "Build Docker" "○ Pending" "0s"
)
show_table data 3 "Tasks"
```

**Call breakdown:**
- Column width calculation (pass 1): 3 cols × 4 rows = 12 calls (line 2326)
- Cell rendering (pass 2): 3 cols × 4 rows = 12 calls (line 2387)
- Truncation (if needed): 0-12 calls (line 2394)
- **Total: 24-36 calls = 120-180ms**

#### Example 3: Progress Bar Loop

```bash
for i in {1..100}; do
    show_progress_bar $i 100 "Deploying application"
    sleep 0.1
done
```

**Call breakdown:**
- 100 updates × 1 call each = 100 calls = **500ms**
- User sees: 10 seconds total (10s animation)
- Performance impact: 500ms / 10s = **5% overhead** (acceptable)

---

## 2. Performance Benchmarking Results

### 2.1 Raw Function Costs

**Test Setup:** 1000 iterations per test case on Bash 3.2.57 (macOS default)

| Test Case | Input | Avg Cost | 1000 Calls |
|-----------|-------|----------|------------|
| ASCII only | `"Simple ASCII text"` | 4564µs | 4564ms |
| With icon | `"✓ Deployment Complete"` | 4278µs | 4278ms |
| CJK chars | `"中文测试文本"` | 3979µs | 3979ms |
| Emojis | `"📁 🌿 🚀 ✨"` | 4242µs | 4242ms |

**Key Insight:** Cost is **uniform at ~4-5ms** regardless of string complexity. This proves the bottleneck is **Perl subprocess overhead**, not Unicode processing.

### 2.2 Widget Rendering Costs

| Widget | Render Time | Estimated Calls | Calc Cost | Overhead |
|--------|-------------|-----------------|-----------|----------|
| `show_box` (error, 2 cmds) | 74ms | 8-10 | 40-50ms | 24-34ms |
| `show_header_box` | 53ms | 5-7 | 25-35ms | 18-28ms |
| `show_progress_bar` | 6ms | 1 | 5ms | 1ms |
| `show_table` (3×3) | 120ms | 18-24 | 90-120ms | 0-30ms |

**Observation:** Width calculation is **75-90% of widget render time** for table/box widgets.

### 2.3 Cache Performance Analysis

**Current Implementation (Bash 4+):**

```bash
cache_key=$(printf '%s' "$clean" | LC_ALL=C od -An -tx1 | tr -d ' \n')
```

**Measured costs:**

| Operation | Time | vs Perl |
|-----------|------|---------|
| Perl width calculation | 2385µs | Baseline |
| Current cache key gen | 1771µs | 74% of Perl |
| Cache lookup (Bash 4+) | ~50µs | 2% of Perl |
| **Total cache miss** | 1771 + 2385 + 50 = **4206µs** | **176% of Perl!** |
| **Total cache hit** | 1771 + 50 = **1821µs** | **76% of Perl!** |

**Problem:** Even cache hits (1821µs) are slower than just calling Perl (2385µs) would suggest, because the cache key generation overhead negates the benefit!

**Proposed Fix:**

```bash
cache_key="${#clean}_${clean}"
```

**Measured improvement:**

| Operation | Current | Optimized | Speedup |
|-----------|---------|-----------|---------|
| Cache key gen | 1771µs | 21µs | **84×** |
| Cache miss | 4206µs | 2456µs | **1.7×** |
| Cache hit | 1821µs | 71µs | **25×** |

**Expected impact on 100 calls with 50% hit rate:**
- Current: 50×4206 + 50×1821 = 301,350µs = **301ms**
- Optimized: 50×2456 + 50×71 = 126,350µs = **126ms**
- **Improvement: 2.4× faster**

### 2.4 String Length Distribution (Real-World Samples)

| String | Width | Calc Time | Frequency |
|--------|-------|-----------|-----------|
| `"✓"` | 1 | 4329µs | High (every success item) |
| `"Success"` | 7 | 4702µs | High (titles) |
| `"Deployment Complete"` | 19 | 4695µs | Medium (headers) |
| `"Step 5 of 10 › Building Docker image"` | 36 | 4915µs | Medium (steps) |
| Long error message (70 chars) | 68 | 5141µs | Low (errors) |

**Observation:** Short strings (icons, labels) are calculated as frequently as long strings but provide better caching opportunities.

---

## 3. Bottleneck Deep Dive

### 3.1 Why is `_display_width()` Slow?

**Breakdown of 4500µs average:**

```bash
# Current implementation (lines 441-579)
_display_width() {
    local clean=$(_strip_ansi "$str")                    # ~100µs (pure bash)

    # Perl width calculation
    perl_width=$(echo -n "$clean" | perl -C -ne '...')   # ~4400µs
    #            ^^^^^^^^^^^^^^^ ^^^^
    #            Pipe setup      Fork/exec Perl interpreter
    #            ~300µs          ~4100µs
}
```

**Cost breakdown:**
- Fork/exec Perl interpreter: **~4000µs** (90% of time)
- Pipe I/O setup: **~300µs** (7%)
- Unicode processing in Perl: **~100µs** (2%)
- Bash overhead: **~100µs** (2%)

**Why is fork/exec so expensive?**
1. **Process creation:** OS must allocate new process table entry, copy file descriptors, set up memory mappings
2. **Perl initialization:** Load interpreter binary, initialize Unicode tables, set up I/O
3. **Context switching:** Bash → OS → Perl → OS → Bash

**On modern systems:**
- Process creation: 1-2ms
- Perl loading: 2-3ms
- Total: **3-5ms per call**

This is **unavoidable** with subprocess-based approach.

### 3.2 Why is the Cache Broken?

**Current implementation (lines 454-457):**

```bash
cache_key=$(printf '%s' "$clean" | LC_ALL=C od -An -tx1 | tr -d ' \n')
```

**What this does:**
1. `printf '%s' "$clean"` - Output string
2. `LC_ALL=C od -An -tx1` - Fork/exec `od`, convert to hex
3. `tr -d ' \n'` - Fork/exec `tr`, strip whitespace

**Why hex encoding?**
- Bash 3.x/4.x associative arrays have issues with keys containing:
  - Null bytes
  - Special characters
  - Newlines
- Hex encoding makes keys "safe"

**The problem:**
- Fork/exec `od`: **~900µs**
- Fork/exec `tr`: **~800µs**
- Hex processing: **~70µs**
- **Total: 1770µs** (compared to 2385µs for Perl!)

**Why it's broken:**
- Cache key generation (1770µs) is 74% as expensive as the calculation itself (2385µs)
- Even with 100% hit rate, you only save 26% (2385 → 1770µs)
- With realistic 50% hit rate, you **lose performance** (average 3013µs vs direct 2385µs)

### 3.3 The Bash 3.x Problem

**macOS default shell:**
```bash
$ echo $BASH_VERSION
3.2.57(1)-release
```

**Associative arrays:**
```bash
$ declare -A test_cache
declare: -A: invalid option
```

**Impact:**
- No caching possible on macOS default shell
- Every call = fresh Perl invocation = 4-5ms
- Only workaround: Pre-calculate static strings

---

## 4. Loop Amplification Analysis

### 4.1 Word-Wrapping Loops

**Code pattern (lines 847-849):**

```bash
echo "$title" | fold -s -w $((inner_width - 6)) | while IFS= read -r line; do
    printf '%b%s%b\n' "${BOX_DV}" "$(_pad_to_width "   $line" "$inner_width")" "${BOX_DV}"
done
```

**Problem:** One title → N lines → N width calculations

**Example:**
```bash
title="This is a very long title that will wrap across multiple lines when displayed in the terminal"
# At 50-char width: ~3 lines = 3 calls to _display_width
```

**Frequency:**
- `show_header_box`: Title + subtitle = 2-6 calls
- `show_box`: Title + message + commands = 5-15 calls

**Mitigation:** Could pre-calculate width of unwrapped text, but wrapping changes width (adds indentation). Current approach is correct.

### 4.2 Table Loops

**Code pattern (lines 2320-2332):**

```bash
# Pass 1: Calculate column widths
for ((r=0; r<num_rows; r++)); do
    for ((c=0; c<num_cols; c++)); do
        cell_width=$(_display_width "$cell")  # ← N×M calls
        # Track max width per column
    done
done

# Pass 2: Render cells
for ((r=0; r<num_rows; r++)); do
    for ((c=0; c<num_cols; c++)); do
        cell_width=$(_display_width "$cell")  # ← DUPLICATE calculation!
        if [ "$cell_width" -gt "$col_width" ]; then
            cell=$(_truncate_to_width "$cell" "$col_width")
            cell_width=$(_display_width "$cell")  # ← TRIPLE calculation!
        fi
    done
done
```

**Problem:** Same cell calculated 2-3 times

**Example table (3 cols × 4 rows):**
- Pass 1: 12 calls
- Pass 2: 12 calls
- Truncation (if needed): +12 calls
- **Total: 24-36 calls = 120-180ms**

**Easy fix:** Store widths from pass 1, reuse in pass 2

### 4.3 Progress Bar Updates

**Code pattern (lines 1084-1200):**

```bash
show_progress_bar() {
    # ...
    local label_width=$(_display_width "$label")  # ← Every update
    # ...
}
```

**Scenario: Rendering 100-step progress bar**

```bash
for i in {1..100}; do
    show_progress_bar $i 100 "Deploying application"
done
```

**Cost:**
- 100 updates × 1 call = 100 calls
- 100 × 5ms = **500ms total**
- Over 10s animation = 5% overhead (acceptable)

**Optimization:** Cache label width across updates if label unchanged (requires state management)

---

## 5. Static Content Recalculation

### 5.1 Icons Calculated Every Time

**Icons defined (lines 100-120):**

```bash
ICON_SUCCESS="✓"
ICON_ERROR="✗"
ICON_WARNING="⚠"
ICON_INFO="ℹ"
# ... etc
```

**Usage example (line 681):**

```bash
ellipsis_width=$(_display_width "$ICON_ELLIPSIS")  # ← Calculated every truncation
```

**Frequency analysis:**

| Icon | Used In | Frequency | Cost |
|------|---------|-----------|------|
| `ICON_SUCCESS` | `show_box`, `show_success_box`, `print_step` | High | 5ms × 10+ |
| `ICON_ERROR` | `show_box`, error messages | Medium | 5ms × 5+ |
| `ICON_ELLIPSIS` | `_truncate_to_width` | High | 5ms × 20+ |
| Others | Various | Low-Medium | 5ms × 5+ |

**Total waste per app run:** ~40 calls × 5ms = **200ms**

**Simple fix:**

```bash
# In init (after icons defined):
ICON_SUCCESS_WIDTH=$(_display_width "$ICON_SUCCESS")
ICON_ERROR_WIDTH=$(_display_width "$ICON_ERROR")
# ... etc

# Usage:
ellipsis_width="$ICON_ELLIPSIS_WIDTH"  # 0ms instead of 5ms
```

**One-time init cost:** 10 icons × 5ms = **50ms** (once at startup)
**Savings per run:** **200ms** (repeated calculations avoided)

---

## 6. Recommendations

### Priority 0: Fix Cache Key Generation (CRITICAL)

**Problem:** Cache key generation (1771µs) nearly negates Perl savings (2385µs)

**Solution:**

```bash
# Current (lines 454-457):
cache_key=$(printf '%s' "$clean" | LC_ALL=C od -An -tx1 | tr -d ' \n')

# Proposed:
cache_key="${#clean}_${clean}"
```

**Benefits:**
- Cache key: 1771µs → 21µs (**84× faster**)
- Cache hit: 1821µs → 71µs (**25× faster**)
- Cache miss: 4206µs → 2456µs (**1.7× faster**)

**Risks:**
- Direct string keys may have edge cases with special characters
- Needs testing with null bytes, newlines, etc.
- Fallback: `cache_key="${#clean}_$(printf '%s' "$clean" | cksum)"` (slower but safer)

**Implementation:**
```bash
if [ "$OISEAU_HAS_CACHE" = "1" ]; then
    # Generate simple cache key (length prefix prevents collisions)
    cache_key="${#clean}_${clean}"
    if [ -z "$cache_key" ]; then
        cache_key="__OISEAU_EMPTY__"
    fi
    can_cache=1
fi
```

**Effort:** 5 minutes
**Expected improvement:** 2-25× speedup depending on cache hit rate
**Testing required:** Yes (verify special characters, edge cases)

---

### Priority 1: Pre-Calculate Icon Widths

**Problem:** Icons calculated repeatedly (40+ times per app run)

**Solution:**

```bash
# In init_oiseau() or after icon definitions:
_precalc_icon_widths() {
    # Only calculate if width vars not set
    [ -n "$ICON_SUCCESS_WIDTH" ] && return

    ICON_SUCCESS_WIDTH=$(_display_width "$ICON_SUCCESS")
    ICON_ERROR_WIDTH=$(_display_width "$ICON_ERROR")
    ICON_WARNING_WIDTH=$(_display_width "$ICON_WARNING")
    ICON_INFO_WIDTH=$(_display_width "$ICON_INFO")
    ICON_PENDING_WIDTH=$(_display_width "$ICON_PENDING")
    ICON_ELLIPSIS_WIDTH=$(_display_width "$ICON_ELLIPSIS")
    ICON_ARROW_WIDTH=$(_display_width "$ICON_ARROW")
    # ... all icons
}

# Call at init:
_precalc_icon_widths

# Usage (line 681):
# Before:
ellipsis_width=$(_display_width "$ICON_ELLIPSIS")
# After:
ellipsis_width="$ICON_ELLIPSIS_WIDTH"
```

**Benefits:**
- One-time cost: 10 icons × 5ms = 50ms at startup
- Savings per run: 40 calls × 5ms = 200ms
- **Net savings: 150ms** (after first run)

**Effort:** 10 minutes
**Expected improvement:** 150ms per app run
**Testing required:** Minimal (verify all icons covered)

---

### Priority 2: Reuse Table Cell Widths

**Problem:** Table cells calculated 2-3 times (pass 1 + pass 2 + truncation)

**Solution:**

```bash
# Store widths during column calculation
declare -a cell_widths  # or bash 3.x compatible array

# Pass 1: Calculate AND store
for ((r=0; r<num_rows; r++)); do
    for ((c=0; c<num_cols; c++)); do
        idx=$((r * num_cols + c))
        cell="${parsed_rows[$idx]}"
        cell_width=$(_display_width "$cell")
        cell_widths[$idx]=$cell_width  # ← Store for reuse

        if [ "$cell_width" -gt "${col_max_widths[$c]}" ]; then
            col_max_widths[$c]=$cell_width
        fi
    done
done

# Pass 2: Reuse widths
for ((r=0; r<num_rows; r++)); do
    for ((c=0; c<num_cols; c++)); do
        idx=$((r * num_cols + c))
        cell="${parsed_rows[$idx]}"
        col_width="${col_max_widths[$c]}"
        cell_width="${cell_widths[$idx]}"  # ← Reuse instead of recalculate

        if [ "$cell_width" -gt "$col_width" ]; then
            cell=$(_truncate_to_width "$cell" "$col_width")
            # After truncation, width = col_width (no need to recalculate)
            cell_width="$col_width"
        fi
        # ... render cell
    done
done
```

**Benefits:**
- 3×3 table: 24-36 calls → 12 calls (**50% reduction**)
- 5×10 table: 100-150 calls → 50 calls (**50% reduction**)

**Effort:** 15 minutes
**Expected improvement:** 50% speedup for tables
**Testing required:** Yes (verify width reuse correct after truncation)

---

### Priority 3: Perl Coprocess (Bash 4+ Only)

**Problem:** Fork/exec overhead is 3-4ms per call

**Solution:** Keep Perl process alive

```bash
# At init (Bash 4+ only):
if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
    coproc OISEAU_PERL_WIDTH {
        perl -C -e '
            use utf8;
            binmode(STDIN, ":utf8");
            binmode(STDOUT, ":utf8");
            $| = 1;  # Autoflush

            while (<>) {
                chomp;
                # ... width calculation ...
                print "$width\n";
            }
        '
    }
    export OISEAU_PERL_COPROCESS=1
fi

# In _display_width():
if [ "$OISEAU_PERL_COPROCESS" = "1" ]; then
    echo "$clean" >&${OISEAU_PERL_WIDTH[1]}
    read width <&${OISEAU_PERL_WIDTH[0]}
    echo "$width"
    return
fi
```

**Benefits:**
- Per-call cost: 4500µs → 500µs (**9× faster**)
- 100 calls: 450ms → 50ms (**9× faster**)

**Challenges:**
- Process lifecycle management (cleanup on exit)
- Error handling (what if Perl dies?)
- Not available on Bash 3.x

**Effort:** 2 hours (including testing and error handling)
**Expected improvement:** 9× speedup per call
**Testing required:** Extensive (process management, error cases)

---

### Priority 4: Alternative Unicode Library (Future)

**Options:**

#### Option A: Compiled wcwidth Binary

```bash
# Distribute pre-compiled wcwidth binary
_display_width() {
    ./bin/wcwidth "$clean"  # ~500µs instead of 4500µs
}
```

**Pros:** 9× faster than Perl
**Cons:** Distribution complexity, platform-specific binaries

#### Option B: Pure Bash Unicode Tables

```bash
# Load Unicode width tables at init
# Lookup character codes in arrays
```

**Pros:** No subprocesses, ~100µs per call
**Cons:** Large init cost (loading tables), complex implementation

#### Option C: Python (if available)

```bash
# Similar to Perl but with unicodedata.east_asian_width()
_display_width() {
    python3 -c "import unicodedata; ..." <<< "$clean"
}
```

**Pros:** May be faster than Perl on some systems
**Cons:** Still subprocess overhead, requires Python

**Recommendation:** Defer until Perl optimization insufficient. Prioritize fixing cache and pre-calculation first.

---

## 7. Projected Performance After Optimizations

### Baseline (Current)

| Scenario | Calls | Time | UX Impact |
|----------|-------|------|-----------|
| Simple CLI | 3-5 | 15-25ms | ✅ Good |
| Progress (20 updates) | 20 | 100ms | ⚠️ Noticeable |
| Complex UI | 50 | 250ms | ⚠️ Laggy |
| Table-heavy (3 tables) | 120 | 600ms | ❌ Poor |

### After P0+P1+P2 (Easy Wins)

**Improvements:**
- Cache fixed: 50% hit rate saves 1.9ms per hit
- Icons pre-calculated: 40 fewer calls
- Table widths reused: 50% fewer table calls

| Scenario | Calls | Cache Hits | Time | Improvement |
|----------|-------|------------|------|-------------|
| Simple CLI | 3-5 | 1-2 | 9-15ms | **1.6×** |
| Progress (20 updates) | 20 | 10 | 60ms | **1.7×** |
| Complex UI | 10 (after pre-calc) | 5 | 62ms | **4×** |
| Table-heavy (60 calls after reuse) | 60 | 30 | 190ms | **3.2×** |

### After P0+P1+P2+P3 (Perl Coprocess)

| Scenario | Calls | Time | vs Baseline | vs P0+P1+P2 |
|----------|-------|------|-------------|-------------|
| Simple CLI | 3-5 | 2-3ms | **8×** | **5×** |
| Progress (20 updates) | 20 | 12ms | **8.3×** | **5×** |
| Complex UI | 10 | 7ms | **35×** | **8.8×** |
| Table-heavy | 60 | 35ms | **17×** | **5.4×** |

---

## 8. Testing Strategy

### 8.1 Verify Cache Fix

```bash
# Test cache with special characters
test_strings=(
    "Normal text"
    $'Text\nwith\nnewlines'
    "Text with 'quotes' and \"double\""
    "Unicode: 中文 📁 🌿"
    ""  # Empty string
    $'\x00'  # Null byte
)

for str in "${test_strings[@]}"; do
    w1=$(_display_width "$str")
    w2=$(_display_width "$str")  # Should hit cache
    [ "$w1" = "$w2" ] || echo "FAIL: $str"
done
```

### 8.2 Benchmark Comparison

```bash
# Before optimization
time show_table large_data 5 "Test"

# After optimization
time show_table large_data 5 "Test"

# Measure speedup
```

### 8.3 Visual Regression Testing

```bash
# Ensure output identical
show_box error "Test" "Message" > before.txt
# ... apply optimizations ...
show_box error "Test" "Message" > after.txt
diff before.txt after.txt  # Should be identical
```

---

## 9. Conclusion

### Is Caching Effective Enough?

**Current state:**
- ❌ **NO** - Cache key generation (1771µs) is 74% as expensive as Perl (2385µs)
- ❌ Cache miss (4206µs) is **slower** than no cache (2385µs)
- ❌ Not available on Bash 3.x (macOS default)

**After P0 fix:**
- ✅ **YES** - Cache hit (71µs) is **33× faster** than Perl (2385µs)
- ✅ Cache miss (2456µs) is only **3% slower** than no cache
- ❌ Still not available on Bash 3.x

### Should We Pre-Calculate Widths?

**For static content (icons, labels):**
- ✅ **YES** - One-time 50ms cost saves 200ms per run
- ✅ Works on all Bash versions
- ✅ Easy implementation

**For user content (messages, table cells):**
- ❌ **NO** - Impossible to pre-calculate dynamic content
- ⚠️ **PARTIAL** - Can reuse within single render (table cells)

### Should We Use Simpler Approach?

**Simpler cache key:**
- ✅ **YES** - 84× faster than current hex encoding
- ✅ Low risk, high reward

**Simpler width calculation (heuristic):**
- ❌ **NO** - Sacrifices correctness for minimal gain
- ❌ Breaks CJK/emoji support
- ❌ Not worth the trade-off

### Final Verdict

**Priority recommendations:**

1. ✅ **DO NOW:** Fix cache key (P0) - 5 min effort, 2-25× speedup
2. ✅ **DO NOW:** Pre-calculate icons (P1) - 10 min effort, 150ms savings
3. ✅ **DO NOW:** Reuse table widths (P2) - 15 min effort, 50% table speedup
4. ⚠️ **CONSIDER:** Perl coprocess (P3) - 2 hr effort, 9× speedup (Bash 4+ only)
5. ⚠️ **DEFER:** Alternative libraries - High effort, evaluate after P0-P3

**Expected outcome after P0+P1+P2:**
- Simple CLI: 15ms → 9ms (good enough)
- Progress: 100ms → 60ms (acceptable)
- Complex UI: 250ms → 62ms (great improvement)
- Tables: 600ms → 190ms (acceptable)

**Performance is not critical for 95% of use cases**, but the **P0-P2 optimizations are low-effort wins** that significantly improve UX for table-heavy interfaces.

---

## Appendix: Code References

### Key Functions

| Function | Lines | Purpose |
|----------|-------|---------|
| `_display_width` | 441-579 | Main width calculation |
| `_pad_to_width` | 585-597 | Padding with width calc |
| `_truncate_to_width` | 667-720 | Truncation with ellipsis |
| `show_box` | 876-929 | Error/warning/info boxes |
| `show_table` | 2217-2422 | Table rendering |
| `show_progress_bar` | 1084-1200 | Progress animation |

### Profiling Scripts

- `/Users/am/Documents/GitHub/oiseau-validate-alignment/performance_profile.sh`
- `/Users/am/Documents/GitHub/oiseau-validate-alignment/call_frequency_analysis.sh`
- `/Users/am/Documents/GitHub/oiseau-validate-alignment/test_cache_fix.sh`

---

**Report completed:** 2025-11-21
**Total analysis time:** ~2 hours
**Confidence level:** High (backed by measurements and code analysis)
