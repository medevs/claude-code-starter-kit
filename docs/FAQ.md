# Frequently Asked Questions

## General

### What is the Claude Code Starter Kit?

A production-grade scaffold for Claude Code that provides pre-configured commands, rules, skills, subagents, hooks, and MCP templates. It transforms Claude Code from a general-purpose assistant into a structured development workflow engine.

### Who is this for?

Any developer using Claude Code who wants:
- A repeatable workflow (plan → implement → validate → commit)
- Safety guardrails (hooks block dangerous commands, permissions are pre-set)
- Framework-specific guidance (rules and skills for your stack)
- Faster development through subagent delegation

### What languages does it support?

The kit is focused on **JavaScript/TypeScript and Python** projects. Framework-specific behavior is injected through templates during `/setup` — choose Next.js, FastAPI, CLI tools, or AI agents, or use the "Custom" option for any JS/TS or Python project.

### Do I need to use all of it?

No. The kit is designed for incremental adoption:
1. **Start with rules** — just copy `.claude/rules/` for instant code quality improvements
2. **Add commands** — copy `.claude/commands/` for the Plan-Implement-Validate workflow
3. **Add skills** — copy `.claude/skills/` for auto-detected guidance
4. **Add agents** — copy `.claude/agents/` for delegation
5. **Add hooks** — copy `.claude/hooks/` and update `settings.json` for safety

Each layer works independently. Use what you need.

---

## Commands

### What's the difference between `/build` and running individual commands?

`/build <feature>` chains all five core commands sequentially: `/prime` → `/plan` → `/execute` → `/validate` → `/commit`. Each step must pass a gate before proceeding. Use `/build` for autonomous end-to-end development. Use individual commands when you want manual control between steps.

### What does `allowed-tools` in command frontmatter do?

It restricts which tools Claude can use during that command. For example, `/prime` only allows `Read, Glob, Grep, Bash(git:*)` — it can explore the codebase but cannot modify files. This prevents accidental changes during exploration. See the [Commands Reference](./COMMANDS-REFERENCE.md) for each command's allowed tools.

### What's the difference between `/rca` and `/fix`?

`/rca` (Root Cause Analysis) investigates a bug and produces a diagnostic document at `.plans/rca-<id>.md`. It reads code and git history but makes no changes. `/fix` reads the RCA document and implements the actual fix with tests. Always run `/rca` first, then `/fix`.

### What are `/execution-report` and `/code-review-fix`?

`/execution-report` generates a post-implementation reflection comparing the original plan against what was actually built. It captures divergences and lessons learned. `/code-review-fix` reads a review report (from `/review`) and applies the suggested fixes, then runs validation.

---

## Rules & Skills

### What's the difference between rules and skills?

**Rules** (`.claude/rules/`) are always loaded into every conversation. They define standards Claude must follow — naming conventions, testing requirements, security practices. Think of them as "always-on constraints."

**Skills** (`.claude/skills/`) are detected and activated on demand when Claude encounters a relevant scenario. They provide methodology and patterns — how to manage context, how to debug, when to delegate. Think of them as "on-demand expertise."

### How does path-targeting work for rules?

Rules in subdirectories of `.claude/rules/` only activate when Claude is editing files whose path matches the subdirectory name:
- `.claude/rules/api/api-patterns.md` → active for files in `src/api/`, `app/api/`, `routes/`
- `.claude/rules/frontend/ui-patterns.md` → active for files in `frontend/`, `src/frontend/`

Rules in the root of `.claude/rules/` always load.

### What is "progressive depth" for skills?

Skills use a two-layer structure:
- `SKILL.md` — Overview and key patterns (under 160 lines, always loaded when skill activates)
- `references/` — Deep detail documents (200-400 lines, loaded only when needed)

This keeps context small by default while making deep knowledge available on demand.

### Can I disable a rule without deleting it?

Move it out of `.claude/rules/` (e.g., into a `rules-disabled/` directory). Rules are auto-loaded from `.claude/rules/` only. Also remove any `@import` for it in `CLAUDE.md`.

---

## Subagents

### What models do subagents use?

| Agent | Model | Why |
|-------|-------|-----|
| researcher | Haiku | Fast, cheap, read-only — ideal for parallel codebase exploration |
| planner | Sonnet | Needs reasoning for complex decomposition and strategy |
| code-reviewer | Sonnet | Needs reasoning for multi-dimension quality analysis |
| validator | Sonnet | Needs to parse and group diverse tool outputs |
| investigator | Sonnet | Needs reasoning for hypothesis-driven debugging |

### How much do subagents cost?

Subagents consume tokens from your Claude API usage. The researcher (Haiku) is significantly cheaper than Sonnet-based agents. For cost-sensitive workflows, prefer the researcher for read-only tasks and reserve Sonnet agents for complex analysis.

