# Tool Design Guide

Deep reference for designing agent tools, writing system prompts, and evaluating agent performance.

## Tool Docstring Templates by Type

### Read-Only Tool (Search, Fetch, Query)

```yaml
name: search_documents
summary: Search documents by keyword, returning ranked results with snippets.

use_when:
  - User asks a question requiring document lookup
  - Agent needs to verify a fact or find context for a task

do_not_use_when:
  - Document content is already in context
  - Use fetch_document when you know the exact document ID

args:
  query: string — Natural language search query. Be specific.
  max_results: integer (1-20, default 5) — Fewer = faster, less context.
  response_format: "minimal" | "concise" | "detailed"

returns:
  Array of { id, title, snippet, relevance_score }. Empty array if no matches.

performance:
  ~200ms per query. Detailed mode costs ~300 tokens per result.

examples:
  - search_documents(query="user authentication flow", max_results=3)
  - search_documents(query="rate limiting middleware", response_format="detailed", max_results=1)
```

### Write Tool (Create, Update, Delete)

```yaml
name: file_manage
summary: Create, update, append to, or delete files in the project workspace.

use_when:
  - Implementing code changes, writing tests, updating config

do_not_use_when:
  - Reading files (use read_file) or searching (use search_files)

args:
  operation: "create" | "update" | "append" | "delete"
  path: string — Relative path from project root.
  content: string — Required for create/update/append.
  create_dirs: boolean (default true)

returns:
  { success, path, operation, bytes_written }
  On error: { success: false, error, suggestion }

performance:
  ~50ms for local files. Use read_file to verify after write.

examples:
  - file_manage(operation="create", path="src/utils/helpers.ts", content="export function ...")
  - file_manage(operation="delete", path="tmp/scratch.txt")
```

### Transformation Tool (Convert, Format, Parse)

```yaml
name: format_code
summary: Format source code according to project style rules.

use_when:
  - After generating/modifying code, before presenting to user
  - Preparing code for a commit or pull request

do_not_use_when:
  - Code is already formatted; use lint_code for logical issues

args:
  code: string — The source code to format.
  language: string — Programming language.
  style: string (optional) — Style preset (defaults to project config).

returns:
  { formatted, changed, diff_summary }

performance:
  ~100ms for files under 500 lines.

examples:
  - format_code(code="function foo(){return 1}", language="typescript")
  - format_code(code="def bar():\n  x=1\n  return x", language="python", style="black")
```

### Communication Tool (Send Message, Notify)

```yaml
name: notify_user
summary: Send a notification or status update to the user.

use_when:
  - Long-running task completes or fails
  - Agent needs user input to proceed

do_not_use_when:
  - Normal conversation flow (just reply directly)
  - Internal agent logging or inter-agent communication

args:
  message: string — Clear, actionable. Include what happened and what to do next.
  severity: "info" | "warning" | "error" (default "info")
  channel: string (optional) — Override default notification channel.

returns:
  { delivered, channel, timestamp }

performance:
  ~300ms delivery. Rate limited to 10/minute. Batch related updates.

examples:
  - notify_user(message="Migration completed. 3 tables created.", severity="info")
  - notify_user(message="API key expired. Update OPENAI_API_KEY.", severity="error")
```

## Tool Consolidation Framework

### When to Consolidate

Consolidate tools when:
- 3+ tools operate on the same domain (files, database, messages)
- Tools share similar parameters (path, id, content)
- Tools have overlapping use cases that confuse the agent
- The agent frequently calls the wrong variant

### When NOT to Consolidate

Keep tools separate when:
- Different authentication or permission requirements
- Significantly different error handling needs
- Very different parameter sets (consolidation would mean many optional params)
- Different performance characteristics that the agent should reason about
- Destructive vs non-destructive operations that need different confirmation flows

### Consolidation Pattern

```yaml
name: database_manage
args:
  operation: "query" | "insert" | "update" | "delete" | "schema"
  table: string
  data: object (for insert/update)
  where: object (for query/update/delete)
  sql: string (for raw query, operation="query" only)
```

The `operation` parameter acts as a discriminator. Document which args apply to which operations.

### Anti-Pattern: Over-Consolidation

```yaml
# BAD: too many unrelated operations in one tool
name: do_everything
args:
  operation: "search_code" | "write_file" | "run_test" | "deploy" | "send_email"
```

