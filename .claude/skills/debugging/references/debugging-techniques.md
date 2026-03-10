# Debugging Techniques — Deep Reference

This reference provides detailed walkthroughs for each debugging technique
summarized in the parent SKILL.md.

---

## 1. Binary Search Isolation Technique

The fastest way to narrow down a bug is to eliminate half the search space
at each step.

### Code Bisection

1. Identify the full scope of code that could contain the bug.
2. Comment out (or bypass) roughly half of that code.
3. Run the reproduction case.
4. If the bug persists, the cause is in the remaining active code.
5. If the bug disappears, the cause is in the commented-out code.
6. Repeat on the guilty half until you reach a single function or block.

**Tip:** When commenting out code creates compile or runtime errors, replace
the removed section with a stub that returns a safe default value.

### Git Bisect (Commit Bisection)

Use when you know the bug was not present at some earlier commit.

```
git bisect start
git bisect bad                  # current commit has the bug
git bisect good <known-good>    # a commit where it worked
# Git checks out a midpoint commit — test it
git bisect good                 # or git bisect bad
# Repeat until Git identifies the first bad commit
git bisect reset                # return to your branch
```

**Automated bisect** — supply a test script that exits 0 for good, 1 for bad:

```
git bisect start HEAD <known-good>
git bisect run ./test-for-bug.sh
```

### Input Bisection

When a bug only appears with complex input data:

1. Take the full failing input.
2. Remove half of it (fields, records, characters).
3. Test with the reduced input.
4. If the bug still triggers, keep reducing.
5. If the bug vanishes, restore the removed half and reduce the other portion.
6. Continue until you have the minimal input that triggers the bug.

This minimal reproduction is invaluable for writing a focused regression test.

---

## 2. Common Error Pattern Catalog

### Null / Undefined Reference

**Typical causes:**
- Variable used before initialization or assignment
- Missing optional chaining on a nested property access
- Race condition where state is read before an async operation completes
- API response missing an expected field

**Investigation steps:**
1. Find the exact line where the null access occurs (stack trace).
2. Trace backward: where was the variable supposed to be assigned?
3. Check all code paths that reach this line — is there one that skips assignment?
4. If async, check whether the timing of assignment is guaranteed.

**Common fix:** Guard the access, but also fix why the value is null.

### Off-by-One Errors

**Typical causes:**
- Using `<=` instead of `<` in loop bounds
- Confusing 0-based and 1-based indexing
- Pagination calculating wrong offset or limit
- Fence-post errors in range calculations

**Investigation steps:**
1. Write down the expected values for the first and last iterations.
2. Manually trace the loop with a small input (e.g., array of 2-3 items).
3. Check boundary: what happens with 0 items? 1 item? Maximum items?

### Race Conditions

**Typical causes:**
- Two async operations accessing shared state without synchronization
- Missing `await` on a promise, so code continues before the result is ready
- Event handlers firing in an unexpected order
- Stale reads from a cache or database during concurrent writes

**Investigation steps:**
1. Add timestamps to log statements around suspected async operations.
2. Run the reproduction multiple times — does the order of logs change?
3. Look for shared mutable state accessed from multiple async contexts.
4. Check for missing `await` keywords or unhandled promise chains.

**Common fix:** Serialize access to shared state, add proper await, or use
optimistic concurrency control.

### Stale Closures

**Typical causes:**
- React `useEffect` or `useCallback` capturing an old value of state
- `setTimeout` or `setInterval` closing over a variable that changes later
- Event listeners registered with values that become outdated

**Investigation steps:**
1. Log the value inside the closure and compare to the current state.
2. Check dependency arrays in hooks — is the relevant value listed?
3. Look for functions defined once but expected to see updated state.

**Common fix:** Add missing dependencies, use refs for values that should
always reflect the latest state, or use functional state updates.

### Circular Dependencies

**Typical causes:**
- Module A imports from module B, which imports from module A
- Initialization order causes one module to see `undefined` exports
- Often introduced gradually as features are added across modules

**Investigation steps:**
1. Check the error: is a specific import `undefined` at runtime?
2. Trace the import chain between the involved modules.
3. Use a tool or bundler plugin that detects circular imports.

**Common fix:** Extract the shared dependency into a third module that both
A and B can import without creating a cycle.

### Memory Leaks

**Typical causes:**
- Event listeners added but never removed (especially in SPAs)
- `setInterval` or `setTimeout` not cleared on component unmount
- Caches that grow unbounded without eviction
- Closures holding references to large objects that are no longer needed

**Investigation steps:**
1. Monitor memory usage over time (browser DevTools, process metrics).
2. Take heap snapshots before and after the suspected operation.
3. Look for objects that grow in count between snapshots.
4. Check cleanup functions in `useEffect`, `componentWillUnmount`, or
   equivalent lifecycle hooks.

**Common fix:** Always pair resource acquisition with cleanup. Use weak
references for caches when appropriate.

### Type Coercion Bugs

**Typical causes:**
- Using `==` instead of `===` in JavaScript
- String concatenation instead of numeric addition (`"5" + 3` = `"53"`)
- Truthy/falsy confusion: `0`, `""`, `null`, `undefined` are all falsy
- Date comparisons using string representations

**Investigation steps:**
1. Log the type and value of both operands at the comparison point.
2. Check whether values come from user input, URL params, or JSON
   (these are often strings even when you expect numbers).
3. Look for implicit toString or valueOf calls.

**Common fix:** Use strict equality, explicitly convert types at boundaries,
and add TypeScript or runtime validation.

