# AI Workflow

- Read files just-in-time, not preemptively — only when needed for the current step
- Search with glob/grep before reading — never read entire directories
- Plan before multi-file edits — identify all affected files and dependency order first
- Delegate research to sub-agents — keep main context focused on implementation
- Use sub-agents in parallel for independent searches
- Compact proactively — summarize findings when context grows large
- Verify each change compiles/passes before moving to the next file
- Use /clear between unrelated tasks to reset context
- Prefer reading public APIs/interfaces over implementation details
- Do NOT use sub-agents for simple, focused tasks (one file, one edit)
