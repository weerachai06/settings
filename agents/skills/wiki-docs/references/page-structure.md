# Page Structure Templates

## Default wiki layout

```
wiki/
├── Home.md              # Project overview and navigation index
├── Getting-Started.md   # Installation, setup, and quickstart
├── Architecture.md      # System design, diagrams, key decisions
├── API-Reference.md     # Public interfaces and usage examples
└── Contributing.md      # Dev setup, conventions, and PR process
```

## Dual-audience section template

Every `##` section follows this two-layer structure:

```markdown
## Feature / Component Name

> **In plain English:** One sentence — what it does and why it matters to the business.

[Mermaid diagram here — see diagram-templates.md]

### How it works (for engineers)
Technical detail, code references, config options.
```

**Rules:**
- Business value leads, technical detail follows — never reversed
- Plain-English summary before every technical block
- No acronyms in the plain-English layer; define on first use in the technical layer

## Navigation footer

Add at the bottom of every page:

```markdown
---
[Home](Home) | [Getting Started](Getting-Started) | [Architecture](Architecture)
```

## Wiki clone URL mapping

| Remote format | Wiki clone URL |
|---|---|
| `https://github.com/owner/repo.git` | `https://github.com/owner/repo.wiki.git` |
| `git@github.com:owner/repo.git` | `git@github.com:owner/repo.wiki.git` |
