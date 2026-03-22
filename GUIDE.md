# Claude Code Starter Kit: Comprehensive Guide

A complete guide to using the Claude Code Starter Kit effectively — combining the kit's architecture, agentic coding methodology, practical workflows, and real-world patterns into one reference.

---

## Part 1: Understanding the Starter Kit

### What It Is

The Claude Code Starter Kit is a production-grade scaffold that transforms Claude Code from a blank canvas into a structured development engine. Instead of ad-hoc prompting, you get a repeatable workflow that plans, implements, validates, and commits — with safety guardrails and framework-specific guidance.

**Before**: You manually prompt Claude, hope it follows conventions, and check its work yourself.
**After**: Run `/build add user authentication` and get a planned, implemented, tested, and committed feature — following your project's patterns.

### The 5-Layer Architecture

The kit is built on five layers, each with a distinct role. They activate at different times and compose to create a complete development workflow.

```
┌─────────────────────────────────────────────────────────┐
│  Layer 1: Rules (always loaded)                         │  Standards & constraints
├─────────────────────────────────────────────────────────┤
│  Layer 2: Commands (user-invoked)                       │  Workflows & actions
├─────────────────────────────────────────────────────────┤
│  Layer 3: Skills (auto-detected)                        │  On-demand expertise
├─────────────────────────────────────────────────────────┤
│  Layer 4: Subagents (delegated)                         │  Parallel workers
├─────────────────────────────────────────────────────────┤
│  Layer 5: Hooks (safety net)                            │  Guardrails & automation
└─────────────────────────────────────────────────────────┘
```

**Rules** are always loaded into every conversation. They define the standards Claude must follow — code quality, testing, security, architecture, git workflow, and AI workflow patterns. Path-targeted rules activate only when editing files in matching directories (e.g., `api/`, `frontend/`).

**Commands** are user-invoked slash commands that define structured workflows. Each command specifies its allowed tools, restricting what Claude can do during execution. Commands range from read-only exploration (`/prime`) to full implementation pipelines (`/build`).

**Skills** are auto-detected when Claude encounters a relevant scenario. They provide methodology and deep knowledge — context management, debugging, planning, refactoring, and delegation guidance. Skills use progressive depth: a concise overview (SKILL.md, <160 lines) with detailed references loaded only when needed.

**Subagents** are specialized workers that Claude delegates to for parallel or focused tasks. Each agent has a specific model, tool restrictions, and turn limit. They handle research, planning, code review, validation, and investigation without polluting the main conversation context.

**Hooks** are shell scripts that run automatically before tool use, after tool use, or when Claude stops. They provide safety (blocking dangerous commands, branch protection), automation (auto-formatting, auto-linting), and quality-of-life features (desktop notifications on completion).

### Complete Inventory

| Category | Count | Items |
|----------|-------|-------|
| **Slash Commands** | 16 | `/prime`, `/plan`, `/execute`, `/validate`, `/commit`, `/build`, `/setup`, `/create-prd`, `/review`, `/execution-report`, `/system-review`, `/code-review-fix`, `/refactor`, `/test`, `/rca`, `/fix` |
| **Rules** | 8 | `code-quality`, `testing`, `git-workflow`, `security`, `architecture`, `ai-workflow` + 2 path-targeted (`api/`, `frontend/`) |
| **Skills** | 16 | 5 custom (`context-management`, `grill-me`, `improve-codebase-architecture`, `creating-skills`, `delegation`) + 11 ecosystem |
| **Subagents** | 5 | `researcher` (haiku), `planner` (sonnet), `code-reviewer` (sonnet), `validator` (sonnet), `investigator` (sonnet) |
| **Safety Hooks** | 5 | `block-dangerous-commands`, `branch-protection`, `auto-format`, `auto-lint`, `notify-completion` |
| **MCP Templates** | 7 | Playwright, Supabase, GitHub, PostgreSQL, Memory, Fetch, Filesystem |
| **Rule Templates** | 6 | Next.js, FastAPI, CLI, AI Agents, Hono, React Native |
| **Skill Templates** | 10 | 2 custom + 8 ecosystem (Vercel, wshobson, supercent) |

### How Layers Work Together: A `/build` Walkthrough

When you run `/build add user authentication`, here's what each layer does:

1. **Rules** (always-on): Code quality, testing, security, architecture, and git workflow rules are already loaded and constrain every action Claude takes.
2. **Command** (`/build`): Chains `/prime` → `/plan` → `/execute` → `/validate` → `/commit` with gates between each step.
3. **Skills** (auto-detected): Context management skill activates to guide efficient file reading. Planning skill activates during `/plan`. Delegation skill activates when deciding whether to use subagents.
4. **Subagents** (delegated): The `researcher` (haiku) explores the codebase in parallel. The `planner` (sonnet) designs the implementation plan. The `validator` (sonnet) runs checks.
5. **Hooks** (safety net): `branch-protection` warns if you're on main. `block-dangerous-commands` prevents destructive operations. `auto-format` and `auto-lint` clean up code after each edit. `notify-completion` pings you when done.

