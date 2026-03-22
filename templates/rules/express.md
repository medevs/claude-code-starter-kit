# Express API Rules

**Version Pins:** Express 5.x+, TypeScript 5.4+, Node.js 18+

## Project Structure (Vertical Slice)

```
src/
  index.ts                     # App entry point, server setup
  features/
    todos/
      route.ts                 # Express Router — endpoint definitions
      service.ts               # Business logic (pure functions)
      schema.ts                # Zod schemas + TypeScript types
      repository.ts            # Data access (DB queries)
      todos.test.ts            # Tests (colocated)
    users/
      route.ts
      service.ts
      ...
  shared/
    middleware/
      error-handler.ts         # Centralized error handling
      validate.ts              # Zod validation middleware
      auth.ts                  # JWT/session authentication
    types/
      index.ts                 # Shared type definitions
    lib/
      db.ts                    # Database client
      logger.ts                # Structured logger
```

## App Setup

```ts
import express from "express";
import helmet from "helmet";
import cors from "cors";
import { todosRouter } from "./features/todos/route.js";
import { errorHandler } from "./shared/middleware/error-handler.js";

const app = express();

// Middleware order matters: security → parsing → routes → errors
app.use(helmet());
app.use(cors({ origin: process.env["ALLOWED_ORIGINS"]?.split(",") }));
app.use(express.json({ limit: "10kb" }));

// Mount feature routes
app.use("/api/todos", todosRouter);

// Error handler must be last
app.use(errorHandler);

export default app;
```

## Routing

Use `express.Router()` per feature. Keep handlers thin — delegate to services:

```ts
import { Router } from "express";
import type { Request, Response, NextFunction } from "express";
import { validate } from "../../shared/middleware/validate.js";
import { CreateTodoSchema, UpdateTodoSchema } from "./schema.js";
import * as todoService from "./service.js";

export const todosRouter = Router();

todosRouter.get("/", async (_req: Request, res: Response) => {
  const todos = await todoService.getAll();
  res.json(todos);
});

todosRouter.post("/", validate(CreateTodoSchema), async (req: Request, res: Response) => {
  const todo = await todoService.create(req.body);
  res.status(201).json(todo);
});

todosRouter.get("/:id", async (req: Request, res: Response, next: NextFunction) => {
  const id = req.params.id as string;
  const todo = await todoService.getById(id);
  if (!todo) { res.status(404).json({ error: "Not found" }); return; }
  res.json(todo);
});
```

## Request Validation with Zod

Create a reusable validation middleware:

```ts
// shared/middleware/validate.ts
import type { Request, Response, NextFunction } from "express";
import type { ZodSchema } from "zod";

export function validate(schema: ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      res.status(400).json({ error: "Validation failed", details: result.error.flatten() });
      return;
    }
    req.body = result.data;
    next();
  };
}
```

Define schemas per feature:

```ts
// features/todos/schema.ts
import { z } from "zod";

export const CreateTodoSchema = z.object({
  title: z.string().min(1).max(255),
});

export const UpdateTodoSchema = z.object({
  title: z.string().min(1).max(255).optional(),
  completed: z.boolean().optional(),
});

export type CreateTodoInput = z.infer<typeof CreateTodoSchema>;
export type UpdateTodoInput = z.infer<typeof UpdateTodoSchema>;
```

## Error Handling

Use a centralized error handler with custom error classes:

```ts
// shared/middleware/error-handler.ts
import type { Request, Response, NextFunction } from "express";

export class AppError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
  }
}

export function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({ error: err.message });
    return;
  }
  console.error("Unhandled error:", err);
  res.status(500).json({ error: "Internal server error" });
}
```

Wrap async handlers to catch rejected promises:

```ts
// Express 5 handles async errors automatically.
// For Express 4, use a wrapper:
export function catchAsync(fn: (req: Request, res: Response, next: NextFunction) => Promise<void>) {
  return (req: Request, res: Response, next: NextFunction) => {
    fn(req, res, next).catch(next);
  };
}
```

## ESM Import Rules

With `"type": "module"` and `module: "nodenext"` in tsconfig:

- All relative imports **MUST** use `.js` extensions: `from "./service.js"`
- Use `import type` for type-only imports: `import type { Request } from "express"`
- Use `process.env["KEY"]` (bracket notation) with `noUncheckedIndexedAccess`

## Testing

Use Vitest with supertest for integration tests:

```ts
import { describe, it, expect, beforeEach } from "vitest";
import request from "supertest";
import app from "../../index.js";

describe("POST /api/todos", () => {
  it("should create a todo and return 201", async () => {
    const res = await request(app)
      .post("/api/todos")
      .send({ title: "Buy milk" })
      .expect(201);

    expect(res.body.title).toBe("Buy milk");
    expect(res.body.id).toBeDefined();
  });

  it("should return 400 when title is missing", async () => {
    await request(app)
      .post("/api/todos")
      .send({})
      .expect(400);
  });
});
```

For unit tests, test service functions directly without HTTP:

```ts
import { describe, it, expect } from "vitest";
import * as todoService from "./service.js";

describe("todoService.create", () => {
  it("should create a todo with correct defaults", () => {
    const todo = todoService.create({ title: "Test" });
    expect(todo.completed).toBe(false);
  });
});
```

## Security Checklist

- Use `helmet()` for secure HTTP headers
- Set `express.json({ limit: "10kb" })` to prevent large payloads
- Configure CORS with explicit allowed origins — never `*` in production
- Use `express-rate-limit` on auth endpoints
- Validate all input with Zod at the boundary
- Never expose raw error details in production responses

## DO NOT Use

- `req.params.id` without type assertion — Express 5 types it as `string | string[] | undefined`
- `app.listen()` in the same file as app creation — separate for testability
- Callback-style middleware (`err` parameter) without 4 arguments — Express needs all 4 for error middleware
- `any` for request body — use Zod schemas with `z.infer<>` for type safety
- `require()` in ESM projects — use `import` with `.js` extensions
