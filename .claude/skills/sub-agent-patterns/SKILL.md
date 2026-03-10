---
name: sub-agent-patterns
description: >
  Teaches when and how to delegate tasks to sub-agents for parallel research,
  isolated execution, and context protection. Use when gathering information
  from multiple independent sources, when research results would pollute the
  main context, when running validation/test suites in isolation, or when
  planning complex features that need deep codebase analysis. Covers research,
  parallel, validation, and planning agent patterns.
---

# Sub-Agent Patterns

## When to Use Sub-Agents

Use the decision matrix below. If any YES column applies, consider delegation.

| Scenario | Delegate? | Why |
|----------|-----------|-----|
| Need info from 3+ files you haven't read | **Yes** | Protects main context from exploration overhead |
| Two independent research questions | **Yes** | Parallel agents are faster than sequential reads |
| Running a full test suite | **Yes** | Test output is large and mostly noise |
| Analyzing unfamiliar module before integration | **Yes** | Research stays isolated, you get a summary |
| Planning a complex feature | **Yes** | Deep analysis without polluting implementation context |
| Reading one known file | No | Overhead exceeds benefit |
| Making a single edit | No | Direct action is faster |
| Sequential steps where each depends on the last | No | Can't parallelize, no context benefit |
| You already have the information in context | No | Delegation would be redundant |
| In a tight edit-test-fix loop | No | Latency of delegation disrupts flow |

## The 4 Patterns

### 1. Research Agent

**Purpose:** Gather information without polluting main context.

**Use when:** You need to explore, search, or read code that won't be directly edited in the main context.

**Flow:** Launch agent with specific question → receive structured summary → continue work in main context.

**Examples:**
- "Find all implementations of the Observer pattern in `src/`"
- "Read the Stripe SDK docs and summarize the subscription lifecycle hooks"
- "Explore `src/auth/` and report its architecture: entry points, key classes, dependencies"

### 2. Parallel Research Agent

**Purpose:** Gather multiple independent pieces of information simultaneously.

**Use when:** You need answers to 2-3 unrelated questions before proceeding.

**Flow:** Launch 2-3 agents with independent questions → collect results → synthesize.

**Examples:**
- Agent A: "Find test patterns in `tests/`" + Agent B: "Find API route patterns in `src/routes/`"
- Agent A: "Summarize library X docs" + Agent B: "Summarize library Y docs"
- Agent A: "Analyze frontend auth flow" + Agent B: "Analyze backend auth flow"

### 3. Validation Agent

**Purpose:** Run checks without loading verbose output into main context.

**Use when:** You need pass/fail results from test suites, linters, or type checkers.

**Flow:** Launch agent to run commands → receive pass/fail summary with failure details only → fix in main context.

**Examples:**
- "Run `npm test` and report only failing tests with their error messages"
- "Run `tsc --noEmit` and list all type errors by file"
- "Run the linter and report issues grouped by severity"

### 4. Planning Agent

**Purpose:** Deep codebase analysis to produce an implementation plan.

**Use when:** A complex feature needs thorough analysis before you start coding.

**Flow:** Launch agent with feature requirements + codebase scope → receive structured plan → execute plan in main context.

**Examples:**
- "Analyze `src/orders/` and design an implementation plan for order cancellation with refunds"
- "Research how this project handles migrations and propose a plan for adding a `preferences` table"

## Delegation Prompt Template

Effective delegation requires a well-structured prompt. Use this template:

```
Task: [Specific question or objective]
Scope: [Which directories/files to look in]
Output format: [How to structure the response]
Boundaries: [What NOT to do]
```

### Writing Effective Delegation Prompts

**Be specific about WHAT to find:**
- Bad: "Look at the codebase and tell me about it"
- Good: "Find all files in `src/features/` that export a Router component. For each, report the file path, route path, and whether it uses authentication middleware."

**Specify scope to prevent wandering:**
- Bad: "Find how errors are handled"
- Good: "In `src/services/` and `src/middleware/`, find all try-catch blocks and report the error handling pattern used (rethrow, log-and-continue, or transform)."

**Define output format for actionable results:**
- "Return a markdown table with columns: file, function, description"
- "List each finding as: `file:line` — one-sentence description"
- "Summarize in 3-5 bullet points with file path references"

**Set boundaries to prevent unintended actions:**
- "Do not modify any files — report findings only"
- "Only search in the `src/` directory, ignore `node_modules/` and `dist/`"
- "Focus on public API surface, skip internal helper functions"

## Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|-------------|---------|----------------|
| Over-delegation | Launching agents for trivial lookups wastes time | Delegate only when context savings justify the overhead |
| Vague prompts | "Look at the code" returns unfocused results | Use the template: specific task, scope, output format, boundaries |
| Sequential when parallel is possible | Waiting for agent A before launching agent B | Identify independent questions and launch agents simultaneously |
| Delegating dependent work | Agent B needs agent A's output to proceed | Keep dependent work in main context or chain explicitly |
| Not specifying output format | Agent returns a wall of text | Always request structured output: tables, bullet lists, or summaries |
| Delegating the core task | The main implementation work goes to a sub-agent | Sub-agents research and report; main context implements |

## Reference

See `references/delegation-templates.md` for ready-to-use delegation prompt templates.
