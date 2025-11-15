# MADF Session Example: Progress Bar Widget

This is an example of how the Multi-Agent Decision Framework analyzes and solves a Tier 3 problem.

## Problem Statement

**User Request**: "Implement a progress bar widget for the Oiseau library"

**Initial Context**:
- Need to show progress from 0-100%
- Should work in various terminal widths
- Must be consistent with existing Oiseau widgets
- Performance matters (may be updated frequently in loops)

## Phase 1: Classification

```
TIER: 3 (Complex)

REASONING:
- New widget implementation (not modification)
- Multiple technical challenges (rendering, performance, API design)
- Expected time: 2-4 hours
- Affects core library architecture

RECOMMENDED AGENTS:
1. Performance Agent (frequent updates = performance critical)
2. Maintainability Agent (API design, consistency)
3. Robustness Agent (edge cases, terminal sizes)
4. Usability Agent (simple API for developers)
5. Compatibility Agent (bash 3.2+, cross-platform)

PARALLEL EXECUTION: Yes (all 5 agents simultaneously)
```

## Phase 2: Agent Solutions

### Performance Agent

**APPROACH**: Minimize terminal writes using differential updates

**PROS**:
- O(1) updates (only redraw changed portions)
- Minimal ANSI escape sequences
- Cache formatting strings
- Single printf call per update

**CONS**:
- More complex code
- Harder to understand state management

**CODE**:
```bash
oiseau_progress_bar() {
    local percent="$1"
    local width="${2:-40}"

    # Cache previous state to avoid unnecessary redraws
    local cache_key="${width}_${percent}"
    [[ "${_OISEAU_PROGRESS_CACHE}" == "${cache_key}" ]] && return
    _OISEAU_PROGRESS_CACHE="${cache_key}"

    # Single calculation and printf
    local filled=$((width * percent / 100))
    printf '\r[%*s%*s] %3d%%' \
        "${filled}" '' "$((width - filled))" '' "${percent}" |
        tr ' ' '█' | tr '' ' '
}
```

**CONFIDENCE**: ★★★★★

### Maintainability Agent

**APPROACH**: Clear, self-documenting code with standard patterns

**PROS**:
- Follows existing Oiseau conventions
- Well-documented
- Easy to extend (colors, labels)
- Clear variable names

**CONS**:
- May sacrifice some performance for clarity
- More verbose

**CODE**:
```bash
oiseau_progress_bar() {
    # Draw a progress bar from 0-100%
    # Args:
    #   $1 - percent (0-100)
    #   $2 - width (optional, default 40)
    #   $3 - filled_char (optional, default ▓)
    #   $4 - empty_char (optional, default ░)

    local percent="${1:-0}"
    local bar_width="${2:-40}"
    local filled_char="${3:-▓}"
    local empty_char="${4:-░}"

    # Calculate filled and empty portions
    local filled_count=$((bar_width * percent / 100))
    local empty_count=$((bar_width - filled_count))

    # Build the bar components
    local filled_portion
    local empty_portion
    filled_portion=$(printf "%${filled_count}s" | tr ' ' "${filled_char}")
    empty_portion=$(printf "%${empty_count}s" | tr ' ' "${empty_char}")

    # Print the complete bar
    printf '\r[%s%s] %3d%%' "${filled_portion}" "${empty_portion}" "${percent}"
}
```

**CONFIDENCE**: ★★★★☆

### Robustness Agent

**APPROACH**: Extensive validation and graceful degradation

**PROS**:
- Handles all edge cases (invalid inputs, narrow terminals)
- Never crashes or produces garbled output
- Graceful fallbacks for limitations

**CONS**:
- More code complexity
- Slower due to validation overhead

**CODE**:
```bash
oiseau_progress_bar() {
    local percent="${1:-0}"
    local width="${2:-40}"

    # Validate percent (0-100)
    if [[ ! "${percent}" =~ ^[0-9]+$ ]]; then
        printf '\r[ERROR] Invalid percent: %s\n' "${percent}" >&2
        return 1
    fi
    [[ "${percent}" -lt 0 ]] && percent=0
    [[ "${percent}" -gt 100 ]] && percent=100

    # Validate width (minimum 10, maximum terminal width)
    local term_width
    term_width=$(tput cols 2>/dev/null || echo 80)
    [[ "${width}" -lt 10 ]] && width=10
    [[ "${width}" -gt $((term_width - 10)) ]] && width=$((term_width - 10))

    # Handle narrow terminals (< 20 cols)
    if [[ "${term_width}" -lt 20 ]]; then
        # Fallback to compact format
        printf '\r%3d%%' "${percent}"
        return 0
    fi

    # Calculate with overflow protection
    local filled=$((width * percent / 100))
    [[ "${filled}" -gt "${width}" ]] && filled="${width}"

    # Build and print bar
    local bar
    bar=$(printf "%${filled}s%$((width - filled))s" | tr ' ' '█' | sed "s/█/$'\u2591'/g; 1,$((filled))s/./$'\u2593'/g")
    printf '\r[%s] %3d%%' "${bar}" "${percent}"
}
```

