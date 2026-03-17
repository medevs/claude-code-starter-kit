---
description: Implement a feature from an existing plan
argument-hint: <path-to-plan-file>
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
---

# Execute: Implement from Plan

## Plan File: $ARGUMENTS

## Instructions

### 1. Read and Understand the Plan

- Read the ENTIRE plan file at `$ARGUMENTS`
- Read ALL files listed in "Mandatory Reading" section
- Understand the task dependencies and order
- Note validation commands to run after each task

### 2. Execute Tasks in Order

For EACH task in "Step-by-Step Tasks":

**a. Prepare**
- Read existing files being modified
- Check the pattern references cited in the task

**b. Implement**
- Follow specifications exactly
- Match existing codebase patterns (naming, structure, error handling)
- Include proper types, imports, and error handling

**c. Validate**
- Run the task's validation command immediately
- If it fails: fix the issue, re-run, continue only when passing

**d. Report Progress**
- After each task: "✅ Task N complete — [brief description]"

### 3. Implement Tests

After completing implementation tasks:
- Create all test files specified in the plan
- Follow the testing strategy section
- Cover edge cases listed in the plan
- Run the full test suite

### 4. Run All Validation Commands

Execute ALL validation commands from the plan in order:

**Level 1**: Lint & Format
**Level 2**: Type Check
**Level 3**: Tests
**Level 4**: Build
**Level 5**: Manual Verification

**CRITICAL**: Never skip a failing validation. Every level must pass before completion.

If any command fails:
1. Fix the issue
2. Re-run the command
3. Continue only when it passes

### 5. Final Verification

Before completing:
- ✅ All tasks from plan completed
- ✅ All tests created and passing
- ✅ All validation commands pass
- ✅ Code follows project conventions
- ✅ No regressions introduced

## Output Report

```markdown
### Execution Complete

**Plan**: [plan file path]
**Feature**: [feature name]

### Tasks Completed
1. ✅ [Task description]
2. ✅ [Task description]
...

### Files Created
- `path/to/new/file` — [purpose]

### Files Modified
- `path/to/modified/file` — [what changed]

### Tests Added
- `path/to/test/file` — [X test cases]

### Validation Results
- Lint: ✅ Pass
- Type Check: ✅ Pass
- Tests: ✅ X/X passing
- Build: ✅ Pass

### Ready for Commit
All changes validated. Run `/commit` to commit.
```

## If Issues Arise

- If the plan has errors or missing context: document and work around them
- If you need to deviate from the plan: explain the reason clearly
- Track all deviations with: Planned vs Actual vs Reason
- Deviation types: Better approach found | Plan assumption wrong | Security concern | Performance issue | Missing context
- If a test fails and the fix is non-obvious: describe the issue for review
- If blocked on external dependencies: document and continue with what's possible

## Next Steps

- **Run validation:** → `/validate` for comprehensive checks
- **Save your work:** → `/commit` (includes AI context tracking)
- **Want reflection?** → `/execution-report` for plan-vs-actual analysis
- **Session getting long?** → `/handoff` before continuing to preserve context