```
User runs /build
    │
    ├── Rules loaded (always-on context)
    │
    ├── /prime ──gate──→ /plan ──gate──→ /execute ──gate──→ /validate ──gate──→ /commit
    │     │                │                │                  │                  │
    │     └ researcher     └ planner        └ Skills activate  └ validator        └ Hooks: auto-format,
    │       explores         designs          (context mgmt,     runs checks        auto-lint, branch
    │       codebase         plan             delegation)                           protection
    │
    └── Hooks intercept every tool call throughout
```

For the full architecture details, see [Architecture Guide](docs/ARCHITECTURE-GUIDE.md).

---

## Part 2: Getting Started

### Prerequisites

- **Claude Code** v1.0+ installed and authenticated
- **Git** initialized in your project
- **Node.js 18+** or **Python 3.10+** (depending on your stack)
- **Bash-compatible terminal** (Git Bash or WSL on Windows; native terminal on macOS/Linux)

### Installation Paths

#### Path 1: New Project

```bash
# Clone and initialize
git clone https://github.com/medevs/claude-code-starter-kit.git my-project
cd my-project && rm -rf .git && git init

# Open Claude Code and run setup
claude
/setup
```

#### Path 2: Existing Project (Migration)

```bash
# Copy the configuration into your existing project
cp -r claude-code-starter-kit/.claude/ your-project/.claude/
cp -r claude-code-starter-kit/templates/ your-project/templates/
cp claude-code-starter-kit/CLAUDE.md your-project/CLAUDE.md

# Open Claude Code in your project
cd your-project
claude
/setup
```

`/setup` will detect your existing tech stack from config files and populate CLAUDE.md accordingly.

#### Path 3: Cherry-Picking (Incremental Adoption)

You don't need everything at once. Start small:

| Week | Add | Benefit |
|------|-----|---------|
| 1 | `.claude/rules/` + `CLAUDE.md` | Immediate improvement to code quality, testing, security guidance |
| 2 | `.claude/commands/` | Structured workflows with `/plan` and `/validate` |
| 3 | `.claude/skills/` | Auto-detected context management, debugging, planning skills |
| 4 | `.claude/agents/` + `.claude/hooks/` + `settings.json` | Delegation and safety guardrails |

### Running `/setup`

`/setup` is an interactive wizard that:
1. Detects or asks your tech stack (Next.js, FastAPI, CLI, AI Agent, Custom)
2. Asks architecture preference (VSA, Clean, Simple)
3. Detects package manager and tools from lock files
4. Offers MCP server integrations (Playwright, Supabase, GitHub, etc.)
5. Populates CLAUDE.md, copies matching rule and skill templates
6. Verifies setup with `/prime`

### Understanding and Customizing CLAUDE.md

CLAUDE.md is the root rules file — kept under 200 lines using `@imports`:

```markdown
# Project Rules

@.claude/rules/code-quality.md
@.claude/rules/testing.md
@.claude/rules/git-workflow.md
@.claude/rules/security.md
@.claude/rules/architecture.md
@.claude/rules/ai-workflow.md

## Context
<!-- One-line project description -->

## Tech Stack
<!-- Populated by /setup -->

## Dev Commands
<!-- Populated by /setup -->

## Verification
<!-- lint, test, types, build commands -->

## Key Directories
<!-- Populated by /setup -->
```

**Critical**: Fill in the Verification section. This is the single highest-leverage thing you can do — it gives Claude a way to verify its work. Without it, bugs accumulate silently.

### First Steps

```bash
/prime                              # Load codebase context
/build hello world                  # Build your first feature
# Review the output, then iterate
```

For the full getting-started walkthrough, see [Getting Started](docs/GETTING-STARTED.md).

---

## Part 3: The Agentic Coding Methodology

### The Core Loop: Plan → Implement → Validate

The core methodology is a tight loop:

```
┌──────────┐     ┌─────────────┐     ┌──────────┐
│   PLAN   │────→│  IMPLEMENT  │────→│ VALIDATE │
│          │     │             │     │          │
│ /prime   │     │ /execute    │     │ /validate│
│ /plan    │     │             │     │ /review  │
└──────────┘     └─────────────┘     └──────────┘
     ↑                                     │
     └─────────── iterate ─────────────────┘
```

| Phase | Kit Commands | What Happens |
|-------|-------------|--------------|
| **Plan** | `/prime`, `/plan` | Load context, create implementation plan with confidence score |
| **Implement** | `/execute` | Implement from plan, validate per-task |
| **Validate** | `/validate`, `/review` | Run lint, types, tests, build; code review |
| **Ship** | `/commit` | Atomic conventional commit |
| **Full pipeline** | `/build` | Chains all above with gates between steps |

Each loop should be one logical change. Smaller scope = higher success rate. For complex features, break them into multiple loops.

### Context Engineering

Claude Code operates within a 200K token context window. Every file read, tool output, and conversation message consumes tokens. Efficient context use = faster, more accurate results.

**Five Principles:**

1. **Just-In-Time Reading** — Read files when needed, not "just in case." Use glob/grep to find specific files first.
2. **Targeted Search** — Search with glob/grep before reading entire files. Read interfaces before implementations.
3. **Subagent Delegation** — Offload research to subagents (especially the haiku `researcher`) to keep main context clean. Only findings return.
4. **Plan Before Edit** — Know all files you'll touch before opening any. The plan contains all context needed for implementation.
5. **Progressive Depth** — Skim → Scan → Read → Deep Dive. Only go deeper when needed. Skills load overviews first, deep references only when the overview isn't sufficient.

