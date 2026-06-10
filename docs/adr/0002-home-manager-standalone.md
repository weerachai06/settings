# Use home-manager standalone instead of nix-darwin + NixOS hosts

## Status

accepted (supersedes ADR-0001's architecture)

## Context

ADR-0001 chose a single flake with `darwinConfigurations` + `nixosConfigurations`
sharing a home-manager layer. In practice the actual goal is narrower: **give each
machine a similar dev environment**, not manage whole machines. The nix-darwin /
NixOS-host approach pulled in machine-level coupling that the goal doesn't need —
per-host system config, hostnames, a `users.users.<name>`, `system.primaryUser`,
a generated `hardware-configuration.nix`, sudo, and `nix.enable = false` to coexist
with the Determinate installer.

## Decision

Manage only the user environment with **home-manager standalone**. A single
`home.nix` is exposed as `homeConfigurations.<system>` for each system arch, applied
with `home-manager switch --flake .#<system>` — no sudo, no system config, no
per-host files. Username lives in one `let` binding; OS-specific shell integration is
guarded with `lib.optionalString pkgs.stdenv.isDarwin`.

What this drops versus ADR-0001:

- **Homebrew casks** are no longer declarative — GUI apps (orbstack, zed, wezterm,
  codexbar, fonts) are installed manually.
- **`gh-pr-notifier`** and **`global-protect`** stay script-based (their `install.sh`).
- **No NixOS system management** — only the dev env is shared across machines.

What it keeps: CLI tools, git, zsh (+ oh-my-zsh/plugins), and all app config symlinks,
verified building on `aarch64-darwin` and evaluating on `x86_64-linux`.

## Considered Options

- **nix-darwin + NixOS hosts (ADR-0001).** Rejected: machine-level scope and coupling
  beyond the "shared dev env" goal; requires sudo and per-host hardware config.
- **`nix shell` / `nix profile` only.** Rejected: ephemeral / packages-only; does not
  place config files or manage the shell.

## Consequences

- Activation is `home-manager switch`, not `darwin-rebuild` — no system mutation, no sudo.
- GUI apps and macOS services are now outside Nix; that tradeoff is accepted for a much
  simpler, genuinely portable config.
