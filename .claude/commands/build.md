---
description: End-to-end feature development pipeline (prime -> plan -> execute -> validate -> commit)
argument-hint: <feature-description>
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
---

# Build: End-to-End Feature Development

**Feature**: $ARGUMENTS

This command chains the core workflow for autonomous feature development from planning to commit.

---

## Step 1: Prime — Load Codebase Context

Execute the priming workflow to understand the codebase:

.claude/commands/prime.md

**Gate**: Must have clear understanding of the project before proceeding.

---

## Step 2: Plan — Create Implementation Plan

Create a detailed implementation plan for the feature.

.claude/commands/plan.md
Replace `ARGUMENTS` in the planning command with: **$ARGUMENTS**

**Gate**: Plan must have a confidence score of 7+/10. If lower, refine before proceeding.

---

## Step 3: Execute — Implement the Feature

Implement from the plan created in Step 2.

.claude/commands/execute.md
Replace `ARGUMENTS` in the execute command with: `.plans/{feature-name}.md`

**Gate**: All validation commands must pass.

---

## Step 4: Validate — Comprehensive Check

Run full validation suite to confirm implementation quality.

.claude/commands/validate.md

When the `Agent` tool is available, delegate this step to the `validator` agent for comprehensive test/lint/build verification. The validator agent runs all checks and reports results back.

**Gate**: All checks must pass with zero errors.

---

## Step 5: Commit — Save Changes

Create an atomic git commit for the completed feature.

.claude/commands/commit.md

---

## Final Summary

```markdown
### Build Complete: $ARGUMENTS

**Steps Executed:**
1. ✅ Prime — Codebase context loaded
2. ✅ Plan — Plan created at `.plans/[feature].md`
3. ✅ Execute — Feature implemented
4. ✅ Validate — All checks passing
5. ✅ Commit — Changes committed

**Outputs:**
- Plan: `.plans/[feature-name].md`
- Files created: [list]
- Files modified: [list]
- Tests added: [list]
- Commit: [hash] [message]

**Next Steps:**
- Push to remote: `git push`
- Create pull request if applicable
```
