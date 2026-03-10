# Query Optimization Guide

Reference for query optimization, index selection, and ORM-specific patterns.

## EXPLAIN ANALYZE Walkthrough

Run `EXPLAIN ANALYZE` before any query to see the plan with real timing. Read from innermost node outward.

### Key Node Types

| Node Type | Meaning | Performance |
|-----------|---------|-------------|
| Seq Scan | Reads every row in the table | Slow on large tables |
| Index Scan | Uses an index to find rows | Fast for selective queries |
| Index Only Scan | Reads data from index alone | Fastest — no table access |
| Bitmap Index Scan | Builds a bitmap of matching rows | Good for medium selectivity |
| Bitmap Heap Scan | Reads rows identified by bitmap | Paired with Bitmap Index Scan |
| Nested Loop | Joins by looping inner for each outer row | Fast for small inner sets |
| Hash Join | Builds hash table of one side, probes with other | Good for larger joins |
| Merge Join | Merges two sorted inputs | Good when both sides are sorted |
| Sort | Sorts rows (may spill to disk) | Watch for large sorts |
| Aggregate | Groups and aggregates rows | Normal for GROUP BY |

### Key Metrics

```
Seq Scan on orders  (cost=0.00..431.00 rows=50 width=64)
                     (actual time=0.015..2.340 rows=47 loops=1)
  Filter: (user_id = 42)
  Rows Removed by Filter: 9953
  Buffers: shared hit=181
```

- **cost**: Estimated startup..total cost (arbitrary units)
- **rows**: Estimated row count (compare with actual)
- **actual time**: Real execution time in milliseconds (startup..total)
- **loops**: Number of times this node executed
- **Buffers: shared hit**: Pages read from cache (good)
- **Buffers: shared read**: Pages read from disk (slow)
- **Rows Removed by Filter**: Rows scanned but not returned (high = inefficient)

### Before/After: Adding an Index

**Before** (no index on `user_id`):

```
Seq Scan on orders  (cost=0.00..431.00 rows=50 width=64)
                     (actual time=0.015..2.340 rows=47 loops=1)
  Filter: (user_id = 42)
  Rows Removed by Filter: 9953
  Planning Time: 0.082 ms
  Execution Time: 2.401 ms
```

**After** (`CREATE INDEX idx_orders_user_id ON orders(user_id)`):

```
Index Scan using idx_orders_user_id on orders  (cost=0.29..8.31 rows=50 width=64)
                                                (actual time=0.021..0.089 rows=47 loops=1)
  Index Cond: (user_id = 42)
  Planning Time: 0.095 ms
  Execution Time: 0.112 ms
```

The Seq Scan (2.4ms, scanning 10,000 rows) becomes an Index Scan (0.1ms, reading only 47 rows).

### Common Plan Patterns

- **Seq Scan + Filter removing many rows**: Missing index
- **Nested Loop with inner Seq Scan**: Missing index on join column
- **Sort with large row count**: Add index matching ORDER BY
- **Bitmap Heap Scan + Recheck Cond**: Work_mem too small or many matching rows

## Index Types Deep-Dive

### B-tree (Default)

```sql
CREATE INDEX idx_users_email ON users(email);
```

- Best for: equality, range (`<`, `>`, `BETWEEN`), `ORDER BY`, `IS NULL`
- Default type — use unless you have a specific reason not to
- Supports `LIKE 'prefix%'` but not `LIKE '%suffix'`

### Hash

- Best for: equality-only lookups. Smaller than B-tree for this case.
- Cannot support range queries or sorting. Rarely used.

### GIN (Generalized Inverted Index)

```sql
CREATE INDEX idx_posts_tags ON posts USING gin(tags);
CREATE INDEX idx_docs_content ON documents USING gin(to_tsvector('english', content));
```

- Best for: full-text search, JSONB containment (`@>`), array operations
- Slower to update than B-tree; `jsonb_path_ops` variant is faster for containment

### GiST (Generalized Search Tree)

- Best for: geometric data (PostGIS), range types, full-text (alternative to GIN)
- Supports nearest-neighbor queries (`ORDER BY <-> point`)

### BRIN (Block Range Index)

```sql
CREATE INDEX idx_logs_created ON logs USING brin(created_at);
```

- Best for: large tables with naturally ordered data (timestamps, sequential IDs)
- Extremely small index size (stores min/max per block range)
- Works well when correlated data is physically adjacent on disk
- Poor performance if data is randomly distributed
- Ideal for append-only tables like logs and events

### Partial Indexes

```sql
CREATE INDEX idx_orders_active ON orders(created_at)
  WHERE status = 'active';

CREATE INDEX idx_users_unverified ON users(email)
  WHERE is_verified = false;
```

