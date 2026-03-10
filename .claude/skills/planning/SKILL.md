---
name: planning
description: >
  Teaches strategic planning methodology for features, refactors, and complex
  changes. Use before implementing any feature touching 3+ files, before
  refactors that change public interfaces, when integrating a new library or
  service, or when a task feels complex with unclear requirements. Covers
  feature decomposition, dependency mapping, risk assessment, confidence
  scoring, and implementation ordering.
---

# Planning

## When to Use

- Before implementing any feature touching 3+ files
- Before refactors that change public interfaces
- When integrating a new library or service
- When a task feels complex or has unclear requirements
- When you want to estimate confidence before committing to an approach

## When NOT to Use

- Single-file bug fixes with obvious cause and solution
- Simple config changes or copy updates
- Tasks where the entire scope is already clear in your head
- Following an existing plan that is already written

## Quick Plan vs Full Plan

Not every task needs a detailed plan file. Use this decision guide:

| Situation | Plan Type | What It Looks Like |
|-----------|-----------|-------------------|
| 1-2 files, clear path | **Mental checklist** | Think through steps, then execute |
| 3-5 files, known patterns | **Quick plan** | Bullet list of files and changes in your head or stated briefly |
| 5+ files, new patterns | **Full plan** | Written plan file with phases, risks, and validation |
| Unclear requirements | **Full plan** | Must resolve ambiguity before any implementation |
| Refactor with public API changes | **Full plan** | Need to map all consumers and plan migration |

## Planning Process

### 1. Decompose the Feature

Break the work into atomic units. Each unit should be independently testable with clear inputs and outputs.

```
Feature: [name]
├── Unit 1: Types/schemas
├── Unit 2: Core business logic
├── Unit 3: Data access layer
├── Unit 4: API endpoint/route
├── Unit 5: Integration with existing code
└── Unit 6: Tests
```

### 2. Map Dependencies

Determine what must come before what:
- Types/schemas first (everything depends on data shapes)
- Core logic before integration code
- Integration before end-to-end tests
- Identify existing code that must be read and understood

### 3. Identify Existing Patterns

Before writing new code, search for how similar things are done:
- How are similar features structured in this codebase?
- What naming conventions, error handling, and test patterns exist?
- Match the codebase — never invent new conventions.

### 4. Assess Risks

For each unit, ask: what could go wrong?
- Stale documentation (library APIs may have changed)
- Implicit dependencies (code that looks independent but isn't)
- Missing validation at boundaries
- Integration gaps (works alone, fails when connected)

### 5. Design Validation Strategy

For each unit, define how you will verify it works:
- What command confirms success? (test, type check, lint)
- What does "done" look like? (acceptance criteria)
- Fastest feedback loop: unit test > integration test > manual check

### 6. Order Implementation

Arrange tasks for one-pass success:
1. Read necessary files (JIT, not all upfront)
2. Create types/schemas
3. Implement core logic
4. Add integration points
5. Write tests
6. Run full validation

## Confidence Scoring

Rate your plan before executing. This calibrates effort and identifies gaps.

| Score | Meaning | Example | Action |
|-------|---------|---------|--------|
| **9-10** | High certainty | "Add a field to an existing form — same pattern used 5 times already" | Execute immediately |
| **7-8** | Clear path, minor unknowns | "New API endpoint following existing patterns, one unfamiliar library call" | Proceed, research the unknown part first |
| **5-6** | Significant unknowns | "Integrate a payment provider I haven't used, docs look reasonable" | Research before implementing, use sub-agents |
| **3-4** | Major gaps | "Refactor auth system, unclear how sessions interact with SSO" | Deep research phase required, consider spike |
| **1-2** | Too many unknowns | "Rewrite the build system with a tool the team hasn't used" | Stop and clarify requirements, prototype first |

**Rule:** If confidence is below 7, invest more time in research and pattern identification. Use sub-agents for parallel investigation. Do not start implementing until confidence reaches 7+.

## Plan Validation Checklist

Before executing your plan, verify each item:

- [ ] All affected files identified (use grep/glob to confirm, don't guess)
- [ ] Existing patterns researched (how does the codebase do similar things?)
- [ ] Types and schemas designed (data shapes defined before logic)
- [ ] Edge cases listed (empty inputs, error paths, concurrent access)
- [ ] Test strategy defined (what tests, where, what assertions)
- [ ] Rollback approach exists (can you revert safely if something goes wrong?)
- [ ] No unresolved questions (all ambiguities resolved before coding)
- [ ] Confidence score is 7 or higher

If any item is unchecked, address it before starting implementation.

## Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|-------------|---------|----------------|
| Over-planning | More time planning than implementing | Quick plan for small tasks, full plan only for complex ones |
| Premature abstraction | Planning for hypothetical future needs | Plan for what is needed now; refactor later if needed |
| Ignoring existing patterns | Inventing new conventions | Always search for how similar features are built first |
| Monolithic plans | One giant phase with no checkpoints | Break into phases with validation between each |
| Skipping risk assessment | The bugs you don't anticipate cost the most | Spend 2 minutes listing what could go wrong |
| Starting at confidence 4 | "I'll figure it out as I go" | Research until confidence reaches 7+, then implement |
| No validation strategy | "I think it works" | Define concrete pass/fail criteria for every unit |

## Reference

See `references/plan-templates.md` for full and lightweight plan templates, risk matrices, and pre-implementation checklists.
