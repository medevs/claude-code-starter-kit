# AI Agent Development Rules

**SDK Version Pins:** `@anthropic-ai/sdk 1.x+` (TypeScript), `anthropic 1.x+` (Python)

## Architecture

```
src/
  agents/
    orchestrator.ts          # Main agent that delegates to specialists
    researcher.ts            # Research/information gathering agent
    implementer.ts           # Code generation/modification agent
  tools/
    search.ts                # Search tool definition
    file-ops.ts              # File operation tools
    api-client.ts            # External API tools
  prompts/
    system.ts                # System prompt templates
    templates/               # Reusable prompt fragments
  schemas/
    tool-schemas.ts          # Tool input/output schemas
    message-schemas.ts       # Message format schemas
  lib/
    llm-client.ts            # LLM API client wrapper
    context.ts               # Context window management
    streaming.ts             # Stream handling utilities
```

## LLM API Patterns

- Use the official SDK (Anthropic SDK, OpenAI SDK) — not raw HTTP
- Always set `max_tokens` explicitly — don't rely on defaults
- Handle rate limits with exponential backoff and jitter
- Use streaming for long responses — show progress to users
- Cache identical requests when appropriate (same prompt + same model)

## Anthropic SDK Patterns

### TypeScript — Zod Tool Definition

```ts
import Anthropic from "@anthropic-ai/sdk";
import { zodTool } from "@anthropic-ai/sdk/helpers/zod";
import { z } from "zod";

const client = new Anthropic();

const searchTool = zodTool({
  name: "search_docs",
  description: "Search documentation by query. Use when the user asks about features or APIs.",
  schema: z.object({
    query: z.string().describe("Natural language search query"),
    max_results: z.number().min(1).max(20).default(5),
  }),
});

const response = await client.messages.create({
  model: "claude-sonnet-4-6",
  max_tokens: 1024,
  tools: [searchTool],
  messages: [{ role: "user", content: "How do I set up authentication?" }],
});
```

### Python — Tool Definition

```python
import anthropic

client = anthropic.Anthropic()

tools = [
    {
        "name": "search_docs",
        "description": "Search documentation by query.",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "Natural language search query"},
                "max_results": {"type": "integer", "default": 5, "minimum": 1, "maximum": 20},
            },
            "required": ["query"],
        },
    }
]

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "How do I set up authentication?"}],
)
```

## Tool Design (7-Element Docstrings)

Every tool must include these elements in its description:

1. **One-line summary**: What the tool does
2. **Use this when**: 3-5 specific scenarios (affirmative guidance)
3. **Do NOT use for**: Scenarios where other tools are better (negative guidance)
4. **Args**: Each parameter with type, description, and guidance on value choices
5. **Returns**: What's returned and its format/structure
6. **Performance notes**: Token usage, execution time, resource limits
7. **Examples**: 2-4 realistic usage examples

**Tool Consolidation**: Prefer one tool with an `operation` parameter over multiple similar tools. Reduces tool selection confusion.

## Prompt Engineering

- System prompts: role, capabilities, constraints, output format
- Keep system prompts under 2000 tokens — use @imports for detailed rules
- Use XML tags for structured sections: `<context>`, `<instructions>`, `<examples>`
- Provide 2-3 examples of desired output format (few-shot)
- Be explicit about what NOT to do — models need negative guidance

## Agent Orchestration

- **Orchestrator pattern**: Main agent delegates to specialized sub-agents
- Keep sub-agent scope narrow — one capability per agent
- Pass minimal context between agents — only what's needed
- Use structured handoff formats (JSON) between agents
- Implement timeout and retry logic for agent calls

## MCP (Model Context Protocol)

MCP is the industry-standard protocol (Linux Foundation) for connecting AI models to tools and data sources.

### Core Concepts

- **Tools**: Functions the model can invoke (search, create, update)
- **Resources**: Data the model can read (files, database records, API responses)
- **Prompts**: Reusable prompt templates exposed by the server
- **OAuth 2.0**: Standard auth flow for remote MCP servers

### MCP Server Development

```ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

const server = new McpServer({ name: "my-server", version: "1.0.0" });

server.tool("search_issues", { query: z.string(), status: z.enum(["open", "closed"]).optional() },
  async ({ query, status }) => {
    const results = await searchIssues(query, status);
    return { content: [{ type: "text", text: JSON.stringify(results) }] };
  }
);

// Test with: npx @modelcontextprotocol/inspector
```

### MCP Best Practices

- Use `@modelcontextprotocol/sdk` for TypeScript, `mcp` package for Python
- Test servers with `npx @modelcontextprotocol/inspector` before deploying
- Return structured JSON from tools — easier for models to parse
- Separate read-only resources from write tools for safety
- Handle errors gracefully — return error messages in content, don't crash the server

## Context Window Management

- Track token usage across conversation turns
- Summarize older context when approaching limits
- Use retrieval (RAG) for large knowledge bases — don't stuff context
- Prioritize recent and relevant context over comprehensive history
- Design tools to return token-efficient responses (offer `response_format` parameter)

## Structured Output

- Use Zod/Pydantic schemas for all tool inputs AND outputs
- Define response schemas for agent outputs when format matters
- Validate tool outputs before passing to next agent
- Handle malformed LLM outputs gracefully — retry with clarification

## Streaming & UX

- Stream responses for all user-facing output
- Show tool call progress (which tool, what arguments)
- Provide cancel/abort mechanism for long-running operations
- Display token usage and cost when relevant

## Error Handling

- Distinguish between tool errors (fixable) and system errors (fatal)
- On tool error: include error details in next message for self-correction
- On rate limit: exponential backoff with user notification
- On context overflow: summarize and continue, don't crash
- Log all LLM interactions for debugging (sanitize sensitive data)

## Testing

```ts
import { describe, it, expect, vi } from "vitest";

describe("search_docs tool", () => {
  it("returns ranked results for valid query", async () => {
    const mockDb = createTestIndex(sampleDocs);
    const tool = createSearchTool(mockDb);
    const result = await tool.execute({ query: "authentication", max_results: 3 });
    expect(result.content).toHaveLength(3);
    expect(result.content[0].relevance).toBeGreaterThan(result.content[1].relevance);
  });

  it("returns empty array for no matches", async () => {
    const mockDb = createTestIndex([]);
    const tool = createSearchTool(mockDb);
    const result = await tool.execute({ query: "nonexistent", max_results: 5 });
    expect(result.content).toHaveLength(0);
  });
});
```

## DO NOT Use

- Raw HTTP requests to LLM APIs — use official SDKs (`@anthropic-ai/sdk`, `anthropic`)
- Unstructured string output from tools — always return structured JSON
- Single monolithic agent for complex tasks — decompose into specialized sub-agents
- Hardcoded model IDs — use configuration or constants for easy model upgrades
- `any` types for tool schemas — use Zod or JSON Schema for runtime validation
