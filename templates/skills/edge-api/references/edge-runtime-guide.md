# Edge Runtime Guide

Deep reference for edge runtime APIs, Cloudflare bindings, Vercel Edge, and storage patterns.

## Cloudflare Workers Setup

### wrangler.toml Configuration

```toml
name = "my-api"
main = "src/index.ts"
compatibility_date = "2024-12-01"

[vars]
ENVIRONMENT = "production"

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxxx-xxxx-xxxx"

[[kv_namespaces]]
binding = "KV"
id = "xxxx-xxxx-xxxx"

[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"

[[queues.producers]]
binding = "QUEUE"
queue = "my-queue"
```

### Local Development

```bash
# Start local dev server with bindings
npx wrangler dev

# Create D1 database
npx wrangler d1 create my-database

# Run D1 migrations
npx wrangler d1 migrations apply my-database

# Create KV namespace
npx wrangler kv namespace create KV

# Deploy to Cloudflare
npx wrangler deploy
```

## D1 Database Deep-Dive

### Migration Files

```sql
-- migrations/0001_create_users.sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_users_email ON users(email);
```

### Batch Operations

```ts
// D1 supports batch operations for transactions
const results = await c.env.DB.batch([
  c.env.DB.prepare("INSERT INTO orders (user_id, total) VALUES (?, ?)").bind(userId, total),
  c.env.DB.prepare("UPDATE users SET order_count = order_count + 1 WHERE id = ?").bind(userId),
]);
// All statements execute atomically
```

### Query Patterns

```ts
// Parameterized queries (always use — prevents SQL injection)
const user = await c.env.DB.prepare(
  "SELECT * FROM users WHERE email = ?"
).bind(email).first();

// Pagination with cursor
const { results } = await c.env.DB.prepare(
  "SELECT * FROM products WHERE id > ? ORDER BY id ASC LIMIT ?"
).bind(cursor || 0, pageSize).all();
```

## KV Store Patterns

### With Metadata

```ts
// Store value with metadata for filtering without reading full value
await c.env.KV.put("session:abc123", JSON.stringify(sessionData), {
  metadata: { userId: "user-1", expiresAt: Date.now() + 3600000 },
  expirationTtl: 3600,
});

// List with prefix and metadata
const { keys } = await c.env.KV.list({ prefix: "session:" });
for (const key of keys) {
  console.log(key.name, key.metadata);  // Access metadata without reading value
}
```

### Caching Pattern

```ts
async function getWithCache<T>(kv: KVNamespace, key: string, fetchFn: () => Promise<T>, ttl = 300): Promise<T> {
  // Try cache first
  const cached = await kv.get(key, "json");
  if (cached) return cached as T;

  // Fetch fresh data
  const fresh = await fetchFn();
  // Non-blocking cache write
  await kv.put(key, JSON.stringify(fresh), { expirationTtl: ttl });
  return fresh;
}
```

## R2 Object Storage Patterns

### Presigned URLs for Direct Upload

```ts
app.post("/upload-url", async (c) => {
  const { filename, contentType } = await c.req.json();
  const key = `uploads/${crypto.randomUUID()}/${filename}`;

  // Generate a presigned URL for direct client upload
  const url = await c.env.BUCKET.createMultipartUpload(key, {
    httpMetadata: { contentType },
  });

  return c.json({ uploadId: url.uploadId, key });
});
```

### Serving Files with Range Support

```ts
app.get("/files/:key{.+}", async (c) => {
  const key = c.req.param("key");
  const range = c.req.header("range");

  const object = range
    ? await c.env.BUCKET.get(key, { range })
    : await c.env.BUCKET.get(key);

  if (!object) throw new HTTPException(404, { message: "File not found" });

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set("etag", object.httpEtag);

  if (range) {
    headers.set("content-range", `bytes ${object.range.offset}-${object.range.offset + object.range.length - 1}/${object.size}`);
    return new Response(object.body, { status: 206, headers });
  }

  return new Response(object.body, { headers });
});
```

## Durable Objects

Durable Objects provide strongly consistent, stateful coordination at the edge.

### Counter Example

```ts
export class Counter {
  private state: DurableObjectState;
  private value = 0;

  constructor(state: DurableObjectState) {
    this.state = state;
    this.state.blockConcurrencyWhile(async () => {
      this.value = (await this.state.storage.get("value")) || 0;
    });
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/increment") {
      this.value++;
      await this.state.storage.put("value", this.value);
    }

    return Response.json({ value: this.value });
  }
}

// Usage from Worker
app.post("/counters/:name/increment", async (c) => {
  const id = c.env.COUNTER.idFromName(c.req.param("name"));
  const stub = c.env.COUNTER.get(id);
  const response = await stub.fetch(new Request("https://dummy/increment"));
  return response;
});
```

