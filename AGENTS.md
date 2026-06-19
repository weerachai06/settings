# AGENTS.md

Guidance for AI agents (kiro-cli, opencode, etc.) working in this repository.

## Working style

Ask before assuming. If something is unclear, name it — don't guess silently.

Write minimum code. No speculative features, no abstractions for single-use code.
If it could be 50 lines, don't write 200.

Touch only what the task requires. Don't improve adjacent code. Match existing style.
If you notice unrelated dead code, mention it — don't delete it.

Before multi-step tasks, state the plan: `[step] → verify: [check]`. Loop until each passes.

**After every task:**
- ✅ Done — what changed.
- ⬜ Remaining — what's left (or "nothing").

Never use `/tmp`. Use `./tmp` at project root.
Run `fnm use` before any Node/npm command.

## Commands

```bash
# Build the config without activating (verify it evaluates)
nix build '.#homeConfigurations.aarch64-darwin.activationPackage'

# Activate (no sudo). Use the matching system arch.
home-manager switch --flake '.#aarch64-darwin'   # or .#x86_64-linux
# first time, before home-manager is on PATH:
nix run home-manager/master -- switch --flake '.#aarch64-darwin'

# Update flake inputs (regenerate flake.lock)
nix flake update

# Script-based pieces (deliberately not in Nix — see ADR-0002)
bash gh-pr-notifier/install.sh <name>
bash global-protect/install.sh
bash skills/install.sh
```

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