- Index only rows matching a condition
- Much smaller than full indexes
- Queries must include the WHERE clause to use the index
- Great for filtering on common status values

### Composite Indexes

```sql
-- Supports: WHERE user_id = ? AND created_at > ?
-- Supports: WHERE user_id = ?
-- Does NOT efficiently support: WHERE created_at > ? (without user_id)
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);
```

- Column order matters: leftmost columns can be used independently
- Put equality columns first, then range columns
- Put most selective column first for equality-only queries
- A composite index on `(a, b)` can serve queries on `(a)` but not `(b)` alone

## Query Anti-Patterns with Fixes

### N+1 Queries

**Problem**: Fetching a list, then querying related data in a loop.

```python
# BAD: 1 query for users + N queries for orders
users = db.query("SELECT * FROM users LIMIT 100")
for user in users:
    orders = db.query("SELECT * FROM orders WHERE user_id = %s", user.id)
```

**Fix**: Use a JOIN or IN clause.

```python
# GOOD: 1 query with JOIN
results = db.query("""
    SELECT u.*, o.*
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id
    WHERE u.id IN (SELECT id FROM users LIMIT 100)
""")
```

### Implicit Type Casting

**Problem**: Type mismatch prevents index use.

```sql
-- BAD: id is integer, but '123' is text — PostgreSQL casts, may skip index
SELECT * FROM users WHERE id = '123';

-- GOOD: use correct type
SELECT * FROM users WHERE id = 123;
```

### OR Conditions Preventing Index Use

**Problem**: OR across different columns prevents single index scan.

```sql
-- BAD: can't use a single index efficiently
SELECT * FROM users WHERE email = 'a@b.com' OR phone = '555-1234';

-- GOOD: rewrite as UNION
SELECT * FROM users WHERE email = 'a@b.com'
UNION
SELECT * FROM users WHERE phone = '555-1234';
```

### Functions on Indexed Columns

**Problem**: Applying a function prevents index use.

```sql
-- BAD: index on email won't be used
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- GOOD: create an expression index
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';
```

### Correlated Subqueries

**Problem**: Subquery re-executes for every row.

```sql
-- BAD: correlated subquery
SELECT u.*, (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.id) AS order_count
FROM users u;

-- GOOD: rewrite as JOIN with aggregation
SELECT u.*, COALESCE(o.order_count, 0) AS order_count
FROM users u
LEFT JOIN (SELECT user_id, COUNT(*) AS order_count FROM orders GROUP BY user_id) o
  ON o.user_id = u.id;
```

### Leading Wildcard LIKE

**Problem**: `LIKE '%term'` cannot use a standard B-tree index.

```sql
-- BAD: full table scan
SELECT * FROM products WHERE name LIKE '%widget%';

-- GOOD: use trigram index for partial matches
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
SELECT * FROM products WHERE name LIKE '%widget%';

-- ALTERNATIVE: use full-text search for natural language
CREATE INDEX idx_products_fts ON products USING gin(to_tsvector('english', name));
SELECT * FROM products WHERE to_tsvector('english', name) @@ to_tsquery('widget');
```

## N+1 Detection by ORM

### Prisma (TypeScript/JavaScript)

```typescript
// BAD: N+1
const users = await prisma.user.findMany();
for (const user of users) {
    const orders = await prisma.order.findMany({ where: { userId: user.id } });
}

// GOOD: eager loading with include
const users = await prisma.user.findMany({
    include: { orders: true }
});

// Enable query logging to detect N+1
const prisma = new PrismaClient({ log: ['query'] });
```

### SQLAlchemy (Python)

```python
# BAD: lazy loading triggers N+1
users = session.query(User).all()
for user in users:
    print(user.orders)  # Each access fires a query

# GOOD: eager loading strategies
from sqlalchemy.orm import joinedload, selectinload

# joinedload: single query with JOIN (good for one-to-one, small one-to-many)
users = session.query(User).options(joinedload(User.orders)).all()

# selectinload: separate IN query (good for large one-to-many)
users = session.query(User).options(selectinload(User.orders)).all()
```

### Django (Python)

```python
# BAD: N+1
for order in Order.objects.all():
    print(order.user.name)  # Hits DB for each user

# GOOD: select_related for ForeignKey/OneToOne (uses JOIN)
orders = Order.objects.select_related('user').all()

# GOOD: prefetch_related for ManyToMany/reverse FK (uses IN query)
users = User.objects.prefetch_related('orders').all()
```

### TypeORM (TypeScript)

