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

Never use `/tmp`. Use `./tmp` at project root.
Run `fnm use` before any Node/npm command.

## Model delegation
For pure file/code exploration (locating files, grepping symbols, "where is X defined"), delegate to the `file-explorer` subagent (haiku) instead of doing it inline.
For heavy analysis (architecture review, cross-file consistency, design tradeoffs, root-cause diagnosis, planning nontrivial implementations), delegate to the `deep-analyzer` subagent (opus) instead of doing it inline.
Simple, single-file edits and quick answers stay on the main model — don't delegate trivial work.
