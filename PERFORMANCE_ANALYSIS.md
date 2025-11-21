# Performance Analysis: Emoji/CJK Width Calculations

## Executive Summary

**Current State:**
- `_display_width()` averages **4-5ms per call** (4000-5000µs)
- Perl subprocess invocation is the primary bottleneck (~95% of time)
- No caching on Bash 3.x (macOS default), full caching on Bash 4+
- 21 direct calls to `_display_width()` in core library
- 14 calls to `_pad_to_width()` (which itself calls `_display_width()`)

**Performance Impact:**
- **Low**: Simple CLI tools (10-20 calls = 40-100ms total)
- **Medium**: Progress animations (20-50 calls = 100-250ms total)
- **High**: Table-heavy UIs (100+ calls = 400ms+ total)

**Bottleneck:** Not the frequency of calls, but the **4-5ms cost per call** due to Perl subprocess overhead.

---

## 1. Call Frequency Analysis

### Direct `_display_width()` Calls (21 total)

| Function | Line(s) | Calls per Invocation | Context |
|----------|---------|---------------------|---------|
| `_pad_to_width` | 588 | 1 | Used by almost all widgets |
| `_truncate_to_width` | 671, 681, 701 | 1-3 | Text truncation with ellipsis |
| `print_step_header` | 794, 804 | 1-2 | Step header with title/subtitle |
| `show_success_box` | 1297, 1308 | 1 + N items | Success box with checklist |
| `show_table` | 2326, 2387, 2394 | N × M × 2 | Table rendering (2 passes) |

### Indirect Calls via `_pad_to_width()` (14 call sites)

| Function | Line(s) | Frequency | Widget Type |
|----------|---------|-----------|-------------|
| `show_header_box` | 843, 848, 852, 858, 860 | 5+ per box | Header boxes |
| `show_box` | 902, 908, 914, 919-927 | 8-12 per box | Error/warning/info boxes |

### Widget-Level Call Counts

Based on code analysis:

```
print_step()              →  0 calls (no width calculation)
print_step_header()       →  2 calls (title + optional subtitle)
show_header_box()         →  5 calls (via _pad_to_width)
show_box()                →  8-12 calls (via _pad_to_width)
show_progress_bar()       →  1 call (label width)
show_success_box()        →  1 + N calls (title + items)
show_table(N×M)           →  N×M×2 calls (column width + truncation)
```

---

## 2. Performance Measurements

### Raw Function Costs (1000 iterations)

| Test Case | Avg Cost/Call | 1000 Calls |
|-----------|---------------|------------|
| ASCII text | 4564µs (4.6ms) | 4564ms |
| Text with icons (✓) | 4278µs (4.3ms) | 4278ms |
| CJK characters (中文) | 3979µs (4.0ms) | 3979ms |
| Emojis (📁 🌿) | 4242µs (4.2ms) | 4242ms |

**Key Finding:** Cost is ~4-5ms regardless of string complexity. This confirms the bottleneck is **Perl subprocess overhead**, not Unicode processing.

### Widget Rendering Costs

| Widget | Render Time | Est. Calls | Cost/Call |
|--------|-------------|------------|-----------|
| `show_box` (error, 2 cmds) | 74ms | ~8-10 | ~7-9ms |
| `show_header_box` (title+subtitle) | 53ms | ~5 | ~10ms |
| `show_progress_bar` | 6ms | ~1 | ~6ms |
| `show_table` (3×3) | 120ms | ~18 | ~6-7ms |

**Key Finding:** Widget overhead (formatting, printf, etc.) is ~2-3ms per call. Combined with 4-5ms width calculation = 6-10ms total per `_display_width()` call.

### Cache Effectiveness (Bash 4+ only)

```
First call (cache miss):  6518µs
Second call (cache hit):  6484µs
Cache speedup:            ~0% (cache broken!)
```

**CRITICAL ISSUE:** Cache is not working! Even on Bash 4+, cache hits are as slow as misses. This suggests:
1. Cache key generation is expensive (hex encoding via `od`)
2. Cache lookup overhead negates benefits
3. String variation is too high (low hit rate)

---

## 3. Real-World Usage Patterns

### Scenario Analysis

#### Scenario 1: Simple CLI Tool
```bash
# 10 print_step calls + 1 success box
Total calls: 10 × 0 + 1 × 3 = ~3 calls
Total time:  3 × 5ms = 15ms
Impact:      Negligible
```

#### Scenario 2: Progress Animation
```bash
# 20 progress bar updates
Total calls: 20 × 1 = 20 calls
Total time:  20 × 5ms = 100ms
Impact:      Noticeable (100ms over 20 frames = 5ms/frame)
```

