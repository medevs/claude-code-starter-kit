# Code Quality Standards

## Naming

- Use verbose, intention-revealing names: `user_email` not `ue`, `fetchProductById` not `getData`
- Boolean variables: prefix with `is`, `has`, `should`, `can` — e.g., `isActive`, `hasPermission`
- Functions describe actions: `calculateTotal`, `validateUserInput`, `sendNotification`
- Constants: UPPER_SNAKE_CASE for true constants, camelCase/snake_case for config values

## Code Structure

- Functions under 50 lines (soft target). Extract when logic is independently testable.
- Files under 300 lines (soft target). Split by responsibility when exceeded.
- One export per file for components/classes. Utilities may have multiple exports.
- Group imports: stdlib/builtins → external packages → internal modules → relative imports

## Error Handling

- Validate at system boundaries (user input, API responses, file I/O, environment variables)
- Trust internal code — don't add defensive checks between your own modules
- Use typed errors or error codes, not string matching
- Never swallow errors silently. Log or propagate with context.
- Return early for error cases. Keep the happy path unindented.

## Logging

- Use structured logging (JSON format) with contextual fields
- Include `fix_suggestion` field for error-level logs to aid debugging
- Log levels: ERROR (needs fix), WARN (degraded but functional), INFO (key events), DEBUG (development)
- Never log sensitive data: passwords, tokens, PII, API keys

## Code Hygiene

- No dead code. Delete unused functions, imports, and variables.
- No commented-out code. Use version control for history.
- No TODO comments without linked issue numbers: `// TODO(#123): description`
- No magic numbers or strings. Extract to named constants.
- Prefer composition over inheritance. Prefer pure functions over stateful classes.

## Type Safety

- Enable strict type checking (TypeScript strict mode, Python type hints, etc.)
- Use schema validation libraries (Zod, Pydantic, io-ts) for runtime validation at boundaries
- Avoid `any` / `object` / `dict` without type parameters. Be explicit about shapes.
- Define shared types/interfaces in a central location. Import from there.
