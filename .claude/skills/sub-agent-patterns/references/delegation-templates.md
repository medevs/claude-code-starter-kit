# Delegation Templates

Ready-to-use prompt templates for sub-agent delegation. Each template includes the task description, scope guidance, expected output format, and boundaries.

Copy and adapt these templates for your specific codebase.

---

## 1. Codebase Architecture Analysis

**When to use:** First time working in a codebase, or exploring an unfamiliar module before making changes.

**Prompt:**
```
Analyze the architecture of [directory/module].

Scope: [src/module-name/] and any shared code it imports from.

Report the following:
1. Entry points (files that are imported by code outside this module)
2. Key classes/functions and their responsibilities (one line each)
3. External dependencies (npm packages, other internal modules)
4. Data flow: how data enters, transforms, and exits this module
5. Patterns used (repository, factory, observer, etc.)

Output as a structured markdown summary with the sections above.
Do not modify any files.
```

**Expected output:** A 20-40 line architectural summary with clear sections.

---

## 2. Test Pattern Discovery

**When to use:** Before writing tests for a new feature, to match existing test conventions.

**Prompt:**
```
Analyze the testing patterns in this project.

Scope: [tests/ or __tests__/ or *.test.* files]

Report:
1. Test framework and assertion library used
2. File naming convention (e.g., foo.test.ts, foo.spec.ts, test_foo.py)
3. Directory structure (mirrors src? flat? grouped by type?)
4. Common setup patterns (beforeEach, fixtures, factories, mocks)
5. How mocks are handled (manual mocks, library mocks, dependency injection)
6. Example of a typical unit test (copy one representative test, 10-20 lines)
7. Example of a typical integration test if present

Output as a structured report with sections. Include file paths for examples.
Do not modify any files.
```

**Expected output:** A testing conventions guide specific to this project.

---

## 3. Dependency Audit

**When to use:** Before upgrading a dependency, adding a new one, or investigating bundle size.

**Prompt:**
```
Audit the usage of [package-name] in this project.

Scope: All source files in [src/].

Report:
1. All import statements referencing this package (file:line for each)
2. Which specific exports from the package are used
3. Whether the package is used directly or wrapped in a utility
4. Any version constraints in package.json/requirements.txt
5. Potential impact of removing or replacing this dependency

Output as a markdown table: | File | Line | Import | Usage Context |
Do not modify any files.
```

**Expected output:** A table of all usage points with enough context to assess impact.

---

## 4. Type/Interface Extraction

**When to use:** Before designing new types, to understand existing type conventions and avoid duplication.

**Prompt:**
```
Extract all type definitions and interfaces from [directory].

Scope: [src/types/, src/models/, or relevant directories]

Report:
1. All exported types/interfaces with their file paths
2. For each type: name, fields (name and type), and which files import it
3. Shared types used across 3+ files (highlight these)
4. Any type duplication (similar shapes defined in multiple places)

Output format:
### [TypeName] — `file/path.ts`
- field1: type
- field2: type
- Used by: file1.ts, file2.ts, file3.ts

Do not modify any files.
```

**Expected output:** A type catalog organized by definition location.

---

## 5. Migration Impact Analysis

**When to use:** Before a database migration, schema change, or data model refactor.

**Prompt:**
```
Analyze the impact of changing [describe the schema/model change].

Scope: All source files in [src/].

Report:
1. All files that reference the affected model/table/schema
2. All queries that read from or write to the affected fields
3. API endpoints that expose the affected data
4. Tests that assert on the affected fields
5. Migration files that have previously modified this model
6. Risk assessment: what could break, what needs updating

Output format: Group findings by category (queries, endpoints, tests, etc.)
with file:line references for each finding.
Do not modify any files.
```

**Expected output:** A categorized impact report with specific file:line references.

---

## 6. Security Sweep

**When to use:** Before a security review, after adding auth features, or as a periodic check.

