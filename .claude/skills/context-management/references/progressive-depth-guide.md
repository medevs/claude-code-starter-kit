# Progressive Depth Guide

Detailed reference for context management techniques: progressive depth exploration, compaction, session management, and context budgeting.

## Progressive Depth Levels

Each level represents a deeper engagement with the code. Move to the next level only for the specific code path you are actively working on.

### Level 1: Skim — Directory Structure, File Names, Exports

**Purpose:** Orient yourself in unfamiliar code. Understand what exists and where things live.

**Scenario: Exploring a new codebase for the first time**

```
# Step 1: See the top-level structure
ls src/

# Step 2: Identify feature areas
glob("src/**/index.ts")  → shows module entry points

# Step 3: Note the shape without reading details
src/
  auth/         ← authentication feature
  products/     ← product catalog
  orders/       ← order processing
  shared/       ← shared utilities
  config/       ← app configuration
```

**What you learn:** Module boundaries, naming conventions, approximate project size.
**Context cost:** Minimal — just file listings and directory names.

### Level 2: Scan — Function Signatures, Interfaces, Types

**Purpose:** Understand a module's API surface without reading implementation details.

**Scenario: Understanding the auth module before integrating with it**

```
# Step 1: Find the public API
grep("export (function|class|interface|type)" path="src/auth/")

# Step 2: Read only the type definitions
Read src/auth/types.ts  → User, Session, AuthToken interfaces

# Step 3: Read function signatures (not bodies)
Read src/auth/service.ts lines 1-30  → login(), logout(), validateToken() signatures
```

**What you learn:** What functions are available, what types they accept and return, the module's contract.
**Context cost:** Low — type definitions and signatures are compact.

### Level 3: Read — Full Implementation of Target Code

**Purpose:** Understand the actual implementation of code you are about to modify or extend.

**Scenario: Implementing a "forgot password" feature that extends the auth module**

```
# Step 1: Read the service method you'll extend
Read src/auth/service.ts (full file)  → understand login() flow in detail

# Step 2: Read the related route handler
Read src/auth/route.ts lines 45-80   → see how login endpoint is structured

# Step 3: Read the email utility you'll use
Read src/shared/email.ts lines 1-40  → sendEmail() function

# Now implement: you have exactly the context needed
```

**What you learn:** Implementation patterns, error handling approach, how existing code is structured.
**Context cost:** Moderate — full files or large sections for the code being changed.

### Level 4: Deep Dive — Complex Logic Requiring Careful Analysis

**Purpose:** Trace through complex logic to understand subtle behavior, debug tricky issues, or safely modify intricate code.

**Scenario: Debugging a race condition in session handling**

```
# Step 1: Read the session management code in full
Read src/auth/session.ts  → full file, understand state management

# Step 2: Trace the token refresh flow
Read src/auth/token-refresh.ts  → understand async refresh logic

# Step 3: Read the middleware that checks sessions
Read src/middleware/auth.ts  → see how sessions are validated per-request

# Step 4: Read the failing test
Read tests/auth/session.test.ts lines 120-160  → reproduce the scenario

# Step 5: Trace the execution path mentally
# Request A: enters middleware → checks session → starts refresh
# Request B: enters middleware → checks same session → also starts refresh
# Both complete → session gets refreshed twice → second refresh invalidates first
```

**What you learn:** Execution flow across modules, timing dependencies, subtle interactions.
**Context cost:** High — multiple full files needed simultaneously. This is when compaction of earlier context becomes critical.

## Compaction Techniques

### What to Summarize

Research findings and exploration results should be compacted once you have extracted the key information:

- **Codebase exploration results:** "Auth module uses JWT tokens, sessions stored in Redis, token refresh handled by `src/auth/token-refresh.ts`. Key functions: `refreshToken()` (line 34), `validateSession()` (line 78)."
- **Documentation lookups:** "Library X supports streaming via `createStream()` method. Requires config option `{ stream: true }`. See docs at section 4.2."
- **Pattern analysis:** "Project uses repository pattern for data access. All repos extend `BaseRepository` from `src/shared/base-repo.ts`. Methods: `findById`, `findMany`, `create`, `update`, `delete`."

### What to Keep Verbatim

Some things should never be summarized — keep them as-is in context:

- **Current plan:** The ordered list of steps you are following
- **Key decisions and rationale:** "Chose approach B because approach A would require changing the public API"
- **Error messages being debugged:** The exact error text, stack trace lines, and relevant log output
- **Code you are actively editing:** The current state of files you are modifying
- **Constraints and requirements:** What the user asked for, acceptance criteria

### What to Note as File:Line References

Code you have read and understood but do not need to hold in full:

- "Session validation logic: `src/middleware/auth.ts:45-62`"
- "Email template rendering: `src/shared/email.ts:sendEmail()` at line 23"
- "Product schema definition: `src/products/schema.ts:1-35`"
- "Test fixtures for auth: `tests/fixtures/auth.ts:createMockUser()` at line 12"

