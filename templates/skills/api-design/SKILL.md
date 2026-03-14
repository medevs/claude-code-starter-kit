---
name: api-design
description: >
  Teaches REST and GraphQL API design patterns including endpoint conventions,
  error response formats, pagination, authentication, and versioning. Use when
  designing new API endpoints, defining request/response schemas, implementing
  pagination or filtering, setting up authentication middleware, adding rate
  limiting, or choosing an API versioning strategy.
---

# API Design Patterns

## When to Use

- Designing or modifying API endpoints, request/response schemas, status codes
- Implementing pagination, filtering, sorting, or search
- Setting up authentication, authorization, or rate limiting
- Choosing an API versioning strategy

## When NOT to Use

- Frontend-only work, database schema design, or internal function APIs

## API Design Checklist

- [ ] RESTful URL structure (plural nouns, kebab-case)
- [ ] Correct HTTP methods and status codes
- [ ] Consistent error response format
- [ ] Pagination for list endpoints
- [ ] Input validation with descriptive errors
- [ ] Authentication and authorization
- [ ] Rate limiting headers
- [ ] API versioning strategy

## REST Conventions

### URL Structure
```
GET    /api/v1/users              # List users
POST   /api/v1/users              # Create user
GET    /api/v1/users/:id          # Get user
PATCH  /api/v1/users/:id          # Update user (partial)
PUT    /api/v1/users/:id          # Replace user (full)
DELETE /api/v1/users/:id          # Delete user
GET    /api/v1/users/:id/orders   # Nested resource (max 2 levels)
```

- Use plural nouns: `/users` not `/user`
- Use kebab-case: `/order-items` not `/orderItems`
- Use query params for filtering and sorting: `?status=active&sort=-created_at`

### Status Codes
- `200` OK -- Successful GET, PATCH, PUT
- `201` Created -- Successful POST
- `204` No Content -- Successful DELETE
- `400` Bad Request -- Validation error
- `401` Unauthorized -- Missing or invalid auth
- `403` Forbidden -- Auth valid but no permission
- `404` Not Found -- Resource doesn't exist
- `409` Conflict -- Duplicate or state conflict
- `422` Unprocessable Entity -- Valid syntax, invalid semantics
- `429` Too Many Requests -- Rate limited
- `500` Internal Server Error -- Unexpected server error

## TypeScript-First API Frameworks

Modern TypeScript API frameworks provide end-to-end type safety and better DX:

- **tRPC**: End-to-end type safety between client and server without code generation. Best for full-stack TypeScript apps where you control both client and server.
- **Express/Fastify**: Mature Node.js frameworks with large ecosystem and middleware support.

### When to Choose
- **Next.js API Routes** → Full-stack Next.js app, co-located frontend and backend
- **FastAPI** → Python backend, async, auto-generated OpenAPI docs
- **tRPC** → Full-stack TS monorepo, no REST needed, maximum type safety
- **Express/Fastify** → Large existing ecosystem, many middleware dependencies

## Error Response Format

Use a consistent format across all endpoints:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description of the error",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address",
        "code": "INVALID_FORMAT"
      }
    ]
  }
}
```

- Always include a machine-readable `code` and human-readable `message`
- Use `details` array for field-level validation errors
- Never expose stack traces or internal error details in production

## Pagination

### Cursor-Based (Recommended)
```json
{
  "data": [],
  "pagination": { "next_cursor": "eyJpZCI6MTAwfQ==", "has_more": true }
}
```
Best for: infinite scroll, real-time data, large datasets. Consistent under inserts/deletes.

### Offset-Based
```json
{
  "data": [],
  "pagination": { "page": 1, "per_page": 20, "total": 156, "total_pages": 8 }
}
```
Best for: numbered pages, admin dashboards. Simpler but inconsistent under concurrent writes.

## Authentication Patterns

### JWT (Stateless)
- Access token: short-lived (15 min), sent in `Authorization: Bearer <token>`
- Refresh token: long-lived (7-30 days), stored in httpOnly cookie
- Include only essential claims (user_id, role) -- not sensitive data

### API Keys
- For service-to-service or developer API access
- Send in header: `X-API-Key: <key>` or `Authorization: Bearer <key>`
- Scope keys to specific permissions
- Support key rotation (allow multiple active keys per client)

## GraphQL Essentials

### When to Prefer GraphQL over REST
- Clients need flexible data shapes (mobile vs web)
- Multiple related resources needed in a single request
- Rapid frontend iteration without backend changes

### Core Patterns
- **Schema-first design**: define types and operations before resolvers
- **Resolver pattern**: one resolver per field, compose for complex queries
- **N+1 prevention**: use DataLoader to batch and deduplicate database calls
- **Pagination**: use Relay-style connections (edges, nodes, pageInfo)

## Rate Limiting

- Return `429 Too Many Requests` with `Retry-After` header
- Progressive limits: stricter for writes, relaxed for reads
- Include headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Versioning

- URL prefix versioning: `/api/v1/`, `/api/v2/`
- Only increment for breaking changes
- Support previous version for a reasonable deprecation period
- Document breaking changes in a changelog

## Anti-Patterns

- **Verbs in URLs** -- `/getUsers` instead of `GET /users`
- **Exposing internal IDs or database structure** -- use UUIDs or slugs
- **Inconsistent error formats** across endpoints
- **Missing pagination** on list endpoints
- **Leaking stack traces** in production error responses
- **Ignoring idempotency** -- PUT and DELETE should be idempotent

## References

See `references/api-cookbook.md` for complete endpoint implementations, middleware patterns, and OpenAPI templates.
