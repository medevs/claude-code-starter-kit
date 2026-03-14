# Claude Code Starter Kit

**Ship features 10x faster with a production-grade Claude Code scaffold.**

Turn Claude Code from a blank canvas into a structured development engine. Go from "figure it out yourself" to a repeatable workflow that plans, implements, validates, and commits — with safety guardrails, framework-specific guidance, and parallel subagent delegation.

**Before**: You manually prompt Claude, hope it follows conventions, and check its work yourself.
**After**: Run `/build add user authentication` and get a planned, implemented, tested, and committed feature — following your project's patterns.

---

## What You Get

| Category | Count | Details |
|----------|-------|---------|
| Slash commands | 16 | 5 PIV loop + 1 pipeline + 8 extended + 2 bugfix |
| Rules | 8 | 6 universal + 2 path-targeted (api/, frontend/) |
| Skills | 12 | 1 custom + 11 from ecosystem (anthropics, vercel, obra, supercent, mattpocock) |
| Subagents | 5 | 1 haiku (fast research) + 4 sonnet (reasoning) |
| Safety hooks | 5 | Command blocker, auto-formatter, auto-linter, branch protection, completion notifier |
| Permission tiers | 3 | allow / ask / deny in settings.json |
| MCP templates | 7 | Playwright, Supabase, GitHub, PostgreSQL, Memory, Fetch, Filesystem |
| Rule templates | 4 | Next.js, FastAPI, CLI, AI Agents |
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

## The PIV Loop

Five core commands form the Plan-Implement-Validate workflow:

```
/prime ──→ /plan ──→ /execute ──→ /validate ──→ /commit
  │          │          │            │             │
  Load       Create     Implement    Run all       Atomic
  context    plan       from plan    checks        commit
```

**`/build <feature>`** chains all five (plus optional report) with gates between each step. One command, full feature.

**Feedback loop**: After implementation, `/execution-report` captures divergences, then `/system-review` analyzes the process and suggests improvements to CLAUDE.md, commands, and workflows.

---

## All Commands

### Core PIV Loop

| Command | Args | Allowed Tools | Output |
|---------|------|---------------|--------|
| `/prime` | — | Read, Glob, Grep, Bash(git) | Console summary |
| `/plan` | `<feature>` | Read, Write, Glob, Grep, Bash(git), Agent | `.plans/{name}.md` |
| `/execute` | `<plan-file>` | Read, Write, Edit, Bash, Glob, Grep, Agent | Console report |
| `/validate` | — | Read, Bash, Glob, Grep | Pass/fail table |
| `/commit` | — | Read, Grep, Bash(git) | Git commit |

### Pipeline

| Command | Args | Allowed Tools | Output |
|---------|------|---------------|--------|
| `/build` | `<feature>` | Read, Write, Edit, Bash, Glob, Grep, Agent | Plan + commit |

### Extended

| Command | Args | Allowed Tools | Output |
|---------|------|---------------|--------|
| `/setup` | — | Read, Write, Edit, Bash, Glob, Grep | CLAUDE.md + configs |
| `/create-prd` | `<name>` | Read, Write, Glob, Grep | `.plans/prd-{name}.md` |
| `/review` | `[files]` | Read, Write, Glob, Grep, Bash(git), Agent | `.plans/reviews/` |
| `/execution-report` | — | Read, Write, Glob, Grep, Bash(git) | `.plans/reports/` |
| `/system-review` | `<plan> <report>` | Read, Write, Glob, Grep, Bash(git) | `.plans/system-reviews/` |
| `/code-review-fix` | `<review-file>` | Read, Write, Edit, Bash, Glob, Grep | Console report |
| `/refactor` | `<scope>` | Read, Write, Edit, Bash, Glob, Grep, Agent | `.plans/refactors/` + commits |
| `/test` | `<file-or-module>` | Read, Write, Edit, Bash, Glob, Grep, Agent | Test files + console |

### Bugfix

