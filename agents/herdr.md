# Herdr policy

Applies when the user mentions Herdr. Check which Herdr you are in:

- `HERDR_ENV=1`: the Herdr terminal UI. Use the `herdr` skill (`herdr --skill`) and the TUI rules below.
- `HC_TERMINAL_ID` set: the Herdr desktop app. Use the `hc` skill (`hc --skill`) for messaging and the `herdr-app` skill only to change the layout. `herdr pane` and `herdr agent` do not see the app's terminals.

## Desktop app

- Send work with `hc send --wait <t> "<task>"`, then read the result with `hc read --lines 100 <t>`.
- A `blocked` terminal is waiting for the user: report it and leave its prompt to the user.
- Do not send to terminals you did not start unless the user names the target.

## Terminal UI

- One workspace per repo listed under "Other Repos" in `~/.dotfiles/CLAUDE.md`; one worktree per task.
- Send work with `agent prompt <name> "<task>" --wait --timeout <ms>`, then read the result with `agent read`.
- A `blocked` worker is waiting for the user: report it and leave its approval prompt to the user.