---

## 3. Git Bisect for Regression Hunting

### When to Use

Git bisect is ideal when:
- The bug was not present at some known earlier point ("it worked last week")
- You can write a quick test or manual check that detects the bug
- The commit history is linear or manageable

### Detailed Walkthrough

1. **Find a known-good commit.** Check release tags, deployment logs, or your
   memory of when things last worked.

2. **Start the bisect session:**
   ```
   git bisect start
   git bisect bad HEAD
   git bisect good v1.2.0
   ```

3. **Test each midpoint.** Git checks out a commit halfway between good and
   bad. Run your reproduction case and mark the result:
   ```
   git bisect good   # if the bug is not present
   git bisect bad    # if the bug is present
   ```

4. **Repeat.** Git narrows the range with each step. For 1000 commits,
   you need at most ~10 steps.

5. **Review the result.** Git prints the first bad commit with its message
   and diff. Read the diff carefully to understand the change.

6. **Clean up:**
   ```
   git bisect reset
   ```

### Automated Bisect with a Test Script

If you can script the reproduction:

```bash
#!/bin/bash
# test-for-bug.sh
npm test -- --grep "specific test name" 2>/dev/null
exit $?
```

Then run:
```
git bisect start HEAD v1.2.0
git bisect run ./test-for-bug.sh
```

Git will automatically find the first bad commit without manual intervention.

---

## 4. Log-Based Debugging Strategies

### Strategic Log Placement

Do not scatter logs randomly. Place them based on your hypothesis:

- **Function entry/exit:** Log arguments on entry, return value on exit.
- **Before/after state changes:** Log the state before a mutation and after.
- **Branch points:** Log which branch of a conditional was taken and why.
- **Error boundaries:** Log caught exceptions with full context.

### Structured Logging

Include context that helps correlate log lines:

```
[DEBUG] [requestId=abc123] [userId=42] processOrder: input={itemCount: 3, total: 59.99}
[DEBUG] [requestId=abc123] [userId=42] processOrder: validation passed
[DEBUG] [requestId=abc123] [userId=42] processOrder: result={orderId: 789, status: "confirmed"}
```

Key fields to include: timestamp, request/correlation ID, user ID, function
name, and relevant input values.

### Clean Up After Debugging

- Use a dedicated log level (DEBUG or TRACE) for debugging logs.
- Remove or downgrade debugging logs before committing.
- If the log is permanently useful, keep it at an appropriate level.
- Never log sensitive data (passwords, tokens, PII) even at debug level.

### Trace Correlation

When debugging across multiple services or functions:

1. Generate a correlation ID at the entry point.
2. Pass it through every function call and service boundary.
3. Include it in every log line.
4. Filter logs by correlation ID to see the full request journey.

---

## 5. Async Debugging Patterns

### Promise Chain Debugging

When a promise chain produces unexpected results:

1. Add `.then(val => { console.log("step N:", val); return val; })` between
   each step in the chain.
2. Check whether any step returns `undefined` (missing return statement).
3. Verify error handling: is there a `.catch()` at the end?
4. Look for promises that are created but never awaited.

### Race Condition Detection

1. Add timestamps to every async operation's start and completion:
   ```
   console.log(`[${Date.now()}] fetchUser: start`);
   const user = await fetchUser(id);
   console.log(`[${Date.now()}] fetchUser: done`);
   ```
2. Run the reproduction multiple times.
3. Compare the ordering of start/done messages across runs.
4. If the order varies and the bug is intermittent, you have a race condition.

### Deadlock Identification

When async operations hang indefinitely:

1. Add timeout wrappers to suspected operations.
2. Check for circular await dependencies (A awaits B, B awaits A).
3. Look for resource acquisition patterns: are two operations each waiting
   for a resource the other holds?
4. In database contexts, query lock tables to identify blocking transactions.

### Timeout Debugging

When operations time out intermittently:

1. Add timing measurements around each sub-operation.
2. Identify which sub-operation is consuming the most time.
3. Check external dependencies (network calls, database queries).
4. Add descriptive timeout error messages that include what was being
   attempted and how long it waited.

---

## 6. Database Debugging

### Slow Query Identification

Use `EXPLAIN ANALYZE` to understand query execution:

```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 42 AND status = 'pending';
```

Look for:
- **Seq Scan** on large tables (missing index)
- **Nested Loop** with high row counts (consider join strategy)
- **Sort** operations on large result sets (add index for sort column)
- Estimated vs actual row counts (large differences indicate stale statistics)

### Lock Contention

When queries hang or deadlock:

1. Check active locks: `SELECT * FROM pg_locks WHERE NOT granted;`
2. Identify blocking queries: join `pg_locks` with `pg_stat_activity`.
3. Look for long-running transactions that hold locks.
4. Check transaction isolation levels — are they stricter than needed?

### Connection Exhaustion

When the application cannot connect to the database:

1. Check pool configuration: max connections, idle timeout, queue size.
2. Monitor active vs idle connections over time.
3. Look for leaked connections: queries that open a connection but do not
   release it (missing `finally` block or `using` statement).
4. Check if connection limits are set at both application and database levels.

### Data Integrity Issues

When data is in an unexpected state:

1. Check constraints: are `NOT NULL`, `UNIQUE`, and `FOREIGN KEY` constraints
   in place and enforced?
2. Look for application-level validations that might be bypassed (direct SQL,
   migration scripts, admin tools).
3. Check for concurrent modifications that could violate business rules not
   enforced by database constraints.
4. Review recent migration scripts for data transformation errors.
