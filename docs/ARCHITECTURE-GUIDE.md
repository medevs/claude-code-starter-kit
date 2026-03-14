# Architecture Guide

## The 5-Layer Stack

The starter kit is built on five layers, each with a distinct role. They activate at different times and compose to create a complete development workflow.

```
┌─────────────────────────────────────────────┐
│  Rules (always loaded)                      │  Standards & constraints
├─────────────────────────────────────────────┤
│  Commands (user-invoked)                    │  Workflows & actions
├─────────────────────────────────────────────┤
│  Skills (auto-detected)                     │  On-demand expertise
├─────────────────────────────────────────────┤
│  Subagents (delegated)                      │  Parallel workers
├─────────────────────────────────────────────┤
│  Hooks (safety net)                         │  Guardrails & automation
└─────────────────────────────────────────────┘
```

**Rules** are always loaded into every conversation. They define the standards Claude must follow — code quality, testing, security, architecture, git workflow, and AI workflow patterns. Path-targeted rules activate only when editing files in matching directories.

**Commands** are user-invoked slash commands that define structured workflows. Each command specifies its allowed tools, restricting what Claude can do during execution. Commands range from read-only exploration (`/prime`) to full implementation pipelines (`/build`).

**Skills** are auto-detected when Claude encounters a relevant scenario. They provide methodology and deep knowledge — context management strategies, debugging techniques, planning templates, refactoring patterns, and delegation guidance. Skills use progressive depth: a concise overview (SKILL.md) with detailed references loaded only when needed.

**Subagents** are specialized workers that Claude delegates to for parallel or focused tasks. Each agent has a specific model, tool restrictions, and turn limit. Agents handle research, planning, code review, validation, and investigation without polluting the main conversation context.

**Hooks** are shell scripts that run automatically before tool use, after tool use, or when Claude stops. They provide safety (blocking dangerous commands, branch protection), automation (auto-formatting, auto-linting), and quality-of-life features (desktop notifications on completion). Hooks are configured in `.claude/settings.json`.

### Data Flow Between Layers

```
User → Command → (reads Rules) → delegates to Subagents → (Skills activate on-demand)
                                                        ↓
                                            Hooks intercept tool calls
                                            (PreToolUse: block/allow, branch protection)
                                            (PostToolUse: auto-format, auto-lint)
                                            (Stop: completion notification)
```

---

## Subagents Layer

Five specialized agents handle delegated tasks. No agent has unrestricted Write + Edit + Bash access together — this is a deliberate security constraint.

| Agent | Model | Tools | maxTurns | Purpose |
|-------|-------|-------|----------|---------|
| **researcher** | haiku | Read, Glob, Grep, Bash(git, ls) | 15 | Fast codebase explorer — pattern discovery, architecture analysis, dependency mapping |
| **planner** | sonnet | Read, Write, Glob, Grep, Bash(git, ls) | 20 | Solution designer — analyzes code, produces plans in `.plans/` |
| **code-reviewer** | sonnet | Read, Write, Glob, Grep, Bash(git, ls) | 25 | Quality reviewer — 6-dimension analysis, produces reports in `.plans/reviews/` |
| **validator** | sonnet | Read, Glob, Grep, Bash(test/lint/build tools) | 12 | Validation runner — detects tools, runs checks, distills results |
| **investigator** | sonnet | Read, Glob, Grep, Bash(git, ls) | 20 | Debugger — hypothesis-driven RCA, traces code paths, uses git blame |

### Model Selection Rationale

- **Haiku** for the researcher: read-only exploration is I/O-bound, not reasoning-bound. Haiku is fast and cheap — ideal for launching 2-5 parallel instances to answer independent questions.
- **Sonnet** for planner, code-reviewer, validator, investigator: these agents need reasoning to decompose problems, evaluate quality, group failures, and form hypotheses.

### Security Design

- **researcher**: Read-only. Cannot create, edit, or delete anything.
- **planner**: Can only Write to `.plans/` — cannot modify source code.
- **code-reviewer**: Can only Write to `.plans/reviews/` — cannot modify source code.
- **validator**: Can run test/lint/build commands but cannot edit files.
- **investigator**: Read-only with git history access. Cannot modify anything.

---

## Why Vertical Slice Architecture?

Traditional layered architecture (controllers → services → repositories) creates **horizontal coupling** — changing a feature requires touching files across many directories. This makes AI-assisted development slower because more context is needed.

**Vertical Slice Architecture (VSA)** organizes by feature:

```
features/
  auth/
    route.ts          # API endpoint
    service.ts        # Business logic
    repository.ts     # Data access
    schema.ts         # Types & validation
    auth.test.ts      # Tests
  products/
    route.ts
    service.ts
    repository.ts
    schema.ts
    products.test.ts
shared/
  database.ts         # Shared DB connection
  auth-middleware.ts   # Shared auth logic
  logger.ts           # Shared logging
```

### Benefits for AI-Assisted Development