**Prompt:**
```
Perform a security-focused review of [directory or feature].

Scope: [src/auth/, src/api/, or relevant directories]

Check for and report:
1. Hardcoded secrets, API keys, or credentials (any string that looks like a secret)
2. SQL/NoSQL injection vectors (string concatenation in queries)
3. Missing input validation on user-facing endpoints
4. Missing authentication or authorization checks on routes
5. Sensitive data in logs (passwords, tokens, PII)
6. Insecure dependencies (if package.json/requirements.txt is accessible)

Output format: Severity (HIGH/MEDIUM/LOW) | File:Line | Finding | Recommendation
Do not modify any files.
```

**Expected output:** A prioritized findings table with actionable recommendations.

---

## 7. API Surface Mapping

**When to use:** Before integrating with an API, documenting endpoints, or planning API changes.

**Prompt:**
```
Map all API endpoints in this project.

Scope: [src/routes/, src/api/, src/controllers/, or relevant directories]

For each endpoint, report:
1. HTTP method and path (e.g., GET /api/users/:id)
2. File and line number where it's defined
3. Authentication required? (yes/no, which middleware)
4. Request parameters (path params, query params, body schema)
5. Response shape (return type or example)
6. Any middleware applied (validation, rate limiting, etc.)

Output as a markdown table:
| Method | Path | File:Line | Auth | Middleware |

Then list detailed request/response shapes below the table.
Do not modify any files.
```

**Expected output:** A complete API reference table with detailed shapes.

---

## 8. Documentation Gap Analysis

**When to use:** Before a documentation sprint, onboarding new team members, or assessing project health.

**Prompt:**
```
Analyze documentation coverage in this project.

Scope: Entire project (README, docs/, inline comments, JSDoc/docstrings).

Report:
1. What documentation exists (list files and their topics)
2. Public functions/classes missing JSDoc/docstrings (file:line for each)
3. Exported modules without README or usage examples
4. Configuration options without documentation
5. Setup/deployment steps that are undocumented
6. Stale documentation (references to files, functions, or patterns that no longer exist)

Output format: Group by category. For missing docs, include file:line.
For stale docs, include the doc file:line and what it references that no longer exists.
Do not modify any files.
```

**Expected output:** A prioritized list of documentation gaps and stale references.

---

## 9. Performance Hotspot Identification

**When to use:** Before optimization work, when investigating slow operations, or during performance reviews.

**Prompt:**
```
Identify potential performance hotspots in [directory or feature].

Scope: [src/ or specific module]

Look for:
1. N+1 query patterns (loops that make database/API calls)
2. Missing pagination on list endpoints
3. Large data transformations without streaming
4. Synchronous file I/O in request handlers
5. Missing caching for expensive computations or repeated queries
6. Unbounded data structures (arrays/maps that grow without limits)
7. Missing indexes (if schema/migration files are available)

Output format: Priority (HIGH/MEDIUM/LOW) | File:Line | Pattern | Suggestion
Do not modify any files.
```

**Expected output:** A prioritized table of performance concerns with specific locations.

---

## 10. Error Handling Audit

**When to use:** Before improving error handling, after incidents, or when standardizing error responses.

**Prompt:**
```
Audit error handling patterns in [directory or feature].

Scope: [src/ or specific module]

Report:
1. Try-catch blocks: what is caught and how it's handled (file:line for each)
2. Unhandled promise rejections (async functions without try-catch or .catch)
3. Error types used (custom error classes, generic Error, string throws)
4. Error response format consistency (do all endpoints return the same error shape?)
5. Silent error swallowing (catch blocks that don't log or rethrow)
6. Missing error handling (functions that can throw but callers don't handle)

Output format:
### [Pattern Name]
- Count: N occurrences
- Examples: file1:line, file2:line, file3:line
- Assessment: Good/Needs Improvement/Critical
- Recommendation: [one line]

Do not modify any files.
```

**Expected output:** A categorized error handling report with counts, examples, and recommendations.
