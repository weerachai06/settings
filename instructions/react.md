# React Instructions

Reference: `~/.agents/skills/vercel-react-best-practices/AGENTS.md`
Rule files: `~/.agents/skills/vercel-react-best-practices/rules/`

When writing, reviewing, or refactoring React/Next.js code, apply the rules below in priority order.
Read the relevant rule file before generating code in that category.

---

## 1. Eliminating Waterfalls — CRITICAL

Rules: `async-parallel`, `async-api-routes`, `async-defer-await`, `async-dependencies`, `async-suspense-boundaries`

- Use `Promise.all()` for independent async operations — never await sequentially.
- In API routes/Server Actions, start all independent promises before any `await`.
- Move `await` inside the branch that actually needs it, not before conditionals.
- Use Suspense boundaries so the shell renders immediately while data streams in.

## 2. Bundle Size Optimization — CRITICAL

Rules: `bundle-barrel-imports`, `bundle-dynamic-imports`, `bundle-defer-third-party`, `bundle-conditional`, `bundle-preload`

- Import directly from source files, never from barrel `index` files (lucide-react, @mui/material, etc.).
- Use `next/dynamic` for heavy components not needed on initial render.
- Defer analytics/logging libraries with `{ ssr: false }` after hydration.
- Preload heavy bundles `onMouseEnter`/`onFocus` to reduce perceived latency.

## 3. Server-Side Performance — HIGH

Rules: `server-auth-actions`, `server-parallel-fetching`, `server-cache-react`, `server-serialization`, `server-dedup-props`, `server-cache-lru`, `server-after-nonblocking`

- Always authenticate inside each Server Action — never rely on middleware alone.
- Restructure RSC trees so sibling components fetch in parallel.
- Use `React.cache()` for per-request deduplication of DB queries and auth checks.
- Pass only the fields a client component actually uses across the RSC boundary.
- Use `after()` for logging/analytics so they don't block the response.

## 4. Re-render Optimization — MEDIUM

Rules: `rerender-derived-state-no-effect`, `rerender-functional-setstate`, `rerender-memo`, `rerender-dependencies`, `rerender-lazy-state-init`, `rerender-defer-reads`, `rerender-transitions`, `rerender-use-ref-transient-values`

- Derive values during render — don't store derivable state or sync it in effects.
- Use functional `setState(curr => ...)` to avoid stale closures and stable callbacks.
- Use primitive dependencies in `useEffect` (e.g., `user.id`, not `user`).
- Pass `useState(() => expensiveInit())` for costly initial values.
- Use `startTransition` for non-urgent updates (scroll, search input).
- Use `useRef` for values that change frequently but don't need to trigger re-renders.

## 5. Rendering Performance — MEDIUM

Rules: `rendering-conditional-render`, `rendering-hoist-jsx`, `rendering-hydration-no-flicker`, `rendering-activity`, `rendering-usetransition-loading`, `rendering-content-visibility`

- Use ternary (`? :`) not `&&` for conditional rendering when condition can be `0`/`NaN`.
- Hoist static JSX outside components so React reuses the same element reference.
- For client-only data (theme, preferences), inject an inline script to avoid hydration flicker.
- Use `<Activity mode="hidden">` instead of unmounting expensive components on toggle.
- Apply `content-visibility: auto` with `contain-intrinsic-size` on long list items.

## 6. Client-Side Data Fetching — MEDIUM-HIGH

Rules: `client-swr-dedup`, `client-passive-event-listeners`, `client-localstorage-schema`, `client-event-listeners`

- Use `useSWR` for client fetches — automatic deduplication across component instances.
- Add `{ passive: true }` to `touchstart`/`wheel` listeners unless `preventDefault` is needed.
- Version localStorage keys (`userConfig:v2`) and store only needed fields; wrap in try-catch.

## 7. JavaScript Performance — LOW-MEDIUM

Rules: `js-index-maps`, `js-set-map-lookups`, `js-tosorted-immutable`, `js-combine-iterations`, `js-cache-function-results`, `js-early-exit`, `js-hoist-regexp`

- Build a `Map` for repeated `.find()` lookups on the same key.
- Use `Set`/`Map` for membership checks instead of `Array.includes()`.
- Use `.toSorted()` instead of `.sort()` to avoid mutating props/state.
- Combine multiple `.filter()`/`.map()` passes into one loop when possible.
- Return early once the result is determined.
- Hoist `RegExp` creation outside render; memoize dynamic patterns with `useMemo`.

## 8. Advanced Patterns — LOW

Rules: `advanced-init-once`, `advanced-event-handler-refs`, `advanced-use-latest`

- Guard one-time app init with a module-level `didInit` flag, not `useEffect([])` alone.
- Use `useEffectEvent` (or a ref) for handlers in effects that shouldn't re-subscribe on callback changes.
