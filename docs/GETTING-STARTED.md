# Getting Started

## Prerequisites

- **Claude Code** v1.0+ installed and authenticated
- **Git** 2.20+
- **Node.js** 18+ or **Python** 3.10+ (for your project's runtime)
- A **bash-compatible terminal** (Git Bash on Windows, Terminal on macOS/Linux)

## Installation

### Step 1: Clone the Starter Kit

```bash
git clone https://github.com/medevs/claude-code-starter-kit.git my-project
cd my-project
```

**Expected**: A `my-project/` directory with `.claude/`, `docs/`, `templates/`, and `CLAUDE.md`.

**If this fails**: Check your git installation (`git --version`) and network connection.

### Step 2: Remove Starter Kit Git History

```bash
rm -rf .git
git init
```

**Expected**: A fresh git repository with no commit history.

### Step 3: Open Claude Code

```bash
claude
```

**Expected**: Claude Code starts in the project directory and detects the `.claude/` configuration.

**If this fails**: Ensure Claude Code is installed (`claude --version`) and you're in the project root.

### Step 4: Run Setup

```
/setup
```

This is the most important step. `/setup` will:
1. **Detect your tech stack** from config files (package.json, pyproject.toml, etc.) or ask you
2. **Ask your architecture preference** (Vertical Slice, Clean Architecture, or Simple)
3. **Detect your package manager** and tools from lock files and configs
4. **Offer MCP integrations** (Playwright, Supabase, GitHub, PostgreSQL, Memory, Fetch, Filesystem)
5. **Populate CLAUDE.md** with your project's tech stack, dev commands, and directory structure
6. **Copy matching templates** — framework-specific rules and skills from `templates/` into `.claude/`
7. **Configure MCP servers** if you selected any
8. **Verify** by running `/prime` to confirm everything loaded

**Expected**: A summary showing your configuration, active rules, available skills, and all 16 commands.

**If this fails**: See [Troubleshooting — /setup not detecting framework](./TROUBLESHOOTING.md#setup-not-detecting-framework).

### Step 5: Start Building

```
/build add user authentication
```

Or create a PRD first for a new project:
```
/create-prd my-app-name
```

---

## Your First Feature

Walk through the full workflow with `/build`:

```
/build add a hello world API endpoint
```

**What happens**:

1. **Prime** — Claude analyzes your project structure, tech stack, and conventions
2. **Plan** — Creates a plan at `.plans/add-a-hello-world-api-endpoint.md` with tasks, patterns, and validation commands
3. **Execute** — Implements the endpoint, following your project's patterns, and creates tests
4. **Validate** — Runs lint, type check, tests, and build
5. **Commit** — Creates an atomic commit: `feat(api): add hello world endpoint`

**Expected output**:
```
Build Complete: add a hello world API endpoint
✅ Prime — Codebase context loaded
✅ Plan — .plans/add-a-hello-world-api-endpoint.md (Confidence: 9/10)
✅ Execute — 2 files created, 1 modified
✅ Validate — All checks passing
✅ Commit — feat(api): add hello world endpoint
```

---

## Your First Bug Fix

The bugfix workflow uses two commands:

```
/rca "the /users endpoint returns 500 when email contains a plus sign"
```

**What happens**: Claude investigates the codebase, traces the code path, forms hypotheses, and produces an RCA document at `.plans/rca-users-endpoint-500.md`.

```
/fix users-endpoint-500
```

**What happens**: Claude reads the RCA, implements the fix, adds regression tests, runs validation, and suggests a commit message.

```
/commit
```

**What happens**: Claude creates an atomic commit: `fix(users): handle plus sign in email validation`.

---

## Understanding the Layers

The starter kit has five layers that work together:

| Layer | Location | When Active | What It Does |
|-------|----------|-------------|--------------|
| **Rules** | `.claude/rules/` | Always loaded | Standards: code quality, testing, security, architecture |
| **Commands** | `.claude/commands/` | User-invoked (`/command`) | Workflows: plan, build, validate, commit |
| **Skills** | `.claude/skills/` | Auto-detected | Expertise: context management, debugging, planning |
| **Subagents** | `.claude/agents/` | Delegated by commands | Workers: researcher, planner, reviewer, validator, investigator |
| **Hooks** | `.claude/hooks/` | Pre/post tool use + stop | Safety: block dangerous commands (active by default); branch protection, auto-format, auto-lint, completion notifications (opt-in) |

For the full architecture explanation, see [Architecture Guide](./ARCHITECTURE-GUIDE.md).

---

## What Next?

- **[Commands Reference](./COMMANDS-REFERENCE.md)** — All 16 commands with INPUT/PROCESS/OUTPUT, allowed tools, and examples
- **[Architecture Guide](./ARCHITECTURE-GUIDE.md)** — The 5-layer stack, subagents, VSA, context engineering, migration guide
- **[Customization](./CUSTOMIZATION.md)** — Add your own rules, commands, skills, subagents, hooks, and MCP servers
- **[Troubleshooting](./TROUBLESHOOTING.md)** — Common issues, permissions, platform-specific fixes
- **[FAQ](./FAQ.md)** — Answers to frequently asked questions
- **[Migration Guide](./MIGRATION.md)** — Integrate the starter kit into an existing project

---

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Commands not appearing | Check file exists in `.claude/commands/` with valid `description` frontmatter. Restart Claude Code. |
| Hook blocking a safe command | Check `.claude/hooks/block-dangerous-commands.sh` patterns. Add to `permissions.allow` in settings.json. |
| MCP server not connecting | Verify `.mcp.json` at project root. Check env vars. Restart Claude Code. |
| `/setup` not detecting stack | Ensure config files (package.json, etc.) are in project root. Use manual selection. |

For more details, see [Troubleshooting](./TROUBLESHOOTING.md).
