# Git Workflow

## Commit Messages

Use conventional commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`, `style`

- `feat`: New user-facing functionality
- `fix`: Bug fix
- `refactor`: Code restructuring without behavior change

## Commit Practices

- Atomic commits: one logical change per commit
- Write in imperative mood: "add feature" not "added feature"
- First line under 72 characters
- Reference issue numbers in footer: `Fixes #123` or `Closes #456`
- Never commit secrets, credentials, or .env files

## AI Context Change Tracking

When commits modify AI context files alongside code, add a `Context:` section to the commit body listing what changed.

**What counts as AI context files:**
- `.claude/rules/` — conventions and standards
- `.claude/commands/` — slash commands
- `.claude/skills/` — skill definitions and references
- `.claude/agents/` — agent definitions
- `CLAUDE.md` — global project rules

**Format example:**
```
feat(api): add rate limiting middleware

Added per-endpoint rate limits with Redis backing store.

Context:
- Added .claude/rules/api/rate-limiting.md with configuration conventions
- Updated CLAUDE.md with rate limit dev commands
```

**Why:** This makes the AI layer's evolution visible in `git log`. Future agents can trace when and why a rule was added, a command was changed, or a convention was introduced.

## Branch Naming

- Features: `feat/short-description` or `feat/issue-123-description`
- Fixes: `fix/short-description` or `fix/issue-123-description`
- Chores: `chore/short-description`

## Safety Rules

- Never force push to main/master
- Always create new commits — never amend unless explicitly asked
- Never use `git reset --hard` without explicit confirmation
- Never skip pre-commit hooks with `--no-verify`

## Pull Requests

- Title follows conventional commit format
- Description includes: Summary, Changes made, Test plan
- Keep PRs focused — one feature or fix per PR
- Link related issues in the description
