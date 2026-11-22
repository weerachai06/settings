---
paths:
  - 'src/**/*.{ts,tsx}'
---

# TypeScript Rules

## Types

- Infer return and local types. Write an explicit return type only when the
  function returns a discriminated union (for example `Result<T>`). `T | null`,
  `Promise<T | null>`, `boolean`, `void`, and GenQL-derived types stay inferred.
- Declare a type once. Before adding an `interface` or `type`, search for an
  existing one (service response type, GenQL generated type, `z.infer` of a
  schema) and import it. Derive a variant with `Pick`, `Omit`, `Partial`, or
  indexed access instead of redeclaring its fields, and use the existing type
  directly instead of wrapping it in an alias that only renames it.
- Use `interface` for extendable object shapes and `type` for unions,
  intersections, and mapped types.
- Prefer string-literal unions. When a shared enum is required, use a PascalCase
  `const enum` in `constants/`; co-located hook enums use `.enum.ts`.
- Prefer a known key over a bare `string` when the value comes from a fixed set:
  a string-literal union, an enum, or `keyof typeof` a constant map. Use plain
  `string` only for open-ended values such as user input, IDs, or API text.
  For a fixed mapping, key the `Record` by the union or enum
  (`Record<Status, Config>`), not `Record<string, Config>`.
- Use `unknown` and narrow it. Avoid `any`, `as unknown as` double assertions,
  and `React.FC`; refactor the types instead.
- Mark inputs `Readonly<T>` when callers must not mutate them.

## Naming and imports

- Folders and helpers: kebab-case; components and schemas: PascalCase; hooks:
  `use*` camelCase; constants: UPPER_SNAKE_CASE.
- Name files, functions, variables, and types after the domain term in the
  feature's `GLOSSARY.md` (see `GLOSSARY-MAP.md`), so the name says what it is
  or does. Prefer a clear name over an unclear name plus a comment. Comments are
  still allowed; remove one that only restates the name.
- Boolean props, variables, hook returns, and constants start with `is`, `has`,
  `can`, `should`, `will`, `needs`, `was`, or `did`. The rule does not cover
  function names.
- Local event handlers use `handle*`. Callbacks that report an event, exposed by
  hooks or props, use `on*`. A function the caller invokes to run a command uses
  a verb name such as `toggleX`.
- Relative imports may go up one level. Use `@/` for deeper paths.
- Import from the file or component directory, never from the top-level
  barrels `@/shared/components/ui`, `@/shared/helpers`, or `@/shared/hooks`
  (enforced by lint). `@/shared/types` stays allowed until its imports are
  migrated. Do not add new top-level barrels.

## Implementation

- Use arrow functions.
- Prefer guard clauses; use `Record` for fixed key/value mappings and `switch`
  when branches return different shapes.
- Return a discriminated union (a `kind` or `state` field) instead of building
  the result by spreading optional fields.
- Server-side fallible work returns `Result` and never throws. Build it with
  `createResult` (sync) or `createAsyncResult` (async). Check `isSuccess` before
  reading `data`; client-side code does not need this wrapper.
- Do not destructure a discriminated-union discriminant; narrowing only works on
  the whole object.
- Remove unused code instead of commenting it out. Keep production output free
  of `console.log`.

## Schemas

- Define Zod schemas in `schemas/` or a `.schema.ts` file.
- Name exported schemas in PascalCase with a `Schema` suffix.
- Export the inferred type beside every schema:
  `export type Values = z.infer<typeof ValuesSchema>`.
- Keep validation messages on the failing rule. Never add or edit locale keys;
  hardcode a user-facing message with a `TODO` until the key exists.
