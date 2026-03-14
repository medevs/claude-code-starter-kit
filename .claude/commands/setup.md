---
description: Interactive project initialization wizard — configure tech stack, rules, skills, and commands
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Setup: Project Initialization Wizard

## Objective

Configure this starter kit for your specific project. This wizard will populate CLAUDE.md, copy relevant template rules and skills, and verify the setup.

## Process

### Step 1: Detect or Ask Tech Stack

**Auto-detect first** by checking for existing config files:
- `package.json` → Node.js project (check for Next.js, React, etc.)
- `pyproject.toml` / `requirements.txt` → Python project (check for FastAPI, Flask)
- `tsconfig.json` → TypeScript enabled

**If no config files found or ambiguous, ask the user:**

**Phase A: Primary framework (exactly one)**
> What are you building?
> 1. **Next.js web app** (React, App Router, Tailwind)
> 2. **FastAPI backend** (Python, async, SQLAlchemy)
> 3. **CLI tool** (Node.js or Python command-line application)
> 4. **AI Agent** (LLM-powered, JS/TS or Python)
> 5. **Custom** (JS/TS or Python — I'll specify)

**Phase B: Additional capabilities (zero or more)**
> Would you like to add any additional skill sets?
> - [ ] **Database patterns** (schema design, migrations, query optimization)
> - [ ] **API design patterns** (REST conventions, pagination, error handling)
> - [ ] **AI agent patterns** (tool design, prompt engineering, MCP)

### Step 2: Identify Architecture

**Ask the user:**
> What architecture pattern do you prefer?
> 1. **Vertical Slice Architecture** (recommended — organize by feature)
> 2. **Clean Architecture** (layers: domain, application, infrastructure)
> 3. **Simple/Flat** (for small projects — minimal structure)

### Step 3: Detect Package Manager & Tools

**Auto-detect:**
- Lock files: `pnpm-lock.yaml` → pnpm, `bun.lockb` → bun, `package-lock.json` → npm, `uv.lock` → uv, `yarn.lock` → yarn
- Test config: `vitest.config.*` → Vitest, `jest.config.*` → Jest, `pytest.ini` or `pyproject.toml[tool.pytest]` → pytest
- Lint config: `biome.json` → Biome, `.eslintrc*` → ESLint, `pyproject.toml[tool.ruff]` → Ruff

**If not detected, ask the user for each.**

### Step 4: Ask About MCP Servers (Optional)

> Would you like to enable any MCP server integrations?
> - [ ] **Playwright** — Browser automation & UI testing
> - [ ] **Supabase** — Database management
> - [ ] **GitHub** — GitHub API integration
> - [ ] **PostgreSQL** — Direct database access
> - [ ] **Memory** — Persistent memory across sessions
> - [ ] **Fetch** — Web content fetching
> - [ ] **Filesystem** — Extended file operations
> - [ ] **None for now** (can add later)

### Step 5: Execute Setup

Based on answers, perform these actions:

**a. Populate CLAUDE.md**
Edit the template sections in CLAUDE.md:
- Fill in Tech Stack, Architecture, Package Manager, Test Framework, Lint/Format
- Fill in Development Commands (install, dev, test, lint, typecheck, build)
- Fill in Key Directories (source, tests, config)

**b. Copy Matching Template Rules**
Based on the detected/chosen stack, copy relevant templates from `templates/rules/` to `.claude/rules/`:
- Next.js project → copy `templates/rules/nextjs.md` → `.claude/rules/nextjs.md`
- FastAPI project → copy `templates/rules/fastapi.md` → `.claude/rules/fastapi.md`
- CLI tool → copy `templates/rules/cli-tool.md` → `.claude/rules/cli-tool.md`
- AI Agent → copy `templates/rules/ai-agents.md` → `.claude/rules/ai-agents.md`

Then add the `@import` for the copied rule file to CLAUDE.md.

**c. Copy Matching Template Skills**
Based on the stack and Phase B selections, copy skill templates to `.claude/skills/`:

**Default combinations (auto-included with primary framework):**
- Next.js → `react-patterns/`
- FastAPI → `api-design/` + `database/`
- CLI tool → (no default skills)
- AI Agent → `agent-development/`

**Phase B additions (user-selected, additive):**
- Database patterns → `database/`
- API design patterns → `api-design/`
- AI agent patterns → `agent-development/`

Deduplicate: if a skill is already included by the primary framework default, don't copy it twice.

**d. Configure MCP Servers (if selected)**
Read the selected MCP template(s) from `.claude/mcp-templates/` and merge their config into `.mcp.json` at the project root.

**e. Initialize Project Structure**
If starting fresh (no existing source code):
- Create recommended directory structure based on chosen architecture
- Create `.plans/` directory for plan files
- Initialize git if not already initialized
- Create `.gitignore` if it doesn't exist

**f. Install Dependencies (if applicable)**
Run the appropriate install command if package manager is configured.

### Step 6: Verify

Run `/prime` to verify everything loaded correctly:
- Confirm CLAUDE.md is populated
- Confirm rules are loading
- Confirm skills are detected
- Confirm commands are available

## Output

```markdown
### Setup Complete ✅

**Project Configuration:**
- Tech Stack: [detected/chosen stack]
- Architecture: [chosen pattern]
- Package Manager: [detected/chosen]
- Test Framework: [detected/chosen]
- Lint/Format: [detected/chosen]

**Files Modified:**
- `CLAUDE.md` — Populated with project config
- `.claude/rules/` — [X] rule files active
- `.claude/skills/` — [X] skills available
- `.claude/settings.json` — [MCP servers if any]

**Available Commands:**
- `/prime` — Load codebase context
- `/plan <feature>` — Create implementation plan
- `/execute <plan-path>` — Implement from plan
- `/validate` — Run all checks
- `/commit` — Create atomic commit
- `/build <feature>` — End-to-end pipeline
- `/create-prd <filename>` — Generate PRD
- `/review` — Code review
- `/execution-report` — Post-implementation reflection
- `/code-review-fix <review-file>` — Fix issues from a code review
- `/rca <issue-id>` — Root cause analysis
- `/fix <issue-id>` — Implement fix from RCA

**Next Steps:**
1. Review CLAUDE.md and adjust if needed
2. Start building: `/build <your-first-feature>`
```