This lets you quickly re-read if needed without holding the content in context.

## Session Management

### When to Use /clear

Use `/clear` at natural task boundaries to reset context:

- **After completing a feature:** Implementation is done, tests pass, commit created
- **Switching to unrelated work:** Moving from auth bug fix to UI styling task
- **After heavy research:** You explored many files and context is full of exploration artifacts
- **After a failed approach:** You went down a wrong path and want a fresh start
- **Before a new user request:** The previous conversation is about a different topic

### Context Handoff Patterns

When you need to `/clear` but want to preserve state for the next context:

**Pattern 1: Summary before clear**
```
Before clearing, state:
- What was accomplished: "Implemented password reset endpoint, tests passing"
- What remains: "Need to add rate limiting to the endpoint, see src/auth/route.ts:89"
- Key decisions: "Used existing email service, token expires in 1 hour"
```

**Pattern 2: Plan file as breadcrumb**
```
Write state to a plan file (e.g., .plan.md or a todo in the codebase):
- Current phase and progress
- Files modified so far
- Next steps with specific file:line references
- Open questions or risks
```

**Pattern 3: Commit message as checkpoint**
```
Create a commit with a descriptive message that captures the state:
"feat(auth): add password reset endpoint

Implements POST /auth/reset-password with email verification.
Token stored in Redis with 1-hour TTL.

Remaining: rate limiting, admin notification, docs update"
```

### Signs Context Is Getting Too Large

Watch for these indicators and act proactively:

- **Slower responses:** Processing time increases noticeably
- **Repetition:** You start restating things already established
- **Losing details:** Earlier parts of the conversation become fuzzy or forgotten
- **Redundant reads:** You re-read files that were already loaded earlier
- **Drift from plan:** You lose track of where you are in a multi-step process

**When you notice these signs:**
1. Summarize current state and findings
2. Note file:line references for anything you might need again
3. If mid-task: compact and continue. If at a boundary: `/clear` and restart with summary.

## Context Budget Estimation Heuristics

### Small Task (1-2 files) — ~10% context budget

**Examples:** Fix a typo, update a config value, add a simple utility function.

**Strategy:** No special management. Read the file, make the change, validate.

### Medium Task (3-8 files) — ~30-50% context budget

**Examples:** Add a new API endpoint, refactor a service, implement a feature within one module.

**Strategy:**
- Plan the change set before editing any files
- Use JIT reading — read each file when you reach its step in the plan
- Summarize any research before starting implementation
- One validation pass at the end

### Large Task (10+ files) — ~70%+ context budget

**Examples:** Cross-cutting refactor, new feature spanning multiple modules, major library upgrade.

**Strategy:**
- Create a written plan file
- Delegate all research to sub-agents
- Implement in phases with validation between each phase
- Compact aggressively between phases
- Consider splitting into multiple sessions with handoff notes

### Research Task — Heaviest context consumer

**Examples:** "How does the auth system work?", "What testing patterns does this project use?", "Audit all API endpoints."

**Strategy:**
- Always delegate to sub-agents
- Never load raw research results into main context
- Request structured summaries from sub-agents
- Compile findings into a document or plan file

## Good vs Bad Context Usage Patterns

### Pattern 1: File Reading

**Bad:** Read 15 files upfront to "understand the codebase" before making any changes.
Result: Context is 60% full before you write a single line of code.

**Good:** Read the entry point file. Follow one import that is relevant. Implement the change. Read the next file only when you need it.
Result: Context contains only what is needed for the current step.

### Pattern 2: Test Output

**Bad:** Keep full test output (200+ lines) in context after analyzing it.
Result: Large block of text consuming context, rarely referenced again.

**Good:** Summarize: "3 tests failing in auth module — `test/auth.test.ts:45` (missing token), `:78` (expired session), `:112` (invalid role). All related to the session refactor."
Result: Key information preserved in a compact reference.

### Pattern 3: Research Results

**Bad:** Read documentation files in full, keeping all sections in context.
Result: Docs consume disproportionate context for the amount of useful information.

**Good:** Delegate doc reading to a sub-agent with a specific question. Receive a 5-line summary with the relevant configuration options.
Result: Only actionable information enters context.

### Pattern 4: Error Debugging

**Bad:** Keep every attempted fix and its error output in context as you iterate.
Result: Context fills with failed attempts that are no longer relevant.

**Good:** After each failed attempt, note what you tried and why it failed in one line. Keep only the current error and your current hypothesis.
Result: Context stays focused on the active debugging path.

### Pattern 5: Multi-Phase Work

**Bad:** Complete phase 1 research, start phase 2 implementation, keep all phase 1 exploration in context.
Result: Phase 1 artifacts crowd out space needed for phase 2 code.

**Good:** After phase 1, summarize findings in 5-10 lines. Note file:line references. Clear or compact. Start phase 2 with just the summary.
Result: Each phase gets the context space it needs.
