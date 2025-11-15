# Multi-Agent Decision Framework - Quick Reference

## Invocation Methods

### Method 1: Slash Command (Fastest)
```
/madf [problem description]
```

### Method 2: Explicit Skill Reference
```
Please use the multi-agent-framework skill to solve: [problem]
```

### Method 3: Natural Language
```
I need help with [problem]. I want multiple perspectives on the best approach.
```

## Complexity Tier Quick Guide

| Tier | Time | Agents | Example |
|------|------|--------|---------|
| 1 | < 30min | 1 | Fix typo, update comment |
| 2 | 30min-2hr | 2-3 | Add parameter, localized refactor |
| 3 | 2-8hr | 4-5 | New widget, architecture change |
| 4 | > 8hr | 6 | Multi-phase features, major redesign |

## Agent Specializations

| Agent | Focus | Use When |
|-------|-------|----------|
| Performance | Speed, efficiency | Loops, rendering, high-frequency calls |
| Maintainability | Code clarity | Complex logic, team collaboration |
| Robustness | Error handling | User input, edge cases, failures |
| Usability | API design | New features, developer-facing code |
| Security | Input sanitization | User input, shell execution, file ops |
| Compatibility | Cross-platform | Bash versions, OS differences, terminals |

## Expected Output Structure

```
1. PROBLEM CLASSIFICATION
   - Tier: [1-4]
   - Agents: [List]
   - Reasoning: [Why]

2. AGENT SOLUTIONS
   [Each agent's approach with pros/cons/code]

3. COMPARISON MATRIX
   [Side-by-side tradeoffs]

4. SYNTHESIS
   - Recommended approach
   - What we took from each agent
   - Implementation plan
   - Risks & mitigations

5. NEXT STEPS
   [Concrete actions]
```

## Common Patterns

### Pattern 1: New Feature
```
Tier: 3
Agents: Performance, Maintainability, Robustness, Usability, Compatibility
Focus: Balanced implementation with all concerns
```

### Pattern 2: Performance Issue
```
Tier: 2-3
Agents: Performance, Maintainability
Focus: Optimize without sacrificing readability
```

### Pattern 3: Bug Fix
```
Tier: 2
Agents: Robustness, Maintainability
Focus: Fix root cause cleanly
```

### Pattern 4: Architecture Decision
```
Tier: 4
Agents: All 6
Focus: Comprehensive analysis of long-term impact
```

### Pattern 5: API Design
```
Tier: 2-3
Agents: Usability, Maintainability, Compatibility
Focus: Developer experience and consistency
```

## Decision Tree: Which Agents?

```
New widget or feature?
  → Performance, Maintainability, Robustness, Usability, Compatibility

Performance problem?
  → Performance, Maintainability

Bug or edge case?
  → Robustness, Maintainability

API or interface change?
  → Usability, Maintainability, Compatibility

User input handling?
  → Security, Robustness, Usability

Cross-platform issue?
  → Compatibility, Robustness

Major architecture change?
  → ALL 6 agents
```

## Workflow Checklist

- [ ] Classify problem tier (1-4)
- [ ] Identify required agent specializations
- [ ] Spawn agents in parallel
- [ ] Review each agent's solution
- [ ] Study comparison matrix
- [ ] Understand synthesis recommendations
- [ ] Create implementation plan
- [ ] Identify risks and mitigations
- [ ] Implement synthesized solution
- [ ] Test across platforms
- [ ] Document decision rationale

## Troubleshooting

### Issue: Agents agree too much
**Fix**: Bump to higher tier, add more specializations

### Issue: Too much output (overwhelming)
**Fix**: Start with 2-3 agents, add more if needed

### Issue: Synthesis unclear
**Fix**: Ask "Which parts came from which agents?"

### Issue: Wrong tier classification
**Fix**: Reclassify and re-run with different agent count

### Issue: Missing important perspective
**Fix**: Add specific agent: "Please include Security Agent"

## Best Practices

1. **Be Specific**: Provide context, constraints, examples
2. **Trust Process**: Don't skip agent outputs
3. **Read Tradeoffs**: Learn from comparison matrix
4. **Question Synthesis**: Ask why if unclear
5. **Iterate**: Refine based on feedback
6. **Document**: Save decision rationale for future reference

## Time Estimates

| Tier | Classification | Agent Execution | Synthesis | Total |
|------|----------------|-----------------|-----------|-------|
| 1 | 1 min | 2 min | 1 min | ~5 min |
| 2 | 2 min | 5 min | 3 min | ~10 min |
| 3 | 3 min | 8 min | 5 min | ~15 min |
| 4 | 5 min | 12 min | 8 min | ~25 min |

Framework overhead is usually 10-20% of implementation time, but saves 50%+ in revisions and rework.

## Success Indicators

You know MADF worked well when:

- Multiple distinct approaches were generated
- Clear tradeoffs emerged in comparison
- Synthesis combined best aspects
- Implementation plan is concrete and actionable
- Risks are identified with mitigations
- You understand WHY the approach is best

## Anti-Patterns

Avoid these mistakes:

- Classifying everything as Tier 1 (missing valuable perspectives)
- Skipping agent outputs to jump to synthesis
- Ignoring comparison matrix
- Not questioning synthesis when it seems off
- Using MADF for trivial changes (overhead not worth it)
- Treating synthesis as gospel (it's a recommendation)

## Examples by Category

### New Widgets
- Progress bar: Tier 3, 5 agents
- Tree view: Tier 3, 5 agents
- Table: Tier 3, 5 agents
- Chart/graph: Tier 4, 6 agents

### Bug Fixes
- Rendering glitch: Tier 2, 2 agents
- Crash on edge case: Tier 2, 2 agents
- Performance regression: Tier 3, 4 agents

### Architecture
- Split library into modules: Tier 4, 6 agents
- Add plugin system: Tier 4, 6 agents
- Change state management: Tier 4, 6 agents

### API Changes
- Add parameter to function: Tier 2, 2 agents
- Rename function: Tier 2, 2 agents
- Change function signature: Tier 3, 4 agents
- Redesign entire API: Tier 4, 6 agents

---

Keep this guide handy for quick MADF reference during development.