### Can I customize subagent behavior?

Yes. Edit the agent files in `.claude/agents/`. You can change:
- `model` — switch between haiku and sonnet
- `tools` — restrict or expand available tools
- `maxTurns` — adjust how many steps the agent can take
- The prompt — modify the role, process, guidelines, or output format

### Can I create new subagents?

Yes. Create a new `.md` file in `.claude/agents/` with YAML frontmatter (name, description, model, tools, maxTurns) and a markdown body defining the agent's role and process. See [Customization Guide](./CUSTOMIZATION.md#custom-subagents) for the template.

---

## Hooks & Safety

### What commands are blocked by default?

The `block-dangerous-commands.sh` hook blocks:
- `rm -rf /`, `rm -rf ~`, `rm -rf .` — catastrophic deletions
- `git push --force`, `git push -f` — force pushes that destroy remote history
- `DROP TABLE`, `DROP DATABASE` — destructive SQL
- `chmod 777` — insecure permissions
- Pipe-to-shell patterns (`curl | sh`, `wget | bash`) — remote code execution
- Fork bombs and filesystem destruction commands

Sensitive file access (`.env`, `.pem`, credentials) triggers a confirmation prompt.

### What hooks are included?

The starter kit includes 4 hook scripts. Only `block-dangerous-commands.sh` is active by default — the others are available in `.claude/hooks/` and can be enabled in `.claude/settings.json`:

| Hook | Event | Default | Purpose |
|------|-------|---------|---------|
| `block-dangerous-commands.sh` | PreToolUse | **Active** | Blocks destructive shell commands |
| `branch-protection.sh` | PreToolUse | Opt-in | Warns when editing on main/master |
| `auto-format.sh` | PostToolUse | Opt-in | Auto-formats files after edits |
| `auto-lint.sh` | PostToolUse | Opt-in | Runs linter after edits for immediate feedback |

### Can I enable/disable hooks?

Yes. Add or remove hook entries in `.claude/settings.json` under the `hooks` section. See [Customization](./CUSTOMIZATION.md) for examples of how to enable each hook.

### How does the 3-tier permission system work?

Configured in `.claude/settings.json` under `permissions`:
- **allow**: Commands execute without prompting (git status, npm test, file reads)
- **ask**: Commands prompt for user confirmation (git push, rm, docker, package installs)
- **deny**: Commands are always blocked (rm -rf /, force push, chmod 777, credential file reads)

The `deny` list also blocks reading credential directories (`~/.ssh`, `~/.aws`, `~/.gnupg`, `~/.kube`) and editing shell configs (`~/.bashrc`, `~/.zshrc`). The `ask` list requires confirmation for package installs (`npm install`, `pip install`, etc.) to mitigate supply chain risk.

See [Troubleshooting](./TROUBLESHOOTING.md#understanding-the-3-tier-model) for details.

---

## MCP Servers

### What MCP server templates are included?

| Template | Purpose | Required Env Vars |
|----------|---------|-------------------|
| `fetch.json` | Web content fetching | None |
| `filesystem.json` | Extended file operations | None |
| `github.json` | GitHub API (issues, PRs, actions) | `GITHUB_TOKEN` |
| `memory.json` | Persistent memory across sessions | None |
| `playwright.json` | Browser automation & UI testing | None |
| `postgres.json` | Direct PostgreSQL access | `DB_URL` or connection params |
| `supabase.json` | Supabase database management | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` |

### Are MCP servers required?

No. MCP servers are entirely optional. The core workflow (commands, rules, skills, agents) works without any MCP servers. Add them only when you need specific capabilities like browser testing or database access.

### How do I add a new MCP server?

1. Create a template in `.claude/mcp-templates/` (or use an existing one)
2. Copy the server config into `.mcp.json` at the project root
3. Set any required environment variables
4. Restart Claude Code

Or run `/setup` and select the servers you want — it handles the configuration automatically.

---

## Templates

### What templates are available?

**Rule templates** (in `templates/rules/`):
| Template | Framework |
|----------|-----------|
| `nextjs.md` | Next.js 15+, React 19+, App Router, Tailwind v4 |
| `fastapi.md` | FastAPI 0.115+, Pydantic 2.x, Python 3.12+ |
| `cli-tool.md` | CLI applications |
| `ai-agents.md` | LLM-powered applications |

**Skill templates** (in `templates/skills/`):
| Template | Focus |
|----------|-------|
| `react-patterns/` | React 19, hooks, composition, Server Components |
| `api-design/` | REST conventions, validation, pagination |
| `database/` | Schema design, migrations, query optimization |
| `agent-development/` | Tool design, prompt engineering, MCP |

### How do I request a new template?

Open an issue on the GitHub repository describing the framework or technology you need. Include the key patterns, conventions, and common pitfalls that should be covered.
