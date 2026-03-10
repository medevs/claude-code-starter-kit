# Commands Reference

Complete reference for all 15 slash commands in the Claude Code Starter Kit.

## Overview

Commands live in `.claude/commands/` as markdown files with YAML frontmatter. Each command specifies:

- **description** — Shown in the command list and autocomplete
- **argument-hint** — Shows expected arguments (e.g., `<feature-description>`)
- **allowed-tools** — Restricts which tools Claude can use during execution

Commands are organized into four categories: Core PIV Loop, Pipeline, Extended, and Bugfix.

---

## Core PIV Loop

The five core commands that form the Plan-Implement-Validate workflow.

### `/prime`

| | |
|---|---|
| **Purpose** | Load and understand codebase context |
| **Usage** | `/prime` |
| **Allowed Tools** | `Read, Glob, Grep, Bash(git:*)` |

**INPUT**: The current codebase — files, configs, git history, documentation.

**PROCESS**:
1. Analyze project structure via `git ls-files`
2. Detect tech stack from config files (package.json, pyproject.toml, Cargo.toml, go.mod)
3. Read core documentation (CLAUDE.md, README.md)
4. Identify key files (entry points, schemas, routers)
5. Check git state (`git log -10`, `git status`, `git branch -a`)
6. List available commands, skills, and MCP servers

**OUTPUT**: Structured summary covering project overview, architecture, tech stack, dev commands, current state, and observations.

**Example**:
```
/prime
→ Project: Next.js 15 e-commerce app
→ Stack: TypeScript, React 19, Tailwind v4, Prisma
→ 3 features implemented, 2 in progress
→ 12 commands, 7 skills available
```

---

### `/plan <feature-description>`

| | |
|---|---|
| **Purpose** | Create comprehensive implementation plan |
| **Usage** | `/plan add user authentication with JWT` |
| **Allowed Tools** | `Read, Write, Glob, Grep, Bash(git:*), Agent` |

**INPUT**: Feature description from user. Existing codebase patterns and conventions.

**PROCESS**:
1. Extract feature requirements, user value, and complexity
2. Gather codebase intelligence (patterns, dependencies, test conventions) — uses subagents for parallel research on large codebases
3. Research external documentation and best practices
4. Map affected files, dependencies, and order of operations
5. Decompose into phased, atomic tasks with validation commands
6. Assess risks and score confidence (1-10)

**OUTPUT**: Plan file at `.plans/{feature-name}.md` with mandatory reading, patterns to follow, step-by-step tasks, testing strategy, and validation commands.

**Example**:
```
/plan add user authentication with JWT
→ Plan saved to .plans/add-user-authentication.md
→ Complexity: Medium | Confidence: 8/10
→ 6 tasks across 3 phases
```

---

### `/execute <path-to-plan>`

| | |
|---|---|
| **Purpose** | Implement a feature from an existing plan file |
| **Usage** | `/execute .plans/add-user-authentication.md` |
| **Allowed Tools** | `Read, Write, Edit, Bash, Glob, Grep, Agent` |

**INPUT**: A plan file created by `/plan`. All files referenced in the plan's mandatory reading section.

**PROCESS**:
1. Read the entire plan and all mandatory reading files
2. Execute each task in order, following specified patterns
3. Validate after each task using the task's validation command
4. Create all tests specified in the testing strategy
5. Run the full validation suite (lint, types, tests, build)

**OUTPUT**: Implementation report listing files created/modified, tests added, and validation results. Indicates readiness for `/commit`.

**Example**:
```
/execute .plans/add-user-authentication.md
→ 6/6 tasks complete
→ 4 files created, 3 modified
→ 8 tests added, all passing
→ Validation: ✅ Lint ✅ Types ✅ Tests ✅ Build
```

---

### `/validate`

| | |
|---|---|
| **Purpose** | Run all project validation checks |
| **Usage** | `/validate` |
| **Allowed Tools** | `Read, Bash, Glob, Grep` |

**INPUT**: Project config files (package.json, pyproject.toml, CLAUDE.md dev commands).

**PROCESS**:
1. Detect project tools from CLAUDE.md or config files
2. Run lint & format check (eslint, biome, ruff, prettier)
3. Run type checking (tsc, mypy, pyright)
4. Run test suite (vitest, jest, pytest, cargo test, go test)
5. Run build (npm run build, cargo build, go build)

**OUTPUT**: Pass/fail table for each check with failure details. Does NOT auto-fix — suggests running `/code-review-fix` or manual fixes.

