---
name: react-patterns
description: >
  Teaches React component patterns, hooks, state management, and accessibility
  best practices. Use when building or modifying React components, designing
  component APIs, choosing between state management approaches, implementing
  accessible UI patterns, optimizing React rendering performance, or working
  with forms and error boundaries in React/Next.js projects.
---

# React Component Patterns

## When to Use

- Building or modifying React components
- Designing component APIs (props, composition, children)
- Choosing between state management approaches
- Implementing accessible UI patterns
- Optimizing React rendering performance
- Working with forms and error handling

## When NOT to Use

- Non-React projects (use framework-specific skills instead)
- Backend-only work (use api-design or database skills)
- Styling-only changes (use CSS/design-system knowledge instead)

## Component Design Checklist

- [ ] Props interface is minimal and well-typed
- [ ] Component has single responsibility
- [ ] Handles loading, error, and empty states
- [ ] Accessible (keyboard nav, screen reader, semantic HTML)
- [ ] Performance considered (memoization only where measured need exists)

## Component Composition Patterns

### Compound Components
Share state between related sub-parts via React Context:

```tsx
<Select value={selected} onChange={setSelected}>
  <Select.Trigger>Choose option</Select.Trigger>
  <Select.Options>
    <Select.Option value="a">Option A</Select.Option>
  </Select.Options>
</Select>
```

### Custom Hooks
Extract reusable stateful logic into hooks when used by 2+ components:

```tsx
function useDebounce<T>(value: T, delay: number): T { ... }
function useLocalStorage<T>(key: string, initial: T): [T, (v: T) => void] { ... }
function useMediaQuery(query: string): boolean { ... }
```

### Render Props
Consumer controls rendering while component provides logic:

```tsx
<DataFetcher url="/api/users">
  {({ data, loading, error }) => (
    loading ? <Spinner /> : <UserList users={data} />
  )}
</DataFetcher>
```

## React 19 Patterns

### `use()` Hook
Read promises and context directly in render — replaces many `useEffect` + `useState` patterns:

```tsx
import { use, Suspense } from "react";

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise); // Suspends until resolved
  return <h1>{user.name}</h1>;
}

// Usage: wrap in Suspense
<Suspense fallback={<Spinner />}>
  <UserProfile userPromise={fetchUser(id)} />
</Suspense>
```

### `useActionState` for Forms
Handles Server Action state, pending status, and progressive enhancement:

```tsx
"use client";
import { useActionState } from "react";
import { submitForm } from "./actions";

function ContactForm() {
  const [state, formAction, isPending] = useActionState(submitForm, { error: null });
  return (
    <form action={formAction}>
      <input name="email" type="email" required />
      {state.error && <p role="alert">{state.error}</p>}
      <button disabled={isPending}>{isPending ? "Sending..." : "Send"}</button>
    </form>
  );
}
```

### `useOptimistic` for Instant UI Updates

```tsx
import { useOptimistic } from "react";

function TodoList({ todos, addTodoAction }: Props) {
  const [optimisticTodos, addOptimistic] = useOptimistic(
    todos,
    (state, newTodo: string) => [...state, { id: "temp", text: newTodo, pending: true }]
  );
  return (
    <form action={async (formData) => {
      addOptimistic(formData.get("text") as string);
      await addTodoAction(formData);
    }}>
      <input name="text" />
      <button>Add</button>
      {optimisticTodos.map((t) => <li key={t.id} style={{ opacity: t.pending ? 0.5 : 1 }}>{t.text}</li>)}
    </form>
  );
}
```

### `<form action={}>` with Server Actions
Forms can directly invoke Server Actions — works without JavaScript:

```tsx
<form action={createTodo}>
  <input name="title" />
  <button type="submit">Create</button>
</form>
```

## State Management Decision Tree

1. **Component-local state** -> `useState` (default choice)
2. **Shared between parent/child** -> lift state to common ancestor
3. **Deep prop passing** -> React Context (sparingly)
4. **Server data** -> TanStack Query / SWR (handles caching, refetching, optimistic updates)
5. **Complex client state** -> Zustand or Jotai (simpler than Redux)
6. **URL state** -> Use URL search params (shareable, bookmarkable)

**Rule**: Don't reach for global state until local state is insufficient.

## Performance Patterns

### Memoization
Use `useCallback`, `useMemo`, and `React.memo` only when profiling shows a need. Premature memoization adds complexity without benefit.

### Lazy Loading
```tsx
const HeavyComponent = lazy(() => import("./HeavyComponent"));
// Wrap with <Suspense fallback={<Spinner />}>
```

### Virtualization
Use `react-window` or `@tanstack/react-virtual` for lists with 100+ items. Renders only visible rows, dramatically reducing DOM nodes.

## Accessibility Quick Reference

- [ ] Interactive elements: keyboard accessible (Tab, Enter, Escape, Arrow keys)
- [ ] Semantic HTML: use correct elements (`button`, `nav`, `main`, `article`, `dialog`)
- [ ] Images: descriptive `alt` text (decorative: `alt=""`, `role="presentation"`)
- [ ] Forms: `<label>` associated with every input via `htmlFor`
- [ ] Focus management: focus moves logically, trapped in modals
- [ ] ARIA: use only when semantic HTML is insufficient
- [ ] Color: never the sole means of conveying information
- [ ] Motion: respect `prefers-reduced-motion`

## Form Patterns

- Use a form library (React Hook Form, Formik) for complex forms
- Validate with Zod schema -- shared between client and server
- Show validation errors inline, next to the field
- Disable submit button during submission (prevent double-submit)
- Use `aria-invalid` and `aria-describedby` for accessible error states

## Error Boundary Pattern

Place error boundaries around independent feature sections, not the entire app. Provide a retry mechanism so users can recover without a full page reload.

```tsx
<ErrorBoundary fallback={<ErrorFallback />}>
  <FeatureSection />
</ErrorBoundary>
```

## Anti-Patterns

- **Prop drilling past 2 levels** -- use Context or composition instead
- **useEffect for derived state** -- use `useMemo` instead
- **Premature memoization** -- profile first, optimize second
- **Giant monolithic components** -- decompose by responsibility
- **Syncing state with useEffect** -- derive state or lift it instead
- **Ignoring cleanup** -- always return cleanup functions from effects with subscriptions

## References

See `references/component-cookbook.md` for complete component examples, hook recipes, and accessibility implementation patterns.
