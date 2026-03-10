---
paths:
  - "src/api/**"
  - "app/api/**"
  - "api/**"
  - "routes/**"
  - "endpoints/**"
  - "**/*router*"
  - "**/*route*"
---

# API Design Patterns

## Request/Response Design

- Validate all request bodies with schema validation (Zod, Pydantic, joi, etc.)
- Use separate schemas for request and response — never reuse the same model for both
- Consistent error format: `{ error: { code, message, details? } }`
- Version APIs in the URL path (`/v1/`) or headers from the start

## Endpoint Design

- RESTful resource naming: plural nouns (`/users`, `/orders`), not verbs
- Use appropriate HTTP methods: GET (read), POST (create), PUT/PATCH (update), DELETE (remove)
- Return appropriate status codes: 201 (created), 204 (no content), 400 (bad request), 404 (not found)
- Paginate all list endpoints — never return unbounded collections
- Include request IDs in responses for tracing and debugging

## Safety

- Validate path and query parameters — never trust raw input
- Implement rate limiting on public and authenticated endpoints
- Return 404 instead of 403 for resources the user shouldn't know exist
- Log all 4xx/5xx responses with contextual details (endpoint, method, user, request ID)
- Never expose stack traces, internal paths, or database details in error responses
