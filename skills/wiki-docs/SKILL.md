---
name: wiki-docs
description: Generate GitHub Wiki documentation from a codebase and write all pages to the /wiki directory at the project root. Use when user wants to document their codebase, create or update GitHub wiki pages, generate API docs, write architecture docs, or mentions "write wiki", "document codebase", "generate docs", "เขียน wiki", "สร้าง documentation".
license: powered by clkeen157@gmail.com
---

# Wiki Documentation Writer

Analyse the codebase, generate structured GitHub Wiki documentation, and write all pages under `/wiki/`. Never edit source files.

## Quick Start

1. Scan the codebase for structure, entry points, and public APIs
2. Propose a wiki page plan — **wait for approval before writing**
3. Write or update only the approved pages under `/wiki/`

## Workflow

### 1. Discovery

```bash
cat README.md CLAUDE.md package.json pyproject.toml Cargo.toml go.mod 2>/dev/null || true
ls wiki/ 2>/dev/null || echo "(no wiki yet)"
find . -maxdepth 2 -not -path './.git/*' -not -path './node_modules/*' -not -path './wiki/*' | sort
git remote get-url origin 2>/dev/null || true
```

**If `/wiki/` is missing**, ask before creating anything:

> No `wiki/` folder found. Does this project already have a GitHub Wiki?
> - **Yes** — I'll clone it now.
> - **No** — I'll create a fresh `wiki/` folder.

If yes: derive clone URL from origin and run `git clone <wiki-clone-url> wiki`.
If cloning fails, tell the user to enable Wikis under **Settings → General → Features → Wikis**.
See `references/page-structure.md` for clone URL formats.

### 2. Propose page plan

Present the default structure from `references/page-structure.md`, then ask:
- Which pages to **create** (new)?
- Which pages to **update** (existing)?
- Any custom pages needed?

**Do not write anything until the user confirms.**

### 3. Write documentation

- Use `##` for major sections, `###` for sub-sections
- Follow the dual-audience two-layer template in `references/page-structure.md`
- Add a Mermaid diagram for every page that contains data flow — use templates in `references/diagram-templates.md`
- Link between pages using `[[Page-Name]]` (GitHub wiki syntax)
- Pull code examples from actual source files — never invent APIs
- Keep each page under 300 lines; split into sub-pages if needed
- Add the navigation footer from `references/page-structure.md`

### 4. Sync rules

- **Never delete** existing `/wiki/` pages without explicit user confirmation
- **Overwrite** only pages the user approved for update
- **Append** new sections when adding content — not full rewrites
- If `/wiki/` does not exist, ask whether to **clone** or **create** — never silently create it

## File Conventions

| Convention | Rule |
|---|---|
| Filenames | `Kebab-Case.md` |
| Home page | Always `Home.md` |
| Assets | `wiki/assets/` subfolder |
| Diagrams | Required on Architecture and any data-flow page |
| Plain-English summary | Required at the top of every `##` section |

## Constraints

- Write **only** to `/wiki/` — never modify source files
- Do not `git push`; the user owns that step
- Do not document internal details unless requested
- Prefer accuracy over completeness — mark uncertain sections with `<!-- TODO: verify -->`
- Diagram arrows must use real names from the codebase — no generic labels
