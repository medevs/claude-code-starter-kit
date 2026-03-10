---
name: refactoring
description: >
  Teaches systematic refactoring strategies for safely restructuring code
  without changing behavior. Use when restructuring code for improved
  readability, extracting shared logic into reusable modules, migrating
  between patterns or frameworks, reducing code duplication, or simplifying
  complex functions that have grown unwieldy.
---

# Refactoring

## When to Use

- Restructuring code for improved readability or maintainability
- Extracting shared logic into reusable modules
- Migrating between patterns or frameworks
- Reducing code duplication across the codebase
- Simplifying complex functions that have grown unwieldy

## When NOT to Use

- **Adding new behavior** — that is a feature, not a refactoring
- **When no tests exist** — write characterization tests first, then refactor
- **Premature optimization** — do not refactor for performance without profiling data

---

## Refactoring Safety Protocol

Follow these rules strictly. They exist to prevent regressions.

1. **Ensure tests exist.** If the code lacks tests, write characterization
   tests that capture the current behavior before touching anything.

2. **One refactoring at a time.** Apply a single, named refactoring pattern
   per step. Do not combine multiple transformations.

3. **Run tests after each change.** Every individual refactoring step must
   leave the test suite green.

4. **Commit after each successful refactoring.** Small, incremental commits
   make it easy to revert if something goes wrong.

5. **NEVER mix refactoring with behavior changes in the same commit.**
   Refactoring changes structure. Features change behavior. Mixing them
   makes both harder to review, debug, and revert.

---

## Common Refactoring Patterns

### Extract Function

**Trigger:** A function is longer than ~30 lines with distinct sections.
**Action:** Pull each section into its own well-named function.
**Result:** The original function reads like a table of contents.

### Extract Module

**Trigger:** A file exceeds ~300 lines with multiple responsibilities.
**Action:** Split the file by responsibility into separate modules.
**Result:** Each module has a single, clear purpose.

### Inline

**Trigger:** An abstraction adds indirection without adding clarity.
**Action:** Put the code back where it is used. Remove the wrapper.
**Result:** Fewer layers to navigate when reading the code.

### Rename

**Trigger:** A variable, function, or module name is unclear or misleading.
**Action:** Replace with an intention-revealing name.
**Result:** Readers understand the purpose without reading the implementation.

### Replace Conditionals with Guard Clauses

**Trigger:** Deeply nested if/else blocks that are hard to follow.
**Action:** Invert conditions and return early for edge cases.
**Result:** The happy path flows straight down without nesting.

### Decompose Large Function

**Trigger:** A function over ~100 lines mixing multiple abstraction levels.
**Action:** Create an orchestrator that calls focused helper functions.
**Result:** Each function operates at a single level of abstraction.

### Replace Magic Values

**Trigger:** Literal strings or numbers scattered through the code.
**Action:** Extract them into named constants with descriptive names.
**Result:** The meaning of each value is clear and changes happen in one place.

### Introduce Parameter Object

**Trigger:** A function takes 5 or more parameters.
**Action:** Group related parameters into an options object or struct.
**Result:** The function signature is cleaner and easier to extend.

---

## Migration Strategies

Use these strategies when replacing one pattern or system with another.

### Strangler Fig

Gradually replace old code with new. Both run in parallel during the
transition.

- Create a facade at the boundary between old and new
- Route traffic to the new implementation incrementally
- Remove the old implementation once migration is complete
- Lowest risk — you can stop or reverse at any point

### Branch by Abstraction

Introduce an abstraction layer, then swap the implementation behind it.

- Define an interface that both old and new implementations satisfy
- Switch all consumers to use the interface
- Build the new implementation behind the same interface
- Swap to the new implementation when ready

### Parallel Implementation

Build the new version alongside the old, compare results, then switch.

- Run both implementations simultaneously with the same inputs
- Compare outputs to verify the new version matches
- Switch over when confidence is high
- Useful when correctness is critical and hard to verify with tests alone

---

## Anti-Patterns to Avoid

1. **Refactoring without tests.** You cannot verify that behavior is preserved
   without automated checks. Write tests first.

2. **Big-bang rewrites.** Rewriting a large system from scratch is high risk
   and usually fails. Use the strangler fig pattern instead.

3. **Premature abstraction.** Wait until you see 3 or more concrete uses
   before extracting a shared abstraction. Two uses is often coincidence.

4. **Gold plating.** Making code "perfect" beyond what the current needs
   require. Refactor to the level of quality you need now.

5. **Mixing refactoring with features.** This makes both harder to review
   and harder to debug when something breaks. Keep them in separate commits.

---

## Going Deeper

See references/refactoring-catalog.md for detailed pattern mechanics with
before/after examples and migration playbooks.
