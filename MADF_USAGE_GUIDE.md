# Multi-Agent Decision Framework - Complete Usage Guide

## Overview

The Multi-Agent Decision Framework (MADF) is now configured as a reusable **Agent Skill** in your Oiseau repository. This guide explains everything you need to know to use it effectively.

## What You Now Have

### 1. Agent Skill
**Location**: `/Users/am/Documents/GitHub/oiseau/.claude/skills/multi-agent-framework.md` (after PR merge)

This is the core coordinator that:
- Classifies problems into tiers (1-4)
- Spawns specialized agents in parallel
- Compares solutions
- Synthesizes best approach

### 2. Slash Command
**Location**: `/Users/am/Documents/GitHub/oiseau/.claude/commands/madf.md` (after PR merge)

Quick invocation shortcut: `/madf [problem]`

### 3. Documentation
**Locations**:
- `docs/multi-agent-framework.md` - Complete framework guide
- `docs/examples/madf-sessions/quick-reference.md` - Quick reference
- `docs/examples/madf-sessions/example-progress-bar.md` - Example session

## How to Invoke the Framework

### Method 1: Slash Command (Recommended)

Simply type the slash command followed by your problem:

```
/madf Implement a progress bar widget for Oiseau
```

```
/madf Should we split oiseau.sh into multiple files?
```

```
/madf Fix rendering bug in table widget when terminal width < 20
```

### Method 2: Direct Skill Reference

Reference the skill explicitly in your message:

```
I need to implement a tree view widget. Please use the multi-agent-framework skill to analyze this.
```

### Method 3: Natural Language (Auto-detection)

For complex problems, just describe what you need:

```
I need help implementing a complex data table widget with sorting, filtering, and pagination. I want multiple perspectives on the best approach.
```

Claude Code will recognize the need for multiple perspectives and may suggest using MADF.

## When to Use MADF

### USE IT FOR:

**Tier 2: Moderate (2-3 agents, 30min-2hr)**
- Adding new parameters to existing widgets
- Non-critical bug fixes with multiple approaches
- Localized refactoring
- API design for new functions

**Tier 3: Complex (4-5 agents, 2-8hr)**
- **New widget implementation** (progress bars, tables, trees)
- Architecture changes affecting multiple components
- Performance optimizations
- Complex bug fixes with edge cases

**Tier 4: Very Complex (6 agents, > 8hr)**
- Multi-phase feature rollouts
- Breaking API changes
- Major architecture redesigns (like splitting oiseau.sh)
- Plugin system design

### DON'T USE IT FOR:

**Tier 1: Trivial (single agent, < 30min)**
- Fixing typos
- Updating comments
- Simple documentation changes
- Obvious one-line fixes

The framework overhead (10-25 minutes) isn't worth it for trivial changes.

## What You Get Back

The framework provides **5-phase structured output**:

### Phase 1: Problem Classification
```
TIER: 3 (Complex)
AGENTS DEPLOYED: Performance, Maintainability, Robustness, Usability, Compatibility
REASONING: New widget with multiple technical challenges
```

### Phase 2: Agent Solutions
Each agent provides:
- **APPROACH**: High-level strategy
- **PROS**: Advantages of this approach
- **CONS**: Disadvantages/tradeoffs
- **CODE**: Implementation or detailed pseudocode
- **CONFIDENCE**: Star rating (1-5)

### Phase 3: Comparison Matrix
```
| Criterion        | Performance | Maintain | Robust | Usability | Compat |
|------------------|-------------|----------|--------|-----------|--------|
| Performance      | ★★★★★       | ★★★☆☆    | ★★☆☆☆  | ★★★★☆     | ★★★★☆  |
| Maintainability  | ★★★☆☆       | ★★★★★    | ★★☆☆☆  | ★★★★☆     | ★★★☆☆  |
| ...
```

### Phase 4: Synthesis & Recommendation
```
RECOMMENDED APPROACH:
- Core Strategy: [From which agent]
- Performance Optimizations: [From Performance Agent]
- Error Handling: [From Robustness Agent]
- API Design: [From Usability Agent]
- Security Measures: [From Security Agent]
- Compatibility Fixes: [From Compatibility Agent]
- Code Quality: [From Maintainability Agent]
```

### Phase 5: Implementation Plan
```
1. Add function to oiseau.sh after widget section
2. Add function header documentation
3. Create example: examples/widget_demo.sh
4. Add tests: tests/test_widget.sh
5. Update README.md

RISKS AND MITIGATIONS:
- Risk: X → Mitigation: Y
```

## Agent Specializations Explained

### Performance Agent
**When it matters**: Loops, rendering, high-frequency calls, large datasets

**What it optimizes**:
- Runtime complexity (O(n) vs O(n^2))
- Memory usage
- Rendering speed (minimize terminal writes)
- Caching strategies

**Example**: For a progress bar updated 10,000 times, Performance Agent will suggest caching and differential updates.

### Maintainability Agent
**When it matters**: Complex logic, team collaboration, long-term maintenance