```typescript
// BAD: lazy relations trigger N+1
const users = await userRepository.find();
for (const user of users) {
    const orders = await user.orders;  // Lazy load
}

// GOOD: eager loading with relations
const users = await userRepository.find({ relations: ['orders'] });

// GOOD: query builder with join
const users = await userRepository
    .createQueryBuilder('user')
    .leftJoinAndSelect('user.orders', 'order')
    .getMany();
```

### ActiveRecord (Ruby)

```ruby
# BAD: N+1
User.all.each { |user| puts user.orders.count }

# GOOD: includes (lets Rails choose strategy)
User.includes(:orders).each { |user| puts user.orders.count }

# GOOD: eager_load (forces LEFT JOIN)
User.eager_load(:orders).all

# GOOD: preload (forces separate query)
User.preload(:orders).all
```

## Migration Rollback Strategies

### Reversible Migrations

Always write both `up` and `down`. For destructive changes, document that data loss occurs on rollback:

```sql
-- up
ALTER TABLE users ADD COLUMN bio TEXT;
-- down
ALTER TABLE users DROP COLUMN bio;
```

### Zero-Downtime Migrations

1. **Expand-contract pattern**: Add new structure, migrate data, remove old structure
2. **Feature flags**: Decouple code deployment from schema migration
3. **Dual-write**: Write to both old and new columns during transition

## Connection Pool Sizing

### Formula

```
connections = (cores * 2) + effective_spindle_count
```

For SSDs (spindle count ~ 1): a 4-core machine needs approximately 9 connections.

### Typical Configurations

| Application Type | Pool Size | Notes |
|-----------------|-----------|-------|
| Small web app | 5-10 | Single server |
| Medium web app | 10-20 | Multiple servers, share limit |
| Background workers | 3-5 | Long-running queries |
| Microservices | 3-10 per service | Coordinate total across services |

### PgBouncer Modes

- **Session**: One server connection per client session (most compatible)
- **Transaction**: Connection returned after each transaction (most efficient)
- **Statement**: Connection returned after each statement (limited — no transactions)

Use **transaction mode** for most web applications. Use **session mode** if you need prepared statements or advisory locks.

### Monitoring

- Track active, idle, and waiting connections
- Alert when pool utilization exceeds 80%
- Monitor average connection wait time
- Check for connection leaks (connections not returned to pool)

## Monitoring Checklist

- [ ] Slow query log enabled (queries > 100ms)
- [ ] Connection pool utilization tracked and alerted
- [ ] Table bloat monitored and vacuum frequency reviewed
- [ ] Index usage statistics checked (`pg_stat_user_indexes`)
- [ ] Lock wait times monitored for deadlock detection
- [ ] Replication lag tracked (if applicable)

## Drizzle ORM N+1 Detection

### Drizzle (TypeScript)

```typescript
import { eq } from "drizzle-orm";
import { drizzle } from "drizzle-orm/node-postgres";

// BAD: N+1 — querying orders in a loop
const allUsers = await db.select().from(users);
for (const user of allUsers) {
  const userOrders = await db.select().from(orders).where(eq(orders.userId, user.id));
}

// GOOD: Single query with join
const usersWithOrders = await db
  .select()
  .from(users)
  .leftJoin(orders, eq(users.id, orders.userId));

// GOOD: Relational queries API (if using drizzle relational)
const result = await db.query.users.findMany({
  with: { orders: true },
});

// Enable query logging to detect N+1
const db = drizzle(pool, { logger: true });
```

## pgvector Index Selection

When using `pgvector` for vector similarity search, index choice significantly impacts performance:

### HNSW (Hierarchical Navigable Small World)

```sql
-- Best for most workloads: fast queries, higher memory usage
CREATE INDEX idx_docs_embedding_hnsw ON documents
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Tune search accuracy vs speed at query time
SET hnsw.ef_search = 100;  -- Higher = more accurate, slower
```

- Build time: slower (builds graph structure)
- Query time: faster (logarithmic search)
- Memory: higher (stores graph connections)
- Best for: datasets under 10M vectors, low-latency requirements

### IVFFlat (Inverted File with Flat Compression)

```sql
-- Best for very large datasets with memory constraints
CREATE INDEX idx_docs_embedding_ivf ON documents
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);  -- sqrt(num_rows) is a good starting point

-- Tune search accuracy vs speed at query time
SET ivfflat.probes = 10;  -- Higher = more accurate, slower
```

- Build time: faster (clusters vectors)
- Query time: slower (scans cluster lists)
- Memory: lower (stores cluster assignments)
- Best for: datasets over 10M vectors, memory-constrained environments

### Distance Operators

| Operator | Distance | Use When |
|----------|----------|----------|
| `<=>` | Cosine | Default for most embedding models (OpenAI, Cohere) |
| `<->` | L2 (Euclidean) | When magnitude matters |
| `<#>` | Inner Product | When embeddings are normalized |