### When to Use Durable Objects
- Rate limiting with exact counts
- WebSocket coordination (chat rooms, collaboration)
- Distributed locks and semaphores
- Shopping carts or session state
- Any pattern requiring strong consistency across requests

## Vercel Edge Setup

### Edge Route Handler (App Router)

```ts
// app/api/products/route.ts
export const runtime = "edge";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const category = searchParams.get("category");

  // Use fetch to call your data API
  const res = await fetch(`${process.env.API_URL}/products?category=${category}`, {
    headers: { "Authorization": `Bearer ${process.env.API_KEY}` },
    next: { revalidate: 60 },  // Cache for 60 seconds
  });

  const products = await res.json();
  return Response.json(products);
}
```

### Edge Middleware

```ts
// middleware.ts (runs on every request at the edge)
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  // Geolocation-based routing
  const country = request.geo?.country || "US";
  if (country === "DE") {
    return NextResponse.redirect(new URL("/de", request.url));
  }

  // Add custom headers
  const response = NextResponse.next();
  response.headers.set("x-request-id", crypto.randomUUID());
  return response;
}

export const config = {
  matcher: ["/api/:path*", "/dashboard/:path*"],
};
```

## Edge Storage Decision Tree

```
Need fast key-value lookups?
  → KV (eventually consistent, <10ms reads globally)

Need SQL queries with joins?
  → D1 (SQLite, strong consistency in one region)

Need to store files/media?
  → R2 (S3-compatible, no egress fees)

Need exact counters or coordination?
  → Durable Objects (strongly consistent, stateful)

Need async task processing?
  → Queues (at-least-once delivery, retry support)

Need real-time pub/sub?
  → Durable Objects + WebSockets
```

## Performance Optimization

### Avoid Cold Starts

```ts
// Preload data during module initialization (runs once per isolate)
const CONFIG = await fetch("https://config-api.example.com/settings").then((r) => r.json());

export default {
  fetch(request: Request, env: Env) {
    // CONFIG is already available — no cold start penalty
    return handleRequest(request, env, CONFIG);
  },
};
```

### Parallel Fetches

```ts
app.get("/dashboard", async (c) => {
  // Fetch independent data in parallel
  const [user, orders, notifications] = await Promise.all([
    fetchUser(c.env, userId),
    fetchOrders(c.env, userId),
    fetchNotifications(c.env, userId),
  ]);
  return c.json({ user, orders, notifications });
});
```

### Use `waitUntil` for Non-Critical Work

```ts
app.post("/events", async (c) => {
  const event = await c.req.json();

  // Respond immediately
  const response = c.json({ received: true });

  // Process analytics in background (doesn't delay response)
  c.executionCtx.waitUntil(
    Promise.all([
      c.env.QUEUE.send(event),
      logAnalytics(c.env.KV, event),
    ])
  );

  return response;
});
```

## Error Handling at the Edge

```ts
import { HTTPException } from "hono/http-exception";

// Global error handler with structured responses
app.onError((err, c) => {
  const requestId = c.get("requestId") || "unknown";

  if (err instanceof HTTPException) {
    return c.json({
      error: { code: err.status, message: err.message, request_id: requestId },
    }, err.status);
  }

  // Log unexpected errors
  console.error(`[${requestId}] Unhandled error:`, err.message);

  return c.json({
    error: { code: 500, message: "Internal server error", request_id: requestId },
  }, 500);
});
```

## Security Patterns

### Request Validation

```ts
// Validate API key from headers
app.use("/api/*", async (c, next) => {
  const apiKey = c.req.header("x-api-key");
  if (!apiKey) throw new HTTPException(401, { message: "API key required" });

  // Check against KV store
  const keyData = await c.env.KV.get(`apikey:${apiKey}`, "json");
  if (!keyData) throw new HTTPException(401, { message: "Invalid API key" });

  c.set("apiKeyData", keyData);
  await next();
});
```

### CORS for Edge APIs

```ts
import { cors } from "hono/cors";

app.use("/api/*", cors({
  origin: ["https://myapp.com", "https://staging.myapp.com"],
  allowMethods: ["GET", "POST", "PUT", "DELETE"],
  allowHeaders: ["Content-Type", "Authorization", "X-API-Key"],
  maxAge: 86400,
}));
```

## Monitoring & Debugging

### Cloudflare Workers Logs

```bash
# Tail real-time logs
npx wrangler tail

# Filter by status
npx wrangler tail --status error

# Filter by search term
npx wrangler tail --search "product"
```

### Custom Metrics

```ts
// Use Workers Analytics Engine for custom metrics
app.use("*", async (c, next) => {
  const start = Date.now();
  await next();
  const duration = Date.now() - start;

  // Non-blocking analytics write
  c.executionCtx.waitUntil(
    c.env.ANALYTICS?.writeDataPoint({
      blobs: [c.req.method, c.req.path, String(c.res.status)],
      doubles: [duration],
    })
  );
});
```
