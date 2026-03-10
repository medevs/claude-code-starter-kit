# FastAPI Rules

**Version Pins:** FastAPI 0.115+, Pydantic 2.x, Python 3.12+, SQLAlchemy 2.0+, asyncpg

## Project Structure

```
app/
  main.py                    # FastAPI app creation, lifespan, middleware
  features/
    auth/
      router.py              # Route definitions
      service.py             # Business logic
      schemas.py             # Pydantic models (request/response)
      repository.py          # Database queries
      dependencies.py        # Dependency injection
      tests/
        test_router.py
        test_service.py
    users/
      ...
  shared/
    database.py              # DB session, engine
    config.py                # Settings from env vars
    exceptions.py            # Custom exception classes
    middleware.py             # Custom middleware
```

## App Lifespan

Use the lifespan context manager — `on_startup`/`on_shutdown` are deprecated:

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: initialize DB pool, cache connections, etc.
    async with db_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown: close DB pool, flush logs, etc.
    await db_engine.dispose()

app = FastAPI(lifespan=lifespan)
```

## Pydantic Models

- Use Pydantic v2 `BaseModel` for ALL request/response schemas
- Separate schemas: `CreateRequest`, `UpdateRequest`, `Response`, `ListResponse`
- Use `Field()` for validation constraints: `Field(gt=0, max_length=255)`
- Use `model_config = ConfigDict(from_attributes=True)` for ORM compatibility
- Never expose internal models directly — always map to response schemas

## Complete Route Example

```python
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

router = APIRouter(prefix="/products", tags=["products"])

class CreateProductRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    price: float = Field(gt=0, description="Price in USD")
    category_id: int = Field(gt=0)

class ProductResponse(BaseModel):
    id: int
    name: str
    price: float
    model_config = ConfigDict(from_attributes=True)

CurrentUser = Annotated[User, Depends(get_current_user)]
DbSession = Annotated[AsyncSession, Depends(get_session)]

@router.post("/", status_code=status.HTTP_201_CREATED, response_model=ProductResponse)
async def create_product(body: CreateProductRequest, user: CurrentUser, db: DbSession):
    product = await product_service.create(db, body, created_by=user.id)
    return product
```

## Dependency Injection

- Use `Depends()` for all shared logic: auth, database sessions, permissions
- Create reusable dependencies in `dependencies.py` per feature
- Chain dependencies: `current_user = Depends(get_current_user)` → `admin_user = Depends(require_admin)`
- Use `Annotated` types for cleaner signatures: `CurrentUser = Annotated[User, Depends(get_current_user)]`

## Async Patterns

- Use `async def` for all route handlers and service methods
- Use `asyncpg` or `SQLAlchemy async` for database operations
- Use `httpx.AsyncClient` for external HTTP calls
- Use `asyncio.gather()` for parallel independent operations
- Never use blocking I/O in async functions — use `run_in_executor` if needed

## Database (SQLAlchemy)

- Use SQLAlchemy 2.0+ async ORM with `AsyncSession`
- Use Alembic for all migrations — never modify schema manually
- Repository pattern: one repository class per feature for database operations
- Use `select()` statements, not legacy `session.query()`
- Always use transactions for multi-step operations

## Error Handling

- Use `HTTPException` for expected errors with proper status codes
- Create custom exception handlers for domain-specific errors
- Return consistent error response format: `{"detail": "message", "code": "ERROR_CODE"}`
- Never expose internal errors or stack traces to clients

## Structured Logging

```python
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.dev.ConsoleRenderer(),  # Use JSONRenderer() in production
    ],
)
logger = structlog.get_logger()

# Usage in route handlers
logger.info("product_created", product_id=product.id, user_id=user.id)
logger.error("payment_failed", order_id=order.id, error=str(e), fix_suggestion="Check Stripe API key")
```

## Testing

```python
import pytest
from httpx import ASGITransport, AsyncClient
from app.main import app

@pytest.fixture
async def client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac

@pytest.mark.anyio
async def test_create_product(client: AsyncClient, auth_headers: dict):
    response = await client.post("/products/", json={"name": "Widget", "price": 29.99, "category_id": 1}, headers=auth_headers)
    assert response.status_code == 201
    assert response.json()["name"] == "Widget"
```

## Configuration

- Use Pydantic `BaseSettings` for environment variable management
- Group settings by concern: `DatabaseSettings`, `AuthSettings`, `AppSettings`
- Load `.env` file in development, environment variables in production
- Validate all settings at startup — fail fast if misconfigured

## DO NOT Use

- Pydantic v1 `class Config` — use `model_config = ConfigDict(...)` instead
- Pydantic v1 `@validator` — use `@field_validator` with `mode="before"` or `mode="after"`
- Synchronous SQLAlchemy (`create_engine` without `create_async_engine`)
- `on_startup` / `on_shutdown` events — use the `lifespan` context manager
- `session.query()` — use `select()` with `session.execute()`
