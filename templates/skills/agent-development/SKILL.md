---
name: agent-development
description: >
  Teaches AI agent orchestration patterns, tool design, prompt engineering, and
  context window management for building LLM-powered agents. Use when building
  or modifying LLM-powered agents, designing tool interfaces for agent use,
  implementing multi-agent orchestration, writing system prompts for agents,
  implementing error handling and self-correction, or testing and evaluating
  agent performance.
---

# Agent Development Patterns

## When to Use This Skill

- Building or modifying LLM-powered agents
- Designing tool interfaces for agent use
- Implementing multi-agent orchestration systems
- Writing or refining system prompts for agents
- Implementing error handling and self-correction loops
- Testing and evaluating agent performance
- Building MCP servers for tool/data integration

## When NOT to Use This Skill

- Traditional software without LLM components
- Simple API integrations that don't involve AI reasoning
- Data pipelines without AI decision-making
- Frontend UI development (use frontend skills)

## Tool Design Checklist

- [ ] 7-element docstring (summary, when to use, when NOT to use, args, returns, performance, examples)
- [ ] Response format parameter (`minimal`/`concise`/`detailed`) for variable-length outputs
- [ ] Consolidated tools where possible (one tool with `operation` param vs many similar tools)
- [ ] Error messages include recovery guidance
- [ ] Idempotent where possible

## Tool Design Principles

### The 7-Element Tool Docstring

Every tool exposed to an agent MUST include:

1. **One-line summary** — What the tool does
2. **Use this when** — 3-5 specific scenarios (affirmative guidance)
3. **Do NOT use for** — Redirect to correct alternatives (negative guidance)
4. **Args** — Parameters with types AND guidance on value choices
5. **Returns** — Format and structure details
6. **Performance notes** — Token costs, execution time, limits
7. **Examples** — 2-4 realistic examples (not "foo", "bar")

### Tool Consolidation

Prefer one tool with an `operation` parameter over multiple similar tools.
Consolidate when: 3+ tools share the same domain and similar parameters.
Do NOT consolidate when: different auth requirements, different error handling, or very different parameters.

### Response Format Control

Add `response_format` parameter to variable-length tools: `"minimal"` (~50 tokens), `"concise"` (~150 tokens, default), `"detailed"` (~1500+ tokens, use sparingly).

## Anthropic SDK Tool Patterns

### TypeScript — `zodTool()` Helper

```ts
import Anthropic from "@anthropic-ai/sdk";
import { zodTool } from "@anthropic-ai/sdk/helpers/zod";
import { z } from "zod";

const client = new Anthropic();

const searchTool = zodTool({
  name: "search_codebase",
  description: "Search the codebase for files matching a query. Use when looking for implementations.",
  schema: z.object({
    query: z.string().describe("Search query — use function or class names for best results"),
    filePattern: z.string().optional().describe("Glob pattern to filter files, e.g. '*.ts'"),
  }),
});

const response = await client.messages.create({
  model: "claude-sonnet-4-6",
  max_tokens: 1024,
  tools: [searchTool],
  messages,
});
```

### Python — Tool Use Loop

```python
import anthropic

client = anthropic.Anthropic()

tools = [
    {
        "name": "search_codebase",
        "description": "Search the codebase for files matching a query.",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "Search query"},
                "file_pattern": {"type": "string", "description": "Glob pattern to filter files"},
            },
            "required": ["query"],
        },
    }
]

# Tool use loop
response = client.messages.create(model="claude-sonnet-4-6", max_tokens=1024, tools=tools, messages=messages)
while response.stop_reason == "tool_use":
    tool_results = process_tool_calls(response)
    messages.append({"role": "assistant", "content": response.content})
    messages.append({"role": "user", "content": tool_results})
    response = client.messages.create(model="claude-sonnet-4-6", max_tokens=1024, tools=tools, messages=messages)
```

## MCP Server Development

MCP (Model Context Protocol) is the industry-standard protocol (Linux Foundation) for connecting AI models to tools and data sources.

### Core Concepts

- **Tools**: Functions the model can invoke (search, create, update)
- **Resources**: Data the model can read (files, database records, API responses)
- **Prompts**: Reusable prompt templates exposed by the server
- **OAuth 2.0**: Standard auth flow for remote MCP servers

