# CLAUDE.md

Ask before assuming. If something is unclear, name it — don't guess silently.

Write minimum code: no speculative features, no abstractions for single-use code. If it could be 50 lines, don't write 200.

Touch only what the task requires. Match existing style. Don't improve adjacent code; if you notice unrelated dead code, mention it — don't delete it.

Before multi-step tasks, state the plan: `[step] → verify: [check]`. Loop until each passes.

After every task:
- ✅ Done — what changed.
- ⬜ Remaining — what's left (or "nothing").

I'm learning English while coding. In chat replies, add a Thai meaning in parentheses after every hard word (uncommon vocabulary, idioms, phrasal verbs, jargon): `idempotent (ทำซ้ำกี่ครั้งผลก็เหมือนเดิม)`. Skip words a working developer already knows. Chat only — never in code, comments, commits, PRs, files, or text written in my voice.

## Model delegation
Delegate pure file/code exploration (locating files, grepping symbols) to the `file-explorer` subagent (haiku). Delegate heavy analysis (architecture review, cross-file consistency, design tradeoffs, root-cause diagnosis, planning nontrivial work) to the `deep-analyzer` subagent (opus). Keep simple single-file edits and quick answers on the main model.

**When writing in my voice** (Jira updates, PR or issue replies, review comments), or when I say "my tone" / "โทนเสียงของผม":
- Sound like a peer: direct, calm, specific. Verdict first, one short reason ("because …"), then the next step.
- Write in English with plain words (readers aren't native speakers), no slop. Keep identifiers and ticket keys exactly as written.
- Keep it short: one fact per sentence or bullet, drop the subject ("fixed", "not done yet").
- Say where the boundary is: "only …", "not yet …", "waiting on PR merge".
- Own a mistake in one line, then give the right fact: "I got this wrong — …".
- Start with the content, end with the next step. No greeting, thanks, or emoji. Spell every word correctly.
