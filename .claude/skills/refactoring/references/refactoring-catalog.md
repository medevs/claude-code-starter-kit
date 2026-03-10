# Refactoring Catalog — Deep Reference

This reference provides detailed mechanics, before/after examples, and
migration playbooks for each refactoring pattern in the parent SKILL.md.

---

## 1. Detailed Pattern Mechanics

### Extract Function

**Trigger:** Function longer than ~30 lines with distinct logical sections.

**Step-by-step mechanics:**
1. Identify a block of code that performs a single logical task.
2. Note all variables the block reads (parameters) and writes (return values).
3. Create a new function with a name describing what the block does.
4. Move the block into the new function, passing reads as parameters.
5. Return any values the original code needs from the block.
6. Replace the original block with a call to the new function.
7. Run tests.

**Before:**
```javascript
function processOrder(order) {
  // Validate order
  if (!order.items || order.items.length === 0) {
    throw new Error("Order must have items");
  }
  if (!order.customerId) {
    throw new Error("Order must have a customer");
  }

  // Calculate total
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
  }
  if (order.discount) {
    total = total * (1 - order.discount);
  }

  // Save order
  const record = { ...order, total, status: "pending", createdAt: new Date() };
  return db.orders.insert(record);
}
```

**After:**
```javascript
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order.items, order.discount);
  return saveOrder(order, total);
}

function validateOrder(order) {
  if (!order.items || order.items.length === 0) {
    throw new Error("Order must have items");
  }
  if (!order.customerId) {
    throw new Error("Order must have a customer");
  }
}

function calculateTotal(items, discount) {
  let total = 0;
  for (const item of items) {
    total += item.price * item.quantity;
  }
  if (discount) {
    total = total * (1 - discount);
  }
  return total;
}

function saveOrder(order, total) {
  const record = { ...order, total, status: "pending", createdAt: new Date() };
  return db.orders.insert(record);
}
```

**Risks/gotchas:**
- Do not extract if the resulting function needs 6+ parameters — this suggests
  the grouping is wrong.
- Watch for shared mutable state; prefer passing values explicitly.

---

### Extract Module

**Trigger:** File exceeds ~300 lines with multiple distinct responsibilities.

**Step-by-step mechanics:**
1. Identify groups of functions/classes that belong to the same responsibility.
2. Create a new file for each responsibility group.
3. Move the relevant code into each new file.
4. Update imports in the original file to reference the new modules.
5. Update all external consumers that imported from the original file.
6. Run tests after each move.

**Before:** A single `utils.js` file with date helpers, string formatters,
validation functions, and API client helpers all mixed together.

**After:**
- `date-utils.js` — date formatting, parsing, comparison
- `string-utils.js` — string formatting, truncation, sanitization
- `validators.js` — input validation functions
- `api-helpers.js` — request building, response parsing

**Risks/gotchas:**
- Update all import paths. A global search for the old filename catches most.
- If functions in the original file depend on each other across
  responsibility boundaries, that dependency needs resolution first.

---

### Replace Conditionals with Guard Clauses

**Trigger:** Deeply nested if/else blocks making the happy path hard to find.

**Step-by-step mechanics:**
1. Identify conditions that represent edge cases or error states.
2. Convert each to an early return (guard clause) at the top of the function.
3. Remove the else branches — they are now the remaining function body.
4. The happy path should flow straight down without nesting.

**Before:**
```javascript
function getPaymentStatus(user) {
  if (user) {
    if (user.account) {
      if (user.account.subscription) {
        if (user.account.subscription.isActive) {
          return "active";
        } else {
          return "expired";
        }
      } else {
        return "no-subscription";
      }
    } else {
      return "no-account";
    }
  } else {
    return "no-user";
  }
}
```

**After:**
```javascript
function getPaymentStatus(user) {
  if (!user) return "no-user";
  if (!user.account) return "no-account";
  if (!user.account.subscription) return "no-subscription";
  if (!user.account.subscription.isActive) return "expired";
  return "active";
}
```

**Risks/gotchas:**
- Ensure guard clauses handle side effects correctly (e.g., cleanup code that
  must run regardless of which branch is taken).
- Maintain the same return type from all paths.

---

### Decompose Large Function

**Trigger:** Function over ~100 lines mixing multiple levels of abstraction.

**Step-by-step mechanics:**
1. Read the function and identify the high-level steps it performs.
2. Write a new version of the function that calls helper functions for each
   step (the helpers do not exist yet).
3. Implement each helper by moving the relevant code from the original.
4. Delete the original function body, replace with the orchestrator version.
5. Run tests.

**Key insight:** The orchestrator function should read like pseudocode. Each
helper should operate at a single, consistent level of abstraction.

**Risks/gotchas:**
- If the original function has complex control flow (break/continue across
  sections), decomposition may require restructuring the flow first.
- Shared local variables between sections may need to become parameters or
  a shared context object.

---

### Introduce Parameter Object

**Trigger:** Function signature has 5 or more parameters.

**Step-by-step mechanics:**
1. Define an options type/interface grouping the related parameters.
2. Create the options object at each call site.
3. Update the function signature to accept the options object.
4. Update the function body to destructure from the options object.
5. Run tests.

**Before:**
```typescript
function createUser(name, email, role, department, startDate, manager) {
  // ...
}
createUser("Alice", "alice@co.com", "engineer", "platform", "2025-01-15", "Bob");
```

