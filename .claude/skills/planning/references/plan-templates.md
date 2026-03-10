# Plan Templates

Ready-to-use templates for planning features, assessing risks, and validating implementation readiness.

---

## Full Plan Template

Use for features touching 5+ files, complex refactors, or new integrations.

```markdown
# Plan: [Feature/Change Name]

## Summary
[2-3 sentences describing what this change accomplishes and why.]

## Scope
- **In scope:** [What this plan covers]
- **Out of scope:** [What this plan explicitly does NOT cover]
- **Affected modules:** [List of modules/features touched]

## Affected Files
| File | Change Type | Description |
|------|------------|-------------|
| src/types/user.ts | Modify | Add `preferences` field to User type |
| src/services/user.ts | Modify | Add getPreferences() and setPreferences() methods |
| src/routes/user.ts | Modify | Add GET/PUT /users/:id/preferences endpoints |
| src/services/user.test.ts | Create | Unit tests for preference methods |
| src/routes/user.test.ts | Modify | Integration tests for new endpoints |

## Phases

### Phase 1: Foundation
- [ ] Define `UserPreferences` type in `src/types/user.ts`
- [ ] Add `preferences` field to `User` interface
- [ ] Create database migration for preferences column
- **Validation:** Types compile, migration runs successfully

### Phase 2: Core Logic
- [ ] Implement `getPreferences()` in `src/services/user.ts`
- [ ] Implement `setPreferences()` with validation
- [ ] Add default preferences constant
- **Validation:** Unit tests pass for both methods

### Phase 3: API Layer
- [ ] Add GET /users/:id/preferences endpoint
- [ ] Add PUT /users/:id/preferences endpoint
- [ ] Add request validation middleware
- **Validation:** Integration tests pass, manual API test with curl

### Phase 4: Integration
- [ ] Update user profile page to display preferences
- [ ] Add preferences to user export/import
- [ ] Update API documentation
- **Validation:** End-to-end flow works, existing tests still pass

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Migration fails on existing data | Medium | High | Add default value, test on staging first |
| Preferences schema changes later | High | Low | Use JSON column for flexibility |
| Performance impact on user queries | Low | Medium | Preferences loaded separately, not with every user query |

## Validation Strategy
- Unit tests for service methods (happy path + edge cases)
- Integration tests for API endpoints (auth, validation, CRUD)
- Run full test suite to check for regressions
- Manual test: create user → set preferences → retrieve → verify

## Confidence Score: [X/10]
[Brief justification for the score and what would raise it.]

## Open Questions
- [List any unresolved questions that need answers before or during implementation]
```

---

## Lightweight Plan Template

Use for medium tasks (3-5 files) where a full plan is overkill.

```markdown
# Quick Plan: [Change Name]

## Goal
[One sentence: what you're doing and why.]

## Tasks
- [ ] [Task 1 — specific file and change]
- [ ] [Task 2 — specific file and change]
- [ ] [Task 3 — specific file and change]
- [ ] [Task 4 — write/update tests]
- [ ] [Task 5 — validate]

## Risks
- [Risk 1 and how you'll handle it]
- [Risk 2 and how you'll handle it]

## Done When
- [ ] All tasks checked off
- [ ] Tests pass
- [ ] No type errors
- [ ] [Specific acceptance criterion]
```

**Example filled in:**

```markdown
# Quick Plan: Add rate limiting to login endpoint

## Goal
Prevent brute-force attacks by limiting login attempts to 5 per minute per IP.

## Tasks
- [ ] Add rate-limiter middleware in src/middleware/rate-limit.ts (follow existing middleware pattern)
- [ ] Apply to POST /auth/login in src/auth/route.ts
- [ ] Add rate limit config to src/config/security.ts
- [ ] Write tests for rate limiting behavior
- [ ] Test manually: hit endpoint 6 times, verify 429 on 6th

## Risks
- Redis dependency for distributed rate limiting — check if project already uses Redis
- May need to handle X-Forwarded-For behind a proxy

## Done When
- [ ] 6th login attempt within 1 minute returns 429
- [ ] Rate limit resets after 1 minute
- [ ] Tests cover: under limit, at limit, over limit, reset
- [ ] Existing auth tests still pass
```

---

## Risk Assessment Matrix

Use this grid to classify risks by likelihood and impact, then determine the appropriate response.

```
                        IMPACT
                 Low        Medium       High
            ┌──────────┬──────────┬──────────┐
    High    │ MITIGATE │  AVOID   │  AVOID   │
            │          │          │          │
LIKELIHOOD  ├──────────┼──────────┼──────────┤
    Medium  │  ACCEPT  │ MITIGATE │  AVOID   │
            │          │          │          │
            ├──────────┼──────────┼──────────┤
    Low     │  ACCEPT  │  ACCEPT  │ MITIGATE │
            │          │          │          │
            └──────────┴──────────┴──────────┘
```

**Actions:**
- **Accept:** Acknowledge the risk, proceed without special action. Monitor during implementation.
- **Mitigate:** Proceed but add safeguards. Write extra tests, add validation, create a rollback plan.
- **Avoid:** Redesign to eliminate the risk. Choose a different approach, reduce scope, or resolve unknowns first.

---

## Common Risk Patterns by Category