**What it optimizes**:
- Code clarity and readability
- Documentation quality
- Consistency with existing patterns
- Future modification ease

**Example**: For any widget, Maintainability Agent ensures clear variable names, good documentation, and follows Oiseau conventions.

### Robustness Agent
**When it matters**: User input, edge cases, error conditions

**What it optimizes**:
- Input validation
- Error handling
- Edge case coverage
- Graceful degradation

**Example**: For a table widget, Robustness Agent handles terminal width < 20, empty data, invalid inputs.

### Usability Agent
**When it matters**: New features, developer-facing code, API design

**What it optimizes**:
- API simplicity
- Sensible defaults
- Clear error messages
- Developer experience

**Example**: For a prompt function, Usability Agent suggests auto-detection (password prompts auto-mask input).

### Security Agent
**When it matters**: User input handling, shell execution, file operations

**What it optimizes**:
- Input sanitization
- Command injection prevention
- Path traversal protection
- Safe defaults

**Example**: For text input, Security Agent ensures all input goes through `_escape_input()` to prevent ANSI injection.

### Compatibility Agent
**When it matters**: Always (Oiseau targets bash 3.2+, macOS + Linux)

**What it optimizes**:
- Bash 3.2+ compatibility (macOS default)
- Cross-platform portability
- Terminal emulator variations
- Fallback for limited environments

**Example**: Compatibility Agent prevents using bash 4+ features like `${var,,}` and suggests portable alternatives.

## Example Workflows

### Example 1: New Widget (Tier 3)

**Problem**: You need to implement a spinner (loading indicator) widget.

**Invocation**:
```
/madf Implement a spinner widget for showing loading states
```

**What happens**:
1. Framework classifies as Tier 3 (new widget = complex)
2. Spawns 5 agents: Performance, Maintainability, Robustness, Usability, Compatibility
3. Each agent provides their approach:
   - **Performance**: Use minimal frames, efficient rendering
   - **Maintainability**: Clear state management, well-documented
   - **Robustness**: Handle terminal resize, SIGINT cleanup
   - **Usability**: Simple start/stop API
   - **Compatibility**: ASCII fallback for plain mode
4. Comparison matrix shows tradeoffs
5. Synthesis combines best aspects
6. Implementation plan with steps

**Time**: 15 minutes for analysis, saves 2-4 hours in revisions

### Example 2: Bug Fix (Tier 2)

**Problem**: Progress bar flickers when updating rapidly

**Invocation**:
```
/madf Fix flickering in progress bar during rapid updates
```

**What happens**:
1. Framework classifies as Tier 2 (performance bug)
2. Spawns 2 agents: Performance, Maintainability
3. Performance Agent suggests buffering and differential updates
4. Maintainability Agent ensures fix is clean and understandable
5. Synthesis provides clean solution

**Time**: 10 minutes for analysis

### Example 3: Architecture Decision (Tier 4)

**Problem**: Should oiseau.sh be split into multiple files?

**Invocation**:
```
/madf Should we split oiseau.sh into multiple files or keep it as a single file?
```

**What happens**:
1. Framework classifies as Tier 4 (major architecture decision)
2. Spawns all 6 agents
3. Each provides perspective:
   - **Performance**: Load time, sourcing overhead
   - **Maintainability**: Organization, navigability
   - **Robustness**: Module loading, dependencies
   - **Usability**: Developer experience, import complexity
   - **Security**: Attack surface, isolation
   - **Compatibility**: Sourcing across platforms
4. Detailed comparison matrix
5. Synthesis with clear recommendation and reasoning

**Time**: 25 minutes for analysis, prevents weeks of wrong direction

## Integration with Oiseau Workflow

### Standard Feature Development

```bash
# 1. Create worktree
cd /Users/am/Documents/GitHub/oiseau
bin/worktree-new spinner-widget

# 2. Move to worktree
cd ../oiseau-spinner-widget

# 3. Invoke MADF (in Claude Code session)
/madf Implement a spinner widget with multiple animation styles

# 4. Review all agent outputs
# 5. Study comparison matrix
# 6. Read synthesis carefully

# 7. Implement recommended solution
# Edit files, add tests, create examples

# 8. Commit
git add -A
git commit -m "Implement spinner widget with multiple animation styles"

# 9. Push and create PR
git push -u origin feature/spinner-widget
gh pr create --title "Add spinner widget" --body "..."

# 10. After merge, cleanup
cd /Users/am/Documents/GitHub/oiseau
bin/worktree-cleanup spinner-widget
```

### Quick Bug Fixes

For non-critical bugs that still benefit from multiple perspectives:

```bash
# 1. Create worktree
bin/worktree-new fix-table-rendering

# 2. Invoke MADF for analysis
/madf Fix table widget rendering issue on narrow terminals

# 3. Implement recommended fix
# 4. Test across terminal sizes
# 5. Commit and PR
```

## Pro Tips

### 1. Be Specific in Your Problem Description

**Bad**:
```
/madf Fix bug
```