If operations don't share parameters or domain logic, keep them separate.

## System Prompt Engineering Cookbook

### Template: Task-Focused Agent

```
You are a [ROLE] agent. Your job is to [PRIMARY TASK].

## Capabilities
You have access to these tools:
- [tool_1]: [one-line description]. Use when [scenario].
- [tool_2]: [one-line description]. Use when [scenario].

## Workflow
1. [First step — what to do and when]
2. [Second step]
3. [Final step — how to present results]

## Constraints
- NEVER [dangerous action]
- ALWAYS [safety requirement]
- If unsure, [fallback behavior]

## Output Format
Respond with:
- **Summary**: 1-2 sentence overview
- **Details**: Bullet points of findings/changes
- **Next Steps**: What the user should do next

## Examples
User: [example input]
Agent: [example of correct tool usage and response]
```

### Template: Conversational Agent

```
You are [NAME], a [ROLE] that helps users with [DOMAIN].

## Personality
- [Trait 1: e.g., concise and direct]
- [Trait 2: e.g., asks clarifying questions before acting]

## Tools
[List tools with when-to-use guidance]

## Boundaries
- You can help with: [explicit list]
- You cannot help with: [explicit list]
```

### Template: Tool-Heavy Agent

```
You are an automation agent with access to [N] tools.

## Tool Selection Rules
- ALWAYS check before modifying: use [read_tool] before [write_tool]
- PREFER [tool_A] over [tool_B] when [condition]
- NEVER use [tool_C] without first [prerequisite]

## Error Recovery
- After 3 consecutive failures, try [alternative approach]
- After 3 failures with different tools, ask the user for help

## Performance
- Minimize tool calls: plan before starting
- Use minimal response_format for exploration, detailed only for final reads
```

### Anti-Patterns in System Prompts

- **Too long**: Prompts over 2000 tokens dilute important instructions
- **Contradictory rules**: "Always be thorough" + "Keep responses under 100 words"
- **No examples**: Agent guesses at expected behavior
- **Vague tool guidance**: "Use tools as needed" gives no decision framework
- **Missing negative guidance**: Agent doesn't know what NOT to do

### Prompt Versioning

- Store prompts in version control; tag versions (v1.0, v1.1)
- A/B test new versions with measurable metrics
- Roll back if metrics degrade

## Agent Memory Patterns

| Memory Type | Scope | Persistence | Use Case |
|-------------|-------|-------------|----------|
| Short-term | Current turn | None (context window) | Active reasoning, recent tool results |
| Medium-term | Current session | File-based (.agent/notes.md) | Multi-step task progress |
| Long-term | Cross-session | Vector DB or structured storage | User prefs, project knowledge |

- Short-term is automatic; medium-term requires explicit file writes; long-term requires DB operations
- When context grows large, summarize findings into medium-term notes

## Error Recovery Implementation

### Retry with Exponential Backoff

```python
import time
import random

def retry_with_backoff(func, max_retries=3, base_delay=1.0):
    for attempt in range(max_retries):
        try:
            return func()
        except RetryableError as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt) + random.uniform(0, 0.5)
            time.sleep(delay)
    raise MaxRetriesExceeded(f"Failed after {max_retries} attempts")
```

### Fallback Tool Selection

```
Primary: search_vector_db(query)
  |-- on failure --> search_keyword(query)
      |-- on failure --> search_files(glob_pattern)
          |-- on failure --> ask_user("I couldn't find information about X. Can you point me to the right file?")
```

Define fallback chains for critical operations. Each fallback should be a different approach, not just a retry.

### Graceful Degradation Hierarchy

1. **Full capability**: All tools available, use optimal approach
2. **Reduced capability**: Some tools unavailable, use alternatives
3. **Minimal capability**: Most tools down, provide best-effort response from context
4. **Safe failure**: Cannot proceed, clearly explain what failed and what the user can do

### User Escalation Thresholds

- 1 failure: Retry with adjusted parameters
- 2 failures: Try alternative tool or approach
- 3 failures: Inform user and ask for guidance
- Never silently loop more than 3 times on the same error

## Agent Testing Framework

### Unit Testing Tools

Test each tool independently with the AAA pattern:

