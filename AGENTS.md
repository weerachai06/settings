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
bash agents/skills/install.sh   # links agents/skills and agents/mods into the tools

# opencode v2 (beta) + cursor-rules plugin deps — symlinks/config are in home.nix
bash agents/opencode/install.sh
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
- `agents/` — coding-agent setup (formerly the Home Repo): `skills/`, `mods/`,
  and per-tool `claude/`, `kiro/`, `opencode/` (instructions, subagents, settings).
  `home.nix` symlinks them from here; `agents/skills/install.sh` links skills and mods.

### Config style (hybrid)

- **Native modules** where Nix adds value and translation is clean — `programs.git`, `programs.zsh`
- **Symlinks** (`home.file`/`xdg.configFile`) for files better left native — wezterm, zed, opencode, claude. App-writable configs use `config.lib.file.mkOutOfStoreSymlink` to the repo so the apps can still write them.
- OS-specific shell bits are guarded with `lib.optionalString pkgs.stdenv.isDarwin`.

### Deliberately outside Nix (see ADR-0002)

GUI apps (orbstack, zed, wezterm, codexbar, fonts) are installed manually.
`gh-pr-notifier/`, `global-protect/`, and `agents/opencode/` retain their own `install.sh`.
`agents/skills/` and the shared agent files (`agents/claude/CLAUDE.md`, `agents/claude/agents/`, `agents/kiro/AGENTS.md`, `agents/opencode/AGENTS.md`) live in `agents/`; `home.nix` symlinks them from there.
bun, rust, and opencode use their own installers.

## Other Repos

- kpc-web-frontend-2 (KPC Web Frontend 2, Next.js 15 + TypeScript app): ~/Documents/projects/kpc-web-frontend-2. Clone from git@github.com:kingpowerclick/kpc-web-frontend-2.git if missing. Read its AGENTS.md first. Branches: `KPGDX-XXXXX/feature-name`.
- kpc-web-backoffice-2 (Back Office 2.0): ~/Documents/projects/kpc-web-backoffice-2. Clone from git@github.com:kingpowerclick/kpc-web-backoffice-2.git if missing. Read its AGENTS.md first.
- kpc-web-frontend (KP Web Frontend): ~/Documents/projects/kpc-web-frontend. Clone from git@github.com:kingpowerclick/kpc-web-frontend.git if missing. No AGENTS.md; see .github/copilot-instructions.md.
- crown-design-tokens (Crown design tokens monorepo): ~/Documents/projects/crown-design-tokens. Clone from git@github.com:kingpowerclick/crown-design-tokens.git if missing. Read its CLAUDE.md first (its AGENTS.md only points there); CONTEXT.md has the glossary.

## Herdr

Use only when I mention Herdr and `HERDR_ENV=1`. Run `herdr --skill` for exact syntax.

- One workspace per repo in "Other Repos"; one worktree per task (`herdr worktree create --branch <name>`).
- Send work with `herdr agent prompt <name> "<task>" --wait --timeout <ms>`, then `herdr agent read`.
- A `blocked` worker is waiting for me. Never answer its approval prompt; report it.
