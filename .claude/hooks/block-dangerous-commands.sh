#!/bin/bash
# PreToolUse hook: Block dangerous commands
# Input (stdin): {"tool_name": "Bash", "tool_input": {"command": "..."}}
# Output (stdout): hookSpecificOutput JSON

input=$(cat)

# Parse command — jq if available, grep fallback
if command -v jq &>/dev/null; then
  cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
else
  cmd=$(echo "$input" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
fi

if [ -z "$cmd" ]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

# Block destructive commands
if echo "$cmd" | grep -qE '(rm -rf /|rm -rf ~|rm -rf \.|git push --force|git push -f |git reset --hard|git clean -fd|DROP TABLE|DROP DATABASE|> /dev/sd|mkfs\.|:\(\)\{|curl.*\| *bash|wget.*\| *bash|chmod 777)'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blocked: This command matches a dangerous pattern. Review and run manually if intended."}}'
  exit 0
fi

# Ask on sensitive file access (excluding templates/examples)
if echo "$cmd" | grep -qE '\.(env|pem|key)([^.]|$)|credentials|secrets|\.ssh/|\.aws/'; then
  if ! echo "$cmd" | grep -qE '\.(example|sample|template|md)'; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"This command accesses potentially sensitive files. Please confirm."}}'
    exit 0
  fi
fi

# Allow everything else
echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
exit 0
