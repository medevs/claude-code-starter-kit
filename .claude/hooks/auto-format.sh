#!/bin/bash
# PostToolUse hook: Auto-format written/edited files
# Input (stdin): JSON with tool_name, tool_input (file_path), tool_output

input=$(cat)

# Extract file path
if command -v jq &>/dev/null; then
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')
else
  file_path=$(echo "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
fi

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

ext="${file_path##*.}"

case "$ext" in
  ts|tsx|js|jsx|mjs|cjs|json|css|scss|html|md)
    if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
      npx biome format --write "$file_path" 2>/dev/null
    elif [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ] || [ -f "prettier.config.mjs" ]; then
      npx prettier --write "$file_path" 2>/dev/null
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$file_path" 2>/dev/null
    elif command -v uv &>/dev/null; then
      uv run ruff format "$file_path" 2>/dev/null
    fi
    ;;
esac

exit 0