**Example**:
```
/validate
→ Lint: ✅ PASS | Types: ✅ PASS | Tests: ✅ 42/42 | Build: ✅ PASS
→ Overall: ✅ ALL PASSING
```

---

### `/commit`

| | |
|---|---|
| **Purpose** | Create atomic git commit with conventional message |
| **Usage** | `/commit` |
| **Allowed Tools** | `Read, Grep, Bash(git:*)` |

**INPUT**: Staged and unstaged changes in the working directory.

**PROCESS**:
1. Review changes (`git status`, `git diff HEAD`)
2. Safety checks — no secrets, no large binaries, changes are logically related
3. Stage relevant files (prefers specific files over `git add -A`)
4. Auto-generate conventional commit message from diff analysis
5. Commit and confirm with `git log -1`

**OUTPUT**: Commit hash and conventional commit message. Suggests splitting if diff is large (20+ files or 500+ lines).

**Example**:
```
/commit
→ feat(auth): add JWT authentication with refresh tokens
→ Commit: a1b2c3d
```

---

## Pipeline

### `/build <feature-description>`

| | |
|---|---|
| **Purpose** | End-to-end pipeline: prime → plan → execute → validate → commit |
| **Usage** | `/build add shopping cart with checkout flow` |
| **Allowed Tools** | `Read, Write, Edit, Bash, Glob, Grep, Agent` |

**INPUT**: Feature description from user.

**PROCESS**:
```
/prime ──gate──→ /plan ──gate──→ /execute ──gate──→ /validate ──gate──→ /commit
  │                │                │                  │                  │
  └ Understand     └ Confidence     └ All tasks        └ All checks      └ Clean
    codebase         ≥ 7/10          complete            pass              commit
```

Each step must pass its gate before the next begins:
- **Prime gate**: Clear understanding of the project
- **Plan gate**: Confidence score ≥ 7/10
- **Execute gate**: All tasks complete with per-task validation
- **Validate gate**: All checks pass with zero errors

**OUTPUT**: Complete summary of the entire pipeline — plan location, files created/modified, tests added, validation results, commit hash.

**Example**:
```
/build add shopping cart with checkout flow
→ Step 1: ✅ Prime — Codebase context loaded
→ Step 2: ✅ Plan — .plans/add-shopping-cart.md (Confidence: 9/10)
→ Step 3: ✅ Execute — 8 files created, 5 modified
→ Step 4: ✅ Validate — All checks passing
→ Step 5: ✅ Commit — feat(cart): add shopping cart with checkout flow
```

---

## Extended Commands

### `/setup`

| | |
|---|---|
| **Purpose** | Interactive project initialization wizard |
| **Usage** | `/setup` |
| **Allowed Tools** | `Read, Write, Edit, Bash, Glob, Grep` |

**INPUT**: Existing config files (auto-detected) or user responses to prompts.

**PROCESS**:
1. Detect or ask tech stack (Next.js, FastAPI, Hono, React Native, CLI, AI Agent, Custom)
2. Ask architecture preference (VSA, Clean, Simple)
3. Detect package manager and tools from lock files and configs
4. Offer MCP server integrations (Playwright, Supabase, GitHub, PostgreSQL, Memory, Fetch, Filesystem)
5. Populate CLAUDE.md, copy matching rule and skill templates, configure MCP
6. Verify setup with `/prime`

**OUTPUT**: Setup summary with project configuration, files modified, available commands, and next steps.

---

### `/create-prd <output-filename>`

| | |
|---|---|
| **Purpose** | Generate a Product Requirements Document |
| **Usage** | `/create-prd my-app-name` |
| **Allowed Tools** | `Read, Write, Glob, Grep` |

**INPUT**: App name/concept from user. Conversation context and requirements discussed.

**PROCESS**:
1. Extract requirements from conversation
2. Synthesize into 13 structured sections (executive summary, user stories, architecture, tech stack, API spec, implementation phases, etc.)
3. Write the PRD with markdown formatting, checkboxes, and tables

**OUTPUT**: PRD file at `.plans/prd-{name}.md`. Suggests next steps: review → `/plan <first-feature>` → `/build`.

---

### `/review [files]`

| | |
|---|---|
| **Purpose** | Code review — analyze changes for quality, security, and correctness |
| **Usage** | `/review` (staged) or `/review src/auth/` (specific files) |
| **Allowed Tools** | `Read, Write, Glob, Grep, Bash(git:*), Agent` |

**INPUT**: Staged changes (default), unstaged changes, or specified file paths.

