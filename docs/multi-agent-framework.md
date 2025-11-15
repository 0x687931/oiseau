# Multi-Agent Decision Framework

## Overview

The Multi-Agent Decision Framework (MADF) is a reusable pattern for solving complex problems in the Oiseau project by coordinating multiple specialized agents working in parallel.

## Why Use This Framework?

Traditional single-agent problem solving can miss important perspectives:
- Performance optimizations may sacrifice maintainability
- Robust error handling may complicate the API
- Security measures may impact usability

The MADF ensures all perspectives are considered and synthesized into the best solution.

## How It Works

### 1. Problem Classification

Problems are classified into 4 tiers based on complexity:

**Tier 1: Trivial** (< 30 min)
- Single agent sufficient
- Examples: Fix typo, update comment, simple refactor

**Tier 2: Moderate** (30 min - 2 hours)
- 2-3 specialized agents
- Examples: Add parameter to widget, localized refactor

**Tier 3: Complex** (2-8 hours)
- 4-5 specialized agents
- Examples: New widget, architecture change, performance optimization

**Tier 4: Very Complex** (> 8 hours)
- All 6 specialized agents
- Examples: Multi-phase features, breaking changes, major redesigns

### 2. Agent Specializations

Six specialized agents provide different perspectives:

1. **Performance Agent**: Speed, efficiency, resource usage
2. **Maintainability Agent**: Code clarity, documentation, patterns
3. **Robustness Agent**: Error handling, edge cases, validation
4. **Usability Agent**: Developer experience, API design
5. **Security Agent**: Input sanitization, injection prevention
6. **Compatibility Agent**: Cross-platform, bash version compatibility

### 3. Parallel Execution

Agents work simultaneously on the same problem, each from their unique perspective. This parallelism:
- Saves time (no sequential blocking)
- Generates diverse solutions
- Reveals tradeoffs between approaches

### 4. Synthesis

The coordinator combines the best aspects from all agents into a unified solution that:
- Takes performance optimizations from Performance Agent
- Incorporates error handling from Robustness Agent
- Uses API design from Usability Agent
- Applies security measures from Security Agent
- Ensures compatibility from Compatibility Agent
- Maintains code quality from Maintainability Agent

## Usage

### Slash Command (Quick Access)

```bash
/madf Implement a progress bar widget with percentage display
```

### Skill Invocation (Explicit)

In Claude Code, reference the skill:
```
I need help with [problem]. Please use the multi-agent-framework skill.
```

### Direct Description

Simply describe your problem with context:
```
I need to implement a tree view widget. It should support:
- Nested items with indentation
- Expand/collapse functionality
- Icons for folders and files
- Keyboard navigation

This is complex and I want multiple perspectives on the best approach.
```

The framework will automatically classify and deploy appropriate agents.

## Example Workflows

### Example 1: New Feature (Tier 3)

**Problem**: Implement a progress bar widget

**Classification**: Tier 3 (new widget, 2-8 hours)

**Agents Deployed**:
- Performance: Efficient redrawing, minimize terminal updates
- Maintainability: Clean API, consistent with existing widgets
- Robustness: Handle edge cases (0%, 100%, terminal resize)
- Usability: Simple API with sensible defaults
- Compatibility: Bash 3.2+, macOS/Linux

**Output**:
- 5 different implementation approaches
- Comparison matrix showing tradeoffs
- Synthesized solution combining best aspects
- Implementation plan with concrete steps

### Example 2: Bug Fix (Tier 2)

**Problem**: Table widget renders incorrectly on narrow terminals (< 20 cols)

**Classification**: Tier 2 (specific bug, multiple approaches possible)

**Agents Deployed**:
- Robustness: Edge case handling
- Maintainability: Clean, understandable fix

**Output**:
- 2 approaches to handling narrow terminals
- Tradeoffs between approaches
- Recommended solution
- Test cases to prevent regression

### Example 3: Architecture Decision (Tier 4)

**Problem**: Should we split oiseau.sh into multiple files?

**Classification**: Tier 4 (major architectural change)

**Agents Deployed**: All 6 (Performance, Maintainability, Robustness, Usability, Security, Compatibility)

