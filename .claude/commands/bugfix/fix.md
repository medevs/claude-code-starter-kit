---
description: Implement fix from RCA document
argument-hint: <github-issue-id-or-bug-name>
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
---

# Fix: Implement from RCA — $ARGUMENTS

## Prerequisites

RCA document must exist at `.plans/rca-$ARGUMENTS.md`

If it doesn't exist, run `/rca $ARGUMENTS` first.

## Process

### 1. Read RCA Document

Read the entire RCA at `.plans/rca-$ARGUMENTS.md`:
- Understand the root cause
- Review the proposed fix strategy
- Note all files to modify
- Review testing requirements

### 2. Verify the Bug

Before fixing, confirm:
- The affected code matches what the RCA describes
- No recent changes have already addressed the issue
- The proposed fix is still the best approach

### 3. Implement the Fix

For each file listed in "Files to Modify":

**a.** Read the existing file and locate the affected code
**b.** Implement the change as described in the RCA
**c.** Maintain existing code style and conventions
**d.** Add a comment only if the fix is non-obvious

### 4. Add Tests

Create tests as specified in "Testing Requirements":

1. **Fix verification test** — Reproduces the bug scenario and confirms it's resolved
2. **Edge case tests** — Tests related boundary conditions
3. **Regression test** — Ensures existing functionality is preserved

Test naming: `test_issue_<id>_<description>` or `it("should <fix> when <condition>")`

### 5. Run Validation

Execute the validation workflow:

.claude/commands/validate.md

When the `Agent` tool is available, optionally delegate validation to the `validator` agent for comprehensive test/lint/build verification in an isolated context.

Fix any failures before proceeding.

### 6. Verify Fix

- Follow the reproduction steps from the RCA
- Confirm the bug no longer occurs
- Check for unintended side effects

## Output Report

```markdown
### Fix Implemented: $ARGUMENTS

**Root Cause**: [one-line summary from RCA]

### Changes Made
- `path/to/file` (lines X-Y) — [what changed]
- ...

### Tests Added
- `path/to/test` — [test descriptions]

### Validation Results
- Lint: ✅
- Type Check: ✅
- Tests: ✅ X/X passing
- Build: ✅

### Verification
- ✅ Reproduction steps — bug resolved
- ✅ Edge cases — passing
- ✅ No regressions

### Ready for Commit
Suggested message:
fix(<scope>): <description>

<details of what was fixed and how>

Fixes #$ARGUMENTS
```