```python
def test_search_returns_ranked_results():
    mock_db = create_test_database(documents=sample_docs)
    tool = SearchTool(db=mock_db)
    results = tool.execute(query="authentication", max_results=3)
    assert len(results) <= 3
    assert results[0].relevance_score >= results[1].relevance_score

def test_search_error_includes_recovery_guidance():
    tool = SearchTool(db=None)  # Simulate connection failure
    error = tool.execute(query="test")
    assert error.suggestion is not None
```

### Integration Testing (Recorded Conversations)

```python
def test_agent_completes_file_search_task():
    # Record a conversation with known inputs and expected behavior
    conversation = [
        {"role": "user", "content": "Find all files related to authentication"},
        # Agent should call search_files, then read relevant results
    ]

    result = run_agent(conversation, tools=mock_tools)

    # Assert on behavior, not exact output
    assert "search_files" in result.tool_calls
    assert result.final_response contains "auth"
    assert result.tool_call_count <= 5  # Efficiency check
```

### Evaluation Metrics

| Metric | How to Measure | Target |
|--------|---------------|--------|
| Task completion rate | % of tasks fully completed | > 90% |
| Tool call efficiency | Unnecessary tool calls / total calls | < 15% |
| Error recovery rate | Errors recovered from / total errors | > 70% |
| Response quality | LLM-as-judge score (1-5) | > 4.0 |
| Latency | Time from request to final response | < 30s for simple tasks |
| Context efficiency | Tokens used / minimum tokens needed | < 2.0x |

### A/B Testing Prompt Variations

- Run both prompt variants against the same test cases (30+ for significance)
- Use LLM-as-judge to score each variant's output
- Compare mean scores and calculate statistical significance
- Track: task completion rate, tool call efficiency, response quality
- Keep a changelog of prompt changes and their measured impact

## Multi-Agent Communication Protocols

### Direct Message Passing

Structured JSON messages between agents. Best for simple request-response. Low overhead.

### Shared State (File-Based or Database)

Agents read/write to shared files or database records. Best for collaborative artifacts where multiple agents contribute.

### Event-Driven (Pub/Sub)

Agents subscribe to events (`task.created`, `plan.completed`, `code.reviewed`). Best for loosely coupled, extensible systems.

### Orchestrator-Mediated

Central coordinator routes tasks, evaluates quality, and handles error recovery. Best for workflows with quality gates.

### Choosing a Pattern

| Pattern | Complexity | Coupling | Scalability | Best For |
|---------|-----------|----------|-------------|----------|
| Direct message | Low | High | Low | Two-agent interactions |
| Shared state | Medium | Medium | Medium | Collaborative artifacts |
| Event-driven | High | Low | High | Dynamic, extensible systems |
| Orchestrator | Medium | Medium | Medium | Quality-gated workflows |

## MCP Server Examples

### TypeScript MCP Server

Complete MCP server with tools and resources using `@modelcontextprotocol/sdk`:

```ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "project-management",
  version: "1.0.0",
});

// Tool: search issues
server.tool(
  "search_issues",
  {
    query: z.string().describe("Search query for issue title or body"),
    status: z.enum(["open", "closed", "all"]).default("open"),
    limit: z.number().min(1).max(50).default(10),
  },
  async ({ query, status, limit }) => {
    const issues = await db.issues.search({ query, status, limit });
    return {
      content: [{ type: "text", text: JSON.stringify(issues, null, 2) }],
    };
  }
);

// Tool: create issue
server.tool(
  "create_issue",
  {
    title: z.string().min(1).max(255),
    body: z.string(),
    labels: z.array(z.string()).optional(),
  },
  async ({ title, body, labels }) => {
    const issue = await db.issues.create({ title, body, labels });
    return {
      content: [{ type: "text", text: `Created issue #${issue.id}: ${issue.title}` }],
    };
  }
);

