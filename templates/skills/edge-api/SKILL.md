---
name: edge-api
description: >
  Teaches edge runtime API patterns for Cloudflare Workers, Vercel Edge, and
  other serverless edge platforms. Use when building APIs that run on edge
  runtimes, working with Cloudflare Workers/D1/KV/R2, deploying to Vercel Edge
  Functions, implementing edge caching strategies, or choosing between edge
  storage options.
---

# Edge Runtime API Patterns

## When to Use This Skill

- Building APIs that run on edge runtimes (Cloudflare Workers, Vercel Edge, Deno Deploy)
- Working with Cloudflare bindings (D1, KV, R2, Durable Objects)
- Implementing edge caching and streaming patterns
- Choosing between edge storage options
- Migrating Node.js APIs to edge runtimes

## When NOT to Use This Skill

- Traditional Node.js server APIs (use api-design skill)
- Frontend-only work (use react-patterns skill)
- Heavy computation that exceeds edge CPU limits (use serverless functions instead)
- Long-running background jobs (use queue-based architecture)

## Edge Runtime Constraints

- **No Node.js APIs**: No `fs`, `path`, `child_process`, `net`, etc.
- **Memory limit**: 128MB per request (Cloudflare Workers)
- **CPU time limit**: 10-50ms CPU time per request (varies by plan)
- **No native modules**: Cannot use packages with native bindings
- **Web Standard APIs**: Use `fetch`, `Request`, `Response`, `URL`, `crypto`, `TextEncoder`

## When to Use Edge vs Serverless

### Choose Edge When
- Low latency is critical (runs in 300+ locations)
- Simple request/response transformations
- Auth/routing middleware
- API proxying and header manipulation
- Static content with dynamic headers
- A/B testing and feature flags

### Choose Serverless When
- CPU-intensive computation (>50ms)
- Large memory requirements (>128MB)
- Need Node.js native modules
- Database connections requiring connection pooling
- Long-running operations (>30s)

## Cloudflare Workers Patterns

### Bindings Type Definition

```ts
type Env = {
  DB: D1Database;          // SQL database
  KV: KVNamespace;         // Key-value store
  BUCKET: R2Bucket;        // Object storage
  QUEUE: Queue;            // Message queue
  COUNTER: DurableObjectNamespace;  // Stateful coordination
  API_KEY: string;         // Secret (from wrangler.toml or dashboard)
};
```

### KV Store (Key-Value)

```ts
// Fast reads, eventually consistent, best for config/cache
app.get("/config/:key", async (c) => {
  const value = await c.env.KV.get(c.req.param("key"), "json");
  if (!value) throw new HTTPException(404, { message: "Config not found" });
  return c.json(value);
});

app.put("/config/:key", async (c) => {
  const body = await c.req.json();
  await c.env.KV.put(c.req.param("key"), JSON.stringify(body), {
    expirationTtl: 3600,  // Optional TTL in seconds
  });
  return c.json({ success: true });
});
```

### D1 Database (SQL)

```ts
// SQLite-based SQL database at the edge
app.get("/users", async (c) => {
  const { results } = await c.env.DB.prepare(
    "SELECT id, name, email FROM users WHERE active = ? ORDER BY created_at DESC LIMIT ?"
  ).bind(1, 20).all();
  return c.json({ data: results });
});

app.post("/users", zValidator("json", createUserSchema), async (c) => {
  const { name, email } = c.req.valid("json");
  const { meta } = await c.env.DB.prepare(
    "INSERT INTO users (name, email) VALUES (?, ?)"
  ).bind(name, email).run();
  return c.json({ id: meta.last_row_id }, 201);
});
```

### R2 Object Storage

```ts
// S3-compatible object storage, no egress fees
app.get("/files/:key", async (c) => {
  const object = await c.env.BUCKET.get(c.req.param("key"));
  if (!object) throw new HTTPException(404, { message: "File not found" });
  const headers = new Headers();
  object.writeHttpMetadata(headers);
  return new Response(object.body, { headers });
});

app.put("/files/:key", async (c) => {
  const body = await c.req.arrayBuffer();
  await c.env.BUCKET.put(c.req.param("key"), body, {
    httpMetadata: { contentType: c.req.header("content-type") || "application/octet-stream" },
  });
  return c.json({ success: true });
});
```

## Vercel Edge Functions

```ts
// app/api/hello/route.ts (Next.js Edge Route)
export const runtime = "edge";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const name = searchParams.get("name") || "World";
  return Response.json({ message: `Hello, ${name}!` });
}
```

## Edge Caching Patterns

### Cache API

```ts
app.get("/products/:id", async (c) => {
  const cache = caches.default;
  const cacheKey = new Request(c.req.url);

  // Check cache first
  let response = await cache.match(cacheKey);
  if (response) return response;

  // Fetch from origin
  const product = await fetchProduct(c.req.param("id"));
  response = c.json(product);
  response.headers.set("Cache-Control", "public, max-age=60");

  // Store in cache (non-blocking)
  c.executionCtx.waitUntil(cache.put(cacheKey, response.clone()));
  return response;
});
```

## Streaming Responses

```ts
app.get("/stream", async (c) => {
  const { readable, writable } = new TransformStream();
  const writer = writable.getWriter();
  const encoder = new TextEncoder();

  c.executionCtx.waitUntil((async () => {
    for (const chunk of dataChunks) {
      await writer.write(encoder.encode(JSON.stringify(chunk) + "\n"));
    }
    await writer.close();
  })());

  return new Response(readable, {
    headers: { "Content-Type": "application/x-ndjson" },
  });
});
```

## Storage Decision Tree

| Need | Solution | Consistency | Latency |
|------|----------|------------|---------|
| Config/cache | KV | Eventually consistent | <10ms reads |
| Relational data | D1 | Strong (single region) | <5ms reads |
| Files/media | R2 | Strong | ~50ms |
| Counters/coordination | Durable Objects | Strong | <1ms (co-located) |
| Message passing | Queues | At-least-once | Async |

## Testing Edge Functions

```ts
import { describe, it, expect } from "vitest";
import { env } from "cloudflare:test";
import app from "../src/index";

describe("Edge API", () => {
  it("returns cached product", async () => {
    // Seed test data
    await env.DB.prepare("INSERT INTO products (id, name) VALUES (?, ?)").bind("p1", "Widget").run();

    const res = await app.request("/products/p1", {}, env);
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.name).toBe("Widget");
  });
});
```

## Anti-Patterns

- **`process.env`** on edge — use `c.env` or platform-specific bindings
- **Heavy Node.js dependencies** — check runtime compatibility before importing
- **Connection pooling** — edge functions are stateless, use HTTP-based DB clients
- **Large response bodies** — stream instead of buffering
- **Blocking operations** — use `waitUntil()` for non-critical async work
- **Global mutable state** — each request may run on a different isolate

## References

See `references/edge-runtime-guide.md` for Cloudflare bindings deep-dive, Vercel Edge setup, and storage decision trees.
