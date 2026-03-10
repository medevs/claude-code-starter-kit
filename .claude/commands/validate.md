---
description: Run comprehensive project validation (tests, types, lint, build)
allowed-tools: Read, Bash, Glob, Grep
---

# Validate: Comprehensive Project Check

Run all validation commands to ensure the project is in a healthy state.

## Process

### 1. Detect Project Tools

Read `CLAUDE.md` "Development Commands" section to identify available commands. If not populated, auto-detect from config files:

- `package.json` → scripts section (test, lint, typecheck, build)
- `pyproject.toml` → tool sections (pytest, mypy, ruff, pyright)
- `tsconfig.json` → TypeScript project
- `biome.json` → Biome linter/formatter

### 2. Run Validation Suite

Execute each detected command in order. Report results after each:

#### Level 1: Lint & Format Check
Run the project's linting and format checking commands.

**Expected**: No errors or warnings.

#### Level 2: Type Checking
Run type checker (tsc, mypy, pyright, etc.).

**Expected**: No type errors.

#### Level 3: Test Suite
Run the full test suite.

**Expected**: All tests pass.

#### Level 4: Build
Run the build command to verify the project compiles/bundles.

**Expected**: Build succeeds without errors.

### 3. Summary Report

```
## Validation Results

| Check       | Status | Details              |
|-------------|--------|----------------------|
| Lint        | ✅/❌  | [output summary]     |
| Type Check  | ✅/❌  | [output summary]     |
| Tests       | ✅/❌  | [X passed, Y failed] |
| Build       | ✅/❌  | [output summary]     |

**Overall: ✅ PASS / ❌ FAIL**
```

### 4. If Failures Detected

For each failure:
- Identify the root cause
- Describe the fix. Do NOT apply fixes automatically — run `/code-review-fix` or fix manually, then re-run `/validate`.

Do NOT silently skip failing checks.