### Two-Tier Context System

| Tier | What | How It Loads | Examples |
|------|------|-------------|----------|
| **Always-on** | Rules, CLAUDE.md | Automatically every session | Code quality, testing, security, git workflow |
| **On-demand** | Skills, plans, references | Activated when relevant or invoked | TDD methodology, debugging framework, PRD templates |

Rules define *what* Claude must always follow. Skills provide *how* — loaded only when the task matches, keeping context lean.

### Vertical Slice Architecture (VSA)

Traditional layered architecture creates horizontal coupling — changing a feature requires touching files across many directories. This makes AI-assisted development slower because more context is needed.

**VSA organizes by feature:**

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
    ...
shared/
  database.ts         # Shared DB connection (used by 3+ features)
  auth-middleware.ts   # Shared auth logic
```

**Why VSA matters for AI:**
- **Minimal context needed** — One feature = one directory to read
- **Context isolation** — Changes to `auth/` don't require understanding `products/`
- **Token efficiency** — Plans reference files in one place, not scattered across layers
- **Parallel development** — Independent features can be built by separate agents in worktrees
- **Natural decomposition** — Features map to user stories and GitHub issues

**Rules**: Features depend on `shared/`, never on each other. Only extract to `shared/` when used by 3+ features. Each feature is independently testable.

### Context Window as Budget

The 200K context window is a finite resource — treat it as a budget:

- **Use `/clear` between unrelated tasks** to reset context
- **Keep sessions to 30-45 minutes** of active work
- **Delegate research to subagents** to keep the main context focused on implementation
- **Start fresh sessions for execution** after planning — don't carry planning context into implementation

**Signs of context pressure**: Repeated tool errors, forgotten earlier decisions, circular reasoning, re-reading files already analyzed. When you see these, it's time for `/clear` or a new session.

---

## Part 4: Core Workflows

### Full Pipeline (`/build`)

The simplest and most powerful command — one command, full feature:

```
/build add user authentication with JWT
```

What happens internally:

```
/prime ──gate──→ /plan ──gate──→ /execute ──gate──→ /validate ──gate──→ /commit
  │                │                │                  │                  │
  └ Understand     └ Confidence     └ All tasks        └ All checks      └ Clean
    codebase         ≥ 7/10          complete            pass              commit