**PROCESS**:
1. Gather changes via `git diff --cached` or read specified files
2. Analyze on 5 dimensions: correctness, security, performance, test coverage, conventions — delegates to `code-reviewer` agent when available
3. Classify findings by severity: Critical (must fix), Warning (should fix), Suggestion (nice to have)
4. Save review report

**OUTPUT**: Review report at `.plans/reviews/{date}-{scope}.md` with verdict: Approve / Approve with Comments / Request Changes. Suggests `/code-review-fix` for applying fixes.

---

### `/execution-report`

| | |
|---|---|
| **Purpose** | Post-implementation reflection comparing plan vs actual |
| **Usage** | `/execution-report` |
| **Allowed Tools** | `Read, Write, Glob, Grep, Bash(git:*)` |

**INPUT**: Recent commits, the implementation plan from `.plans/`, and validation results.

**PROCESS**:
1. Gather recent git activity and identify the plan used
2. Compare each plan task against actual implementation
3. Classify divergences as Justified (better approach) or Problematic (regression risk)
4. Note skipped items and generate recommendations

**OUTPUT**: Report at `.plans/reports/{feature}-report.md` with validation results, what went well, challenges, divergences table, and recommendations.

---

### `/code-review-fix [review-file] [scope]`

| | |
|---|---|
| **Purpose** | Apply fixes from a code review report |
| **Usage** | `/code-review-fix .plans/reviews/2025-01-15-auth.md` |
| **Allowed Tools** | `Read, Write, Edit, Bash, Glob, Grep` |

**INPUT**: A review report file (from `/review`). Optional scope filter: `critical`, `warning`, `security`, or `all` (default).

**PROCESS**:
1. Parse review findings by severity
2. Fix issues highest-severity-first: critical → warning → suggestion
3. For each issue: locate code, understand the fix, apply it maintaining style
4. Run full validation via `/validate`

**OUTPUT**: Report listing fixes applied, items skipped, and validation results. Indicates readiness for `/commit`.

---

### `/refactor <scope>`

| | |
|---|---|
| **Purpose** | Safely restructure code without changing behavior |
| **Usage** | `/refactor src/auth/` or `/refactor utils.ts` |
| **Allowed Tools** | `Read, Write, Edit, Bash, Glob, Grep, Agent` |

**INPUT**: File path, directory, or module to refactor. Existing test coverage for the target code.

**PROCESS**:
1. Analyze scope — read target files, identify refactoring type (extract, rename, simplify, migrate, deduplicate)
2. Gather intelligence — delegates to `researcher` (usage patterns, call sites) and `code-reviewer` (code smells, duplication)
3. Assess test coverage — run existing tests; if insufficient, write characterization tests first and commit them separately
4. Plan refactoring sequence — create plan at `.plans/refactors/{scope}.md` with named patterns, one per step
5. Execute one-at-a-time — apply single pattern → run tests → commit → repeat
6. Final validation — full test suite, lint, types, build; optionally delegates to `validator` agent

**OUTPUT**: Refactoring report with steps applied, metrics (lines removed, functions simplified), commits created, and validation results. Each step produces its own atomic commit: `refactor(scope): [pattern] — [description]`.

**Example**:
```
/refactor src/services/auth.ts
→ Plan: .plans/refactors/auth-service.md (4 steps)
→ Step 1: ✅ Extract Function — pull token validation into validateToken()
→ Step 2: ✅ Extract Function — pull permission check into checkPermissions()
→ Step 3: ✅ Rename — clarify variable names in login flow
→ Step 4: ✅ Replace Conditionals — guard clauses in refreshToken()
→ 4 commits created, all tests passing
```

---

### `/test <file-or-module>`

| | |
|---|---|
| **Purpose** | Generate focused tests for existing code |
| **Usage** | `/test src/services/auth.ts` or `/test src/utils/` |
| **Allowed Tools** | `Read, Write, Edit, Bash, Glob, Grep, Agent` |

**INPUT**: File or module path to generate tests for. Existing test framework configuration and conventions.

**PROCESS**:
1. Identify target — read target code, determine type (business logic, API, utility, UI component, data access)
2. Discover patterns — delegates to `researcher` to find test framework, naming conventions, directory structure, shared utilities, and example tests
3. Analyze target code — map exported functions/methods, identify happy paths, edge cases, error paths, and integration points
4. Identify gaps — if tests already exist, find untested functions, edge cases, and error paths
5. Generate tests — create test files using AAA pattern, project conventions, and proper mocking
6. Validate — run new tests, run full suite for regressions, run twice to verify determinism; optionally delegates to `validator` agent

