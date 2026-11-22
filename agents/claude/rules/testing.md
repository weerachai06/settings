---
paths:
  - '**/*.test.{ts,tsx}'
---

# Testing Rules

- Structure tests as Arrange, Act, Assert. Use `describe('[type] Name')` and
  behavior names beginning with `should` or `shouldn't`.
- Name a test file after the file it tests (`foo.ts` → `foo.test.ts`).
- Helpers use Vitest unit tests; components use Testing Library; containers use
  integration tests with MSW. Test business behavior at the container; add a
  hook test only for logic a container test cannot reach.
- Share setup through a helper that takes parameters (for example `warnings`)
  instead of copying setup between tests.
- Import `render`, `server`, `http`, `graphql`, and `apiEndpoint` from
  `@/shared/helpers/testing`; import `HttpResponse` from `msw`.
- Mock API traffic with MSW. Do not mock API hooks/functions with `vi.mocked()`;
  `vi.mock()` remains acceptable for non-API boundaries.
- Type fixtures and factory overrides as `DeepOptional<BaseType>` from the
  exported service response type, not `*Locale` variants. Never use `any`,
  `Record<string, unknown>`, or `as unknown as`. Read fixture fields with
  optional access.
- Type every `HttpResponse.json` a PR adds or changes with a generic, wrapping
  the payload as `{ data: DeepOptional<…> }`. Use the service response type or
  `Pick<Query, 'field'>` from `@/lib/genql-cli/generated`. If the service type
  is the inner value, keep its key:
  `{ data: { promotionCode: DeepOptional<…> } }`.
- Use `@ts-expect-error` only for deliberately invalid input, never to hide a
  partial mock.
- Cover success and error behavior, including both mutation-modal branches.
- Run integration tests with `pnpm test:integration`.
