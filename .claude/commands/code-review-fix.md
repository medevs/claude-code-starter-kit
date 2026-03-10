---
description: Fix issues found in a code review
argument-hint: <review-file-path> [scope]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Code Review Fix

## Input

- **Review file**: $ARGUMENTS (first argument — path to the review file, e.g. `.plans/reviews/2025-01-15-auth.md`)
- **Scope filter** (optional): second argument — filter by severity: `critical`, `warning`, `security`, or `all` (default: `all`)

## Process

### 1. Read the Review

Read the review file and parse all findings by severity:
- 🔴 Critical (must fix)
- 🟡 Warning (should fix)
- 🔵 Suggestion (nice to have)

If a scope filter is provided, only address issues matching that severity.

### 2. Fix Issues (Highest Severity First)

For each issue, in order of severity (critical → warning → suggestion):

**a.** Read the affected file and locate the code referenced in the review
**b.** Understand the issue and the suggested fix
**c.** Apply the fix, maintaining existing code style and conventions
**d.** Report: "Fixed: [file:line] — [brief description]"

If a fix requires broader changes than described in the review, note this and apply the minimal correct fix.

### 3. Validate

Run the validation workflow to confirm fixes don't introduce regressions:

.claude/commands/validate.md

### 4. Output Report

```markdown
### Code Review Fixes Applied

**Review file**: [path]
**Scope**: [all/critical/warning/security]

### Fixes Applied
- ✅ **[file:line]**: [issue] — [what was changed]
- ✅ **[file:line]**: [issue] — [what was changed]

### Skipped
- ⏭️ **[file:line]**: [reason for skipping, e.g. "suggestion-level, out of scope"]

### Validation Results
- Lint: ✅/❌
- Type Check: ✅/❌
- Tests: ✅/❌
- Build: ✅/❌

### Ready for Commit
Run `/commit` to commit the fixes.
```