**OUTPUT**: Test generation report with files created, coverage summary by function, test results, and a "Bugs Discovered" section — if tests reveal unexpected behavior in the target code, they are reported but NOT fixed (run `/rca` for that).

**Example**:
```
/test src/services/payment.ts
→ Framework: vitest (detected from vitest.config.ts)
→ Created: src/services/__tests__/payment.test.ts — 14 test cases
→ Coverage: processPayment (5 tests), refund (4 tests), validateCard (5 tests)
→ Results: ✅ 14/14 passing, no regressions
→ Bugs found: 1 — refund() doesn't handle negative amounts (reported, not fixed)
```

---

## Bugfix Commands

Namespaced under `bugfix/` directory — a pattern for grouping related commands.

### `/rca <issue-id-or-description>`

| | |
|---|---|
| **Purpose** | Root cause analysis for a bug |
| **Usage** | `/rca 123` or `/rca "login fails with special characters"` |
| **Allowed Tools** | `Read, Write, Glob, Grep, Bash(git:*), Bash(gh:*), Agent` |

**INPUT**: GitHub issue ID or bug description. Access to codebase and git history.

**PROCESS**:
1. Gather bug details (from GitHub issue via `gh` CLI, or parse description)
2. Search codebase for affected components, error messages, recent changes — delegates to `researcher` and `investigator` agents when available
3. Trace code paths and identify root cause (logic error, edge case, missing validation)
4. Assess impact (severity, scope, data/security implications)
5. Design fix strategy with testing requirements

**OUTPUT**: RCA document at `.plans/rca-{id}.md` with bug summary, reproduction steps, root cause analysis, proposed fix, and testing requirements. Suggests running `/fix` next.

---

### `/fix <issue-id-or-name>`

| | |
|---|---|
| **Purpose** | Implement fix from an existing RCA document |
| **Usage** | `/fix 123` |
| **Allowed Tools** | `Read, Write, Edit, Bash, Glob, Grep, Agent` |

**INPUT**: RCA document at `.plans/rca-{id}.md` (must exist — run `/rca` first).

**PROCESS**:
1. Read the RCA document — understand root cause, proposed fix, files to modify
2. Verify the bug still exists (no recent changes already fixed it)
3. Implement the fix following the RCA strategy
4. Add tests: fix verification, edge cases, regression
5. Run full validation via `/validate` — optionally delegates to `validator` agent
6. Verify the reproduction steps no longer trigger the bug

**OUTPUT**: Fix report with changes made, tests added, validation results, and a suggested conventional commit message (`fix(<scope>): ...`).

---

## Quick Reference

| Command | Args | Allowed Tools | Output Location |
|---------|------|---------------|-----------------|
| `/prime` | — | Read, Glob, Grep, Bash(git) | Console |
| `/plan` | `<feature>` | Read, Write, Glob, Grep, Bash(git), Agent | `.plans/{name}.md` |
| `/execute` | `<plan-file>` | Read, Write, Edit, Bash, Glob, Grep, Agent | Console |
| `/validate` | — | Read, Bash, Glob, Grep | Console |
| `/commit` | — | Read, Grep, Bash(git) | Git commit |
| `/build` | `<feature>` | Read, Write, Edit, Bash, Glob, Grep, Agent | `.plans/` + Git commit |
| `/setup` | — | Read, Write, Edit, Bash, Glob, Grep | CLAUDE.md + configs |
| `/create-prd` | `<name>` | Read, Write, Glob, Grep | `.plans/prd-{name}.md` |
| `/review` | `[files]` | Read, Write, Glob, Grep, Bash(git), Agent | `.plans/reviews/` |
| `/execution-report` | — | Read, Write, Glob, Grep, Bash(git) | `.plans/reports/` |
| `/code-review-fix` | `<review-file> [scope]` | Read, Write, Edit, Bash, Glob, Grep | Console |
| `/refactor` | `<scope>` | Read, Write, Edit, Bash, Glob, Grep, Agent | `.plans/refactors/` + Git commits |
| `/test` | `<file-or-module>` | Read, Write, Edit, Bash, Glob, Grep, Agent | Test files + Console |
| `/rca` | `<issue-or-desc>` | Read, Write, Glob, Grep, Bash(git), Bash(gh), Agent | `.plans/rca-{id}.md` |
| `/fix` | `<issue-id>` | Read, Write, Edit, Bash, Glob, Grep, Agent | Console + suggested commit |
