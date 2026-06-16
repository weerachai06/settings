# dotfiles

A personal, portable development environment managed with **home-manager standalone**.
One config (`home.nix`) gives every machine — macOS or Linux — the same dev setup:
CLI tools, zsh, git, and app configs. No system management, no sudo.

See [ADR-0002](docs/adr/0002-home-manager-standalone.md) for the design,
[`CONTEXT.md`](CONTEXT.md) for terminology, and
[`docs/programs/`](docs/programs/) for per-tool usage docs.

## Installation

1. Install Nix (e.g. the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Clone and activate (pick your system arch):

   ```bash
   git clone <repo-url> ~/.dotfiles
   cd ~/.dotfiles

   # first time
   nix run home-manager/master -- switch --flake '.#aarch64-darwin'
   # afterwards
   home-manager switch --flake '.#aarch64-darwin'
   ```

   Configs available: `aarch64-darwin` (Mac), `x86_64-linux`, `aarch64-linux`.

   To check it builds without activating:

   ```bash
   nix build '.#homeConfigurations.aarch64-darwin.activationPackage'
   ```

## What home-manager manages

- **CLI tools** — `cmake`, `fnm`, `gh`, `jq`, `openssl`, `uv`
- **git** — `programs.git` (user, `adog` alias, `pull.rebase`, global ignores)
- **zsh** — Oh My Zsh (`robbyrussell`, `git` plugin), autosuggestions,
  syntax-highlighting, fnm, uv completion. macOS-only integrations (brew, orbstack,
  global-protect, bun, opencode, cargo) are guarded with `isDarwin`.
- **App configs** — wezterm, zed, opencode, claude via `home.file`/`xdg.configFile`.
  App-writable configs use out-of-store symlinks so the apps can still write them.

The username lives in one `let` binding in `home.nix`; change that one line per user.

## Not managed by Nix (deliberately — see ADR-0002)

- **GUI apps** — orbstack, zed, wezterm, codexbar, fonts: install manually
- **`gh-pr-notifier/`** — macOS LaunchAgent; `bash gh-pr-notifier/install.sh <name>`
- **`global-protect/`** — macOS VPN helper; `global-protect/install.sh`
- **`skills/`** — `bash skills/install.sh`
- **bun, rust, opencode** — installed via their own installers

## Structure

```
.dotfiles/
├── flake.nix           # inputs + homeConfigurations.<system>
├── home.nix            # the portable dev env (packages, git, zsh, app configs)
├── claude/             # Claude Code settings and CLAUDE.md
├── gh-pr-notifier/     # GitHub PR review notifier (LaunchAgent) — not in Nix
├── global-protect/     # GlobalProtect VPN helper — not in Nix
├── opencode/           # opencode config and AGENTS.md
├── skills/             # Claude Code / opencode skills — not in Nix
├── wezterm/            # WezTerm config
├── zed/                # Zed settings, keymap, and tasks
├── check-deps.sh       # Dependency checker
├── CONTEXT.md          # Domain glossary
├── docs/programs/      # Per-tool usage docs
└── docs/adr/           # Architecture decision records
```
