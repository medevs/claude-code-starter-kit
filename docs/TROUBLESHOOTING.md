# Troubleshooting

## Common Issues

### Commands Not Appearing

**Symptom**: Running `/mycommand` returns "command not found" or doesn't show in autocomplete.

**Fix**:
1. Verify the file exists in `.claude/commands/` with a `.md` extension
2. Check frontmatter has valid `description` field (required for discovery)
3. For namespaced commands (e.g., `bugfix/rca.md`), invoke with `/rca` not `/bugfix/rca`
4. Restart Claude Code — commands are loaded at session start

### Hook Blocking Legitimate Commands

**Symptom**: A bash command is denied with "BLOCKED" even though it's safe.

**Fix**:
1. Check `.claude/hooks/block-dangerous-commands.sh` for the pattern that's matching
2. The hook uses pattern matching — your command may contain a substring that matches a blocked pattern (e.g., `rm` inside a longer command)
3. To allow a specific command, add it to the `permissions.allow` array in `.claude/settings.json`
4. To temporarily disable the hook, remove its entry from `hooks.PreToolUse` in `.claude/settings.json` (restore it after)

### MCP Server Not Connecting

**Symptom**: MCP tools aren't available, or you see connection errors.

**Fix**:
1. Verify `.mcp.json` exists at the project root (not inside `.claude/`)
2. Check that the server package is installed: `npx -y @modelcontextprotocol/server-<name>` should work
3. Verify environment variables are set (check the template in `.claude/mcp-templates/` for required vars)
4. For servers requiring tokens (GitHub, Supabase), ensure the env var is exported in your shell profile
5. Restart Claude Code after modifying `.mcp.json`

### /setup Not Detecting Framework

**Symptom**: `/setup` asks for your tech stack even though config files exist.

**Fix**:
1. Ensure config files are in the project root: `package.json`, `pyproject.toml`, or `tsconfig.json`
2. If auto-detection fails, manually select your framework — `/setup` will still configure everything correctly

### Subagent Timing Out

**Symptom**: A subagent (researcher, planner, etc.) stops responding or takes too long.

**Fix**:
1. Check the `maxTurns` setting in the agent file (`.claude/agents/<name>.md`) — increase if needed
2. The researcher agent (haiku model) has 15 turns; complex questions may need more
3. For large codebases, break the question into smaller, focused queries and run multiple researcher agents in parallel
4. Ensure your network connection is stable — agent calls require API access

### Auto-Format Changing Files Unexpectedly

**Symptom**: Files are reformatted after every edit, or formatting conflicts with your style.

**Fix**:
1. The `auto-format.sh` hook detects your formatter from config files (biome.json, .prettierrc, pyproject.toml with ruff, etc.)
2. If no formatter config exists, the hook does nothing
3. To disable: remove the `PostToolUse` entry from `.claude/settings.json`
4. To change formatter: add/modify your formatter config file — the hook will detect it automatically

### Path-Targeted Rules Not Loading

**Symptom**: Rules in `.claude/rules/frontend/` aren't applied when editing frontend files.

**Fix**:
1. Path-targeted rules activate based on the subdirectory name matching the file path being edited
2. The directory name must match a path component — `.claude/rules/frontend/` activates for files containing `frontend/` in their path
3. Check that your source files are in a matching path (e.g., `src/frontend/`, `frontend/`, `app/frontend/`)
4. Rules in the root of `.claude/rules/` always load regardless of file path

## Permissions Issues

### Understanding the 3-Tier Model

Claude Code uses three permission levels configured in `.claude/settings.json`:

| Level | Behavior | Use For |
|-------|----------|---------|
| `allow` | Executes without asking | Safe, read-only, and standard dev commands |
| `ask` | Prompts for confirmation | Potentially destructive but sometimes needed (push, rm, docker) |
| `deny` | Always blocked | Dangerous commands that should never run (rm -rf /, force push) |

### Checking Current Permissions

Read `.claude/settings.json` and look at the `permissions` object:
- `allow`: Array of tool patterns that execute freely
- `ask`: Array of tool patterns that prompt for confirmation
- `deny`: Array of tool patterns that are always blocked

### Modifying Permissions

Edit `.claude/settings.json`. Tool patterns use the format:
- `"Bash(command*)"` — matches any bash command starting with `command`
- `"Read"`, `"Write"`, `"Edit"` — file operation tools
- `"Glob"`, `"Grep"` — search tools

**Example — allow docker commands without prompting**:
```json
{
  "permissions": {
    "allow": [
      "Bash(docker compose*)",
      "Bash(docker build*)"
    ]
  }
}
```

### Hooks on Windows

**Symptom**: Hooks fail silently, produce no output, or error with "bash: command not found".

**Fix**:
1. Hooks are bash scripts (`.sh`) and require a bash-compatible shell to execute
2. **Git Bash** (included with Git for Windows) or **WSL** must be available — PowerShell and CMD cannot run bash hooks
3. Ensure `bash` is on your system PATH: run `where bash` in your terminal to verify
4. If hooks fail silently (no error, no output), Claude Code may not be finding bash — add Git Bash to your PATH: typically `C:\Program Files\Git\bin`
5. After PATH changes, restart your terminal and Claude Code
6. As a workaround, you can disable hooks by removing the `hooks` entries from `.claude/settings.json` — but this removes safety guardrails

## Platform-Specific Issues

### Windows

- **Use Git Bash or WSL**, not PowerShell or CMD — hooks are bash scripts
- If hooks fail with "permission denied", run: `chmod +x .claude/hooks/*.sh` in Git Bash
- Path separators: hooks use forward slashes (`/`) — Git Bash handles this automatically
- If `npx` commands hang, try `npx.cmd` or install packages globally first

### macOS

- Ensure Claude Code is installed via Homebrew or the official installer
- If hooks fail with "permission denied": `chmod +x .claude/hooks/*.sh`
- For MCP servers using Node.js, ensure `node` is in your PATH (check with `which node`)

### Linux

- Make hooks executable: `chmod +x .claude/hooks/*.sh`
- If using nvm, ensure the correct Node.js version is active before starting Claude Code
- For MCP servers, verify `npx` resolves correctly: `which npx`

## Getting Help

- **Documentation**: Read the [Architecture Guide](./ARCHITECTURE-GUIDE.md) for how layers interact
- **FAQ**: Check [FAQ.md](./FAQ.md) for answers to common questions
- **GitHub Issues**: Report bugs or request features at the project repository
- **Commands Reference**: See [COMMANDS-REFERENCE.md](./COMMANDS-REFERENCE.md) for detailed command usage
