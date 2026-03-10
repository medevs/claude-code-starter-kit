# Hono API Rules

**Version Pins:** Hono 4.x+, TypeScript 5.4+

## Project Structure

```
src/
  index.ts                   # App entry point, runtime adapter
  routes/
    products.ts              # Product routes
    auth.ts                  # Auth routes
    index.ts                 # Route aggregation
  middleware/
    auth.ts                  # JWT/API key verification
    logger.ts                # Request logging
    cors.ts                  # CORS configuration
  schemas/
    products.ts              # Zod schemas for validation
    auth.ts                  # Auth schemas
  services/
    product-service.ts       # Business logic
    auth-service.ts          # Auth logic
  lib/
    db.ts                    # Database client (D1, Postgres, etc.)
    errors.ts                # Custom error classes
  types/
    env.ts                   # Environment bindings type
```

## Routing

Use `Hono().route()` for grouped routes with shared prefixes:

```ts
import { Hono } from "hono";
import { productRoutes } from "./routes/products";
import { authRoutes } from "./routes/auth";

const app = new Hono();
app.route("/api/products", productRoutes);
app.route("/api/auth", authRoutes);

export default app;
```

## Typed Routes with Zod OpenAPI

Use `@hono/zod-openapi` for type-safe routes with auto-generated documentation:

```ts
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";

const CreateProductSchema = z.object({
  name: z.string().min(1).max(255).openapi({ example: "Widget" }),
  price: z.number().positive().openapi({ example: 29.99 }),
});

const ProductSchema = z.object({
  id: z.string(),
  name: z.string(),
  price: z.number(),
});

const route = createRoute({
  method: "post",
  path: "/",
  request: { body: { content: { "application/json": { schema: CreateProductSchema } } } },
  responses: { 201: { content: { "application/json": { schema: ProductSchema } }, description: "Product created" } },
});

const app = new OpenAPIHono();
app.openapi(route, async (c) => {
  const body = c.req.valid("json");
  const product = await productService.create(body);
  return c.json(product, 201);
});
```

## Request Validation

Use `@hono/zod-validator` for request validation:

```ts
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";

const querySchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
});

app.get("/products", zValidator("query", querySchema), async (c) => {
  const { page, limit } = c.req.valid("query");
  const products = await productService.list({ page, limit });
  return c.json({ data: products });
});
```

## Runtime Adapters

Hono runs on any JavaScript runtime. Use the correct adapter:

```ts
// Cloudflare Workers (default export)
export default app;

// Node.js
import { serve } from "@hono/node-server";
serve({ fetch: app.fetch, port: 3000 });

// Bun
export default { fetch: app.fetch, port: 3000 };
```

## Context and Bindings

```ts
// Type your environment bindings
type Env = {
  Bindings: { DB: D1Database; KV: KVNamespace; API_KEY: string };
  Variables: { user: User; requestId: string };
};

const app = new Hono<Env>();

// Access bindings via c.env, request-scoped variables via c.var
app.use("*", async (c, next) => {
  c.set("requestId", crypto.randomUUID());
  await next();
});

app.get("/products", async (c) => {
  const db = c.env.DB;                    // Cloudflare D1 binding
  const requestId = c.get("requestId");   // Request-scoped variable
  return c.json({ data: products });
});
```

## Error Handling

```ts
import { HTTPException } from "hono/http-exception";

// Throw HTTPException for expected errors
app.get("/products/:id", async (c) => {
  const product = await productService.findById(c.req.param("id"));
  if (!product) throw new HTTPException(404, { message: "Product not found" });
  return c.json(product);
});

// Global error handler
app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: { code: err.status, message: err.message } }, err.status);
  }
  console.error("Unhandled error:", err);
  return c.json({ error: { code: 500, message: "Internal server error" } }, 500);
});
```

## Middleware

```ts
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { secureHeaders } from "hono/secure-headers";
import { jwt } from "hono/jwt";

app.use("*", logger());
app.use("*", secureHeaders());
app.use("/api/*", cors({ origin: ["https://example.com"], allowMethods: ["GET", "POST", "PUT", "DELETE"] }));
app.use("/api/protected/*", jwt({ secret: "your-secret" }));
```

## Testing

Use `app.request()` for integration tests — no HTTP server needed:

```ts
import { describe, it, expect } from "vitest";
import app from "../src/index";

describe("POST /api/products", () => {
  it("creates a product and returns 201", async () => {
    const res = await app.request("/api/products", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: "Widget", price: 29.99 }),
    });
    expect(res.status).toBe(201);
    const data = await res.json();
    expect(data.name).toBe("Widget");
  });

  it("returns 400 for invalid input", async () => {
    const res = await app.request("/api/products", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: "", price: -1 }),
    });
    expect(res.status).toBe(400);
  });
});
```

## DO NOT Use

- Express-style middleware (`req, res, next`) — use Hono's `c` (Context) pattern
- `process.env` on edge runtimes — use `c.env` for Cloudflare bindings
- Heavy Node.js-only dependencies on edge — check runtime compatibility
- `app.listen()` — use the runtime-specific adapter (`@hono/node-server`, default export)
- Callback-based patterns — Hono is async/await native
