# Customization Guide

## Adding Custom Rules

### Auto-Loaded Rules

Place `.md` files in `.claude/rules/` — they're automatically loaded into every conversation.

```
.claude/rules/
  my-custom-rule.md     # Loaded for all files
  backend/
    api-rules.md        # Loaded only when working in backend/
```

**Tips:**
- Keep rules concise and actionable
- Use imperative language: "Use X" not "You should consider using X"
- Include examples of correct and incorrect patterns
- Reference project-specific conventions

### Path-Targeted Rules

Create subdirectories matching your source paths:

```
.claude/rules/
  frontend/             # Rules active when editing frontend/ files
    react-rules.md
  backend/              # Rules active when editing backend/ files
    python-rules.md
  mobile/               # Rules active when editing mobile/ files
    rn-rules.md
```

### Rule Template

```markdown
# Rule Name

## [Topic]

- [Specific instruction]
- [Specific instruction]
- [Specific instruction with example]

## [Another Topic]

- [Specific instruction]

## Examples

### Correct
[code example]

### Incorrect
[code example]
```

---

## Adding Custom Commands

### Slash Commands

Place `.md` files in `.claude/commands/`:

```
.claude/commands/
  my-command.md         # Available as /my-command
  deploy.md             # Available as /deploy
  category/
    sub-command.md      # Available as /sub-command (namespaced directory)
```

### Command Frontmatter

Commands use YAML frontmatter to configure behavior:

```yaml
---
description: Brief description shown in command list
argument-hint: <required-arg> [optional-arg]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---
```

**Fields:**
- **description** (required) — Shown in autocomplete and command list
- **argument-hint** — Shows expected arguments after the command name
- **allowed-tools** — Restricts which tools Claude can use. If omitted, all tools are available

### Allowed Tools Reference

Common tool restrictions for commands:

| Pattern | What It Allows |
|---------|---------------|
| `Read, Glob, Grep` | Read-only exploration |
| `Read, Glob, Grep, Bash(git:*)` | Read-only + git commands |
| `Read, Write, Glob, Grep` | File operations, no bash |
| `Read, Write, Edit, Bash, Glob, Grep` | Full file + bash access |
| `Read, Write, Edit, Bash, Glob, Grep, Agent` | Full access + subagent delegation |

### Namespaced Commands

Group related commands in subdirectories:

```
.claude/commands/
  bugfix/
    rca.md              # Available as /rca
    fix.md              # Available as /fix
  deploy/
    staging.md          # Available as /staging
    production.md       # Available as /production
```

### Command Template

```markdown
---
description: Brief description shown in command list
argument-hint: <required-arg> [optional-arg]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Command Name: $ARGUMENTS

## Purpose
What this command does.

## Process

### Step 1: [Name]
Instructions for step 1.

### Step 2: [Name]
Instructions for step 2.

## Output
What to report when done.
```

**Key elements:**
- `$ARGUMENTS` — Replaced with whatever the user types after the command
- Use `!` prefix for shell commands that should be executed: `!git status`

---

## Adding Custom Skills

### Skill Structure

```
.claude/skills/
  my-skill/
    SKILL.md            # Skill definition (required, <160 lines)
    references/         # Deep detail docs (200-400 lines each)
      patterns.md
      cookbook.md
```

### Progressive Depth Pattern

Skills use two layers to manage context efficiently:

**SKILL.md** (overview layer):
- Under 160 lines — this is loaded whenever the skill activates
- Contains: when to use, key patterns, decision frameworks
- Focused on actionable guidance, not exhaustive reference

