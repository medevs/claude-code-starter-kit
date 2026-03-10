---
name: context-management
description: >
  Teaches advanced context window optimization strategies for large codebases
  and multi-step tasks. Use when working in repositories with 50+ files, making
  changes across 5+ files, when context is growing large and responses are
  slowing, or when performing research-heavy tasks that risk consuming the
  context window. Covers JIT reading, progressive depth exploration, compaction
  strategies, and session management.
---

# Context Management

## When to Use

- Working in a large codebase (50+ files)
- Making changes across multiple files (5+)
- Context is growing large and responses are slowing
- Performing research-heavy tasks (pattern analysis, documentation review)
- Starting a new unrelated task in the same session

## When NOT to Use

- Small, focused edits to 1-2 files
- You already have all needed context loaded
- The task is straightforward with a clear path
- Running simple commands or quick lookups

## Context Management Workflow

Follow this sequence for any task that may consume significant context:

1. **Assess scope** — How many files are involved? Is this a small fix or a cross-cutting change? Estimate the context budget (see below).
2. **Choose strategy** — Small task: just work. Medium task: plan first, read JIT. Large task: delegate research to sub-agents, plan in a file.
3. **Apply JIT reading** — Read only the file or section you need for the current step. Follow imports only when the current code references them.
4. **Monitor context usage** — Watch for signs of context pressure: slower responses, repetition in output, losing track of earlier details.
5. **Compact when needed** — Summarize findings, note file:line references, use `/clear` at task boundaries.

## Core Techniques

### Just-In-Time (JIT) Reading

Read files only when their content is needed for the current step.

**How to apply JIT in practice:**
- Start from the entry point of the change (the file you will edit first)
- When that file imports from another module, read that module only if the import is relevant to your change
- Read specific line ranges when you know what section matters
- After reading, extract what you need and move on — don't hold entire files in context

**Example flow:**
```
Need to fix a bug in UserService.createUser()
→ Read src/services/user.ts (the file with the bug)
→ See it calls validateEmail() from src/utils/validation.ts
→ Read only validateEmail() function (lines 45-62), not the whole file
→ Fix the bug, move on
```

### Targeted Search Before Reading

Always narrow down before reading:
1. `glob` to find files by name pattern
2. `grep` to find specific content across files
3. Read only the matched files or line ranges
4. Never read an entire directory to "understand the codebase"

### Sub-Agent Delegation for Research

Offload heavy exploration to sub-agents to protect main context:
- "Find all implementations of interface X" → sub-agent returns a summary
- "Analyze the test patterns in this project" → sub-agent returns a structured report
- "Search docs for configuration options" → sub-agent returns relevant excerpts

Keep in main context: your plan, current implementation work, key decisions.

### Progressive Depth Exploration

Start broad, go deep only where needed:

| Level | What You Read | When |
|-------|--------------|------|
| **Skim** | Directory structure, file names, exports | Orienting in unfamiliar code |
| **Scan** | Function signatures, class interfaces, types | Understanding a module's API |
| **Read** | Full implementation of specific functions | Implementing changes |
| **Deep dive** | Complex algorithms, state machines, edge cases | Debugging subtle issues |

Move to the next level only for the specific code path you are working on.

## Context Budget Estimation

Quick heuristics for how much context a task will consume:

| Task Size | Files | Budget | Strategy |
|-----------|-------|--------|----------|
| **Small** | 1-2 files | ~10% | No special management needed |
| **Medium** | 3-8 files | ~30-50% | Plan before editing, use JIT reading |
| **Large** | 10+ files | ~70%+ | Mandatory sub-agent delegation, periodic compaction |
| **Research** | Variable | Heaviest | Always delegate to sub-agents |

If you estimate a task will exceed 50% of context, create a plan file and use sub-agents for exploration.

## Anti-Patterns

| Anti-Pattern | Why It Hurts | Instead |
|-------------|-------------|---------|
| Reading 10+ files upfront "to understand" | Context full before implementation starts | Read entry point, follow imports as needed |
| Keeping full test output in context | Test output is large and rarely re-read | Summarize: "3 failures in auth module, see test/auth.test.ts:45,78,112" |
| Re-reading files already in context | Wastes context on duplicate content | Note key info on first read, refer to file:line later |
| Using sub-agents for trivial tasks | Overhead exceeds benefit | Just read the one file directly |
| Not using `/clear` between tasks | Unrelated context accumulates | Clear at task boundaries |
| Reading entire files when you need one function | Loads unnecessary code into context | Read specific line ranges |

## Reference

See `references/progressive-depth-guide.md` for detailed examples at each depth level, compaction techniques, and session management strategies.
