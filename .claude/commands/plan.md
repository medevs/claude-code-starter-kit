---
description: Create comprehensive implementation plan with codebase analysis and research
argument-hint: <feature-description>
allowed-tools: Read, Write, Glob, Grep, Bash(git:*), Agent
---

# Plan: $ARGUMENTS

## Mission

Transform a feature request into a **comprehensive implementation plan** through systematic codebase analysis, research, and strategic planning.

**Core Principle**: We do NOT write code in this phase. We create a context-rich plan that enables one-pass implementation success.

**Key Philosophy**: Context is King. The plan must contain ALL information needed — patterns, mandatory reading, documentation, validation commands — so the execution agent succeeds on the first attempt.

## Planning Process

### Phase 1: Feature Understanding

- Extract the core problem being solved
- Identify user value and feature type: New Capability / Enhancement / Refactor / Bug Fix
- Assess complexity: Low / Medium / High
- Map affected systems and components

**Create User Story:**
```
As a <type of user>
I want to <action/goal>
So that <benefit/value>
```

**Problem Statement:**
<Clearly define the specific problem or opportunity this feature addresses>

**Solution Statement:**
<Describe the proposed solution approach>

### Phase 2: Codebase Intelligence Gathering

**Use sub-agents for parallel research when beneficial.** Launch the `researcher` agent for parallel codebase research when the codebase has 50+ files.

1. **Project Structure Analysis** — Detect languages, frameworks, directory patterns, config files
2. **Pattern Recognition** (Use sub-agents when beneficial)
   - Search for similar implementations in codebase
   - Identify coding conventions:
     - Naming patterns (CamelCase, snake_case, kebab-case)
     - File organization and module structure
     - Error handling approaches (typed errors vs exceptions, early returns)
     - Logging patterns and standards
   - Extract common patterns for the feature's domain
   - Document anti-patterns to avoid
   - Check CLAUDE.md and `.claude/rules/` for project-specific rules
3. **Dependency Analysis** — Catalog relevant libraries, check versions, find internal documentation
4. **Testing Patterns** — Identify test framework, find similar test examples, note coverage requirements
5. **Integration Points** — Map files needing updates, new files to create, registration patterns
6. **Stack-Specific Intelligence**:
   - **JS/TS projects**: Check `tsconfig.json` for path aliases (affects import patterns), `package.json` scripts for available dev/test/build commands, monorepo indicators (`workspaces`, `turbo.json`, `nx.json`)
   - **Python projects**: Check `pyproject.toml` for tool configs (ruff, mypy, pytest), `uv.lock` vs `requirements.txt` (determines install/run commands), `alembic/` directory (database migrations)

**If requirements are unclear, ASK the user before continuing.**

### Phase 3: External Research

**Use sub-agents for documentation gathering:**

- Research latest best practices for the technology stack
- Find official documentation with specific section links
- Locate implementation examples
- Identify common gotchas and breaking changes

**Compile Research References:**
```markdown
## Relevant Documentation
- [Library Docs](URL#section) — Why: [needed for X]
- [Framework Guide](URL#section) — Why: [shows integration pattern]
```

### Phase 4: Strategic Thinking

- How does this feature fit into the existing architecture?
- What are the critical dependencies and order of operations?
- What could go wrong? (Edge cases, race conditions, errors)
- How will this be tested comprehensively?
- Are there security or performance considerations?

### Phase 5: Generate Plan

Write the plan to `.plans/{kebab-case-feature-name}.md` using this structure:

