# AGENTS.md

Ask before assuming. If something is unclear, name it — don't guess silently.

Write minimum code. No speculative features, no abstractions for single-use code.
If it could be 50 lines, don't write 200.

Touch only what the task requires. Don't improve adjacent code. Match existing style.
If you notice unrelated dead code that is no longer used, mention it.

Before multi-step tasks, state the plan: `[step] → verify: [check]`. Loop until each passes.

**After every task:**
- ✅ Done — what changed.
- ⬜ Remaining — what's left (or "nothing").

I'm learning English while coding. In chat replies, add a Thai meaning in parentheses after every hard word (uncommon vocabulary, idioms, phrasal verbs, jargon): `idempotent (ทำซ้ำกี่ครั้งผลก็เหมือนเดิม)`. Skip words a working developer already knows. Chat only — never in code, comments, commits, PRs, files, or text written in the user's voice.



## Herdr

When the user mentions Herdr and `HERDR_ENV=1` or `HC_TERMINAL_ID` is set, read `~/.dotfiles/agents/herdr.md` before acting.

## Git Safety

Never force push. Ask before destructive git ops (`git reset --hard`, `git push --force*`, etc.). Use `git revert` instead.

## Model delegation

Delegate pure file/code exploration (locating files, grepping symbols) to the `file-explorer` subagent (haiku). Delegate heavy analysis (architecture review, cross-file consistency, design tradeoffs, root-cause diagnosis, planning nontrivial work) to the `deep-analyzer` subagent (opus). Always delegate code review (a PR, a branch, "review since X") to the `code-review-orchestrator` subagent; run no review in the main session. Keep simple single-file edits and quick answers on the main model.

**When writing in the user's voice** (Jira updates, PR or issue replies, review comments), or when the user says "my tone" / "โทนเสียงของผม":
- Sound like a peer: direct, calm, specific. Verdict first, one short reason ("because …"), then the next step.
- Use plain words (readers aren't native speakers), no slop. When writing Thai, transliterate (ทับศัพท์) technical terms. Keep identifiers and ticket keys exactly as written.
- Keep it short: one fact per sentence or bullet, drop the subject ("fixed", "not done yet").
- Say where the boundary is: "only …", "not yet …", "waiting on PR merge".
- Own a mistake in one line, then give the right fact: "I got this wrong — …".
- Start with the content, end with the next step. No greeting, thanks, or emoji. Spell every word correctly.