### Data Migrations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Data loss during migration | Low | **Critical** | Backup before migration, test on staging data, write rollback migration |
| Downtime during migration | Medium | High | Use zero-downtime migration pattern (add column → backfill → switch → drop old) |
| Rollback complexity | Medium | High | Always write both up and down migrations, test rollback before deploying |
| Schema drift between environments | Medium | Medium | Track all migrations in version control, never modify production schema manually |
| Large table migration timeout | Medium | Medium | Batch operations, avoid locking entire tables, migrate during low-traffic windows |

### API Changes

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Breaking existing consumers | High | **Critical** | Version the API, maintain backward compatibility, deprecate before removing |
| Missing validation on new fields | Medium | High | Add schema validation at the boundary, test with invalid inputs |
| Inconsistent error format | Medium | Medium | Follow existing error response pattern, add integration tests for error cases |
| Performance regression | Low | Medium | Load test new endpoints, add monitoring, set performance budgets |
| Missing authentication on new routes | Low | **Critical** | Review all new routes against auth middleware, add auth tests |

### Authentication Changes

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| User lockout | Medium | **Critical** | Test login flow end-to-end before deploying, have emergency bypass |
| Session invalidation side effects | Medium | High | Understand session storage, test concurrent sessions, gradual rollout |
| Permission gaps in new roles | Medium | High | Map all endpoints to required permissions, write permission matrix tests |
| Token format change breaking clients | Low | High | Version tokens, support both old and new format during transition |
| OAuth flow regression | Medium | High | Test full OAuth flow including edge cases (expired token, revoked access) |

### UI Refactors

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Accessibility regression | Medium | High | Run automated a11y checks, manual screen reader test on key flows |
| Responsive layout breakage | Medium | Medium | Test at standard breakpoints (320px, 768px, 1024px, 1440px) |
| State management bugs | Medium | High | Keep state changes minimal, test state transitions, add error boundaries |
| Visual regression | High | Low | Use visual snapshot tests if available, manual review of changed pages |
| Performance regression (bundle size) | Medium | Medium | Check bundle size before and after, lazy load new components |

---

## Dependency Mapping Examples

### Simple Feature (Linear Dependencies)

```
Types → Service → Route → Tests
  │                        ▲
  └────────────────────────┘
  (tests also validate types)
```

### Feature with Shared Dependencies

```
                    ┌─── ServiceA ──── RouteA
Types ──── Schema ──┤
                    └─── ServiceB ──── RouteB
                              │
                              ▼
                         SharedUtil
```

**Implementation order:** Types → Schema → SharedUtil → ServiceA + ServiceB (parallel) → RouteA + RouteB (parallel) → Tests

### Cross-Cutting Change

```
Config Change
    │
    ├── Module A (update import)
    ├── Module B (update import)
    ├── Module C (update import + logic change)
    └── Tests (update all affected test files)
```

**Implementation order:** Config → Module A → Module B → Module C (most complex last) → Tests

### Integration Feature

```
External API Client
    │
    ├── Types (response shapes)
    ├── Client wrapper (HTTP calls)
    ├── Service (business logic using client)
    ├── Route (expose via API)
    ├── Mock server (for testing)
    └── Tests (unit + integration)
```

**Implementation order:** Types → Mock server → Client wrapper → Service → Route → Tests

---

## Pre-Implementation Checklist

Copy this checklist and verify every item before starting implementation. If any item is unchecked, address it first.

```markdown
## Pre-Implementation Checklist: [Feature Name]

### Research Complete
- [ ] All affected files identified (verified with grep/glob, not guessed)
- [ ] Existing patterns researched (how does the codebase do similar things?)
- [ ] External documentation reviewed (library docs, API specs)
- [ ] No unresolved questions remaining

### Design Complete
- [ ] Types/schemas designed (data shapes defined before logic)
- [ ] Edge cases listed (empty inputs, error paths, boundary values, concurrent access)
- [ ] Error handling approach decided (matches existing patterns)
- [ ] Public API surface defined (function signatures, route paths, request/response shapes)

### Strategy Defined
- [ ] Test strategy defined (what tests, where, what assertions)
- [ ] Validation checkpoints set (how to verify each phase works)
- [ ] Rollback plan exists (can you revert safely if something goes wrong?)
- [ ] Implementation order determined (dependency-aware sequencing)

### Ready to Execute
- [ ] Confidence score is 7/10 or higher
- [ ] Estimated context budget fits within one session (or session handoff planned)
- [ ] No blockers or dependencies on external work
```

---

## Confidence Calibration Examples

Use these examples to calibrate your confidence scoring:

### Score: 9/10
"Add email field validation to the registration form. The codebase has 4 other forms with identical validation using Zod schemas. I can see the exact pattern in `src/features/profile/schema.ts`. One file to change, one test to add."

**Why 9:** Familiar pattern, minimal files, clear precedent.

### Score: 7/10
"Add a new REST endpoint for exporting user data as CSV. The project has 12 similar endpoints I can follow. I haven't used the CSV library before, but docs look clear. Need to add streaming for large exports."

**Why 7:** Known patterns for most of it, one unfamiliar aspect (streaming CSV) that needs research.

### Score: 5/10
"Integrate Stripe webhooks for subscription management. The project has no existing webhook handlers. Stripe docs are comprehensive but the event flow is complex. Need to handle idempotency, retries, and signature verification."

**Why 5:** No existing pattern to follow, complex external integration, multiple failure modes to handle.

### Score: 3/10
"Migrate the auth system from session-based to JWT while maintaining backward compatibility with existing sessions during a transition period."

**Why 3:** High-risk change, complex state management, affects every authenticated endpoint, transition period adds significant complexity. Needs a spike/prototype first.
