---
paths:
  - 'src/**/services/**/*.ts'
---

# API Service Rules

- Use `apiServices({ auth })` for GraphQL and `fetchService({ kind })` for REST.
- Always pass the auth scenario. The default is `'guest'`, which sends no token.
- Do not read tokens or cookies, add an `Authorization` header, or check for an
  expired session in a service. `src/lib/genql-cli/fetch-services.ts` attaches
  the token and handles session errors.
- Define public request/response types in the feature's `types/` module.
- Add `__name` to every GraphQL query and mutation.
- Wrap transport calls in `try/catch`, log with the operation name, and follow
  the consumer contract below.

| Scenario         | Use when                              | Behavior                                                                                                                        |
| ---------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `'auth'`         | The request needs a signed-in user.   | Sends the Bearer token. A lost session shows the modal and the request stays pending; with no modal, the caller gets the error. |
| `'optionalAuth'` | Valid for guests and signed-in users. | Sends the token when a session exists, else as a guest.                                                                         |
| `'guest'`        | The data is public.                   | Sends no token.                                                                                                                 |

| Consumer           | Error contract                                                            |
| ------------------ | ------------------------------------------------------------------------- |
| `useQuery`         | Throw a `GraphQLError`.                                                   |
| `useMutation`      | Throw the original `GraphQLError` so callers can read `code`/`message`.   |
| `useSuspenseQuery` | Return `null`; never throw.                                               |
| Server component   | Return the service fallback; wrap the call site with `createAsyncResult`. |

- Keep GenQL fragments at the nested response level where the API returns them;
  do not model an `on_*` selection as a top-level response.
- REST services return an explicitly typed fallback such as `{ items: null }`
  when their consumer does not require rejection.
