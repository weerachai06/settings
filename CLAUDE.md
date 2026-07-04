# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build the config without activating (verify it evaluates)
nix build '.#homeConfigurations.x86_64-linux.activationPackage'

# Activate (no sudo). Use the matching system arch.
home-manager switch --flake '.#x86_64-linux'   # or .#aarch64-linux
# first time, before home-manager is on PATH:
nix run nixpkgs#home-manager -- switch --flake '.#x86_64-linux'

# Update flake inputs (regenerate flake.lock)
nix flake update

# Script-based pieces (deliberately not in Nix — see ADR-0002)
bash gh-pr-notifier/install.sh <name>
bash global-protect/install.sh
bash skills/install.sh
```

## Agent skills

### Issue tracker

Issues and PRDs live as markdown files in `.scratch/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Using default canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context repo with optional `CONTEXT.md` and `docs/adr/` at the root. See `docs/agents/domain.md`.

## Git Safety

Never force push. Ask before destructive git ops (`git reset --hard`, `git push --force*`, etc.). Use `git revert` instead.

## Architecture

This repo is a **home-manager standalone** flake (`nixpkgs-unstable`). It manages the
user dev environment only — no nix-darwin, no system config, no sudo. See
[`CONTEXT.md`](CONTEXT.md): a **tool config** is a per-tool directory of files; a
**module** is a Nix config unit; a **home config** is a `homeConfigurations.<system>`.

### Layout

- `flake.nix` — inputs (nixpkgs, home-manager) + `homeConfigurations.<system>`
- `home.nix` — the entire portable dev env (CLI packages, `programs.git`,
  `programs.zsh`, app config symlinks). Username is one `let` binding.

### Config style (hybrid)

- **Native modules** where Nix adds value and translation is clean — `programs.git`, `programs.zsh`
- **Symlinks** (`home.file`/`xdg.configFile`) for files better left native — wezterm, zed, opencode, claude. App-writable configs use `config.lib.file.mkOutOfStoreSymlink` to the repo so the apps can still write them.
- OS-specific shell bits are guarded with `lib.optionalString pkgs.stdenv.isDarwin`.

### Deliberately outside Nix (see ADR-0002)

GUI apps (orbstack, zed, wezterm, codexbar, fonts) are installed manually.
`gh-pr-notifier/`, `global-protect/`, and `skills/` retain their own `install.sh`.
bun, rust, and opencode use their own installers.