```

**Gates** ensure quality at each step:
- **Prime gate**: Clear understanding of the project
- **Plan gate**: Confidence score ≥ 7/10
- **Execute gate**: All tasks complete with per-task validation
- **Validate gate**: All checks pass with zero errors

### Individual Commands: Decision Tree

```
What do I need to do?
│
├── Understand the codebase ──────────────→ /prime
├── Design an approach ───────────────────→ /plan <feature>
├── Implement from a plan ────────────────→ /execute <plan-file>
├── Check if everything passes ───────────→ /validate
├── Commit my changes ────────────────────→ /commit
├── Do everything end-to-end ─────────────→ /build <feature>
│
├── Set up a new project ─────────────────→ /setup
├── Create requirements doc ──────────────→ /create-prd <name>
├── Review code quality ──────────────────→ /review [files]
├── Apply review fixes ───────────────────→ /code-review-fix <review-file>
├── Restructure code safely ──────────────→ /refactor <scope>
├── Generate tests ───────────────────────→ /test <file>
│
├── Investigate a bug ────────────────────→ /rca <issue>
├── Fix a bug from RCA ───────────────────→ /fix <issue>
│
├── Compare plan vs actual ───────────────→ /execution-report
└── Improve the process ──────────────────→ /system-review <plan> <report>
```

### Bug Fix Workflow

```
/rca 123                    # Investigate: delegates to researcher + investigator agents
# Review the RCA at .plans/rca-123.md
/fix 123                    # Implement fix from RCA + add regression tests
/validate                   # Verify all checks pass
/commit                     # Ship: fix(scope): description
```

The `/rca` command uses the `researcher` and `investigator` subagents to explore the codebase, trace code paths, check git blame, and form hypotheses — all without polluting your main context.

### Code Review Workflow

```
/review                                     # Review staged changes (or /review src/auth/)
# Review findings at .plans/reviews/
/code-review-fix .plans/reviews/report.md   # Apply fixes (critical → warning → suggestion)
/validate                                   # Verify fixes don't break anything
/commit                                     # Ship the fixes
```

### PRD-Driven Development

```
/create-prd my-app                          # Generate PRD from conversation
# Review the PRD at .plans/prd-my-app.md
/plan <first-feature-from-prd>              # Plan the first feature
/build <feature>                            # Or use the full pipeline
```

### Refactoring Workflow

```
/refactor src/auth/                         # Analyze, plan, and execute refactoring
```

`/refactor` follows a safe sequence:
1. Assess test coverage — write characterization tests if needed (separate commit)
2. Plan refactoring at `.plans/refactors/{scope}.md` with named patterns
3. Execute one pattern at a time → run tests → commit → repeat
4. Each step produces an atomic commit: `refactor(scope): [pattern] — [description]`

### Self-Improving Feedback Loop

After implementation, capture lessons and improve the system:

```
/execution-report                           # Compare plan vs actual implementation
/system-review .plans/feature.md .plans/reports/feature-report.md
# Review suggestions, then apply improvements to CLAUDE.md, commands, workflows
```

This is how the kit gets smarter over time. The system improves itself.

For full command documentation, see [Commands Reference](docs/COMMANDS-REFERENCE.md).

---

## Part 5: Advanced Scenarios

### Scenario 1: New Feature from Scratch

The full lifecycle from vague idea to shipped feature.

**Phase 1 — Grill (human + AI thinking)**
```
grill-me
```
Describe your rough idea to the `grill-me` skill. It will interview you relentlessly about edge cases, trade-offs, and assumptions. This is where ubiquitous language gets established — terms like "materialize," "ghost entity," "cascade" become shared vocabulary between you and the AI.

Key principles from real-world usage:
- Explain the **why**, not just the **what**. If the AI doesn't know why you want a feature, it can't suggest alternatives.
- Let the AI drive most questions, but take the wheel when you have strong opinions.
- Spend 15-30 minutes here. The more you do here, the less rework later.

**Phase 2 — PRD**
```
/create-prd my-feature
```
The grilling session becomes rich fodder for the PRD. Q&A collocates questions with answers — the attention mechanism treats nearby context as a "hot spot," making this excellent input for summarization.

**Phase 3 — Issues**
```
prd-to-issues
```
Break the PRD into independently-grabbable GitHub issues using vertical slices. Each issue should touch the API, service, and UI for one piece of functionality. Aim for issues that are "not too big, not too small" — big enough to justify spinning up an agent, small enough to complete in one session.

**Phase 4 — AFK Agent Implementation**
Set your agent loose on the issues while you go do something else (see [Scenario 6](#scenario-6-afk-agent-execution) for details).

**Phase 5 — QA**
Create a QA plan from the commits, walk through it manually, file feedback as GitHub issues. Run the agent again to fix bugs while you continue QA-ing.

**Phase 6 — Iterate**
Repeat Phase 5 until satisfied. Each iteration tightens the feedback loop.

### Scenario 2: Complex Bug Fix

When a bug requires deep investigation across multiple code paths:

```
/rca "login fails with special characters in password"
```

The `/rca` command:
1. Gathers bug details (from GitHub issue or your description)
2. Delegates to `researcher` agent (haiku) for broad codebase search
3. Delegates to `investigator` agent (sonnet) for hypothesis-driven tracing
4. Both agents work in their own context, returning only findings
5. Produces an RCA document at `.plans/rca-{id}.md`

```
# Review the RCA, then implement
/fix 123
/validate
/commit
```

### Scenario 3: Large Refactoring

For refactoring that touches many files:

```
/refactor src/services/
```

The safe sequence:
1. **Characterization tests first** — If test coverage is insufficient, write tests that capture current behavior. Commit them separately.
2. **Plan with named patterns** — Each step is a recognized refactoring pattern (Extract Function, Rename, Replace Conditionals, etc.)
3. **One pattern, one commit** — Apply a single pattern → run full test suite → commit. If tests break, you know exactly which pattern caused it.
4. **Final validation** — Full test suite, lint, types, build.

### Scenario 4: External APIs and Databases

Use MCP server templates for external integrations:

| Use Case | MCP Template | Required Env Vars |
|----------|-------------|-------------------|
| Browser testing / UI automation | `playwright.json` | None |
| Supabase database | `supabase.json` | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` |
| GitHub API | `github.json` | `GITHUB_TOKEN` |
| Direct PostgreSQL | `postgres.json` | `DB_URL` or connection params |
| Cross-session memory | `memory.json` | None |
| Web content fetching | `fetch.json` | None |
| Extended file operations | `filesystem.json` | None |

**To enable**: Copy the template from `.claude/mcp-templates/` into `.mcp.json` at the project root, or use `/setup` to configure interactively.

**Security**: Never store secrets in `.mcp.json` — use environment variables (e.g., `${GITHUB_TOKEN}`). Add `.env` to `.gitignore` and provide `.env.example` with placeholders.

### Scenario 5: Parallel Development with Worktrees

When multiple features are independent and you want parallel agent execution:

```bash
# Create worktrees for parallel work
git worktree add ../my-project-feature-a feat/feature-a
git worktree add ../my-project-feature-b feat/feature-b

# Run agents in separate terminals
cd ../my-project-feature-a && claude    # Agent 1: /build feature-a
cd ../my-project-feature-b && claude    # Agent 2: /build feature-b
```

Each worktree gets an isolated copy — no merge conflicts during work. Ideal for:
- Parallel feature implementation
- A/B approach testing
- Running QA fixes while building new features

### Scenario 6: AFK Agent Execution

The "set it and forget it" approach — let Claude work while you step away.

**Setup**: Create a prompt or script that:
1. Reads open GitHub issues
2. Picks the next unblocked issue
3. Implements it (plan → execute → validate → commit)
4. Closes the issue
5. Loops to the next issue

**Key requirements for reliable AFK execution**:
- Issues must be well-specified (from a grilling session → PRD → issues pipeline)
- Tests must run on every commit — this is the safety net when you're not watching
- Each iteration starts with a clean context (`/clear` between issues)
- The agent should respect blocking relationships between issues

