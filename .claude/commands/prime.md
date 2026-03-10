---
description: Load and understand codebase context
allowed-tools: Read, Glob, Grep, Bash(git:*)
---

# Prime: Load Project Context

## Objective

Build comprehensive understanding of the codebase by analyzing structure, documentation, and key configuration.

## Process

### 1. Analyze Project Structure

List all tracked files and directory structure:
!`git ls-files`

### 2. Detect Tech Stack

Read configuration files to identify the stack:

**Check for (read whichever exist):**
- `package.json` — Node.js/JavaScript/TypeScript project
- `pyproject.toml` or `requirements.txt` — Python project
- `Cargo.toml` — Rust project
- `go.mod` — Go project
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
- Main entry points (`src/index.ts`, `app/main.py`, `main.go`, etc.)
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
