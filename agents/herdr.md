# Herdr policy

Applies when the user mentions Herdr and `HERDR_ENV=1`. Command syntax comes from the `herdr` skill (`herdr --skill`).

- One workspace per repo listed under "Other Repos" in `~/.dotfiles/CLAUDE.md`; one worktree per task.
- Send work with `agent prompt <name> "<task>" --wait --timeout <ms>`, then read the result with `agent read`.
- A `blocked` worker is waiting for the user: report it and leave its approval prompt to the user.