**CONFIDENCE**: ★★★★★

### Usability Agent

**APPROACH**: Simplest possible API with smart defaults

**PROS**:
- One-line usage: `oiseau_progress_bar 75`
- Sensible defaults
- Optional customization available
- Clear, helpful error messages

**CONS**:
- Less control for advanced users
- May not fit all use cases

**CODE**:
```bash
oiseau_progress_bar() {
    # Simple usage: oiseau_progress_bar 75
    # Custom width: oiseau_progress_bar 75 50
    # With options: oiseau_progress_bar 75 --color green --label "Loading"

    local percent="${1:-0}"
    local width=40
    local color=""
    local label=""

    # Parse optional arguments
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --color) color="$2"; shift 2 ;;
            --label) label="$2"; shift 2 ;;
            [0-9]*) width="$1"; shift ;;
            *) shift ;;
        esac
    done

    # Auto-scale to terminal width if too large
    local max_width=$(($(tput cols) - 10))
    [[ "${width}" -gt "${max_width}" ]] && width="${max_width}"

    # Build bar
    local filled=$((width * percent / 100))
    local bar
    bar=$(printf "%${width}s" | sed "s/ /━/g" | sed "s/^.{0,$filled}/$(printf "%${filled}s" | sed 's/ /▓/g')/")

    # Apply color if specified
    [[ -n "${color}" ]] && bar="\033[32m${bar}\033[0m"

    # Print with optional label
    printf '\r%s[%s] %3d%%' "${label:+${label}: }" "${bar}" "${percent}"
}
```

**CONFIDENCE**: ★★★★☆

### Compatibility Agent

**APPROACH**: Maximum compatibility (bash 3.2+, all terminals)

**PROS**:
- Works on macOS default bash (3.2)
- No bashisms that break on old versions
- Handles terminals without UTF-8
- Fallback characters for all terminals

**CONS**:
- Cannot use modern bash features
- Less elegant code
- May look basic on modern terminals

**CODE**:
```bash
oiseau_progress_bar() {
    # Compatible with bash 3.2+ (macOS default)
    local percent="$1"
    local width="${2:-40}"

    # Validate input (bash 3.2 compatible)
    case "${percent}" in
        ''|*[!0-9]*) percent=0 ;;
    esac
    [ "${percent}" -lt 0 ] && percent=0
    [ "${percent}" -gt 100 ] && percent=100

    # Calculate filled portion
    local filled=$(( width * percent / 100 ))

    # Build bar with ASCII fallback
    # Use = for filled, - for empty (works on all terminals)
    local i bar=""
    for (( i=0; i<width; i++ )); do
        if [ "${i}" -lt "${filled}" ]; then
            bar="${bar}="
        else
            bar="${bar}-"
        fi
    done

    # Print (using printf for compatibility)
    printf '\r[%s] %3d%%' "${bar}" "${percent}"
}
```

**CONFIDENCE**: ★★★★★

## Phase 3: Comparison Matrix

| Criterion       | Performance | Maintain | Robust | Usability | Compat |
|-----------------|-------------|----------|--------|-----------|--------|
| Performance     | ★★★★★       | ★★★☆☆    | ★★☆☆☆  | ★★★★☆     | ★★★★☆  |
| Maintainability | ★★★☆☆       | ★★★★★    | ★★☆☆☆  | ★★★★☆     | ★★★☆☆  |
| Robustness      | ★★★☆☆       | ★★★☆☆    | ★★★★★  | ★★★☆☆     | ★★★★☆  |
| Usability       | ★★☆☆☆       | ★★★★☆    | ★★★☆☆  | ★★★★★     | ★★☆☆☆  |
| Security        | ★★★★☆       | ★★★★☆    | ★★★★★  | ★★★★☆     | ★★★★☆  |
| Compatibility   | ★★★★☆       | ★★★★☆    | ★★★★☆  | ★★★☆☆     | ★★★★★  |

### Key Insights

1. **Performance Agent** wins on speed but sacrifices clarity
2. **Maintainability Agent** has the clearest code but may be slower
3. **Robustness Agent** handles all cases but is most complex
4. **Usability Agent** has best API but more overhead in parsing
5. **Compatibility Agent** works everywhere but limits features

### Tradeoff Analysis

