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

### 5.5. Capture AI Context Changes

Check if any AI-layer files are in the staged diff:
- `.claude/rules/` — conventions added, updated, or removed
- `.claude/commands/` — slash commands created or modified
- `.claude/skills/` — skill definitions or reference docs
- `.claude/agents/` — agent definitions
- `CLAUDE.md` — global rules changes

If any are present, append a `Context:` footer to the commit body listing what changed:

```
feat(auth): add session token rotation

Added automatic token rotation on refresh. Tokens now expire
after 15 minutes instead of 24 hours.

Context:
- Updated .claude/rules/security.md with token rotation conventions
- Added .claude/commands/audit-sessions.md for session inspection
```

**Why this matters:** Your git log is long-term memory. Future agents and sessions use `git log` to understand project history. If context changes aren't captured in commits, the AI layer's evolution becomes invisible.

### 6. Confirm

```bash
git log -1 --oneline
git status
```

Report the commit hash and summary.

## Next Steps

- **Ready to push?** → `git push`
- **Want reflection?** → `/execution-report`
- **Starting new feature?** → `/prime` then `/plan`
- **Ending session?** → `/handoff`