// Resource: single issue by ID
server.resource("issue/{id}", async (uri) => {
  const id = uri.pathname.split("/").pop()!;
  const issue = await db.issues.findById(id);
  if (!issue) throw new Error(`Issue ${id} not found`);
  return {
    contents: [{
      uri: uri.href,
      mimeType: "application/json",
      text: JSON.stringify(issue, null, 2),
    }],
  };
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Python MCP Server

Complete MCP server using the `mcp` Python package with FastMCP:

```python
import json
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("project-management")

@mcp.tool()
async def search_issues(query: str, status: str = "open", limit: int = 10) -> str:
    """Search project issues by query.

    Args:
        query: Search query for issue title or body
        status: Filter by status - open, closed, or all
        limit: Maximum number of results (1-50)
    """
    issues = await db.issues.search(query=query, status=status, limit=limit)
    return json.dumps(issues, indent=2)

@mcp.tool()
async def create_issue(title: str, body: str, labels: list[str] | None = None) -> str:
    """Create a new project issue.

    Args:
        title: Issue title (1-255 characters)
        body: Issue description in markdown
        labels: Optional list of label names
    """
    issue = await db.issues.create(title=title, body=body, labels=labels or [])
    return f"Created issue #{issue.id}: {issue.title}"

@mcp.resource("issue://{id}")
async def get_issue(id: str) -> str:
    """Get a single issue by ID."""
    issue = await db.issues.find_by_id(id)
    if not issue:
        raise ValueError(f"Issue {id} not found")
    return json.dumps(issue, indent=2)

if __name__ == "__main__":
    mcp.run()
```

### Testing MCP Servers

```bash
# Use the MCP Inspector for interactive testing
npx @modelcontextprotocol/inspector

# Point it at your server
npx @modelcontextprotocol/inspector node dist/index.js

# For Python servers
npx @modelcontextprotocol/inspector python server.py
```

## SDK Tool Definition Patterns

### Anthropic SDK — TypeScript with Zod

```ts
import Anthropic from "@anthropic-ai/sdk";
import { zodTool } from "@anthropic-ai/sdk/helpers/zod";
import { z } from "zod";

const client = new Anthropic();

// Define tools with Zod schemas for automatic validation
const tools = [
  zodTool({
    name: "search_codebase",
    description: "Search codebase for files matching a query. Use when looking for implementations, definitions, or usage patterns.",
    schema: z.object({
      query: z.string().describe("Search query — use function/class names for precise results"),
      filePattern: z.string().optional().describe("Glob pattern, e.g. '**/*.ts'"),
      maxResults: z.number().min(1).max(20).default(5),
    }),
  }),
  zodTool({
    name: "read_file",
    description: "Read a file's contents. Use after search to examine specific files.",
    schema: z.object({
      path: z.string().describe("Relative path from project root"),
      startLine: z.number().optional().describe("First line to read (1-based)"),
      endLine: z.number().optional().describe("Last line to read"),
    }),
  }),
];

// Agentic loop with tool execution
let messages: Anthropic.MessageParam[] = [{ role: "user", content: userQuery }];

while (true) {
  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 4096,
    tools,
    messages,
  });

  messages.push({ role: "assistant", content: response.content });

  if (response.stop_reason === "end_turn") break;

  const toolResults = [];
  for (const block of response.content) {
    if (block.type === "tool_use") {
      const result = await executeToolCall(block.name, block.input);
      toolResults.push({ type: "tool_result" as const, tool_use_id: block.id, content: result });
    }
  }
  messages.push({ role: "user", content: toolResults });
}
```

## Observability for Agents

### Structured Logging

Log all LLM interactions with structured fields for debugging and cost tracking:

```ts
import structlog from "structlog";  // Or pino, winston

const logger = structlog.getLogger();

// Log every LLM call
logger.info("llm_request", {
  model: "claude-sonnet-4-6",
  input_tokens: response.usage.input_tokens,
  output_tokens: response.usage.output_tokens,
  stop_reason: response.stop_reason,
  tool_calls: response.content.filter((b) => b.type === "tool_use").map((b) => b.name),
  latency_ms: endTime - startTime,
  request_id: requestId,
});

// Log tool executions
logger.info("tool_execution", {
  tool: toolName,
  input_summary: JSON.stringify(input).slice(0, 200),
  success: true,
  latency_ms: toolEndTime - toolStartTime,
});
```

### Key Metrics to Track

| Metric | Description | Alert Threshold |
|--------|-------------|----------------|
| Token usage per request | Total input + output tokens | > 50k per request |
| Tool call count | Number of tool calls per task | > 15 per task |
| Error rate | Failed tool calls / total | > 20% |
| Latency p95 | 95th percentile response time | > 60s |
| Cost per task | USD cost of LLM calls | > $0.50 per task |