**Real-world numbers** (from video): 4 issues → 5 agent iterations → 6 commits → feature done, all while the developer went for a walk.

### Scenario 7: Session Handoff

When you're approaching context limits or ending a session:

```
/handoff
```

This creates a `HANDOFF.md` file that captures:
- What was accomplished
- What's in progress
- What's left to do
- Key decisions made
- Important context

**Next session**:
```
claude
# Claude reads HANDOFF.md and picks up where you left off
/prime
# Continue work
```

**Signs you should handoff**: Repeated tool errors, forgotten earlier decisions, circular reasoning, session exceeding 30-45 minutes of active work.

### Scenario 8: Code Review and QA Loops

For thorough quality assurance after AI implementation:

1. **Create a QA plan** from recent commits:
   ```
   Take the last N commits and create a QA plan. Save it as a GitHub issue.
   The QA plan should give a step-by-step guide on how to test every part of the new implementation.
   ```

2. **Walk through the QA plan manually** — test each item in the running application.

3. **File feedback as GitHub issues** — Describe what's wrong, include the route/context, let the agent pick it up.

4. **Run the agent to fix issues** while you continue QA-ing other items. This parallelizes human QA with AI bug-fixing.

5. **Repeat** until satisfied. Close the QA plan issue when done.

### Scenario 9: Working with MCP Servers

Match the template to your use case:

| Scenario | Template | Why |
|----------|----------|-----|
| End-to-end UI testing | `playwright.json` | Browser automation, screenshots, DOM interaction |
| Database queries and migrations | `postgres.json` or `supabase.json` | Direct SQL access without API layer |
| GitHub workflow automation | `github.json` | Issues, PRs, actions, releases |
| Fetching external docs/APIs | `fetch.json` | Web content without leaving Claude |
| Persistent cross-session knowledge | `memory.json` | Remember decisions, patterns, preferences |
| File operations beyond Read/Write | `filesystem.json` | Directory operations, file watching |

### Scenario 10: Scaling with Subagents

**When to use parallel dispatch** (3+ independent tasks):
```
# Claude launches multiple researcher agents simultaneously
# Example: exploring auth patterns, database schema, and test conventions at once
```

**When to use sequential dispatch** (dependent tasks):
```
# Step 1: researcher finds the affected code
# Step 2: investigator traces the root cause using Step 1's findings
# Step 3: planner designs the fix using Step 2's analysis
```

**Model selection**:
- **Haiku** (`researcher`): Fast, cheap. Ideal for read-only exploration, pattern discovery, launching 2-5 instances in parallel.
- **Sonnet** (`planner`, `code-reviewer`, `validator`, `investigator`): Better reasoning. Needed for decomposing problems, evaluating quality, forming hypotheses.

**When NOT to use subagents**:
- Simple, focused tasks (one file, one edit)
- When the answer is a single glob/grep query away
- Tasks requiring full conversation context

---

## Part 6: Best Practices

### Context Management

| Practice | How |
|----------|-----|
| **JIT reading** | Read files only when needed for the current step. Search with glob/grep first. |
| **Use `/clear` liberally** | Reset context between unrelated tasks. Don't carry debugging context into feature work. |
| **30-45 minute sessions** | Sessions longer than this risk context degradation. Start fresh for major topic changes. |
| **Delegate research** | Use `researcher` (haiku) for broad codebase exploration. Only summaries return to main context. |
| **Progressive depth** | Read interfaces before implementations. Load skill overviews before deep references. |
| **Focused compaction** | When compacting, always specify what to preserve vs. discard. Never compact without instructions. |

### When to Use Subagents vs Direct Work

| Task Type | Approach | Why |
|-----------|----------|-----|
| Quick file lookup | Direct (glob/grep) | Faster than spinning up an agent |
| Single-file edit | Direct | Full context already available |
| Broad codebase research | `researcher` agent (haiku) | Keeps main context clean |
| Multi-file planning | `planner` agent (sonnet) | Needs reasoning + isolated context |
| Quality review | `code-reviewer` agent (sonnet) | 6-dimension analysis needs focus |
| Running test suites | `validator` agent (sonnet) | Can run in background while you continue |
| Bug investigation | `investigator` agent (sonnet) | Hypothesis-driven tracing needs depth |
| 3+ independent questions | Parallel `researcher` agents | Answers faster than sequential |

### Planning Depth Guidelines

| Scope | Approach | Command |
|-------|----------|---------|
| < 5 files | Skip the plan, just implement | Direct editing or `/execute` with mental plan |
| 5-15 files | Create a plan | `/plan <feature>` → review → `/execute` |
| 15+ files | Full pipeline | `/build <feature>` (or `/plan` → stress-test → `/execute`) |
| Architectural change | Plan + grill | `grill-me` → `/create-prd` → `/plan` → `/build` |

### Validation Discipline

The Validation Pyramid — each level catches different issues:

```
         ┌───────────┐
         │   Build   │   Can it compile/bundle?
        ┌┴───────────┴┐
        │    Tests    │   Does it behave correctly?
       ┌┴─────────────┴┐
       │  Type Checks  │   Are types consistent?
      ┌┴───────────────┴┐
      │     Linting     │   Does it follow conventions?
     ┌┴─────────────────┴┐
     │   Code Review     │   Is it maintainable?
     └───────────────────┘
```

