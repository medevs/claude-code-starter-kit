---
description: Refactor code — safely restructure without changing behavior
argument-hint: <scope-or-file-path>
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
---

# Refactor: Safe Code Restructuring

## Target: $ARGUMENTS

## Prerequisites

- The refactoring skill at `.claude/skills/refactoring/SKILL.md` is loaded automatically. Follow its Safety Protocol strictly.
- Tests MUST exist before refactoring begins. If they don't, write characterization tests first.
- NEVER mix refactoring with behavior changes. Refactoring changes structure only.

## Process

### 1. Analyze Scope

- Read the target files or directory at `$ARGUMENTS`
- Identify what kind of refactoring is needed (extract, rename, simplify, migrate, deduplicate)
- Check file sizes, function lengths, and complexity indicators
- Note the public API surface that must be preserved

### 2. Gather Intelligence

Delegate to the `researcher` agent to explore in parallel:
- How the target code is used across the codebase (imports, call sites, references)
- Existing test coverage for the target
- Related patterns elsewhere that should stay consistent
- Any recent changes to the target (via `git log`)

Delegate to the `code-reviewer` agent to identify:
- Code smells: long functions, deep nesting, feature envy, shotgun surgery
- Duplication across the target and related files
- Naming issues, unclear abstractions, unnecessary indirection

### 3. Assess Test Coverage

- Run existing tests that cover the target code
- If coverage is insufficient:
  - Write characterization tests that capture current behavior
  - Run them to confirm they pass
  - Commit them separately: `test(scope): add characterization tests before refactoring`

### 4. Plan Refactoring Sequence

Create a refactoring plan at `.plans/refactors/{scope}.md`:

```markdown
## Refactoring Plan: {scope}

### Current State
- [Description of current structure and issues]

### Target State
- [Description of desired structure]

### Sequence (one refactoring per step)
1. [Named pattern] — [specific change] — [validation command]
2. [Named pattern] — [specific change] — [validation command]
...

### Risk Assessment
- [What could break, how to verify]
```

Each step must use a **named refactoring pattern** from the skill (Extract Function, Extract Module, Inline, Rename, Replace Conditionals, Decompose, Replace Magic Values, Introduce Parameter Object).

### 5. Execute One-at-a-Time

For EACH step in the sequence:

**a. Apply** — Make the single structural change

**b. Validate** — Run the test suite immediately
- If tests fail: revert the change and reassess
- If tests pass: continue

**c. Commit** — Create an atomic commit: `refactor(scope): [named pattern] — [description]`

**d. Report** — "✅ Step N complete — [pattern]: [description]"

**CRITICAL**: Do NOT combine multiple refactoring steps. One pattern, one commit, one validation.

### 6. Final Validation

After all steps are complete:
- Run the full test suite
- Verify the public API surface is unchanged
- Optionally delegate to `validator` agent for comprehensive checks (lint, types, tests, build)
- Compare before/after: fewer lines, simpler structure, same behavior

## Sub-Agent Delegation

When the `Agent` tool is available:

| Agent | Task |
|-------|------|
| `researcher` | Discover usage patterns, test coverage, call sites, related code |
| `code-reviewer` | Identify code smells, duplication, naming issues, unnecessary complexity |
| `validator` | Run full validation suite after refactoring is complete |

## Output Report

```markdown
### Refactoring Complete

**Scope**: [target description]
**Plan**: .plans/refactors/{scope}.md

### Steps Applied
1. ✅ [Named pattern] — [description]
2. ✅ [Named pattern] — [description]
...

### Metrics
- Functions simplified: X
- Lines removed: X
- Files split/merged: X
- Test coverage: maintained/improved

### Commits Created
- `refactor(scope): [step 1]`
- `refactor(scope): [step 2]`
...

### Validation
- Tests: ✅ X/X passing
- Lint: ✅ Pass
- Types: ✅ Pass
- Build: ✅ Pass

### Public API
- ✅ No breaking changes to public interfaces
```

## If Issues Arise

- If tests fail after a refactoring step: revert and try a smaller step
- If the scope is too large: break into multiple `/refactor` invocations
- If behavior changes are needed: stop and use `/plan` + `/execute` instead — refactoring is structure-only
- If no tests exist and characterization tests are hard to write: document the risk and proceed with extra caution