- Performance vs Maintainability: Classic tension
- Robustness vs Simplicity: More validation = more code
- Usability vs Control: Simple API may limit power users
- Compatibility vs Features: Old bash = fewer options

## Phase 4: Synthesis

**RECOMMENDED APPROACH**: Hybrid combining best aspects

### Core Strategy
Start with **Maintainability Agent's** clear structure, add **Performance Agent's** caching, incorporate **Robustness Agent's** validation, use **Usability Agent's** API design, ensure **Compatibility Agent's** bash 3.2 support.

### Synthesized Implementation

```bash
oiseau_progress_bar() {
    # Progress bar widget (0-100%)
    # Usage: oiseau_progress_bar PERCENT [WIDTH]
    # Args:
    #   PERCENT - Progress percentage (0-100)
    #   WIDTH   - Bar width in chars (optional, default 40)

    local percent="${1:-0}"
    local bar_width="${2:-40}"

    # Validate percent (Robustness Agent)
    case "${percent}" in
        ''|*[!0-9]*) percent=0 ;;
    esac
    [ "${percent}" -lt 0 ] && percent=0
    [ "${percent}" -gt 100 ] && percent=100

    # Validate and constrain width (Robustness Agent)
    local term_width
    term_width=$(tput cols 2>/dev/null || echo 80)
    [ "${bar_width}" -lt 10 ] && bar_width=10
    [ "${bar_width}" -gt $((term_width - 10)) ] && bar_width=$((term_width - 10))

    # Cache check for performance (Performance Agent)
    local cache_key="${bar_width}_${percent}"
    [ "${_OISEAU_PROGRESS_CACHE:-}" = "${cache_key}" ] && return 0
    _OISEAU_PROGRESS_CACHE="${cache_key}"

    # Calculate filled portion (Maintainability Agent - clear logic)
    local filled=$((bar_width * percent / 100))
    local empty=$((bar_width - filled))

    # Build bar with compatibility (Compatibility Agent - bash 3.2)
    local filled_str empty_str
    filled_str=$(printf "%${filled}s" | tr ' ' '=')
    empty_str=$(printf "%${empty}s" | tr ' ' '-')

    # Single printf for efficiency (Performance Agent)
    printf '\r[%s%s] %3d%%' "${filled_str}" "${empty_str}" "${percent}"
}
```

### Implementation Plan

1. Add function to `oiseau.sh` after other widget functions
2. Add function header documentation
3. Create example: `examples/progress_bar_demo.sh`
4. Add tests: `tests/test_progress_bar.sh`
5. Update README.md with progress bar documentation
6. Test on macOS and Linux
7. Test on narrow terminals (< 20 cols)
8. Performance test (10000 updates)

### Risks & Mitigations

**Risk**: Cache might cause stale renders if called from different contexts
**Mitigation**: Include context ID in cache key if needed

**Risk**: UTF-8 characters (= and -) may not render on all terminals
**Mitigation**: Already using ASCII-safe characters

**Risk**: Frequent updates may flicker
**Mitigation**: Using `\r` (carriage return) without newline

**Risk**: Width calculation fails if `tput` unavailable
**Mitigation**: Fallback to 80 cols already included

## Phase 5: Implementation Notes

### What We Took From Each Agent

1. **Performance Agent**: Caching mechanism, single printf call
2. **Maintainability Agent**: Clear structure, good documentation, variable names
3. **Robustness Agent**: Input validation, width constraints, terminal checks
4. **Usability Agent**: Simple two-parameter API
5. **Compatibility Agent**: Bash 3.2 syntax, ASCII characters, portable commands

### What We Left Out

1. **Performance Agent**: Differential updates (too complex for benefit)
2. **Maintainability Agent**: Four parameters (too many for simple widget)
3. **Robustness Agent**: Narrow terminal fallback (keep simple for now)
4. **Usability Agent**: Flag parsing (--color, --label - add later if needed)
5. **Compatibility Agent**: Loop-based bar building (less efficient)

## Lessons Learned

1. **Multiple perspectives reveal hidden tradeoffs**: Performance caching vs maintainable simplicity
2. **Synthesis is better than any single approach**: Combined solution has 4.5★ average vs 4★ max
3. **Tier 3 was correct**: 5 agents provided valuable diversity without overwhelming
4. **Security wasn't needed**: No user input injection risks in this widget
5. **Real-world testing matters**: Need to validate on actual terminals before finalizing

## Follow-up Questions

After this session, consider:

1. Should we add color support? (Invoke Usability + Compatibility agents)
2. What about labels/titles? (Usability agent)
3. Horizontal vs vertical progress bars? (New feature = new MADF session)
4. Animation support (spinner while loading)? (Performance concerns)

---

This example demonstrates the full MADF workflow from classification through synthesis.
