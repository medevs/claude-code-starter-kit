# React Component Cookbook

Complete examples and patterns for common React scenarios.

## Compound Component: Tabs

Accessible Tabs using Context for shared state.

```tsx
import { createContext, useContext, useState, useId, type ReactNode } from "react";

interface TabsContextValue {
  activeTab: string;
  setActiveTab: (id: string) => void;
  tabsId: string;
}

const TabsContext = createContext<TabsContextValue | null>(null);

function useTabsContext() {
  const ctx = useContext(TabsContext);
  if (!ctx) throw new Error("Tab components must be used within <Tabs>");
  return ctx;
}

export function Tabs({ defaultTab, children }: { defaultTab: string; children: ReactNode }) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  const tabsId = useId();
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab, tabsId }}>
      <div>{children}</div>
    </TabsContext.Provider>
  );
}

export function TabList({ children }: { children: ReactNode }) {
  return <div role="tablist" aria-orientation="horizontal">{children}</div>;
}

export function Tab({ id, children }: { id: string; children: ReactNode }) {
  const { activeTab, setActiveTab, tabsId } = useTabsContext();
  const isActive = activeTab === id;
  return (
    <button
      role="tab"
      id={`${tabsId}-tab-${id}`}
      aria-selected={isActive}
      aria-controls={`${tabsId}-panel-${id}`}
      tabIndex={isActive ? 0 : -1}
      onClick={() => setActiveTab(id)}
    >
      {children}
    </button>
  );
}

export function TabPanel({ id, children }: { id: string; children: ReactNode }) {
  const { activeTab, tabsId } = useTabsContext();
  if (activeTab !== id) return null;
  return (
    <div role="tabpanel" id={`${tabsId}-panel-${id}`} aria-labelledby={`${tabsId}-tab-${id}`} tabIndex={0}>
      {children}
    </div>
  );
}
```

## Custom Hook Recipes

### useDebounce

```tsx
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}
```

### useLocalStorage

```tsx
function useLocalStorage<T>(key: string, initial: T): [T, (v: T | ((p: T) => T)) => void] {
  const [value, setValue] = useState<T>(() => {
    if (typeof window === "undefined") return initial;
    try { return JSON.parse(window.localStorage.getItem(key) || "") as T; }
    catch { return initial; }
  });
  const set = (v: T | ((p: T) => T)) => {
    const next = v instanceof Function ? v(value) : v;
    setValue(next);
    window.localStorage.setItem(key, JSON.stringify(next));
  };
  return [value, set];
}
```

### useMediaQuery

```tsx
function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() =>
    typeof window !== "undefined" ? window.matchMedia(query).matches : false
  );
  useEffect(() => {
    const mq = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mq.addEventListener("change", handler);
    return () => mq.removeEventListener("change", handler);
  }, [query]);
  return matches;
}
```

### useOnClickOutside

```tsx
function useOnClickOutside(ref: RefObject<HTMLElement | null>, handler: () => void) {
  useEffect(() => {
    const listener = (e: MouseEvent | TouchEvent) => {
      if (!ref.current || ref.current.contains(e.target as Node)) return;
      handler();
    };
    document.addEventListener("mousedown", listener);
    document.addEventListener("touchstart", listener);
    return () => {
      document.removeEventListener("mousedown", listener);
      document.removeEventListener("touchstart", listener);
    };
  }, [ref, handler]);
}
```

### usePrevious

```tsx
function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T | undefined>(undefined);
  useEffect(() => { ref.current = value; });
  return ref.current;
}
```

## Accessible Form Pattern

React Hook Form + Zod with aria attributes for screen readers.

```tsx
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const schema = z.object({
  name: z.string().min(1, "Name is required"),
  email: z.string().email("Enter a valid email"),
});
type FormData = z.infer<typeof schema>;

export function ContactForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  return (
    <form onSubmit={handleSubmit((data) => fetch("/api/contact", { method: "POST", body: JSON.stringify(data) }))} noValidate>
      <label htmlFor="name">Name</label>
      <input id="name" {...register("name")} aria-invalid={!!errors.name} aria-describedby={errors.name ? "name-err" : undefined} />
      {errors.name && <p id="name-err" role="alert">{errors.name.message}</p>}

      <label htmlFor="email">Email</label>
      <input id="email" type="email" {...register("email")} aria-invalid={!!errors.email} aria-describedby={errors.email ? "email-err" : undefined} />
      {errors.email && <p id="email-err" role="alert">{errors.email.message}</p>}

      <button type="submit" disabled={isSubmitting}>{isSubmitting ? "Sending..." : "Send"}</button>
    </form>
  );
}
```

