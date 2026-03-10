---
description: Code review — analyze staged changes or specified files for quality, security, and correctness
argument-hint: [file-paths-or-blank-for-staged]
allowed-tools: Read, Write, Glob, Grep, Bash(git:*), Agent
---

# Review: Code Review

## Target

Review: `$ARGUMENTS`

If no arguments provided, review all staged changes (`git diff --cached`). If no staged changes, review unstaged changes (`git diff`).

## Process

### 1. Gather Changes

```bash
# If arguments provided, read those files
# Otherwise, review git diff
git diff --cached --stat
git diff --cached
```

If no staged changes:
```bash
git diff --stat
git diff
```

### 2. Analyze Each Change

For each modified file, evaluate:

#### Correctness
- Does the logic work for all inputs, including edge cases?
- Are there off-by-one errors, null/undefined risks, or race conditions?
- Are error paths handled correctly?
- Do types match expectations?

#### Security
- Any hardcoded secrets, tokens, or credentials?
- Is user input validated and sanitized?
- Are database queries parameterized?
- Any XSS, injection, or CSRF vulnerabilities?
- Are permissions checked appropriately?

#### Performance
- Any N+1 queries or unnecessary database calls?
- Are there memory leaks (unclosed connections, event listeners)?
- Expensive operations in hot paths?
- Missing pagination for list endpoints?

#### Test Coverage
- Are there tests for the new/changed behavior?
- Do tests cover edge cases and error paths?
- Are mocks appropriate and not excessive?

#### Style & Conventions
- Does the code follow project conventions from CLAUDE.md and rules?
- Are names intention-revealing?
- Is the code readable without excessive comments?
- Any code duplication that should be extracted?

### 3. Report Findings

Save the review to: `.plans/reviews/{date}-{scope}.md`

Group issues by severity:

```markdown
## Review: [files/changes reviewed]

### 🔴 Critical (must fix before merge)
- **[file:line]**: [issue description]
  - **Fix**: [specific suggestion]

### 🟡 Warning (should fix)
- **[file:line]**: [issue description]
  - **Fix**: [specific suggestion]

### 🔵 Suggestion (nice to have)
- **[file:line]**: [issue description]
  - **Fix**: [specific suggestion]

### ✅ Looks Good
- [Positive observations about the code]

### Summary
- **Files reviewed**: X
- **Critical issues**: X
- **Warnings**: X
- **Suggestions**: X
- **Verdict**: ✅ Approve / 🟡 Approve with comments / 🔴 Request changes
```

### Sub-Agent Delegation

When the `Agent` tool is available, delegate the multi-dimensional analysis (Step 2) to the `code-reviewer` agent. Launch it with the diff or file contents and let it perform correctness, security, performance, test coverage, and style analysis in parallel. Use the agent's findings to populate the review report.

### 4. Offer Fixes

For critical and warning issues, suggest running `/code-review-fix .plans/reviews/{file}.md` to apply fixes.