| Command | Args | Allowed Tools | Output |
|---------|------|---------------|--------|
| `/rca` | `<issue-or-desc>` | Read, Write, Glob, Grep, Bash(git, gh), Agent | `.plans/rca-{id}.md` |
| `/fix` | `<issue-id>` | Read, Write, Edit, Bash, Glob, Grep, Agent | Console + suggested commit |

### Feedback Loop

| Command | Args | Allowed Tools | Output |
|---------|------|---------------|--------|
| `/system-review` | `<plan> <report>` | Read, Write, Glob, Grep, Bash(git) | `.plans/system-reviews/` |

See [Commands Reference](docs/COMMANDS-REFERENCE.md) for INPUT/PROCESS/OUTPUT documentation for each command.

---

## Layer Architecture

```
┌─────────────────────────────────────────────┐
│  Rules          (always loaded)             │  8 rules: code quality, testing, security,
│                                             │  architecture, git, AI workflow, api, frontend
├─────────────────────────────────────────────┤
│  Commands       (user-invoked)              │  16 commands with tool restrictions
├─────────────────────────────────────────────┤
│  Skills         (auto-detected)             │  12 skills (1 custom + 11 ecosystem)
├─────────────────────────────────────────────┤
│  Subagents      (delegated)                 │  5 agents: researcher, planner, reviewer,
│                                             │  validator, investigator
├─────────────────────────────────────────────┤
│  Hooks          (safety net)                │  5 hooks: safety, formatting, linting,
│                                             │  branch protection, notifications
└─────────────────────────────────────────────┘
```

**Subagents** handle parallel work without polluting the main context:

| Agent | Model | Purpose |
|-------|-------|---------|
| researcher | haiku | Fast codebase exploration (read-only, parallelizable) |
| planner | sonnet | Solution design and plan generation |
| code-reviewer | sonnet | 6-dimension quality analysis |
| validator | sonnet | Test/lint/type/build runner |
| investigator | sonnet | Hypothesis-driven debugging and RCA |

See [Architecture Guide](docs/ARCHITECTURE-GUIDE.md) for the full stack explanation, subagent security design, and migration guide.

---

## Project Structure

