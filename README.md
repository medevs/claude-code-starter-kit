# Claude Code Starter Kit

**Ship features 10x faster with a production-grade Claude Code scaffold.**

Turn Claude Code from a blank canvas into a structured development engine. Go from "figure it out yourself" to a repeatable workflow that plans, implements, validates, and commits — with safety guardrails, framework-specific guidance, and parallel subagent delegation.

**Before**: You manually prompt Claude, hope it follows conventions, and check its work yourself.
**After**: Run `/build add user authentication` and get a planned, implemented, tested, and committed feature — following your project's patterns.

---

## Who Is This For?

Any developer using Claude Code who wants a repeatable workflow instead of ad-hoc prompting. Whether you're building web apps, APIs, CLIs, or AI agents — the kit gives Claude the structure to work autonomously while following your project's conventions.

---

## What Makes This Different?

- **Tool restrictions per command** — `/prime` can only read, `/commit` can only use git. No accidental modifications during exploration.
- **5-layer architecture** — Rules (always-on) → Commands (workflows) → Skills (on-demand) → Subagents (parallel workers) → Hooks (safety net). Each layer activates at the right time.
- **Subagent delegation** — Research runs in haiku (fast, cheap), reasoning runs in sonnet. Main context stays clean.
- **Self-improving** — Feedback loops (`/execution-report` → `/system-review`) analyze the process and suggest improvements to CLAUDE.md and commands.

---

## What You Get

16 commands, 8 rules, 16 skills, 5 subagents, 4 hooks — all pre-configured.

| Category | Count | Details |
|----------|-------|---------|
| Slash commands | 16 | 5 core + 1 pipeline + 8 extended + 2 bugfix |
| Rules | 8 | 6 universal + 2 path-targeted (api/, frontend/) |
| Skills | 16 | 5 custom + 11 from ecosystem (anthropics, vercel, obra, supercent, mattpocock) |
| Subagents | 5 | 1 haiku (fast research) + 4 sonnet (reasoning) |
| Safety hooks | 4 | Command blocker, auto-formatter, auto-linter, branch protection |
| Permission tiers | 3 | allow / ask / deny in settings.json |
| MCP templates | 7 | Playwright, Supabase, GitHub, PostgreSQL, Memory, Fetch, Filesystem |
| Rule templates | 6 | Next.js, FastAPI, CLI, AI Agents, Hono, React Native |
| Skill templates | 10 | 2 custom + 8 from ecosystem (vercel, wshobson, supercent) |

**JS/TS + Python focused** with injectable specializations for web apps, APIs, CLIs, and AI agents.

---

## Quick Start

**Prerequisites**: Claude Code v1.0+, Git, Node.js 18+ or Python 3.10+, bash-compatible terminal.

```bash
# 1. Clone into your project
git clone https://github.com/medevs/claude-code-starter-kit.git my-project
cd my-project && rm -rf .git && git init

# 2. Open Claude Code and run setup
claude
/setup

# 3. Build your first feature
/build add user authentication
```

**What just happened?** `/setup` detected your tech stack, configured CLAUDE.md, and copied matching templates. `/build` chained five commands — prime, plan, execute, validate, commit — to deliver a planned, implemented, tested, and committed feature.

See [Getting Started](docs/GETTING-STARTED.md) for the full walkthrough with expected output at each step.

---

## The Core Workflow

Five core commands form the Plan-Implement-Validate workflow:

```
/prime ──→ /plan ──→ /execute ──→ /validate ──→ /commit
  │          │          │            │             │
  Load       Create     Implement    Run all       Atomic
  context    plan       from plan    checks        commit
```

**`/build <feature>`** chains all five (plus optional report) with gates between each step. One command, full feature.

**Feedback loop**: After implementation, `/execution-report` captures divergences, then `/system-review` analyzes the process and suggests improvements to CLAUDE.md, commands, and workflows.

See [Workflow Guide](docs/WORKFLOW-GUIDE.md) for the full methodology: two-tier context system, validation pyramid, stress-testing, and best practices.

