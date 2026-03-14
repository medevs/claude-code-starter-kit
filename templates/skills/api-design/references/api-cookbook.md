# API Design Cookbook

Complete endpoint implementations, middleware patterns, and templates.

## Complete CRUD Endpoint Example

Express/Node.js style with framework-agnostic patterns.

### GET List with Filtering, Sorting, Pagination

```ts
router.get("/products", async (req, res) => {
  const { category, sort = "-created_at", cursor, limit = "20" } = req.query;
  const filters: ProductFilters = {};
  if (category) filters.category = String(category);

  const sortDir = String(sort).startsWith("-") ? "desc" : "asc";
  const sortCol = String(sort).replace(/^-/, "");
  const pageSize = Math.min(Number(limit), 100);

  const products = await productService.list({
    filters, sort: { column: sortCol, direction: sortDir },
    cursor: cursor ? String(cursor) : undefined,
    limit: pageSize + 1, // extra to check has_more
  });

  const hasMore = products.length > pageSize;
  const data = hasMore ? products.slice(0, pageSize) : products;
  res.json({
    data,
    pagination: { next_cursor: hasMore ? encodeCursor(data.at(-1)!.id) : null, has_more: hasMore },
  });
});
```

### GET Single / POST / PATCH / DELETE

```ts
// GET /products/:id
router.get("/products/:id", async (req, res) => {
  const product = await productService.findById(req.params.id);
  if (!product) throw new NotFoundError(`Product ${req.params.id} not found`);
  res.json({ data: product });
});

// POST /products
router.post("/products", async (req, res) => {
  const validated = createProductSchema.parse(req.body);
  const product = await productService.create(validated);
  res.status(201).json({ data: product });
});

// PATCH /products/:id
router.patch("/products/:id", async (req, res) => {
  const product = await productService.findById(req.params.id);
  if (!product) throw new NotFoundError(`Product ${req.params.id} not found`);
  const updated = await productService.update(req.params.id, updateProductSchema.parse(req.body));
  res.json({ data: updated });
});

// DELETE /products/:id
router.delete("/products/:id", async (req, res) => {
  const product = await productService.findById(req.params.id);
  if (!product) throw new NotFoundError(`Product ${req.params.id} not found`);
  await productService.delete(req.params.id);
  res.status(204).send();
});
```

## Error Handling Middleware

### Custom Error Classes

```ts
export class AppError extends Error {
  constructor(public statusCode: number, public code: string, message: string,
    public details?: Array<{ field: string; message: string; code: string }>) {
    super(message);
  }
}
export class ValidationError extends AppError {
  constructor(details: Array<{ field: string; message: string; code: string }>) {
    super(400, "VALIDATION_ERROR", "Validation failed", details);
  }
}
export class NotFoundError extends AppError {
  constructor(msg: string) { super(404, "NOT_FOUND", msg); }
}
export class AuthError extends AppError {
  constructor(msg = "Authentication required") { super(401, "UNAUTHORIZED", msg); }
}
```

### Centralized Error Handler

```ts
export const errorHandler: ErrorRequestHandler = (err, req, res, _next) => {
  logger.error({ error: err.message, requestId: req.id, method: req.method, path: req.path });

  if (err instanceof ZodError) {
    return res.status(400).json({
      error: { code: "VALIDATION_ERROR", message: "Invalid request data",
        details: err.errors.map((e) => ({ field: e.path.join("."), message: e.message, code: "INVALID_VALUE" })) },
    });
  }
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: { code: err.code, message: err.message, details: err.details } });
  }
  const isProd = process.env.NODE_ENV === "production";
  res.status(500).json({ error: { code: "INTERNAL_ERROR", message: isProd ? "An unexpected error occurred" : err.message } });
};
```

## Cursor-Based Pagination Implementation

### Encoding/Decoding Cursors

```ts
function encodeCursor(id: string, sortValue?: string): string {
  return Buffer.from(JSON.stringify({ id, sv: sortValue })).toString("base64url");
}

function decodeCursor(cursor: string): { id: string; sv?: string } {
  return JSON.parse(Buffer.from(cursor, "base64url").toString("utf-8"));
}
```

### Database Query with Cursor

```ts
async function listWithCursor(opts: { cursor?: string; limit: number; sortBy: string; sortDir: "asc" | "desc" }) {
  let query = db.select().from(products).orderBy(
    opts.sortDir === "asc" ? asc(products[opts.sortBy]) : desc(products[opts.sortBy])
  );
  if (opts.cursor) {
    const { id, sv } = decodeCursor(opts.cursor);
    const op = opts.sortDir === "desc" ? lt : gt;
    query = query.where(or(op(products[opts.sortBy], sv), and(eq(products[opts.sortBy], sv), gt(products.id, id))));
  }
  return query.limit(opts.limit);
}
```

## Rate Limiting Patterns

### Token Bucket Middleware

