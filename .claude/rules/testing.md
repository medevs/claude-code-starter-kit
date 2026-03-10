# Testing Standards

## Requirements

- Every feature needs tests BEFORE the PR is merged
- Coverage target: 80%+ for new code
- Tests must be deterministic — no flaky tests, no sleep-based waits

## Test Naming

- Pattern: `test_<what>_<when>_<expected>` or `it("should <behavior> when <condition>")`
- Test names describe the behavior, not the implementation
- Examples:
  - `test_login_with_invalid_password_returns_401`
  - `it("should display error message when form submission fails")`

## Test Structure (AAA Pattern)

```
Arrange — Set up test data and preconditions
Act     — Execute the code under test
Assert  — Verify the expected outcome
```

- One logical assertion per test (multiple related asserts are fine)
- Keep tests focused — each test validates one behavior

## What to Test

- **Unit tests**: Business logic, utility functions, data transformations
- **Integration tests**: API endpoints, database queries, service interactions
- **Edge cases**: Empty inputs, boundary values, null/undefined, error paths, concurrent access
- **Regression tests**: One test per bug fix to prevent recurrence

## What NOT to Do

- Never mock the thing being tested — mock its dependencies
- Never test implementation details (private methods, internal state)
- Never write tests that depend on execution order
- Never use production databases or external services in tests
- Never hardcode dates/times — use deterministic test values or freeze time

## Test Organization

- Mirror source directory structure in test directories
- Shared test utilities in `tests/helpers/` or `tests/fixtures/`
- Factory functions for test data — avoid copying object literals across tests
