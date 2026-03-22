# Migration Guide

Integrate the Claude Code Starter Kit into an existing project.

> **New project?** See [Getting Started](./GETTING-STARTED.md) instead — it covers greenfield setup from scratch.

---

## Decision Table

| What You Have | Migration Path |
|---------------|----------------|
| Nothing (no `.claude/` directory) | Follow the **Full Migration** below |
| CLAUDE.md only | Follow the **Full Migration**, merge your CLAUDE.md at Step 5 |
| Some rules + commands already | Follow **Cherry-Picking** to add what you're missing |
| Full custom setup | Review **Cherry-Picking** for specific components you want |

---

## Full Migration (9 Steps)

### Step 1: Get the Starter Kit

```bash
# Clone to a temporary directory
git clone https://github.com/medevs/claude-code-starter-kit.git /tmp/claude-starter-kit
```

### Step 2: Copy `.claude/` Directory

```bash
# From your project root
cp -r /tmp/claude-starter-kit/.claude/ .claude/
cp /tmp/claude-starter-kit/.claudeignore .claudeignore
```

The `.claudeignore` file excludes dependencies, build artifacts, and binaries from Claude's context window — saving 30-100K tokens for typical projects.

If you already have a `.claude/` directory, copy subdirectories individually to avoid overwriting your `settings.json`:

```bash
cp -r /tmp/claude-starter-kit/.claude/commands/ .claude/commands/
cp -r /tmp/claude-starter-kit/.claude/rules/ .claude/rules/
cp -r /tmp/claude-starter-kit/.claude/skills/ .claude/skills/
cp -r /tmp/claude-starter-kit/.claude/agents/ .claude/agents/
cp -r /tmp/claude-starter-kit/.claude/hooks/ .claude/hooks/
```

### Step 3: Merge Rules

If you have existing rules in `.claude/rules/`:

1. Compare your rules with the starter kit rules
2. Keep your project-specific rules
3. Add starter kit rules that you're missing (see **Priority Rules** below)
4. Remove duplicates — prefer the starter kit version for standard topics

**Priority rules to add** (in order of impact):
1. `ai-workflow.md` — Optimizes how Claude works (JIT reading, delegation, context management)
2. `testing.md` — Test standards (AAA pattern, naming, coverage)
3. `security.md` — OWASP, secrets, input validation

### Step 4: Merge `settings.json`

If you have an existing `.claude/settings.json`:

```bash
# Back up your current settings
cp .claude/settings.json .claude/settings.json.backup
```

Merge manually — the starter kit's `settings.json` includes:
- **Permission tiers**: `allow`, `ask`, `deny` lists for tool access
- **Hook definitions**: PreToolUse and PostToolUse hooks
- **MCP server configs**: Optional integrations

Keep your existing permissions and add any missing hook definitions from the starter kit.

### Step 5: Merge CLAUDE.md

If you have an existing `CLAUDE.md`:

1. **Keep** your project-specific sections: Tech Stack, Dev Commands, Key Directories
2. **Add** the `@.claude/rules/` imports from the starter kit's CLAUDE.md
3. **Add** the Core Principles section if you don't have equivalent guidance
4. Keep total length under 200 lines — use `@imports` for details

Example merge:
```markdown
# Project Rules

@.claude/rules/code-quality.md
@.claude/rules/testing.md
@.claude/rules/git-workflow.md
@.claude/rules/security.md
@.claude/rules/architecture.md
@.claude/rules/ai-workflow.md

## Core Principles
<!-- From starter kit -->

## Tech Stack
<!-- Your existing content -->

## Dev Commands
<!-- Your existing content -->

## Key Directories
<!-- Your existing content -->
```

### Step 6: Copy Templates

```bash
cp -r /tmp/claude-starter-kit/templates/ templates/
```

Then run `/setup` to apply the right framework-specific templates for your stack.

### Step 7: Copy Docs

```bash
cp -r /tmp/claude-starter-kit/docs/ docs/claude-code/
```

