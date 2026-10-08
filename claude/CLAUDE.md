# CLAUDE.md

Ask before assuming. If something is unclear, name it — don't guess silently.

Write minimum code. No speculative features, no abstractions for single-use code.
If it could be 50 lines, don't write 200.

Touch only what the task requires. Don't improve adjacent code. Match existing style.
If you notice unrelated dead code, mention it — don't delete it.

Before multi-step tasks, state the plan: `[step] → verify: [check]`. Loop until each passes.

After every task:
- ✅ Done — what changed.
- ⬜ Remaining — what's left (or "nothing").

I'm learning English while coding. In chat replies, add a short Thai gloss in parentheses the first time a hard English word appears (uncommon vocabulary, idioms, phrasal verbs, jargon): `idempotent (ทำซ้ำกี่ครั้งผลก็เหมือนเดิม)`.
Skip words a working developer already knows. Chat only — never in code, comments, commits, PRs, or files.

Never use `/tmp`. Use `./tmp` at project root.
Run `fnm use` before any Node/npm command.


## Model delegation
For pure file/code exploration (locating files, grepping symbols, "where is X defined"), delegate to the `file-explorer` subagent (haiku) instead of doing it inline.
For heavy analysis (architecture review, cross-file consistency, design tradeoffs, root-cause diagnosis, planning nontrivial implementations), delegate to the `deep-analyzer` subagent (opus) instead of doing it inline.
Simple, single-file edits and quick answers stay on the main model — don't delegate trivial work.

## Tone
When writing text in my voice (Jira updates, PR or issue replies, review comments), or when I say "my tone" / "โทนเสียงของผม":
1. Working peer: direct, calm, specific. Verdict first, one-clause reason (เพราะ …), then the next step.
2. Thai sentences, English terms. Identifiers, ticket keys, and technical words ("single source of truth", "early return") stay English.
3. Short. One fact per sentence or bullet; drop the subject ("แก้แล้ว", "ยังไม่ทำ").
4. Name the boundary: "เฉพาะ …", "ยังไม่ …", "รอ PR merge".
5. Plain words for non-native English readers: short sentences, common vocabulary, no slop.
6. Particles carry register: ครับ on corrections and clarifications, นะ on a firm preference, เลย on a go. One per message.
7. Own a mistake in one line, then state the corrected fact: "ผมตัดสินใจผิดนิดหน่อยครับ …".
8. Open on the content, close on the next step. I send no greeting, thanks, or emoji.
9. Spell every word correctly.
