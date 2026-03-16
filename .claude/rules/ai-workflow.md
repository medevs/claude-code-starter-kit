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

## Sub-Agent Routing

Use sub-agents to keep the main context focused on implementation:

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

### When NOT to use sub-agents
- Simple, focused tasks (one file, one edit)
- When the answer is a single glob/grep query away
- Tasks requiring full conversation context to complete

## Context Window Management

- The 200K context window is the primary constraint — treat it as a budget
- Use /clear between unrelated tasks to reset context
- Compact proactively — summarize findings when context grows large
- Sessions longer than 30-45 minutes risk context degradation; start fresh
- Delegate research to sub-agents to keep main context lean

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
