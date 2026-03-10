---
paths:
  - "src/**/*.{tsx,jsx,vue,svelte}"
  - "app/**/*.{tsx,jsx,vue,svelte}"
  - "components/**/*.{tsx,jsx,vue,svelte}"
  - "pages/**/*.{tsx,jsx,vue,svelte}"
---

# Frontend UI Patterns

## Component Design

- Components are single-responsibility: one component, one purpose
- Prefer composition over prop drilling — use children and render props
- Co-locate component, styles, types, and tests in the same directory
- Separate container (data-fetching) from presentational (rendering) components

## Accessibility (a11y)

- Every interactive element must be keyboard accessible
- Use semantic HTML elements: `<button>`, `<nav>`, `<main>`, `<article>`
- All images need descriptive `alt` text (decorative images: `alt=""`)
- Form inputs need associated `<label>` elements
- Color alone must never convey information — use icons or text too
- Test with screen reader and keyboard navigation

## State Management

- Local state first — only lift state when needed by siblings or parents
- Server state belongs in data-fetching libraries (React Query, SWR, etc.)
- Global state for truly app-wide concerns only (auth, theme, locale)
- Avoid derived state — compute from source of truth instead

## Performance

- Lazy load routes and heavy components
- Optimize images: use appropriate formats (WebP/AVIF), set explicit dimensions
- Avoid layout shifts — reserve space for dynamic content
- Memoize expensive computations, not every component

## Styling

- Use a consistent approach (CSS Modules, Tailwind, styled-components — pick one)
- Design tokens for colors, spacing, typography — never hardcode values
- Mobile-first responsive design
- Support dark/light mode via CSS custom properties or theme tokens