### TypeScript MCP Server

```ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

const server = new McpServer({ name: "project-tools", version: "1.0.0" });

server.tool("search_issues",
  { query: z.string(), status: z.enum(["open", "closed", "all"]).default("open") },
  async ({ query, status }) => {
    const issues = await issueTracker.search(query, { status });
    return { content: [{ type: "text", text: JSON.stringify(issues, null, 2) }] };
  }
);

server.resource("issue/{id}", async (uri) => {
  const id = uri.pathname.split("/").pop();
  const issue = await issueTracker.get(id);
  return { contents: [{ uri: uri.href, mimeType: "application/json", text: JSON.stringify(issue) }] };
});
```

### Python MCP Server

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("project-tools")

@mcp.tool()
async def search_issues(query: str, status: str = "open") -> str:
    """Search project issues by query. Returns JSON array of matching issues."""
    issues = await issue_tracker.search(query, status=status)
    return json.dumps(issues)

@mcp.resource("issue://{id}")
async def get_issue(id: str) -> str:
    """Get a single issue by ID."""
    issue = await issue_tracker.get(id)
    return json.dumps(issue)
```

### MCP Testing & Best Practices

- Test with `npx @modelcontextprotocol/inspector` before deploying
- Return structured JSON from tools — easier for models to parse
- Separate read-only resources from write tools for safety
- Use `@modelcontextprotocol/sdk` (TS) or `mcp` package (Python)

## Agent Orchestration Patterns

### Orchestrator Pattern

Main agent delegates to specialized sub-agents:

```
Orchestrator Agent
  - Research Agent    (reads docs, searches code)
  - Planning Agent    (designs solutions)
  - Coding Agent      (implements changes)
  - Review Agent      (validates quality)
```

Each sub-agent has narrow, focused capabilities. Orchestrator decides which to invoke and synthesizes results. Communication via structured JSON messages.

### Pipeline Pattern

Sequential processing with handoffs:

```
Input -> Parse -> Plan -> Implement -> Validate -> Output
```

Each stage transforms input for the next. Good for well-defined workflows.

### Map-Reduce Pattern

Parallel processing of independent subtasks:

```
Task -> [Subtask A, Subtask B, Subtask C] -> Synthesize Results
```

Good for analyzing multiple files, searching multiple sources, processing batch items.

## Prompt Engineering Essentials

Structure system prompts with five sections: `<role>`, `<capabilities>`, `<constraints>`, `<output_format>`, `<examples>`. Be explicit about WHAT and WHEN for tool usage, provide negative guidance, show multi-step reasoning examples, and include error recovery instructions.

## Context Window Management

Budget: ~30% system prompt/tools, ~40% conversation history, ~30% response generation. Compress history when approaching limits:
- Summarize older turns (keep last 3-5 verbatim)
- Replace large tool outputs with summaries after processing
- Use sub-agents for research to keep main context clean
- Use `response_format` to control tool output size

## Error Handling

**Self-correction loop**: tool error -> adjust approach -> retry with corrected parameters -> after 3 failures, escalate to user.

**Graceful degradation**: tool failure (try alternative), rate limit (exponential backoff), context overflow (summarize and continue), ambiguous input (ask, don't guess).

## Testing Strategy

### Unit Testing

- Test each tool independently with mock inputs
- Verify tool schemas match implementation
- Test error handling for each tool

### Behavior Testing

- Record LLM responses and replay for deterministic tests
- Use assertion-based checks on agent output
- Test multi-turn conversations with scripted inputs

### Evaluation

- LLM-as-judge for subjective quality assessment
- Track metrics: task completion rate, tool usage efficiency, error rate
- A/B test prompt variations for measurable improvements

## Anti-Patterns

- Tools without usage guidance — agent can't decide when to use them
- Overly broad tools — do-everything tools confuse the agent
- Missing error recovery instructions — agent gets stuck on first failure
- No evaluation metrics — can't measure improvement over time
- System prompts without examples — agent guesses at expected behavior
- Tight coupling between agents — defeats the purpose of delegation

## References

See `references/tool-design-guide.md` for tool docstring templates, system prompt cookbook, and agent evaluation framework.