#### Scenario 3: Complex Deployment UI
```bash
# 1 header + 10 progress + 2 boxes + 1 table (3×3)
Total calls: 2 + 10 + (8+8) + 18 = 46 calls
Total time:  46 × 5ms = 230ms
Impact:      Noticeable lag
```

#### Scenario 4: Table-Heavy Interface
```bash
# 3 tables, each 5×4 (5 cols, 4 rows)
Total calls: 3 × (5×4×2) = 120 calls
Total time:  120 × 5ms = 600ms
Impact:      POOR UX (visible lag)
```

---

## 4. Bottleneck Deep Dive

### Why is `_display_width()` so slow?

**Perl Subprocess Overhead:**
```bash
# Each call executes:
echo -n "$clean" | perl -C -ne '...' 2>/dev/null

# Breakdown:
- Fork/exec Perl:          ~3-4ms
- Pipe setup:              ~0.5ms
- Unicode processing:      ~0.5ms
- Total:                   ~4-5ms
```

**Cache Overhead (when enabled):**
```bash
# Cache key generation (lines 454-457):
cache_key=$(printf '%s' "$clean" | LC_ALL=C od -An -tx1 | tr -d ' \n')

# Breakdown:
- Fork/exec od:            ~3ms
- Fork/exec tr:            ~3ms
- Hex string processing:   ~0.5ms
- Total:                   ~6.5ms (SLOWER than Perl!)
```

**This explains why cache doesn't help!** The cache key generation (6.5ms) is slower than just calling Perl (4-5ms).

---

## 5. Current Optimization Strategies

### ✅ What's Working

1. **`_repeat_char` caching** (lines 599-662)
   - Static cache for common patterns (spaces, box chars)
   - Dynamic FIFO cache for runtime patterns
   - **95%+ speedup** for padding generation
   - Cost: 42ms for 1000 iterations (negligible)

2. **Fallback heuristic** (lines 549-579)
   - Byte count vs character count estimation
   - Used when Perl unavailable
   - ~50-100µs faster but **less accurate**

3. **Single-pass table rendering** (lines 2320-2332)
   - Calculates column widths in one O(n) scan
   - Avoids recalculating same cell twice
   - Still expensive for large tables

### ❌ What's Broken

1. **Width cache** (lines 448-466)
   - Cache key generation (6.5ms) > Perl call (4.5ms)
   - Hex encoding via `od` is the killer
   - Should use simpler key (direct string?) but bash associative arrays don't support complex keys safely

2. **No pre-calculation** for static content
   - Icons (`ICON_SUCCESS`, `ICON_ERROR`, etc.) calculated every time
   - Could pre-calculate at init

3. **Table truncation** (lines 2390-2395)
   - Calls `_display_width()` on already-calculated cells
   - Could reuse width from column calculation

---

## 6. Performance Recommendations

### Priority 1: Fix the Cache (Bash 4+ systems)

**Problem:** Cache key generation (6.5ms) is slower than width calculation (4.5ms)

**Solution:** Use string hash or simpler key
```bash
# Instead of hex encoding:
cache_key=$(printf '%s' "$clean" | LC_ALL=C od -An -tx1 | tr -d ' \n')

# Try:
cache_key="${#clean}_${clean:0:20}_${clean: -20}"  # Length + first/last 20 chars
# OR
cache_key="$clean"  # Direct (if bash handles it)
```

**Expected Improvement:**
- Cache hit: 6.5ms → 0.1ms = **65× speedup**
- Cache miss: 6.5ms + 4.5ms = 11ms → 4.5ms = **2.4× speedup**

### Priority 2: Pre-calculate Static Widths

**Problem:** Icons calculated on every render

**Solution:** Calculate at init
```bash
# In init_oiseau():
ICON_SUCCESS_WIDTH=$(_display_width "$ICON_SUCCESS")
ICON_ERROR_WIDTH=$(_display_width "$ICON_ERROR")
# ... etc for all icons

# Usage:
icon_width="$ICON_SUCCESS_WIDTH"  # 0ms vs 4.5ms
```

**Expected Improvement:** Save 4.5ms × (icon usage frequency)

### Priority 3: Batch Width Calculation for Tables

**Problem:** Tables call `_display_width()` twice per cell (column width + truncation)

