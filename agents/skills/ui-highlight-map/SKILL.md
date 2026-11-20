---
name: ui-highlight-map
description: 'Highlight map: a wireframe whose screen positions are tagged with the entity fields they read. Use when the user wants to see which fields of an entity or type (e.g. CartItem) show up at which position on a screen, such as "ตำแหน่งของ X map field อะไรบ้าง".'
---

# UI Highlight Map

A **highlight map** is a wireframe of one screen region. Every **zone** (a position the user can see or tap) carries a tag with the entity field it reads. Hovering a zone spotlights it and opens its detail card; clicking a field chip spotlights every zone that reads that field. The map answers "where does this field show up?" and, by exclusion, "which fields never do?".

The axis is screen position. A zone's data path (rename, computation, condition) lives in its detail card as "shown as".

## Steps

1. **Pin the screen.** Name the entity and the one screen or component that renders it ("CartItem row, Cart page"). When several screens render it, take the one the user named, or state your pick in a line and continue. *Done when* one sentence reads "entity X on screen Y".

2. **Trace the render path by reading.** Read the rendering component, every child down to the leaves, and the parent that wraps it. For each zone record: name, shown-as, show condition, click action, `file:line`.
   - Find the mapper between store and props (selector, `normalize`, a `{...product}` spread). UI prop names differ from field names; the rename (`productName → name`) and the computation (`unitPrice × quantity`) live there.
   - Parents draw part of the row too (limit bar, section header). Include what they draw.
   - Follow each prop to a consumer. A prop passed under one name and read under another is a **dead prop**: leave it off the map and mention it.
   - A subagent can locate files. Read the lines yourself before they reach the page: on the CartItem map the subagent missed the mapper and reported a type with no builder.

   *Done when* every zone has a `file:line` you read, for shown-as and for its condition.

3. **Classify every field.** Take the full field list (type plus query). Each field lands in exactly one group:
   - **shown**: its value is rendered.
   - **drives**: not rendered, but controls a zone or behaviour (key, flag, loading state).
   - **unused**: no zone in scope reads it. Give the reason (analytics only, dropped by the mapper, nothing reads it) and word it "not found in scope".

   *Done when* the three groups sum to the field count and each unused field has a grep-backed reason.

4. **Build the page from `template.html`.** Copy it. Replace everything above `// ---- helpers ----` (`ZONES`, `GROUPS`, `NOTES`, the toggle state `S`, `mockHtml()`), plus the toggle buttons, the mock CSS and the header and footer copy. Keep the engine below that marker (spotlight, detail card, field chips, reveal toggles).
   - A zone record is `{ id, no, name, tag, when, fields: [[field, shownAs]], action?, refs, needs?, hideWhen? }`.
   - Draw the mock in the real layout order, with sample data labelled as examples.
   - Give each conditional zone a toggle (`needs` / `hideWhen`); selecting a hidden zone reveals it.
   - Tags carry the shortest field name; leave column gaps wider than the widest tag.
   - Write page copy in the user's language and keep identifiers in English.

   *Done when* the page opens on a selected zone, every zone responds to hover, click and keyboard, and each field sits in exactly one chip group.

5. **Check once.** Run `fnm use`, then `node --check` on the extracted script and assert every zone field is in a group. Chrome blocks `file://`: serve the folder with `python3 -I -m http.server --bind 127.0.0.1`, add `<meta charset="utf-8">` to a preview copy (the Artifact skeleton adds its own), take one screenshot and fix what it shows. Stop the server and close the tab.

6. **Publish so others can view.** In Claude Code, load the `artifact-design` skill, then publish with the Artifact tool; revising an earlier map republishes to the same `url`. The page stays private until its owner shares it from the page's Share menu: tell the user, with the link. Without the Artifact tool, save the single HTML file to `./tmp/<entity>-ui-map.html` and give the path.

   *Done when* the reply carries the link or path, the scope boundary (screens and parents not read), and what was not checked (interactions, light theme, mobile).
