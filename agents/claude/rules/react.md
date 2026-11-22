---
paths:
  - 'src/**/{components,containers,hooks,helpers}/**/*.{ts,tsx}'
  - 'src/app/**/*.tsx'
---

# React Rules

## Functional core, imperative shell

- Core (`helpers/`): pure, higher-order, composable and reusable functions with
  no I/O, mutation or React. Build larger behavior by composing small helpers.
- Shell (`hooks/`, `containers/`): thin. It holds state, effects, queries and
  I/O, and calls the core for every decision and data transform.
- A container makes the business decision and passes the result to a hook as a
  parameter; the hook does not derive it again.

## Components

- Read the source of a shared component before use and import it directly from
  `@/shared/components/ui/<component>`, not the UI barrel.
- Reuse and compose existing shared UI. Modify `src/shared/components/ui/` only
  when that shared primitive is explicitly in scope. A contract bug in a shared
  primitive may be fixed when the change has tests and the PR lists the affected
  callers; prefer a stacked PR.
- Keep `components/` presentational. Containers own business logic, API hooks,
  and client state; server pages compose containers and Suspense boundaries.
- Function props that report an event use `on<Event>` names. Boolean props use
  the prefixes defined in `typescript.md`.
- Order inside a component: hooks, then logic, then render. Compute a value
  passed as a prop at the top of the component, not inline in the JSX.
- Build forms with React Hook Form and Zod using existing Form primitives.
- Preserve keyboard, focus, ARIA, and screen-reader behavior; use react-aria for
  custom interactions. Mark decorative icons `aria-hidden`.
- For performance-sensitive work (data fetching, bundle size, rendering), follow
  the `vercel-react-best-practices` skill in `.agents/skills/`. Where it
  conflicts with a rule in this repo, the repo rule wins.

### Images

- Use `next/image` with meaningful `alt` text; use `alt=""` only for decorative
  images.
- Responsive images use `fill` and `sizes` inside a positioned, sized parent;
  fixed images use matching `width` and `height`.
- Apply `priority` and `fetchPriority="high"` only to LCP images.
- Product and banner images use `placeholder="blur"` with
  `DEFAULT_BLUR_DATA_URL`.
- External hosts must exist in `next.config.ts` `remotePatterns`.

## Hooks

- Add `'use client'` only to hook files that use client-only APIs. Name hooks
  `use*` in camelCase.
- A custom hook calls at least one hook and returns a named object, not a tuple.
- Call hooks only at the top level and clean up effects.
- Avoid `useEffect`. Run work that a user action causes in the event handler,
  and derive a value during render instead of syncing it into state. Use
  `useEffect` only to sync with an external system (browser API, subscription,
  timer, third-party widget), and clean it up.
- Group related state and side effects; use a plain helper when no hook is
  needed.
- Add `useMemo` or `useCallback` only for a measured or contract-driven need.
  Before removing one, check whether its value is a dependency of another memo
  or effect.
- Use suspense query hooks only below a Suspense boundary; otherwise use their
  non-suspense equivalents.
- React Query keys include every variable that changes the result. Place data
  transforms in the query `select` option when practical.