- `/validate` runs the top four levels automatically
- `/review` adds the human-quality code review layer
- **Always run tests after changes** — this is non-negotiable
- Define verification commands in CLAUDE.md — the single highest-leverage practice

### Git Workflow with AI

- **Conventional commits**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- **Atomic changes**: One logical change per commit. Never bundle unrelated changes.
- **Plan as checkpoint**: Commit the plan before execution — enables rollback if implementation goes wrong.
- **Context footers**: When commits modify AI context files (rules, commands, skills), add a `Context:` section to the commit body.
- **Git log as long-term memory**: Write commits as if the next reader is an AI agent.

### Feedback Loops

```
/execution-report → /system-review → improve CLAUDE.md, commands, workflows
```

After each significant feature:
1. `/execution-report` captures what diverged from the plan and why
2. `/system-review` analyzes divergences and suggests concrete improvements
3. Apply improvements so the next iteration is better

This is how the kit evolves with your project.

---

## Part 7: Anti-Patterns to Avoid

### Workflow Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| **Prompt Tunneling** | Sending 10+ messages without checking results. Claude drifts, compounds errors, wastes context. | Review output after each meaningful step. Use subagents for parallel exploration. |
| **Ghost Context** | Assuming Claude remembers prior sessions. Each conversation starts fresh. | Use CLAUDE.md for persistent rules. Use `HANDOFF.md` for session state. Reference specific files and line numbers. |
| **Mega-Prompt** | Requesting 5 features in one message. Claude misses some, conflates others. | One task per prompt. Use plan files to sequence related tasks. |
| **Kitchen Sink Session** | Mixing unrelated tasks (debug auth, then refactor CSS, then add a feature) in one session. | Use `/clear` between unrelated tasks. Start fresh sessions for fresh topics. |
| **Specs-to-Code Without QA** | Writing detailed specs, generating code, and shipping without testing the actual output. | Always QA the running application. File feedback issues. Iterate. Edge cases emerge only when you see the real thing. |
| **Skipping the Grill** | Jumping straight to implementation without stress-testing your ideas. | Spend 15-30 minutes in `grill-me` first. The more you do here, the less rework later. |

### Configuration Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| **Over-Specified CLAUDE.md** | 500+ lines. Claude can't prioritize; important rules lost in noise. | Keep under 200 lines. Use `.claude/rules/` for detail. Use imperative statements, not essays. |
| **Zero Verification** | No test/lint/build commands configured. Bugs accumulate silently. | Always define verification commands in CLAUDE.md. "Give Claude a way to verify its work" is the highest-leverage practice. |
| **Over-Reviewing AI Output** | Reading every line of generated code instead of testing behavior. | Review inputs and outputs — interfaces, modules, test results. Spot-check code, but trust the test suite. |

### Context Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| **Reading Everything Upfront** | Reading every file "just in case." Burns context window budget on irrelevant code. | Read just-in-time. Use glob/grep first. Delegate to subagents. |
| **Ignoring Context Limits** | Running sessions for hours. After ~30-45 min, quality degrades as older messages compress. | Use `/clear` between tasks. Start new sessions for major changes. Use subagents for research. |
| **Over-Planning** | Spending excessive time planning before any implementation. Plans over 500-700 lines waste context. | Match planning depth to scope. For < 5 files, skip the plan. Request conciseness. |
| **Plans Only in Conversation** | Keeping the plan in chat instead of a file. Lost when context compresses. | Always write plans to `.plans/`. They persist and can be referenced later. |

