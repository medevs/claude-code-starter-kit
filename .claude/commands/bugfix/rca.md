---
description: Root cause analysis for a bug (GitHub issue, error log, or description)
argument-hint: <github-issue-id-or-bug-description>
allowed-tools: Read, Write, Glob, Grep, Bash(git:*), Bash(gh:*), Agent
---

# Root Cause Analysis: $ARGUMENTS

## Objective

Investigate the reported bug, identify the root cause, and document findings for implementation.

## Investigation Process

### 1. Gather Bug Details

**If GitHub issue ID provided:**
```bash
gh issue view $ARGUMENTS
```

**If error description provided:**
- Parse the error message, stack trace, or behavior description
- Identify affected components and user-facing symptoms

### 2. Search Codebase

- Search for components, functions, and error messages mentioned in the bug
- Find related code paths and recent changes
- Check for similar patterns elsewhere that may share the vulnerability

```bash
git log --oneline -20 -- [relevant-paths]
```

### 3. Review Recent History

Check recent changes to affected areas:
```bash
git log --oneline -20 -- [relevant-paths]
git log --diff-filter=M --oneline -10 -- [relevant-paths]
```

Look for:
- Recent modifications to affected code
- Related bug fixes that may have introduced the issue
- Refactorings near the affected area

### 4. Identify Root Cause

Analyze the code to determine:
- What is the actual bug?
- Why is it happening? (logic error, edge case, missing validation, race condition?)
- What was the original intent of the code?
- Are there related issues or symptoms?

### 5. Assess Impact

- How widespread is the issue?
- What features are affected?
- Are there data corruption or security implications?
- Severity: Critical / High / Medium / Low

### 6. Design Fix

- What needs to change and in which files?
- What tests should verify the fix?
- Are there risks or side effects?
- What's the simplest correct solution?

## Sub-Agent Delegation

When the `Agent` tool is available, delegate investigation to specialized agents:

1. **Codebase search** → Launch the `researcher` agent to search for affected components, error messages, related code paths, and recent changes in parallel.
2. **Hypothesis-driven debugging** → Launch the `investigator` agent with the bug details and let it perform systematic hypothesis testing, code path tracing, and root cause identification.

Use the agents' findings to populate the RCA document below. The investigation process above remains the orchestration frame when agents are unavailable.

## Output: RCA Document

Save to: `.plans/rca-$ARGUMENTS.md`

```markdown
# Root Cause Analysis: $ARGUMENTS

## Bug Summary
- **Source**: [GitHub Issue #X / Error log / User report]
- **Title**: [brief title]
- **Severity**: [Critical/High/Medium/Low]
- **Affected Components**: [list]

## Problem Description
[Clear description of the bug]

**Expected Behavior**: [what should happen]
**Actual Behavior**: [what actually happens]

## Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Observe the bug]

**Reproduction Verified**: Yes / No

## Root Cause

### Affected Code
- `path/to/file` (lines X-Y) — [description of the issue]

### Analysis
[Detailed explanation of why the bug occurs]

### Code Location
```
[file:line — relevant code snippet]
```

## Proposed Fix

### Strategy
[High-level approach to fixing]

### Files to Modify
1. `path/to/file` — [what changes and why]
2. `path/to/file` — [what changes and why]

### Alternative Approaches
[Other solutions considered and why the proposed approach is preferred]

### Testing Requirements
1. Test that verifies the fix works
2. Test for edge cases related to the bug
3. Regression test for existing functionality

### Risks
- [Any risks or side effects of the fix]

## Next Steps
Run `/fix $ARGUMENTS` to implement the fix.
```
