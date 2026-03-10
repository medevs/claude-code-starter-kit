---
description: Create an atomic git commit with conventional commit message
allowed-tools: Read, Grep, Bash(git:*)
---

# Commit: Atomic Git Commit

## Process

### 1. Review Changes

```bash
git status
git diff HEAD
git status --porcelain
```

### 2. Safety Checks

**Before committing, verify:**
- No secrets, API keys, or credentials in the diff (`.env`, tokens, passwords)
- No large binary files or build artifacts
- Changes are logically related (one concern per commit)

**If the diff is large (20+ files or 500+ lines):**
- Suggest splitting into multiple atomic commits
- Group by logical change (e.g., feature code, tests, config)

### 3. Stage Changes

Add untracked and modified files relevant to the current change:
```bash
git add <specific-files>
```

Prefer staging specific files over `git add -A`.

### 4. Generate Commit Message

Analyze the staged diff to determine:
- **Type**: feat, fix, refactor, test, docs, chore, perf, ci, style
- **Scope**: affected module or component (optional)
- **Description**: concise imperative summary

Format:
```
<type>(<scope>): <description>

[optional body with details]

[optional footer: Fixes #123]
```

### 5. Commit

```bash
git commit -m "<generated message>"
```

### 6. Confirm

```bash
git log -1 --oneline
git status
```

Report the commit hash and summary.