---

## All Commands

| Command | Purpose | Output |
|---------|---------|--------|
| `/prime` | Load codebase context | Console summary |
| `/plan <feature>` | Create implementation plan | `.plans/{name}.md` |
| `/execute <plan>` | Implement from plan | Console report |
| `/validate` | Run lint, types, tests, build | Pass/fail table |
| `/commit` | Atomic conventional commit | Git commit |
| `/build <feature>` | Full pipeline (all above) | Plan + commit |
| `/setup` | Project initialization wizard | CLAUDE.md + configs |
| `/create-prd <name>` | Generate PRD | `.plans/prd-{name}.md` |
| `/review [files]` | Code review | `.plans/reviews/` |
| `/execution-report` | Plan vs actual comparison | `.plans/reports/` |
| `/system-review <plan> <report>` | Process improvements | `.plans/system-reviews/` |
| `/code-review-fix <file>` | Apply review fixes | Console report |
| `/refactor <scope>` | Safe code restructuring | `.plans/refactors/` + commits |
| `/test <file>` | Generate tests | Test files + console |
| `/rca <issue>` | Root cause analysis | `.plans/rca-{id}.md` |
| `/fix <issue>` | Implement fix from RCA | Console + suggested commit |

See [Commands Reference](docs/COMMANDS-REFERENCE.md) for INPUT/PROCESS/OUTPUT documentation and allowed tools for each command.

---

## Project Structure

```
claude-code-starter-kit/
├── CLAUDE.md                     # Root rules (<200 lines, @imports)
├── .claudeignore                 # Excludes deps, builds, binaries from context
├── .claude/
│   ├── settings.json             # Permissions (allow/ask/deny), hooks, MCP
│   ├── agents/                   # 5 subagents (researcher, planner, code-reviewer, validator, investigator)
│   ├── commands/                 # 16 slash commands
│   ├── hooks/                    # 4 hooks (safety + automation)
│   ├── rules/                    # 8 auto-loaded rules (+ path-targeted for api/, frontend/)
│   ├── skills/                   # 16 auto-detected skills (5 custom + 11 ecosystem)
│   └── mcp-templates/            # 7 MCP server configs
├── docs/                         # Documentation (8 guides)
└── templates/                    # Injectable specializations
    ├── rules/                    # 6 framework-specific rule templates
    └── skills/                   # 10 framework-specific skill templates
```

See [Architecture Guide](docs/ARCHITECTURE-GUIDE.md) for the full 5-layer stack explanation, subagent security design, and detailed structure.

---

## Workflows

### New Project
```
/setup → /create-prd myapp → /build <feature-1> → /build <feature-2> → ...
```

### Existing Project
```
# See docs/MIGRATION.md for step-by-step integration, then:
/setup → /prime → /plan <feature> → /execute <plan> → /validate → /commit
```

### Bug Fix
```
/rca <issue> → /fix <issue> → /commit
```

### Code Review
```
/review → /code-review-fix .plans/reviews/{file}.md → /commit
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/GETTING-STARTED.md) | Installation, first feature, first bug fix |
| [Workflow Guide](docs/WORKFLOW-GUIDE.md) | Agentic coding methodology, best practices, feedback loops |
| [Commands Reference](docs/COMMANDS-REFERENCE.md) | All 16 commands with INPUT/PROCESS/OUTPUT and allowed tools |
| [Architecture Guide](docs/ARCHITECTURE-GUIDE.md) | 5-layer stack, subagents, design principles, VSA, context engineering |
| [Customization](docs/CUSTOMIZATION.md) | Add rules, commands, skills, subagents, hooks, templates, MCP servers |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues, permissions, platform-specific fixes |
| [FAQ](docs/FAQ.md) | Answers to frequently asked questions |
| [Anti-Patterns](docs/ANTI-PATTERNS.md) | Common mistakes when working with Claude Code |
| [Migration Guide](docs/MIGRATION.md) | Integrate the starter kit into an existing project |

## License

MIT