**After:**
```typescript
interface CreateUserOptions {
  name: string;
  email: string;
  role: string;
  department: string;
  startDate: string;
  manager: string;
}

function createUser(options: CreateUserOptions) {
  const { name, email, role, department, startDate, manager } = options;
  // ...
}
createUser({
  name: "Alice",
  email: "alice@co.com",
  role: "engineer",
  department: "platform",
  startDate: "2025-01-15",
  manager: "Bob",
});
```

**Risks/gotchas:**
- This changes every call site. Do a thorough search to update them all.
- Consider adding default values for optional fields in the options type.

---

### Replace Inheritance with Composition

**Trigger:** Deep inheritance hierarchy or shared behavior implemented via
a base class that many subclasses extend.

**Step-by-step mechanics:**
1. Identify the behaviors provided by the base class.
2. Extract each behavior into a standalone module or function.
3. In each subclass, compose the needed behaviors instead of extending.
4. Remove the base class once no subclass extends it.
5. Run tests after each subclass is migrated.

**Key insight:** Inheritance creates tight coupling. Composition lets each
class pick exactly the behaviors it needs without inheriting the rest.

**Risks/gotchas:**
- If the base class has state, you need to decide where that state lives
  in the composed version.
- `instanceof` checks against the base class will break — search for them.

---

## 2. Migration Strategy Playbooks

### Strangler Fig Pattern

Use when replacing a large system or subsystem incrementally.

**Step 1: Identify the boundary.**
Find where the old system receives requests or inputs. This is where you
will place the routing layer.

**Step 2: Create a facade or proxy.**
Build a thin layer that sits at the boundary and can route to either the
old or new implementation.

**Step 3: Implement new version behind the facade.**
Build the new implementation for one slice of functionality. The facade
routes that slice to the new code, everything else to the old code.

**Step 4: Route traffic gradually.**
Expand the slices handled by the new code. Use feature flags, URL patterns,
or data-based routing to control the rollout.

**Step 5: Remove old implementation.**
Once all traffic goes through the new code and the old code has been idle
for a safe period, delete it and simplify the facade.

**Rollback plan:** At any step, the facade can route back to the old code.

---

### Branch by Abstraction

Use when replacing an internal dependency or subsystem.

**Step 1: Create the abstraction.**
Define an interface or type that describes what consumers need from the
subsystem being replaced.

**Step 2: Implement with existing code.**
Create an adapter that implements the new interface using the existing code.
This should be a thin wrapper.

**Step 3: Switch consumers.**
Update all consumers to depend on the interface, not the concrete
implementation. Run tests after each consumer is switched.

**Step 4: Build the new implementation.**
Create a second implementation of the interface using the new approach.
Test it thoroughly in isolation.

**Step 5: Swap implementations.**
Switch the wiring to use the new implementation. The consumers do not change
because they depend on the interface.

**Rollback plan:** Swap back to the old implementation behind the interface.

---

## 3. Large-Scale Refactoring Planning Template

Use this template when a refactoring effort spans multiple days or involves
coordination across the team.

### Current State Assessment
- What code is being refactored and why?
- What are the specific pain points (duplication, complexity, fragility)?
- How many files, functions, or modules are affected?
- What is the current test coverage of the affected area?

### Target State Description
- What will the code look like when the refactoring is complete?
- What specific qualities will improve (readability, testability, flexibility)?
- Are there new patterns or structures being introduced?

### Migration Phases
Break the work into phases that each leave the codebase in a working state.

- **Phase 1:** Write missing tests for current behavior.
- **Phase 2:** Apply structural refactorings (extract, rename, reorganize).
- **Phase 3:** Migrate consumers to new patterns or APIs.
- **Phase 4:** Remove old code and clean up.

Each phase should have a clear milestone and be independently deployable.

### Rollback Plan
For each phase, define how to revert if problems are discovered:
- Can the phase be reverted with `git revert`?
- Are there database migrations that need reverse scripts?
- Is there a feature flag that controls the new code path?

### Success Metrics
Define how you will know the refactoring achieved its goals:
- Cyclomatic complexity before and after
- File and function length before and after
- Test coverage before and after
- Number of duplicated code blocks before and after

---

## 4. Measuring Refactoring Success

### Cyclomatic Complexity Reduction

Cyclomatic complexity counts the number of independent paths through a
function. Measure before and after the refactoring.

- Tools: ESLint complexity rule, SonarQube, Code Climate
- Target: functions with complexity under 10
- Decompose Large Function is the primary refactoring for reducing this

### File and Function Length Reduction

Track the line counts of affected files and functions.

- Target for functions: under 30-50 lines
- Target for files: under 300 lines
- Extract Function and Extract Module are the primary refactorings

### Test Coverage Improvement

Refactoring often makes code more testable. Track coverage before and after.

- Extracted functions are individually testable
- Dependency injection (from composition over inheritance) enables mocking
- Guard clauses make branch coverage easier to achieve

### Code Duplication Reduction

Use copy-paste detection tools to find and measure duplication.

- Tools: jscpd, PMD CPD, SonarQube duplication detection
- Track the number and size of duplicated blocks before and after
- Extract Function and Extract Module address most duplication

### Developer Comprehension Time

Subjective but valuable. Ask: Can a new team member understand this faster?
