# Architecture Principles

## Vertical Slice Architecture (Recommended)

Organize by feature, not by layer:

```
# ✅ Vertical Slices (by feature)          # ❌ Horizontal Layers
features/                                   controllers/
  auth/                                       user_controller.py
    route.ts                                  product_controller.py
    service.ts                              services/
    repository.ts                             user_service.py
    schema.ts                                 product_service.py
    auth.test.ts                            repositories/
  products/                                   user_repository.py
    route.ts                                  product_repository.py
    service.ts
    ...
```

- Each feature is self-contained: route, logic, data access, types, tests
- Features can be developed, tested, and deployed independently
- New developers understand a feature by reading one directory

## Dependency Rules

- Features depend on `shared/` or `lib/`, never on each other
- Shared code: only extract when used by 3+ features
- Clear dependency direction: features → shared → core
- No circular dependencies between modules

## Module Design

- Entry points are thin wrappers that compose features
- Configuration lives in environment variables, never in code
- Each module exposes a clean public API — internals are private
- Prefer explicit imports over re-export files

## Data Flow

- Validate at the boundary, transform to internal types immediately
- Use DTOs/schemas for external data, domain models internally
- Keep business logic pure — no I/O in core logic functions
- Side effects (DB, API, file I/O) at the edges, not in business logic