```
claude-code-starter-kit/
├── CLAUDE.md                          # Root rules (<200 lines, @imports)
├── .claudeignore                      # Excludes deps, builds, binaries from context
├── README.md                          # This file
├── .claude/
│   ├── settings.json                  # Permissions (allow/ask/deny), hooks, MCP
│   ├── agents/                        # 5 subagents
│   │   ├── researcher.md              #   haiku — fast codebase explorer
│   │   ├── planner.md                 #   sonnet — solution designer
│   │   ├── code-reviewer.md           #   sonnet — quality reviewer
│   │   ├── validator.md               #   sonnet — test/lint/build runner
│   │   └── investigator.md            #   sonnet — debugger & RCA
│   ├── commands/                      # 16 slash commands
│   │   ├── prime.md                   #   /prime — load context
│   │   ├── plan.md                    #   /plan — create plan
│   │   ├── execute.md                 #   /execute — implement from plan
│   │   ├── validate.md                #   /validate — run all checks
│   │   ├── commit.md                  #   /commit — atomic commit
│   │   ├── build.md                   #   /build — full pipeline
│   │   ├── setup.md                   #   /setup — project init wizard
│   │   ├── create-prd.md              #   /create-prd — generate PRD
│   │   ├── review.md                  #   /review — code review
│   │   ├── execution-report.md        #   /execution-report — plan vs actual
│   │   ├── system-review.md          #   /system-review — process improvements
│   │   ├── code-review-fix.md         #   /code-review-fix — apply review fixes
│   │   ├── refactor.md                #   /refactor — safe code restructuring
│   │   ├── test.md                    #   /test — focused test generation
│   │   └── bugfix/                    #   Namespaced bugfix commands
│   │       ├── rca.md                 #     /rca — root cause analysis
│   │       └── fix.md                 #     /fix — implement fix from RCA
│   ├── hooks/                         # 5 hooks (safety + automation)
│   │   ├── block-dangerous-commands.sh#   PreToolUse — blocks destructive commands
│   │   ├── branch-protection.sh       #   PreToolUse — warns on main/master edits
│   │   ├── auto-format.sh            #   PostToolUse — auto-formats after edits
│   │   ├── auto-lint.sh              #   PostToolUse — runs linter after edits
│   │   └── notify-completion.sh      #   Stop — desktop notification on task completion
│   ├── rules/                         # 8 auto-loaded rules
│   │   ├── code-quality.md            #   Naming, structure, error handling
│   │   ├── testing.md                 #   Test standards, AAA, coverage
│   │   ├── git-workflow.md            #   Conventional commits, safety
│   │   ├── security.md                #   OWASP, secrets, validation
│   │   ├── architecture.md            #   VSA, dependencies, module design
│   │   ├── ai-workflow.md             #   JIT reading, delegation, context
│   │   ├── api/
│   │   │   └── api-patterns.md        #   Path-targeted: REST design, pagination
│   │   └── frontend/
│   │       └── ui-patterns.md         #   Path-targeted: UI design patterns
│   ├── skills/                        # 12 auto-detected skills (1 custom + 11 ecosystem)
│   │   ├── context-management/        #   Context window optimization
│   │   ├── claude-api/                #   🌐 anthropics/skills — Claude API & SDK patterns
│   │   ├── frontend-design/           #   🌐 anthropics/skills — Production-grade UI design
│   │   ├── mcp-builder/               #   🌐 anthropics/skills — Build MCP servers
│   │   ├── skill-creator/             #   🌐 anthropics/skills — Create & test skills with evals
│   │   ├── webapp-testing/            #   🌐 anthropics/skills — Playwright web app testing
│   │   ├── systematic-debugging/      #   🌐 obra/superpowers — Hypothesis-driven debugging (30K)
│   │   ├── subagent-driven-development/ # 🌐 obra/superpowers — Parallel subagent patterns (19K)
│   │   ├── code-refactoring/          #   🌐 supercent-io — Safe code restructuring (10.8K)
│   │   ├── task-planning/             #   🌐 supercent-io — Task planning & decomposition (10.6K)
│   │   ├── tdd/                       #   🌐 mattpocock/skills — Test-driven development (3.3K)
│   │   └── web-design-guidelines/     #   🌐 vercel-labs — UI review (100+ rules, 164K)
│   └── mcp-templates/                 # 7 MCP server configs
│       ├── fetch.json                 #   Web content fetching
│       ├── filesystem.json            #   Extended file operations
│       ├── github.json                #   GitHub API integration
│       ├── memory.json                #   Persistent memory
│       ├── playwright.json            #   Browser automation
│       ├── postgres.json              #   PostgreSQL access
│       └── supabase.json              #   Supabase management
├── docs/                              # Documentation
│   ├── GETTING-STARTED.md             #   Installation and first feature
│   ├── COMMANDS-REFERENCE.md          #   All 16 commands detailed
│   ├── ANTI-PATTERNS.md              #   Common mistakes and how to avoid them
│   ├── ARCHITECTURE-GUIDE.md          #   5-layer stack, subagents, VSA
│   ├── CUSTOMIZATION.md              #   Add rules, commands, skills, agents, hooks
│   ├── TROUBLESHOOTING.md            #   Common issues and platform fixes
│   └── FAQ.md                         #   Frequently asked questions
└── templates/                         # Injectable specializations
    ├── rules/                         # 4 framework-specific rule templates
    │   ├── nextjs.md                  #   Next.js 15+, React 19+, Tailwind v4
    │   ├── fastapi.md                 #   FastAPI, Pydantic 2.x, Python 3.12+
    │   ├── cli-tool.md                #   CLI applications
    │   └── ai-agents.md              #   LLM-powered applications
    └── skills/                        # 10 framework-specific skill templates (2 custom + 8 ecosystem)
        ├── agent-development/         #   Tool design, MCP, prompting
        ├── edge-api/                  #   Edge API patterns
        ├── vercel-react-best-practices/ # 🌐 vercel-labs — React/Next.js perf (40+ rules, 208K)
        ├── vercel-composition-patterns/ # 🌐 vercel-labs — Component composition patterns
        ├── nextjs-app-router-patterns/  # 🌐 wshobson/agents — Next.js App Router (8.3K)
        ├── fastapi-templates/           # 🌐 wshobson/agents — FastAPI patterns (6.4K)
        ├── python-performance-optimization/ # 🌐 wshobson/agents — Python perf (8.9K)
        ├── python-testing-patterns/     # 🌐 wshobson/agents — Python testing (7.1K)
        ├── api-design/                  # 🌐 supercent-io — REST API design (10.8K)
        └── database-schema-design/      # 🌐 supercent-io — Schema design (11K)
```