```ts
function rateLimitMiddleware(config: { maxTokens: number; refillRate: number; keyPrefix: string }) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const key = req.user?.id || req.ip;
    const result = await checkRateLimit(redis, `${config.keyPrefix}:${key}`, config);

    res.set({
      "X-RateLimit-Limit": String(config.maxTokens),
      "X-RateLimit-Remaining": String(result.remaining),
      "X-RateLimit-Reset": String(result.resetAt),
    });

    if (!result.allowed) {
      res.set("Retry-After", String(Math.ceil((result.resetAt - Date.now()) / 1000)));
      throw new AppError(429, "RATE_LIMITED", "Too many requests");
    }
    next();
  };
}

// Different limits by operation type
router.get("/products", rateLimitMiddleware({ maxTokens: 100, refillRate: 10, keyPrefix: "read" }));
router.post("/products", rateLimitMiddleware({ maxTokens: 20, refillRate: 2, keyPrefix: "write" }));
```

## OpenAPI/Swagger Template

```yaml
openapi: "3.1.0"
info:
  title: My API
  version: 1.0.0
servers:
  - url: https://api.example.com/v1

components:
  schemas:
    Error:
      type: object
      required: [error]
      properties:
        error:
          type: object
          required: [code, message]
          properties:
            code: { type: string, example: VALIDATION_ERROR }
            message: { type: string }
            details:
              type: array
              items:
                type: object
                properties:
                  field: { type: string }
                  message: { type: string }
                  code: { type: string }
    PaginationCursor:
      type: object
      properties:
        next_cursor: { type: string, nullable: true }
        has_more: { type: boolean }
  securitySchemes:
    BearerAuth: { type: http, scheme: bearer, bearerFormat: JWT }
    ApiKeyAuth: { type: apiKey, in: header, name: X-API-Key }

security:
  - BearerAuth: []

paths:
  /products:
    get:
      summary: List products
      parameters:
        - { name: cursor, in: query, schema: { type: string } }
        - { name: limit, in: query, schema: { type: integer, default: 20, maximum: 100 } }
      responses:
        "200":
          description: Product list
          content:
            application/json:
              schema:
                type: object
                properties:
                  data: { type: array, items: { $ref: "#/components/schemas/Product" } }
                  pagination: { $ref: "#/components/schemas/PaginationCursor" }
```

## GraphQL Schema Examples

### Type Definitions with Relay Connections

```graphql
type Query {
  product(id: ID!): Product
  products(first: Int, after: String, filter: ProductFilter): ProductConnection!
}

type Mutation {
  createProduct(input: CreateProductInput!): Product!
  updateProduct(id: ID!, input: UpdateProductInput!): Product!
  deleteProduct(id: ID!): Boolean!
}

type Product {
  id: ID!
  name: String!
  price: Float!
  category: Category!
  createdAt: DateTime!
}

type ProductConnection {
  edges: [ProductEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type ProductEdge { node: Product!; cursor: String! }
type PageInfo { hasNextPage: Boolean!; endCursor: String }

input ProductFilter { category: String; minPrice: Float; maxPrice: Float }
input CreateProductInput { name: String!; price: Float!; categoryId: ID! }
input UpdateProductInput { name: String; price: Float; categoryId: ID }
```

### DataLoader for N+1 Prevention

```ts
import DataLoader from "dataloader";

function createLoaders() {
  return {
    categoryLoader: new DataLoader<string, Category>(async (ids) => {
      const categories = await db.category.findMany({ where: { id: { in: [...ids] } } });
      const map = new Map(categories.map((c) => [c.id, c]));
      return ids.map((id) => map.get(id) ?? new Error(`Category ${id} not found`));
    }),
  };
}

// Resolver: Product.category = (product, _, ctx) => ctx.loaders.categoryLoader.load(product.categoryId)
```

## API Testing Patterns

### Contract and Error Testing

```ts
describe("POST /api/v1/products", () => {
  it("should return 201 with created product", async () => {
    const res = await request(app).post("/api/v1/products").send({ name: "Widget", price: 29.99, categoryId: "cat-1" });
    expect(res.status).toBe(201);
    expect(res.body.data).toMatchObject({ id: expect.any(String), name: "Widget", price: 29.99 });
  });

  it("should return 400 for invalid input", async () => {
    const res = await request(app).post("/api/v1/products").send({});
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("VALIDATION_ERROR");
    expect(res.body.error.details).toEqual(expect.arrayContaining([expect.objectContaining({ field: "name" })]));
  });
});

describe("Authentication", () => {
  it("should return 401 without token", async () => {
    const res = await request(app).get("/api/v1/products");
    expect(res.status).toBe(401);
  });

  it("should return 403 with insufficient permissions", async () => {
    const token = createTestToken({ role: "viewer" });
    const res = await request(app).delete("/api/v1/products/p-1").set("Authorization", `Bearer ${token}`);
    expect(res.status).toBe(403);
  });
});

describe("Error scenarios", () => {
  it("should return 404 for non-existent resource", async () => {
    const res = await request(app).get("/api/v1/products/nonexistent");
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("NOT_FOUND");
  });

  it("should return 409 for duplicate resource", async () => {
    await createProduct({ slug: "existing" });
    const res = await request(app).post("/api/v1/products").send({ name: "Dup", slug: "existing", price: 10 });
    expect(res.status).toBe(409);
  });
});
```
