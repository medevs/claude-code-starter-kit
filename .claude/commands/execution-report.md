---
description: Generate post-implementation reflection report
allowed-tools: Read, Write, Glob, Grep, Bash(git:*)
---

# Execution Report

## Objective

Generate a post-implementation reflection comparing the plan against what was actually built. This captures lessons learned and flags divergences.

## Process

### 1. Gather Context

Collect recent implementation activity:

```bash
git log -5 --oneline
git diff --stat HEAD~1
```

- Read the implementation plan from `.plans/` (identify from recent commits or ask user)
- Read any validation results from the current session

### 2. Compare Plan vs Actual

For each task in the plan:
- Was it completed as specified?
- Were there deviations? If so, classify as **Justified** (better approach found) or **Problematic** (regression risk)
- Were any tasks skipped?

### 3. Generate Report

Write the report to: `.plans/reports/{feature}-report.md`

```markdown
# Execution Report: {feature-name}

## Meta Information
- **Plan**: `.plans/{plan-file}.md`
- **Date**: {date}
- **Commits**: {list of commit hashes}
- **Files added**: [list with paths]
- **Files modified**: [list with paths]
- **Lines changed**: +X / -Y

## Validation Results
| Check       | Status | Details              |
|-------------|--------|----------------------|
| Lint        | ✅/❌  | [output summary]     |
| Type Check  | ✅/❌  | [output summary]     |
| Tests       | ✅/❌  | [X passed, Y failed] |
| Build       | ✅/❌  | [output summary]     |

## What Went Well
- [Positive outcomes and smooth implementation areas]

## Challenges
- [Difficulties encountered and how they were resolved]

## Divergences from Plan

For each divergence:

**[Divergence Title]**
- **Planned**: [what the plan specified]
- **Actual**: [what was implemented instead]
- **Reason**: [why this divergence occurred]
- **Type**: Better approach found | Plan assumption wrong | Security concern | Performance issue | Missing context
- **Classification**: Justified / Problematic

## Skipped Items
- [Any planned tasks that were not implemented, with reasons]

## Recommendations

### Plan Command Improvements
- [What the plan should have included or clarified]

### Execute Command Improvements
- [Execution workflow changes needed]

### CLAUDE.md Additions
- [New rules, patterns, or anti-patterns to document]

### New Commands or Skills Needed
- [Manual processes that could be automated]
```

### 4. Summary

After writing the report, provide:
- Path to the report file
- Count of divergences (justified vs problematic)
- Top recommendation
