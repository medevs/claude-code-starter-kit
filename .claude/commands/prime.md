---
description: Load and understand codebase context (optionally scoped to a specific area)
argument-hint: [scope]
allowed-tools: Read, Glob, Grep, Bash(git:*)
---

# Prime: Load Project Context

## Scope

**Scope**: $ARGUMENTS

- If a scope is provided (e.g., `frontend`, `api`, `auth`), focus priming on that area — read only files, entry points, and patterns relevant to the scope. Still read CLAUDE.md and project-level config, but skip unrelated directories.
- If no scope is provided, perform full project priming.

### Scoped Priming Guidelines

When a scope is provided:
- **Always read**: `CLAUDE.md` and any `.claude/rules/` files that match the scope (e.g., `.claude/rules/api/` for `api` scope)
- **Focus on**: Entry points, key modules, and patterns within the scoped directory
- **Skip**: Unrelated directories, test fixtures for other features, unrelated config
- **Common scopes**: `frontend`, `api`, `backend`, `database`, `auth`, `testing`, `infra`

Use scoped priming when you need depth in one area. Use full priming when you need breadth across the whole project.

## Objective

Build comprehensive understanding of the codebase by analyzing structure, documentation, and key configuration.

## Process

### 1. Analyze Project Structure

List all tracked files and directory structure:
!`git ls-files`

Show directory structure (depth 3):
!`find . -maxdepth 3 -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/__pycache__/*' -not -path '*/build/*' | head -80`

If a scope was provided, filter the above to focus on directories and files matching the scope.

### 2. Detect Tech Stack

Read configuration files to identify the stack:

**Check for (read whichever exist):**
- `package.json` — Node.js/JavaScript/TypeScript project
- `pyproject.toml` or `requirements.txt` — Python project
- `tsconfig.json` — TypeScript configuration
- `biome.json` or `.eslintrc*` — Linting setup
- `vitest.config.*` or `jest.config.*` or `pytest.ini` — Test framework
- `docker-compose.yml` or `Dockerfile` — Container setup

### 3. Read Core Documentation

- Read `CLAUDE.md` (project rules and context)
- Read `README.md` at project root
- Check for `.plans/` directory — read any existing plans or PRDs
- Check for `docs/` directory — scan for architecture docs

### 4. Identify Key Files

Based on detected stack, read:
- Main entry points (`src/index.ts`, `app/main.py`, etc.)
- Core configuration files
- Key model/schema definitions
- Router or API definitions

### 5. Understand Current State

!`git log -10 --oneline`
!`git status`
!`git branch -a`

### 6. Check Available Tools

- List available slash commands in `.claude/commands/`
- List available skills in `.claude/skills/`
- Check for MCP server configurations

## Output

Provide a structured summary:

### Project Overview
- Purpose and type of application
- Primary technologies and frameworks
- Current version/state

### Architecture
- Overall structure and organization pattern
- Key directories and their purposes
- Important architectural decisions

### Tech Stack
- Languages and versions
- Frameworks and major libraries
- Build tools and package managers
- Testing frameworks
- Linting/formatting tools

### Core Principles
- Code style and conventions observed
- Documentation standards in use
- Testing approach and patterns

### Development Commands
- How to install, run, test, lint, build

### Current State
- Active branch and recent changes
- Any in-progress work or plans
- Available commands and skills

### Observations
- Notable patterns or conventions
- Potential areas of concern
- Suggestions for next steps

## Next Steps

- **Have a feature to build?** → `/plan <feature>`
- **Want the full pipeline?** → `/build <feature>`
- **Just exploring?** → Use the researcher agent for targeted questions
- **Need depth in a specific area?** → `/prime <scope>` (e.g., `/prime frontend`)