## Modal/Dialog Accessibility

Focus trap, escape to close, return focus on unmount.

```tsx
export function Modal({ isOpen, onClose, title, children }: {
  isOpen: boolean; onClose: () => void; title: string; children: ReactNode;
}) {
  const modalRef = useRef<HTMLDivElement>(null);
  const prevFocusRef = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (isOpen) { prevFocusRef.current = document.activeElement as HTMLElement; modalRef.current?.focus(); }
    return () => { prevFocusRef.current?.focus(); };
  }, [isOpen]);

  useEffect(() => {
    if (!isOpen) return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === "Escape") { onClose(); return; }
      if (e.key === "Tab" && modalRef.current) {
        const els = modalRef.current.querySelectorAll<HTMLElement>('button,[href],input,select,textarea,[tabindex]:not([tabindex="-1"])');
        const first = els[0], last = els[els.length - 1];
        if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last?.focus(); }
        else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first?.focus(); }
      }
    };
    document.addEventListener("keydown", handler);
    return () => document.removeEventListener("keydown", handler);
  }, [isOpen, onClose]);

  if (!isOpen) return null;
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div ref={modalRef} role="dialog" aria-modal="true" aria-labelledby="modal-title" tabIndex={-1} onClick={(e) => e.stopPropagation()}>
        <h2 id="modal-title">{title}</h2>
        {children}
        <button onClick={onClose} aria-label="Close dialog">Close</button>
      </div>
    </div>
  );
}
```

## React 19: useActionState Form Example

Server Action + `useActionState` for progressive enhancement. Works without JavaScript.

```tsx
// actions.ts
"use server";
import { z } from "zod";

const ContactSchema = z.object({
  name: z.string().min(1, "Name is required"),
  email: z.string().email("Invalid email"),
  message: z.string().min(10, "Message must be at least 10 characters"),
});

export async function submitContact(prevState: { error?: string; success?: boolean }, formData: FormData) {
  const raw = Object.fromEntries(formData);
  const parsed = ContactSchema.safeParse(raw);
  if (!parsed.success) {
    return { error: parsed.error.errors[0].message };
  }
  try {
    await db.contact.create({ data: parsed.data });
    return { success: true };
  } catch {
    return { error: "Failed to submit. Please try again." };
  }
}
```

```tsx
// ContactForm.tsx
"use client";
import { useActionState } from "react";
import { submitContact } from "./actions";

export function ContactForm() {
  const [state, formAction, isPending] = useActionState(submitContact, {});

  if (state.success) return <p role="status">Thank you! We'll be in touch.</p>;

  return (
    <form action={formAction}>
      <label htmlFor="name">Name</label>
      <input id="name" name="name" required aria-invalid={!!state.error} />

      <label htmlFor="email">Email</label>
      <input id="email" name="email" type="email" required />

      <label htmlFor="message">Message</label>
      <textarea id="message" name="message" required minLength={10} />

      {state.error && <p role="alert">{state.error}</p>}
      <button type="submit" disabled={isPending}>{isPending ? "Sending..." : "Send Message"}</button>
    </form>
  );
}
```

## React 19: use() Hook Example

Read a promise directly in render — suspends the component until the promise resolves.

```tsx
import { use, Suspense } from "react";

// Create the promise outside of render or in a parent component
async function fetchUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) throw new Error("Failed to fetch user");
  return res.json();
}

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}

// Parent component creates the promise and wraps with Suspense
export default function UserPage({ params }: { params: { id: string } }) {
  const userPromise = fetchUser(params.id);
  return (
    <Suspense fallback={<div>Loading user...</div>}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  );
}

// use() also works with Context — replaces useContext()
function ThemeButton() {
  const theme = use(ThemeContext);
  return <button style={{ background: theme.primary }}>Themed Button</button>;
}
```