```markdown
# Feature: <feature-name>

The following plan should be complete, but validate documentation and codebase patterns before implementing.
Pay special attention to naming of existing utils, types, and models. Import from the right files.

## Feature Description
<Detailed description, purpose, and user value>

## User Story
As a <user> I want to <goal> so that <benefit>

## Problem Statement
<Clearly define the specific problem or opportunity>

## Solution Statement
<Describe the proposed solution approach>

## Feature Metadata
- **Type**: [New Capability/Enhancement/Refactor/Bug Fix]
- **Complexity**: [Low/Medium/High]
- **Systems Affected**: [list]
- **Dependencies**: [list]

---

## MANDATORY READING

### Codebase Files (READ BEFORE IMPLEMENTING)
- `path/to/file` (lines X-Y) — Why: [reason]
- ...

### New Files to Create
- `path/to/new_file` — [purpose]
- ...

### Documentation to Reference
- [Doc name](URL#section) — Why: [reason]
- ...

### Patterns to Follow
<Actual code examples from the codebase showing naming, error handling, logging, etc.>

---

## IMPLEMENTATION PLAN

### Phase 1: Foundation
<Setup, schemas, types, interfaces>

### Phase 2: Core Implementation
<Business logic, services, endpoints>

### Phase 3: Integration
<Connect to existing code, registration, configuration>

### Phase 4: Testing & Validation
<Tests, edge cases, validation>

---

## STEP-BY-STEP TASKS

Each task is atomic and independently testable. Execute in order.

### Task Format

Use ACTION keywords for clarity:
- **CREATE**: New files or components
- **UPDATE**: Modify existing files
- **ADD**: Insert new functionality into existing code
- **REMOVE**: Delete deprecated code
- **REFACTOR**: Restructure without changing behavior
- **MIRROR**: Copy pattern from elsewhere in codebase

### Task 1: {ACTION} {target_file}
- **IMPLEMENT**: {specific detail}
- **PATTERN**: {reference to existing pattern — file:line}
- **IMPORTS**: {required imports}
- **GOTCHA**: {known issues to avoid}
- **VALIDATE**: `{executable command}`

### Task 2: ...
(continue for all tasks)

---

## TESTING STRATEGY

### Unit Tests
<Scope and requirements>

### Integration Tests
<Scope and requirements>

### Edge Cases
<Specific edge cases to test>

---

## VALIDATION COMMANDS

### Level 1: Lint & Format
<commands from CLAUDE.md>

### Level 2: Type Check
<commands from CLAUDE.md>

### Level 3: Tests
<commands from CLAUDE.md>

### Level 4: Manual Verification
<feature-specific manual testing — API calls, UI testing, CLI execution>

### Level 5: Build & Additional Validation
<Build commands and any additional checks (MCP servers, e2e tools)>

---

## ACCEPTANCE CRITERIA
- [ ] All specified functionality implemented
- [ ] All validation commands pass
- [ ] Test coverage ≥ 80% for new code
- [ ] Code follows project conventions
- [ ] No regressions

---

## COMPLETION CHECKLIST
- [ ] All tasks completed in order
- [ ] Each task validation passed
- [ ] All validation commands executed successfully
- [ ] Full test suite passes
- [ ] No linting or type checking errors
- [ ] Acceptance criteria all met
```

## Sub-Agent Delegation

When the `Agent` tool is available, delegate heavy lifting to specialized agents:

1. **Research phase** → Launch the `researcher` agent for parallel codebase intelligence gathering (structure analysis, pattern recognition, dependency mapping). Run multiple researcher agents concurrently for independent search tasks.
2. **Plan generation** → Launch the `planner` agent to draft the implementation plan structure, phased tasks, and validation commands based on research findings.

The process above remains the orchestration frame — use it standalone when agents are unavailable, or as the coordination layer when delegating to agents.

## After Plan Creation

Report:
- Summary of feature and approach
- Path to plan file
- Complexity assessment
- Key risks or considerations
- Confidence score (X/10) for one-pass implementation success

## Quality Criteria

### Context Completeness
- [ ] All necessary patterns identified and documented
- [ ] Integration points clearly mapped
- [ ] Every task has an executable validation command

### Implementation Ready
- [ ] Another agent could execute without additional context
- [ ] Tasks ordered by dependency (top-to-bottom)
- [ ] Each task is atomic and independently testable
- [ ] Pattern references include specific file:line numbers