1. **Minimal context needed** — An AI agent can understand and modify one feature by reading one directory
2. **Independent features** — Changes to `auth/` don't require understanding `products/`
3. **Self-contained plans** — A plan for a feature lists files in one place
4. **Easy testing** — Each feature has co-located tests
5. **Natural decomposition** — Features map to user stories and tasks

### Rules

- Features depend on `shared/`, never on each other
- Only extract to `shared/` when used by 3+ features
- Each feature is independently testable and deployable
- Entry points (`app.ts`, `main.py`) are thin composites of features

---

## Context Engineering Principles

### Why Context Matters

Claude Code operates within a context window. Every file read, every tool output, every conversation message consumes tokens. Efficient context use = faster, more accurate results.

### Principles

1. **Just-In-Time Reading** — Read files when needed, not "just in case"
2. **Targeted Search** — Use grep/glob before reading entire files
3. **Sub-Agent Delegation** — Offload research to sub-agents to keep main context clean
4. **Plan Before Edit** — Know all files you'll touch before opening any
5. **Progressive Depth** — Skim → Scan → Read → Deep Dive (only go deeper when needed)

### Progressive Depth in Practice

The kit implements progressive depth at multiple levels:

- **CLAUDE.md** stays under 200 lines using `@imports` for rule files
- **Rules** are modular — path-targeted rules only load when relevant
- **Skills** use two layers: SKILL.md (overview, <160 lines) loaded on activation, `references/` (200-400 lines) loaded only when deep knowledge is needed
- **Plans** are self-contained documents — all context in one file so the execution agent doesn't need to search
- **Commands** are focused — each does one thing well with restricted tools

### How This Kit Optimizes Context

- **CLAUDE.md under 200 lines** — Uses @imports to keep the root file small
- **Modular rules** — Only relevant rules loaded (path-targeted for `api/`, `frontend/`)
- **Skills as reference** — Loaded on demand, not always present
- **Plans as documents** — All context for implementation in one file
- **Commands are focused** — Each command does one thing well
- **Subagent delegation** — Research runs in separate context, only findings return

---

## Project Structure for AI

### Recommended Structure

```
your-project/
├── CLAUDE.md              # Project rules (populated by /setup)
├── .claude/               # Claude Code configuration
│   ├── settings.json      # Permissions, hooks
│   ├── agents/            # Subagents for delegation
│   ├── rules/             # Auto-loaded rules
│   ├── commands/          # Slash commands
│   ├── skills/            # Auto-detected skills
│   ├── hooks/             # Safety & automation scripts
│   └── mcp-templates/     # Optional MCP configs
├── .plans/                # Plans, PRDs, RCA docs
│   ├── reports/           # Execution reports
│   └── reviews/           # Code review reports
├── src/ or app/           # Source code (VSA structure)
│   ├── features/          # Feature slices
│   └── shared/            # Shared utilities
├── tests/                 # Test files (or co-located)
├── docs/                  # Documentation
└── templates/             # Framework templates (from starter kit)
    ├── rules/             # Framework-specific rules
    └── skills/            # Framework-specific skills
```

### Key Decisions

| Decision | Recommendation | Reason |
|----------|---------------|--------|
| Architecture | Vertical Slice | Minimal context per feature |
| File size | Under 300 lines | Fits in context window |
| Function size | Under 50 lines | Easy to understand |
| Test location | Co-located or mirrored | Easy to find |
| Types | Central definitions | Single source of truth |
| Config | Environment variables | No secrets in code |
| Plans | `.plans/` directory | Persistent, referenceable |

---

## Migration Guide

### "I have an existing project"

Follow these steps to add the starter kit to an existing codebase:

1. **Copy the `.claude/` directory** into your project root
   ```bash
   cp -r claude-code-starter-kit/.claude/ your-project/.claude/
   ```

2. **Copy the `templates/` directory** (optional, for future `/setup` runs)
   ```bash
   cp -r claude-code-starter-kit/templates/ your-project/templates/
   ```

3. **Copy or create `CLAUDE.md`** at your project root
   ```bash
   cp claude-code-starter-kit/CLAUDE.md your-project/CLAUDE.md
   ```

4. **Open Claude Code in your project and run `/setup`**
   - It will detect your existing tech stack from config files
   - It will populate CLAUDE.md with your project's specifics
   - It will copy matching templates into `.claude/rules/` and `.claude/skills/`

5. **Review and customize**
   - Edit CLAUDE.md to match your project's conventions
   - Remove rules that don't apply
   - Adjust permissions in `.claude/settings.json`

### Incremental Adoption

You don't need everything at once. Start small and add layers as needed:

**Week 1 — Rules only**:
Copy `.claude/rules/` and CLAUDE.md. Immediate improvement to code quality, testing, and security guidance.

**Week 2 — Add commands**:
Copy `.claude/commands/`. Use `/plan` and `/validate` to structure your workflow.

**Week 3 — Add skills**:
Copy `.claude/skills/`. Claude automatically detects and uses context management, debugging, and planning skills.

**Week 4 — Add agents and hooks**:
Copy `.claude/agents/` and `.claude/hooks/`. Update `settings.json` with hook configuration. Now you have delegation and safety guardrails.