**Good**:
```
/madf Fix rendering bug in table widget when terminal width is less than 20 columns. Currently it crashes with division by zero.
```

### 2. Include Context and Constraints

**Better**:
```
/madf Implement a tree view widget that supports:
- Nested items with indentation
- Expand/collapse functionality
- Icons for folders and files
- Must work in bash 3.2+
- Should handle up to 1000 items efficiently
```

### 3. Trust the Process

Don't skip agent outputs to jump to synthesis. The different perspectives are valuable learning, even if you think you know the answer.

### 4. Question the Synthesis

If something in the recommended approach seems off, ask:
```
Why did you choose Performance Agent's caching strategy over Maintainability Agent's simpler approach?
```

### 5. Use for Learning

Even if you already have a solution in mind, running it through MADF can:
- Reveal edge cases you missed
- Suggest performance optimizations
- Identify security issues
- Ensure compatibility

### 6. Save Decision Rationale

The MADF output is valuable documentation. Save it for:
- Future reference when maintaining the code
- Explaining decisions to collaborators
- Understanding why certain tradeoffs were made

## Troubleshooting

### Issue: Agents all agree too much

**Diagnosis**: Problem may be under-classified (wrong tier)

**Solution**: Bump to next tier or explicitly request more agents:
```
/madf [problem] - please include Security Agent as well
```

### Issue: Too much output (overwhelming)

**Diagnosis**: May have over-classified (Tier 4 when Tier 2 would work)

**Solution**: Start with fewer agents:
```
/madf [problem] - start with just Performance and Maintainability agents
```

### Issue: Synthesis unclear or contradictory

**Diagnosis**: Agents may have found genuine tradeoffs with no clear winner

**Solution**: Ask for clarification:
```
The synthesis recommends Performance Agent's approach but also warns about Maintainability concerns. Can you explain which to prioritize and why?
```

### Issue: Framework suggests wrong tier

**Diagnosis**: Problem description may be ambiguous

**Solution**: Override classification:
```
This is a Tier 3 problem (not Tier 2). Please deploy 5 agents: Performance, Maintainability, Robustness, Usability, Compatibility
```

## Advanced Usage

### Custom Agent Selection

You can request specific agents for unusual problems:

```
/madf [problem] - I specifically need Performance, Security, and Compatibility perspectives
```

### Phased Analysis

For very complex problems, analyze in phases:

```
/madf Phase 1: Should we implement this feature at all? (Use all 6 agents)

[After reviewing output]

/madf Phase 2: Given we're implementing it, what's the best API design? (Use Usability, Maintainability, Compatibility)

[After reviewing output]

/madf Phase 3: Optimize the implementation (Use Performance, Robustness)
```

### Comparison of Existing Solutions

Use MADF to evaluate multiple existing approaches:

```
/madf We have two pull requests for the same feature. PR #1 uses approach A, PR #2 uses approach B. Please analyze both from all perspectives and recommend which to merge.
```

## Real-World Success Stories

### Success 1: Phases 6-10 Implementation
- **Problem**: Implement 5 phases of UI library (Tier 4)
- **Agents**: All 6 deployed in parallel
- **Outcome**: Completed in 1 day instead of estimated 1 week
- **Key Insight**: Performance Agent caught O(n^2) issues early

### Success 2: PR#21 Critical Fixes
- **Problem**: Multiple P1 issues needing fixes (Tier 3)
- **Agents**: 5 agents for systematic analysis
- **Outcome**: All issues resolved with no regressions
- **Key Insight**: Robustness Agent found related edge cases

### Success 3: API Design for `ask_input`
- **Problem**: Design text input with validation (Tier 3)
- **Agents**: Usability, Security, Maintainability, Compatibility, Robustness
- **Outcome**: Auto-detection of password prompts (brilliant UX)
- **Key Insight**: Usability + Security collaboration

## Next Steps

1. **Read the full framework guide**: `docs/multi-agent-framework.md`
2. **Review the quick reference**: `docs/examples/madf-sessions/quick-reference.md`
3. **Study the example session**: `docs/examples/madf-sessions/example-progress-bar.md`
4. **Try it on a real problem**: Use `/madf` for your next feature
5. **Share feedback**: Update documentation with lessons learned

## Summary

The Multi-Agent Decision Framework is now available as:

- **Agent Skill**: Auto-invoked by Claude Code when using the skill
- **Slash Command**: `/madf [problem]` for quick access
- **Natural Language**: Just describe complex problems

**Why it's an Agent Skill (not slash command or MCP)**:
1. **Complex multi-step workflow** - Coordination across multiple agents
2. **Spawns subagents** - Uses Task tool to create specialized agents
3. **Reusable pattern** - Works for any problem type
4. **Project-scoped** - Lives in `.claude/` for this repo
5. **Persistent** - Always available in this repository

**Remember**: The framework overhead (10-25 minutes) is always worth it for Tier 2+ problems. It prevents hours of rework and reveals hidden tradeoffs.

---

Questions? Check `docs/multi-agent-framework.md` or open a GitHub issue.