**Output**:
- 6 perspectives on single-file vs multi-file
- Performance impact analysis
- Maintainability improvements/costs
- Robustness considerations (module loading)
- Usability impact (sourcing complexity)
- Security implications (attack surface)
- Compatibility challenges (bash sourcing across platforms)
- Final recommendation with detailed reasoning

## Best Practices

### When to Use MADF

Use this framework when:
- Problem is Tier 2+ (not trivial)
- Multiple valid approaches exist
- Tradeoffs need to be evaluated
- You want comprehensive solution
- Decision has long-term impact

### When NOT to Use MADF

Skip the framework for:
- Trivial changes (typos, comments)
- Obvious single solution
- Time-critical quick fixes
- Well-established patterns (just follow existing code)

### Getting the Most Value

1. **Be specific**: Provide context, constraints, requirements
2. **Trust the process**: Don't skip agent perspectives
3. **Read comparisons**: The tradeoffs are valuable learning
4. **Question synthesis**: If something seems off, ask why
5. **Iterate**: Use feedback to refine classification

## Integration with Oiseau Workflow

### Standard Workflow

```bash
# 1. Create worktree for feature
bin/worktree-new progress-bar-widget

# 2. Move to worktree
cd ../oiseau-progress-bar-widget

# 3. Invoke MADF
/madf Implement progress bar widget

# 4. Review agent outputs and synthesis

# 5. Implement recommended solution

# 6. Test and commit

# 7. Create PR
../oiseau/bin/worktree-pr

# 8. After merge, cleanup
cd /Users/am/Documents/GitHub/oiseau
bin/worktree-complete progress-bar-widget
```

### Emergency Fixes

For P0/P1 critical issues, you can still use MADF but with tighter scope:

```bash
# Quick classification and 2-3 agents only
/madf Fix critical rendering bug in table widget causing crashes
```

## Configuration

### Settings

The framework can be customized in `.claude/settings.json`:

```json
{
  "skills": {
    "multi-agent-framework": {
      "defaultTier": "auto",
      "agentTimeout": 120,
      "parallelExecution": true
    }
  }
}
```

### Agent Customization

To add Oiseau-specific agents, edit `.claude/skills/multi-agent-framework.md` and add new specializations:

```markdown
**Testing Agent**
- Focus: Test coverage, edge case testing
- Concerns: Unit tests, integration tests, example scripts
- Questions: Are all code paths tested? Edge cases covered?
```

## Success Metrics

A successful MADF session produces:

1. Clear tier classification with reasoning
2. Diverse agent perspectives (not all agreeing)
3. Concrete code examples from each agent
4. Comparison matrix showing tradeoffs
5. Synthesized solution better than any single agent
6. Actionable implementation plan
7. Risk identification and mitigation

## Troubleshooting

### Agents Agree Too Much

**Problem**: All agents produce similar solutions
**Solution**: You may have under-classified the tier. Consider bumping to next tier.

### Synthesis is Unclear

**Problem**: Recommended approach doesn't clearly combine agent insights
**Solution**: Ask the coordinator to explain which parts came from which agents.

### Wrong Agents Deployed

**Problem**: Classification chose wrong specializations
**Solution**: Explicitly request specific agents: "Please include Security Agent"

### Too Many Agents (Overwhelming)

**Problem**: Tier 4 with 6 agents produces too much output
**Solution**: Request phased analysis: "Start with Performance and Maintainability first"

## Future Enhancements

Planned improvements to the framework:

1. **Agent Learning**: Agents remember past decisions and improve over time
2. **Custom Agents**: Project-specific agents (e.g., "Oiseau Patterns Agent")
3. **Hybrid Modes**: Mix parallel and sequential agent execution
4. **Confidence Scoring**: Weight synthesis based on agent confidence
5. **Decision History**: Track which agent perspectives were most valuable

## References

- Agent Skill Documentation: `.claude/skills/multi-agent-framework.md`
- Slash Command: `.claude/commands/madf.md`
- Example Sessions: `docs/examples/madf-sessions/`

---

For questions or feedback on the Multi-Agent Decision Framework, see the main Oiseau documentation or open a GitHub issue.
