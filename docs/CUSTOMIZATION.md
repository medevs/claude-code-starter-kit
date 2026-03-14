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

### How /setup Discovers Templates

`/setup` maps frameworks to templates:

| Detected Framework | Rule Template | Skill Templates |
|--------------------|---------------|-----------------|
| Next.js | `nextjs.md` | `react-patterns/` |
| FastAPI | `fastapi.md` | `api-design/`, `database/` |
| CLI tool | `cli-tool.md` | — |
| AI Agent | `ai-agents.md` | `agent-development/` |

Users can also select additional skill templates (database, API design, agent development) regardless of framework.

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

**PreToolUse — Block Dangerous Commands** (`.claude/hooks/block-dangerous-commands.sh`)
- Blocks destructive shell commands (rm -rf /, force push, DROP TABLE, pipe-to-shell, fork bombs)
- Prompts for confirmation on sensitive file access (.env, .pem, credentials)
- Receives JSON on stdin with `tool_name` and `tool_input`

**PostToolUse — Auto-Format** (`.claude/hooks/auto-format.sh`)
- Auto-formats files after Write/Edit operations
- Detects project formatter from config files (Biome, Prettier, Ruff)
- Non-blocking — runs after the tool completes

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
            "command": ".claude/hooks/my-hook.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/after-write.sh",
            "timeout": 30000
          }
        ]
      }
    ]
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
