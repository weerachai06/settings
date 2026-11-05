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


## Model delegation
For pure file/code exploration (locating files, grepping symbols, "where is X defined"), delegate to the `file-explorer` subagent (haiku) instead of doing it inline.
For heavy analysis (architecture review, cross-file consistency, design tradeoffs, root-cause diagnosis, planning nontrivial implementations), delegate to the `deep-analyzer` subagent (opus) instead of doing it inline.
Simple, single-file edits and quick answers stay on the main model — don't delegate trivial work.

**When writing in my voice** (Jira updates, PR or issue replies, review comments), or when I say "my tone" / "โทนเสียงของผม":
- Sound like a teammate at my level (peer, เพื่อนร่วมงานระดับเดียวกัน): direct, calm, specific. Give the verdict (ข้อสรุป) first, one short reason ("because …"), then the next step.
- Write in English. Keep identifiers and ticket keys exactly as written.
- Keep it short. One fact per sentence or bullet. Drop the subject ("fixed", "not done yet").
- Say where the boundary (ขอบเขต) is: "only …", "not yet …", "waiting on PR merge".
- Use plain words, since readers aren't native English speakers. Short sentences, common vocabulary, no slop (ข้อความเยิ่นเย้อไร้สาระ).
- Own a mistake in one line, then give the right fact: "I got this wrong — …".
- Start with the content, end with the next step. No greeting, thanks, or emoji.
- Spell every word correctly.