## Data Fetching with TanStack Query

### Basic Query

```tsx
function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ["user", userId],
    queryFn: () => fetch(`/api/users/${userId}`).then((r) => r.json()),
  });
  if (isLoading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;
  return <ProfileCard user={data} />;
}
```

### Mutation with Optimistic Update

```tsx
function useUpdateUser() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: UpdateUserInput) =>
      fetch(`/api/users/${data.id}`, { method: "PATCH", body: JSON.stringify(data) }).then((r) => r.json()),
    onMutate: async (newData) => {
      await qc.cancelQueries({ queryKey: ["user", newData.id] });
      const prev = qc.getQueryData(["user", newData.id]);
      qc.setQueryData(["user", newData.id], (old: User) => ({ ...old, ...newData }));
      return { prev };
    },
    onError: (_err, vars, ctx) => qc.setQueryData(["user", vars.id], ctx?.prev),
    onSettled: (_d, _e, vars) => qc.invalidateQueries({ queryKey: ["user", vars.id] }),
  });
}
```

### Prefetching on Hover

```tsx
function UserLink({ userId, name }: { userId: string; name: string }) {
  const qc = useQueryClient();
  return (
    <Link href={`/users/${userId}`} onMouseEnter={() => {
      qc.prefetchQuery({ queryKey: ["user", userId], queryFn: () => fetch(`/api/users/${userId}`).then((r) => r.json()), staleTime: 60_000 });
    }}>{name}</Link>
  );
}
```

## Performance Optimization Examples

### Splitting Context by Update Frequency

```tsx
// BAD: one context causes all consumers to re-render on any change
const AppContext = createContext({ user: null, theme: "light", notifications: [] });

// GOOD: separate contexts by change frequency
const UserContext = createContext<User | null>(null);           // rarely changes
const ThemeContext = createContext<string>("light");            // rarely changes
const NotificationContext = createContext<Notification[]>([]);  // changes often
```

### Memoizing Expensive Computation

```tsx
// Without memo: filters run on every render even if inputs are stable
const filtered = products.filter((p) => p.name.toLowerCase().includes(search.toLowerCase()));

// With memo: only recomputes when products or search change
const filtered = useMemo(
  () => products.filter((p) => p.name.toLowerCase().includes(search.toLowerCase())),
  [products, search]
);
```

## Error Boundary with Retry

```tsx
interface State { hasError: boolean; error: Error | null }

export class ErrorBoundary extends Component<{ children: ReactNode; fallback?: (p: { error: Error; retry: () => void }) => ReactNode }, State> {
  state: State = { hasError: false, error: null };
  static getDerivedStateFromError(error: Error): State { return { hasError: true, error }; }
  retry = () => this.setState({ hasError: false, error: null });
  render() {
    if (this.state.hasError && this.state.error) {
      return this.props.fallback
        ? this.props.fallback({ error: this.state.error, retry: this.retry })
        : <div role="alert"><h2>Something went wrong</h2><button onClick={this.retry}>Try Again</button></div>;
    }
    return this.props.children;
  }
}
// Fallback variants: FullPageError, InlineError, or Toast
```

## Server vs Client Component Guide (Next.js App Router)

### Server Components (Default)
Use for static content, data fetching, no interactivity. Reduces JS bundle.

```tsx
// app/users/page.tsx -- Server Component (no "use client")
export default async function UsersPage() {
  const users = await db.user.findMany();
  return <UserList users={users} />;
}
```

### Client Components
Add `"use client"` for event handlers, hooks, browser APIs, interactive UI.

```tsx
"use client";
export function SearchInput() {
  const [query, setQuery] = useState("");
  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

### Composition: Server Wrapping Client

```tsx
// Server Component passes server-fetched data as children to Client Component
import { ClientSidebar } from "./client-sidebar";
export default async function Layout({ children }) {
  const nav = await getNavItems();
  return <ClientSidebar>{nav.map((i) => <NavLink key={i.href} href={i.href}>{i.label}</NavLink>)}</ClientSidebar>;
}
```

### Serialization Boundary

**Can cross**: primitives, plain objects/arrays, Server Actions (`"use server"`)
**Cannot cross**: functions (except Server Actions), classes, Dates, Maps, Sets, refs, context
