# Diagram Templates

## When to use each type

| Situation | Diagram type |
|---|---|
| Data moves through a pipeline or system | `flowchart LR` |
| Steps happen over time between actors | `sequenceDiagram` |
| States a record or job can be in | `stateDiagram-v2` |
| How components depend on each other | `graph TD` |

## Flowchart (data pipeline)

```mermaid
flowchart LR
    A([User / Caller]) --> B[Entry Point]
    B --> C{Decision / Branch}
    C -- path 1 --> D[Service A]
    C -- path 2 --> E[Service B]
    D --> F[(Database)]
    E --> F
    F --> G([Response])
```

## Sequence (request-response)

```mermaid
sequenceDiagram
    actor User
    participant API
    participant Service
    participant DB

    User->>API: request
    API->>Service: process(input)
    Service->>DB: query
    DB-->>Service: result
    Service-->>API: response
    API-->>User: output
```

> Label every arrow with the **real** field, function, or event name from the codebase. Never use generic labels like "data" or "request".