### Hook Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| **Stop Hook Loops** | A Stop hook triggers additional Claude activity, creating an infinite loop. | Guard with environment variable check. Keep Stop hooks lightweight — notifications only. |
| **Exit Code Confusion** | Using `exit 1` to block (it doesn't — `exit 2` does). | `exit 0` = success, `exit 1` = hook error (tool still runs), `exit 2` = block the tool call. |

For the full anti-patterns reference, see [Anti-Patterns Guide](docs/ANTI-PATTERNS.md).

---

## Part 8: The Day Shift / Night Shift Model

### Concept

The Day Shift / Night Shift model (coined by Jamon Holmgren) separates human work from AI work:

- **Day Shift (Human)**: Think, design, QA, make decisions. High-leverage cognitive work.
- **Night Shift (AI)**: Implement, fix bugs, run tests. Autonomous code generation.

The human focuses on inputs and outputs — what to build, why, and whether the output is correct. The AI handles the mechanical middle: writing code, running tests, making commits.

### The Full 6-Phase Workflow

This workflow comes from real-world practice building features in a production application:

```
Phase 1: Grill (22 min)          Phase 2: PRD (5 min)
┌──────────────────────┐         ┌──────────────────────┐
│  grill-me            │         │  /create-prd         │
│  ↓                   │         │  ↓                   │
│  Human explains idea │───────→ │  AI summarizes into  │
│  AI asks questions   │         │  structured document │
│  Shared vocabulary   │         │  Submitted as GH     │
│  emerges             │         │  issue               │
└──────────────────────┘         └──────────┬───────────┘
                                            │
Phase 3: Issues (5 min)          Phase 4: AFK Agent (30-90 min)
┌──────────────────────┐         ┌──────────────────────┐
│  prd-to-issues       │         │  Agent loop          │
│  ↓                   │         │  ↓                   │
│  Break PRD into      │───────→ │  Pick issue →        │
│  vertical slices     │         │  implement → test →  │
│  4-6 GitHub issues   │         │  commit → close →    │
│  with dependencies   │         │  next issue          │
└──────────────────────┘         │                      │
                                 │  HUMAN WALKS AWAY    │
                                 └──────────┬───────────┘
                                            │
Phase 5: QA (15-20 min)         Phase 6: Iterate
┌──────────────────────┐         ┌──────────────────────┐
│  Create QA plan      │         │  Agent fixes bugs    │
│  from commits        │         │  while human         │
│  ↓                   │         │  continues QA        │
│  Walk through app    │───────→ │  ↓                   │
│  File feedback as    │         │  Repeat until        │
│  GitHub issues       │         │  satisfied           │
└──────────────────────┘         └──────────────────────┘
```

### Why It Works

1. **Parallelization**: While the AI implements Issue 1, you can grill on the next feature. While the AI fixes QA bugs, you continue testing other areas.
2. **Human focuses on high-leverage work**: Thinking, designing, and QA are where human judgment is irreplaceable. Code generation is not.
3. **Tight feedback loops**: The QA → file issue → agent fixes → QA cycle is fast because issues are small and well-specified.
4. **Quality through iteration**: No single pass produces perfect code. The model embraces multiple iterations with human judgment at each gate.

### Key Principles

**Explain "why" not "what"**: If the AI has the "what," it understands what to build. But without the "why," it can't suggest alternatives or make trade-off decisions. Always explain the motivation behind a feature.

**Maintain ubiquitous language**: Establish shared terminology between you and the AI (from Domain-Driven Design). Terms like "materialize," "ghost entity," "cascade" become precise communication tools. Store these in a ubiquitous language document or CLAUDE.md so the AI uses them consistently.

**Monitor context usage**: Check your token usage periodically. At 40K tokens after a 25-minute grilling session, you're being efficient. If context grows fast, delegate research to subagents.

**Run tests on every commit**: This is the safety net for AFK execution. Without it, bugs compound silently across multiple agent iterations. The agent should run lint, types, tests, and build before every commit.

**Review interfaces, not implementations**: Focus on how modules change (the API surface), not line-by-line code review. If the tests pass and the interfaces make sense, the implementation is likely correct.

### Real Numbers from Practice

From a single feature build documented in the video:
- **22 minutes** of grilling session → 8 bullet points of clear requirements
- **~5 minutes** to generate PRD and break into issues
- **4 GitHub issues** with blocking relationships
- **5 agent iterations** (each a fresh Claude Code session)
- **6 commits** from the first pass
- **~8 minutes** of QA → 6 additional feedback issues
- **~30 minutes** of agent time fixing QA issues → 8 more commits
- **14 total commits** for the complete feature
- Total human active time: ~50 minutes. Total elapsed time: ~2.5 hours (most of it AFK).

---

## Part 9: Quick Reference

### Command Cheat Sheet

| Command | Args | Purpose | Output |
|---------|------|---------|--------|
| `/prime` | — | Load codebase context | Console summary |
| `/plan` | `<feature>` | Create implementation plan | `.plans/{name}.md` |
| `/execute` | `<plan-file>` | Implement from plan | Console report |
| `/validate` | — | Run lint, types, tests, build | Pass/fail table |
| `/commit` | — | Atomic conventional commit | Git commit |
| `/build` | `<feature>` | Full pipeline (all above) | Plan + commit |
| `/setup` | — | Project initialization wizard | CLAUDE.md + configs |
| `/create-prd` | `<name>` | Generate PRD | `.plans/prd-{name}.md` |
| `/review` | `[files]` | Code review | `.plans/reviews/` |
| `/execution-report` | — | Plan vs actual comparison | `.plans/reports/` |
| `/system-review` | `<plan> <report>` | Process improvements | `.plans/system-reviews/` |
| `/code-review-fix` | `<review-file> [scope]` | Apply review fixes | Console report |
| `/refactor` | `<scope>` | Safe code restructuring | `.plans/refactors/` + commits |
| `/test` | `<file-or-module>` | Generate tests | Test files + console |
| `/rca` | `<issue-or-desc>` | Root cause analysis | `.plans/rca-{id}.md` |
| `/fix` | `<issue-id>` | Implement fix from RCA | Console + suggested commit |

### Subagent Routing Guide

| Scenario | Agent | Model | Why |
|----------|-------|-------|-----|
| "What patterns does this codebase use?" | `researcher` | haiku | Fast, cheap, read-only exploration |
| "How should we implement this feature?" | `planner` | sonnet | Needs reasoning for decomposition |
| "Is this code secure and well-tested?" | `code-reviewer` | sonnet | Multi-dimension quality analysis |
| "Do all checks pass?" | `validator` | sonnet | Runs test/lint/build tools |
| "Why is this failing?" | `investigator` | sonnet | Hypothesis-driven tracing, git blame |
| 3+ independent questions | Multiple `researcher` | haiku | Parallel dispatch, fast answers |

### Validation Pyramid

| Level | What It Catches | Command |
|-------|----------------|---------|
| 5. **Build** | Compilation/bundling failures | `npm run build` |
| 4. **Tests** | Behavioral regressions | `npx vitest run` / `pytest` |
| 3. **Type Checks** | Type inconsistencies | `npx tsc --noEmit` / `mypy .` |
| 2. **Linting** | Convention violations | `npx eslint .` / `ruff check .` |
| 1. **Code Review** | Maintainability, security, design | `/review` |

### Decision Framework: What Goes Where

| Question | Answer | Location |
|----------|--------|----------|
| Is it constant and needed every session? | Yes | Rules (CLAUDE.md / `.claude/rules/`) |
| Is it a repeated task-type pattern? | Yes | Skills (`.claude/skills/`) |
| Is it a structured workflow? | Yes | Commands (`.claude/commands/`) |
| Is it specific to this feature? | Yes | Plan (`.plans/`) |
| Should it run automatically? | Yes | Hooks (`.claude/hooks/`) |
| Does it need parallel execution? | Yes | Subagents (`.claude/agents/`) |
| Is it framework-specific? | Yes | Templates (`templates/rules/`, `templates/skills/`) |

**Rule of thumb**: Principles go in rules. Workflows go in commands. Never mix them.

### Common Troubleshooting

| Issue | Fix |
|-------|-----|
| Commands not appearing | Check `.claude/commands/` has `.md` files with valid `description` frontmatter. Restart Claude Code. |
| Hook blocking legitimate commands | Check pattern in `block-dangerous-commands.sh`. Add to `permissions.allow` in `settings.json`. |
| MCP server not connecting | Verify `.mcp.json` exists at project root. Check env vars. Restart Claude Code. |
| `/setup` not detecting framework | Ensure config files (`package.json`, `pyproject.toml`) are at project root. |
| Subagent timing out | Increase `maxTurns` in `.claude/agents/{name}.md`. Break complex questions into smaller queries. |
| Auto-format changing files unexpectedly | Check formatter config (biome.json, .prettierrc). Remove PostToolUse hook entry to disable. |
| Path-targeted rules not loading | Directory name must match file path component (e.g., `.claude/rules/frontend/` matches `frontend/`). |
| Hooks failing on Windows | Ensure Git Bash is on PATH (`C:\Program Files\Git\bin`). Hooks are bash scripts. |

### File Reference

```
your-project/
├── CLAUDE.md                        # Root rules (<200 lines, @imports)
├── .claudeignore                    # Excludes deps, builds, binaries from context
├── .mcp.json                        # MCP server configuration
├── .claude/
│   ├── settings.json                # Permissions (allow/ask/deny), hooks
│   ├── agents/                      # 5 subagents
│   │   ├── researcher.md            #   haiku - fast codebase exploration
│   │   ├── planner.md               #   sonnet - solution design
│   │   ├── code-reviewer.md         #   sonnet - quality review
│   │   ├── validator.md             #   sonnet - validation runner
│   │   └── investigator.md          #   sonnet - bug investigation
│   ├── commands/                    # 16 slash commands
│   │   ├── prime.md                 ├── plan.md
│   │   ├── execute.md               ├── validate.md
│   │   ├── commit.md                ├── build.md
│   │   ├── setup.md                 ├── create-prd.md
│   │   ├── review.md                ├── execution-report.md
│   │   ├── system-review.md         ├── code-review-fix.md
│   │   ├── refactor.md              ├── test.md
│   │   └── bugfix/
│   │       ├── rca.md               └── fix.md
│   ├── hooks/                       # Safety & automation hooks (1 active, 4 opt-in)
│   │   ├── block-dangerous-commands.sh  # Active by default
│   │   ├── branch-protection.sh         # Opt-in
│   │   ├── auto-format.sh              # Opt-in
│   │   ├── auto-lint.sh                # Opt-in
│   │   └── notify-completion.sh         # Opt-in
│   ├── rules/                       # 8 auto-loaded rules
│   │   ├── code-quality.md          ├── testing.md
│   │   ├── git-workflow.md          ├── security.md
│   │   ├── architecture.md          ├── ai-workflow.md
│   │   ├── api/                     # Path-targeted
│   │   └── frontend/                # Path-targeted
│   ├── skills/                      # 16 auto-detected skills
│   └── mcp-templates/               # 7 MCP server configs
├── .plans/                          # Plans, PRDs, RCA docs, reports
│   ├── reports/                     # Execution reports
│   ├── reviews/                     # Code review reports
│   ├── refactors/                   # Refactoring plans
│   └── system-reviews/              # System improvement reviews
├── templates/                       # Injectable specializations
│   ├── rules/                       # 6 framework-specific rule templates
│   └── skills/                      # 10 framework-specific skill templates
└── docs/                            # Documentation
    ├── GETTING-STARTED.md
    ├── WORKFLOW-GUIDE.md
    ├── COMMANDS-REFERENCE.md
    ├── ARCHITECTURE-GUIDE.md
    ├── CUSTOMIZATION.md
    ├── TROUBLESHOOTING.md
    ├── FAQ.md
    ├── ANTI-PATTERNS.md
    └── MIGRATION.md
```

---

*For deep dives into specific topics, see the individual guides in `docs/`. For customization (adding your own rules, commands, skills, agents, hooks, and MCP servers), see [Customization Guide](docs/CUSTOMIZATION.md).*
