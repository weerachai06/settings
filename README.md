# dotfiles

Personal macOS dotfiles managed with symlinks.

## Requirements

- macOS
- [Homebrew](https://brew.sh/)
- [GitHub CLI (`gh`)](https://cli.github.com/) — for `gh-pr-notifier`
- [Oh My Zsh](https://ohmyz.sh/) — for zsh config
- [fnm](https://github.com/Schniz/fnm) — Node version manager
- [WezTerm](https://wezfurlong.org/wezterm/) — terminal emulator
- [Zed](https://zed.dev/) — editor

## Installation

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
bash check-deps.sh   # verify dependencies
bash install.sh
```

`install.sh` installs brew packages, then creates symlinks from `~` (and `~/.config`) to files in this repo. Existing files are backed up with a `.bak` suffix before being replaced.

To remove all symlinks:

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

Symlinked to `~/.gitconfig`.

### WezTerm

Symlinked to `~/.config/wezterm/wezterm.lua`.

### Zed

Symlinked to `~/.config/zed/settings.json` and `~/.config/zed/keymap.json`.

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
├── gh-pr-notifier/     # GitHub PR review notifier (LaunchAgent)
├── git/                # .gitconfig
├── global-protect/     # GlobalProtect VPN helper
├── wezterm/            # WezTerm config
├── zed/                # Zed settings and keymap
├── zsh/                # .zshrc, .zshenv, .zprofile
├── check-deps.sh       # Dependency checker
└── install.sh          # Symlink installer / pruner
```
