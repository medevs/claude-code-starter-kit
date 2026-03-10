# Next.js Rules

**Version Pins:** Next.js 15+, React 19+, TypeScript 5.5+, Tailwind CSS v4+

## App Router Patterns

- Use the App Router (`app/` directory) for all new routes
- Default to Server Components — add `"use client"` only when needed (interactivity, hooks, browser APIs)
- Use Server Actions for form submissions and mutations — avoid API routes for simple CRUD
- Use `loading.tsx` for streaming/suspense boundaries, `error.tsx` for error boundaries
- Co-locate page components with their loading, error, and layout files
- **Breaking (Next.js 15):** `cookies()`, `headers()`, `params`, `searchParams` are now async — must `await` them
- **Breaking (Next.js 15):** `fetch()` is uncached by default — explicitly opt in with `cache: 'force-cache'`

## Component Patterns

- Server Components: data fetching, heavy computation, sensitive operations (DB, secrets)
- Client Components: interactivity, useState/useEffect, event handlers, browser APIs
- Pass server data to client components via props — don't fetch in client if server can provide
- Use `Suspense` boundaries to stream independent page sections

## Data Fetching

- Fetch data in Server Components using `async/await` — no useEffect for initial data
- Use `fetch()` with `cache: 'force-cache'` or `next: { revalidate: N }` for caching
- For mutations: Server Actions > Route Handlers > client-side API calls
- Revalidate with `revalidatePath()` or `revalidateTag()` after mutations

## Server Action Error Handling

```tsx
"use server";
import { redirect } from "next/navigation";

export async function createPost(prevState: { error?: string }, formData: FormData) {
  const title = formData.get("title") as string;
  if (!title || title.length < 3) {
    return { error: "Title must be at least 3 characters" };
  }
  try {
    await db.post.create({ data: { title } });
  } catch (e) {
    return { error: "Failed to create post. Please try again." };
  }
  redirect("/posts");
}
```

```tsx
"use client";
import { useActionState } from "react";
import { createPost } from "./actions";

export function CreatePostForm() {
  const [state, formAction, isPending] = useActionState(createPost, { error: undefined });
  return (
    <form action={formAction}>
      <input name="title" required minLength={3} />
      {state.error && <p role="alert">{state.error}</p>}
      <button type="submit" disabled={isPending}>{isPending ? "Creating..." : "Create"}</button>
    </form>
  );
}
```

## Rendering Strategies

- Default: Static rendering (build time)
- Use `dynamic = "force-dynamic"` or `revalidate = 0` for dynamic pages
- ISR: Set `revalidate = <seconds>` for time-based revalidation
- PPR (Partial Prerendering): Static shell + dynamic holes with Suspense

## Styling

- Use Tailwind CSS v4 with CSS-native `@theme` directive (replaces `tailwind.config.js`)
- Use `cn()` helper (clsx + tailwind-merge) for conditional classes
- Component library: shadcn/ui components in `components/ui/`
- Use OKLCH color space for design tokens — more perceptually uniform than HSL

## File Conventions

```
app/
  (auth)/                    # Route group (no URL segment)
    login/page.tsx
    register/page.tsx
  dashboard/
    page.tsx                 # Route page
    loading.tsx              # Loading UI
    error.tsx                # Error boundary
    layout.tsx               # Shared layout
  api/                       # API routes (only when Server Actions won't work)
    webhook/route.ts
components/
  ui/                        # shadcn/ui base components
  features/                  # Feature-specific components
lib/
  db.ts                      # Database client
  auth.ts                    # Auth utilities
  utils.ts                   # Shared utilities
```

## Performance

- Use `next/image` for all images (automatic optimization)
- Use `next/font` for fonts (no layout shift)
- Lazy load below-fold components with `dynamic(() => import(...))`
- Use `generateStaticParams` for static generation of dynamic routes
- Minimize client-side JavaScript — keep `"use client"` boundaries small

## TypeScript

- Enable strict mode in `tsconfig.json`
- Use Zod for runtime validation of form data and API inputs
- Type Server Actions with proper input/output types
- Use `satisfies` operator for type-checked config objects

## Testing

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { CreatePostForm } from "./create-post-form";

vi.mock("./actions", () => ({
  createPost: vi.fn().mockResolvedValue({ error: undefined }),
}));

test("displays validation error from server action", async () => {
  const { createPost } = await import("./actions");
  vi.mocked(createPost).mockResolvedValueOnce({ error: "Title too short" });
  render(<CreatePostForm />);
  await userEvent.click(screen.getByRole("button", { name: /create/i }));
  expect(await screen.findByRole("alert")).toHaveTextContent("Title too short");
});
```

## DO NOT Use

- `tailwind.config.js` — use CSS-native `@theme` in Tailwind v4
- `tailwindcss-animate` — use `tw-animate-css` instead
- HSL color values — use OKLCH for better perceptual uniformity
- Synchronous `cookies()` or `headers()` — these are async in Next.js 15
- `next/amp` — deprecated, use native AMP or alternative approach
- Pages Router for new projects — App Router is the standard