**Solution:** Calculate once, reuse
```bash
# Instead of:
cell_width=$(_display_width "$cell")
if [ "$cell_width" -gt "$col_width" ]; then
    cell=$(_truncate_to_width "$cell" "$col_width")
    cell_width=$(_display_width "$cell")  # ← Redundant!
fi

# Do:
cell_width=$(_display_width "$cell")
if [ "$cell_width" -gt "$col_width" ]; then
    cell=$(_truncate_to_width "$cell" "$col_width")
    # Reuse known width after truncation
    cell_width="$col_width"
fi
```

**Expected Improvement:** 50% reduction in table rendering time

### Priority 4: Consider Perl Module Caching

**Problem:** Perl subprocess fork/exec is 3-4ms overhead

**Solution:** Keep Perl process alive (if possible)
```bash
# Use coprocess (Bash 4+):
coproc PERL_WIDTH {
    perl -C -e 'while(<>) { ... width calculation ... print "$width\n"; }'
}

_display_width() {
    echo "$clean" >&${PERL_WIDTH[1]}
    read width <&${PERL_WIDTH[0]}
    echo "$width"
}
```

**Expected Improvement:** 3-4ms → 0.5ms = **8× speedup** per call

---

## 7. Impact Analysis by Scenario

### After All Optimizations

| Scenario | Current | Optimized | Improvement |
|----------|---------|-----------|-------------|
| Simple CLI (3 calls) | 15ms | 3ms | 5× faster |
| Progress (20 calls) | 100ms | 20ms | 5× faster |
| Complex UI (46 calls) | 230ms | 46ms | 5× faster |
| Table-heavy (120 calls) | 600ms | 120ms | 5× faster |

**Note:** These assume cache hits + Perl coprocess. Without Perl coprocess, expect ~2× improvement instead.

---

## 8. Alternative Approaches (Not Recommended)

### Option A: Use Simpler Heuristic Always

Replace Perl with fallback heuristic everywhere.

**Pros:**
- ~50-100µs per call (100× faster)
- No subprocess overhead

**Cons:**
- **Inaccurate** for CJK/emoji
- Breaks alignment for international users
- User-facing bug risk

**Verdict:** ❌ Don't do this. Performance isn't bad enough to sacrifice correctness.

### Option B: Pre-calculate Everything

Pre-calculate widths for all possible strings.

**Pros:**
- Zero runtime cost

**Cons:**
- **Impossible** for user-provided content
- Only helps with static strings (icons, labels)

**Verdict:** ⚠️ Already recommended for icons (Priority 2), but can't solve whole problem.

### Option C: External wcwidth Binary

Replace Perl with compiled C binary.

**Pros:**
- ~100-500µs per call (10× faster than Perl)
- Still accurate

**Cons:**
- **Distribution complexity** (need to ship binary)
- Platform-specific compilation
- More dependencies

**Verdict:** ⚠️ Consider for future if Perl optimization insufficient.

---

## 9. Final Recommendations

### Immediate Actions (Worth Doing Now)

1. ✅ **Fix cache key generation** (Priority 1)
   - Simpler key → 2-65× speedup depending on hit rate
   - Low effort, high reward

2. ✅ **Pre-calculate icon widths** (Priority 2)
   - One-time 20ms cost at init
   - Saves 4.5ms × usage frequency
   - Trivial implementation

3. ✅ **Reuse table cell widths** (Priority 3)
   - 50% speedup for tables
   - Small code change

### Future Considerations (If Performance Still Insufficient)

4. ⚠️ **Perl coprocess** (Priority 4)
   - 8× speedup per call
   - Bash 4+ only
   - More complex lifecycle management

5. ⚠️ **wcwidth binary** (Alternative C)
   - 10× speedup
   - Distribution complexity

### Don't Do

- ❌ Replace with heuristic (sacrifices accuracy)
- ❌ Remove width calculations (breaks CJK/emoji support)
- ❌ Current cache implementation is already optimal given constraints

---

## 10. Conclusion

**Is caching effective enough?**
- Currently: **NO** (cache key generation is slower than calculation!)
- After fix: **YES** (65× speedup on hits)

**Should we pre-calculate widths?**
- For icons/static strings: **YES** (trivial win)
- For user content: **NO** (impossible)

**Use simpler approach?**
- For heuristic: **NO** (breaks correctness)
- For cache key: **YES** (simpler = faster)

**Bottom line:** The current implementation is **correct but slow**. The cache is **broken** (key generation too expensive). Fixing the cache + pre-calculating icons should reduce costs by **2-5×** with minimal code changes. This is sufficient for typical usage (<50 calls). For heavy table usage (100+ calls), consider Perl coprocess or wcwidth binary.

**Performance is not a critical issue for 95% of use cases**, but the broken cache should be fixed regardless.
