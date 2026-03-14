---
description: Generate tests — focused test creation for existing code
argument-hint: <file-or-module-path>
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
---

# Test: Focused Test Generation

## Target: $ARGUMENTS

## Instructions

Follow the testing standards defined in `.claude/rules/testing.md` (AAA pattern, naming conventions, coverage targets).

### 1. Identify Target

- Read the target file or module at `$ARGUMENTS`
- Determine what type of code it is: business logic, API endpoint, utility, UI component, data access
- Identify the public API surface: exported functions, class methods, route handlers
- Note dependencies that will need mocking

### 2. Discover Patterns

Delegate to the `researcher` agent to discover in parallel:
- What test framework is configured (vitest, jest, pytest, etc.)
- Existing test file naming conventions (`.test.ts`, `.spec.ts`, `test_*.py`)
- Test directory structure (colocated vs separate `tests/` directory)
- Shared test utilities, fixtures, factories, and helpers
- How similar code in the project is already tested (find 2-3 example test files)

### 3. Analyze Target Code

For each exported function/method/handler, identify:
- **Happy path**: Normal inputs → expected output
- **Edge cases**: Empty inputs, boundary values, null/undefined, max/min values
- **Error paths**: Invalid inputs, missing dependencies, network failures, timeouts
- **State transitions**: If stateful, what state changes occur and in what order
- **Integration points**: Database queries, API calls, file I/O that need mocking

### 4. Identify Gaps

If tests already exist for the target:
- Read existing test files
- Map which functions/paths are already covered
- Identify untested edge cases, error paths, and recent additions
- Focus new tests on gaps only — do not duplicate existing coverage

### 5. Generate Tests

Create test files following project conventions discovered in Step 2.

**Structure each test using AAA pattern**:
```
Arrange — Set up test data, mocks, and preconditions
Act     — Call the function/endpoint under test
Assert  — Verify the expected outcome
```

**Naming**: Use the project's convention. Default to:
- `test_<what>_<when>_<expected>` (Python)
- `it("should <behavior> when <condition>")` (JS/TS)

**Organization**:
- Group by function/method using `describe` blocks or test classes
- Order: happy path → edge cases → error paths
- One logical assertion per test
- Use factory functions for test data — avoid copying object literals

**Mocking**:
- Mock dependencies, never the thing being tested
- Use the project's existing mock patterns and utilities
- Prefer lightweight fakes over complex mock setups
- Reset mocks between tests to prevent state leakage

### 6. Validate

- Run the new tests: verify they all pass
- Run the full test suite: verify no regressions
- Optionally delegate to `validator` agent for comprehensive validation (lint, types, tests, build)
- Check that tests are deterministic — run twice to confirm no flaky behavior

## Sub-Agent Delegation

When the `Agent` tool is available:

| Agent | Task |
|-------|------|
| `researcher` | Discover test framework, conventions, utilities, and example tests |
| `validator` | Run full validation suite after tests are written |

## Output Report

```markdown
### Test Generation Complete

**Target**: [file/module path]
**Framework**: [test framework detected]

### Tests Created
- `path/to/test/file` — X test cases
  - [list of test names grouped by function]

### Coverage Summary
| Function/Method | Happy Path | Edge Cases | Error Paths |
|-----------------|------------|------------|-------------|
| functionName    | ✅ 2 tests | ✅ 3 tests | ✅ 1 test  |
| ...             | ...        | ...        | ...         |

### Test Results
- New tests: ✅ X/X passing
- Full suite: ✅ X/X passing (no regressions)
- Deterministic: ✅ Passed twice

### Bugs Discovered
If any tests revealed unexpected behavior in the target code:
- **[function:line]**: [description of unexpected behavior]
  - Expected: [what the code should do]
  - Actual: [what the code does]
  - Note: This is a bug report, not a fix. Run `/rca` to investigate.

### Ready for Commit
Run `/commit` to commit the new tests.
Suggested message: `test(scope): add tests for [target]`
```

## If Issues Arise

- If the test framework isn't configured: suggest setup steps but don't auto-configure
- If tests reveal bugs: document them in the "Bugs Discovered" section but do NOT fix them — that's a separate task
- If mocking is complex: prefer integration tests over heavily-mocked unit tests
- If existing tests are flaky: note them but don't fix — that's a separate refactoring task
