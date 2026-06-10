# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build the macOS config without activating (verify it evaluates)
nix build '.#darwinConfigurations.mac-mini.system'

# Apply the macOS config
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake '.#mac-mini'

# Update flake inputs (regenerate flake.lock)
nix flake update

# Not-yet-migrated modules (still script-based)
bash gh-pr-notifier/install.sh <name>
bash global-protect/install.sh
bash skills/install.sh
```

> Migration status: the Nix flake replaces the old `bootstrap.sh`/`install.sh`
> shell installers but has not yet been built/verified (no `flake.lock` yet).
> See `docs/adr/0001-cross-platform-nix-migration.md`.

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

This repo is a single **Nix flake** (`nixpkgs-unstable`) providing both
`darwinConfigurations` (macOS via nix-darwin) and `nixosConfigurations` (NixOS),
sharing one home-manager layer. See `docs/agents/domain.md` terminology in
[`CONTEXT.md`](CONTEXT.md): a **tool config** is a per-tool directory of files; a
**module** is a Nix config unit; a **host** is a named machine config.

### Layout

- `flake.nix` — inputs (nixpkgs, nix-darwin, home-manager) and host outputs
- `home/` — **shared layer**: home-manager config applied to every host
  (CLI packages, `programs.git`, `programs.zsh`, app config symlinks)
- `hosts/<host>/` — **darwin/nixos layer**: per-host system config (e.g.
  `hosts/mac-mini/` holds the nix-darwin system + `homebrew` cask block)

### Config style (hybrid)

- **Native modules** where Nix adds value and translation is clean — `programs.git`, `programs.zsh`
- **Symlinks** (`home.file`/`xdg.configFile`) for files better left native — wezterm, zed, opencode, claude. App-writable configs use `config.lib.file.mkOutOfStoreSymlink` to the repo so the apps can still write them.

### Per-host configuration

Each host declares its own package set in `hosts/<host>/`. This replaces the old
gitignored `SKIP_*` Homebrew feature flags — there is no shared opt-out list.

### Still script-based (not yet migrated)

`gh-pr-notifier/`, `global-protect/`, and `skills/` retain their own `install.sh`.
bun, rust, and opencode installers are not yet ported to Nix.
