---
name: database
description: >
  Teaches database schema design, migration patterns, query optimization, and
  indexing strategies. Use when designing or modifying database schemas, writing
  migration files, troubleshooting slow queries, choosing indexing strategies,
  setting up connection pooling, or deciding between SQL and NoSQL for a data model.
---

# Database Patterns

## When to Use This Skill

- Designing or modifying database schemas
- Writing or reviewing migration files
- Troubleshooting slow queries or missing indexes
- Choosing indexing strategies for read-heavy or write-heavy workloads
- Setting up connection pooling
- Deciding between SQL and NoSQL for a data model

## When NOT to Use This Skill

- API endpoint design (use api-design skill)
- Application-layer business logic
- Frontend data management or state management
- Authentication/authorization logic (use security patterns)

## Schema Design Checklist

- [ ] Table/column naming follows conventions (plural snake_case tables, singular snake_case columns)
- [ ] Primary keys defined (`id` with auto-increment or UUID)
- [ ] Foreign key constraints added (not just application-level)
- [ ] `created_at` and `updated_at` timestamps on every table
- [ ] Appropriate data types (`TIMESTAMPTZ`, `TEXT`, `NUMERIC` for money)
- [ ] Indexes on foreign keys and frequently queried columns
- [ ] Boolean columns prefixed with `is_`, `has_`, `can_`

## Schema Design Essentials

### Naming Conventions

- Tables: plural snake_case (`users`, `order_items`, `user_preferences`)
- Columns: singular snake_case (`email`, `created_at`, `is_active`)
- Primary keys: `id` (auto-increment integer or UUID)
- Foreign keys: `<singular_table>_id` (e.g., `user_id`, `order_id`)

### Essential Columns for Every Table

```sql
id          SERIAL PRIMARY KEY,  -- or UUID
created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

### Relationships

- One-to-many: Foreign key on the "many" side
- Many-to-many: Junction/join table with composite key
- One-to-one: Foreign key with UNIQUE constraint (prefer merging if possible)
- Always add foreign key constraints — never rely on application logic alone

### Data Types

- Use `TIMESTAMPTZ` not `TIMESTAMP` (always store timezone)
- Use `TEXT` for variable-length strings (no performance difference with VARCHAR in PostgreSQL)
- Use `NUMERIC`/`DECIMAL` for money — never `FLOAT`
- Use `JSONB` sparingly for truly dynamic/unstructured data
- Use `ENUM` types for fixed sets of values (status, role)

## ORM Options

### Prisma (TypeScript)
Type-safe ORM with declarative schema and auto-generated migrations. Best for TypeScript projects wanting schema-first design with excellent DX.

### Drizzle ORM (TypeScript)
SQL-like TypeScript ORM with zero overhead. Best for developers who prefer writing SQL-like queries with full type safety:

```ts
import { drizzle } from "drizzle-orm/node-postgres";
import { pgTable, serial, text, timestamp } from "drizzle-orm/pg-core";

const users = pgTable("users", {
  id: serial("id").primaryKey(),
  email: text("email").notNull().unique(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

const db = drizzle(pool);
const result = await db.select().from(users).where(eq(users.email, "user@example.com"));
```

### SQLAlchemy (Python)
Mature ORM with both Core (SQL expression) and ORM (mapped classes) APIs. Use 2.0+ async style.

### When to Choose
- **Prisma** → TypeScript, schema-first, rapid prototyping, great migrations
- **Drizzle** → TypeScript, SQL-first, lightweight, maximum control
- **SQLAlchemy** → Python, complex queries, mature ecosystem

## pgvector for AI/Embeddings

For projects using AI embeddings or semantic search:

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE documents (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  embedding vector(1536)  -- OpenAI ada-002 dimensions
);

-- Use HNSW index for fast approximate nearest neighbor search
CREATE INDEX idx_documents_embedding ON documents USING hnsw (embedding vector_cosine_ops);

-- Query: find similar documents
SELECT id, content, embedding <=> '[0.1, 0.2, ...]'::vector AS distance
FROM documents ORDER BY distance LIMIT 10;
```

- Use HNSW index for most workloads (faster queries, more memory)
- Use IVFFlat index for very large datasets with memory constraints
- Choose distance operator based on your embedding model: `<=>` (cosine), `<->` (L2), `<#>` (inner product)

## Migration Safety Checklist

- [ ] Migration is reversible (has `up` AND `down`)
- [ ] One logical change per migration
- [ ] Add column as nullable first, then backfill, then add constraint
- [ ] Use `CONCURRENTLY` for index creation
- [ ] Tested against copy of production data
- [ ] Never modify already-applied migrations

### Safe Migration Strategies

- **Add column**: Add as nullable first, backfill data, then add NOT NULL constraint
- **Remove column**: Stop reading from column, deploy, remove column in next migration
- **Rename column**: Add new column, copy data, update code, remove old column
- **Add index**: Use `CREATE INDEX CONCURRENTLY` (PostgreSQL) to avoid locking

### Migration Naming

```
YYYY-MM-DD-HHMMSS_description.sql
001_create_users_table.sql
002_add_email_index.sql
```

## Query Optimization

### Indexing Strategy

- Index all foreign keys (queries join on these)
- Index columns used in `WHERE` clauses frequently
- Index columns used in `ORDER BY` for paginated queries
- Composite indexes: put most selective column first
- Don't over-index — each index slows writes

### Common Performance Issues

- **N+1 queries**: Use eager loading / joins instead of looping queries
- **Missing indexes**: Use `EXPLAIN ANALYZE` to identify sequential scans
- **SELECT ***: Only select columns you need
- **Unbounded queries**: Always use `LIMIT` — never return entire tables
- **Missing pagination**: Use cursor-based pagination for large datasets

## Connection Management

- Use connection pooling (PgBouncer, SQLAlchemy pool, Prisma pool)
- Set appropriate pool sizes: 5-20 connections for most apps
- Close connections properly — use context managers or `finally` blocks
- Set query timeouts to prevent long-running queries from holding connections
- Monitor connection usage and pool saturation

## SQL vs NoSQL Decision Guide

### When to Use NoSQL

- Highly variable document structures
- High write throughput with eventual consistency acceptable
- Time-series data or log storage
- Caching layer (Redis)

### When to Stay with SQL

- Complex relationships between entities
- Need for ACID transactions
- Complex aggregation queries
- Data integrity is critical

## Anti-Patterns

- `SELECT *` in production queries — select only needed columns
- Missing indexes on foreign keys — causes slow joins
- Unbounded queries without `LIMIT` — can return millions of rows
- `FLOAT` for monetary values — use `NUMERIC`/`DECIMAL`
- Modifying already-applied migrations — create a new migration instead
- Storing denormalized data without a clear caching strategy
- Using application-level enforcement instead of database constraints

## References

See `references/query-optimization-guide.md` for EXPLAIN ANALYZE walkthroughs, index type deep-dives, and ORM-specific N+1 detection.
