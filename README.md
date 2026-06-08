# dotfiles

Personal macOS dotfiles managed with symlinks.

## Installation

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
bash bootstrap.sh
```

`bootstrap.sh` handles everything from a clean Mac:

1. Installs Homebrew (if missing)
2. Installs Oh My Zsh (if missing)
3. Installs Rust (if missing)
4. Installs fnm, bun, uv via Homebrew / official installers
5. Installs apps: WezTerm, Zed, OrbStack
6. Runs `install.sh` to create all symlinks

### Symlinks only

To (re-)apply symlinks without installing tools:

```bash
bash install.sh
```

Existing files are backed up with a `.bak` suffix before being replaced.

### Remove symlinks

```bash
bash install.sh prune
```

## What's included

### zsh

Symlinked to `~/.zshrc`, `~/.zshenv`, `~/.zprofile`.

- Oh My Zsh with `robbyrussell` theme and `git` plugin
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) — fish-style inline suggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) — command highlighting as you type
- fnm shell integration
- bun, uv, OpenSSL environment setup
- Sources `~/global-protect.sh` for VPN helpers

### git

Symlinked to `~/.gitconfig` and `~/.gitignore_global`.

### WezTerm

Symlinked to `~/.config/wezterm/wezterm.lua`.

### Zed

Symlinked to `~/.config/zed/settings.json`, `~/.config/zed/keymap.json`, and `~/.config/zed/tasks.json`.

### Homebrew

All packages are declared in `homebrew/Brewfile` and installed via `brew bundle`. Includes:

- **Formulae**: cmake, fnm, gh, jq, openssl@3, uv, zsh, zsh-autosuggestions, zsh-syntax-highlighting
- **Optional formulae**: minikube (`SKIP_MINIKUBE`), vault (`SKIP_VAULT`)
- **Casks**: android-platform-tools, blackhole-2ch/64ch, font-meslo-lg-nerd-font, localsend, wezterm, zed
- **Optional casks**: orbstack (`SKIP_ORBSTACK`)

#### Per-machine feature flags

Optional packages can be disabled per machine without modifying the shared Brewfile:

```bash
cp homebrew/.local.example homebrew/.local
```

Then uncomment any packages to skip in `homebrew/.local`:

```bash
SKIP_ORBSTACK=1
SKIP_MINIKUBE=1
SKIP_VAULT=1
# ...
```

`homebrew/.local` is gitignored — each machine keeps its own copy.

Setting a flag skips the tap, formula, or cask entirely — `brew bundle` won't fetch, install, or upgrade it. The skip is logged during bootstrap so you can see what was excluded.

> **Note:** Always run Homebrew installs via the module script — not `brew bundle` directly — so feature flags are applied:
> ```bash
> bash ~/.dotfiles/homebrew/install.sh
> ```

### Claude Code

Symlinked to `~/.claude/settings.json` and `~/.claude/CLAUDE.md`.

### opencode

Symlinked to `~/.config/opencode/opencode.jsonc` and `~/.config/opencode/AGENTS.md`.

### Skills

Claude Code and opencode skills are managed via the `skills/` directory and symlinked into `~/.claude/skills` and `~/.config/opencode/skills`.

### GlobalProtect

`global-protect/global-protect.sh` is symlinked to `~/global-protect.sh` and sourced by `.zshrc`. Provides a `globalprotect` shell function for VPN management.

### gh-pr-notifier

A macOS LaunchAgent that sends a native dialog notification when there are open GitHub PRs waiting for your review. Runs on a configurable interval (default: 30 minutes). See [`gh-pr-notifier/README.md`](gh-pr-notifier/README.md) for full setup and usage.

**Quick start:**

```bash
cd gh-pr-notifier
bash install.sh yourname
```

## Structure

```
.dotfiles/
├── claude/             # Claude Code settings and CLAUDE.md
├── homebrew/           # Brewfile + install.sh
├── gh-pr-notifier/     # GitHub PR review notifier (LaunchAgent)
├── git/                # .gitconfig, .gitignore_global
├── global-protect/     # GlobalProtect VPN helper
├── opencode/           # opencode config and AGENTS.md
├── skills/             # Claude Code / opencode skills
├── wezterm/            # WezTerm config
├── zed/                # Zed settings, keymap, and tasks
├── zsh/                # .zshrc, .zshenv, .zprofile
├── bootstrap.sh        # Full machine setup (tools + symlinks)
├── check-deps.sh       # Dependency checker
├── install.sh          # Symlink installer / pruner
└── lib.sh              # Shared shell helpers
```