**references/** (detail layer):
- 200-400 lines per file — loaded only when deep knowledge is needed
- Contains: cookbooks, catalogs, step-by-step guides, examples
- Claude reads these on demand when the overview isn't sufficient

**When to put content where:**
- If Claude needs it every time the skill activates → SKILL.md
- If Claude needs it only for specific sub-tasks → references/

### Skill Template

```markdown
---
name: skill-name
description: When and how this skill should be used. Be specific about scenarios
  where this skill applies. Claude uses this to decide when to activate the skill.
---

# Skill Name

## Overview
What this skill teaches Claude to do.

## When to Use This Skill
- Scenario 1 where this applies
- Scenario 2 where this applies

## Patterns

### Pattern 1: [Name]
[Detailed instructions with examples]

### Pattern 2: [Name]
[Detailed instructions with examples]

## Anti-Patterns
- What NOT to do
```

**Tips:**
- The `description` field is critical — Claude uses it to decide when to activate the skill
- Be specific about scenarios in the description
- Include concrete examples, not abstract principles
- Keep SKILL.md under 160 lines — use references/ for depth

### Advanced Skill Frontmatter

Beyond `name` and `description`, skills support these additional frontmatter fields:

| Field | Type | Effect |
|-------|------|--------|
| `argument-hint` | `string` | Shows expected arguments (e.g., `<component-name>`) |
| `disable-model-invocation` | `boolean` | When `true`, skill is manual-only — Claude won't auto-detect it |
| `user-invocable` | `boolean` | When `false`, skill is background knowledge only (no `/skill-name`) |
| `allowed-tools` | `string[]` | Restricts which tools Claude can use when skill is active |
| `model` | `string` | Override model (e.g., `sonnet` for cheaper execution) |
| `context` | `string` | Set to `fork` to run skill in an isolated subagent context |
| `agent` | `string` | Delegate skill execution to a specific subagent |
| `hooks` | `object` | Skill-scoped hooks that only run when this skill is active |

### Installing Community Skills

Skills follow the [Agent Skills](https://agentskills.io) open standard and can be installed across 40+ AI agents. Browse the skill directory and leaderboard at [skills.sh](https://skills.sh).

**npx skills CLI** (recommended — works across Claude Code, Cursor, Codex, Copilot, and 40+ agents):
```bash
npx skills add vercel-labs/agent-skills          # Install all Vercel skills
npx skills add anthropics/skills                 # Install all Anthropic skills
npx skills add anthropics/skills -s skill-creator  # Install specific skill
npx skills find "testing"                        # Search for skills
npx skills list                                  # List installed skills
npx skills remove skill-name                     # Uninstall a skill
npx skills check                                 # Check for updates
npx skills init my-skill                         # Create new SKILL.md template
```

**Plugin Marketplace** (Claude Code native):
```bash
/plugin marketplace add anthropics/skills                      # Register repo
/plugin install document-skills@anthropic-agent-skills         # Install plugin
/plugin list                                                   # List installed
```

**Manual Installation:**
Copy a skill directory into `.claude/skills/` (project) or `~/.claude/skills/` (global):
```
.claude/skills/
  community-skill/
    SKILL.md
    references/
      cookbook.md
```

**Using the Skill Creator:**
Use the `/creating-skills` core skill or install Anthropic's official `skill-creator` (`npx skills add anthropics/skills -s skill-creator`) for a full eval-driven workflow with automated description optimization.

**Key Ecosystems:**
- **[anthropics/skills](https://github.com/anthropics/skills)** — Official Anthropic skills: frontend-design, skill-creator, webapp-testing, PDF/DOCX/XLSX, claude-api, mcp-builder
- **[vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)** — react-best-practices (40+ rules), web-design-guidelines (100+ rules), composition-patterns
- **[obra/superpowers](https://github.com/obra/superpowers)** — Complete dev workflow with TDD, debugging, and 20+ battle-tested skills
- **[travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills)** — Curated directory of community skills across all domains

---

## Custom Subagents

### Agent File Format

Create `.md` files in `.claude/agents/` with YAML frontmatter:

```markdown
---
name: my-agent
description: >
  Detailed description of when and how to use this agent. Claude uses this
  to decide when to delegate to the agent. Include example scenarios.
model: sonnet
memory: project
tools:
  - Read
  - Glob
  - Grep
  - Bash(git log*)
  - Bash(ls *)
maxTurns: 15
color: blue
skills:
  - relevant-skill
---

# Role

You are a **[role name]** — [one-line description of what this agent does].

# Process

1. **Step 1** — [what to do first]
2. **Step 2** — [what to do next]
3. **Step 3** — [final step]

# Guidelines

- [Specific constraint or best practice]
- [Another constraint]

# Output Format

[Define the exact structure of what this agent returns]
```

### Available Models

| Model | Best For | Trade-offs |
|-------|----------|------------|
| `haiku` | Read-only exploration, pattern discovery, simple questions | Fast, cheap. Lower reasoning capability. |
| `sonnet` | Complex analysis, planning, code review, debugging | Better reasoning. Slower, more expensive. |

### Optional Frontmatter Fields

| Field | Type | Effect |
|-------|------|--------|
| `memory` | `string` | Enables cross-session persistence. Set to `project` for agents that benefit from accumulated knowledge (planner, code-reviewer, investigator). Omit for ephemeral agents (researcher, validator). |
| `color` | `string` | Terminal color for the agent's output (e.g., `red`, `orange`, `blue`). Helps distinguish agents visually. |
| `skills` | `string[]` | Skills available to this agent (e.g., `planning`, `debugging`). |

### Tool Restrictions

Choose tools carefully — they define what the agent can and cannot do:

- **Read-only agents**: `Read, Glob, Grep, Bash(git log*), Bash(ls *)` — safe for parallel research
- **Planning agents**: Add `Write` — can save plans but not modify source code
- **Validation agents**: Add `Bash(npm test*), Bash(npx tsc*)` etc. — can run checks but not edit
- **Never give an agent**: unrestricted `Bash` + `Write` + `Edit` together (security risk)

### Agent Template

Use this as a starting point for new agents:

```markdown
---
name: agent-name
description: >
  One paragraph describing when to use this agent. Include 2-3 example
  scenarios. Be specific enough for Claude to match tasks to this agent.
model: sonnet
tools:
  - Read
  - Glob
  - Grep
maxTurns: 15
---

# Role

You are a **[role]** — [purpose]. You [key constraint: never modify code / only write to .plans/ / etc.].

# Process

1. **[Phase 1]** — [instructions]
2. **[Phase 2]** — [instructions]
3. **[Phase 3]** — [instructions]

# Guidelines

- **[Principle]**: [explanation]
- **[Principle]**: [explanation]

# Output Format

[Define the exact structure the agent should return]
```

---

## Custom Templates

### How Templates Work

Templates in `templates/` are framework-specific rules and skills that get copied into `.claude/rules/` and `.claude/skills/` during `/setup`. They provide specialized guidance for your tech stack.

### Adding a Rule Template

1. Create a `.md` file in `templates/rules/`:
   ```
   templates/rules/my-framework.md
   ```
2. Follow the same format as existing templates — framework-specific conventions, patterns, and anti-patterns
3. Update `/setup` command to detect your framework and offer the template

**Naming convention**: Use the framework name in lowercase: `nextjs.md`, `fastapi.md`, `cli-tool.md`

### Adding a Skill Template

1. Create a directory in `templates/skills/`:
   ```
   templates/skills/my-skill/
     SKILL.md
     references/
       cookbook.md
   ```
2. Follow the progressive depth pattern — overview in SKILL.md, detail in references/
3. Update `/setup` to offer the skill for relevant frameworks

### Available Rule Templates

| Template | Framework | Key Topics |
|----------|-----------|------------|
| `nextjs.md` | Next.js 15+ | App Router, Server/Client Components, React 19, Tailwind v4 |
| `fastapi.md` | FastAPI 0.115+ | Pydantic 2.x, SQLAlchemy 2.0, async patterns, Python 3.12+ |
| `cli-tool.md` | CLI apps | Argument parsing, output formatting, exit codes |
| `ai-agents.md` | AI/LLM | Tool design, prompt engineering, MCP integration |
| `hono.md` | Hono 4.x+ | Edge-first API patterns, middleware, TypeScript |
| `react-native.md` | React Native / Expo | Expo SDK 52+, React Native 0.76+ |

### Available Skill Templates

| Template | Source | Focus |
|----------|--------|-------|
| `vercel-react-best-practices/` | vercel-labs/agent-skills | React/Next.js perf (40+ rules, 208K installs) |
| `vercel-composition-patterns/` | vercel-labs/agent-skills | Component composition that scales |
| `nextjs-app-router-patterns/` | wshobson/agents | Next.js 15+ App Router patterns (8.3K installs) |
| `fastapi-templates/` | wshobson/agents | FastAPI route patterns (6.4K installs) |
| `python-performance-optimization/` | wshobson/agents | Python performance (8.9K installs) |
| `python-testing-patterns/` | wshobson/agents | Python testing patterns (7.1K installs) |
| `api-design/` | supercent-io/skills-template | REST API design patterns (10.8K installs) |
| `database-schema-design/` | supercent-io/skills-template | Schema design, migrations (11K installs) |
| `agent-development/` | Custom | Tool design, prompt engineering, MCP |
| `edge-api/` | Custom | Edge API patterns |

### How /setup Discovers Templates

`/setup` maps frameworks to templates:

| Detected Framework | Rule Template | Skill Templates |
|--------------------|---------------|-----------------|
| Next.js | `nextjs.md` | `vercel-react-best-practices/`, `vercel-composition-patterns/`, `nextjs-app-router-patterns/` |
| FastAPI | `fastapi.md` | `api-design/`, `database-schema-design/`, `fastapi-templates/`, `python-performance-optimization/` |
| CLI tool | `cli-tool.md` | — |
| AI Agent | `ai-agents.md` | `agent-development/` |

Users can also select additional skill templates (database, API design, agent development, python testing) regardless of framework. The `python-testing-patterns/` skill is offered to all Python stacks during Phase B of setup.

---

## Configuring MCP Servers

### Adding MCP Servers

Edit `.mcp.json` at the project root and add to the `mcpServers` section:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server-package"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

### Using MCP Templates

The starter kit includes 7 pre-configured templates in `.claude/mcp-templates/`:

| Template | Purpose | Required Env Vars |
|----------|---------|-------------------|
| `fetch.json` | Web content fetching | None |
| `filesystem.json` | Extended file operations | None |
| `github.json` | GitHub API integration | `GITHUB_TOKEN` |
| `memory.json` | Persistent memory across sessions | None |
| `playwright.json` | Browser automation & UI testing | None |
| `postgres.json` | Direct PostgreSQL access | `DB_URL` or connection params |
| `supabase.json` | Supabase database management | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` |

**To enable a template manually:**

1. Read the template: `.claude/mcp-templates/playwright.json`
2. Copy the `config.mcpServers` section into `.mcp.json` at the project root
3. Set any required environment variables

Or use `/setup` to configure them interactively.

---

## Customizing Hooks

### Included Hooks

Only `block-dangerous-commands.sh` is active by default. The other 4 hooks are available in `.claude/hooks/` and can be enabled by adding them to `.claude/settings.json`.

**PreToolUse — Block Dangerous Commands** (`.claude/hooks/block-dangerous-commands.sh`) — **Active by default**
- Blocks destructive shell commands (rm -rf /, force push, DROP TABLE, pipe-to-shell, fork bombs)
- Prompts for confirmation on sensitive file access (.env, .pem, credentials)
- Receives JSON on stdin with `tool_name` and `tool_input`

**PreToolUse — Branch Protection** (`.claude/hooks/branch-protection.sh`) — **Opt-in**
- Warns when Write/Edit operations are attempted on `main` or `master` branch
- Prompts user to create a feature branch first
- Note: This prompts on every file edit while on main, which can be noisy for solo developers

**PostToolUse — Auto-Format** (`.claude/hooks/auto-format.sh`) — **Opt-in**
- Auto-formats files after Write/Edit operations
- Detects project formatter from config files (Biome, Prettier, Ruff)
- Note: Requires a formatter to be installed — runs `npx` on every edit which adds latency

**PostToolUse — Auto-Lint** (`.claude/hooks/auto-lint.sh`) — **Opt-in**
- Runs linter on files after Write/Edit operations (separate from formatting)
- Detects project linter: Biome, ESLint (JS/TS) or Ruff (Python)
- Note: Requires a linter to be installed — adds latency after every edit

### Hook Configuration in settings.json

Hooks are configured in `.claude/settings.json` using this format:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-dangerous-commands.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

To enable optional hooks, add entries to the appropriate event arrays:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": ".claude/hooks/block-dangerous-commands.sh", "timeout": 5000 }]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": ".claude/hooks/branch-protection.sh", "timeout": 5000 }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/auto-format.sh", "timeout": 30000 },
          { "type": "command", "command": ".claude/hooks/auto-lint.sh", "timeout": 30000 }
        ]
      }
    ],
}
}
```

**Configuration fields:**
- **matcher** — Tool name pattern to match (e.g., `"Bash"`, `"Write|Edit"`, `"Read"`)
- **type** — Always `"command"` for shell script hooks
- **command** — Path to the hook script (relative to project root)
- **timeout** — Maximum execution time in milliseconds

### Hook Output Format

PreToolUse hooks must return JSON with the `hookSpecificOutput` wrapper:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow"
  }
}
```

Valid `permissionDecision` values:
- `"allow"` — Let the tool execute
- `"deny"` — Block the tool (add `"permissionDecisionReason"` to explain why)
- `"ask"` — Prompt the user for confirmation

PostToolUse hooks don't need to return a permission decision — they run after the tool completes.

### Adding New Hooks

1. Create a bash script in `.claude/hooks/`:
   ```bash
   #!/bin/bash
   # Read JSON input from stdin
   INPUT=$(cat)
   TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
   TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')

   # Your logic here...

   # Return decision (PreToolUse only)
   echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
   ```
2. Make it executable: `chmod +x .claude/hooks/my-hook.sh`
3. Register it in `.claude/settings.json` under the appropriate event

---

## Configuring .claudeignore

### What Is .claudeignore?

`.claudeignore` works like `.gitignore` but for Claude Code's context window. Files matching patterns in `.claudeignore` are excluded when Claude scans your project, saving significant context budget.

### Default Exclusions

The starter kit's `.claudeignore` excludes:
- **Dependencies**: `node_modules/`, `.venv/`, `__pycache__/`
- **Build artifacts**: `dist/`, `build/`, `.next/`, `coverage/`
- **Generated files**: `*.min.js`, `*.map`, lock files (`pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`)
- **IDE/Editor files**: `.idea/`, `.vscode/`, swap files
- **Large binaries**: images, fonts, media, PDFs

### Customizing

Add project-specific patterns to `.claudeignore` at the project root:

```gitignore
# Project-specific exclusions
data/fixtures/large-dataset.json
generated/
*.sqlite
```

### Impact

For a typical Node.js project, `.claudeignore` saves 30-100K tokens by excluding `node_modules/`, lock files, and build output from context.

---

## Modifying CLAUDE.md

### @imports

CLAUDE.md uses `@` imports to include rule files:

```markdown
@.claude/rules/code-quality.md
@.claude/rules/my-custom-rule.md
```

Add imports for any new rule files you create.

### Template Sections

After running `/setup`, the template sections in CLAUDE.md are populated. You can edit them manually at any time:

- **Tech Stack**: Add or change technologies
- **Development Commands**: Update commands as your project evolves
- **Key Directories**: Update as project structure changes
