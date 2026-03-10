---
name: debugging
description: >
  Teaches systematic debugging and troubleshooting methodology for identifying
  and resolving bugs efficiently. Use when investigating a bug report or error,
  when a test is failing unexpectedly, when encountering runtime errors or
  unexpected behavior, when performing root cause analysis, or when
  troubleshooting integration failures between components.
---

# Debugging & Troubleshooting

## When to Use

- Investigating a bug report or error message
- A test is failing unexpectedly
- Encountering runtime errors or unexpected behavior
- Performing root cause analysis on a production issue
- Troubleshooting integration failures between components

## When NOT to Use

- **Feature design** — debugging fixes broken things, it does not design new ones
- **Performance optimization** — use profiling tools and techniques instead
- **Code review** — reviewing code for quality is a different discipline

---

## Systematic Debugging Workflow

Follow these seven steps in order. Do not skip steps.

### Step 1: Reproduce

Get a reliable reproduction of the bug before anything else.

- Note the exact steps, inputs, and environment
- Confirm you can trigger the bug consistently
- If you cannot reproduce it, gather more information before proceeding

### Step 2: Isolate

Narrow the scope of where the bug could live.

- Binary search through code: comment out halves until the bug disappears
- Binary search through commits: use `git bisect` to find the introducing commit
- Binary search through inputs: reduce complex input to a minimal reproduction

### Step 3: Hypothesize

Form 2-3 theories about the root cause. Rank them by likelihood.

- Consider recent changes to the affected area
- Think about boundary conditions and edge cases
- Check assumptions about data types, shapes, and state

### Step 4: Test

Design a targeted test that confirms or eliminates each hypothesis.

- One hypothesis at a time — do not test multiple theories simultaneously
- Use assertions, log statements, or a debugger to verify
- Record what you learn from each test

### Step 5: Root Cause

Identify the actual cause, not just the symptom.

- Ask "why" repeatedly until you reach the origin of the problem
- Trace the data flow backward from the symptom to the source
- Distinguish between the trigger and the underlying defect

### Step 6: Fix

Make the minimal change that addresses the root cause.

- Resist the urge to refactor nearby code at the same time
- Keep the fix focused so it is easy to review and verify
- If a larger change is needed, fix the bug first, then refactor separately

### Step 7: Verify

Confirm the fix resolves the original issue and does not introduce regressions.

- Run the original reproduction case and confirm it passes
- Add a regression test that would catch this bug if it returns
- Run the full test suite to check for side effects

---

## Debugging by Error Type

Use this decision tree to guide your initial investigation.

### Type Errors
- Check types at module/function boundaries
- Look for implicit conversions (string to number, null coercion)
- Inspect TypeScript `any` casts or missing type annotations

### Runtime Errors
- Check for null/undefined access on optional values
- Verify array bounds and object property existence
- Look for missing error handling on async operations

### Logic Errors
- Add assertions at key decision points
- Trace data flow step by step through the affected path
- Compare expected values against actual values at each stage

### Integration Errors
- Verify API contracts: request/response shapes, status codes, headers
- Check serialization/deserialization (JSON parsing, date formats)
- Confirm authentication tokens and permissions
- Inspect network connectivity and timeout configuration

### Performance Issues
- Profile first — do not guess where the bottleneck is
- Check for N+1 query patterns in database access
- Look for unnecessary re-renders or recomputations in UI code

---

## Anti-Patterns to Avoid

1. **Shotgun debugging** — Making random changes hoping something works.
   Fix: Follow the systematic workflow. Form a hypothesis before changing code.

2. **Print-statement sprawl** — Adding logs everywhere without a hypothesis.
   Fix: Place logs strategically based on your theory of where the bug lives.

3. **Fixing symptoms not causes** — Adding null checks instead of fixing the
   source of null. Fix: Always trace back to the root cause.

4. **Assuming the bug is elsewhere** — Blaming libraries or infrastructure
   before checking your own code. Fix: Verify your code first.

5. **Not writing a regression test** — Fixing the bug but leaving no guard
   against it returning. Fix: Always add a test as part of the fix.

---

## Going Deeper

See references/debugging-techniques.md for detailed technique walkthroughs,
common error pattern catalog, and async debugging patterns.
