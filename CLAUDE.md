# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Full machine setup (tools + symlinks)
bash bootstrap.sh

# Apply/re-apply symlinks only
bash install.sh

# Remove all symlinks
bash install.sh prune

# Install Homebrew packages
bash homebrew/install.sh

# Install a specific module's symlinks
bash <module>/install.sh
```

## Architecture

This repo uses a **module-per-tool** layout. Each subdirectory owns its config files and an `install.sh` that creates the symlinks. The top-level `install.sh` iterates over all modules and calls their `install.sh` in order.

### Shared helpers — `lib.sh`

All install scripts source `lib.sh` for three helpers:
- `link <src> <dst>` — creates a symlink; backs up existing non-symlink files with `.bak`
- `unlink_path <dst>` — removes a symlink (used by `prune`)
- `brew_install` / `brew_cask_install` / `cmd_installed` — idempotent Homebrew wrappers

### Module overview

| Directory | Symlink target(s) |
|---|---|
| `zsh/` | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` |
| `git/` | `~/.gitconfig`, `~/.gitignore_global` |
| `wezterm/` | `~/.config/wezterm/wezterm.lua` |
| `zed/` | `~/.config/zed/settings.json`, `keymap.json`, `tasks.json` |
| `claude/` | `~/.claude/settings.json`, `~/.claude/CLAUDE.md` |
| `opencode/` | `~/.config/opencode/opencode.jsonc`, `~/.opencode/AGENTS.md` |
| `global-protect/` | `~/global-protect.sh` |
| `instructions/` | `~/instructions/*.md` |
| `gh-pr-notifier/` | macOS LaunchAgent (see its README) |

### Skills — `skills/`

`skills/install.sh` handles two things:
1. Installs npm-managed skills via `npx skills@latest add …`
2. Copies every subdirectory of `skills/` into `~/.agents/skills/`

Both Claude Code and opencode symlink to `~/.agents/skills`, so skills placed in `skills/` are available to both tools after running `bash skills/install.sh`. To add a new skill, create a `skills/<name>/SKILL.md` directory — it will be deployed automatically on the next install.

### Homebrew feature flags

`homebrew/.local` (gitignored, copied from `.local.example`) lets each machine opt out of optional packages without touching the shared `Brewfile`. Set `SKIP_<NAME>=1` to exclude a tap/formula/cask. The install script parses the Brewfile and builds the `HOMEBREW_BUNDLE_*_SKIP` env vars before running `brew bundle`.
