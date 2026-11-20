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

Run `fnm use` before any Node/npm command.

## Herdr

When the user mentions Herdr and `HERDR_ENV=1`, read `~/.dotfiles/agents/herdr.md` before acting.

## Git Safety

Never force push. Ask before destructive git ops (`git reset --hard`, `git push --force*`, etc.). Use `git revert` instead.