Or copy to your existing docs directory. These are reference docs — adjust the path as needed.

### Step 8: Verify

```bash
claude
/prime
```

Verify that `/prime` shows:
- ✅ All rules loaded
- ✅ All 16 commands available
- ✅ Skills detected
- ✅ Subagents listed
- ✅ Your project's tech stack and conventions recognized

If something is missing, check the [Troubleshooting](#troubleshooting) section below.

### Step 9: Clean Up

```bash
rm -rf /tmp/claude-starter-kit
```

Commit the integration:
```bash
git add .claude/ .claudeignore CLAUDE.md templates/ docs/
git commit -m "chore: integrate claude-code-starter-kit"
```

---

## Cherry-Picking

Take only what you need. Each component is independent.

### Just Commands

```bash
cp -r /tmp/claude-starter-kit/.claude/commands/ .claude/commands/
```

You get all 16 slash commands. Commands reference rules and agents, so you may want those too.

### Just Hooks

```bash
cp -r /tmp/claude-starter-kit/.claude/hooks/ .claude/hooks/
```

You get all 5 hook scripts. Only `block-dangerous-commands.sh` is active by default. Enable the others (branch protection, auto-formatter, auto-linter, completion notifier) by adding them to `.claude/settings.json` — see [Customization](./CUSTOMIZATION.md) for examples.

### Just Rules

```bash
cp -r /tmp/claude-starter-kit/.claude/rules/ .claude/rules/
```

Add `@.claude/rules/<name>.md` imports to your CLAUDE.md for each rule you want active.

### Just the Core Workflow

Copy only the 5 core commands + the build pipeline:

```bash
for cmd in prime plan execute validate commit build; do
  cp /tmp/claude-starter-kit/.claude/commands/$cmd.md .claude/commands/
done
```

### Just Subagents

```bash
cp -r /tmp/claude-starter-kit/.claude/agents/ .claude/agents/
```

Subagents are used by commands that have `Agent` in their allowed-tools. They work independently of other components.

### Just Skills

```bash
cp -r /tmp/claude-starter-kit/.claude/skills/ .claude/skills/
```

Skills are auto-detected by Claude Code — no additional configuration needed.

---

## Troubleshooting

### Conflicting Rules

**Symptom**: Claude follows inconsistent conventions.

**Fix**: Check for duplicate or contradictory guidance between your existing rules and the starter kit rules. Remove duplicates. For conflicts, keep one version — prefer whichever is more specific to your project.

### Missing Agents

**Symptom**: Commands that delegate to agents (plan, review, rca, fix, refactor, test) don't use subagents.

**Fix**: Ensure `.claude/agents/` contains the agent files (`researcher.md`, `planner.md`, `code-reviewer.md`, `validator.md`, `investigator.md`). Commands will work without agents — they just won't parallelize research.

### Settings Merge Issues

**Symptom**: Hooks don't fire, permissions are wrong, or MCP servers don't connect.

**Fix**: Compare your `.claude/settings.json` with the starter kit version. The most common issue is missing hook registrations. Back up your settings and merge carefully — don't overwrite your existing permissions.

### CLAUDE.md Too Long

**Symptom**: Claude seems to ignore some rules or context.

**Fix**: Keep CLAUDE.md under 200 lines. Move detailed guidance into `.claude/rules/` files and use `@imports`. The starter kit's CLAUDE.md is a minimal shell that imports everything via `@.claude/rules/<name>.md`.

### Commands Not Appearing

**Symptom**: `/refactor` or `/test` don't show in autocomplete.

**Fix**: Verify the command files exist in `.claude/commands/` with valid YAML frontmatter (must have `description` field). Restart Claude Code.

---

## Next Steps

After migration:

1. **Run `/setup`** to detect your tech stack and apply framework-specific templates
2. **Run `/prime`** to verify everything is loaded correctly
3. **Try `/build <small-feature>`** to test the full pipeline
4. **Read [Customization](./CUSTOMIZATION.md)** to adapt rules, commands, and skills to your project
