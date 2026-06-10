# dotfiles

Personal cross-platform machine configuration managed with **Nix** (a single flake
for macOS via nix-darwin and NixOS), sharing a common home-manager layer.

> **Status: migration in progress, not yet verified.** The shell-script installer
> has been removed in favour of the Nix flake, but the flake has not yet been built
> on a machine with Nix installed (no `flake.lock` is committed yet). The first
> `darwin-rebuild`/`nix build` may surface eval errors that need fixing. See
> [ADR-0001](docs/adr/0001-cross-platform-nix-migration.md) for the design and
> [`CONTEXT.md`](CONTEXT.md) for terminology.

## Installation

1. Install Nix with the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Clone and build:

   ```bash
   git clone <repo-url> ~/.dotfiles
   cd ~/.dotfiles

   # macOS (Mac mini host):
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake '.#mac-mini'

   # NixOS host (not yet defined — Phase 8):
   # sudo nixos-rebuild switch --flake '.#<host>'
   ```

   To verify the config builds without activating it:

   ```bash
   nix build '.#darwinConfigurations.mac-mini.system'
   ```

## What Nix manages

- **CLI tools** (`cmake`, `fnm`, `gh`, `jq`, `openssl`, `uv`) — from nixpkgs, shared layer
- **git** — `programs.git` (user, `adog` alias, `pull.rebase`, global ignores)
- **zsh** — `programs.zsh`: Oh My Zsh (`robbyrussell`, `git` plugin), autosuggestions,
  syntax-highlighting, fnm `env --use-on-cd`, uv completion
- **App configs** — wezterm, zed, opencode, claude via `home.file`/`xdg.configFile`.
  App-writable configs (claude/zed settings, `opencode.jsonc`) use out-of-store
  symlinks so the apps can still write to them.
- **Casks** — orbstack, wezterm, zed, codexbar, fonts, blackhole, android-platform-tools,
  localsend, plus `vault`/`minikube` brews — declared through nix-darwin's `homebrew` block

### Per-machine differences

Each host (`darwinConfigurations.<host>`, `nixosConfigurations.<host>`) declares its own
package set in `hosts/<host>/`. This replaces the old gitignored `SKIP_*` feature flags.

## Not yet migrated (still script-based or pending)

- **`gh-pr-notifier/`** — macOS LaunchAgent; run `bash gh-pr-notifier/install.sh <name>` (Phase: follow-up for NixOS parity)
- **`global-protect/`** — macOS VPN helper; `global-protect/install.sh`, sourced by `.zshrc`
- **`skills/`** — `bash skills/install.sh`
- **bun, rust, opencode** — installers not yet ported to Nix
- **Deferred zsh lines** — `brew shellenv`, orbstack, global-protect, bun, opencode,
  cargo env, openssl env vars (to move into the darwin layer)

## Structure

```
.dotfiles/
├── flake.nix           # nixpkgs-unstable, nix-darwin, home-manager
├── home/               # shared home-manager layer (git, zsh, packages, app configs)
├── hosts/
│   └── mac-mini/       # macOS host (nix-darwin system + homebrew casks)
├── claude/             # Claude Code settings and CLAUDE.md
├── gh-pr-notifier/     # GitHub PR review notifier (LaunchAgent) — not migrated
├── git/                # .gitconfig, .gitignore_global (now inlined in home/)
├── global-protect/     # GlobalProtect VPN helper — not migrated
├── opencode/           # opencode config and AGENTS.md
├── skills/             # Claude Code / opencode skills — not migrated
├── wezterm/            # WezTerm config
├── zed/                # Zed settings, keymap, and tasks
├── zsh/                # .zshrc, .zshenv, .zprofile (config files; superseded by home/)
├── check-deps.sh       # Dependency checker
├── CONTEXT.md          # Domain glossary
└── docs/adr/           # Architecture decision records
```
