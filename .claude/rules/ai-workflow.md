# AI Workflow

## Core Principles

- Read files just-in-time, not preemptively — only when needed for the current step
- Search with glob/grep before reading — never read entire directories
- Verify each change compiles/passes before moving to the next file
- Prefer reading public APIs/interfaces over implementation details
- Keep iterations small — when in doubt, go smaller. Break complex features into multiple plan-implement-validate loops
- Small scope + good system = incredible results, even for advanced features built over many loops

## Verification (Highest Priority)

- Give Claude a way to verify its work — this is the single highest-leverage thing you can do
- Always run tests, lint, and type checks after changes: specify the exact commands in CLAUDE.md
- Never consider a change "done" until verification passes
- If no test exists for the behavior you changed, write one

## Subagent Routing

Use subagents to keep the main context focused on implementation:

### When to use parallel dispatch
- 3+ independent research queries with no shared state
- Searching across unrelated parts of the codebase simultaneously
- Running independent validations (lint + test + typecheck)

### When to use sequential dispatch
- Tasks where each step depends on the previous result
- Changes that must be applied in dependency order
- Investigation where findings from step 1 guide step 2

### When to use background agents
- Research that doesn't block current implementation work
- Long-running validation while you continue editing
- Exploring alternative approaches while primary approach proceeds

### When NOT to use subagents
- Simple, focused tasks (one file, one edit)
- When the answer is a single glob/grep query away
- Tasks requiring full conversation context to complete

## Context Window Management

- The 200K context window is the primary constraint — treat it as a budget
- Use /clear between unrelated tasks to reset context
- Compact proactively — summarize findings when context grows large
- Sessions longer than 30-45 minutes risk context degradation; start fresh
- Delegate research to subagents to keep main context lean

## Worktrees for Parallel Execution

- Use worktrees when multiple agents need to edit files simultaneously
- Each worktree gets an isolated copy — no merge conflicts during work
- Ideal for: parallel feature implementation, A/B approach testing

## Planning and Thinking

- Plan before multi-file edits — identify all affected files and dependency order first
- Use extended thinking ("ultrathink") for architecture decisions and complex debugging
- Enter Plan Mode for tasks touching 5+ files or involving architectural changes
- Exit Plan Mode once the approach is clear — don't over-plan simple changes
- Commit the plan as a save state BEFORE execution — enables rollback to the plan checkpoint if implementation goes wrong
- Plans exceeding 500-700 lines waste context — request conciseness before executing

## What Belongs Where (Decision Framework)

- **Is it constant and needed every session?** → Global rules (CLAUDE.md / .claude/rules/)
- **Is it a repeated task-type pattern?** → On-demand context (skills / reference guides loaded by commands)
- **Is it specific to this feature?** → Layer 2 planning (structured plan for this development loop)
- Principles go in rules. Workflows go in commands. Never mix them.

## Session Lifecycle

### Write — Externalize Knowledge

- Plans go in `.plans/` — never keep a plan only in conversation context
- Enriched commits with `Context:` footers make the AI layer's evolution visible in git log
- Handoff documents (`HANDOFF.md`) capture session state for continuation
- Git log IS long-term memory — write commits as if the next reader is an AI agent

### Isolate — Protect Context from Pollution

- Delegate research to subagents — keeps main context focused on implementation
- **Scout pattern**: When checking reference docs or skill files, read only the header/description first. Load the full document only if the header indicates relevance
- Never load large reference documents directly into main context — use a researcher agent
- Use worktrees when multiple agents need to edit files simultaneously

### Select — Load Only What's Needed

- `/prime [scope]` loads only the relevant slice of the codebase
- Path-scoped rules (e.g., `.claude/rules/api/`) auto-load only when working in matching paths
- Progressive disclosure: start with interfaces and public APIs, drill into implementation only when needed
- Read CLAUDE.md every session, but load scope-specific rules on demand

### Compress — Manage Context Proactively

- Run `/handoff` proactively before hitting context limits, not reactively after
- When using `/compact`, always provide explicit instructions about what to preserve vs. discard — never compact without specifying what to keep
- Start fresh sessions for execution after planning — don't carry planning context into implementation
- **Signs of context pressure**: repeated tool errors, forgotten earlier decisions, circular reasoning, re-reading files already analyzed

## Focused Compaction

When context grows large, compact with explicit preservation instructions:
- Specify which decisions, patterns, and file paths must be retained
- Specify what can be discarded (exploration paths, verbose tool output, rejected approaches)
- Never run `/compact` without telling it what to keep