---

## Templates

### Rule Templates

| Template | Framework | Key Topics |
|----------|-----------|------------|
| `nextjs.md` | Next.js 15+ | App Router, Server/Client Components, React 19, Tailwind v4 |
| `fastapi.md` | FastAPI 0.115+ | Pydantic 2.x, SQLAlchemy 2.0, async patterns, Python 3.12+ |
| `cli-tool.md` | CLI apps | Argument parsing, output formatting, exit codes |
| `ai-agents.md` | AI/LLM | Tool design, prompt engineering, MCP integration |

### Skill Templates

| Template | Source | Focus |
|----------|--------|-------|
| `vercel-react-best-practices/` | 🌐 vercel-labs/agent-skills | React/Next.js perf (40+ rules, 208K installs) |
| `vercel-composition-patterns/` | 🌐 vercel-labs/agent-skills | Component composition that scales |
| `nextjs-app-router-patterns/` | 🌐 wshobson/agents | Next.js 15+ App Router patterns (8.3K installs) |
| `fastapi-templates/` | 🌐 wshobson/agents | FastAPI route patterns (6.4K installs) |
| `python-performance-optimization/` | 🌐 wshobson/agents | Python performance (8.9K installs) |
| `python-testing-patterns/` | 🌐 wshobson/agents | Python testing patterns (7.1K installs) |
| `api-design/` | 🌐 supercent-io/skills-template | REST API design patterns (10.8K installs) |
| `database-schema-design/` | 🌐 supercent-io/skills-template | Schema design, migrations (11K installs) |
| `agent-development/` | Custom | Tool design, prompt engineering, MCP |
| `edge-api/` | Custom | Edge API patterns |

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

## Design Principles

1. **Context is King** — Every file maximizes relevant context with minimum token waste
2. **Deterministic Safety** — Hooks block dangerous operations 100% of the time
3. **One-Pass Success** — Plans contain ALL information needed for first-try implementation
4. **Universal Core, Targeted Templates** — Core rules work for any JS/TS or Python project; specializations are injected
5. **Progressive Disclosure** — Start with `/setup`, learn commands as needed, customize over time
6. **Agent-First Design** — Subagents handle parallel research and validation, keeping main context clean
7. **Progressive Depth** — Skills load overview first, deep references only when needed

---

## Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/GETTING-STARTED.md) | Installation, first feature, first bug fix |
| [Commands Reference](docs/COMMANDS-REFERENCE.md) | All 16 commands with INPUT/PROCESS/OUTPUT and allowed tools |
| [Architecture Guide](docs/ARCHITECTURE-GUIDE.md) | 5-layer stack, subagents, VSA, context engineering, migration |
| [Customization](docs/CUSTOMIZATION.md) | Add rules, commands, skills, subagents, hooks, MCP servers |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues, permissions, platform-specific fixes |
| [FAQ](docs/FAQ.md) | Answers to frequently asked questions |
| [Anti-Patterns](docs/ANTI-PATTERNS.md) | Common mistakes when working with Claude Code |
| [Migration Guide](docs/MIGRATION.md) | Integrate the starter kit into an existing project |

## License

MIT
